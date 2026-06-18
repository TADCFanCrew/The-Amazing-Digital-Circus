package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;
import openfl.events.Event;
import intro.IntroState;
import audio.master.AudioMaster;

class Main extends Sprite
{
	#if mobile
	static inline final GAME_WIDTH:Int  = 0;
	static inline final GAME_HEIGHT:Int = 0;
	#else
	static inline final GAME_WIDTH:Int  = 1280;
	static inline final GAME_HEIGHT:Int = 720;
	#end

	static inline final FRAMERATE:Int   = 60;
	static inline final SAVE_NAME:String = "tadc_fangame";
	static inline final SAVE_ID:String   = "com.tadc.fangame";

	var game:FlxGame;

	public function new()
	{
		super();

		game = new FlxGame(GAME_WIDTH, GAME_HEIGHT, IntroState, FRAMERATE, FRAMERATE, true);
		addChild(game);

		setupSave();
		setupGame();
		setupAudio();
	}

	function setupSave():Void
	{
		FlxG.save.bind(SAVE_NAME, SAVE_ID);

		if (!FlxG.save.data.initialized)
		{
			FlxG.save.data.initialized   = true;
			FlxG.save.data.masterVolume  = 0.8;
			FlxG.save.data.musicVolume   = 1.0;
			FlxG.save.data.sfxVolume     = 1.0;
			FlxG.save.data.voiceVolume   = 1.0;
			FlxG.save.data.ambientVolume = 1.0;
			FlxG.save.data.muted         = false;
			FlxG.save.data.language      = "en-US";
			FlxG.save.flush();
		}
	}

	function loadSaveIntoAudio():Void
	{
		AudioMaster.setMasterVolume(getSaveFloat("masterVolume", 0.8));
		AudioMaster.setBusVolume("music",   getSaveFloat("musicVolume",   1.0));
		AudioMaster.setBusVolume("sfx",     getSaveFloat("sfxVolume",     1.0));
		AudioMaster.setBusVolume("voice",   getSaveFloat("voiceVolume",   1.0));
		AudioMaster.setBusVolume("ambient", getSaveFloat("ambientVolume", 1.0));
		AudioMaster.setMasterMuted(getSaveBool("muted", false));
	}

	public static function saveAudioSettings():Void
	{
		FlxG.save.data.masterVolume  = AudioMaster.getMasterVolume();
		FlxG.save.data.musicVolume   = AudioMaster.getBusVolumeRaw("music");
		FlxG.save.data.sfxVolume     = AudioMaster.getBusVolumeRaw("sfx");
		FlxG.save.data.voiceVolume   = AudioMaster.getBusVolumeRaw("voice");
		FlxG.save.data.ambientVolume = AudioMaster.getBusVolumeRaw("ambient");
		FlxG.save.data.muted         = AudioMaster.isMasterMuted();
		FlxG.save.flush();
	}

	public static function getSaveFloat(key:String, fallback:Float):Float
	{
		var value:Dynamic = Reflect.field(FlxG.save.data, key);
		return (value != null) ? cast(value, Float) : fallback;
	}

	public static function getSaveBool(key:String, fallback:Bool):Bool
	{
		var value:Dynamic = Reflect.field(FlxG.save.data, key);
		return (value != null) ? cast(value, Bool) : fallback;
	}

	public static function getSaveString(key:String, fallback:String):String
	{
		var value:Dynamic = Reflect.field(FlxG.save.data, key);
		return (value != null) ? cast(value, String) : fallback;
	}

	public static function setSaveValue(key:String, value:Dynamic):Void
	{
		Reflect.setField(FlxG.save.data, key, value);
		FlxG.save.flush();
	}

	public static function resetSaveData():Void
	{
		FlxG.save.erase();
		FlxG.save.data.initialized   = true;
		FlxG.save.data.masterVolume  = 0.8;
		FlxG.save.data.musicVolume   = 1.0;
		FlxG.save.data.sfxVolume     = 1.0;
		FlxG.save.data.voiceVolume   = 1.0;
		FlxG.save.data.ambientVolume = 1.0;
		FlxG.save.data.muted         = false;
		FlxG.save.data.language      = "en-US";
		FlxG.save.flush();
	}

	function setupGame():Void
	{
		#if mobile
		FlxG.autoPause = true;
		#else
		FlxG.autoPause = false;
		#end

		FlxG.fixedTimestep = false;

		#if desktop
		FlxG.sound.muteKeys       = [flixel.input.keyboard.FlxKey.ZERO];
		FlxG.sound.volumeUpKeys   = [flixel.input.keyboard.FlxKey.NUMPADPLUS,  flixel.input.keyboard.FlxKey.PLUS];
		FlxG.sound.volumeDownKeys = [flixel.input.keyboard.FlxKey.NUMPADMINUS, flixel.input.keyboard.FlxKey.MINUS];
		#end

		#if android
		FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		#if debug
		FlxG.debugger.drawDebug = true;
		#end
	}

	function setupAudio():Void
	{
		AudioMaster.init();
		loadSaveIntoAudio();

		FlxG.signals.preStateSwitch.add(onPreStateSwitch);

		game.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		#if mobile
		game.stage.addEventListener(Event.ACTIVATE, onAppActivate);
		game.stage.addEventListener(Event.DEACTIVATE, onAppDeactivate);
		#end
	}

	function onEnterFrame(e:Event):Void
	{
		AudioMaster.update(1.0 / FRAMERATE);
	}

	function onPreStateSwitch():Void
	{
		AudioMaster.clearQueue();
	}

	function onAppActivate(e:Event):Void
	{
		AudioMaster.resumeMusic();
	}

	function onAppDeactivate(e:Event):Void
	{
		AudioMaster.pauseMusic();
		saveAudioSettings();
	}
}