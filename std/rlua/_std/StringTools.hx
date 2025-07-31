import haxe.iterators.StringIterator;
import haxe.iterators.StringKeyValueIterator;

class StringTools
{
	public static function urlEncode(s:String):String
	{
		s = untyped string.gsub(s, "\\n", "\\r\\n");
		s = untyped __lua__('string.gsub({0}, "([^%w %-%_%.%~])", {1})', s, function(c) {
			return untyped string.format("%%%02X", string.byte(c) + '');
		});
		s = untyped string.gsub(s, " ", "+");
		return s;
	}

	public static function urlDecode(s:String):String
	{
		s = untyped string.gsub(s, "+", " ");
		s = untyped __lua__('string.gsub({0}, "%%(%x%x)", {1})', s, function(h) {
			return untyped string.char(tonumber(h, 16));
		});
		s = untyped string.gsub(s, "\\r\\n", "\\n");
		return s;
	}

	// TODO: Also maybe check out the haxe.iterators package? plus gotta also do the other String classes like StringBuf
	public static function htmlEscape(s:String, ?quotes:Bool):String
	{
		var buf = new StringBuf();
		for (code in iterator(s))
		{
			switch (code)
			{
				case '&'.code:
					buf.add("&amp;");
				case '<'.code:
					buf.add("&lt;");
				case '>'.code:
					buf.add("&gt;");
				case '"'.code if (quotes):
					buf.add("&quot;");
				case '\''.code if (quotes):
					buf.add("&#039;");
				case _:
					buf.addChar(code);
			}
		}
		return buf.toString();
	}

	public static function htmlUnescape(s:String):String
		return s.split("&gt;")
			.join(">")
			.split("&lt;")
			.join("<")
			.split("&quot;")
			.join('"')
			.split("&#039;")
			.join("'")
			.split("&amp;")
			.join("&");

	public static inline function contains(s:String, value:String):Bool
		return s.indexOf(value) != -1;

	public static function startsWith(s:String, start:String):Bool
		return untyped __lua__("{0}:sub(1, #{1}) == {1}", s, start);

	public static function endsWith(s:String, ends:String):Bool
		return ends == "" || untyped __lua__("{0}:sub(-#{1}) == {1}", s, ends);

	public static function isSpace(s:String, pos:Int):Bool
	{
		if (s.length == 0 || pos < 0 || pos >= s.length)
			return false;
		var c = s.charCodeAt(pos);
		return (c > 8 && c < 14) || c == 32;
	}

	public static function ltrim(s:String):String
	{
		var l = s.length;
		var r = 0;
		while (r < l && isSpace(s, r))
			r++;
		if (r > 0)
			return s.substr(r, l - r);
		return s;
	}

	public static function rtrim(s:String):String
	{
		var l = s.length;
		var r = 0;
		while (r < l && isSpace(s, l - r - 1))
			r++;
		if (r > 0)
			return s.substr(0, l - r);
		return s;
	}

	public static inline function trim(s:String):String
		return ltrim(rtrim(s));

	public static function lpad(s:String, c:String, l:Int):String
	{
		if (c.length <= 0)
			return s;

		var buf = new StringBuf();
		l -= s.length;
		while (buf.length < l)
			buf.add(c);

		buf.add(s);
		return buf.toString();
	}

	public static function rpad(s:String, c:String, l:Int):String
	{
		if (c.length <= 0)
			return s;

		var buf = new StringBuf();
		buf.add(s);

		while (buf.length < l)
			buf.add(c);
		return buf.toString();
	}

	public static inline function replace(s:String, sub:String, by:String):String
		return untyped __lua__("{0}:gsub({1},{2})", s, sub, by);

	public static function hex(n:Int, ?digits:Int)
	{
		var s = "";
		var hexChars = "0123456789ABCDEF";
		do {
			s = hexChars.charAt(n & 15) + s;
			n >>>= 4;
		} while (n > 0);
		if (digits != null)
			while (s.length < digits)
				s = "0" + s;
		return s;
	}
	
	public static inline function fastCodeAt(s:String, index:Int):Int
		return s.charCodeAt(index);

	public static inline function unsafeCodeAt(s:String, index:Int):Int
		return s.charCodeAt(index);

	// TODO: Review this
	public static inline function iterator(s:String):StringIterator
		return new StringIterator(s);

	public static inline function keyValueIterator(s:String):StringKeyValueIterator
		return new StringKeyValueIterator(s);

	@:noUsing
	public static inline function isEof(c:Null<Int>):Bool
		return c == null;
}
