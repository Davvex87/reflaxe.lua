package tests.unit.suites;

import shared.*;

@:keep
@:rtti
class TestFunctionArguments
{
	@test
	static function testFunctionArguments()
	{
		Assert.run(() -> myTestFunction(30, "hello", [""]));
	}

	@test
	static function testOptionalArguments()
	{
		Assert.equals(optionalNumberFunction(), 2);
		Assert.equals(optionalNumberFunction(null), 2);
		Assert.equals(optionalNumberFunction(10), 3);

		Assert.equals(optionalAndNullableStringFunction(), 2);
		Assert.equals(optionalAndNullableStringFunction(null), 2);
		Assert.equals(optionalAndNullableStringFunction("hey"), 3);
	}

	@test
	static function testDefaultArguments()
	{
		Assert.isTrue(nullableStringFunction());
		Assert.isTrue(nullableStringFunction(null));
		Assert.isFalse(nullableStringFunction("cool text!"));
	}

	@test
	static function testRestCallPassing()
	{
		Assert.equals(countArgs(1, 2, 3), 3);
		Assert.equals(countArgs("a"), 1);
		Assert.equals(countArgs(), 0);
	}

	@test
	static function testRestCallPassingComplex()
	{
		Assert.equals(countArgsComplex(2, 1, 2, 3), 6);
		Assert.equals(countArgsComplex(3, "a", "b", null), 6);
		Assert.equals(countArgsComplex(10, 1.2, 3.4, {name: "David"}, null, "null"), 50);
		Assert.equals(countArgsComplex(1, null), 0);
	}

	@test
	static function testRestCallException()
	{
		Assert.run(() -> checkForOddNumbers(1, 3, 5, 7));
		Assert.throws(() -> checkForOddNumbers(2, 4, 6));
	}

	@test
	static function testFunctionBind()
	{
		var boundFunction = myTestFunction.bind(4, "hello", [""]);
		Assert.runWith(boundFunction, 2);

		var anotherBoundFunction = nullableStringFunction.bind("not null");
		Assert.isFalse(anotherBoundFunction());
	}

	static function myTestFunction(number:Int, text:String, names:Array<String>):Int
	{
		var messages:Int = 0;

		if (number > 18)
			messages++;

		if (text == "hello")
			messages++;

		if (names.length == 1)
			messages++;

		return messages;
	}

	static function optionalNumberFunction(n:Null<Int> = 5):Int
	{
		if (n == null)
			return 1;

		if (n == 5)
			return 2;

		return 3;
	}

	static function optionalAndNullableStringFunction(?o:String = "Hello"):Int
	{
		if (o == null)
			return 1;

		if (o == "Hello")
			return 2;

		return 3;
	}

	static function nullableStringFunction(?o:String):Bool
	{
		if (o == null)
			return true;
		else
			return false;
	}

	static function countArgs(...args:Dynamic):Int
	{
		return args.length;
	}

	static function checkForOddNumbers(...numbers:Int)
	{
		for (n in numbers)
		{
			if (n % 2 == 0)
				throw "Even number found: $n";
		}
	}

	static function countArgsComplex(multiplier:Int, ...args:Dynamic):Int
	{
		return args.length * multiplier;
	}
}
