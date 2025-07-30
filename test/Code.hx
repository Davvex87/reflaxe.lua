// A bit of code to compile with your custom compiler.
//
// This code has no relevance beyond testing purposes.
// Please modify and add your own test code!

package;

import rlua.Syntax;

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
		Lua.print(rest);

		var arr = [1,2,5];
		Lua.print(arr.join(", "));
		Lua.print(arr.length);
		Lua.print(arr[2]);
		arr[3] = 10;

		var otherArray:Array<Int> = new Array<Int>();
		otherArray.push(8);
		otherArray.pop();

		Lua.print(otherArray.concat(arr));
	}

	public function increment(i:Int) {
		Lua.print(i);
		switch(field) {
			case One: field = Two;
			case Two: field = Three;
			case _:
		}
		//Lua.print(field);
		untyped __lua__("local testStr = 'aaaa'\n\tprint(testStr, {0})", field);
	}

	public static function getNumber():Int
		return 3;
}

function main() {
	Lua.print("Hello world!");

	final c = new TestClass("Yay!");
	for(i in 0...TestClass.getNumber()) {
		c.increment(i);
		if (i == 2)
			Lua.print("Two!");
	}
	trace(c.increment);

	var myStruct:{one:Int, two:Int, three:String} = {
		one: 1,
		two: (0+4-3)*2,
		three: "3",
	}

	myStruct.three = "4";
	Lua.print(myStruct);
}

@:native("")
class Lua
{
	@:native("print")
	extern public static function print(str:Dynamic):Void;
}