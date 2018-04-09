local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: marshaling marshal')

local marshaler = luarpc._marshaling


function test_canMarshalRequest()
    lu.assertEquals(marshaler:marshalRequest('methodName', {'astring', 1337, 'anotherstring'}), 'methodName\nastring\n1337\nanotherstring')
end

function test_canMarshalResponse()
    lu.assertEquals(marshaler:marshalResponse({44, 'success'}), '44\nsuccess')
end

function test_canMarshalResponse2()
    lu.assertEquals(marshaler:marshalResponse({44}), '44')
end

function test_canMarshalResponse3()
    lu.assertEquals(marshaler:marshalResponse({}), '')
end

function test_canMarshalErrorResponse()
    lu.assertEquals(marshaler:marshalErrorResponse('ocorreu um erro'), '__ERRORPC: ocorreu um erro')
end


lu.LuaUnit.run('--name', './tests/marshaling/marshal')
print('\n')
