local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: marshaling unmarshal')

local marshaler = luarpc._marshaling


function test_canUnmarshalRequest()
    local success, method, args = marshaler:unmarshalRequest('methodName|astring|1337|anotherstring', {inTypes = {'string', 'double', 'string'}})
    lu.assertTrue(success)
    lu.assertEquals(method, 'methodName')
    lu.assertEquals(args, {'astring', 1337, 'anotherstring'})
end

function test_canUnmarshalBadRequest()
    local success, cause = marshaler:unmarshalRequest('methodName|1234|asdf', {inTypes = {'double', 'double'}})
    lu.assertFalse(success)
    lu.assertEquals(cause, 'couldn\'t unmarshal client request')
end

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

function test_canUnmarshalErrorResponse()
    local success, cause = marshaler:unmarshalResponse('__ERRORPC: ocorreu um erro', {outTypes = {'double', 'string'}})
    lu.assertFalse(success)
    lu.assertEquals(cause, 'server responded with "ocorreu um erro"')
end


lu.LuaUnit.run('--name', './tests/marshaling/unmarshal')
print('\n')
