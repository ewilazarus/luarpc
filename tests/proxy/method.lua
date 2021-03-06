local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: proxy method')

local factory = luarpc._proxyFactory

local function createProxyMethod(meta, socket)
    return factory:_createProxyMethodWrapper('test', meta, socket, luarpc._marshaling)
end

local function createSocketMock(recvFn)
    local socketMock = {}
    function socketMock:send(data)
    end
    function socketMock:receive()
        return recvFn()
    end
    return socketMock
end

--
local methodMock1 = {
        inTypes = {'double', 'double'},
        outTypes = {'double'}
    }

local socketMock1 = createSocketMock(function() return '42', nil end)

function test_canCreateMethod()
    local method = createProxyMethod(methodMock1, socketMock1)
    local err, result = method(1, 2)
    lu.assertEquals(err, nil)
    lu.assertEquals(result, 42)
end

--
local methodMock2 = {
        inTypes = {'double'},
        outTypes = {'double', 'double'}
}

local socketMock2 = createSocketMock(function() return '13\n37', nil end)

function test_canCreateMethodWithMultipleReturnValues()
    local method = createProxyMethod(methodMock2, socketMock2)
    local err, r1, r2 = method(1)
    lu.assertEquals(err, nil)
    lu.assertEquals(r1, 13)
    lu.assertEquals(r2, 37)
end

--
local methodMock3 = {
        inTypes = {'double'},
        outTypes = {'double'}
}

local socketMock3 = createSocketMock(function() return '42', nil end)

function test_canCreateMethodWithMissingArgs()
    local method = createProxyMethod(methodMock3, socketMock3)
    local err, result = method()
    lu.assertEquals(err, nil)
    lu.assertEquals(result, 42)
end

--
local methodMock4 = {
        inTypes = {'double'},
        outTypes = {'double'}
}

local socketMock4 = createSocketMock(function() return '42', nil end)

function test_canCreateMethodWithMoreArgsThanNeeded()
    local method = createProxyMethod(methodMock4, socketMock4)
    local err, result = method(42, 'im not needed', 'me neither', 7)
    lu.assertEquals(err, nil)
    lu.assertEquals(result, 42)
end

--
local methodMock5 = {
        inTypes = {'double'},
        outTypes = {'double'}
}

local socketMock5 = createSocketMock(function() return '42', nil end)

function test_cantCreateMethodWithWrongTypes()
    local method = createProxyMethod(methodMock5, socketMock5)
    lu.assertErrorMsgContains(errors.P01, method, 'eu nao sou double')
end

--
local methodMock51 = {
    inTypes = {'double'},
    outTypes = {'char'}
}

local socketMock51 = createSocketMock(function() return 'hello im not a char', nil end)

function test_cantCreateMethodWithWrongTypes2()
    local method = createProxyMethod(methodMock51, socketMock51)
    lu.assertErrorMsgContains(errors.P01, method, 'hello im not a char')
end

--
local methodMock6 = {
        inTypes = {'double'},
        outTypes = {'double'}
}

local socketMock6 = createSocketMock(function() return nil, 'timeout' end)

function test_canCreateMethodWithTimeout()
    local method = createProxyMethod(methodMock6, socketMock6)
    local err, result = method(43)
    lu.assertEquals(err, 'timeout')
    lu.assertIsNil(result)
end

--
local methodMock7 = {
        inTypes = {'double'},
        outTypes = {'double'}
}

local socketMock7 = createSocketMock(function() return '__ERRORPC: estou com fome', nil end)

function test_canCreateMethodWithServerError()
    local method = createProxyMethod(methodMock7, socketMock7)
    local err, result = method(43)
    lu.assertEquals(err, 'estou com fome\n')
    lu.assertIsNil(result)
end

--
local methodMock8 = {
        inTypes = {'double'},
        outTypes = {'double', 'string', 'double', 'char'}
}

local socketMock8 = createSocketMock(function() return '13\nmcdonalds\n37\ns', nil end)

function test_canCreateMethodWithMultipleReturnValues2()
    local method = createProxyMethod(methodMock8, socketMock8)
    local err, r1, r2, r3, r4 = method(1)
    lu.assertEquals(err, nil)
    lu.assertEquals(r1, 13)
    lu.assertEquals(r2, 'mcdonalds')
    lu.assertEquals(r3, 37)
    lu.assertEquals(r4, 's')
end


lu.LuaUnit.run('--name', './tests/proxy/method')
print('\n')
