package rluacompiler.resources;

final hxPkgWrapperRequire:String = "local importPkg, _ = require(\"hxPkgWrapper\");";
final hxPkgWrapperContent:String = "
local hxPkgWrapper = {}
hxPkgWrapper.modules = {}

function hxPkgWrapper.importPkg(pkgName)
	local mod = hxPkgWrapper.modules[pkgName]
	if not mod then
		mod = table.pack(require(pkgName))
		hxPkgWrapper.modules[pkgName] = mod
	end
	return unpack(mod)
end

return hxPkgWrapper.importPkg, hxPkgWrapper
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
