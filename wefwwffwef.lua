local Read = {}
local FLOAT_PRECISION = 24


function Read.new(bytecode)
  local self = {}
  local stream = buffer.fromstring(bytecode)
  self.cursor = 0
  function self:len()
    return buffer.len(stream)
  end
  
  function self:nextByte()
    local result = buffer.readu8(stream, self.cursor)
    self.cursor = self.cursor + 1
    return result
  end

  function self:nextBytes(count)
    if count == 0 then return end
    local bytes = {}
    for j = 1, count do
      table.insert(bytes, self:nextByte())
    end
    return bytes
  end

  function self:nextChar()
    return string.char(self:nextByte())
  end
  
  function self:readUInt32()
    local res = buffer.readu32(stream,self.cursor)
    self.cursor = self.cursor + 4
    return res
  end
  function self:readInt32()
    local res = buffer.readi32(stream,self.cursor)
    self.cursor = self.cursor + 4
    return res
  end
  function self:readFloat()
    local res = buffer.readf32(stream, self.cursor)
    self.cursor = self.cursor + 4
    return tonumber(string.format("%0." .. FLOAT_PRECISION .. "f", res))
end
  function self:nextVarInt()
    local result = 0
    for i = 0, 4 do
        local b = self:nextByte()
        result = bit32.bor(result, bit32.lshift(bit32.band(b, 0x7F), i * 7))
        if not bit32.btest(b, 0x80) then
            break
        end
    end
    return result  -- Ensure to return the result
  end

		function self:nextString(len)
		len = len or self:nextVarInt()
		if len == 0 then
			return ""
		else
		  len = len or self:nextVarInt()
			local result = buffer.readstring(stream, self.cursor, len)
			self.cursor = self.cursor + len
			return result
		end
	end

	function self:nextDouble()
		local result = buffer.readf64(stream, self.cursor)
		self.cursor = self.cursor + 8
		return result
	end
	function self:nextArg(range)
    range = range or 0
    local result = {}  
    local args = self:nextBytes(range)  

    for _, v in ipairs(args) do
        table.insert(result, v)
    end

    return table.concat(result,", ")
  end

  return self
end

function Read:Set(...)
	FLOAT_PRECISION = ...
end


return Read