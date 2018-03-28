-------------
-- Helpers --
-------------

-- Parsing
local ispecMemoizer
function interface(table)
    ispecMemoizer = table
end

--------------------------------- EXPOSED -------------------------------------
local LuaRPC = {}

-------------------------------
-- "Private" functionalities --
-------------------------------
function LuaRPC:_parse(ifile)
    dofile(ifile)
    return ispecMemoizer
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
