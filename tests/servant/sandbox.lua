local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: servant sandbox')

local interfaceHandler = luarpc._interfaceHandler
local sandbox = luarpc._servantPool._builder._sandbox

local function run(method, meta)
    return sandbox:run(method, meta)
end


local function ok(int)
    return 'int'
end

function test_canRun()
    lu.assertTrue(run(ok, {inTypes = {'double'}, outTypes = {'string'}}))
end

local function wrongReturnCount()
    return 1, 2
end

function test_cantValidateWrongReturnCount()
    lu.assertErrorMsgContains(errors.S03, run, wrongReturnCount, {inTypes = {}, outTypes = {'double'}})
end

local function wrongReturnType()
    return 'hello'
end

function test_cantValidateWrongReturnType()
    lu.assertErrorMsgContains(errors.S04, run, wrongReturnType, {inTypes = {}, outTypes = {'double'}})
end

local function throwsError()
    return error('An error')
end

function test_canValidatePossiblyErrorReturn()
    lu.assertTrue(run(throwsError, {inTypes = {}, outTypes = {'double'}}))
end


lu.LuaUnit.run('--name', './tests/servant/sandbox')
print('\n')
