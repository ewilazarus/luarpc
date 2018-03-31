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
    S04 = 'The provided definition implements a method that does not return the types accordingly to the interface',
    P01 = 'The provided parameters do not match what is specified in the interface'
}


----------------------------------------------------- HELPERS ---------------------------------------------------------
local runtimeEnvironment = os.getenv('LUARPC_ENVIRONMENT')

local function log(type)
    return function(message)
        if runtimeEnvironment ~= 'test' then
            print(type .. ': ' .. message)
        end
    end
end

local logInfo = log('INFO')
local logWarn = log('WARN')
local logErro = log('ERRO')

local function isType(t)
    return function(value)
        if t == 'char' then
            return type(value) == 'string' and string.len(value) == 1
        end
        if t == 'double' then
            return type(value) == 'number'
        end
        return type(value) == t
    end
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

local function stringStartsWith(s, start)
    return string.sub(s, 1, string.len(start)) == start
end


--------------------------------------------------- MARSHALING --------------------------------------------------------
local Marshaling = {}

Marshaling._separator = '|'

function Marshaling:_unmarshalSegment(segment, type)
    if type == 'double' then
        return tonumber(segment)
    end
    return segment
end

function Marshaling:marshalRequest(method, args)
    local stub = method
    for _, arg in pairs(args) do
        stub = stub .. self._separator .. arg
    end
    stub = stub .. '\n'
    return stub
end

function Marshaling:unmarshalRequest(stub, spec)
    local meta = nil
    local methodName = nil
    local args = {}
    count = 0
    for segment in string.gmatch(stub, '[^' .. self._separator .. ']+') do
        if count == 0 then
            methodName = segment
            local method = spec.methods[methodName]
            if method == nil then
                return false, 'couldn\'t find matching function'
            else
                meta = method._meta
            end
        else
            local value = self:_unmarshalSegment(segment, meta.inTypes[count])
            if value == nil then return false, 'couldn\'t unmarshal client request' end
            table.insert(args, value)
        end
        count = count + 1
    end
    if count < #meta.inTypes then
        return false, 'couldn\'t unmarshal client request'
    end
    return true, methodName, args
end

function Marshaling:marshalResponse(args)
    local stub = ''
    for i, arg in pairs(args) do
        if i == 1 then
            stub = stub .. arg
        else
            stub = stub .. self._separator .. arg
        end
    end
    stub = stub .. '\n'
    return stub
end

function Marshaling:marshalErrorResponse(cause)
    return '__ERRORPC: ' .. cause .. '\n'
end

function Marshaling:unmarshalResponse(stub, meta)
    if stringStartsWith(stub, '__ERRORPC: ') then
        return false, 'server responded with "' .. string.sub(stub, 12) .. '"'
    end

    local args = {}
    count = 1
    for segment in string.gmatch(stub, '[^' .. self._separator .. ']+') do
        local value = self:_unmarshalSegment(segment, meta.outTypes[count])
        if value == nil then return false, 'couldn\'t unmarshal server response' end
        table.insert(args, value)
        count = count + 1
    end
    if count - 1 < #meta.outTypes then
        return false, 'couldn\'t unmarshal server response'
    end
    return true, args
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

function ServantBuilderSandbox:_validateOutput(returnValues, meta)
    for i, otype in pairs(meta.outTypes) do
        local validate = isType(otype)
        if not validate(returnValues[i]) then
            return false
        end
    end
    return true
end

function ServantBuilderSandbox:_createInput(meta)
    local input = {}
    for _, m in pairs(meta.inTypes) do
        table.insert(input, self._inputDefaults[m])
    end
    return input
end

function ServantBuilderSandbox:run(method, meta)
    local input = self:_createInput(meta)
    local success, returnVals = pcall(function() return {method(table.unpack(input))} end)
    if success then
        assert(#returnVals == #meta.outTypes, errors.S03)
        assert(self:_validateOutput(returnVals, meta), errors.S04)
    else
        logWarn('One of the provided definitions might be prone to throw an error')
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

function ServantBuilder:bind(def, id, spec, port)
    local s = assert(socket.bind('*', port or '0'))
    local ip, port = s:getsockname()
    logInfo('Definition for "' .. id .. '" bound to "' .. ip .. ':' .. port .. '"')
    return { id = id .. '@' .. port, name = spec.name, ip = ip, port = port, def = def, socket = s, spec = spec }
end


local ServantPool = {}

ServantPool._builder = ServantBuilder
ServantPool._instanceCatalog = {}
ServantPool.instances = {}

function ServantPool:_createNextVersion(id)
    local version = self._instanceCatalog[id]
    version = version == nil and 1 or version + 1
    self._instanceCatalog[id] = version
    return id .. '#' .. version
end

function ServantPool:add(def, spec, port)
    self._builder:validate(def, spec)
    local instance = self._builder:bind(def, self:_createNextVersion(spec._id), spec, port)
    table.insert(self.instances, instance)
    return instance
end


------------------------------------------------------ PROXY ----------------------------------------------------------
local ProxyFactory = {}

ProxyFactory._defaultInputTypes = { double = 1, char = 'c', string = 'string' }

function ProxyFactory:_cleanArgs(meta, args)
    for i, itype in pairs(meta.inTypes) do
        if args[i] == nil then
            args[i] = self._defaultInputTypes[itype]
        else
            local validate = isType(itype)
            assert(validate(args[i]), errors.P01)
        end
    end
    return args
end

function ProxyFactory:_createProxyMethodWrapper(name, methodMeta, s, marshaler)
    return function(...)
        local cleansedArgs = self:_cleanArgs(methodMeta, {...})
        local reqStub = marshaler:marshalRequest(name, cleansedArgs)

        s:send(reqStub)
        logInfo('Sent request')
        local resStub, err = s:receive()
        if err ~= nil then
            logErro('Connection with server failed (' .. err .. ')')
            return nil
        end
        logInfo('Received response')

        local success, rvs = marshaler:unmarshalResponse(resStub, methodMeta)
        if not success then
            logErro(rvs)
            return nil
        end
        return table.unpack(rvs)
    end
end

function ProxyFactory:createProxy(ip, port, spec)
    local proxy = {}
    local s = assert(socket.tcp())
    s:connect(ip, port)
    proxy._socket = s
    for name, method in pairs(spec.methods) do
        proxy[name] = self:_createProxyMethodWrapper(name, method._meta, s, Marshaling)
    end
    logInfo('Created proxy to ' .. ip .. ':' .. port .. ' targeting "' .. spec._id .. '"')
    return proxy
end


----------------------------------------------------- AWAITER ---------------------------------------------------------
local Awaiter = {}


function Awaiter:_run(fn, args)
    return pcall(function()
        return fn(table.unpack(args))
    end)
end

function Awaiter:_act(instance, s, marshaler)
    local reqStub, err = s:receive()
    if err ~= nil then
        logErro('Connection with client failed (' .. err .. ')')
        return false, 'connection issues'
    end
    logInfo('Received request')

    local success, method, args = marshaler:unmarshalRequest(reqStub, instance.spec)
    if not success then
        logErro(method)

        local errStub = marshaler:marshalErrorResponse(method)
        s:send(errStub)

        logInfo('Sent response')
        return false, method
    end

    local fn = instance.def[method]

    local runSuccess, rvs = self:_run(fn, args)
    if runSuccess then
        local resStub = marshaler:marshalResponse(table.pack(rvs))
        s:send(resStub)

        logInfo('Sent response')
        return true, nil
    end

    local resStub = marshaler:marshalErrorResponse(rvs)
    s:send(resStub)  -- TODO: verificar se tem que tratar erro

    logInfo('Sent response')
    return false, rvs
end

function Awaiter:_getSockets(instances)
    local sockets = {}
    for _, instance in pairs(instances) do
        instance.socket:accept()
        table.insert(sockets, instance.socket)
    end
    return sockets
end

function Awaiter:waitIncoming(instances, marshaler)
    local sockets = self:_getSockets(instances)
    while true do
        local selectedSockets = socket.select(sockets)
        for i, s in pairs(selectedSockets) do
            self:_act(instances[i], s, marshaler)
        end
    end
end


-----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- EXPOSED ---------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
return {
    createProxy = function(ip, port, file)
        local spec = InterfaceHandler:consume(file)
        return ProxyFactory:createProxy(ip, port, spec)
    end,

    createServant = function(def, file)
        local spec = InterfaceHandler:consume(file)
        return ServantPool:add(def, spec)
    end,

    waitIncoming = function()
        Awaiter:waitIncoming(ServantPool.instances, Marshaling)
    end,

    _createServant = function(def, file, port)
        local spec = InterfaceHandler:consume(file)
        return ServantPool:add(def, spec, port)
    end,

    _interfaceHandler = InterfaceHandler,
    _servantPool = ServantPool,
    _proxyFactory = ProxyFactory,
    _marshaling = Marshaling,
    _awaiter = Awaiter
}
