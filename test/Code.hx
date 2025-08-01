package;

enum TestEnum {
	One;
	Two;
	Three;
}

class TestClass {
	var field: TestEnum;

	public function new(arg1:String, arg2:TestEnum = One, ...rest) {
		trace("Create Code class! " + arg1);
		field = arg2 ?? Two;
		untyped print(rest);

		var arr = [1,2,5];
		untyped print(arr.join(", ")); 	// "1, 2, 5"
		untyped print(arr.length); 		// 3
		untyped print(arr[2]); 			// 5
		arr[3] = 10;

		var otherArray:Array<Int> = new Array<Int>();
		otherArray.push(8);
		otherArray.pop();

		untyped print(otherArray.concat(arr));

		var e:Dynamic = cast "TestStr";
		untyped print(e + 20); 					// "print(e + 20)"
		untyped print(cast(e, String) + 20); 	// "print(e .. 20)"

		for (num in arr)
			untyped print(num * 2);
	}

	public function increment(i:Int) {
		untyped print(i);
		switch(field) {
			case One: field = Two;
			case Two: field = Three;
			case _:
		}
		untyped print(field);
		untyped __lua__("local testStr = 'aaaa'\n\tprint(testStr, {0})", field);
	}

	public static function getNumber():Int
		return 3;
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
}

class SomeClass extends OtherClass
{
	public function new(a1:Int, a2:String) {super(a1 * 2, a2);}

	override public function one(a:Float)
	{
		untyped print("BEFORE");
		super.one(a * 5);
		two(true);
	}

	override public function three()
	{
		trace("THREE WAS NOT CALLED");
	}

}

class OtherClass
{
	static var e:Int = -10;
	public var did:Bool = false;

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
		untyped print(b);
		counter++;
		e += counter;
	}

	public function three()
	{
		trace("I WAS CALLED!");
	}
}