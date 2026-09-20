package shared;

import haxe.Constraints.Function;
import haxe.PosInfos;

class Assert
{
	public static var results:Array<AssertionResult> = [];

	private static function processResult(condition:Bool, msg:Void->String, ?pos:PosInfos):Bool
	{
		var result:AssertionResult = {
			passed: condition,
			msg: msg,
			pos: pos
		};
		results.push(result);
		return condition;
	}

	public static function equals(value:Dynamic, expected:Dynamic, ?pos:PosInfos):Bool
		return processResult(value == expected, () -> 'Expected $expected, got $value', pos);

	public static function isTrue(value:Dynamic, ?pos:PosInfos):Bool
		return processResult(value == true, () -> 'Expected true, got $value', pos);

	public static function isFalse(value:Dynamic, ?pos:PosInfos):Bool
		return processResult(value == false, () -> 'Expected false, got $value', pos);

	public static function isNull(value:Dynamic, ?pos:PosInfos):Bool
		return processResult(value == null, () -> 'Expected null, got $value', pos);

	public static function run(fn:Function, ?pos:PosInfos):Bool
	{
		var passed:Bool = true;
		try
			fn()
		catch (_)
			passed = false;
		return processResult(passed, () -> 'Function threw exception');
	}

	public static function runWith(fn:Function, expected:Dynamic, ?pos:PosInfos):Bool
	{
		var passed:Bool = false;
		try
			passed = fn() == expected
		catch (_)
			passed = false;
		return processResult(passed, () -> 'Function did not return expected value $expected', pos);
	}

	public static function throws(fn:Function, ?pos:PosInfos):Bool
	{
		var passed:Bool = false;
		try
			fn()
		catch (_)
			passed = true;
		return processResult(passed, () -> 'Function did not throw exception');
	}

	public static function throwsWith(fn:Function, expected:Class<Dynamic>, ?pos:PosInfos):Bool
	{
		var passed:Bool = false;
		try
			fn()
		catch (e)
			passed = Std.isOfType(e, expected);
		return processResult(passed, () -> 'Function did not throw expected exception $expected', pos);
	}
}

typedef AssertionResult =
{
	var passed:Bool;
	var msg:Void->String;
	var ?pos:PosInfos;
}
