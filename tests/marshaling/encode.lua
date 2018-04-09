local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: marshaling encode')

local marshaler = luarpc._marshaling


function test_canEncode()
    lu.assertEquals(marshaler:_encode('abc'), 'abc')
end

function test_canEncode2()
    lu.assertEquals(marshaler:_encode('a\nc'), 'a\\:-)\\c')
end

function test_canEncode3()
    lu.assertEquals(marshaler:_encode('a\nb\nc'), 'a\\:-)\\b\\:-)\\c')
end

function test_canEncode4()
    lu.assertEquals(marshaler:_encode('\n'), '\\:-)\\')
end


lu.LuaUnit.run('--name', './tests/marshaling/marshal')
print('\n')
