local ispec

function interface(table)
    ispec = table
end

local function parse(ifile)
    dofile(ifile)
    return ispec
end

return parse
