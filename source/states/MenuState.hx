package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	static final ITEMS:Array<String> = ["Play", "Options", "Quit"];

	var menuItems:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;

	override function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(10, 5, 20);

		var header = new FlxText(0, 40, FlxG.width, "MAIN MENU");
		header.setFormat(null, 28, FlxColor.fromRGB(200, 150, 255), CENTER, OUTLINE);
		header.borderColor = FlxColor.fromRGB(100, 0, 180);
		header.borderSize  = 2;
		add(header);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...ITEMS.length)
		{
			var item = new FlxText(0, 260 + i * 70, FlxG.width, ITEMS[i]);
			item.setFormat(null, 32, FlxColor.WHITE, CENTER);
			item.alpha = 0;
			menuItems.add(item);

			FlxTween.tween(item, {alpha: 1}, 0.5, {startDelay: 0.1 * i, ease: FlxEase.quadOut});
		}

		updateSelection(0);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if desktop
		if (FlxG.keys.justPressed.UP   || FlxG.keys.justPressed.W) updateSelection(-1);
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) updateSelection(1);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.Z)
			confirmSelection();
		#end
	}

	function updateSelection(change:Int):Void
	{
		curSelected = (curSelected + change + ITEMS.length) % ITEMS.length;

		menuItems.forEachAlive(item ->
		{
			var idx   = menuItems.members.indexOf(item);
			var color = (idx == curSelected) ? FlxColor.fromRGB(255, 200, 80) : FlxColor.WHITE;
			var size  = (idx == curSelected) ? 38 : 32;
			item.size = size;
			item.color = color;
		});
	}

	function confirmSelection():Void
	{
		switch (curSelected)
		{
			case 0: FlxG.switchState(new PlayState());
			case 1: // TODO: open options
			case 2: openfl.system.System.exit(0);
		}
	}
}
