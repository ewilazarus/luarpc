local lu = require('luaunit')
local luarpc = require('luarpc')

local expectedGivenISpec = {
    name = 'minhaInt',
    methods = {
          foo = { resulttype = 'double',
          args = {
              { direction = 'in', type = 'double' },
              { direction = 'in', type = 'double' },
              { direction = 'out', type = 'string' },
          }},
          boo = { resulttype = 'void',
          args = {
              { direction = 'inout', type = 'double' },
          }}
        }
    }

function test_canParse()
    local givenISpec = luarpc:_parse('resources/given.ifile')
    lu.assertEquals(givenISpec, expectedGivenISpec)
end

function test_cantParseNonExistentFile()
    lu.assertError(function()
        luarpc:_parse('resources/nonexistent.ifile')
    end)
end

function test_cantParseEmptyFile()
    lu.assertError(function()
        luarpc:_parse('resources/empty.ifile')
    end)
end

function test_cantParseBadSyntaxFile()
    lu.assertError(function()
        luarpc:_parse('resources/badsyntax.ifile')
    end)
end

print(lu.LuaUnit.run('--name', './tests/parsing'))
