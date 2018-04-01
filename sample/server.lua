local luarpc = require('luarpc')

local def = {
    add = function(a, b)
        return a + b
    end,
    multiply = function(a, b)
        return a * b
    end,
    divide = function(a, b)
        return a / b
    end,
    subtract = function(a, b)
        return a - b
    end,
    magic = function(a, b)
        return 'here you go!', a + b, a * b, a / b, a -b
    end
}

local madDef = {
    add = function(a, b)
        return a - b
    end,
    multiply = function(a, b)
        return a / b
    end,
    divide = function(a, b)
        return a * b
    end,
    subtract = function(a, b)
        return a + b
    end,
    magic = function(a, b)
        return 'here you go! MWAHMWAHMWAH', a - b, a / b, a * b, a + b
    end
}

luarpc._createServant(def, 'sample/calculator.idl', '8000')
luarpc._createServant(def, 'sample/calculator.idl', '8001')
luarpc._createServant(madDef, 'sample/calculator.idl', '8002')
luarpc.waitIncoming()
