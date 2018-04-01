local luarpc = require('luarpc')

calculatorProxy = luarpc.createProxy('127.0.0.1', '8000', 'sample/calculator.idl')
madCalculatorProxy = luarpc.createProxy('127.0.0.1', '8001', 'sample/calculator.idl')

print('\n -> A global variable "calculatorProxy" was created.')
print(' -> Go ahead and type "calculatorProxy:add(1, 2)" on your Lua REPL.')
print(' -> To see all possibilities for this proxy, check out the "sample/calculator.idl" file.\n')
print(' DISCLAIMER: The "sample/server.lua" script must be running prior to the execution of')
print('             this script in order for the simulation to work.\n')
