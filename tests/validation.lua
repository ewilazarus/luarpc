local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: validation')

local function parseAndValidate(ifile)
    return luarpc:_validate(luarpc:_parse(ifile))
end


function test_canValidateGiven()
    lu.assertNotNil(parseAndValidate, 'resources/given.ifile')
end

function test_cantValidateFaultyName()
    lu.assertError(parseAndValidate, 'resources/missingname.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongname.ifile')
end

function test_cantValidateFaultyMethods()
    lu.assertError(parseAndValidate, 'resources/missingmethods1.ifile')
    lu.assertError(parseAndValidate, 'resources/missingmethods2.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongmethods.ifile')
end

function test_cantValidateMethodWithFaultyResultType()
    lu.assertError(parseAndValidate, 'resources/missingresulttype.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongresulttype1.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongresulttype2.ifile')
end

function test_canValidateMethodWithMissingArgs()
    lu.assertNotNil(parseAndValidate, 'resources/missingargs1.ifile')
    lu.assertNotNil(parseAndValidate, 'resources/missingargs2.ifile')
end

function test_cantValidateMethodWithFaultyArgs()
    lu.assertError(parseAndValidate, 'resources/wrongargs1.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongargs2.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongargs3.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongargs4.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongargs5.ifile')
    lu.assertError(parseAndValidate, 'resources/wrongargs6.ifile')
end


lu.LuaUnit.run('--name', './tests/validation')
