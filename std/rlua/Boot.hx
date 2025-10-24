package rlua;

class Boot
{
	// A max stack size to respect for unpack operations
	public static var MAXSTACKSIZE(default, null) = 1000;

	public static var platformBigEndian = untyped string.byte(string.dump(function() {}), 7) > 0;

	public static function clampInt32(x:Float)
	{
		if (x <= 2147483647 && x >= -2147483648)
		{
			if (x > 0)
				return untyped math.floor(x);
			else
				return untyped math.ceil(x);
		}
		if (x > 2251798999999999)
			x = x * 2;
		if (x != x || untyped math.abs(x) == untyped math.huge)
			return null;
		return untyped bit.band(x, 2147483647) - untyped math.abs(untyped bit.band(x, 2147483648));
	}

	/**
		Create a standard date object from a lua string representation
	**/
	public static function strDate(s:String):std.Date
	{
		switch (s.length)
		{
			case 8: // hh:mm:ss
				var k = s.split(":");
				return std.Date.fromTime(Lua.tonumber(k[0]) * 3600000. + Lua.tonumber(k[1]) * 60000. + Lua.tonumber(k[2]) * 1000.);
			case 10: // YYYY-MM-DD
				var k = s.split("-");
				return new std.Date(Lua.tonumber(k[0]), Lua.tonumber(k[1]) - 1, Lua.tonumber(k[2]), 0, 0, 0);
			case 19: // YYYY-MM-DD hh:mm:ss
				var k = s.split(" ");
				var y = k[0].split("-");
				var t = k[1].split(":");
				return new std.Date(Lua.tonumber(y[0]), Lua.tonumber(y[1]) - 1, Lua.tonumber(y[2]), Lua.tonumber(t[0]), Lua.tonumber(t[1]), Lua.tonumber(t[2]));
			default:
				throw "Invalid date format : " + s;
		}
	}

	/**
		Get Date object as string representation
	**/
	public static function dateStr(date:std.Date):String
	{
		var m = date.getMonth() + 1;
		var d = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear() + "-" + (if (m < 10) "0" + m else "" + m) + "-" + (if (d < 10) "0" + d else "" + d) + " "
			+ (if (h < 10) "0" + h else "" + h) + ":" + (if (mi < 10) "0" + mi else "" + mi) + ":" + (if (s < 10) "0" + s else "" + s);
	}
}
