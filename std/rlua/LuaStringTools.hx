package rlua;

class LuaStringTools
{
	public static function indexOf(base:String, str:String, ?startIndex:Int):Int
	{
		if (startIndex == null)
			startIndex = 1;
		else
			startIndex += 1;
		if (str == "")
		{
			return indexOfEmpty(base, startIndex - 1);
		}
		var r = untyped __lua__("string.find({0}, {1}, ({2} or 0), true)", base, str, startIndex);
		if (r != null && r > 0)
			return r - 1;
		else
			return -1;
	}

	public static function lastIndexOf(base:String, str:String, ?startIndex:Int):Int
	{
		var ret = -1;
		if (startIndex == null)
			startIndex = base.length;
		while (true)
		{
			var p = indexOf(base, str, ret + 1);
			if (p == -1 || p > startIndex || p == ret)
				break;
			ret = p;
		}
		return ret;
	}

	static function indexOfEmpty(s:String, startIndex:Int):Int
	{
		var length = s.length;
		if (startIndex < 0)
		{
			startIndex = length + startIndex;
			if (startIndex < 0)
				startIndex = 0;
		}
		return startIndex > length ? length : startIndex;
	}

	public static function substr(s:String, pos:Int, ?len:Int):String
	{
		if (len == null || len > pos + s.length)
			len = s.length;
		else if (len < 0)
			len = s.length + len;
		if (pos < 0)
			pos = s.length + pos;
		if (pos < 0)
			pos = 0;
		return untyped __lua__("string.sub({0}, {1} + 1, {1} + ({2} or (#{0} - {1} + 1)))", s, pos, len);
		// return BaseString.sub(this, pos + 1, pos + len).match;
	}

	public static function substring(s:String, startIndex:Int, ?endIndex:Int):String
	{
		if (endIndex == null)
			endIndex = s.length;
		if (endIndex < 0)
			endIndex = 0;
		if (startIndex < 0)
			startIndex = 0;
		if (endIndex < startIndex)
		{
			// swap the index positions
			// return BaseString.sub(this, endIndex + 1, startIndex).match;
			return untyped __lua__("string.sub({0}, {1}, {2})", s, endIndex + 1, startIndex);
		}
		else
		{
			// return BaseString.sub(this, startIndex + 1, endIndex).match;
			return untyped __lua__("string.sub({0}, {1}, {2})", s, startIndex + 1, endIndex);
		}
	}

	#if !roblox
	static inline function escape_pattern(s)
		return untyped __lua__('{0}:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")', s);

	public static function split(str:String, delim:String):Array<String>
	{
		untyped __lua__('
   local t = {}

   -- default: split on whitespace
   if delim == nil then
      for s in str:gmatch("%S+") do
         t[#t + 1] = s
      end
      return t
   end

   -- empty separator = split into characters
   if delim == "" then
      for i = 1, #str do
         t[#t + 1] = str:sub(i, i)
      end
      return t
   end

   -- escape separator so it behaves literally
   delim = {2}(delim)

   local pattern = "([^" .. delim .. "]+)"
   for s in str:gmatch(pattern) do
      t[#t + 1] = s
   end', str, delim, escape_pattern);
		return untyped t;
	}
	#else
	@:nativeFunctionCode("string.split({arg0}, {arg1})")
	public static extern function split(str:String, delim:String):Array<String>;
	#end

	public static function codes(s:String):String->Int->StringCodePoint
	{
		var i = 1;
		var len = s.length;

		return cast function()
		{
			if (i > len)
				return null;

			var c = byte(s, i);
			var codepoint, n;

			if (c < 0x80)
			{
				codepoint = c;
				n = 1;
			}
			else if (c < 0xE0)
			{
				codepoint = ((c % 0x20) << 6) | (byte(s, i + 1) % 0x40);
				n = 2;
			}
			else if (c < 0xF0)
			{
				var c2 = byte(s, i + 1);
				var c3 = byte(s, i + 2);
				codepoint = ((c % 0x10) << 12) | ((c2 % 0x40) << 6) | (c3 % 0x40);
				n = 3;
			}
			else
			{
				var c2 = byte(s, i + 1);
				var c3 = byte(s, i + 2);
				var c4 = byte(s, i + 3);
				codepoint = ((c % 0x08) << 18) | ((c2 % 0x40) << 12) | ((c3 % 0x40) << 6) | (c4 % 0x40);
				n = 4;
			}

			untyped __lua__('local pos = i');
			i += n;
			return untyped __lua__("pos, codepoint");
		}
	}

	public static inline function byte(str:String, ?index:Int):Int
		return untyped string.byte(str, index);
}

@:multiReturn extern class StringCodePoint
{
	var position:Int;
	var codepoint:Int;
}
