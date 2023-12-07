
-- ExprC creation functions --
function NumC (n)
    if type(n) ~= "number" then
        print("NumC requires input to be a number to be initialized.")
        return nil
    end
    return {["type"] = "NumC", ["n"] = n}
end

function StrC (s)
    if type(s) ~= "string" then
        print("StrC requires input to be a string to be initialized.")
        return nil
    end
    return {["type"] = "StrC", ["s"] = s}
end

function IdC (i)
    if type(i) ~= "string" then
        print("IdC requires input to be a string to be initialized.")
        return nil
    end
    return {["type"] = "IdC", ["i"] = i}
end

function IfC (statement, tru, fals)
    if (not (isExprC(statement) and isExprC(tru) and isExprC(fals))) then
        print("IfC received invalid inputs. (must be exprc's)")
        return nil
    end
    return {["type"] = "IfC", ["statement"] = statement, ["tru"] = tru, ["fals"] = fals}
end



-- Returns true if input is an ExprC
function isExprC(expr)
    if expr == nil then
        return false
    end
    local type = expr.type --eventually validate types. ie make sure type is of NumC, StrC... etc
    if type then
        return true
    end
    return false
end

-- helper function to exprToString
local function helper(expr, accumulator)
    if not isExprC(expr) then
        print("printExpr requires an expr as input.")
        return nil
    end
    if accumulator == nil then
        accumulator = ""
    end
    if expr.type == "StrC" then
        accumulator = accumulator .. "StrC('" .. expr.s .. "')"
    end
    if expr.type == "NumC" then
        accumulator = accumulator .. "NumC('" .. expr.n .. "')"
    end
    if expr.type == "IdC" then
        accumulator = accumulator .. "IdC('" .. expr.i .. ")"
    end
    if expr.type == "IfC" then
        accumulator = accumulator .. "IfC(" .. helper(expr.statement) .. " " .. helper(expr.tru)
            .. " " .. helper(expr.fals) .. ")"
    end
    return accumulator
end

-- Returns a string representation of an input expr.
function exprToString(expr)
    return helper(expr, "")
end

