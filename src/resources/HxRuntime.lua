local HxRuntime = {
	modules = {},
	loaded = {},
	classes = {}
}

local _modules = HxRuntime.modules
local _loaded = HxRuntime.loaded
local _classes = HxRuntime.classes

function HxRuntime.RegisterPackage(pkg, types)
	_modules[pkg] = types

	for _, t in pairs(types) do
		if t.__name__ then
			local p, m = pkg:match("^(.*)%.([^%.]+)$")
			if not p then
				p, m = "", pkg
			end
			if t.__name__ == m then
				_classes[pkg] = t
			else
				_classes[p .. "." .. "_" .. m .. "." .. t.__name__] = t
			end
		end
	end
end

function HxRuntime.ImportPackage(pkgName)
	if _loaded[pkgName] == nil then
		_loaded[pkgName] = true
		require(pkgName)
	end
	return _modules[pkgName]
end

return {HxRuntime.ImportPackage, HxRuntime.RegisterPackage, HxRuntime}
