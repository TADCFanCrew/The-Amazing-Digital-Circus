package audio.master;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

typedef BusState = {
	var volume:Float;
	var muted:Bool;
}

typedef PooledSound = {
	var sound:FlxSound;
	var inUse:Bool;
}

class AudioMaster
{
	static var buses:Map<String, BusState> = [
		"music"   => {volume: 1.0, muted: false},
		"sfx"     => {volume: 1.0, muted: false},
		"voice"   => {volume: 1.0, muted: false},
		"ambient" => {volume: 1.0, muted: false}
	];

	static var pool:Array<PooledSound>  = [];
	static var queue:Array<String>      = [];
	static var masterVolume:Float       = 1.0;
	static var masterMuted:Bool         = false;
	static var duckActive:Bool          = false;
	static var duckTarget:Float         = 0.3;
	static var duckDuration:Float       = 0.3;
	static var beatCallbacks:Array<Void->Void> = [];
	static var beatInterval:Float       = 0.5;
	static var beatTimer:Float          = 0.0;
	static var amplitudeHistory:Array<Float> = [];
	static inline var POOL_SIZE:Int     = 16;
	static inline var HISTORY_SIZE:Int  = 64;

	public static function init():Void
	{
		for (i in 0...POOL_SIZE)
		{
			var s = FlxG.sound.load("", 1.0, false);
			s.stop();
			pool.push({sound: s, inUse: false});
		}
	}

	public static function update(elapsed:Float):Void
	{
		for (entry in pool)
			if (entry.inUse && !entry.sound.playing)
				entry.inUse = false;

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			var amp = getAmplitude();
			amplitudeHistory.push(amp);
			if (amplitudeHistory.length > HISTORY_SIZE)
				amplitudeHistory.shift();

			beatTimer += elapsed;
			if (beatTimer >= beatInterval)
			{
				beatTimer = 0.0;
				if (isBeat())
					for (cb in beatCallbacks) cb();
			}
		}

		if (queue.length > 0 && (FlxG.sound.music == null || !FlxG.sound.music.playing))
			playMusicFromQueue();
	}

	public static function playMusic(key:String, loop:Bool = true, fadeIn:Float = 0.0):Void
	{
		var vol = getBusVolume("music");

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		if (fadeIn > 0)
		{
			FlxG.sound.playMusic(backend.Paths.music(key), 0.0, loop);
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeIn(fadeIn, 0.0, vol);
		}
		else
		{
			FlxG.sound.playMusic(backend.Paths.music(key), vol, loop);
		}
	}

	public static function stopMusic():Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
	}

	public static function pauseMusic():Void
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.pause();
	}

	public static function resumeMusic():Void
	{
		if (FlxG.sound.music != null && !FlxG.sound.music.playing)
			FlxG.sound.music.resume();
	}

	public static function isMusicPlaying():Bool
	{
		return FlxG.sound.music != null && FlxG.sound.music.playing;
	}

	public static function fadeInMusic(duration:Float = 1.0):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeIn(duration, 0.0, getBusVolume("music"));
	}

	public static function fadeOutMusic(duration:Float = 1.0, ?onComplete:Void->Void):Void
	{
		if (FlxG.sound.music == null)
		{
			if (onComplete != null) onComplete();
			return;
		}

		FlxG.sound.music.fadeOut(duration, 0.0, _ ->
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			if (onComplete != null) onComplete();
		});
	}

	public static function crossfade(key:String, duration:Float = 1.0, loop:Bool = true):Void
	{
		fadeOutMusic(duration, () -> playMusic(key, loop, duration));
	}

	public static function playSound(key:String, ?bus:String, volumeScale:Float = 1.0):FlxSound
	{
		var busName = bus != null ? bus : "sfx";
		var vol     = getBusVolume(busName) * clamp(volumeScale);
		var entry   = getFreeSlot();

		if (entry != null)
		{
			entry.sound.loadEmbedded(backend.Paths.sound(key), false);
			entry.sound.volume = vol;
			entry.sound.play();
			entry.inUse = true;
			return entry.sound;
		}

		return FlxG.sound.play(backend.Paths.sound(key), vol);
	}

	public static function stopAllSounds():Void
	{
		for (entry in pool)
		{
			if (entry.inUse)
			{
				entry.sound.stop();
				entry.inUse = false;
			}
		}
	}

	public static function setBusVolume(bus:String, volume:Float):Void
	{
		if (!buses.exists(bus)) return;
		buses[bus].volume = clamp(volume);
		applyBusVolume(bus);
	}

	public static function getBusVolumeRaw(bus:String):Float
	{
		return buses.exists(bus) ? buses[bus].volume : 1.0;
	}

	public static function setBusMuted(bus:String, muted:Bool):Void
	{
		if (!buses.exists(bus)) return;
		buses[bus].muted = muted;
		applyBusVolume(bus);
	}

	public static function isBusMuted(bus:String):Bool
	{
		return buses.exists(bus) ? buses[bus].muted : false;
	}

	public static function getBusVolume(bus:String):Float
	{
		if (!buses.exists(bus)) return masterVolume * (masterMuted ? 0.0 : 1.0);
		var b = buses[bus];
		return b.muted ? 0.0 : b.volume * masterVolume * (masterMuted ? 0.0 : 1.0);
	}

	public static function setMasterVolume(v:Float):Void
	{
		masterVolume = clamp(v);
		for (bus in buses.keys()) applyBusVolume(bus);
	}

	public static function getMasterVolume():Float
	{
		return masterVolume;
	}

	public static function setMasterMuted(v:Bool):Void
	{
		masterMuted = v;
		FlxG.sound.muted = v;
		for (bus in buses.keys()) applyBusVolume(bus);
	}

	public static function isMasterMuted():Bool
	{
		return masterMuted;
	}

	public static function toggleMasterMute():Void
	{
		setMasterMuted(!masterMuted);
	}

	public static function duck(?target:Float, ?duration:Float):Void
	{
		if (FlxG.sound.music == null) return;
		if (target   != null) duckTarget   = clamp(target);
		if (duration != null) duckDuration = duration;
		if (duckActive) return;
		duckActive = true;
		FlxTween.cancelTweensOf(FlxG.sound.music);
		FlxTween.tween(FlxG.sound.music, {volume: duckTarget * getBusVolume("music")}, duckDuration, {ease: FlxEase.quadOut});
	}

	public static function unduck(?duration:Float):Void
	{
		if (FlxG.sound.music == null || !duckActive) return;
		var dur = duration != null ? duration : duckDuration;
		duckActive = false;
		FlxTween.cancelTweensOf(FlxG.sound.music);
		FlxTween.tween(FlxG.sound.music, {volume: getBusVolume("music")}, dur, {ease: FlxEase.quadIn});
	}

	public static function isDucking():Bool
	{
		return duckActive;
	}

	public static function enqueue(key:String):Void
	{
		queue.push(key);
	}

	public static function enqueueAll(keys:Array<String>):Void
	{
		for (k in keys) queue.push(k);
	}

	public static function clearQueue():Void
	{
		queue = [];
	}

	public static function queueLength():Int
	{
		return queue.length;
	}

	public static function onBeat(cb:Void->Void):Void
	{
		beatCallbacks.push(cb);
	}

	public static function removeBeatListener(cb:Void->Void):Void
	{
		beatCallbacks.remove(cb);
	}

	public static function clearBeatListeners():Void
	{
		beatCallbacks = [];
	}

	public static function setBeatInterval(interval:Float):Void
	{
		beatInterval = interval;
	}

	public static function setBPM(bpm:Float):Void
	{
		if (bpm <= 0) return;
		beatInterval = 60.0 / bpm;
	}

	public static function getAmplitude():Float
	{
		return FlxG.sound.music != null ? FlxG.sound.music.amplitude : 0.0;
	}

	public static function getAmplitudeHistory():Array<Float>
	{
		return amplitudeHistory.copy();
	}

	public static function getAverageAmplitude():Float
	{
		if (amplitudeHistory.length == 0) return 0.0;
		var sum = 0.0;
		for (v in amplitudeHistory) sum += v;
		return sum / amplitudeHistory.length;
	}

	public static function getMusicTime():Float
	{
		return FlxG.sound.music != null ? FlxG.sound.music.time : 0.0;
	}

	public static function setMusicTime(ms:Float):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.time = ms;
	}

	public static function getMusicLength():Float
	{
		return FlxG.sound.music != null ? FlxG.sound.music.length : 0.0;
	}

	public static function reset():Void
	{
		stopMusic();
		stopAllSounds();
		clearQueue();
		clearBeatListeners();
		duckActive = false;
		beatTimer  = 0.0;
		amplitudeHistory = [];
	}

	static function playMusicFromQueue():Void
	{
		var next = queue.shift();
		playMusic(next, false);
	}

	static function applyBusVolume(bus:String):Void
	{
		if (bus == "music" && FlxG.sound.music != null && !duckActive)
			FlxG.sound.music.volume = getBusVolume("music");

		for (entry in pool)
			if (entry.inUse)
				entry.sound.volume = getBusVolume(bus);
	}

	static function getFreeSlot():PooledSound
	{
		for (entry in pool)
			if (!entry.inUse) return entry;
		return null;
	}

	static function isBeat():Bool
	{
		if (amplitudeHistory.length < 2) return false;
		var current = amplitudeHistory[amplitudeHistory.length - 1];
		var avg = getAverageAmplitude();
		return current > avg * 1.3;
	}

	static inline function clamp(v:Float):Float
	{
		return Math.max(0.0, Math.min(1.0, v));
	}
}