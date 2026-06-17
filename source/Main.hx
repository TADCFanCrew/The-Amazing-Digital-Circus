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

	static inline final FRAMERATE:Int = 60;

	var game:FlxGame;

	public function new()
	{
		super();

		game = new FlxGame(GAME_WIDTH, GAME_HEIGHT, IntroState, FRAMERATE, FRAMERATE, true);
		addChild(game);

		setupGame();
		setupAudio();
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
		AudioMaster.setMasterVolume(0.8);
		AudioMaster.setBusVolume("music",   1.0);
		AudioMaster.setBusVolume("sfx",     1.0);
		AudioMaster.setBusVolume("voice",   1.0);
		AudioMaster.setBusVolume("ambient", 1.0);

		FlxG.signals.preStateSwitch.add(onPreStateSwitch);
		FlxG.signals.gameResized.add(onGameResized);

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

	function onGameResized(width:Int, height:Int):Void
	{
	}

	function onAppActivate(e:Event):Void
	{
		AudioMaster.resumeMusic();
	}

	function onAppDeactivate(e:Event):Void
	{
		AudioMaster.pauseMusic();
	}
}
