package rluacompiler;

#if (macro || rlua_runtime)
import haxe.io.Path;
import sys.FileSystem;
import haxe.Template;
import sys.io.File;
import haxe.Json;

class RuntimeConfig
{
	public static function fromFile(configJsonFile:String):RuntimeConfig
	{
		var content:JsonConfig = Json.parse(File.getContent(configJsonFile));
		return new RuntimeConfig(content.requireStr, content.registerStr, content.importStr, content.runtimePath, Path.directory(configJsonFile));
	}

	public function new(requireStr:String, registerStr:String, importStr:String, runtimePath:String, ?cwd:String)
	{
		this.requireStr = requireStr;
		this.registerStr = registerStr;
		this.importStr = importStr;
		this.runtimePath = runtimePath;
		this.cwd = cwd ?? Sys.getCwd();
	}

	public function resolveRequire():String
	{
		var template = new Template(requireStr);
		return template.execute({}, this);
	}

	public function resolveRegister(moduleId:String, types:Array<String>):String
	{
		var template = new Template(registerStr);
		return template.execute({moduleid: moduleId, types: types}, this);
	}

	public function resolveImport(types:Array<String>, moduleId:String):String
	{
		var template = new Template(importStr);
		return template.execute({types: types, moduleid: moduleId}, this);
	}

	public function getRuntimePath():String
	{
		var template = new Template(runtimePath);
		var result = template.execute({}, this);
		return FileSystem.absolutePath(Path.normalize(Path.join([cwd, result])));
	}

	var requireStr:String;
	var registerStr:String;
	var importStr:String;
	var runtimePath:String;
	var cwd:String;

	@:keep function join(resolve:String->Dynamic, arr:Array<Dynamic>):String
	{
		return arr.join(", ");
	}
}

typedef JsonConfig =
{
	requireStr:String,
	registerStr:String,
	importStr:String,
	runtimePath:String
}
#end
