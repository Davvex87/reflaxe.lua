package rlua;

class LuaStringTools
{
	public static function lastIndexOf(base:String, str:String, ?startIndex:Int):Int
	{
		var last = -1;
		var i = ((startIndex != null) ? startIndex : base.length - 1);
		while (true)
		{
			var found = untyped __lua__("string.find({0}, {1}, {2}, true)", base, str, last + 2);
			if (found == null || found - 1 > i)
				break;
			last = found - 1;
		}
		return last;
	}

	public static function split(str:String, delim:String):Array<String>
	{
		var result = [];
		untyped __lua__('for part in string.gmatch({0}, "([^" .. {1} .. "]+)") do table.insert(result, part) end', str, delim);
		return result;
	}

	public static function codes(s:String):String->Int->StringCodePoint
	{
		var i = 1;
		var len = s.length;

		return cast function()
		{
			if (i > len)
				return null;

			var c = byte(s, i);
			var codepoint, n;

			if (c < 0x80)
			{
				codepoint = c;
				n = 1;
			}
			else if (c < 0xE0)
			{
				codepoint = ((c % 0x20) << 6) | (byte(s, i + 1) % 0x40);
				n = 2;
			}
			else if (c < 0xF0)
			{
				var c2 = byte(s, i + 1);
				var c3 = byte(s, i + 2);
				codepoint = ((c % 0x10) << 12) | ((c2 % 0x40) << 6) | (c3 % 0x40);
				n = 3;
			}
			else
			{
				var c2 = byte(s, i + 1);
				var c3 = byte(s, i + 2);
				var c4 = byte(s, i + 3);
				codepoint = ((c % 0x08) << 18) | ((c2 % 0x40) << 12) | ((c3 % 0x40) << 6) | (c4 % 0x40);
				n = 4;
			}

			var pos = i;
			i += n;
			return untyped __lua__("pos, codepoint");
		}
	}

	public static inline function byte(str:String, ?index:Int):Int
		return untyped string.byte(str, index);
}

@:multiReturn extern class StringCodePoint
{
	var position:Int;
	var codepoint:Int;
}
