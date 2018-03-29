local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: interface parsing')

local interfaceHandler = luarpc._interfaceHandler

local expectedGivenSpecProspect = {
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
    local givenISpecProspect = interfaceHandler:_parse('resources/given.ifile')
    lu.assertEquals(givenISpecProspect, expectedGivenSpecProspect)
end

function test_cantParseNonExistentFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/nonexistent.ifile')
    end)
end

function test_cantParseEmptyFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/empty.ifile')
    end)
end

function test_cantParseBadSyntaxFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/badsyntax.ifile')
    end)
end

function test_cantParseMaliciousSyntaxFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/malicioussyntax.ifile')
    end)
end

lu.LuaUnit.run('--name', './tests/interface/parsing')
