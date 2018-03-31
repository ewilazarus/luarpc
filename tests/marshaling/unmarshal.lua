local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: marshaling unmarshal')

local marshaler = luarpc._marshaling


--
local spec1 = {
    methods = {
        methodName = {
            _meta = {
                inTypes = {'string', 'double', 'string'}
            }
        }
    }
}

function test_canUnmarshalRequest()
    local success, method, args = marshaler:unmarshalRequest('methodName|astring|1337|anotherstring', spec1)
    lu.assertTrue(success)
    lu.assertEquals(method, 'methodName')
    lu.assertEquals(args, {'astring', 1337, 'anotherstring'})
end


--
local spec2 = {
    methods = {
        methodName = {
            _meta = {
                inTypes = {'double', 'double'}
            }
        }
    }
}

function test_canUnmarshalBadRequest()
    local success, cause = marshaler:unmarshalRequest('methodName|1234|asdf', spec2)
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t unmarshal client request')
end


--
local spec3 = {
    methods = {
        methodName = {
            _meta = {
                inTypes = {'string', 'double', 'char'}
            }
        }
    }
}

function test_canUnmarshalBadRequest2()
    local success, cause = marshaler:unmarshalRequest('methodName|1234|asdf', spec3)
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t unmarshal client request')
end


--
local spec4 = {
    methods = {
        methodName = {
            _meta = {
                inTypes = {'string', 'double', 'char'}
            }
        }
    }
}

function test_canUnmarshalBadRequest3()
    local success, cause = marshaler:unmarshalRequest('methodName|1234', spec4)
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t unmarshal client request')
end


--
local spec5 = {
    methods = {
        methodName2 = {
            _meta = {
                inTypes = {'string', 'double', 'char'}
            }
        }
    }
}

function test_canUnmarshalBadRequest3()
    local success, cause = marshaler:unmarshalRequest('methodName|1234', spec5)
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t find matching function')
end


--
function test_canUnmarshalResponse()
    local success, args = marshaler:unmarshalResponse('1337|anotherstring', {outTypes = {'double', 'string'}})
    lu.assertTrue(success)
    lu.assertEquals(args, {1337, 'anotherstring'})
end

function test_canUnmarshalResponse2()
    local success, args = marshaler:unmarshalResponse('', {outTypes = {}})
    lu.assertTrue(success)
end

function test_canUnmarshalBadResponse()
    local success, cause = marshaler:unmarshalResponse('1337|astring', {outTypes = {'double', 'double'}})
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t unmarshal server response')
end

function test_canUnmarshalBadResponse2()
    local success, cause = marshaler:unmarshalResponse('imnotawake|1234', {outTypes = {'string', 'double', 'char'}})
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t unmarshal server response')
end

function test_canUnmarshalErrorResponse()
    local success, cause = marshaler:unmarshalResponse('__ERRORPC: ocorreu um erro', {outTypes = {'double', 'string'}})
    lu.assertFalse(success)
    lu.assertEquals(cause, 'server responded with "ocorreu um erro"')
end


lu.LuaUnit.run('--name', './tests/marshaling/unmarshal')
print('\n')
