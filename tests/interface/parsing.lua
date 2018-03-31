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
    local givenISpecProspect = interfaceHandler:_parse('resources/given.idl')
    lu.assertEquals(givenISpecProspect, expectedGivenSpecProspect)
end

function test_cantParseNonExistentFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/nonexistent.idl')
    end)
end

function test_cantParseEmptyFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/empty.idl')
    end)
end

function test_cantParseBadSyntaxFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/badsyntax.idl')
    end)
end

function test_cantParseMaliciousSyntaxFile()
    lu.assertError(function()
        interfaceHandler:_parse('resources/malicioussyntax.idl')
    end)
end

lu.LuaUnit.run('--name', './tests/interface/parsing')
print('\n')
