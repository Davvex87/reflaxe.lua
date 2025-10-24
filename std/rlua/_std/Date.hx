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

import rlua.Lua;
import rlua.Os;
import rlua.Boot;

@:coreApi class Date
{
	var d:DateResult;
	var dUTC:DateResult;
	var t:Float;

	public function new(year:Int, month:Int, day:Int, hour:Int, min:Int, sec:Int)
	{
		t = Os.time({
			year: year,
			month: month + 1,
			day: day,
			hour: hour,
			min: min,
			sec: sec
		});
		d = Os.date("*t", t);
		dUTC = Os.date("!*t", t);
	}

	public inline function getTime():Float
		return cast t * 1000;

	public inline function getHours():Int
		return d.hour;

	public inline function getMinutes():Int
		return d.min;

	public function getSeconds():Int
		return d.sec;

	public inline function getFullYear():Int
		return d.year;

	public inline function getMonth():Int
		return d.month - 1;

	public inline function getDate():Int
		return d.day;

	public inline function getDay():Int
		return d.wday - 1;

	public inline function getUTCHours():Int
		return dUTC.hour;

	public inline function getUTCMinutes():Int
		return dUTC.min;

	public inline function getUTCSeconds():Int
		return dUTC.sec;

	public inline function getUTCFullYear():Int
		return dUTC.year;

	public inline function getUTCMonth():Int
		return dUTC.month - 1;

	public inline function getUTCDate():Int
		return dUTC.day;

	public inline function getUTCDay():Int
		return dUTC.wday - 1;

	public inline function getTimezoneOffset():Int
	{
		var tUTC = Os.time(dUTC);
		return Std.int((tUTC - t) / 60);
	}

	public inline function toString():String
	{
		return Boot.dateStr(this);
	}

	public static inline function now():Date
	{
		return fromTime(Os.time() * 1000);
	}

	public static function fromTime(t:Float):Date
	{
		var d = Type.createEmptyInstance(Date);
		untyped d.t = t / 1000;
		untyped d.d = Os.date("*t", Std.int(d.t));
		untyped d.dUTC = Os.date("!*t", Std.int(d.t));
		return d;
	}

	public static inline function fromString(s:String):Date
	{
		return Boot.strDate(s);
	}
}
