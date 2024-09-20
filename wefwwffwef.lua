local result = ""
local s = game.Players.LocalPlayer.PlayerScripts.LocalScript
local opcodes = {
    [22] = "JMP" -- Make sure to add more opcodes as necessary
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

-- Assuming getscriptbytecode returns the bytecode for the given script
local bytecode = getscriptbytecode(s)

-- Now process the bytecode
processBytecode(bytecode)
