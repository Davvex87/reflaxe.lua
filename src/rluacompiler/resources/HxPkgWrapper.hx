package rluacompiler.resources;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;

@:keepSub
class HxPkgWrapper implements IPkgWrapper
{
	public function new() {}

	public var requireCode = (moduleId:String) -> 'local importPkg, registerPkg, _ = unpack(require(\"HxPkgWrapper\"));';

	public var registerCode = (moduleId:String, decls:Array<BaseType>) -> 'registerPkg("$moduleId", {${decls.map(t -> t.name).join(", ")}});';

	public var importCode = (moduleId:String) -> 'unpack(importPkg("$moduleId"))';

	public var filePath = "HxPkgWrapper.lua";

	public var wrapperCode = "
local hxPkgWrapper = {}
hxPkgWrapper.modules = {}
hxPkgWrapper.loaded = {}

function hxPkgWrapper.registerPkg(pkgName, types)
    hxPkgWrapper.modules[pkgName] = types
end

function hxPkgWrapper.importPkg(pkgName)
	if hxPkgWrapper.loaded[pkgName] == nil then
		hxPkgWrapper.loaded[pkgName] = true
		require(pkgName)
	end
	return hxPkgWrapper.modules[pkgName]
end

return {hxPkgWrapper.importPkg, hxPkgWrapper.registerPkg, hxPkgWrapper}
";
}
#end
// TODO: consider using a better system that implements placeholder metatables and stuff
/*
	local hxPkgWrapper = {}
	hxPkgWrapper.modules = {}

	local pack = table.pack
	local unpack = table.unpack or unpack

	function hxPkgWrapper.importPkg(pkgName)
	local cached = hxPkgWrapper.modules[pkgName]
	if cached then
		return unpack(cached)
	end

	local placeholder = {}
	hxPkgWrapper.modules[pkgName] = pack(placeholder)

	local res = pack(require(pkgName))

	local first = res[1]
	if type(first) == "table" and first ~= placeholder then
		for k, v in pairs(first) do
			placeholder[k] = v
		end
		hxPkgWrapper.modules[pkgName] = pack(placeholder)
	else
		hxPkgWrapper.modules[pkgName] = res
	end

	return unpack(hxPkgWrapper.modules[pkgName])
	end

	return hxPkgWrapper.importPkg, hxPkgWrapper
 */
