-- Interps ExprCs --
function interp(exp, envi)
    if (isExprC(exp) == true) then
        if exp.type == "NumC" then
            return NumV(exp.n)
        elseif exp.type == "IdC" then
            return looup(exp.i, envi)
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
        end
    end
end

local function looup(id, env)
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

local function serialize(v)
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