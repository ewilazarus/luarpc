local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: parsing')

local expectedGivenISpecProspect = {
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
    local givenISpecProspect = luarpc:_parse('resources/given.ifile')
    lu.assertEquals(givenISpecProspect, expectedGivenISpecProspect)
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

function test_cantParseMaliciousSyntaxFile()
    lu.assertError(function()
        luarpc:_parse('resources/malicioussyntax.ifile')
    end)
end

lu.LuaUnit.run('--name', './tests/parsing')
