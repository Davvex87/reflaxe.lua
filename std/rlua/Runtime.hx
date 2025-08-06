package rlua;

class Runtime
{
	@:noCompletion
	public static function buildMultiReturn(n:Array<String>, ...v:Dynamic):Dynamic
	{
		var t = {};
		for (i in 0...n.length)
			untyped t[n[i]] = v[i];
		return t;
	}
}