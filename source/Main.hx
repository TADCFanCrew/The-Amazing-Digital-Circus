package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	static inline final GAME_WIDTH:Int  = 1280;
	static inline final GAME_HEIGHT:Int = 720;
	static inline final INITIAL_ZOOM:Float = 1.0;
	static inline final FRAMERATE:Int = 60;

	public function new()
	{
		super();
		addChild(new FlxGame(GAME_WIDTH, GAME_HEIGHT, TitleState, FRAMERATE, FRAMERATE, true));
		setupGame();
	}

	function setupGame():Void
	{
		FlxG.autoPause       = false;
		FlxG.fixedTimestep   = false;

		FlxG.sound.volume    = 0.8;
		FlxG.sound.muteKeys  = [flixel.input.keyboard.FlxKey.ZERO];
		FlxG.sound.volumeUpKeys   = [flixel.input.keyboard.FlxKey.NUMPADPLUS,  flixel.input.keyboard.FlxKey.PLUS];
		FlxG.sound.volumeDownKeys = [flixel.input.keyboard.FlxKey.NUMPADMINUS, flixel.input.keyboard.FlxKey.MINUS];

		#if debug
		FlxG.debugger.drawDebug = true;
		#end
	}
}
