package backend;

class FormatJson
{
	public static inline var CURRENT_VERSION:Int = 1;

	public static function parse(text:String, ?fallback:Dynamic):Dynamic
	{
		if (text == null || text.length == 0)
			return fallback;

		var cleaned = stripComments(text);

		try
		{
			return haxe.Json.parse(cleaned);
		}
		catch (e:Dynamic)
		{
			return fallback;
		}
	}

	public static function stringify(value:Dynamic, pretty:Bool = true, indent:String = "\t"):String
	{
		if (!pretty)
			return haxe.Json.stringify(value);

		return haxe.Json.stringify(value, indent);
	}

	public static function stripComments(text:String):String
	{
		var result   = new StringBuf();
		var len      = text.length;
		var i        = 0;
		var inString = false;
		var inGame   = false;
		var stringChar = "";

		while (i < len)
		{
			var c = text.charAt(i);

			if (inString)
			{
				result.add(c);
				if (c == "\\" && i + 1 < len)
				{
					result.add(text.charAt(i + 1));
					i += 2;
					continue;
				}
				if (c == stringChar)
					inString = false;
				i++;
				continue;
			}

			if (c == "\"" || c == "'")
			{
				inString   = true;
				stringChar = c;
				result.add(c);
				i++;
				continue;
			}

			if (c == "/" && i + 1 < len && text.charAt(i + 1) == "/")
			{
				while (i < len && text.charAt(i) != "\n") i++;
				continue;
			}

			if (c == "/" && i + 1 < len && text.charAt(i + 1) == "*")
			{
				i += 2;
				while (i < len - 1 && !(text.charAt(i) == "*" && text.charAt(i + 1) == "/")) i++;
				i += 2;
				continue;
			}

			result.add(c);
			i++;
		}

		return result.toString();
	}

	public static function isValid(text:String):Bool
	{
		try
		{
			haxe.Json.parse(stripComments(text));
			return true;
		}
		catch (e:Dynamic)
		{
			return false;
		}
	}

	public static function get(data:Dynamic, path:String, ?fallback:Dynamic):Dynamic
	{
		if (data == null) return fallback;

		var parts   = path.split(".");
		var current = data;

		for (part in parts)
		{
			if (current == null) return fallback;

			var arrayMatch = ~/^(.+)\[(\d+)\]$/;
			if (arrayMatch.match(part))
			{
				var key = arrayMatch.matched(1);
				var idx = Std.parseInt(arrayMatch.matched(2));

				current = Reflect.field(current, key);
				if (current == null || !Std.isOfType(current, Array)) return fallback;

				var arr:Array<Dynamic> = current;
				if (idx < 0 || idx >= arr.length) return fallback;
				current = arr[idx];
			}
			else
			{
				current = Reflect.field(current, part);
			}
		}

		return current != null ? current : fallback;
	}

	public static function getString(data:Dynamic, path:String, fallback:String = ""):String
	{
		var v = get(data, path, fallback);
		return v != null ? Std.string(v) : fallback;
	}

	public static function getFloat(data:Dynamic, path:String, fallback:Float = 0.0):Float
	{
		var v = get(data, path, fallback);
		return (v != null && Std.isOfType(v, Float)) ? cast(v, Float) : fallback;
	}

	public static function getInt(data:Dynamic, path:String, fallback:Int = 0):Int
	{
		var v = get(data, path, fallback);
		return (v != null) ? Std.int(cast(v, Float)) : fallback;
	}

	public static function getBool(data:Dynamic, path:String, fallback:Bool = false):Bool
	{
		var v = get(data, path, fallback);
		return (v != null && Std.isOfType(v, Bool)) ? cast(v, Bool) : fallback;
	}

	public static function getArray(data:Dynamic, path:String, ?fallback:Array<Dynamic>):Array<Dynamic>
	{
		var v = get(data, path, fallback);
		return (v != null && Std.isOfType(v, Array)) ? cast(v, Array<Dynamic>) : (fallback != null ? fallback : []);
	}

	public static function set(data:Dynamic, path:String, value:Dynamic):Void
	{
		var parts   = path.split(".");
		var current = data;

		for (i in 0...parts.length - 1)
		{
			var part = parts[i];
			var next = Reflect.field(current, part);

			if (next == null)
			{
				next = {};
				Reflect.setField(current, part, next);
			}

			current = next;
		}

		Reflect.setField(current, parts[parts.length - 1], value);
	}

	public static function merge(base:Dynamic, overrides:Dynamic):Dynamic
	{
		if (base == null) return overrides;
		if (overrides == null) return base;

		var result = clone(base);
		var fields = Reflect.fields(overrides);

		for (field in fields)
		{
			var overrideValue = Reflect.field(overrides, field);
			var baseValue      = Reflect.field(result, field);

			if (isObject(overrideValue) && isObject(baseValue))
				Reflect.setField(result, field, merge(baseValue, overrideValue));
			else
				Reflect.setField(result, field, overrideValue);
		}

		return result;
	}

	public static function clone(data:Dynamic):Dynamic
	{
		if (data == null) return null;
		return parse(stringify(data, false));
	}

	public static function isObject(value:Dynamic):Bool
	{
		return value != null
			&& !Std.isOfType(value, Array)
			&& !Std.isOfType(value, String)
			&& !Std.isOfType(value, Float)
			&& !Std.isOfType(value, Bool)
			&& Type.typeof(value) == TObject;
	}

	public static function withVersion(data:Dynamic, version:Int = CURRENT_VERSION):Dynamic
	{
		var result = clone(data);
		Reflect.setField(result, "_version", version);
		return result;
	}

	public static function getVersion(data:Dynamic):Int
	{
		return getInt(data, "_version", 0);
	}

	public static function migrate(data:Dynamic, migrations:Map<Int, Dynamic->Dynamic>):Dynamic
	{
		var current = data;
		var version = getVersion(current);

		while (version < CURRENT_VERSION)
		{
			if (!migrations.exists(version))
				break;

			var migrateFn = migrations.get(version);
			current = migrateFn(current);
			version++;
			Reflect.setField(current, "_version", version);
		}

		return current;
	}

	public static function loadFile(path:String, ?fallback:Dynamic):Dynamic
	{
		#if sys
		try
		{
			var text = sys.io.File.getContent(path);
			return parse(text, fallback);
		}
		catch (e:Dynamic)
		{
			return fallback;
		}
		#else
		return fallback;
		#end
	}

	public static function saveFile(path:String, data:Dynamic, pretty:Bool = true):Bool
	{
		#if sys
		try
		{
			sys.io.File.saveContent(path, stringify(data, pretty));
			return true;
		}
		catch (e:Dynamic)
		{
			return false;
		}
		#else
		return false;
		#end
	}
}
