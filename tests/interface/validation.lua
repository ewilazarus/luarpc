local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: interface validation')

local interfaceHandler = luarpc._interfaceHandler

local function parseAndValidate(ifile)
    return interfaceHandler:_validate(interfaceHandler:_parse(ifile))
end


function test_canValidateGiven()
    lu.assertNotNil(parseAndValidate, 'resources/given.ifile')
end

function test_cantValidateFaultyName()
    lu.assertErrorMsgContains(errors.I02, parseAndValidate, 'resources/missingname.ifile')
    lu.assertErrorMsgContains(errors.I03, parseAndValidate, 'resources/wrongname.ifile')
end

function test_cantValidateFaultyMethods()
    lu.assertErrorMsgContains(errors.I04, parseAndValidate, 'resources/missingmethods1.ifile')
    lu.assertErrorMsgContains(errors.I06, parseAndValidate, 'resources/missingmethods2.ifile')
    lu.assertErrorMsgContains(errors.I05, parseAndValidate, 'resources/wrongmethods.ifile')
end

function test_cantValidateMethodWithFaultyResultType()
    lu.assertErrorMsgContains(errors.I07, parseAndValidate, 'resources/missingresulttype.ifile')
    lu.assertErrorMsgContains(errors.I08, parseAndValidate, 'resources/wrongresulttype1.ifile')
    lu.assertErrorMsgContains(errors.I09, parseAndValidate, 'resources/wrongresulttype2.ifile')
end

function test_canValidateMethodWithMissingArgs()
    lu.assertNotNil(parseAndValidate, 'resources/missingargs1.ifile')
    lu.assertNotNil(parseAndValidate, 'resources/missingargs2.ifile')
end

function test_cantValidateMethodWithFaultyArgs()
    lu.assertError(errors.I10, parseAndValidate, 'resources/wrongargs1.ifile')
    lu.assertError(errors.I11, parseAndValidate, 'resources/wrongargs2.ifile')
    lu.assertError(errors.I12, parseAndValidate, 'resources/wrongargs3.ifile')
    lu.assertError(errors.I13, parseAndValidate, 'resources/wrongargs4.ifile')
    lu.assertError(errors.I14, parseAndValidate, 'resources/wrongargs5.ifile')
    lu.assertError(errors.I15, parseAndValidate, 'resources/wrongargs6.ifile')
end


lu.LuaUnit.run('--name', './tests/interface/validation')
