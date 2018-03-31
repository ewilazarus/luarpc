local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: interface validation')

local interfaceHandler = luarpc._interfaceHandler

local function parseAndValidate(file)
    return interfaceHandler:_validate(interfaceHandler:_parse(file))
end


function test_canValidateGiven()
    lu.assertNotNil(parseAndValidate, 'resources/given.idl')
end

function test_cantValidateFaultyName()
    lu.assertErrorMsgContains(errors.I02, parseAndValidate, 'resources/missingname.idl')
    lu.assertErrorMsgContains(errors.I03, parseAndValidate, 'resources/wrongname.idl')
end

function test_cantValidateFaultyMethods()
    lu.assertErrorMsgContains(errors.I04, parseAndValidate, 'resources/missingmethods1.idl')
    lu.assertErrorMsgContains(errors.I06, parseAndValidate, 'resources/missingmethods2.idl')
    lu.assertErrorMsgContains(errors.I05, parseAndValidate, 'resources/wrongmethods.idl')
end

function test_cantValidateMethodWithFaultyResultType()
    lu.assertErrorMsgContains(errors.I07, parseAndValidate, 'resources/missingresulttype.idl')
    lu.assertErrorMsgContains(errors.I08, parseAndValidate, 'resources/wrongresulttype1.idl')
    lu.assertErrorMsgContains(errors.I09, parseAndValidate, 'resources/wrongresulttype2.idl')
end

function test_canValidateMethodWithMissingArgs()
    lu.assertNotNil(parseAndValidate, 'resources/missingargs1.idl')
    lu.assertNotNil(parseAndValidate, 'resources/missingargs2.idl')
end

function test_cantValidateMethodWithFaultyArgs()
    lu.assertError(errors.I10, parseAndValidate, 'resources/wrongargs1.idl')
    lu.assertError(errors.I11, parseAndValidate, 'resources/wrongargs2.idl')
    lu.assertError(errors.I12, parseAndValidate, 'resources/wrongargs3.idl')
    lu.assertError(errors.I13, parseAndValidate, 'resources/wrongargs4.idl')
    lu.assertError(errors.I14, parseAndValidate, 'resources/wrongargs5.idl')
    lu.assertError(errors.I15, parseAndValidate, 'resources/wrongargs6.idl')
end


lu.LuaUnit.run('--name', './tests/interface/validation')
print('\n')
