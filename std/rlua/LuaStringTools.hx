package rlua;

class LuaStringTools
{
	public static function lastIndexOf(base:String, str:String, ?startIndex:Int):Int
	{
		var last = -1;
		var i = ((startIndex != null) ? startIndex : base.length - 1);
		while (true) {
			var found = untyped __lua__("string.find({0}, {1}, {2}, true)", base, str, last + 2);
			if (found == null || found - 1 > i) break;
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
}
