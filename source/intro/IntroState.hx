package intro;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hxvlc.flixel.FlxVideoSprite;
import states.TitleState;

class IntroState extends FlxState
{
	var video:FlxVideoSprite;
	var finished:Bool = false;

	override function create():Void
	{
		super.create();
		bgColor = FlxColor.BLACK;

		video = new FlxVideoSprite(0, 0);
		add(video);

		video.bitmap.onEndReached.add(onVideoEnd);
		video.bitmap.onEncounteredError.add(onVideoError);

		video.bitmap.onFormatSetup.add(onFormatSetup);

		if (video.load(backend.Paths.file("videos/Intro.mp4")))
			new FlxTimer().start(0.001, _ -> video.play());
	}

	function onFormatSetup():Void
	{
		if (video.bitmap == null || video.bitmap.bitmapData == null) return;

		var scale = Math.min(
			FlxG.width  / video.bitmap.bitmapData.width,
			FlxG.height / video.bitmap.bitmapData.height
		);

		video.setGraphicSize(
			video.bitmap.bitmapData.width  * scale,
			video.bitmap.bitmapData.height * scale
		);
		video.updateHitbox();
		video.screenCenter();
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
		video.bitmap.onEndReached.remove(onVideoEnd);
		video.bitmap.onEncounteredError.remove(onVideoError);
		video.stop();
		onVideoEnd();
	}

	function onVideoEnd():Void
	{
		if (finished) return;
		finished = true;
		FlxG.switchState(new TitleState());
	}

	function onVideoError(message:String):Void
	{
		onVideoEnd();
	}

	override function destroy():Void
	{
		if (video != null && video.bitmap != null)
		{
			video.bitmap.onEndReached.remove(onVideoEnd);
			video.bitmap.onEncounteredError.remove(onVideoError);
		}
		super.destroy();
	}
}