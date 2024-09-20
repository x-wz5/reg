local result = ""
local s = game.Players.LocalPlayer.PlayerScripts.LocalScript
local opcodes = {
    [22] = "if"
}
function findIf(bytecode,Line)


    function parseBytecode(bytecode)
        local instructions = {}
        local i = 1
        while i < #bytecode do
            local byte = string.byte(bytecode,i)
            local opc = opcodes[byte]
            table.insert(instructions,{opcode = opc,byte = byte, line = i})
        end
        return instructions
    end
end
local instructions = parseBytecode(bytecode)

    -- Process instructions and track jumps
    for _, instr in ipairs(instructions) do
        if instr.opcode == "JMP" then
            -- Assuming the byte following JMP is the offset
            local jumpOffset = string.byte(bytecode, instr.line + 1)
            -- Calculate the target line for the jump
            local targetLine = instr.line + jumpOffset + 1 -- +1 to account for next instruction
            
            if jumpOffset < 0x80 then  -- Forward jump
                print("JMP at line " .. instr.line .. " jumps forward to line " .. targetLine)
            else  -- Backward jump (if negative)
                local negativeOffset = jumpOffset - 0x100
                targetLine = instr.line + negativeOffset + 1
                print("JMP at line " .. instr.line .. " jumps backward to line " .. targetLine)
            end
        end
    end
end

local bytecode = getscriptbytecodes(s)
print(findIf(bytecode, 1))
--[[
local function decompileFunction(f, seen,isProto)
    seen = seen or {}
    if seen[f] then return end
    seen[f] = true
    if isProto then
      result = result.."--This is a proto which means it is a function for a connection function.\n"
    end
    local protoSuccess, proto = pcall(getprotos, f)
    local constantSuccess, constants = pcall(getconstants, f)
    local upvalueSuccess, upvalues = pcall(getupvalues, f)

    if upvalueSuccess and upvalues then
        table.foreach(upvalues, function(key, value)
            result = result .. "local " .. tostring(key) .. " = " .. tostring(value) .. "\n"
        end)
    end

    if protoSuccess and proto then
        for key, value in pairs(proto) do
            decompileFunction(value, seen,true)
        end
    end

    if constantSuccess and constants then
      if isProto then
        result = result .. "function unk" .. tostring(getinfo(f).name) .. "()\n"
        else result = result .. "function " .. tostring(getinfo(f).name) .. "()\n"
      
      end
      
        for key, value in pairs(constants) do
            result = result .. "local v" .. tostring(key) .. " = " .. tostring(value) .. "\n"
        end
        local closure = newcclosure(function(...)
            local res = f(...)
            return tostring(res)
        end)
        result = result .. "return " .. closure() .. "\n"
        result = result .. "end\n"
        
    end
    return result
end

  local function decompileTable(tbl, seen)
    seen = seen or {}
    if seen[tbl] then return end
    seen[tbl] = true
    
    result = result .. "local t = {\n"
    table.foreach(tbl, function(key, value)
      result = result..tostring(key).." = "..tostring(value)
      if typeof(value) == "table" then
        result = result .. "local " .. tostring(key) .. " = {\n"
        decompileTable(value, seen)
        result = result .. "}\n"
      elseif typeof(value) == "function" then
        result = result .. "local " .. tostring(key) .. " = function()\n"
        decompileFunction(value, seen)
        result = result .. "end\n"
       end
    end)
    result = result .. "}\n"
    return result
  end

local function ReadAble(str)
    local nonUse = "local v%d* = function: 0x%x+"
    local nonUse2 = "local v%d* = table: 0x%x+"
    
    local InstancePattren = "(local v%d* = Instance)\n(local v%d* = new)\n(local v%d = (%a*))"
    local ConnectPattren = "(local v%d* = (MouseButton1Click))\n(local v%d* = Connect)"
    local EnumPattren = "local v%d* = Enum\nlocal v%d* = %a*\nlocal v%d* = %a*"

    local result = str:gsub(nonUse, "")
    result = result:gsub(nonUse2, "")
    result = result:gsub("\n%s*\n", "\n")
    result = result:gsub(EnumPattren, "")
    result = result:gsub(InstancePattren, function(FirstLine, SecondLine, ThirdLine, value)
        return "local v__" .. value .. "__v = Instance.new('" .. value .. "')"
    end)

    result = result:gsub(ConnectPattren, function(FirstLine, Method, SecondLine)
        return "local v__Connect__v = " .. Method .. ":Connect(function()\nend)"
    end)

    return result
end

print(decompileFunction(simpleFunction))
setclipboard(ReadAble(decompileFunction(s)))






]]
