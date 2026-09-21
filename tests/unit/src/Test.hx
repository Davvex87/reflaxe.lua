import tests.unit.suites.*;
import shared.TestRunner;

class Test
{
	static function main()
	{
		TestUnusedBlockResults.main();
		TestRunner.runTestSuite(TestStrings);
		TestRunner.runTestSuite(TestFunctionArguments);
		TestRunner.runTestSuite(TestBitwiseOperators);
		// haxe.EntryPoint.run();
	}
}

class TestUnusedBlockResults
{
	public static function main()
	{
		trace("=== Testing RemoveUnusedBlockResults Preprocessor ===");

		testInlineFunctionUnused();
		testInlineFunctionUsed();
		testLoneBlockUnused();
		testLoneBlockUsed();
		testNestedBlocks();
		testBranchingConstructs();
		testLoops();
		testMixedScenarios();
	}

	// Test 1: Inline function called but return value NOT used
	static function testInlineFunctionUnused()
	{
		trace("\n--- Test 1: Inline function return unused ---");
		var myArray:Array<String> = ["a", "b", "c"];

		// This should have the pure expression "arr.length - 1" removed
		add(myArray, "d");

		trace("Array after add: " + myArray);
	}

	// Test 2: Inline function called and return value IS used
	static function testInlineFunctionUsed()
	{
		trace("\n--- Test 2: Inline function return used ---");
		var myArray:Array<String> = ["a", "b", "c"];

		// This should keep "arr.length - 1" because we use it
		var index = add(myArray, "d");

		trace("Array after add: " + myArray);
		trace("Returned index: " + index);
	}

	// Test 3: Lone block whose result is NOT used
	static function testLoneBlockUnused()
	{
		trace("\n--- Test 3: Lone block result unused ---");

		// The final pure expression should be removed
		{
			var x = 10;
			var y = 20;
			x + y; // Pure expression, unused - should be removed
		}

		trace("Block executed");
	}

	// Test 4: Lone block whose result IS used
	static function testLoneBlockUsed()
	{
		trace("\n--- Test 4: Lone block result used ---");

		// The final expression should be kept
		var result =
			{
				var x = 10;
				var y = 20;
				x + y; // Pure expression, but used - should be kept
			};

		trace("Block result: " + result);
	}

	// Test 5: Nested blocks
	static function testNestedBlocks()
	{
		trace("\n--- Test 5: Nested blocks ---");

		// Outer block unused, inner block unused
		{
			{
				var a = 5;
				a * 2; // Should be removed
			}
			var b = 10;
			b + 5; // Should be removed
		}

		// Outer block used, inner block used
		var result =
			{
				var inner =
					{
						var a = 5;
						a * 2; // Should be kept (inner block result is used)
					};
				inner + 10; // Should be kept (outer block result is used)
			};

		trace("Nested result: " + result);
	}

	// Test 6: Branching constructs (if/else, switch)
	static function testBranchingConstructs()
	{
		trace("\n--- Test 6: Branching constructs ---");

		var x = 5;

		// If/else with unused result
		if (x > 3)
		{
			var y = x * 2;
			y + 1; // Pure, unused - should be removed
		}
		else
		{
			var z = x * 3;
			z - 1; // Pure, unused - should be removed
		}

		// If/else with used result
		var ifResult = if (x > 3)
		{
			var y = x * 2;
			y + 1; // Pure, but used - should be kept
		}
		else
		{
			var z = x * 3;
			z - 1; // Pure, but used - should be kept
		};

		trace("If/else result: " + ifResult);

		// Switch with unused result
		switch (x)
		{
			case 5:
				var a = 10;
				a + 5; // Pure, unused - should be removed
			default:
				var b = 20;
				b * 2; // Pure, unused - should be removed
		}

		// Switch with used result
		var switchResult = switch (x)
		{
			case 5:
				var a = 10;
				a + 5; // Pure, but used - should be kept
			default:
				var b = 20;
				b * 2; // Pure, but used - should be kept
		};

		trace("Switch result: " + switchResult);
	}

	// Test 7: Loops
	static function testLoops()
	{
		trace("\n--- Test 7: Loops ---");

		var i = 0;

		// While loop - body result never used
		while (i < 3)
		{
			i++;
			trace(i);
			i * 2; // Pure, loop body result never used - should be removed
		}

		// For loop - body result never used
		for (j in 0...3)
		{
			var temp = j * 2;
			temp + 1; // Pure, loop body result never used - should be removed
		}

		trace("Loops completed");
	}

	// Test 8: Mixed scenarios
	static function testMixedScenarios()
	{
		trace("\n--- Test 8: Mixed scenarios ---");

		var arr = [1, 2, 3];

		// Inline function with side effects (should always be kept)
		pushAndReturn(arr, 4);
		trace("After pushAndReturn (unused): " + arr);

		// Same but result used
		var idx = pushAndReturn(arr, 5);
		trace("After pushAndReturn (used): " + arr + ", index: " + idx);

		// Pure inline function, unused
		pureCalculation(10, 20);

		// Pure inline function, used
		var calc = pureCalculation(10, 20);
		trace("Pure calculation result: " + calc);

		// Block with side effects at end (should be kept even if unused)
		{
			var x = 5;
			trace("Side effect in block"); // Side effect - should be kept
		}

		// Block with statement at end (already a statement, should be kept)
		{
			var x = 5;
			var y = 10; // Statement - should be kept
		}

		// Try/catch with unused result
		try
		{
			var x = 10;
			x / 2; // Pure, unused - should be removed
		}
		catch (e:Dynamic)
		{
			var y = 0;
			y + 1; // Pure, unused - should be removed
		}

		// Try/catch with used result
		var tryResult = try
		{
			var x = 10;
			x / 2; // Pure, but used - should be kept
		}
		catch (e:Dynamic)
		{
			var y = 0;
			y + 1; // Pure, but used - should be kept
		};

		trace("Try/catch result: " + tryResult);
	}

	// Helper inline functions
	static inline function add<T>(arr:Array<T>, val:T):Int
	{
		arr.push(val);
		return arr.length - 1; // Pure expression as final result
	}

	static inline function pushAndReturn<T>(arr:Array<T>, val:T):Int
	{
		arr.push(val); // Side effect
		return arr.length - 1; // Pure expression as final result
	}

	static inline function pureCalculation(a:Int, b:Int):Int
	{
		var temp = a * 2;
		return temp + b; // Completely pure
	}
}
