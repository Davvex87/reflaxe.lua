package shared;

import haxe.rtti.Rtti;
import haxe.rtti.CType;
import rlua.Lua.*;
import shared.Assert;

class TestRunner
{
	public static function runTestSuite(suite:Class<Dynamic>):Void
	{
		final className = Type.getClassName(suite);

		print('Running test suite "$className"...');

		final classRtti = Rtti.getRtti(suite);
		var allResults:Map<String, Array<AssertionResult>> = new Map();
		var failed:Bool = false;
		// Test functions are static, so they live in `statics`, not `fields`.
		for (f in classRtti.statics)
		{
			if (!f.type.match(CType.CFunction(_, _)))
				continue;

			for (meta in f.meta)
			{
				if (meta.name == "test")
				{
					final noFailures = runTest(suite, f.name);
					if (!noFailures)
						failed = true;
					allResults.set(f.name, Assert.results);
					break;
				}
			}
		}
	}

	static function runTest(suite:Class<Dynamic>, fnName:String):Bool
	{
		Assert.results = [];

		final startTime = Sys.time();

		var fn = Reflect.field(suite, fnName);
		if (fn == null)
		{
			print('| Could not find test function named "$fnName"');
			return false;
		}

		print('| Running test "$fnName"...');

		fn();

		print('  | Finished in ${Sys.time() - startTime} seconds');
		// print('  | Done running tests, took ${Sys.time() - startTime} seconds');
		// print("  | Test Results:");

		var success = 0, failed = 0;
		for (i in 0...Assert.results.length)
		{
			var result = Assert.results[i];
			if (result.passed)
				success++;
			else
				failed++;
		}

		print('  | Ran ${Assert.results.length} tests, $success passed, $failed failed:');

		var i = 0;
		for (result in Assert.results)
		{
			i++;
			if (result.passed)
				print('   > Test $i: PASSED | ${result.pos != null ? result.pos.fileName + ":" + result.pos.lineNumber : "???"}');
			else
				print('   > Test $i: FAILED - ${result.msg()} | ${result.pos != null ? result.pos.fileName + ":" + result.pos.lineNumber : "???"}');
		}
		return failed == 0;
	}
}
