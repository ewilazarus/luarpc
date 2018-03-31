local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: proxy method')

local factory = luarpc._proxyFactory

local function createProxyMethod(method, socket)
    return factory:_createProxyMethodWrapper('test', method, socket, luarpc._marshaling)
end

local function createSocketMock(recvFn)
    local socketMock = {}
    function socketMock:send(data)
    end
    function socketMock:recv()
        return recvFn()
    end
    return socketMock
end

--
local methodMock1 = {
    _meta = {
        inTypes = {'double', 'double'},
        outTypes = {'double'}
    }
}

local socketMock1 = createSocketMock(function() return '42', nil end)

function test_canCreateMethod()
    local method = createProxyMethod(methodMock1, socketMock1)
    local result = method(1, 2)
    lu.assertEquals(result, 42)
end

--
local methodMock2 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double', 'double'}
    }
}

local socketMock2 = createSocketMock(function() return '13|37', nil end)

function test_canCreateMethodWithMultipleReturnValues()
    local method = createProxyMethod(methodMock2, socketMock2)
    local r1, r2 = method(1)
    lu.assertEquals(r1, 13)
    lu.assertEquals(r2, 37)
end

--
local methodMock3 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double'}
    }
}

local socketMock3 = createSocketMock(function() return '42', nil end)

function test_canCreateMethodWithMissingArgs()
    local method = createProxyMethod(methodMock3, socketMock3)
    local result = method()
    lu.assertEquals(result, 42)
end

--
local methodMock4 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double'}
    }
}

local socketMock4 = createSocketMock(function() return '42', nil end)

function test_canCreateMethodWithMoreArgsThanNeeded()
    local method = createProxyMethod(methodMock4, socketMock4)
    local result = method(42, 'im not needed', 'me neither', 7)
    lu.assertEquals(result, 42)
end

--
local methodMock5 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double'}
    }
}

local socketMock5 = createSocketMock(function() return '42', nil end)

function test_cantCreateMethodWithWrongTypes()
    local method = createProxyMethod(methodMock5, socketMock5)
    lu.assertErrorMsgContains(errors.P01, method, 'eu nao sou double')
end

--
local methodMock6 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double'}
    }
}

local socketMock6 = createSocketMock(function() return nil, 'timeout' end)

function test_canCreateMethodWithTimeout()
    local method = createProxyMethod(methodMock6, socketMock6)
    local result = method(43)
    lu.assertIsNil(result)
end

--
local methodMock7 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double'}
    }
}

local socketMock7 = createSocketMock(function() return '__ERRORPC: estou com fome', nil end)

function test_canCreateMethodWithServerError()
    local method = createProxyMethod(methodMock7, socketMock7)
    local result = method(43)
    lu.assertIsNil(result)
end

--
local methodMock8 = {
    _meta = {
        inTypes = {'double'},
        outTypes = {'double', 'string', 'double', 'char'}
    }
}

local socketMock8 = createSocketMock(function() return '13|mcdonalds|37|s', nil end)

function test_canCreateMethodWithMultipleReturnValues2()
    local method = createProxyMethod(methodMock8, socketMock8)
    local r1, r2, r3, r4 = method(1)
    lu.assertEquals(r1, 13)
    lu.assertEquals(r2, 'mcdonalds')
    lu.assertEquals(r3, 37)
    lu.assertEquals(r4, 's')
end


lu.LuaUnit.run('--name', './tests/proxy/method')
print('\n')
