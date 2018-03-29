local table = require('table')
local socket = require('socket')


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
    S02 = 'The provided definition implements a method that is not of type "function"',
    S03 = 'The provided definition implements a method that does not return the amount of values accordingly to the interface',
    S04 = 'The provided definition implements a method that does not return the types accordingly to the interface'
}


----------------------------------------------------- HELPERS ---------------------------------------------------------
local function isType(t)
    return function(value) return type(value) == t end
end

local isTable = isType('table')
local isString = isType('string')
local isFunction = isType('function')

local function hasValue(array)
    return function(value)
        for _, v in pairs(array) do
            if v == value then return true end
        end
        return false
    end
end

local function getTableKeys(t)
    local keys = {}
    for k, _ in pairs(t) do table.insert(keys, k) end
    return keys
end

local function concatArrays(array1, array2)
    for _, v in pairs(array2) do table.insert(array1, v) end
    return array1
end


---------------------------------------------------- INTERFACE --------------------------------------------------------
local prospectMemoizer
function interface(value)
    prospectMemoizer = value
end

local InterfaceHandler = {}

function InterfaceHandler:_getArgTypesByDirection(args, direction)
    local argTypes = {}
    for _, arg in pairs(args) do
        if arg.direction == direction or arg.direction == 'inout' then
            table.insert(argTypes, arg.type)
        end
    end
    return argTypes
end

function InterfaceHandler:_addMetadata(prospect, id)
    prospect._id = prospect.name .. '[' .. id .. ']'
    for _, method in pairs(prospect.methods) do
        local inTypes = self:_getArgTypesByDirection(method.args, 'in')
        local outArgTypes = self:_getArgTypesByDirection(method.args, 'out')
        local outTypes = method.resulttype == 'void' and outArgTypes or concatArrays({method.resulttype}, outArgTypes)
        method._meta = { inTypes = inTypes, outTypes = outTypes }
    end
    return prospect
end

function InterfaceHandler:_normalize(prospect)
    for _, method in pairs(prospect.methods) do
        if method.args == nil then method.args = {} end
    end
    return prospect
end

InterfaceHandler._isvalidargtype = hasValue({'char', 'string', 'double'})
InterfaceHandler._isvalidargdirection = hasValue({'in', 'out', 'inout'})

function InterfaceHandler:_validateMethodArg(arg)
    assert(arg.direction, errors.I10)
    assert(isString(arg.direction), errors.I11)
    assert(self._isvalidargdirection(arg.direction), errors.I12)
    assert(arg.type, errors.I13)
    assert(isString(arg.type), errors.I14)
    assert(self._isvalidargtype(arg.type), errors.I15)
end

function InterfaceHandler:_validateMethodArgs(method)
    if method.args then
        for _, arg in pairs(method.args) do
            self:_validateMethodArg(arg)
        end
    end
end

InterfaceHandler._isvalidresulttype = hasValue({'void', 'char', 'string', 'double'})

function InterfaceHandler:_validateMethodResultType(method)
    assert(method.resulttype, errors.I07)
    assert(isString(method.resulttype), errors.I08)
    assert(self._isvalidresulttype(method.resulttype), errors.I09)
end

function InterfaceHandler:_validateMethod(method)
    self:_validateMethodResultType(method)
    self:_validateMethodArgs(method)
end

function InterfaceHandler:_validateMethods(prospect)
    assert(prospect.methods, errors.I04)
    assert(isTable(prospect.methods), errors.I05)
    local methodCount = 0
    for _, method in pairs(prospect.methods) do
        methodCount = methodCount + 1
        self:_validateMethod(method)
    end
    assert(methodCount > 0, errors.I06)
end

function InterfaceHandler:_validateName(prospect)
    assert(prospect.name, errors.I02)
    assert(isString(prospect.name), errors.I03)
end

function InterfaceHandler:_validate(prospect)
    self:_validateName(prospect)
    self:_validateMethods(prospect)
    return prospect
end

function InterfaceHandler:_parse(file)
    prospectMemoizer = nil
    dofile(file)
    assert(isTable(prospectMemoizer), errors.I01)
    return prospectMemoizer
end

function InterfaceHandler:consume(file)
    return self:_addMetadata(self:_normalize(self:_validate(self:_parse(file))), file)
end


----------------------------------------------------- SERVANT ---------------------------------------------------------
local ServantBuilderSandbox = {}

ServantBuilderSandbox._inputDefaults = { double = 1, string = 'abc', char = 'c' }
ServantBuilderSandbox._outputTypeAdapters = { double = 'number', char = 'string', string = 'string' }

function ServantBuilderSandbox:_createOutputValidators(meta)
    local validators = {}
    for _, m in pairs(meta.outTypes) do
        table.insert(validators, isType(self._outputTypeAdapters[m]))
    end
    return validators
end

function ServantBuilderSandbox:_createInput(meta)
    local input = {}
    for _, m in pairs(meta.inTypes) do
        table.insert(input, self._inputDefaults[m])
    end
    return input
end

function ServantBuilderSandbox:_validateOutput(returnValues, outputValidators)
    for i = 1, #returnValues do
        if not outputValidators[i](returnValues[i]) then
            return false
        end
    end
    return true
end

function ServantBuilderSandbox:run(method, meta)
    local input = self:_createInput(meta)
    local success, returnVals = pcall(function() return {method(table.unpack(input))} end)
    if success then
        assert(#returnVals == #meta.outTypes, errors.S03)
        local outputValidators = self:_createOutputValidators(meta)
        assert(self:_validateOutput(returnVals, outputValidators), errors.S04)
    else
        print('WARNING: one of the provided definitions might be prone to throw an error')
    end
    return true
end


local ServantBuilder = {}

ServantBuilder._sandbox = ServantBuilderSandbox

function ServantBuilder:validate(def, spec)
    local smethodnames = getTableKeys(spec.methods)
    for i = 1, #smethodnames do
        local smethodname = smethodnames[i]
        local dmethod = def[smethodname]
        assert(dmethod ~= nil, errors.S01)
        assert(isFunction(dmethod), errors.S02)
        self._sandbox:run(dmethod, spec.methods[smethodname]._meta)
    end
    return true
end

function ServantBuilder:bind(def, name)

end


local ServantPool = {}

ServantPool._builder = ServantBuilder
ServantPool._instanceCatalog = {}
ServantPool.instances = {}

function ServantPool:_createNextVersion(id)
    local version = self._instanceCatalog[id]
    if version == nil then
        version = 1
    else
        version = version + 1
    end
    self._instanceCatalog[id] = version
    return id .. '#' .. version
end

function ServantPool:add(def, spec)
    self._builder:validate(def, spec)
    local instance = self._builder:bind(def, self:_createNextVersion(spec._id))
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
