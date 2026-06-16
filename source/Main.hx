package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	// On mobile the game fills the native screen (0 = auto).
	#if mobile
	static inline final GAME_WIDTH:Int  = 0;
	static inline final GAME_HEIGHT:Int = 0;
	#else
	static inline final GAME_WIDTH:Int  = 1280;
	static inline final GAME_HEIGHT:Int = 720;
	#end

	static inline final FRAMERATE:Int = 60;

	public function new()
	{
		super();
		addChild(new FlxGame(GAME_WIDTH, GAME_HEIGHT, TitleState, FRAMERATE, FRAMERATE, true));
		setupGame();
	}

	function setupGame():Void
	{
		// Pause automatically when the app loses focus on mobile.
		#if mobile
		FlxG.autoPause = true;
		#else
		FlxG.autoPause = false;
		#end

		FlxG.fixedTimestep = false;

		FlxG.sound.volume = 0.8;

		// Volume keys only make sense on desktop.
		#if desktop
		FlxG.sound.muteKeys       = [flixel.input.keyboard.FlxKey.ZERO];
		FlxG.sound.volumeUpKeys   = [flixel.input.keyboard.FlxKey.NUMPADPLUS,  flixel.input.keyboard.FlxKey.PLUS];
		FlxG.sound.volumeDownKeys = [flixel.input.keyboard.FlxKey.NUMPADMINUS, flixel.input.keyboard.FlxKey.MINUS];
		#end

		// Android back-button exits gracefully.
		#if android
		FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		#if debug
		FlxG.debugger.drawDebug = true;
		#end
	}
}
