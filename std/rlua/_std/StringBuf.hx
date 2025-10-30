class StringBuf
{
	var b:String;

	public var length(get, never):Int;

	inline function get_length():Int
		return b.length;

	public inline function new()
		b = "";

	public inline function add<T>(x:T):Void
		b += x;

	public inline function addChar(c:Int):Void
		b += String.fromCharCode(c);

	public inline function addSub(s:String, pos:Int, ?len:Int):Void
		b += (len == null ? s.substr(pos) : s.substr(pos, len));

	public inline function toString():String
		return b;
}
