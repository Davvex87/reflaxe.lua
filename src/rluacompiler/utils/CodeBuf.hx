package rluacompiler.utils;

using StringTools;

@:forward
@:forward.new
@:forward.variance
abstract CodeBuf(CodeBufImpl)
{
	@:from public static function fromString(string:String):CodeBuf
		return new CodeBuf(string);

	@:to public function toString():String
		return @:privateAccess this._s;
	
	@:op(A + B) public function add<T>(x:T):CodeBuf @:privateAccess
	{
		this._s += Std.string(x).replace("\n", '\n${this.indent()}');
		return cast this;
	}
}

private class CodeBufImpl
{
	private var _s:String;
	private var _d:Int = 0;
	
	public var length(get, never):Int;
	public var depth(get, never):Int;
	public function get_length():Int
		return _s.length;
	public function get_depth():Int
		return _d;

	public var enter(get, never):String;
	public var leave(get, never):String;

	public function new(?s:String) this._s = s ?? "";

	public function get_enter():String
	{
		++_d;
		return "\n";
	}

	public function get_leave():String
	{
		--_d;
		return "\n";
	}

	public function indent():String
		return [for (_ in 0..._d) "\t"].join("");

	public function toString():String
		return Std.string(_s);
}