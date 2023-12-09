local lu = require("luaunit")
local asgn9 = require("asgn9")

TestCalculator = {}

function TestCalculator:test_add()
    lu.assertEquals(asgn9.num_add({ NumV(2), NumV(1) }).n, 3)
end

os.exit(lu.LuaUnit.run())
