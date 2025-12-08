package rluacompiler.resources;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;

@:keepSub
interface IPkgWrapper
{
	public var requireCode:(moduleId:String) -> String;
	public var registerCode:(moduleId:String, decls:Array<BaseType>) -> String;
	public var importCode:(moduleId:String) -> String;
	public var filePath:String;
	public var wrapperCode:String;
}
#end
