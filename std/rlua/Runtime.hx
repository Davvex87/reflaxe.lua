package rlua;

class Runtime
{
	private static final _hxClasses:Map<String, Class<Dynamic>> = new Map();

	// TODO: implement the lua-safe compiler def stuff here

	public static function isTable(o:Dynamic):Bool
		return untyped type(o) == "table";

	public static function isMetatable(o:Dynamic):Bool
		return untyped type(o) == "table" && untyped getmetatable(o) != null;

	public static function isArray(o:Dynamic):Bool
	{
		if (!isTable(o) || isMetatable(o))
			return false;

		var count = 0;
		var numeric = 0;
		untyped __lua__('for k in pairs(t) do
	count = count + 1
	if type(k) == "number" and k % 1 == 0 and k >= 1 then
		numeric = numeric + 1
	end
end');

		return (numeric == count);
	}

	public static function isObject(o:Dynamic):Bool
		return !isArray(o) && isTable(o);

	public static function isClass(o:Dynamic):Bool
		return isMetatable(o) && untyped o.__index != null && untyped type(o.__name__) == "string";

	public static function isInstance(o:Dynamic):Bool
		return isMetatable(o) && isMetatable(untyped o.__class__);

	public static function isInterface(o:Dynamic):Bool
		return isMetatable(o) && untyped type(o.__interface__) == "table";

	public static function isEnum(o:Dynamic):Bool
		return isMetatable(o) && untyped type(o.__fenum__) == "table";

	public static function isEnumIndex(o:Dynamic):Bool
		return isMetatable(o) && isMetatable(untyped o.__enum__);

	@:noCompletion
	public static function buildMultiReturn(n:Array<String>, ...v:Dynamic):Dynamic
	{
		var t = {};
		for (i in 0...n.length)
			untyped t[n[i]] = v[i];
		return t;
	}
}
