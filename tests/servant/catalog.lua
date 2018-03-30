local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: servant catalog')

local servantPool = luarpc._servantPool

local function createNextVersion(id)
    return servantPool:_createNextVersion(id)
end


function test_canCreateNextVersion()
    lu.assertEquals(createNextVersion('bla'), 'bla#1')
end

function test_canCreateNextNextVersion()
    createNextVersion('ble')
    lu.assertEquals(createNextVersion('ble'), 'ble#2')
end


lu.LuaUnit.run('--name', './tests/servant/catalog')
print('\n\n')
