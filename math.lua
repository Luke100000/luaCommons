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

---@param x number
---@param y number
---@return number
function math.length(x, y)
	return math.sqrt(x * x + y * y)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function math.distance(x1, y1, x2, y2)
	return math.length(x2 - x1, y2 - y1)
end

---Checks if two values are close
---@param a number
---@param b number
---@param rel_tol number?
---@param abs_tol number?
---@return boolean
function math.close(a, b, rel_tol, abs_tol)
	return math.abs(a - b) < ((abs_tol or 1e-9) + rel_tol * math.max(math.abs(a), math.abs(b)))
end
