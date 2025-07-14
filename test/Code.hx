// A bit of code to compile with your custom compiler.
//
// This code has no relevance beyond testing purposes.
// Please modify and add your own test code!

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
		trace(rest);
	}

	public function increment(i:Int) {
		untyped print(i);
		switch(field) {
			case One: field = Two;
			case Two: field = Three;
			case _:
		}
		trace(field);
	}
}

function main() {
	trace("Hello world!");

	final c = new TestClass("Yay!");
	for(i in 0...untyped bruh()) {
		c.increment(i);
		if (i == 2)
			trace("Two!");
	}
	trace(c.increment);

	var myStruct:{one:Int, two:Int, three:String} = {
		one: 1,
		two: (0+4-3)*2,
		three: "3",
	}

	myStruct.three = "4";
	untyped doTheThing(myStruct);
}
