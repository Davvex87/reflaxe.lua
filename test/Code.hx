package;

import pkg.CustomExternClass;
import pkg.MyAbstractNumber;
import pkg.entities.CoolEntity;
import pkg.entities.AbstractEntity;
import rlua.Coroutine;
import rlua.Os;

enum TestEnum
{
	One;
	Two;
	Three;
}

enum AdvancedEnum
{
	Normal;
	Constructor(arg:Array<Int>);
	Constructor2Args(text:String, moreText:String);
	AnotherConstr(fav:Class<Dynamic>);
	Something;
	YetAnotherConstr(bananas:Float, ?yes:Bool);
}

interface TestInterface
{
	public function increment(i:Int):Void;
}

class TestClass implements TestInterface
{
	var field:TestEnum;

	public function new(arg1:String, arg2:TestEnum = One, ...rest:Float)
	{
		trace("Create Code class! " + arg1);
		field = arg2 ?? Two;
		print(rest);
		print(rest.toArray());
		print(rest.length);

		var arr = [1, 2, 5];
		print(arr.join(", ")); // "1, 2, 5"
		print(arr.length); // 3
		print(arr[2]); // 5
		arr[3] = Math.round(Math.PI);

		for (num in arr)
		{
			print(num);
		}

		var a = new Array();
		for (i in 0...arr.length)
			a.push(i);

		trace(a);

		print(CustomExternClass.staticMethod("Hello from static method!"));
		print(Type.typeof(Test));
		var customCls = new CustomExternClass();
		customCls.instanceMethod(42);

		var otherArray:Array<Int> = new Array<Int>();
		otherArray.push(8);
		otherArray.pop();

		print(otherArray.concat(arr));

		var e:Dynamic = cast "TestStr";
		print(e & 20); // "print(e + 20)"
		print(cast(e, String) + 20); // "print(e .. 20)"

		/*
			for (num in arr)
				print(num * 2);
		 */

		var myMap:Map<String, Float> = new Map();
		myMap.set("key", 69.420);
		print(myMap.get("key"));
		myMap.set("name", 70.420);
		print(myMap["name"]);
		myMap.remove("key");
		print(myMap.get("key"));

		var n = 10;
		while (n > 2)
		{
			n -= 1;
			if (n == 5)
				continue;
		}

		while (n > 2)
		{
			n -= 1;
			if (n == 5)
			{
				if (n > 4)
				{
					n -= 3;
					continue;
				}
			}
		}

		while (n > 2)
		{
			n -= 1;
			if (n > 1)
				break;
		}

		while (n > 2)
		{
			n -= 1;
			if (n == 5)
				break;
			else if (n == 8)
				continue;
		}

		{
			print(1);
			{
				print(2);
				{
					print(3);
				}
			}
		}

		var absNum:MyAbstractNumber = 124;
		print(absNum.isEven());
		var gcdResult = absNum.gcd(56);
		print(gcdResult);

		var num:Int = absNum;
		print(num);

		var newAbsNumber:MyAbstractNumber = MyAbstractNumber.randomBetween(10, 50);
		var res:Int = newAbsNumber.sumDigits();
		print(newAbsNumber + res);

		var ent:CoolEntity = new CoolEntity(3);
		ent.special();
		ent.attack(ent);
	}

	public function increment(i:Int)
	{
		print(i);
		switch (field)
		{
			case One:
				field = Two;
			case Two:
				field = Three;
			case _:
		}
		print(field);
		untyped __lua__("local testStr = 'aaaa'\nprint(testStr, {0})", field);
	}

	public static function getNumber():Int
	{
		try
		{
			untyped getValue();
		}
		catch (e:Dynamic)
		{
			trace("Error:", e);
		}

		try
		{
			var num:Int = untyped getValue();
			return num;
		}
		catch (e:Dynamic)
		{
			trace("Error:", e);
		}
		return 3;
	}
}

function main()
{
	print("Hello world!");

	final c = new TestClass("Yay!");
	for (i in 0...TestClass.getNumber())
	{
		c.increment(i);
		if (i == 2)
			print("Two!");
	}
	trace(c.increment);

	var myStruct:{one:Int, two:Int, three:String} = {
		one: ~Std.random(5),
		two: (0 + 4 - 3) * 2,
		three: "3",
	}

	myStruct.three = "4";
	print(myStruct);

	var some = new SomeClass(1, "Hi");
	print(some.did);
	some.one(5.5);
	print(some.did);
	some.three();

	var myEnumVal:AdvancedEnum = YetAnotherConstr(5.5);

	var myValue = switch (myEnumVal)
	{
		case Normal:
			'Normal';
		case Constructor2Args(text, moreText):
			'Constructor2Args($text, $moreText)';
		case AnotherConstr(fav):
			'AnotherConstr($fav)';
		case YetAnotherConstr(bananas, yes):
			'YetAnotherConstr($bananas, ?$yes)';
		default:
			print('Item $myEnumVal not recognized...');
			'???';
	}
	print(myValue);

	var res = Os.remove("important");
	if (res.result == null)
		print(res.error);

	function doSum(r:Dynamic)
	{
		print(r);
	}
	doSum(Os.remove("folder2"));

	function task(...args:Dynamic)
	{
		Coroutine.yield(args[0] ?? "first");
		return "second";
	}

	var taskCoro = Coroutine.create(task);
	var resumeResult = Coroutine.resume(taskCoro, 1, "Yay");
	print(resumeResult.success);
	print(resumeResult.result);
	resumeResult = Coroutine.resume(taskCoro);
	print(resumeResult.success);
	print(resumeResult.result);
}

class SomeClass extends OtherClass
{
	public function new(a1:Int, a2:String)
	{
		super(a1 * 2, a2);
	}

	static var n:Float = 0.3;
	static var myNumber(get, set):Int;

	override public function one(a:Float)
	{
		print("BEFORE");
		super.one(a * myNumber);
		two(true);
	}

	override public function three()
	{
		trace("THREE WAS NOT CALLED");
		myNumber = 4;
	}

	static function set_myNumber(value:Int):Int
		return untyped n += value;

	static function get_myNumber():Int
		return untyped math.floor(n);
}

class OtherClass
{
	static var e:Int = -10;

	public var did:Bool = false;

	public var didWeDoIt(get, never):Bool;

	public static function test()
	{
		print(e);
	}

	public function new(a1:Int, a2:String)
	{
		print(a1);
		print(a2);
	}

	public function one(a:Float)
	{
		print("Hello!");
		print(a);
	}

	public function two(b:Bool)
	{
		static var counter = 0;
		did = b;
		print(didWeDoIt);
		counter++;
		e += counter;
	}

	public function three()
	{
		trace("I WAS CALLED!");
		print(_G);
	}

	public function get_didWeDoIt():Bool
		return did;
}
