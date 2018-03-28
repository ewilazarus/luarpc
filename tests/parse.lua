local lu = require('luaunit')
local parse = require('parse')

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
    local givenISpec = parse('resources/given.ifile')
    lu.assertEquals(givenISpec, expectedGivenISpec)
end

function test_cantParseNonExistentFile()
    lu.assertError(parse, 'resource/nonexistent.ifile')
end

function test_cantParseEmptyFile()
    lu.assertError(parse, 'resource/empty.ifile')
end

function test_cantParseBadComposedFile()
    lu.assertError(parse, 'resource/badcomposed.ifile')
end

print(lu.LuaUnit.run('--name', './tests/parse'))
