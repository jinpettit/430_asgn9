-- ExprC creation functions --
function NumC(n)
    if type(n) ~= "number" then
        print("NumC requires input to be a number to be initialized.")
        return nil
    end
    return { ["type"] = "NumC", ["n"] = n }
end

function StrC(s)
    if type(s) ~= "string" then
        print("StrC requires input to be a string to be initialized.")
        return nil
    end
    return { ["type"] = "StrC", ["s"] = s }
end

function IdC(i)
    if type(i) ~= "string" then
        print("IdC requires input to be a string to be initialized.")
        return nil
    end
    return { ["type"] = "IdC", ["i"] = i }
end

function IfC(statement, tru, fals)
    if (not (isExprC(statement) and isExprC(tru) and isExprC(fals))) then
        print("IfC received invalid inputs. (must be exprc's)")
        return nil
    end
    return { ["type"] = "IfC", ["statement"] = statement, ["tru"] = tru, ["fals"] = fals }
end

-- Binding
function Binding(name, val)
    function Binding(name, val)
        if type(name) ~= "string" then
            error("Binding: Name must be a string")
        end

        if type(val) == "table" and type(val.type) ~= "string" then
            error("Binding: Val must be a Value")
        end

        return { name = name, val = val }
    end
end

-- Values
Value = { NumV, BoolV, StrV, CloV, PrimV }

function NumV(n)
    return { type = "NumV", n = n }
end

function BoolV(b)
    return { type = "BoolV", b = b }
end

function StrV(s)
    return { type = "StrV", s = s }
end

function CloV(args, body, env)
    return { type = "CloV", args = args, body = body, env = env }
end

function PrimV(val)
    return { type = "PrimV", val = val }
end

-- adding two num values together
function num_add(args)
    if #args == 2 then
        local a = args[1]
        local b = args[2]

        if a.type == "NumV" and b.type == "NumV" then
            return NumV(a.n + b.n)
        else
            error('num+ PAIG: one argument was not a number')
        end
    else
        error('num+ PAIG: expected exactly 2 arguments')
    end
end

-- subtracting two num values together
function num_sub(args)
    if #args == 2 then
        local a = args[1]
        local b = args[2]

        if a.type == "NumV" and b.type == "NumV" then
            return NumV(a.n - b.n)
        else
            error('num+ PAIG: one argument was not a number')
        end
    else
        error('num+ PAIG: expected exactly 2 arguments')
    end
end

-- multiplying two num values together
function num_mult(args)
    if #args == 2 then
        local a = args[1]
        local b = args[2]

        if a.type == "NumV" and b.type == "NumV" then
            return NumV(a.n * b.n)
        else
            error('num+ PAIG: one argument was not a number')
        end
    else
        error('num+ PAIG: expected exactly 2 arguments')
    end
end

-- dividing two num values together
function num_div(args)
    if #args == 2 then
        local a = args[1]
        local b = args[2]

        if a.type == "NumV" and b.type == "NumV" then
            if b.n == 0 then
                error('num/ PAIG: divide by zero')
            else
                return NumV(a.n / b.n)
            end
        else
            error('num/ PAIG: one argument was not a number')
        end
    else
        error('num/ PAIG: expected exactly 2 arguments')
    end
end

-- checking if one value less than or equal to second
function num_less_than_equal(args)
    if #args == 2 then
        local left = args[1]
        local right = args[2]

        if left.type == "NumV" and right.type == "NumV" then
            return BoolV(left.n <= right.n)
        else
            error('num<= PAIG: one argument was not a number')
        end
    else
        error('num<= PAIG: expected exactly 2 arguments')
    end
end

-- comparator - checking if two values the same
-- equal function
function equal(args)
    if #args == 2 then
        local left = args[1]
        local right = args[2]

        if left.type == "NumV" and right.type == "NumV" then
            return BoolV(left.n == right.n)
        elseif left.type == "StrV" and right.type == "StrV" then
            return BoolV(left.s == right.s)
        elseif left.type == "BoolV" and right.type == "BoolV" then
            return BoolV(left.b == right.b)
        else
            return BoolV(false)
        end
    else
        error('equal PAIG: more than 2 args')
    end
end

-- top env
top_env = {
    Binding('+', PrimV(num_add)),
    Binding('-', PrimV(num_sub)),
    Binding('*', PrimV(num_mult)),
    Binding('/', PrimV(num_div)),
    Binding('<=', PrimV(num_less_than_equal)),
    Binding('equal?', PrimV(equal)),
    Binding('true', BoolV(true)),
    Binding('false', BoolV(false))
}

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

print(num_add({ NumV(2), NumV(1) }).n)
print(num_sub({ NumV(2), NumV(1) }).n)
print(num_mult({ NumV(2), NumV(5) }).n)
print(num_div({ NumV(6), NumV(2) }).n)
print(num_less_than_equal({ NumV(1), NumV(2) }).b)
print(num_less_than_equal({ NumV(2), NumV(1) }).b)
print(equal({ StrV("hi"), NumV(1) }).b)
print(equal({ StrV("hi"), StrV("hi") }).b)
