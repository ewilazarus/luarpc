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
    lu.assertErrorMsgContains(errorMessages.ISPVAL01, parseAndValidate, 'resources/missingname.ifile')
    lu.assertErrorMsgContains(errorMessages.ISPVAL02, parseAndValidate, 'resources/wrongname.ifile')
end

function test_cantValidateFaultyMethods()
    lu.assertErrorMsgContains(errorMessages.ISPVAL03, parseAndValidate, 'resources/missingmethods1.ifile')
    lu.assertErrorMsgContains(errorMessages.ISPVAL05, parseAndValidate, 'resources/missingmethods2.ifile')
    lu.assertErrorMsgContains(errorMessages.ISPVAL04, parseAndValidate, 'resources/wrongmethods.ifile')
end

function test_cantValidateMethodWithFaultyResultType()
    lu.assertErrorMsgContains(errorMessages.ISPVAL06, parseAndValidate, 'resources/missingresulttype.ifile')
    lu.assertErrorMsgContains(errorMessages.ISPVAL07, parseAndValidate, 'resources/wrongresulttype1.ifile')
    lu.assertErrorMsgContains(errorMessages.ISPVAL08, parseAndValidate, 'resources/wrongresulttype2.ifile')
end

function test_canValidateMethodWithMissingArgs()
    lu.assertNotNil(parseAndValidate, 'resources/missingargs1.ifile')
    lu.assertNotNil(parseAndValidate, 'resources/missingargs2.ifile')
end

function test_cantValidateMethodWithFaultyArgs()
    lu.assertError(errorMessages.ISPVAL09, parseAndValidate, 'resources/wrongargs1.ifile')
    lu.assertError(errorMessages.ISPVAL10, parseAndValidate, 'resources/wrongargs2.ifile')
    lu.assertError(errorMessages.ISPVAL11, parseAndValidate, 'resources/wrongargs3.ifile')
    lu.assertError(errorMessages.ISPVAL12, parseAndValidate, 'resources/wrongargs4.ifile')
    lu.assertError(errorMessages.ISPVAL13, parseAndValidate, 'resources/wrongargs5.ifile')
    lu.assertError(errorMessages.ISPVAL14, parseAndValidate, 'resources/wrongargs6.ifile')
end


lu.LuaUnit.run('--name', './tests/validation')
