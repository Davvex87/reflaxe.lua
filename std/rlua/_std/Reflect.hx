/**
	The Reflect API is a way to manipulate values dynamically through an
	abstract interface in an untyped manner. Use with care.

	@see https://haxe.org/manual/std-reflection.html
**/

import rlua.Runtime;

class Reflect
{
	/**
		Tells if structure `o` has a field named `field`.

		This is only guaranteed to work for anonymous structures. Refer to
		`Type.getInstanceFields` for a function supporting class instances.

		If `o` or `field` are null, the result is unspecified.
	**/
	public static function hasField(o:Dynamic, field:String):Bool untyped
	{
		if (o == null || field == null)
			return false;
		return o[field] != null;
	}

	/**
		Returns the value of the field named `field` on object `o`.

		If `o` is not an object or has no field named `field`, the result is
		null.

		If the field is defined as a property, its accessors are ignored. Refer
		to `Reflect.getProperty` for a function supporting property accessors.

		If `field` is null, the result is unspecified.
	**/
	public static function field(o:Dynamic, field:String):Dynamic untyped
	{
		if (o == null || field == null)
			return null;
		return o[field];
	}

	/**
		Sets the field named `field` of object `o` to value `value`.

		If `o` has no field named `field`, this function is only guaranteed to
		work for anonymous structures.

		If `o` or `field` are null, the result is unspecified.
	**/
	public static function setField(o:Dynamic, field:String, value:Dynamic):Void untyped
	{
		o[field] = value;
	}

	/**
		Returns the value of the field named `field` on object `o`, taking
		property getter functions into account.

		If the field is not a property, this function behaves like
		`Reflect.field`, but might be slower.

		If `o` or `field` are null, the result is unspecified.
	**/
	public static function getProperty(o:Dynamic, field:String):Dynamic untyped
	{
		if (o == null || field == null)
			return null;
		if (Reflect.field(o, "get_" + field) != null)
			return Reflect.callMethod(o, Reflect.field(o, "get_" + field), []);
		return Reflect.field(o, field);
	}

	/**
		Sets the field named `field` of object `o` to value `value`, taking
		property setter functions into account.

		If the field is not a property, this function behaves like
		`Reflect.setField`, but might be slower.

		If `field` is null, the result is unspecified.
	**/
	public static function setProperty(o:Dynamic, field:String, value:Dynamic):Void untyped
	{
		if (o == null || field == null)
			return;
		if (Reflect.field(o, "set_" + field) != null)
			Reflect.callMethod(o, Reflect.field(o, "set_" + field), [value]);
		else
			o[field] = value;
	}

	/**
		Call a method `func` with the given arguments `args`.

		The object `o` is ignored in most cases. It serves as the `this`-context in the following
		situations:

		* (neko) Allows switching the context to `o` in all cases.
		* (macro) Same as neko for Haxe 3. No context switching in Haxe 4.
		* (js, lua) Require the `o` argument if `func` does not, but should have a context.
			This can occur by accessing a function field natively, e.g. through `Reflect.field`
			or by using `(object : Dynamic).field`. However, if `func` has a context, `o` is
			ignored like on other targets.
	**/
	public static function callMethod(o:Dynamic, func:haxe.Constraints.Function, args:Array<Dynamic>):Dynamic
	{
		if (args == null || args.length == 0)
			return func(o);
		else
		{
			var self_arg = false;
			if (o != null && untyped (o.__class__) != null)
				self_arg = true;
			return if (self_arg) func(o, untyped (table.unpack(args))); else func(untyped (table.unpack(args)));
		}
	}

	/**
		Returns the fields of structure `o`.

		This method is only guaranteed to work on anonymous structures. Refer to
		`Type.getInstanceFields` for a function supporting class instances.

		If `o` is null, the result is unspecified.
	**/
	public static function fields(o:Dynamic):Array<String>
	{
		var r = [];
		untyped __lua__("for k in pairs({0}) do table.insert({1}, k) end", o, r);
		return r;
	}

	/**
		Returns true if `f` is a function, false otherwise.

		If `f` is null, the result is false.
	**/
	public static function isFunction(f:Dynamic):Bool
		untyped return type(f) == "function";

	/**
		Compares `a` and `b`.

		If `a` is less than `b`, the result is negative. If `b` is less than
		`a`, the result is positive. If `a` and `b` are equal, the result is 0.

		This function is only defined if `a` and `b` are of the same type.

		If that type is a function, the result is unspecified and
		`Reflect.compareMethods` should be used instead.

		For all other types, the result is 0 if `a` and `b` are equal. If they
		are not equal, the result depends on the type and is negative if:

		- Numeric types: a is less than b
		- String: a is lexicographically less than b
		- Other: unspecified

		If `a` and `b` are null, the result is 0. If only one of them is null,
		the result is unspecified.
	**/
	public static function compare<T>(a:T, b:T):Int
	{
		if (a == b)
			return 0
		else if (a == null)
			return -1
		else if (b == null)
			return 1
		else
			return (cast a) > (cast b) ? 1 : -1;
	}

	/**
		Compares the functions `f1` and `f2`.

		If `f1` or `f2` are null, the result is false.
		If `f1` or `f2` are not functions, the result is unspecified.

		Otherwise the result is true if `f1` and the `f2` are physically equal,
		false otherwise.

		If `f1` or `f2` are member method closures, the result is true if they
		are closures of the same method on the same object value, false otherwise.
	**/
	public static function compareMethods(f1:Dynamic, f2:Dynamic):Bool
		return f1 == f2;

	/**
		Tells if `v` is an object.

		The result is true if `v` is one of the following:

		- class instance
		- structure
		- `Class<T>`
		- `Enum<T>`

		Otherwise, including if `v` is null, the result is false.
	**/
	public static function isObject(v:Dynamic):Bool
		return (untyped (type(v) == "table" && (v.__class__ != null || v.__enum__ != null || v.__name__ != null))) && !Runtime.isArray(v);

	/**
		Tells if `v` is an enum value.

		The result is true if `v` is of type EnumValue, i.e. an enum
		constructor.

		Otherwise, including if `v` is null, the result is false.
	**/
	public static function isEnumValue(v:Dynamic):Bool
		untyped return v != null && type(v) == "table" && v.__enum__ != null;

	/**
		Removes the field named `field` from structure `o`.

		This method is only guaranteed to work on anonymous structures.

		If `o` or `field` are null, the result is unspecified.
	**/
	public static function deleteField(o:Dynamic, field:String):Bool untyped
	{
		if (!Reflect.hasField(o, field))
			return false;
		o[field] = null;
		return true;
	}

	/**
		Copies the fields of structure `o`.

		This is only guaranteed to work on anonymous structures.

		If `o` is null, the result is `null`.
	**/
	public static function copy<T>(o:Null<T>):Null<T>
	{
		if (o == null)
			return null;
		var o2:Dynamic = {};
		for (f in fields(o))
			setField(o2, f, field(o, f));
		return o2;
	}

	/**
		Transform a function taking an array of arguments into a function that can
		be called with any number of arguments.
	**/
	@:overload(function(f:Array<Dynamic>->Void):Dynamic {})
	public static function makeVarArgs(f:Array<Dynamic>->Dynamic):Dynamic
		return untyped __lua__("function(...)
			return f({...})
		end");
}
