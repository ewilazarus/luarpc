local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: normalization')

local expectedNormalizedISpec = { name = 'minhaInt', methods = { foo = { resulttype = 'double', args = {} } } }

local function parseValidateAndNormalize(ifile)
    return luarpc:_normalize(luarpc:_validate(luarpc:_parse(ifile)))
end


function test_canNormalizeMissingMethodArgs()
    lu.assertEquals(parseValidateAndNormalize('resources/missingargs1.ifile'), expectedNormalizedISpec)
end


lu.LuaUnit.run('--name', './tests/normalization')
