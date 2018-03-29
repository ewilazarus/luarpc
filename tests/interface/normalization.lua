local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: interface normalization')

local interfaceHandler = luarpc._interfaceHandler

local expectedNormalizedISpec = { name = 'minhaInt', methods = { foo = { resulttype = 'double', args = {} } } }

local function parseValidateAndNormalize(file)
    return interfaceHandler:_normalize(interfaceHandler:_validate(interfaceHandler:_parse(file)))
end


function test_canNormalizeMissingMethodArgs()
    lu.assertEquals(parseValidateAndNormalize('resources/missingargs1.ifile'), expectedNormalizedISpec)
end


lu.LuaUnit.run('--name', './tests/interface/normalization')
