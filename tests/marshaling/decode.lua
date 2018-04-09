local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: marshaling decode')

local marshaler = luarpc._marshaling


function test_canDecode()
    lu.assertEquals(marshaler:_decode('abc'), 'abc')
end

function test_canDecode2()
    lu.assertEquals(marshaler:_decode('a\\:-)\\c'), 'a\nc')
end

function test_canDecode3()
    lu.assertEquals(marshaler:_decode('a\\:-)\\b\\:-)\\c'), 'a\nb\nc')
end

function test_canDecode4()
    lu.assertEquals(marshaler:_decode('\\:-)\\'), '\n')
end


lu.LuaUnit.run('--name', './tests/marshaling/marshal')
print('\n')
