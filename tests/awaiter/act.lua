local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: awaiter act')

local awaiter = luarpc._awaiter

local function act(instance, socket)
    return awaiter:_act(instance, socket, luarpc._marshaling)
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
local instance1 = {
    def = {
        fn1 = function(double, string)
            return 'hello world'
        end
    },
    spec = {
        methods = {
            fn1 = {
                _meta = {
                    inTypes = {'double', 'string'},
                    outTypes = {'string'}
                }
            }
        }
    }
}

local socketMock1 = createSocketMock(function() return 'fn1|123|alou', nil end)

function test_canAct()
    local result, cause = act(instance1, socketMock1)
    lu.assertTrue(result)
end


--
local instance2 = {
    def = {
        fn2 = function(double, string)
            return 'hello world'
        end
    },
    spec = {
        methods = {
            fn2 = {
                _meta = {
                    inTypes = {'double', 'string'},
                    outTypes = {'string'}
                }
            }
        }
    }
}

local socketMock2 = createSocketMock(function() return 'fn1|123|alou', nil end)

function test_cantActOnNonExistentFunction()
    local result, cause = act(instance2, socketMock2)
    lu.assertFalse(result)
end


--
local instance3 = {
    def = {
        fn1 = function(double, string)
            error('hello world')
        end
    },
    spec = {
        methods = {
            fn1 = {
                _meta = {
                    inTypes = {'double', 'string'},
                    outTypes = {'string'}
                }
            }
        }
    }
}

local socketMock3 = createSocketMock(function() return 'fn1|123|alou', nil end)

function test_cantActOnErrorFunction()
    local result, cause = act(instance3, socketMock3)
    lu.assertFalse(result)
end


--
local instance4 = {
    def = {
        fn1 = function(double, string)
            return 'hello world'
        end
    },
    spec = {
        methods = {
            fn1 = {
                _meta = {
                    inTypes = {'double', 'string'},
                    outTypes = {'string'}
                }
            }
        }
    }
}

local socketMock4 = createSocketMock(function() return nil, 'closed' end)

function test_cantActOnErrorConnection()
    local result, cause = act(instance4, socketMock4)
    lu.assertFalse(result)
end


lu.LuaUnit.run('--name', './tests/awaiter/act')
print('\n')
