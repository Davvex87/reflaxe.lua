package rlua;

@:native("HxRuntime")
extern class Runtime
{
	@:native("classes")
	static var classes:Map<String, Dynamic>;

	// TODO: implement the lua-safe compiler def stuff here
	@:native("IsTable")
	static function isTable(o:Dynamic):Bool;

	@:native("IsMetatable")
	static function isMetatable(o:Dynamic):Bool;

	@:native("IsArray")
	static function isArray(o:Dynamic):Bool;

	@:native("IsObject")
	static function isObject(o:Dynamic):Bool;

	@:native("IsClass")
	static function isClass(o:Dynamic):Bool;

	@:native("IsInstance")
	static function isInstance(o:Dynamic):Bool;

	@:native("IsInterface")
	static function isInterface(o:Dynamic):Bool;

	@:native("IsEnum")
	static function isEnum(o:Dynamic):Bool;

	@:native("IsEnumIndex")
	static function isEnumIndex(o:Dynamic):Bool;

	@:noCompletion
	@:native("BuildMultiReturn")
	static function buildMultiReturn(n:Array<String>, ...v:Dynamic):Dynamic;
}
