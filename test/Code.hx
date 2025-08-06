package;

enum TestEnum {
	One;
	Two;
	Three;
}

enum AdvancedEnum {
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
	var field: TestEnum;

	public function new(arg1:String, arg2:TestEnum = One, ...rest:Float) {
		trace("Create Code class! " + arg1);
		field = arg2 ?? Two;
		untyped print(rest);
		untyped print(rest.toArray);
		untyped print(rest.length);

		var arr = [1,2,5];
		untyped print(arr.join(", ")); 	// "1, 2, 5"
		untyped print(arr.length); 		// 3
		untyped print(arr[2]); 			// 5
		arr[3] = Math.round(Math.PI);

		for (num in arr)
		{
			untyped print(num);
		}

		var otherArray:Array<Int> = new Array<Int>();
		otherArray.push(8);
		otherArray.pop();

		untyped print(otherArray.concat(arr));

		var e:Dynamic = cast "TestStr";
		untyped print(e + 20); 					// "print(e + 20)"
		untyped print(cast(e, String) + 20); 	// "print(e .. 20)"

		/*
		for (num in arr)
			untyped print(num * 2);
		*/

		var n = 10;
		while (n > 2)
		{
			n-=1;
			if (n == 5)
				continue;
		}

		while (n > 2)
		{
			n-=1;
			if (n == 5)
			{
				if (n > 4)
				{	
					n-=3;
					continue;
				}
			}
		}

		while (n > 2)
		{
			n-=1;
			if (n > 1)
				break;
		}

		while (n > 2)
		{
			n-=1;
			if (n == 5)
				break;
			else if(n == 8)
				continue;
		}

		{
			untyped print(1);
			{
				untyped print(2);
				{
					untyped print(3);
				}
			}
		}
	}

	public function increment(i:Int) {
		untyped print(i);
		switch(field) {
			case One: field = Two;
			case Two: field = Three;
			case _:
		}
		untyped print(field);
		untyped __lua__("local testStr = 'aaaa'\nprint(testStr, {0})", field);
	}

	public static function getNumber():Int
	{
		try 
		{
			untyped getValue();
		}
		catch(e:Dynamic)
		{
			trace("Error:", e);
		}

		try 
		{
			var num:Int = untyped getValue();
			return num;
		}
		catch(e:Dynamic)
		{
			trace("Error:", e);
		}
		return 3;
	}
}

function main()
{
	untyped print("Hello world!");

	final c = new TestClass("Yay!");
	for(i in 0...TestClass.getNumber()) {
		c.increment(i);
		if (i == 2)
			untyped print("Two!");
	}
	trace(c.increment);

	var myStruct:{one:Int, two:Int, three:String} = {
		one: ~Std.random(5),
		two: (0+4-3)*2,
		three: "3",
	}

	myStruct.three = "4";
	untyped print(myStruct);

	var some = new SomeClass(1, "Hi");
	untyped print(some.did);
	some.one(5.5);
	untyped print(some.did);
	some.three();

	var myEnumVal:AdvancedEnum = YetAnotherConstr(5.5);

	var myValue = switch(myEnumVal)
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
			untyped print('Item $myEnumVal not recognized...');
			'???';
	}
	untyped print(myValue);

}

class SomeClass extends OtherClass
{
	public function new(a1:Int, a2:String) {super(a1 * 2, a2);}

	static var n:Float = 0.3;
	static var myNumber(get, set):Int;

	override public function one(a:Float)
	{
		untyped print("BEFORE");
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
		untyped print(e);
	}

	public function new(a1:Int, a2:String)
	{
		untyped print(a1);
		untyped print(a2);
	}

	public function one(a:Float)
	{
		untyped print("Hello!", a);
	}

	public function two(b:Bool)
	{
		static var counter = 0;
		did = b;
		untyped print(didWeDoIt);
		counter++;
		e += counter;
	}

	public function three()
	{
		trace("I WAS CALLED!");
	}

	public function get_didWeDoIt():Bool
		return did;
}