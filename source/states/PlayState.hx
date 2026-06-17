package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	override function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(15, 10, 30);

		var label = new FlxText(0, 0, FlxG.width, "PlayState — coming soon");
		label.setFormat(null, 24, FlxColor.WHITE, CENTER);
		label.screenCenter();
		add(label);

		#if desktop
		var back = new FlxText(0, FlxG.height - 40, FlxG.width, "Press ESCAPE to return");
		back.setFormat(null, 16, FlxColor.fromRGB(150, 150, 150), CENTER);
		add(back);
		#end
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if desktop
		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MenuState());
		#end
	}
}
