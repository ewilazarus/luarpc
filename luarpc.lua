-------------
-- Helpers --
-------------

-- Parsing
local ispecProspectMemoizer

function interface(value)
    ispecProspectMemoizer = value
end

local function istable(ispecProspect)
    return type(ispecProspect) == 'table'
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
