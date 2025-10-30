package rlua;

class ArrayTools
{
	public static function concat<T>(a1:Array<T>, a2:Array<T>):Array<T>
	{
		var result = new Array<T>();
		untyped __lua__("
	for i = 1, #{0} do
		{1}[i] = {0}[i]
	end
	for i = 1, #{2} do
		{1}[#{0} + i] = {2}[i]
	end", a1, result, a2);
		return result;
	}

	public static function reverse<T>(a:Array<T>):Void
		untyped __lua__("
	local i, j = 1, #{0}
	while i < j do
		{0}[i], {0}[j] = {0}[j], {0}[i]
		i = i + 1
		j = j - 1
	end", a);

	public static function slice<T>(arr:Array<T>, pos:Int, ?endi:Int):Array<T>
	{
		untyped __lua__("
	local result = {}
	if {1} == nil then {1} = 1
	elseif {1} < 0 then {1} = #{0} + {1} + 1
	else {1} = {1} + 1 end
	if {1} < 1 then {1} = 1 end
	if {1} > #{0} then return {} end

	if {2} == nil or {2} > #{0} then {2} = #{0}
	elseif {2} < 0 then {2} = #{0} + {2} end
	if {2} < {1} then return {} end

	for i = {1}, {2} do table.insert(result, {0}[i]) end", arr, pos, endi);
		return untyped result;
	}

	public static function splice<T>(arr:Array<T>, pos:Int, len:Int):Array<T>
	{
		var ret = new Array<T>();
		untyped __lua__("
	local length = #{0}
	if {2} < 0 or {1} > length then return {}
	elseif {1} < 0 then {1} = length - (-{1} % length)
	end
	{2} = math.min({2}, length - {1})
	for i = {1}, {1} + {2} - 1 do
		table.insert(ret, {0}[i + 1])
		{0}[i + 1] = {0}[i + {2} + 1]
	end
	for i = {1} + {2}, length - 1 do {0}[i + 1] = {0}[i + {2} + 1] end
	for i = length, length - {2} + 1, -1 do {0}[i] = nil end", arr, pos, len);
		return ret;
	}

	public static function find<T>(arr:Array<T>, x:T, ?s:Int):Null<Int>
	{
		untyped __lua__("
	for i = {2}, #{0} do
		if {0}[i] == {1} then
			return i
		end
	end
	", arr, x, s ?? 1);
		return null;
	}

	public static function rfind<T>(arr:Array<T>, x:T, ?s:Int):Null<Int>
	{
		untyped __lua__("
	for i = #{0} - {2}, 1, -1 do
		if {0}[i] == {1} then
			return i
		end
	end", arr, x, s ?? 1);
		return null;
	}

	public static function safeRemove<T>(arr:Array<T>, x:T):Bool
	{
		var find = find(arr, x);
		if (find == null)
			return false;
		untyped table.remove(arr, find);
		return true;
	}

	public static function copy<T>(arr:Array<T>):Array<T>
	{
		var res = new Array<T>();
		untyped __lua__("
	for i = 1, #{0} do
		res[i] = {0}[i]
	end", arr);
		return res;
	}

	public static function resize<T>(arr:Array<T>, len:Int):Void
		untyped __lua__("
	if {1} < #{0} then
		for i = #{0}, {1} + 1, -1 do
			{0}[i] = nil
		end
	else
		for i = #{0} + 1, {1} do
			{0}[i] = nil
		end
	end", arr, len);

	public static function filter<T>(arr:Array<T>, f:T->Bool):Array<T>
		return [for (v in arr) if (f(v)) v];

	public static function map<T, S>(arr:Array<T>, f:T->S):Array<S>
		return [for (v in arr) f(v)];
}
