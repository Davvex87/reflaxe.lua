package rluacompiler.resources;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;

@:keepSub
class RblxPkgWrapper implements IPkgWrapper
{
	public function new() {}

	public var requireCode = (moduleId:String) ->
		'local importPkg, registerPkg = unpack(require(game:GetService(\"ReplicatedStorage\"):WaitForChild(\"HxPkgWrapper\")));';

	public var registerCode = (moduleId:String, decls:Array<BaseType>) -> 'registerPkg("$moduleId", {${decls.map(t -> t.name).join(", ")}});';

	public var importCode = (moduleId:String) -> 'unpack(importPkg("$moduleId"))';

	public var filePath = "HxPkgWrapper.lua";

	public var wrapperCode = "
local hxPkgWrapper = {}
hxPkgWrapper.modules = {}
hxPkgWrapper.loaded = {}
hxPkgWrapper.config = nil--CONFIG

local function recurseGetInst(path, root)
    local spl = path:split('.')
    local current = root
    for _, v in spl do
        if current == game then
            current = current:GetService(v)
        else
            current = current:WaitForChild(v)
        end
    end
    return current
end

function hxPkgWrapper.registerPkg(pkgName, types)
    hxPkgWrapper.modules[pkgName] = types
end

function hxPkgWrapper.importPkg(pkgName)
    if hxPkgWrapper.loaded[pkgName] == nil then
        hxPkgWrapper.loaded[pkgName] = true

        local spl = pkgName:split('.')
        local pkg = table.remove(spl, 1)

        local context = hxPkgWrapper.config.packageContexts[pkg or '_']
        local justPush = false
        if context == nil then
            context = hxPkgWrapper.config.packageContexts['_']
        end
        if context:sub(-1) == '#' then
            context = context:sub(1, -2)
            justPush = true
        end

        local path = nil
        if justPush then
            path = hxPkgWrapper.config.contextPaths[context]..'.'..pkgName
        else
            path = hxPkgWrapper.config.contextPaths[context]..'.'..table.concat(spl, '.')
        end

        local inst = path ~= nil and recurseGetInst(path, game)
        if inst == nil then
            error('Could not load module '..pkgName..'. Context: '..context)
        end

        require(inst)
    end
    return hxPkgWrapper.modules[pkgName]
end

return {hxPkgWrapper.importPkg, hxPkgWrapper.registerPkg, hxPkgWrapper}
";
}
#end
