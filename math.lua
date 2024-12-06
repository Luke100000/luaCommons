---Round to a given number of decimal places
---@param num number
---@param numDecimalPlaces integer
---@return number
function math.round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

---Mix two numbers
---@param a number
---@param b number
---@param f number
---@return number
function math.mix(a, b, f)
	return a * (1.0 - f) + b * f
end

---@param v number
---@param a number
---@param b number
---@return number
function math.clamp(v, a, b)
	return math.max(math.min(v, b or 1.0), a or 0.0)
end

---@param v number
---@return number
function math.sign(v)
	return v > 0 and 1 or v < 0 and -1 or 0
end