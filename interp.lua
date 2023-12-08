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
        elseif exp.type == "BlamC" then
            return CloV(exp.args, exp.body, envi)

            
        elseif exp.type == "AppC" then
            local func = interp(exp.func, envi)
            if func.type == "CloV" then
                if #func.args ~= #exp.args then
                    print("AppC: number of arguments does not match number of parameters")
                    return nil
                end

                -- extend envi
                local append_envi = {}
                for i = 1, #exp.args do
                    append_envi[i] = Binding(func.args[i], interp(exp.args[i], envi))
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
                
            elseif func.type == "PrimV" then
                local args = {}
                for i = 1, #exp.args do
                    args[i] = interp(exp.args[i], envi)
                end
                return func.p(args)
            else
                print("AppC: func is not a function")
                return nil
            end
        else
            print("Invalid expression type")
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