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

function BlamC(args, body)
    return { type = "BlamC", args = args, body = body }
end

function AppC(func, args)
    return { type = "AppC", func = func, args = args }
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

-- Binding
function Binding(name, val)
    if type(name) ~= "string" then
        print(name)
        print(type(name))
        error("Binding: Name must be a string")
    end

    if type(val) == "table" and type(val.type) ~= "string" then
        error("Binding: Val must be a Value")
    end
    top_env[name] = val
    -- return { name = name, val = val }
end

-- top env
top_env = {
    ['+'] = PrimV(num_add),
    ['-'] = PrimV(num_sub),
    ['*'] = PrimV(num_mult),
    ['/'] = PrimV(num_div),
    ['<='] = PrimV(num_less_than_equal),
    ['equal?'] = PrimV(equal),
    ['true'] = BoolV(true),
    ['false'] = BoolV(false)
    -- Binding('+', PrimV(num_add)),
    -- Binding('-', PrimV(num_sub)),
    -- Binding('*', PrimV(num_mult)),
    -- Binding('/', PrimV(num_div)),
    -- Binding('<=', PrimV(num_less_than_equal)),
    -- Binding('equal?', PrimV(equal)),
    -- Binding('true', BoolV(true)),
    -- Binding('false', BoolV(false))
}

-- serialize accepts any PAIG5 value and return a string
-- function serialize(v)
--     if v.type == "NumV" then
--         return tostring(v.n)
--     elseif v.type == "BoolV" then
--         return v.b and "true" or "false"
--     elseif v.type == "StrV" then
--         return tostring(v.s)
--     elseif v.type == "CloV" then
--         return "#<procedure>"
--     elseif v.type == "PrimV" then
--         return "#<primop>"
--     else
--         error("serialize: unrecognized value type")
--     end
-- end

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
    if expr.type == "BlamC" then
        accumulator = accumulator ..
            "BlamC(" .. table.concat(expr.args, ", ") .. ")" .. " "
    end
    return accumulator
end

-- Returns a string representation of an input expr.
function exprToString(expr)
    return helper(expr, "")
end

-- checks if its a valid id
function valid_id(s)
    local invalid_ids = { 'as', 'with', 'blam', '?', 'else:' }

    for i = 1, #invalid_ids do
        if s == invalid_ids[i] then
            return false
        end
    end

    return true
end

-- removes duplicates from list
function remove_duplicates(tbl)
    local seen = {}
    local result = {}

    for i = 1, #tbl do
        local value = tbl[i]
        if not seen[value] then
            table.insert(result, value)
            seen[value] = true
        end
    end

    return result
end

function printArray(arr)
    io.write("{ ")
    for i, v in ipairs(arr) do
        io.write(v)
        if i < #arr then
            io.write(", ")
        end
    end
    io.write(" }\n")
end

-- parse
function parse(s)
    if type(s) == "number" then
        return { type = "NumC", n = s }
    elseif type(s) == "string" then
        if valid_id(s) then
            return { type = "IdC", i = s }
        else
            return { type = "StrC", s = s }
        end
    elseif type(s) == "table" and #s > 0 then
        if s[2] == "?" then
            local statement = s[1]
            local tru = s[3]
            local fals = s[5]

            return { type = "IfC", statement = parse(statement), tru = parse(tru), fals = parse(fals) }
        elseif s[1] == "blam" then
            local args = s[2]
            local body = s[3]

            local parsedBody = {}
            for _, element in ipairs(body) do
                table.insert(parsedBody, parse(element))
                print(exprToString(parse(element)))
            end


            if #args == #remove_duplicates(args) then
                return { type = "BlamC", args = args, body = parsedBody }
            else
                error("parse: Duplicates in args")
            end
        end
    end
end


-- Interps ExprCs --
function interp(exp, envi)
    if (isExprC(exp) == true) then
        if exp.type == "NumC" then
            return NumV(exp.n)
        elseif exp.type == "IdC" then
            return lookup(exp.i, envi)
        elseif exp.type == "StrC" then
            return StrV(exp.s)
        elseif exp.type == "IfC" then
            local temp = interp(exp.statement, envi)
            if temp.type == "BoolV" then
                if temp.b then
                    return interp(exp.tru, envi)
                end
                return interp(exp.fals, envi)
            else
                print("If-statement does not result in boolean value")
                return nil
            end
        elseif exp.type == "BlamC" then
            return CloV(exp.args, exp.body, envi)
        elseif exp.type == "AppC" then
            local func = interp(exp.func, envi)
            if func ~= nil and func.type == "CloV" then
                if #func.args ~= #exp.args then
                    print("AppC: number of arguments does not match number of parameters")
                    return nil
                end

                -- extend envi
                local append_envi = {}
                for i = 1, #exp.args do
                    -- append_envi[i] = Binding(func.args[i], interp(exp.args[i], envi))
                    append_envi[func.args[i].i] = interp(exp.args[i], envi)
                end

                -- append extended envi to original envi
                local new_envi = {}
                for k, v in pairs(envi) do
                    new_envi[k] = v
                end
                for k, v in pairs(append_envi) do
                    new_envi[k] = v
                end
                return interp(func.body, new_envi)
            elseif func ~= nil and func.type == "PrimV" then
                local args_val = {}
                for i = 1, #exp.args do
                    args_val[i] = interp(exp.args[i], envi)
                end

                if func.primop == "+" then
                    return NumV(args_val[1].n + args_val[2].n)
                elseif func.primop == "-" then
                    return NumV(args_val[1].n - args_val[2].n)
                elseif func.primop == "*" then
                    return NumV(args_val[1].n * args_val[2].n)
                elseif func.primop == "/" then
                    return NumV(args_val[1].n / args_val[2].n)
                elseif func.primop == "<=" then
                    return BoolV(args_val[1].n <= args_val[2].n)
                elseif func.primop == "equal?" then
                    return BoolV(args_val[1].n == args_val[2].n)
                elseif func.primop == "true" then
                    return BoolV(true)
                elseif func.primop == "false" then
                    return BoolV(false)
                else
                    print("AppC: func is not a function")
                    return nil
                end
            else
                print("Invalid expression type")
                return nil
            end
        else
            print("Invalid expression type")
            return nil

        end
    end
end


local function lookup(id, env)
    if (id.type ~= "string") then
        print("invalid id variable name")
        return nil
    end
    if (env.type ~= "Env") then
        print("invalid environment for lookup")
        return nil
    end
    if env[id] then
        return env[id]
    else
        print("invalid id, unable to lookup")
        return nil
    end
end

function serialize(v)
    if v.type == "NumV" then
        return tostring(v.n)
    elseif v.type == "BoolV" then
        if v.b then
            return "true"
        end
        return "false"
    elseif v.type == "StrV" then
        return v.s
    elseif v.type == "CloV" then
        return "#<procedure>"
    elseif v.type == "PrimV" then
        return "#<primop>"
    end
end

-- serialize(interp(NumC(9), top_env))

-- TEST CASES --
print(num_add({ NumV(2), NumV(1) }).n)
print(num_sub({ NumV(2), NumV(1) }).n)
print(num_mult({ NumV(2), NumV(5) }).n)
print(num_div({ NumV(6), NumV(2) }).n)
print(num_less_than_equal({ NumV(1), NumV(2) }).b)
print(num_less_than_equal({ NumV(2), NumV(1) }).b)
print(equal({ StrV("hi"), NumV(1) }).b)
print(equal({ StrV("hi"), StrV("hi") }).b)
print(serialize(StrV("hi")))
print(serialize(NumV(3)))
print(serialize(CloV(args, body, env)))
print(serialize(CloV(args, body, env)))
print(exprToString(parse(1)))
print(exprToString(parse(1)))
print(exprToString(parse({ 1, '?', 2, 'else:', 3 })))
print(exprToString(parse({ "blam", { "x", "y" }, { "+", "x", "y" } })))


blam_call = AppC(BlamC({IdC("x")}, AppC(IdC("+"), { IdC("x"), NumC(1) })), {NumC(2)})
print("Expecting 3. Got:")
print(serialize(interp(blam_call)))

serialize_test1 = NumV(9)
print("Expecting 9. Got:")
serialize(serialize_test1)

serialize_test2 = CloV({IdC("x"), AppC(IdC("+"), { IdC("x"), NumC(1)})}, {NumC(2)})
print("Expecting #<procedure>. Got:")
serialize(serialize_test2)

