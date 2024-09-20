local result = ""
local t = 1

local function simpleFunction()
    local button = Instance.new("TextButton")
    button.Parent = script.Parent
    button.Text = "Click Me"
    local t = {
      Money = 100,
      Level = 900
    }
    local h = function()
        local i = "Test"
        i = "Test2"
        print(i)
    end

    if button.Text ~= "Click Me" then
        return false
    end

    button.MouseButton1Click:Connect(h)
    return "Fuck"
end
function fromHex(str)
	return (str:gsub('..', function (cc)
		return string.char(tonumber(cc, 16))
	end))
end

function toHex(str)
	return (str:gsub('.', function (c)
		return string.format('%02X', string.byte(c))
	end))
end
local function disassembly(hex)
  local opcodes = {
        [0] = "MOVE", [1] = "LOADK", [2] = "LOADBOOL", [3] = "LOADNIL",
        [4] = "GETUPVAL", [5] = "GETGLOBAL", [6] = "GETTABLE", [7] = "SETGLOBAL",
        [8] = "SETUPVAL", [9] = "SETTABLE", [10] = "NEWTABLE", [11] = "SELF",
        [12] = "ADD", [13] = "SUB", [14] = "MUL", [15] = "DIV", [16] = "MOD",
        [17] = "POW", [18] = "UNM", [19] = "NOT", [20] = "LEN", [21] = "CONCAT",
        [22] = "JMP", [23] = "EQ", [24] = "LT", [25] = "LE", [26] = "TEST",
        [27] = "TESTSET", [28] = "CALL", [29] = "TAILCALL", [30] = "RETURN",
        [31] = "FORLOOP", [32] = "FORPREP", [33] = "TFORLOOP", [34] = "SETLIST",
        [35] = "CLOSE", [36] = "CLOSURE", [37] = "VARARG"
    }
    
end
local function opCode(byte)
  return disassembly[byte] or "UNK"
end
local function bytecodeToassembly(bytecode)
  local i = 1
  local res = ""
  while i < #bytecode do
    i = i + 1
    local byte = string.byte(bytecode,i)
    local opc = opCode(byte)
    res = res..string.format("%02X %s\n",byte,opc)
    return res
  end
  return bytecodeToassembly(bytecode)
end






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
setclipboard(ReadAble(decompileFunction(simpleFunction)))






