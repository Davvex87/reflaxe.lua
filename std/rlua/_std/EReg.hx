/*
 * Copyright (C)2005-2019 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/**
	The EReg class represents regular expressions.

	While basic usage and patterns consistently work across platforms, some more
	complex operations may yield different results. This is a necessary trade-
	off to retain a certain level of performance.

	EReg instances can be created by calling the constructor, or with the
	special syntax `~/pattern/modifier`

	EReg instances maintain an internal state, which is affected by several of
	its methods.

	A detailed explanation of the supported operations is available at
	<https://haxe.org/manual/std-regex.html>

	Note: This implementation uses Lua 5.1 patterns which are simpler than
	full PCRE regular expressions. Some complex patterns may not work identically.
**/
class EReg
{
	var pattern:String;
	var options:String;
	var global:Bool;
	var s:String; // the last matched string
	var matchStart:Int; // 0-based start position of last match
	var matchEnd:Int; // 0-based end position of last match (exclusive)
	var captures:Array<String>; // captured groups (index 0 = whole match)

	/**
		Creates a new regular expression with pattern `r` and modifiers `opt`.

		This is equivalent to the shorthand syntax `~/r/opt`

		If `r` or `opt` are null, the result is unspecified.
	**/
	public function new(r:String, opt:String)
	{
		pattern = r;
		options = opt != null ? opt : "";
		global = options.indexOf("g") != -1;
		s = null;
		matchStart = -1;
		matchEnd = -1;
		captures = [];
	}

	/**
		Tells if `this` regular expression matches String `s`.

		This method modifies the internal state.

		If `s` is `null`, the result is unspecified.
	**/
	public function match(s:String):Bool
	{
		if (s == null)
			return false;
		this.s = s;
		return doMatch(s, 0);
	}

	function doMatch(str:String, startPos:Int):Bool
	{
		// Lua's string.find returns 1-based indices
		// We wrap the pattern in () to capture the whole match if there are no captures
		var luaPattern = pattern;
		var hasCaptures = pattern.indexOf("(") != -1;

		// Handle case-insensitive matching by converting to lowercase if 'i' option
		var searchStr = str;
		var searchPattern = luaPattern;

		if (options.indexOf("i") != -1)
		{
			searchStr = untyped __lua__("string.lower({0})", str);
			searchPattern = untyped __lua__("string.lower({0})", luaPattern);
		}

		// Lua uses 1-based indexing, add 1 to startPos
		var luaStart = startPos + 1;

		if (hasCaptures)
		{
			// Pattern has captures, use string.find to get positions, then string.match for captures
			var result:Dynamic = untyped __lua__("{ string.find({0}, {1}, {2}) }", searchStr, searchPattern, luaStart);

			if (result == null || untyped __lua__("{0}[1]", result) == null)
			{
				matchStart = -1;
				matchEnd = -1;
				captures = [];
				return false;
			}

			// Convert 1-based to 0-based
			matchStart = untyped __lua__("{0}[1] - 1", result);
			matchEnd = untyped __lua__("{0}[2]", result); // end is inclusive in Lua, we want exclusive

			// Extract captures (indices 3+ in the result)
			captures = [];
			// First capture is the whole match
			captures.push(str.substr(matchStart, matchEnd - matchStart));

			var i = 3;
			while (true)
			{
				var cap:Dynamic = untyped __lua__("{0}[{1}]", result, i);
				if (cap == null)
					break;
				captures.push(cap);
				i++;
			}
		}
		else
		{
			// No captures in pattern, wrap entire pattern to capture whole match
			var result:Dynamic = untyped __lua__("{ string.find({0}, {1}, {2}) }", searchStr, searchPattern, luaStart);

			if (result == null || untyped __lua__("{0}[1]", result) == null)
			{
				matchStart = -1;
				matchEnd = -1;
				captures = [];
				return false;
			}

			// Convert 1-based to 0-based
			matchStart = untyped __lua__("{0}[1] - 1", result);
			matchEnd = untyped __lua__("{0}[2]", result);

			captures = [];
			captures.push(str.substr(matchStart, matchEnd - matchStart));
		}

		return true;
	}

	/**
		Returns the matched sub-group `n` of `this` EReg.

		This method should only be called after `this.match` or
		`this.matchSub`, and then operates on the String of that operation.

		The index `n` corresponds to the n-th set of parentheses in the pattern
		of `this` EReg. If no such sub-group exists, the result is unspecified.

		If `n` equals 0, the whole matched substring is returned.
	**/
	public function matched(n:Int):String
	{
		if (n < 0 || n >= captures.length)
			return null;
		return captures[n];
	}

	/**
		Returns the part to the left of the last matched substring.

		If the most recent call to `this.match` or `this.matchSub` did not
		match anything, the result is unspecified.

		If the global g modifier was in place for the matching, only the
		substring to the left of the leftmost match is returned.

		The result does not include the matched part.
	**/
	public function matchedLeft():String
	{
		if (s == null || matchStart < 0)
			return null;
		return s.substr(0, matchStart);
	}

	/**
		Returns the part to the right of the last matched substring.

		If the most recent call to `this.match` or `this.matchSub` did not
		match anything, the result is unspecified.

		If the global g modifier was in place for the matching, only the
		substring to the right of the leftmost match is returned.

		The result does not include the matched part.
	**/
	public function matchedRight():String
	{
		if (s == null || matchEnd < 0)
			return null;
		return s.substr(matchEnd);
	}

	/**
		Returns the position and length of the last matched substring, within
		the String which was last used as argument to `this.match` or
		`this.matchSub`.

		If the most recent call to `this.match` or `this.matchSub` did not
		match anything, the result is unspecified.

		If the global g modifier was in place for the matching, the position and
		length of the leftmost substring is returned.
	**/
	public function matchedPos():{pos:Int, len:Int}
	{
		if (matchStart < 0)
			return null;
		return {pos: matchStart, len: matchEnd - matchStart};
	}

	/**
		Tells if `this` regular expression matches a substring of String `s`.

		This function expects `pos` and `len` to describe a valid substring of
		`s`, or else the result is unspecified. To get more robust behavior,
		`this.match(s.substr(pos,len))` can be used instead.

		This method modifies the internal state.

		If `s` is null, the result is unspecified.
	**/
	public function matchSub(s:String, pos:Int, len:Int = -1):Bool
	{
		if (s == null)
			return false;

		this.s = s;

		var subStr:String;
		if (len < 0)
		{
			subStr = s.substr(pos);
		}
		else
		{
			subStr = s.substr(pos, len);
		}

		var result = doMatch(subStr, 0);

		if (result)
		{
			// Adjust positions to be relative to original string
			matchStart += pos;
			matchEnd += pos;
		}

		return result;
	}

	/**
		Splits String `s` at all substrings `this` EReg matches.

		If a match is found at the start of `s`, the result contains a leading
		empty String "" entry.

		If a match is found at the end of `s`, the result contains a trailing
		empty String "" entry.

		If two matching substrings appear next to each other, the result
		contains the empty String `""` between them.

		By default, this method splits `s` into two parts at the first matched
		substring. If the global g modifier is in place, `s` is split at each
		matched substring.

		If `s` is null, the result is unspecified.
	**/
	public function split(s:String):Array<String>
	{
		if (s == null)
			return null;

		var result:Array<String> = [];
		var pos = 0;
		var str = s;

		this.s = s;

		while (pos <= str.length)
		{
			if (!doMatch(str, pos))
			{
				// No more matches, add rest of string
				result.push(str.substr(pos));
				break;
			}

			// Add part before match
			result.push(str.substr(pos, matchStart - pos));
			pos = matchEnd;

			// Handle zero-length matches to prevent infinite loop
			if (matchStart == matchEnd)
			{
				if (pos < str.length)
				{
					result.push(str.substr(pos, 1));
					pos++;
				}
				else
				{
					result.push("");
					break;
				}
			}

			if (!global)
			{
				// Not global, add rest and stop
				result.push(str.substr(pos));
				break;
			}
		}

		return result;
	}

	/**
		Replaces the first substring of `s` which `this` EReg matches with `by`.

		If `this` EReg does not match any substring, the result is `s`.

		By default, this method replaces only the first matched substring. If
		the global g modifier is in place, all matched substrings are replaced.

		If `by` contains `$1` to `$9`, the digit corresponds to number of a
		matched sub-group and its value is used instead. If no such sub-group
		exists, the replacement is unspecified. The string `$$` becomes `$`.

		If `s` or `by` are null, the result is unspecified.
	**/
	public function replace(s:String, by:String):String
	{
		if (s == null || by == null)
			return null;

		this.s = s;
		var result = new StringBuf();
		var pos = 0;

		while (pos <= s.length)
		{
			if (!doMatch(s, pos))
			{
				// No more matches
				result.add(s.substr(pos));
				break;
			}

			// Add part before match
			result.add(s.substr(pos, matchStart - pos));

			// Process replacement string
			result.add(processReplacement(by));

			pos = matchEnd;

			// Handle zero-length matches
			if (matchStart == matchEnd)
			{
				if (pos < s.length)
				{
					result.add(s.substr(pos, 1));
					pos++;
				}
				else
				{
					break;
				}
			}

			if (!global)
			{
				// Not global, add rest and stop
				result.add(s.substr(pos));
				break;
			}
		}

		return result.toString();
	}

	function processReplacement(by:String):String
	{
		var result = new StringBuf();
		var i = 0;

		while (i < by.length)
		{
			var c = by.charAt(i);
			if (c == "$" && i + 1 < by.length)
			{
				var next = by.charAt(i + 1);
				if (next == "$")
				{
					result.add("$");
					i += 2;
				}
				else if (next >= "0" && next <= "9")
				{
					var groupNum = Std.parseInt(next);
					if (groupNum != null && groupNum < captures.length)
					{
						var cap = captures[groupNum];
						if (cap != null)
							result.add(cap);
					}
					i += 2;
				}
				else
				{
					result.add(c);
					i++;
				}
			}
			else
			{
				result.add(c);
				i++;
			}
		}

		return result.toString();
	}

	/**
		Calls the function `f` for the substring of `s` which `this` EReg matches
		and replaces that substring with the result of `f` call.

		The `f` function takes `this` EReg object as its first argument and should
		return a replacement string for the substring matched.

		If `this` EReg does not match any substring, the result is `s`.

		By default, this method replaces only the first matched substring. If
		the global g modifier is in place, all matched substrings are replaced.

		If `s` or `f` are null, the result is unspecified.
	**/
	public function map(s:String, f:EReg->String):String
	{
		if (s == null || f == null)
			return null;

		this.s = s;
		var result = new StringBuf();
		var pos = 0;

		while (pos <= s.length)
		{
			if (!doMatch(s, pos))
			{
				// No more matches
				result.add(s.substr(pos));
				break;
			}

			// Add part before match
			result.add(s.substr(pos, matchStart - pos));

			// Call function with this EReg and add result
			result.add(f(this));

			pos = matchEnd;

			// Handle zero-length matches
			if (matchStart == matchEnd)
			{
				if (pos < s.length)
				{
					result.add(s.substr(pos, 1));
					pos++;
				}
				else
				{
					break;
				}
			}

			if (!global)
			{
				// Not global, add rest and stop
				result.add(s.substr(pos));
				break;
			}
		}

		return result.toString();
	}

	/**
		Escape the string `s` for use as a part of regular expression.

		If `s` is null, the result is unspecified.
	**/
	public static function escape(s:String):String
	{
		if (s == null)
			return null;

		// Lua pattern magic characters: ^$()%.[]*+-?
		var result = new StringBuf();
		for (i in 0...s.length)
		{
			var c = s.charAt(i);
			if (c == "^" || c == "$" || c == "(" || c == ")" || c == "%" || c == "." || c == "[" || c == "]" || c == "*" || c == "+" || c == "-" || c == "?")
			{
				result.add("%");
			}
			result.add(c);
		}
		return result.toString();
	}
}
