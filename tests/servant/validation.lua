local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: servant validation')

local interfaceHandler = luarpc._interfaceHandler
local servantBuilder = luarpc._servantPool._builder

local function consumeAndValidate(def, file)
    return servantBuilder:validate(def, interfaceHandler:consume(file))
end


local givenDef = {
    foo = function(a, b, s) return a+b, 'alo alo' end,
    boo = function(n) return n end
}

function test_canValidateGiven()
    lu.assertTrue(consumeAndValidate(givenDef, 'resources/given.ifile'))
end

local missingMethodDef = {
    foo = function(a, b, s) return a+b, 'alo alo' end
}

function test_cantValidateMissingMethod()
    lu.assertErrorMsgContains(errors.S01, consumeAndValidate, missingMethodDef, 'resources/given.ifile')
end

local wrongMethodNameDef = {
    foo = function(a, b, s) return a+b, 'alo alo' end,
    baz = function(n) return n end
}

function test_cantValidateWrongMethodName()
    lu.assertErrorMsgContains(errors.S01, consumeAndValidate, wrongMethodNameDef, 'resources/given.ifile')
end

local nonFunctionMemberDef = {
    foo = function(a, b, s) return a+b, 'alo alo' end,
    boo = 'tchau tchau'
}

function test_cantValidateNonFunctionMember()
    lu.assertErrorMsgContains(errors.S02, consumeAndValidate, nonFunctionMemberDef, 'resources/given.ifile')
end


lu.LuaUnit.run('--name', './tests/servant/validation')
print('\n')
