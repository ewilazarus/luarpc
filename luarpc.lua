--------------------
-- Error messages --
--------------------
errorMessages = {
    IFLPAR01 = 'The provided interface file is either missing or syntatically invalid',
    ISPVAL01 = 'The provided interface must define a "[name]" attribute',
    ISPVAL02 = 'The provided interface "[name]" value must be of type "string"',
    ISPVAL03 = 'The provided interface must define a "[methods]" attribute',
    ISPVAL04 = 'The provided interface "[methods]" value must be of type "table"',
    ISPVAL05 = 'The provided interface "[methods]" value must define at least one "[method]"',
    ISPVAL06 = 'The provided interface has a "[methods].[method]" without a "resulttype" attribute',
    ISPVAL07 = 'The provided interface has a "[methods].[method].[resulttype]" value that is not of type "string"',
    ISPVAL08 = 'The provided interface has a "[methods].[method].[resulttype]" value that is neither \'void\', \'char\', \'string\' nor \'double\'',
    ISPVAL09 = 'The provided interface has a "[methods].[method].[args].[arg]" value that does not define a "[direction]"',
    ISPVAL10 = 'The provided interface has a "[methods].[method].[args].[arg].[direction]" value that is not of type "string"',
    ISPVAL11 = 'The provided interface has a "[methods].[method].[args].[arg].[direction]" value that is neither \'in\', \'out\' nor \'inout\'',
    ISPVAL12 = 'The provided interface has a "[methods].[method].[args].[arg]" value that does not define a "[type]"',
    ISPVAL13 = 'The provided interface has a "[methods].[method].[args].[arg].[type]" value that is not of type "string"',
    ISPVAL14 = 'The provided interface has a "[methods].[method].[args].[arg].[type]" value that is neither \'char\', \'string\' nor \'double\'',
}

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


-- ifile parsing
local ispecProspectMemoizer

function interface(value)
    ispecProspectMemoizer = value
end

local function parse(ifile)
    ispecProspectMemoizer = nil
    dofile(ifile)
    assert(istable(ispecProspectMemoizer), errorMessages.IFLPAR01)
    return ispecProspectMemoizer
end


-- ispecProspect validation
local function validateName(ispecProspect)
    assert(ispecProspect.name, errorMessages.ISPVAL01)
    assert(isstring(ispecProspect.name), errorMessages.ISPVAL02)
end

local isvalidresulttype = hasvalue({'void', 'char', 'string', 'double'})

local function validateMethodResultType(method)
    assert(method.resulttype, errorMessages.ISPVAL06)
    assert(isstring(method.resulttype), errorMessages.ISPVAL07)
    assert(isvalidresulttype(method.resulttype), errorMessages.ISPVAL08)
end

local isvalidargdirection = hasvalue({'in', 'out', 'inout'})
local isvalidargtype = hasvalue({'char', 'string', 'double'})

local function validateMethodArg(arg)
    assert(arg.direction, errorMessages.ISPVAL09)
    assert(isstring(arg.direction), errorMessages.ISPVAL10)
    assert(isvalidargdirection(arg.direction), errorMessages.ISPVAL11)
    assert(arg.type, errorMessages.ISPVAL12)
    assert(isstring(arg.type), errorMessages.ISPVAL13)
    assert(isvalidargtype(arg.type), errorMessages.ISPVAL14)
end

local function validateMethodArgs(method)
    if method.args then
        for _, arg in pairs(method.args) do
            validateMethodArg(arg)
        end
    end
end

local function validateMethod(method)
    validateMethodResultType(method)
    validateMethodArgs(method)
end

local function validateMethods(ispecProspect)
    assert(ispecProspect.methods, errorMessages.ISPVAL03)
    assert(istable(ispecProspect.methods), errorMessages.ISPVAL04)
    local methodCount = 0
    for _, method in pairs(ispecProspect.methods) do
        validateMethod(method)
        methodCount = methodCount + 1
    end
    assert(methodCount > 0, errorMessages.ISPVAL05)
end


-- ispecProspect normalization
local function normalizeMissingMethodArgs(ispecProspect)
    for _, definition in pairs(ispecProspect.methods) do
        if definition.args == nil then
            definition.args = {}
        end
    end
end


--------------------------------- EXPOSED -------------------------------------
local LuaRPC = {}

-------------------------------
-- "Private" functionalities --
-------------------------------
function LuaRPC:_parse(ifile)
    return parse(ifile)
end

function LuaRPC:_validate(ispecProspect)
    validateName(ispecProspect)
    validateMethods(ispecProspect)
    return ispecProspect
end

function LuaRPC:_normalize(ispecProspect)
    normalizeMissingMethodArgs(ispecProspect)
    return ispecProspect
end

function LuaRPC:_consume(ifile)
    return self._normalize(self._validate(self._parse(ifile)))
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
