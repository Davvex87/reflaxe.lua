package pkg;

abstract MyAbstractNumber(Int) from Int to Int
{
	// Basic checks
	public inline function isEven():Bool
		return this % 2 == 0;

	public inline function isOdd():Bool
		return this % 2 != 0;

	public inline function isZero():Bool
		return this == 0;

	// Arithmetic helpers (returning the abstract type)
	public inline function add(n:Int):MyAbstractNumber
		return cast(this + n, MyAbstractNumber);

	public inline function sub(n:Int):MyAbstractNumber
		return cast(this - n, MyAbstractNumber);

	public inline function mul(n:Int):MyAbstractNumber
		return cast(this * n, MyAbstractNumber);

	public inline function divSafe(n:Int):MyAbstractNumber
	{
		if (n == 0)
			return cast(0, MyAbstractNumber);
		return cast(this / n, MyAbstractNumber);
	}

	public inline function mod(n:Int):Int
	{
		if (n == 0)
			return 0;
		return this % n;
	}

	public inline function negate():MyAbstractNumber
		return cast(-this, MyAbstractNumber);

	// Conversions
	public inline function toFloat():Float
		return this;

	public inline function toHex():String
		return StringTools.hex(this);

	// Clamp and power
	public inline function clamp(min:Int, max:Int):MyAbstractNumber
	{
		if (this < min)
			return cast(min, MyAbstractNumber);
		if (this > max)
			return cast(max, MyAbstractNumber);
		return cast(this, MyAbstractNumber);
	}

	public inline function pow(exp:Int):MyAbstractNumber
	{
		// returns integer power (may overflow for large values)
		return cast(Std.int(Math.pow(this, exp)), MyAbstractNumber);
	}

	// GCD / LCM
	public inline function gcd(other:Int):Int
	{
		var a:Int = cast this;
		var b:Int = cast other;
		while (b != 0)
		{
			var t = a % b;
			a = b;
			b = t;
		}
		return a;
	}

	public inline function lcm(other:Int):Int
	{
		if (this == 0 || other == 0)
			return 0;
		return Std.int(Math.abs((this / gcd(other)) * other));
	}

	// Digit operations
	public inline function digits():Array<Int>
	{
		var n:Int = cast this;
		if (n == 0)
			return [0];
		var digs = new Array<Int>();
		while (n > 0)
		{
			digs.push(n % 10);
			n = Std.int(n / 10);
		}
		digs.reverse();
		return digs;
	}

	public inline function sumDigits():Int
	{
		var s:Int = 0;
		var n:Int = cast this;
		while (n > 0)
		{
			s += n % 10;
			n = Std.int(n / 10);
		}
		return s;
	}

	public inline function reverseDigits():MyAbstractNumber
	{
		var n:Int = cast this;
		var rev:Int = 0;
		while (n > 0)
		{
			rev = rev * 10 + (n % 10);
			n = Std.int(n / 10);
		}
		if (this < 0)
			rev = -rev;
		return cast(rev, MyAbstractNumber);
	}

	// Bit operations
	public inline function bitCount():Int
	{
		var n:Int = cast this;
		var cnt:Int = 0;
		while (n != 0)
		{
			if ((n & 1) != 0)
				cnt++;
			n = n >>> 1;
		}
		return cnt;
	}

	// Prime check (naive)
	public inline function isPrime():Bool
	{
		var n = Math.abs(this);
		if (n < 2)
			return false;
		if (n % 2 == 0)
			return n == 2;
		var r = Std.int(Math.sqrt(n));
		var i = 3;
		while (i <= r)
		{
			if (n % i == 0)
				return false;
			i += 2;
		}
		return true;
	}

	// String / parsing helpers
	public inline function toString():String
		return Std.string(this);

	// Random helper
	public static inline function randomBetween(min:Int, max:Int):MyAbstractNumber
	{
		if (max < min)
		{
			var t = min;
			min = max;
			max = t;
		}
		var r = Std.int(Math.floor(Math.random() * (max - min + 1))) + min;
		return cast(r, MyAbstractNumber);
	}
}
