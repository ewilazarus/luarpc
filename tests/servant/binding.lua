local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: servant binding')

local interfaceHandler = luarpc._interfaceHandler
local servantPool = luarpc._servantPool

local function addServant(def, file)
    local spec = interfaceHandler:consume(file)
    return servantPool:add(def, spec)
end


local givenDef = {
    foo = function(a, b, s) return a+b, 'alo alo' end,
    boo = function(n) return n end
}

function test_canAddServant()
    lu.assertEquals(#servantPool.instances, 0)
    lu.assertTrue(addServant(givenDef, 'resources/given.ifile'))
    lu.assertEquals(#servantPool.instances, 1)
end


lu.LuaUnit.run('--name', './tests/servant/catalog')
