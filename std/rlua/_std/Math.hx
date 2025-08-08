/**
	This class defines mathematical functions and constants.

	@see https://haxe.org/manual/std-math.html
**/
extern class Math {
	/**
		Represents the ratio of the circumference of a circle to its diameter,
		specified by the constant, π. `PI` is approximately `3.141592653589793`.
	**/
	public static var PI(get, null):Float;
	public static inline function get_PI():Float
		return untyped math.pi;

	/**
		A special `Float` constant which denotes negative infinity.

		For example, this is the result of `-1.0 / 0.0`.

		Operations with `NEGATIVE_INFINITY` as an operand may result in
		`NEGATIVE_INFINITY`, `POSITIVE_INFINITY` or `NaN`.

		If this constant is converted to an `Int`, e.g. through `Std.int()`, the
		result is unspecified.
	**/
	public static var NEGATIVE_INFINITY(get, null):Float;
	public static inline function get_NEGATIVE_INFINITY():Float
		return untyped -math.huge;

	/**
		A special `Float` constant which denotes positive infinity.

		For example, this is the result of `1.0 / 0.0`.

		Operations with `POSITIVE_INFINITY` as an operand may result in
		`NEGATIVE_INFINITY`, `POSITIVE_INFINITY` or `NaN`.

		If this constant is converted to an `Int`, e.g. through `Std.int()`, the
		result is unspecified.
	**/
	public static var POSITIVE_INFINITY(get, null):Float;
	public static inline function get_POSITIVE_INFINITY():Float
		return untyped math.huge;

	/**
		A special `Float` constant which denotes an invalid number.

		`NaN` stands for "Not a Number". It occurs when a mathematically incorrect
		operation is executed, such as taking the square root of a negative
		number: `Math.sqrt(-1)`.

		All further operations with `NaN` as an operand will result in `NaN`.

		If this constant is converted to an `Int`, e.g. through `Std.int()`, the
		result is unspecified.

		In order to test if a value is `NaN`, you should use `Math.isNaN()` function.
	**/
	public static var NaN(get, null):Float;
	public static inline function get_NaN():Float
		return untyped __lua__("0/0");

	/**
		Returns the absolute value of `v`.

		- If `v` is positive or `0`, the result is unchanged. Otherwise the result is `-v`.
		- If `v` is `NEGATIVE_INFINITY` or `POSITIVE_INFINITY`, the result is `POSITIVE_INFINITY`.
		- If `v` is `NaN`, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.abs({arg0})")
	public static function abs(v:Float):Float;

	/**
		Returns the smaller of values `a` and `b`.

		- If `a` or `b` are `NaN`, the result is `NaN`.
		- If `a` or `b` are `NEGATIVE_INFINITY`, the result is `NEGATIVE_INFINITY`.
		- If `a` and `b` are `POSITIVE_INFINITY`, the result is `POSITIVE_INFINITY`.
	**/
	@:nativeFunctionCode("math.min({arg0}, {arg1})")
	public static function min(a:Float, b:Float):Float;

	/**
		Returns the greater of values `a` and `b`.

		- If `a` or `b` are `NaN`, the result is `NaN`.
		- If `a` or `b` are `POSITIVE_INFINITY`, the result is `POSITIVE_INFINITY`.
		- If `a` and `b` are `NEGATIVE_INFINITY`, the result is `NEGATIVE_INFINITY`.
	**/
	@:nativeFunctionCode("math.max({arg0}, {arg1})")
	public static function max(a:Float, b:Float):Float;

	/**
		Returns the trigonometric sine of the specified angle `v`, in radians.

		If `v` is `NaN` or infinite, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.sin({arg0})")
	public static function sin(v:Float):Float;

	/**
		Returns the trigonometric cosine of the specified angle `v`, in radians.

		If `v` is `NaN` or infinite, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.cos({arg0})")
	public static function cos(v:Float):Float;

	/**
		Returns the trigonometric tangent of the specified angle `v`, in radians.

		If `v` is `NaN` or infinite, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.tan({arg0})")
	public static function tan(v:Float):Float;

	/**
		Returns the trigonometric arc of the specified angle `v`, in radians.

		If `v` is `NaN` or infinite, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.asin({arg0})")
	public static function asin(v:Float):Float;

	/**
		Returns the trigonometric arc cosine of the specified angle `v`,
		in radians.

		If `v` is `NaN` or infinite, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.acos({arg0})")
	public static function acos(v:Float):Float;

	/**
		Returns the trigonometric arc tangent of the specified angle `v`,
		in radians.

		If `v` is `NaN` or infinite, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.atan({arg0})")
	public static function atan(v:Float):Float;

	/**
		Returns the trigonometric arc tangent whose tangent is the quotient of
		two specified numbers, in radians.

		If parameter `x` or `y`  is `NaN`, `NEGATIVE_INFINITY` or `POSITIVE_INFINITY`,
		the result is `NaN`.
	**/
	@:nativeFunctionCode("math.atan2({arg0}, {arg1})")
	public static function atan2(y:Float, x:Float):Float;

	/**
		Returns Euler's number, raised to the power of `v`.

		`exp(1.0)` is approximately `2.718281828459`.

		- If `v` is `POSITIVE_INFINITY`, the result is `POSITIVE_INFINITY`.
		- If `v` is `NEGATIVE_INFINITY`, the result is `0.0`.
		- If `v` is `NaN`, the result is `NaN`.
	**/
	@:nativeFunctionCode("math.exp({arg0})")
	public static function exp(v:Float):Float;

	/**
		Returns the natural logarithm of `v`.

		This is the mathematical inverse operation of exp,
		i.e. `log(exp(v)) == v` always holds.

		- If `v` is negative (including `NEGATIVE_INFINITY`) or `NaN`, the result is `NaN`.
		- If `v` is `POSITIVE_INFINITY`, the result is `POSITIVE_INFINITY`.
		- If `v` is `0.0`, the result is `NEGATIVE_INFINITY`.
	**/
	@:nativeFunctionCode("math.log({arg0})")
	public static function log(v:Float):Float;

	/**
		Returns a specified base `v` raised to the specified power `exp`.
	**/
	@:nativeFunctionCode("{arg0} ^ {arg0}")
	public static function pow(v:Float, exp:Float):Float;

	/**
		Returns the square root of `v`.

		- If `v` is negative (including `NEGATIVE_INFINITY`) or `NaN`, the result is `NaN`.
		- If `v` is `POSITIVE_INFINITY`, the result is `POSITIVE_INFINITY`.
		- If `v` is `0.0`, the result is `0.0`.
	**/
	@:nativeFunctionCode("math.sqrt({arg0})")
	public static function sqrt(v:Float):Float;

	/**
		Rounds `v` to the nearest integer value.

		Ties are rounded up, so that `0.5` becomes `1` and `-0.5` becomes `0`.

		If `v` is outside of the signed `Int32` range, or is `NaN`, `NEGATIVE_INFINITY`
		or `POSITIVE_INFINITY`, the result is unspecified.
	**/
	@:nativeFunctionCode("math.floor({arg0} + 0.5)")
	public static function round(v:Float):Int;

	/**
		Returns the largest integer value that is not greater than `v`.

		If `v` is outside of the signed `Int32` range, or is `NaN`, `NEGATIVE_INFINITY`
		or `POSITIVE_INFINITY`, the result is unspecified.
	**/
	@:nativeFunctionCode("math.floor({arg0})")
	public static function floor(v:Float):Int;

	/**
		Returns the smallest integer value that is not less than `v`.

		If `v` is outside of the signed `Int32` range, or is `NaN`, `NEGATIVE_INFINITY`
		or `POSITIVE_INFINITY`, the result is unspecified.
	**/
	@:nativeFunctionCode("math.ceil({arg0})")
	public static function ceil(v:Float):Int;

	/**
		Returns a pseudo-random number which is greater than or equal to `0.0`,
		and less than `1.0`.
	**/
	@:nativeFunctionCode("math.random()")
	public static function random():Float;

	public static inline function ffloor(v:Float):Float
		return floor(v);

	public static inline function fceil(v:Float):Float
		return ceil(v);

	public static inline function fround(v:Float):Float
		return round(v);

	/**
		Tells if `f` is a finite number.

		If `f` is `POSITIVE_INFINITY`, `NEGATIVE_INFINITY` or `NaN`, the result
		is `false`, otherwise the result is `true`.
	**/
	public static inline function isFinite(f:Float):Bool
		return (f > NEGATIVE_INFINITY && f < POSITIVE_INFINITY);

	/**
		Tells if `f` is `Math.NaN`.

		If `f` is `NaN`, the result is `true`, otherwise the result is `false`.
		In particular, `null`, `POSITIVE_INFINITY` and `NEGATIVE_INFINITY` are
		not considered `NaN`.
	**/
	public static inline function isNaN(f:Float):Bool
		return (f != f);
}
