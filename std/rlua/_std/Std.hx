import rlua.Runtime;
import rlua.UserData;
import rlua.Thread;

class Std
{
	@:deprecated('Std.is is deprecated. Use Std.isOfType instead.')
	public static inline function is(v:Dynamic, t:Dynamic):Bool
		return isOfType(v, t);

	public static function isOfType(v:Dynamic, t:Dynamic):Bool
	{
		if (t == null)
			return false;

		switch (untyped type(t))
		{
			case "number":
				if (untyped type(v) == "number")
				{
					if (Math.ceil(v) == v % 2147483648.0 && Math.ceil(t) == t % 2147483648.0)
						return true;
					else if (Math.ceil(v) != v && Math.ceil(t) != t)
						return true;
				}
				return false;
			case "boolean":
				return untyped type(v) == "boolean";
			case "string":
				return untyped type(v) == "string";
			case "thread":
				return untyped type(v) == "thread";
			case "userdata":
				return untyped type(v) == "userdata";
			case "table":
				return untyped type(v) == "table" && untyped getmetatable(v) == null;
			default:
				if (v != null && untyped (type(v)) == "table" && untyped (type(t)) == "table")
				{
					if (Runtime.isClass(t) || Runtime.isInterface(t))
					{
						if (Runtime.isInstance(v))
							return extendsOrImplements(untyped v.__class__, t);
						else if (Runtime.isClass(v))
							return extendsOrImplements(v, t);
					}
					else if (Runtime.isEnum(t) && Runtime.isEnumIndex(v))
						return untyped v.__enum__ == t;
					else
					{
						untyped __lua__('
local compatible = true
for k, _ in pairs(t) do
	if v[k] == nil then
		compatible = false
		break
	end
end');
						return untyped compatible;
					}
				}
				return false;
		}
	}

	public static inline function downcast<T:{}, S:T>(value:T, c:Class<S>):S
		return isOfType(value, c) ? cast value : null;

	@:deprecated('Std.instance() is deprecated. Use Std.downcast() instead.')
	public static inline function instance<T:{}, S:T>(value:T, c:Class<S>):S
		return downcast(value, c);

	public static inline function string(s:Dynamic):String
		return untyped tostring(s);

	public static function int(x:Float):Int
		return x > 0 ? untyped math.floor(x) : untyped math.ceil(x);

	public static inline function parseInt(x:String):Null<Int>
		return int(untyped tonumber(x));

	static function parseFloat(x:String):Float
		return untyped tonumber(x);

	public static inline function random(x:Int):Int
		return x <= 0 ? 0 : Math.floor(Math.random() * x);

	private static function extendsOrImplements(cl1:Class<Dynamic>, cl2:Class<Dynamic>):Bool
	{
		if (cl1 == null || cl2 == null)
			return false;
		else if (cl1 == cl2)
			return true;
		else if (untyped cl1.__interfaces__ != null)
		{
			var intf = untyped cl1.__interfaces__;
			for (i in 1...(untyped __lua__("#{0}", intf) + 1))
				if (extendsOrImplements(intf[i], cl2))
					return true;
		}

		return extendsOrImplements(untyped cl1.__super__, cl2);
	}
}
