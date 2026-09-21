package tests.unit.suites;

import shared.*;

@:keep
@:rtti
class TestBitwiseOperators
{
	static var staticField:Int = 0xF0;

	var instanceField:Int = 0x0F;

	function new() {}

	@test
	static function testAnd()
	{
		Assert.equals(0xFF & 0x0F, 0x0F);
		Assert.equals(0xC & 0xA, 0x8);
		Assert.equals(0 & 0xFFFF, 0);
		Assert.equals(-1 & 0xFF, 0xFF);
	}

	@test
	static function testOr()
	{
		Assert.equals(0xF0 | 0x0F, 0xFF);
		Assert.equals(0xC | 0xA, 0xE);
		Assert.equals(0 | 0, 0);
		Assert.equals(1 | 2 | 4 | 8, 15);
	}

	@test
	static function testXor()
	{
		Assert.equals(0xFF ^ 0x0F, 0xF0);
		Assert.equals(0xC ^ 0xA, 0x6);
		Assert.equals(123 ^ 123, 0);
		Assert.equals(-1 ^ 0, -1);
	}

	@test
	static function testShiftLeft()
	{
		Assert.equals(1 << 4, 16);
		Assert.equals(1 << 0, 1);
		Assert.equals(3 << 2, 12);
		Assert.equals(1 << 30, 1073741824);
		Assert.equals(1 << 31, -2147483648);
	}

	@test
	static function testShiftRight()
	{
		Assert.equals(16 >> 4, 1);
		Assert.equals(12 >> 2, 3);
		Assert.equals(1 >> 1, 0);
		Assert.equals(-16 >> 2, -4);
		Assert.equals(-1 >> 31, -1);
	}

	@test
	static function testUnsignedShiftRight()
	{
		Assert.equals(16 >>> 4, 1);
		Assert.equals(12 >>> 2, 3);
		Assert.equals(-1 >>> 28, 15);
		Assert.equals(-1 >>> 0, -1);
		Assert.equals(-16 >>> 2, 1073741820);
	}

	@test
	static function testNegBits()
	{
		Assert.equals(~0, -1);
		Assert.equals(~0, -1);
		Assert.equals(~-1, 0);
		Assert.equals(~0xFF, -256);
		Assert.equals(~~42, 42);
	}

	@test
	static function testCompoundAssignments()
	{
		var v = 0xF;

		v &= 0xA;
		Assert.equals(v, 0xA);

		v |= 0x5;
		Assert.equals(v, 0xF);

		v ^= 0x6;
		Assert.equals(v, 0x9);

		v <<= 2;
		Assert.equals(v, 0x24);

		v >>= 1;
		Assert.equals(v, 0x12);

		v = -8;
		v >>>= 1;
		Assert.equals(v, 2147483644);
	}

	@test
	static function testCompoundAssignmentOnStaticField()
	{
		staticField = 0xF0;
		staticField |= 0x0F;
		Assert.equals(staticField, 0xFF);

		staticField &= 0x0F;
		Assert.equals(staticField, 0x0F);

		staticField ^= 0xFF;
		Assert.equals(staticField, 0xF0);

		staticField >>= 4;
		Assert.equals(staticField, 0x0F);

		staticField <<= 4;
		Assert.equals(staticField, 0xF0);
	}

	@test
	static function testCompoundAssignmentOnInstanceField()
	{
		var obj = new TestBitwiseOperators();
		obj.instanceField |= 0xF0;
		Assert.equals(obj.instanceField, 0xFF);

		obj.instanceField &= 0xF0;
		Assert.equals(obj.instanceField, 0xF0);

		obj.instanceField >>>= 4;
		Assert.equals(obj.instanceField, 0x0F);
	}

	@test
	static function testCompoundAssignmentOnArrayElement()
	{
		var arr = [1, 2, 4];
		arr[0] |= 8;
		arr[1] <<= 1;
		arr[2] &= 0;
		Assert.equals(arr[0], 9);
		Assert.equals(arr[1], 4);
		Assert.equals(arr[2], 0);
	}

	@test
	static function testChainedOperators()
	{
		Assert.equals(1 | 2 | 4, 7);
		Assert.equals(0xFF & 0xF0 & 0x30, 0x30);
		Assert.equals(1 ^ 2 ^ 4, 7);
		Assert.equals(1 << 2 << 3, 32);
	}

	@test
	static function testNestedOperators()
	{
		Assert.equals((0xF0 | 0x0F) & 0x3C, 0x3C);
		Assert.equals(~(0xFF & 0x0F) & 0xFF, 0xF0);
		Assert.equals((1 << 4) | (1 << 2), 20);
		Assert.equals((0xABCD >> 8) & 0xFF, 0xAB);
		Assert.equals(((0xABCD & 0xFF) << 8) | (0xABCD >>> 8), 0xCDAB);
	}

	@test
	static function testMixedWithArithmetic()
	{
		Assert.equals(1 + 2 & 2, 2);
		Assert.equals(2 * 3 | 1, 7);
		Assert.equals(8 >> 1 + 1, 2);
		Assert.equals((1 << 3) - 1, 7);
		Assert.equals(10 % 4 ^ 1, 3);
	}

	@test
	static function testMixedWithComparison()
	{
		Assert.isTrue((6 & 2) != 0);
		Assert.isTrue((6 & 1) == 0);
		Assert.isTrue((1 << 3) > 7);
		Assert.isFalse((0xFF ^ 0xFF) > 0);
	}

	@test
	static function testBitwiseInCondition()
	{
		var flags = 0x5;
		var hit = 0;

		if (flags & 0x1 != 0)
			hit++;
		if (flags & 0x2 != 0)
			hit++;
		if (flags & 0x4 != 0)
			hit++;
		if ((flags & 0x8) != 0)
			hit++;

		Assert.equals(hit, 2);
	}

	@test
	static function testBitwiseInLoop()
	{
		var mask = 0;
		for (i in 0...8)
			mask |= 1 << i;
		Assert.equals(mask, 0xFF);

		var count = 0;
		var n = 0xB5;
		while (n != 0)
		{
			count += n & 1;
			n >>>= 1;
		}
		Assert.equals(count, 5);
	}

	@test
	static function testBitwiseInReturn()
	{
		Assert.equals(and(0xFF, 0x0F), 0x0F);
		Assert.equals(or(0xF0, 0x0F), 0xFF);
		Assert.equals(xor(0xFF, 0x0F), 0xF0);
		Assert.equals(shl(1, 8), 256);
		Assert.equals(shr(-256, 8), -1);
		Assert.equals(ushr(-256, 24), 255);
		Assert.equals(not(0), -1);
	}

	@test
	static function testBitwiseAsArguments()
	{
		Assert.equals(sum(1 << 1, 0xF & 0x3, ~-1), 5);
		Assert.equals(and(or(1, 2), xor(7, 4)), 3);
	}

	@test
	static function testBitwiseInLambda()
	{
		var mask = (v:Int, m:Int) -> v & m;
		var setBit = (v:Int, b:Int) -> v | (1 << b);
		var clearBit = (v:Int, b:Int) -> v & ~(1 << b);
		var toggleBit = (v:Int, b:Int) -> v ^ (1 << b);

		Assert.equals(mask(0xFF, 0x0F), 0x0F);
		Assert.equals(setBit(0, 3), 8);
		Assert.equals(clearBit(0xFF, 0), 0xFE);
		Assert.equals(toggleBit(0x5, 1), 0x7);
		Assert.equals(toggleBit(0x7, 1), 0x5);
	}

	@test
	static function testBitwiseInTernary()
	{
		var v = 6;
		Assert.equals(v & 1 == 0 ? v >> 1 : v << 1, 3);
		Assert.equals(v & 2 == 0 ? v >> 1 : v << 1, 12);
	}

	@test
	static function testBitwiseWithArrayMap()
	{
		var input = [1, 2, 4, 8];
		var shifted = input.map(x -> x << 1);
		var masked = input.map(x -> x & 0x6);

		Assert.equals(shifted.join(","), "2,4,8,16");
		Assert.equals(masked.join(","), "0,2,4,0");
	}

	@test
	static function testFlagsPattern()
	{
		var flags = Flags.None;
		flags |= Flags.A;
		flags |= Flags.C;

		Assert.isTrue(flags & Flags.A != 0);
		Assert.isFalse(flags & Flags.B != 0);
		Assert.isTrue(flags & Flags.C != 0);

		flags &= ~Flags.A;
		Assert.isFalse(flags & Flags.A != 0);
		Assert.equals(flags, Flags.C);

		flags ^= Flags.B;
		Assert.equals(flags, Flags.B | Flags.C);
	}

	@test
	static function testPackAndUnpackBytes()
	{
		var packed = pack(0x12, 0x34, 0x56, 0x78);
		Assert.equals(packed, 0x12345678);

		Assert.equals((packed >>> 24) & 0xFF, 0x12);
		Assert.equals((packed >>> 16) & 0xFF, 0x34);
		Assert.equals((packed >>> 8) & 0xFF, 0x56);
		Assert.equals(packed & 0xFF, 0x78);

		var negativePacked = pack(0xFF, 0x00, 0x00, 0x01);
		Assert.equals(negativePacked, -16777215);
		Assert.equals((negativePacked >>> 24) & 0xFF, 0xFF);
		Assert.equals((negativePacked >> 24) & 0xFF, 0xFF);
	}

	@test
	static function testColorChannels()
	{
		var color = 0xFF8040;
		var r = (color >> 16) & 0xFF;
		var g = (color >> 8) & 0xFF;
		var b = color & 0xFF;

		Assert.equals(r, 0xFF);
		Assert.equals(g, 0x80);
		Assert.equals(b, 0x40);
		Assert.equals((r << 16) | (g << 8) | b, color);
	}

	@test
	static function testPowersOfTwo()
	{
		Assert.isTrue(isPowerOfTwo(1));
		Assert.isTrue(isPowerOfTwo(2));
		Assert.isTrue(isPowerOfTwo(1024));
		Assert.isFalse(isPowerOfTwo(0));
		Assert.isFalse(isPowerOfTwo(3));
		Assert.isFalse(isPowerOfTwo(1023));
	}

	@test
	static function testSwapWithXor()
	{
		var a = 17;
		var b = 42;
		a ^= b;
		b ^= a;
		a ^= b;
		Assert.equals(a, 42);
		Assert.equals(b, 17);
	}

	@test
	static function testNullableInt()
	{
		var n:Null<Int> = 0xA;
		Assert.equals(n & 0x2, 0x2);
		Assert.equals(n | 0x5, 0xF);
		Assert.equals(n << 1, 0x14);
	}

	@test
	static function testDynamicOperands()
	{
		var d:Dynamic = 0xF0;
		var result:Int = d | 0x0F;
		Assert.equals(result, 0xFF);
		Assert.equals((d : Int) & 0x30, 0x30);
	}

	@test
	static function testInlineFunctionsWithBitwise()
	{
		Assert.equals(inlineMask(0xABCD, 0xFF), 0xCD);
		Assert.equals(inlineShift(1, 5), 32);
		Assert.equals(inlineNot(0xF0F0) & 0xFFFF, 0x0F0F);
	}

	static function and(a:Int, b:Int):Int
		return a & b;

	static function or(a:Int, b:Int):Int
		return a | b;

	static function xor(a:Int, b:Int):Int
		return a ^ b;

	static function shl(a:Int, b:Int):Int
		return a << b;

	static function shr(a:Int, b:Int):Int
		return a >> b;

	static function ushr(a:Int, b:Int):Int
		return a >>> b;

	static function not(a:Int):Int
		return ~a;

	static function sum(a:Int, b:Int, c:Int):Int
		return a + b + c;

	static function pack(a:Int, b:Int, c:Int, d:Int):Int
		return (a << 24) | (b << 16) | (c << 8) | d;

	static function isPowerOfTwo(v:Int):Bool
		return v > 0 && (v & (v - 1)) == 0;

	static inline function inlineMask(v:Int, m:Int):Int
		return v & m;

	static inline function inlineShift(v:Int, s:Int):Int
		return v << s;

	static inline function inlineNot(v:Int):Int
		return ~v;
}

private class Flags
{
	public static inline var None:Int = 0;
	public static inline var A:Int = 1 << 0;
	public static inline var B:Int = 1 << 1;
	public static inline var C:Int = 1 << 2;
}
