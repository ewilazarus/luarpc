local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: awaiter run')

local awaiter = luarpc._awaiter


local function f1(s1, s2)
    return s1 .. ' ' .. s2
end

function test_canRunMethod()
    local success, result = awaiter:_run(f1, {'boi', 'tata'})
    lu.assertTrue(success)
    lu.assertEquals(result, 'boi tata')
end

local function f2(s1, s2)
    return s1 .. ' ' .. s2, 1337
end

function test_canRunMethod2()
    local success, r1, r2 = awaiter:_run(f2, {'boi', 'tata'})
    lu.assertTrue(success)
    lu.assertEquals(r1, 'boi tata')
    lu.assertEquals(r2, 1337)
end

local function f3()
    return 'hello world'
end

function test_canRunMethod3()
    local success, r1 = awaiter:_run(f3, {})
    lu.assertTrue(success)
    lu.assertEquals(r1, 'hello world')
end

local function f4()
    error('an unexpected error')
end

function test_canRunMethod3()
    local success, r1 = awaiter:_run(f4, {})
    lu.assertFalse(success)
end


lu.LuaUnit.run('--name', './tests/awaiter/run')
print('\n')
