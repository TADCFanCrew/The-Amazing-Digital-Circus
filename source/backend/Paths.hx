package backend;

class Paths
{
	static inline var ASSETS:String = "assets";

	public static function file(path:String):String
	{
		return '$ASSETS/$path';
	}

	public static function image(key:String):String
	{
		return file('images/$key.png');
	}

	public static function xml(key:String):String
	{
		return file('images/$key.xml');
	}

	public static function imageDir(dir:String, key:String):String
	{
		return file('images/$dir/$key.png');
	}

	public static function xmlDir(dir:String, key:String):String
	{
		return file('images/$dir/$key.xml');
	}

	public static function music(key:String):String
	{
		return file('music/$key.ogg');
	}

	public static function sound(key:String):String
	{
		return file('sounds/$key.ogg');
	}

	public static function data(key:String):String
	{
		return file('data/$key.json');
	}

	public static function txt(key:String):String
	{
		return file('data/$key.txt');
	}

	public static function font(key:String):String
	{
		return file('fonts/$key.ttf');
	}

	public static function frag(key:String):String
	{
		return file('shaders/$key.frag');
	}

	public static function vert(key:String):String
	{
		return file('shaders/$key.vert');
	}
}
