local ffi = require("ffi")

---@class Memory
---@field type string
---@field elementSize integer
---@field length integer
---@field width integer
---@field height integer
---@field components integer
---@field byteData love.ByteData
---@field array ffi.cdata* | { [integer] : number }
---@overload fun(type: string, ...: integer): Memory
local Memory = {}

Memory.__index = Memory

---Creates and allocates a new Memory object
---@param length integer The length of the array
---@param type string
---@param data love.Data?
---@return Memory
function Memory.new(length, type, data)
	local elementSize = ffi.sizeof(type)
	local byteData = data or love.data.newByteData(elementSize * length)
	local array = ffi.cast(type .. "*", byteData:getFFIPointer())
	return setmetatable({
		type = type,
		elementSize = elementSize,
		length = length,
		byteData = byteData,
		array = array,
		width = 0,
		height = 0,
		components = 0,
	}, Memory)
end

---@type table<string, [string, integer]>
local knownFormats = {
	normal = { "uint8_t", 4 },
	r8 = { "uint8_t", 1 },
	rg8 = { "uint8_t", 2 },
	rgba8 = { "uint8_t", 4 },
	srgba8 = { "uint8_t", 4 },
	r16 = { "uint16_t", 1 },
	rg16 = { "uint16_t", 2 },
	rgba16 = { "uint16_t", 4 },
	r16f = { "float16_t", 1 },
	rg16f = { "float16_t", 2 },
	rgba16f = { "float16_t", 4 },
	r32f = { "float32_t", 1 },
	rg32f = { "float32_t", 2 },
	rgba32f = { "float32_t", 4 },
}

---Create a new memory from an image data
---@param imageData love.ImageData
function Memory.fromImageData(imageData)
	local f = imageData:getFormat()
	assert(knownFormats[f], "Unknown format")
	local format, n = knownFormats[f][1], knownFormats[f][2]
	local mem = Memory.new(imageData:getWidth() * imageData:getHeight() * n, format, imageData)
	mem.width, mem.height = imageData:getDimensions()
	mem.components = n
	return mem
end

---Sets a value in the memory array
---@param i integer
---@return number
function Memory:get(i)
	assert(i >= 1 and i <= self.length, "Index out of bounds")
	return self.array[i - 1]
end

---Gets a value from the memory array
---@param value any
---@param i integer
function Memory:set(value, i)
	assert(i >= 1 and i <= self.length, "Index out of bounds")
	self.array[i - 1] = value
end

---@param x integer
---@param y integer
---@return number
function Memory:getR(x, y)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	return self.array[i]
end

---@param x integer
---@param y integer
---@param r number
function Memory:setR(x, y, r)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	self.array[i] = r
end

---@param x integer
---@param y integer
---@return number
---@return number
function Memory:getRG(x, y)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	return self.array[i], self.array[i + 1]
end

---@param x integer
---@param y integer
---@param r number
---@param g number
function Memory:setRG(x, y, r, g)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	self.array[i], self.array[i + 1] = r, g
end

---@param x integer
---@param y integer
---@return number
---@return number
---@return number
function Memory:getRGB(x, y)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	return self.array[i], self.array[i + 1], self.array[i + 2]
end

---@param x integer
---@param y integer
---@param r number
---@param g number
---@param b number
function Memory:setRGB(x, y, r, g, b)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	self.array[i], self.array[i + 1], self.array[i + 2] = r, g, b
end

---@param x integer
---@param y integer
---@return number
---@return number
---@return number
---@return number
function Memory:getRGBA(x, y)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	return self.array[i], self.array[i + 1], self.array[i + 2], self.array[i + 3]
end

---@param x integer
---@param y integer
---@param r number
---@param g number
---@param b number
---@param a number
function Memory:setRGBA(x, y, r, g, b, a)
	assert(x >= 1 and x <= self.width, "Index out of bounds")
	assert(y >= 1 and y <= self.height, "Index out of bounds")
	local i = ((y - 1) * self.width + x - 1) * self.components
	self.array[i], self.array[i + 1], self.array[i + 2], self.array[i + 3] = r, g, b, a
end

---Indexes the array with a flat index
---@param i integer
---@return number
function Memory:__index(i)
	if type(i) == "number" then
		return self.array[i - 1]
	else
		return rawget(Memory, i)
	end
end

function Memory:__newindex(i, value)
	if type(i) == "number" then
		self.array[i - 1] = value
	else
		rawset(Memory, i, value)
	end
end

return setmetatable(Memory, {
	__call = function(_, ...)
		return Memory.new(...)
	end,
})
