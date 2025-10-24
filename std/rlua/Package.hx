package rlua;

@:native("package")
extern class Package
{
	/**
	 * The path used by require to search for a C loader.
	 */
	static var cpath:String;

	/**
	 * A table used by require to control which modules are already loaded.
	 * When you require a module modname and package.loaded[modname] is not false,
	 * require simply returns the value stored there.
	 */
	static var loaded:Map<String, Dynamic>;

	/**
	 * A table used by require to control how to load modules.
	 */
	static var loaders:Array<Void->Null<String>>;

	/**
	 * Dynamically links the host program with the C library libname. Inside this library, looks for a function funcname and
	 * returns this function as a C function. (So, funcname must follow the protocol (see lua_CFunction)).
	 * 
	 * This is a low-level function. It completely bypasses the package and module system. Unlike require, it does not
	 * perform any path searching and does not automatically adds extensions. libname must be the complete file name of
	 * the C library, including if necessary a path and extension. funcname must be the exact name exported by the C library
	 * (which may depend on the C compiler and linker used).
	 * 
	 * This function is not supported by ANSI C. As such, it is only available on some platforms (Windows, Linux, Mac OS X,
	 * Solaris, BSD, plus other Unix systems that support the dlfcn standard).
	 */
	static function loadlib(libname:String, funcname:String):Dynamic;

	/**
	 * The path used by require to search for a Lua loader.
	 * 
	 * At start-up, Lua initializes this variable with the value of the environment variable LUA_PATH or with a default
	 * path defined in luaconf.h, if the environment variable is not defined. Any ";;" in the value of the environment
	 * variable is replaced by the default path.
	 */
	static var path:String;

	/**
	 * A table to store loaders for specific modules (see require).
	 */
	static var preload:Map<String, Dynamic>;

	/**
	 * Sets a metatable for module with its __index field referring to the global environment, so that this module inherits
	 * values from the global environment. To be used as an option to function module.
	 */
	static function seeall(module:Dynamic):Void;

	/**
	 * A string describing some compile-time configurations for packages.
	 */
	static var config:String;
}
