local lu = require('luaunit')
local luarpc = require('luarpc')

print('TEST: interface metadata')

local interfaceHandler = luarpc._interfaceHandler

local function parseValidateNormalizeAndAddMetadata(file)
    return interfaceHandler:_addMetadata(interfaceHandler:_normalize(interfaceHandler:_validate(interfaceHandler:_parse(file))))
end


local expectedGivenSpecProspect = {
    name = 'minhaInt',
    methods = {
          foo = { resulttype = 'double',
          args = {
              { direction = 'in', type = 'double' },
              { direction = 'in', type = 'double' },
              { direction = 'out', type = 'string' },
          },
          _meta = {
              inTypes = {'double', 'double'},
              outTypes = {'double', 'string'}
          }},
          boo = { resulttype = 'void',
          args = {
              { direction = 'inout', type = 'double' },
          },
          _meta = {
              inTypes = {'double'},
              outTypes = {'double'}
          }},
          baz = { resulttype = 'void',
          args = {
              { direction = 'out', type = 'string' },
          },
          _meta = { inTypes = {} , outTypes = {'string'}}
          },
          bar = { resulttype = 'void', args = {},
          _meta = { inTypes = {}, outTypes = {} }
          }}}

function test_canAddMetadata()
    lu.assertEquals(parseValidateNormalizeAndAddMetadata('resources/meta.ifile'), expectedGivenSpecProspect)
end


lu.LuaUnit.run('--name', './tests/interface/metadata')