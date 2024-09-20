local result = ""
local s = game.Players.LocalPlayer.PlayerScripts.LocalScript
local opcodes = {
    [0] = "MOVE",
    [1] = "LOADK",
    [2] = "LOADBOOL",
    [3] = "LOADNIL",
    [4] = "GETUPVAL",
    [5] = "GETGLOBAL",
    [6] = "GETTABLE",
    [7] = "SETGLOBAL",
    [8] = "SETUPVAL",
    [9] = "SETTABLE",
    [10] = "NEWTABLE",
    [11] = "SELF",
    [12] = "ADD",
    [13] = "SUB",
    [14] = "MUL",
    [15] = "DIV",
    [16] = "MOD",
    [17] = "POW",
    [18] = "UNM",
    [19] = "NOT",
    [20] = "LEN",
    [21] = "CONCAT",
    [22] = "JMP",
    [23] = "EQ",
    [24] = "LT",
    [25] = "LE",
    [26] = "TEST",
    [27] = "TESTSET",
    [28] = "CALL",
    [29] = "TAILCALL",
    [30] = "RETURN",
    [31] = "FORLOOP",
    [32] = "FORPREP",
    [33] = "TFORLOOP",
    [34] = "SETLIST",
    [35] = "CLOSE",
    [36] = "CLOSURE",
    [37] = "VARARG"
}

-- Corrected parseBytecode function
function parseBytecode(bytecode)
    local instructions = {}
    local i = 1
    while i <= #bytecode do
        local byte = string.byte(bytecode, i)
        local opc = opcodes[byte] -- Lookup the opcode based on byte value
        table.insert(instructions, {opcode = opc, byte = byte, line = i})
        i = i + 1 -- Increment to avoid infinite loop
    end
    return instructions
end

-- Main logic to process bytecode
local function processBytecode(bytecode)
    local instructions = parseBytecode(bytecode)

    for _, instr in ipairs(instructions) do
        local value = nil
        
        -- Assuming the next byte(s) after the opcode represent the value
        if instr.opcode then
            if instr.opcode == "LOADK" then
                value = string.byte(bytecode, instr.line + 1) -- Example for LOADK
            elseif instr.opcode == "LOADBOOL" then
                value = string.byte(bytecode, instr.line + 1) -- Example for LOADBOOL
            elseif instr.opcode == "JMP" then
                value = string.byte(bytecode, instr.line + 1) -- Example for JMP
            end
            -- Add more conditions here for other opcodes as needed
            
            if value then
                print("Opcode " .. instr.opcode .. " found at line " .. instr.line .. " with value: " .. value)
            else
                print("Opcode " .. instr.opcode .. " found at line " .. instr.line)
            end
        end
    end
end

-- Assuming getscriptbytecode returns the bytecode for the given script
local bytecode = getscriptbytecode(s)

-- Now process the bytecode
processBytecode(bytecode)
