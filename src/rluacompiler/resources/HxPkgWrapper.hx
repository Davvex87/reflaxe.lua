package rluacompiler.resources;

final hxPkgWrapperPath:String = "HxPkgWrapper.lua";
final hxPkgWrapperRequire:String = "local importPkg, registerPkg, _ = unpack(require(\"HxPkgWrapper\"));";
final hxPkgWrapperContent:String = "
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
