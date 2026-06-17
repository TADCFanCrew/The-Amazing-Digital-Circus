package audio;

import flixel.FlxG;
import flixel.system.FlxSound;

class Audio
{
	static var musicVolume:Float  = 1.0;
	static var soundVolume:Float  = 1.0;
	static var muted:Bool         = false;

	public static function playMusic(key:String, ?volume:Float, loop:Bool = true):Void
	{
		var vol = (volume != null ? volume : musicVolume) * (muted ? 0.0 : 1.0);

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		FlxG.sound.playMusic(Paths.music(key), vol, loop);
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

	public static function playSound(key:String, ?volume:Float):FlxSound
	{
		var vol = (volume != null ? volume : soundVolume) * (muted ? 0.0 : 1.0);
		return FlxG.sound.play(Paths.sound(key), vol);
	}

	public static function setMusicVolume(v:Float):Void
	{
		musicVolume = clamp(v);
		if (FlxG.sound.music != null && !muted)
			FlxG.sound.music.volume = musicVolume;
	}

	public static function setSoundVolume(v:Float):Void
	{
		soundVolume = clamp(v);
		FlxG.sound.defaultSoundGroup.volume = muted ? 0.0 : soundVolume;
	}

	public static function setMuted(v:Bool):Void
	{
		muted = v;
		FlxG.sound.muted = v;
	}

	public static function toggleMute():Void
	{
		setMuted(!muted);
	}

	public static function isMusicPlaying():Bool
	{
		return FlxG.sound.music != null && FlxG.sound.music.playing;
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

	public static function fadeInMusic(duration:Float = 1.0):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeIn(duration, 0.0, musicVolume);
	}

	public static function fadeOutMusic(duration:Float = 1.0, ?onComplete:Void->Void):Void
	{
		if (FlxG.sound.music == null) return;

		FlxG.sound.music.fadeOut(duration, 0.0, _ ->
		{
			FlxG.sound.music.stop();
			if (onComplete != null) onComplete();
		});
	}

	public static function crossfade(key:String, duration:Float = 1.0, loop:Bool = true):Void
	{
		fadeOutMusic(duration, () -> playMusic(key, musicVolume, loop));
	}

	inline static function clamp(v:Float):Float
	{
		return Math.max(0.0, Math.min(1.0, v));
	}
}
