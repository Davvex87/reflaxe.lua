package pkg;

@:customImport("game.CustomExternClass")
extern class CustomExternClass
{
	public function new();
	public static function staticMethod(arg:String):Int;
	public function instanceMethod(num:Int):String;
}

@:keep
class Test {}
