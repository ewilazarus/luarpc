local table = require('table')


------------------------------------------------------ ERRORS ---------------------------------------------------------
errors = {
    I01 = 'The provided interface file is either missing or syntatically invalid',
    I02 = 'The provided interface does not have a "name" attribute',
    I03 = 'The provided interface "name" attribute whose value is not of type "string"',
    I04 = 'The provided interface does not have a "methods" attribute',
    I05 = 'The provided interface "methods" attribute whose value is not of type "table"',
    I06 = 'The provided interface "methods" attribute whose value must define at least one method',
    I07 = 'The provided interface has a method without a "resulttype" attribute',
    I08 = 'The provided interface has a "resulttype" attribute value that is not of type "string"',
    I09 = 'The provided interface has a "resulttype" attribute value that is neither \'void\', \'char\', \'string\' nor \'double\'',
    I10 = 'The provided interface has an "args" attribute whose value does not define a "direction" attribute',
    I11 = 'The provided interface has a "direction" attribute whose value is not of type "string"',
    I12 = 'The provided interface has a "direction" attribute whose value is neither \'in\', \'out\' nor \'inout\'',
    I13 = 'The provided interface has an "args" attribute whose value does not define a "type" attribute',
    I14 = 'The provided interface has a "type" attribute whose value is not of type "string"',
    I15 = 'The provided interface has a "type" attribute whose value is neither \'char\', \'string\' nor \'double\'',
    S01 = 'The provided definition does not implement all methods in the inferface',
    S02 = 'The provided definition implements a method that is not of type "function"'
}


----------------------------------------------------- HELPERS ---------------------------------------------------------
local function istype(t)
    return function(value) return type(value) == t end
end

local istable = istype('table')
local isstring = istype('string')
local isfunction = istype('function')

local function hasvalue(array)
    return function(value)
        for _, v in pairs(array) do
            if v == value then return true end
        end
        return false
    end
end

local function gettablelength(t)
    local length = 0
    for _ in pairs(t) do length = length + 1 end
    return length
end

local function gettablekeys(t)
    local keys = {}
    for k, _ in pairs(t) do table.insert(keys, k) end
    return keys
end


---------------------------------------------------- INTERFACE --------------------------------------------------------
local prospectMemoizer
function interface(value)
    prospectMemoizer = value
end

local InterfaceHandler = {}

function InterfaceHandler:_normalize(prospect)
    for _, definition in pairs(prospect.methods) do
        if definition.args == nil then definition.args = {} end
    end
    return prospect
end

InterfaceHandler._isvalidargtype = hasvalue({'char', 'string', 'double'})
InterfaceHandler._isvalidargdirection = hasvalue({'in', 'out', 'inout'})

function InterfaceHandler:_validateMethodArg(arg)
    assert(arg.direction, errors.I10)
    assert(isstring(arg.direction), errors.I11)
    assert(self._isvalidargdirection(arg.direction), errors.I12)
    assert(arg.type, errors.I13)
    assert(isstring(arg.type), errors.I14)
    assert(self._isvalidargtype(arg.type), errors.I15)
end

function InterfaceHandler:_validateMethodArgs(method)
    if method.args then
        for _, arg in pairs(method.args) do
            self:_validateMethodArg(arg)
        end
    end
end

InterfaceHandler._isvalidresulttype = hasvalue({'void', 'char', 'string', 'double'})

function InterfaceHandler:_validateMethodResultType(method)
    assert(method.resulttype, errors.I07)
    assert(isstring(method.resulttype), errors.I08)
    assert(self._isvalidresulttype(method.resulttype), errors.I09)
end

function InterfaceHandler:_validateMethod(method)
    self:_validateMethodResultType(method)
    self:_validateMethodArgs(method)
end

function InterfaceHandler:_validateMethods(prospect)
    assert(prospect.methods, errors.I04)
    assert(istable(prospect.methods), errors.I05)
    local methodCount = 0
    for _, method in pairs(prospect.methods) do
        methodCount = methodCount + 1
        self:_validateMethod(method)
    end
    assert(methodCount > 0, errors.I06)
end

function InterfaceHandler:_validateName(prospect)
    assert(prospect.name, errors.I02)
    assert(isstring(prospect.name), errors.I03)
end

function InterfaceHandler:_validate(prospect)
    self:_validateName(prospect)
    self:_validateMethods(prospect)
    return prospect
end

function InterfaceHandler:_parse(file)
    prospectMemoizer = nil
    dofile(file)
    assert(istable(prospectMemoizer), errors.I01)
    return prospectMemoizer
end

function InterfaceHandler:consume(file)
    return self:_normalize(self:_validate(self:_parse(file)))
end


----------------------------------------------------- SERVANT ---------------------------------------------------------
local ServantBuilder = {}

function ServantBuilder:_validateMethod(dmethod, smethod)
end

function ServantBuilder:validate(def, spec)
    dmethodnames = gettablekeys(def)
    smethodnames = gettablekeys(spec.methods)
    for _, smethodname in pairs(smethodnames) do
        local dmethod = def[smethodname]
        assert(dmethod ~= nil, errors.S01)
        assert(isfunction(dmethod), errors.S02)
        self:_validateMethod(dmethod, spec.methods[smethodname])
    end
    return true
end

function ServantBuilder:bind(def)
end

local ServantPool = {}

ServantPool._builder = ServantBuilder
ServantPool.instances = {}

function ServantPool:add(def, spec)
    self._builder:validate(def, spec)
    local instance = self._builder:bind(def)
    table.insert(self.instances, instance)
end


-----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- EXPOSED ---------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
local LuaRPC = {}

LuaRPC._interfaceHandler = InterfaceHandler
LuaRPC._servantPool = ServantPool

function LuaRPC:createProxy(ip, port, file)
    -- TODO: Implement
end

function LuaRPC:createServant(def, file)
    -- TODO: Implement
end

function LuaRPC:waitIncoming()
    -- TODO: Implement
end

return LuaRPC
