import rlua.Runtime;

/**
	The Haxe Reflection API allows retrieval of type information at runtime.

	This class complements the more lightweight Reflect class, with a focus on
	class and enum instances.

	@see https://haxe.org/manual/types.html
	@see https://haxe.org/manual/std-reflection.html
**/
class Type
{
	/**
		Returns the class of `o`, if `o` is a class instance.

		If `o` is null or of a different type, null is returned.

		In general, type parameter information cannot be obtained at runtime.
	**/
	public static function getClass<T>(o:T):Class<T>
	{
		if (o == null)
			return null;

		// FIXME: This generates wrong lua code, help??
		if (Std.isOfType(o, Array))
			return cast Array; // Class<Array> should be Class<getClass.T>
		else if (Std.isOfType(o, String))
			return cast String;
		else untyped
		{
			var cl = o.__class__;
			if (cl != null)
				return cl;
		}
		return null;
	}

	/**
		Returns the enum of enum instance `o`.

		An enum instance is the result of using an enum constructor. Given an
		`enum Color { Red; }`, `getEnum(Red)` returns `Enum<Color>`.

		If `o` is null, null is returned.

		In general, type parameter information cannot be obtained at runtime.
	**/
	public static function getEnum(o:EnumValue):Enum<Dynamic> untyped
	{
		if (o == null)
			return null;
		return untyped o.__enum__;
	}

	/**
		Returns the super-class of class `c`.

		If `c` has no super class, null is returned.

		If `c` is null, the result is unspecified.

		In general, type parameter information cannot be obtained at runtime.
	**/
	public static function getSuperClass(c:Class<Dynamic>):Class<Dynamic>
		untyped return c.__super__;

	/**
		Returns the name of class `c`, including its path.

		If `c` is inside a package, the package structure is returned dot-
		separated, with another dot separating the class name:
		`pack1.pack2.(...).packN.ClassName`
		If `c` is a sub-type of a Haxe module, that module is not part of the
		package structure.

		If `c` has no package, the class name is returned.

		If `c` is null, the result is unspecified.

		The class name does not include any type parameters.
	**/
	public static function getClassName(c:Class<Dynamic>):String
		untyped return c.__name__;

	/**
		Returns the name of enum `e`, including its path.

		If `e` is inside a package, the package structure is returned dot-
		separated, with another dot separating the enum name:
		`pack1.pack2.(...).packN.EnumName`
		If `e` is a sub-type of a Haxe module, that module is not part of the
		package structure.

		If `e` has no package, the enum name is returned.

		If `e` is null, the result is unspecified.

		The enum name does not include any type parameters.
	**/
	public static function getEnumName(e:Enum<Dynamic>):String
		untyped return e.__name__;

	/**
		Resolves a class by name.

		If `name` is the path of an existing class, that class is returned.

		Otherwise null is returned.

		If `name` is null or the path to a different type, the result is
		unspecified.

		The class name must not include any type parameters.
	**/
	public static function resolveClass(name:String):Class<Dynamic>
		return @:privateAccess Runtime._hxClasses.get(name);

	/**
		Resolves an enum by name.

		If `name` is the path of an existing enum, that enum is returned.

		Otherwise null is returned.

		If `name` is null the result is unspecified.

		If `name` is the path to a different type, null is returned.

		The enum name must not include any type parameters.
	**/
	public static function resolveEnum(name:String):Enum<Dynamic>
		return @:privateAccess cast Runtime._hxClasses.get(name);

	/**
		Creates an instance of class `cl`, using `args` as arguments to the
		class constructor.

		This function guarantees that the class constructor is called.

		Default values of constructors arguments are not guaranteed to be
		taken into account.

		If `cl` or `args` are null, or if the number of elements in `args` does
		not match the expected number of constructor arguments, or if any
		argument has an invalid type,  or if `cl` has no own constructor, the
		result is unspecified.

		In particular, default values of constructor arguments are not
		guaranteed to be taken into account.
	**/
	public static function createInstance<T>(cl:Class<T>, args:Array<Dynamic>):T
		untyped return cl["new"](table.unpack(args));

	/**
		Creates an instance of class `cl`.

		This function guarantees that the class constructor is not called.

		If `cl` is null, the result is unspecified.
	**/
	public static function createEmptyInstance<T>(cl:Class<T>):T
		untyped return setmetatable({__tostring: function(self) return Type.getClassName(cl), __class__: cl}, cl);

	/**
		Creates an instance of enum `e` by calling its constructor `constr` with
		arguments `params`.

		If `e` or `constr` is null, or if enum `e` has no constructor named
		`constr`, or if the number of elements in `params` does not match the
		expected number of constructor arguments, or if any argument has an
		invalid type, the result is unspecified.
	**/
	public static function createEnum<T>(e:Enum<T>, constr:String, ?params:Array<Dynamic>):T untyped
	{
		var c = e[constr];
		if (type(c) == "function")
			return c(unpack(params));
		else
			return c.index;
	}

	/**
		Creates an instance of enum `e` by calling its constructor number
		`index` with arguments `params`.

		The constructor indices are preserved from Haxe syntax, so the first
		declared is index 0, the next index 1 etc.

		If `e` or `constr` is null, or if enum `e` has no constructor named
		`constr`, or if the number of elements in `params` does not match the
		expected number of constructor arguments, or if any argument has an
		invalid type, the result is unspecified.
	**/
	public static function createEnumIndex<T>(e:Enum<T>, index:Int, ?params:Array<Dynamic>):T
		return createEnum(e, untyped (e.__fenum__[index]), params);

	/**
		Returns a list of the instance fields of class `c`, including
		inherited fields.

		This only includes fields which are known at compile-time. In
		particular, using `getInstanceFields(getClass(obj))` will not include
		any fields which were added to `obj` at runtime.

		The order of the fields in the returned Array is unspecified.

		If `c` is null, the result is unspecified.
	**/
	public static function getInstanceFields(c:Class<Dynamic>):Array<String>
		untyped return c.__fields__;

	/**
		Returns a list of static fields of class `c`.

		This does not include static fields of parent classes.

		The order of the fields in the returned Array is unspecified.

		If `c` is null, the result is unspecified.
	**/
	public static function getClassFields(c:Class<Dynamic>):Array<String>
		untyped return c.__prototype__;

	/**
		Returns a list of the names of all constructors of enum `e`.

		The order of the constructor names in the returned Array is preserved
		from the original syntax.

		If `e` is null, the result is unspecified.
	**/
	public static function getEnumConstructs(e:Enum<Dynamic>):Array<String>
		return untyped e.__fname__;

	/**
		Returns the runtime type of value `v`.

		The result corresponds to the type `v` has at runtime, which may vary
		per platform. Assumptions regarding this should be minimized to avoid
		surprises.
	**/
	public static function typeof(v:Dynamic):ValueType
	{
		switch (untyped type(v))
		{
			case "boolean":
				return TBool;
			case "string":
				return TClass(String);
			case "number":
				// this should handle all cases : NaN, +/-Inf and Floats outside range
				if (Math.ceil(v) == v % 2147483648.0)
					return TInt;
				return TFloat;
			case "table":
				var e = untyped v.__enum__;
				if (e != null)
					return TEnum(e);
				var c = getClass(v);
				if (c != null)
					return TClass(c);
				return TObject;
			case "function":
				return TFunction;
			case "nil":
				return TNull;
			default:
				return TUnknown;
		}
	}

	/**
		Recursively compares two enum instances `a` and `b` by value.

		Unlike `a == b`, this function performs a deep equality check on the
		arguments of the constructors, if exists.

		If `a` or `b` are null, the result is unspecified.
	**/
	public static function enumEq<T:EnumValue>(a:T, b:T):Bool untyped
	{
		if (a == b)
			return true;
		try
		{
			if (a[0] != b[0])
				return false;
			for (i in 2...a.length)
				if (!enumEq(a[i], b[i]))
					return false;
			var e = a.__enum__;
			if (e != b.__enum__ || e == null)
				return false;
		}
		catch (e:Dynamic)
		{
			return false;
		}
		return true;
	}

	/**
		Returns the constructor name of enum instance `e`.

		The result String does not contain any constructor arguments.

		If `e` is null, the result is unspecified.
	**/
	public static function enumConstructor(e:EnumValue):String
		return untyped e.__name__;

	/**
		Returns a list of the constructor arguments of enum instance `e`.

		If `e` has no arguments, the result is [].

		Otherwise the result are the values that were used as arguments to `e`,
		in the order of their declaration.

		If `e` is null, the result is unspecified.
	**/
	public static function enumParameters(e:EnumValue):Array<Dynamic>
	{
		var c = untyped e.__enum__.__param_constr__[e.__name__];
		var e:Array<Dynamic> = [];
		untyped __lua__("for i = 1, #{0}, 1 do\n\ttable.insert({1}, {0}[i])\nend", c, e);
		return e;
	}

	/**
		Returns the index of enum instance `e`.

		This corresponds to the original syntactic position of `e`. The index of
		the first declared constructor is 0, the next one is 1 etc.

		If `e` is null, the result is unspecified.
	**/
	public static function enumIndex(e:EnumValue):Int
		return untyped e.index;

	/**
		Returns a list of all constructors of enum `e` that require no
		arguments.

		This may return the empty Array `[]` if all constructors of `e` require
		arguments.

		Otherwise an instance of `e` constructed through each of its non-
		argument constructors is returned, in the order of the constructor
		declaration.

		If `e` is null, the result is unspecified.
	**/
	public static function allEnums<T>(e:Enum<T>):Array<T>
		return untyped e.__empty_constr__;
}

/**
	The different possible runtime types of a value.
**/
enum ValueType
{
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass(c:Class<Dynamic>);
	TEnum(e:Enum<Dynamic>);
	TUnknown;
}
