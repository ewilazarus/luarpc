-------------
-- Helpers --
-------------
local function istype(t)
    return function(value)
        return type(value) == t
    end
end

local istable = istype('table')
local isstring = istype('string')

local function hasvalue(array)
    return function(value)
        for _, v in pairs(array) do
            if v == value then
                return true
            end
        end
        return false
    end
end


-- Parsing
local ispecProspectMemoizer

function interface(value)
    ispecProspectMemoizer = value
end


-- Validation
local function validateName(ispecProspect)
    assert(ispecProspect.name, 'The provided interface must have a name')
    assert(isstring(ispecProspect.name), 'The provided interface name must be a string')
end

local isvalidresulttype = hasvalue({'void', 'char', 'string', 'double'})

local function validateMethodResultType(ispecProspectMethod, ispecProspectMethodDefinition)
    assert(ispecProspectMethodDefinition.resulttype, 'The method "' .. ispecProspectMethod .. '" has no resulttype defined')
    assert(isstring(ispecProspectMethodDefinition.resulttype), 'The resulttype of the method "' .. ispecProspectMethod .. '" must be specified as a string')
    assert(isvalidresulttype(ispecProspectMethodDefinition.resulttype), 'The resulttype of the method "' .. ispecProspectMethod .. '" must be either void, char, stirng or double')
end

local isvalidargdirection = hasvalue({'in', 'out', 'inout'})
local isvalidargtype = hasvalue({'char', 'string', 'double'})

local function validateMethodArg(ispecProspectMethod, ispecProspectMethodDefinitionArg)
    assert(ispecProspectMethodDefinitionArg.direction, 'The method "' .. ispecProspectMethod .. '" has defined an arg without direction')
    assert(isstring(ispecProspectMethodDefinitionArg.direction), 'An arg direction of the method "' .. ispecProspectMethod .. '" must be specified as a string')
    assert(isvalidargdirection(ispecProspectMethodDefinitionArg.direction), 'An arg direction of the method "' .. ispecProspectMethod .. '" must be either in, out or inout')
    assert(ispecProspectMethodDefinitionArg.type, 'The method "' .. ispecProspectMethod .. '" has defined an arg without type')
    assert(isstring(ispecProspectMethodDefinitionArg.type), 'An arg type of the method "' .. ispecProspectMethod .. '" must be specified as a string')
    assert(isvalidargtype(ispecProspectMethodDefinitionArg.type), 'An arg type of the method "' .. ispecProspectMethod .. '" must be either char, string or double')
end

local function validateMethodArgs(ispecProspectMethod, ispecProspectMethodDefinition)
    if ispecProspectMethodDefinition.args then
        for _, arg in pairs(ispecProspectMethodDefinition.args) do
            validateMethodArg(ispecProspectMethod, arg)
        end
    end
end

local function validateMethod(ispecProspectMethod, ispecProspectMethodDefinition)
    validateMethodResultType(ispecProspectMethod, ispecProspectMethodDefinition)
    validateMethodArgs(ispecProspectMethod, ispecProspectMethodDefinition)
end

local function validateMethods(ispecProspect)
    assert(ispecProspect.methods, 'The provided intereface must have the "methods" attribute')
    assert(istable(ispecProspect.methods), 'The provided intereface methods must be a table')
    local methodCount = 0
    for method, definition in pairs(ispecProspect.methods) do
        validateMethod(method, definition)
        methodCount = methodCount + 1
    end
    assert(methodCount > 0, 'The provided interface methods must have at least one definition')
end

--------------------------------- EXPOSED -------------------------------------
local LuaRPC = {}

-------------------------------
-- "Private" functionalities --
-------------------------------
function LuaRPC:_parse(ifile)
    ispecProspectMemoizer = nil
    dofile(ifile)
    assert(istable(ispecProspectMemoizer),
    'The file "' .. ifile .. '" is either missing or syntatically invalid')
    return ispecProspectMemoizer
end

function LuaRPC:_validate(ispecProspect)
    validateName(ispecProspect)
    validateMethods(ispecProspect)
    return ispecProspect
end

------------------------------
-- "Public" functionalities --
------------------------------
function LuaRPC:createProxy(ip, port, ifile)
    -- TODO: Implement
end

function LuaRPC:createServant(idef, ifile)
    -- TODO: Implement
end

function LuaRPC:waitIncoming()
    -- TODO: Implement
end

return LuaRPC
