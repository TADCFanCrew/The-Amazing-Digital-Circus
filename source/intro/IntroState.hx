package intro;

import flixel.FlxG;
import flixel.FlxState;
import hxvlc.flixel.FlxVideoSprite;
import states.TitleState;

class IntroState extends FlxState
{
	var video:FlxVideoSprite;
	var finished:Bool = false;

	override function create():Void
	{
		super.create();
		bgColor = flixel.util.FlxColor.BLACK;

		video = new FlxVideoSprite();
		add(video);

		video.onEndReached.add(onVideoEnd);
		video.onEncounteredError.add(onVideoEnd);

		video.load(backend.Paths.file("videos/Intro.mp4"));
		video.play();

		video.bitmap.width  = FlxG.width;
		video.bitmap.height = FlxG.height;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (finished) return;

		#if mobile
		if (FlxG.touches.justStarted().length > 0)
			skip();
		#else
		if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed)
			skip();
		#end
	}

	function skip():Void
	{
		video.onEndReached.remove(onVideoEnd);
		video.onEncounteredError.remove(onVideoEnd);
		video.stop();
		onVideoEnd();
	}

	function onVideoEnd():Void
	{
		if (finished) return;
		finished = true;
		FlxG.switchState(new TitleState());
	}

	override function destroy():Void
	{
		if (video != null)
		{
			video.onEndReached.remove(onVideoEnd);
			video.onEncounteredError.remove(onVideoEnd);
		}
		super.destroy();
	}
}
