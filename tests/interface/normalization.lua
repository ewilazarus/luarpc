local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: interface normalization')

local interfaceHandler = luarpc._interfaceHandler

local function parseValidateAndNormalize(file)
    return interfaceHandler:_normalize(interfaceHandler:_validate(interfaceHandler:_parse(file)))
end


local expectedNormalizedSpec = { name = 'minhaInt', methods = { foo = { resulttype = 'double', args = {} } } }

function test_canNormalizeMissingMethodArgs()
    lu.assertEquals(parseValidateAndNormalize('resources/missingargs1.ifile'), expectedNormalizedSpec)
end


lu.LuaUnit.run('--name', './tests/interface/normalization')
print('\n')
