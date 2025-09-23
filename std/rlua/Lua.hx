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

package rlua;

import haxe.extern.Rest;
import haxe.Constraints.Function;
import haxe.extern.Rest;

/**
	Throws an error if the provided value resolves to false or nil.
**/
@:native("assert")
extern function assert<T>(v:T, ?message:String):T;

/**
	Halts thread execution and throws an error.
**/
@:native("error")
extern function error(message:String, ?level:Int):Void;

/**
	Returns the total memory heap size in kilobytes.
**/
@:native("gcinfo")
extern function gcinfo():Int;

/**
	Returns the metatable of the given table.
**/
@:native("getmetatable")
extern function getmetatable(tbl:Map<Dynamic, Dynamic>):Map<Dynamic, Dynamic>;

/**
	Returns the provided code as a function that can be executed.
**/
@:native("loadstring")
extern function loadstring(contents:String, chunkname:String):Dynamic;

/**
	Creates a blank userdata, with the option for it to have a metatable.
**/
@:native("newproxy")
extern function newproxy(addMetatable:Bool):UserData;

/**
	An iterator function for use in for loops.
**/
@:native("next")
extern function next<K, V>(k:Map<K, V>, ?i:K):NextResult<K, V>;

/**
	Returns an iterator function and the provided table for use in a for loop.
**/
@:native("pairs")
extern function pairs<K, V>(t:Map<K, V>):PairsResult<K, V>;

/**
	Returns an iterator function and the provided table for use in a for loop.
**/
@:native("ipairs")
extern function ipairs<K, V>(t:Map<K, V>):IPairsResult<K, V>;

/**
	Runs the provided function and catches any error it throws, returning the function's success and its results.
**/
@:native("pcall")
extern function pcall(f:Function, rest:Rest<Dynamic>):PCallResult;

/**
	Prints all provided values to the output.
**/
@:native("print")
extern function print(v:haxe.extern.Rest<Dynamic>):Void;

/**
	Returns whether v1 is equal to v2, bypassing their metamethods.
**/
@:native("rawequal")
extern function rawequal(v1:Dynamic, v2:Dynamic):Bool;

/**
	Gets the real value of table[index], bypassing any metamethods.
**/
@:native("rawget")
extern function rawget<K, V>(t:Map<K, V>, k:K):V;

/**
	Returns the length of the string or table, bypassing any metamethods.
**/
@:native("rawlen")
extern function rawlen(t:Map<Dynamic, Dynamic>):Int;

/**
	Sets the real value of table[index], bypassing any metamethods.
**/
@:native("rawset")
extern function rawset<K, V>(t:Map<K, V>, k:K, v:V):Void;

/**
	Returns the value that was returned by the given ModuleScript, running it if it has not been run yet.
**/
@:native("require")
extern function require(module:String):Dynamic;

/**
	Returns all arguments after the given index.
**/
@:native("select")
extern function select(n:Dynamic, rest:Rest<Dynamic>):Dynamic;

/**
	Sets the given table's metatable.
**/
@:native("setmetatable")
extern function setmetatable(tbl:Map<Dynamic, Dynamic>, mtbl:Map<Dynamic, Dynamic>):Map<Dynamic, Dynamic>;

/**
	Returns the provided value converted to a number, or nil if impossible.
**/
@:native("tonumber")
extern function tonumber(str:String, ?base:Int):Int;

/**
	Returns the provided value converted to a string, or nil if impossible.
**/
@:native("tostring")
extern function tostring(v:Dynamic):String;

/**
	Returns the basic type of the provided object.
**/
@:native("type")
extern function type(v:Dynamic):String;

/**
	Returns all elements from the given list as a tuple.
**/
@:native("unpack")
extern function unpack(list:Map<Dynamic, Dynamic>, i:Int, j:Int):Dynamic;

/**
	Similar to pcall() except it uses a custom error handler.
**/
@:native("xpcall")
extern function xpcall(f:Function, msgh:Function, rest:Rest<Dynamic>):PCallResult;

/**
	A table that is shared between all scripts of the same context level.
**/
@:native("_G")
extern var _G:Map<Dynamic, Dynamic>;

/**
	A global variable that holds a string containing the current interpreter version.
**/
@:native("_VERSION")
extern var _VERSION:String;

@:multiReturn
extern class IPairsResult<K, V>
{
	var next:Map<K, V>->Int->NextResult<Int, V>;
	var table:Map<K, V>;
	var index:Int;
}

@:multiReturn
extern class PairsResult<K, V>
{
	var next:Map<K, V>->K->NextResult<K, V>;
	var table:Map<K, V>;
	var index:K;
}

@:multiReturn
extern class NextResult<K, V>
{
	var index:K;
	var value:V;
}

@:multiReturn
extern class PCallResult
{
	var success:Bool;
	var value:Dynamic;
}
