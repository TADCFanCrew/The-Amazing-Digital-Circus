package mobile;

import flixel.FlxG;

class FullScreenUtil
{
	static var immersiveEnabled:Bool = false;
	static var safeAreaTop:Float    = 0;
	static var safeAreaBottom:Float = 0;
	static var safeAreaLeft:Float   = 0;
	static var safeAreaRight:Float  = 0;

	public static function init():Void
	{
		enableImmersiveMode();
	}

	public static function enableImmersiveMode():Void
	{
		#if android
		untyped __java__("
			android.view.Window window = org.haxe.lime.HaxeObject.mainActivity.getWindow();
			window.getDecorView().setSystemUiVisibility(
				android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
				android.view.View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
				android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
				android.view.View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
				android.view.View.SYSTEM_UI_FLAG_FULLSCREEN |
				android.view.View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
			)
		");
		immersiveEnabled = true;
		#end
	}

	public static function disableImmersiveMode():Void
	{
		#if android
		untyped __java__("
			android.view.Window window = org.haxe.lime.HaxeObject.mainActivity.getWindow();
			window.getDecorView().setSystemUiVisibility(android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE)
		");
		immersiveEnabled = false;
		#end
	}

	public static function toggleImmersiveMode():Void
	{
		if (immersiveEnabled)
			disableImmersiveMode();
		else
			enableImmersiveMode();
	}

	public static function isImmersiveEnabled():Bool
	{
		return immersiveEnabled;
	}

	public static function setSafeAreaInsets(top:Float, bottom:Float, left:Float, right:Float):Void
	{
		safeAreaTop    = top;
		safeAreaBottom = bottom;
		safeAreaLeft   = left;
		safeAreaRight  = right;
	}

	public static function getSafeAreaTop():Float
	{
		return safeAreaTop;
	}

	public static function getSafeAreaBottom():Float
	{
		return safeAreaBottom;
	}

	public static function getSafeAreaLeft():Float
	{
		return safeAreaLeft;
	}

	public static function getSafeAreaRight():Float
	{
		return safeAreaRight;
	}

	public static function getSafeContentY():Float
	{
		return safeAreaTop;
	}

	public static function getSafeContentHeight():Float
	{
		return FlxG.height - safeAreaTop - safeAreaBottom;
	}

	public static function getSafeContentX():Float
	{
		return safeAreaLeft;
	}

	public static function getSafeContentWidth():Float
	{
		return FlxG.width - safeAreaLeft - safeAreaRight;
	}

	public static function hasSafeArea():Bool
	{
		return safeAreaTop > 0 || safeAreaBottom > 0 || safeAreaLeft > 0 || safeAreaRight > 0;
	}
}
