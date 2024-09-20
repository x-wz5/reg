local result = ""
local s = game.Players.LocalPlayer.PlayerScripts.LocalScript
function findIf(bytecode,Line)
    local opcodes = {
        [22] = "if"
    }

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
findJumpTarget(bytecode, 1)
