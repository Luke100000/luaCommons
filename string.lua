---Split a string into a sequence of strings.
---@param text string
---@param sep string?
---@return string[]
function string.split(text, sep)
	sep = sep or "%s"
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	local _ = text:gsub(pattern, function(c)
		table.insert(fields, c)
	end)
	return fields
end

---String format wrapped in a pcall.
---@param text string
---@param ... any
---@return string
function string.pformat(text, ...)
	local ok, t = pcall(string.format, text, ...)
	return ok and t or text
end

---Trim whitespace from a string.
---@param text string
---@return string
function string.trim(text)
	local t = text:gsub("^%s+", ""):gsub("%s+$", "")
	return t
end

--Capitalize the first letter of a string.
---@param text string
---@return string
function string.capitalize(text)
	return text:sub(1, 1):upper() .. text:sub(2):lower()
end

local smallWords = {
	["a"] = true,
	["an"] = true,
	["and"] = true,
	["the"] = true,
	["but"] = true,
	["or"] = true,
	["for"] = true,
	["nor"] = true,
	["on"] = true,
	["in"] = true,
	["at"] = true,
	["by"] = true,
	["to"] = true,
	["of"] = true,
	["up"] = true,
}

---Convert to simplified AP style title case.
---@param text string
---@return string
function string.title(text)
	local result = {}
	for word in text:gmatch("%S+%s?") do
		if #result == 0 or not smallWords[word:lower():trim()] then
			table.insert(result, string.capitalize(word))
		else
			table.insert(result, word)
		end
	end
	return table.concat(result)
end

---Check if a string starts with a substring.
---@param text string
---@return boolean
function string.startswith(text)
	return text:sub(1, #text) == text
end

---Check if a string ends with a substring.
---@param text string
---@return boolean
function string.endswith(text)
	return text:sub(-#text) == text
end
