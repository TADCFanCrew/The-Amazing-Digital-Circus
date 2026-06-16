package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class TitleState extends FlxState
{
	var titleText:FlxText;
	var subtitleText:FlxText;
	var promptText:FlxText;
	var canProceed:Bool = false;

	override function create():Void
	{
		super.create();
		bgColor = FlxColor.BLACK;

		titleText = new FlxText(0, 0, FlxG.width, "THE AMAZING\nDIGITAL CIRCUS");
		titleText.setFormat(null, 48, FlxColor.WHITE, CENTER, OUTLINE);
		titleText.borderColor = FlxColor.fromRGB(180, 0, 255);
		titleText.borderSize  = 3;
		titleText.screenCenter();
		titleText.y -= 60;
		titleText.alpha = 0;
		add(titleText);

		subtitleText = new FlxText(0, titleText.y + titleText.height + 12, FlxG.width, "Fangame");
		subtitleText.setFormat(null, 20, FlxColor.fromRGB(200, 180, 255), CENTER);
		subtitleText.alpha = 0;
		add(subtitleText);

		promptText = new FlxText(0, FlxG.height - 60, FlxG.width, "Press ANY KEY to continue");
		promptText.setFormat(null, 18, FlxColor.fromRGB(180, 180, 180), CENTER);
		promptText.alpha = 0;
		add(promptText);

		FlxTween.tween(titleText,    {alpha: 1}, 1.2, {ease: FlxEase.quadOut});
		FlxTween.tween(subtitleText, {alpha: 1}, 1.2, {ease: FlxEase.quadOut, startDelay: 0.4});
		FlxTween.tween(promptText,   {alpha: 1}, 1.0, {ease: FlxEase.quadOut, startDelay: 1.0,
			onComplete: _ -> {
				canProceed = true;
				FlxTween.tween(promptText, {alpha: 0.2}, 0.8, {type: PINGPONG, ease: FlxEase.sineInOut});
			}
		});
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (canProceed && (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed))
			FlxG.switchState(new MenuState());
	}
}
