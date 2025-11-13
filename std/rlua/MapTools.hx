package rlua;

import haxe.Constraints.IMap;

class MapTools
{
	public static function stringifyMap(map:IMap<Dynamic, Dynamic>):String
	{
		var s = new StringBuf();
		s.add("[");
		var it = map.keys();
		for (i in it)
		{
			s.add(i);
			s.add(" => ");
			s.add(Std.string(map.get(i)));
			if (it.hasNext())
				s.add(", ");
		}
		s.add("]");
		return s.toString();
	}

	public static function remove(map:IMap<Dynamic, Dynamic>, key:Dynamic):Bool
	{
		var e = map.exists(key);
		untyped map[key] = null;
		return e;
	}
}
