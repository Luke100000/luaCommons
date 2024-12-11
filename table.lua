---@param first table<any, any>
---@param second table<any, any>
---@param cycles table<any, any>
local function mergeInner(first, second, cycles)
	if cycles[first] then
		return first
	end
	cycles[first] = true
	for k, v in pairs(second) do
		if type(v) == "table" then
			if type(first[k]) == "table" then
				mergeInner(first[k], v, cycles)
			else
				first[k] = v
			end
		else
			first[k] = v
		end
	end
end

---Merge two tables into the first
---@param first table<any, any>
---@param second table<any, any>
---@return table<any, any>
function table.merge(first, second)
	mergeInner(first, second, {})
	return first
end

---Flat-copy a second table into the first
---@generic T : table<any, any>
---@param first T
---@param second T
---@return T
function table.update(first, second)
	---@diagnostic disable-next-line: no-unknown
	for k, v in pairs(second) do
		---@diagnostic disable-next-line: no-unknown
		first[k] = v
	end
	return first
end

---@param value table<any, any>
---@param cycles table<any, any>
---@return table<any, any> | any
local function copyInner(value, cycles)
	if type(value) == "table" then
		if cycles[value] then
			return cycles[value]
		else
			---@type table<any, any>
			local copy = {}
			cycles[value] = copy
			for k, v in next, value do
				copy[k] = copyInner(v, cycles)
			end
			return copy
		end
	else
		return value
	end
end

---Copy a table
---@generic T : table
---@param t T
---@return T
function table.copy(t)
	return copyInner(t, {})
end

---Clone (flat copy) a table
---@generic T : table
---@param t T
---@return T
function table.clone(t)
	local n = {}
	---@diagnostic disable-next-line: no-unknown
	for k, v in pairs(t) do
		---@diagnostic disable-next-line: no-unknown
		n[k] = v
	end
	return n
end

---Invert indices and values to produce a set
---@generic K, V
---@param t { [K]: V }
---@return { [V]: K }
function table.invert(t)
	---@type table<any, any>
	local n = {}
	---@diagnostic disable-next-line: no-unknown
	for d, s in ipairs(t) do
		n[s] = d
	end
	return n
end

---Constructs a set, implemented as a table with given keys set to true
---@generic T
---@param ... T
---@return { [T]: boolean }
function table.set(...)
	---@type table<any, boolean>
	local s = {}
	---@diagnostic disable-next-line: no-unknown
	for _, v in ipairs({ ... }) do
		s[v] = true
	end
	return s
end

---Finds a value in a table and returns its index, or nil of not present
---@param t table<any, any>
---@param v any
---@return any?
function table.find(t, v)
	for d, s in pairs(t) do
		if s == v then
			return d
		end
	end
end

---Finds a value in a table and returns its index, or false of not present
---@param t table<any, any>
---@return integer
function table.size(t)
	local n = 0
	for _, _ in pairs(t) do
		n = n + 1
	end
	return n
end

---Returns the length of a table, with support for Lua 5.2 __len
---@param t table
---@return integer
function table.len(t)
	local mt = getmetatable(t)
	return mt and mt.__len and mt.__len(t) or #t
end

---Checks if a table is empty
---@param t table<any, any>
---@return boolean
function table.empty(t)
	return next(t) == nil
end

---Prevents shallow modification of a table
---@param t table
---@return table
function table.freeze(t)
	return setmetatable({}, {
		__index = t,
		__newindex = function(_, _)
			error("Stats has been frozen!")
		end,
	})
end

---Concatenate tables
---@generic T : table
---@param ... T[]
---@return T
function table.cat(...)
	local n = {}
	for _, t in ipairs({ ... }) do
		---@diagnostic disable-next-line: no-unknown
		for _, v in ipairs(t) do
			table.insert(n, v)
		end
	end
	return n
end

---Map a function over a table
---@generic K, V, T
---@param t { [K]: V }
---@param f fun(key: K, value: V): T
---@return { [K]: T }
function table.map(t, f)
	---@type table<any, any>
	local n = {}
	---@diagnostic disable-next-line: no-unknown
	for k, v in pairs(t) do
		n[k] = f(v, k)
	end
	return n
end

---Filter a table
---@generic K, V
---@param t { [K]: V }
---@param f fun(key: K, value: V): boolean
---@return { [K]: V }
function table.filter(t, f)
	---@type table<any, any>
	local n = {}
	---@diagnostic disable-next-line: no-unknown
	for k, v in pairs(t) do
		if f(v, k) then
			n[k] = v
		end
	end
	return n
end

---Reduce a table
---@generic K, V, T
---@param t { [K]: V }
---@param f fun(accumulator: T, key: K, value: V): T
---@param initial T
---@return T
function table.reduce(t, f, initial)
	local n = initial
	---@diagnostic disable-next-line: no-unknown
	for k, v in pairs(t) do
		---@diagnostic disable-next-line: no-unknown
		n = f(n, v, k)
	end
	return n
end

---Key iterator
---@generic K, V
---@param t { [K]: V }
---@return fun(): K
function table.keys(t)
	local k, v = nil, nil
	return function()
		---@diagnostic disable-next-line: no-unknown
		k, _ = next(t, k)
		return k
	end
end

---Key iterator
---@generic K, V
---@param t { [K]: V }
---@return fun(): V
function table.values(t)
	local k, v = nil, nil
	return function()
		---@diagnostic disable-next-line: no-unknown
		k, v = next(t, k)
		return v
	end
end

---Returns the index of the maximum value in a table
---@param t number[] | string[] | table[]
---@return integer
function table.argmax(t)
	local maxIndex = 1
	local maxValue = t[maxIndex]
	for i = 2, #t do
		if t[i] > maxValue then
			maxIndex = i
			maxValue = t[i]
		end
	end
	return maxIndex
end

---Returns the index of the minimum value in a table
---@param t number[] | string[] | table[]
---@return integer
function table.argmin(t)
	local minIndex = 1
	local minValue = t[minIndex]
	for i = 2, #t do
		if t[i] < minValue then
			minIndex = i
			minValue = t[i]
		end
	end
	return minIndex
end

---Remove an element from an array, supporting negative indices
---@generic T
---@param t T[]
---@param i integer
---@return T
function table.pop(t, i)
	if i < 0 then
		i = #t + i + 1
	end
	return table.remove(t, i)
end

---Returns a subset of a table
---@generic V
---@param t V[]
---@param from integer?
---@param to integer?
---@param step integer? Can be negative, defaults to 1
---@return V[]
function table.slice(t, from, to, step)
	step = step or 1
	from = from or (step > 0 and 1 or #t)
	to = to or (step > 0 and #t or 1)
	local n = {}
	for i = from, to, step do
		table.insert(n, t[i])
	end
	return n
end

---@class View
---@field t any[]
---@field from integer
---@field to integer
---@field step integer
local View = {}

---Maps the view
---@param i integer
---@return integer
function View:map(i)
	return (i - 1) * self.step + self.from
end

---@generic V
---@param self View | { [integer]: V }
---@return fun(): integer?, V
function View:iter()
	local i = self.from
	return function()
		if self.step > 0 and i <= self.to or self.step < 0 and i >= self.to then
			local oi = i
			i = i + self.step
			return oi, self.t[oi]
		end
	end
end

function View:__index(i)
	if type(i) == "number" then
		return self.t[self:map(i)]
	else
		return rawget(View, i)
	end
end

function View:__len()
	return math.ceil((self.to - self.from) / self.step)
end

---Reverses the array in place
---@generic V
---@param t V[]
---@return V[]
function table.reverse(t)
	for i = 1, math.floor(#t / 2) do
		t[i], t[#t - i + 1] = t[#t - i + 1], t[i]
	end
	return t
end

---Shuffles the array in place
---@generic V
---@param t V[]
---@return V[]
function table.shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

---Returns a view of a table
---@generic V
---@param t V[]
---@param from integer?
---@param to integer?
---@param step integer? Can be negative, defaults to 1
---@return View | { [integer]: V }
function table.view(t, from, to, step)
	step = step or 1
	from = from or (step > 0 and 1 or table.len(t))
	to = to or (step > 0 and table.len(t) or 1)
	assert(step ~= 0, "Step cannot be 0")
	return setmetatable({
		t = t,
		from = from,
		to = to,
		step = step,
		iterator = false,
	}, View)
end

---Takes a random value from an array
---@generic T
---@param t T[]
---@return T
function table.sample(t)
	return t[math.random(1, #t)]
end

---Takes random values from an array, with replacement
---@generic T
---@param t T[]
---@param n integer
---@return T
function table.choice(t, n)
	local a = {}
	for _ = 1, n do
		table.insert(a, t[math.random(1, #t)])
	end
	return a
end

---Takes a random values from an array
---@generic T
---@param t T[]
---@param n integer
---@return T
function table.samples(t, n)
	local tc = table.clone(t)
	assert(n <= #t, "Cannot sample more than the array size")
	local a = {}
	for _ = 1, n do
		table.insert(a, table.pop(tc, math.random(1, #tc)))
	end
	return a
end

---Creates a new populated array
---@generic T
---@param n integer
---@param default T
---@return T[]
function table.fill(n, default)
	local t = {}
	for _ = 1, n do
		table.insert(t, default)
	end
	return t
end

---Returns the maximum value in a table
---@generic T
---@param t T[]
---@return T
function table.max(t)
	return math.max(table.unpack(t))
end

---Returns the minimum value in a table
---@generic T
---@param t T[]
---@return T
function table.min(t)
	return math.min(table.unpack(t))
end

---Returns the sum of a table
---@generic T
---@param t T[]
---@return T
function table.sum(t)
	local s = 0
	---@diagnostic disable-next-line: no-unknown
	for _, v in ipairs(t) do
		---@diagnostic disable-next-line: no-unknown
		s = s + v
	end
	return s
end

---Checks if any element in a table evaluates to true
---@param t table<any, any>
---@return boolean
function table.any(t)
	for _, v in pairs(t) do
		if v then
			return true
		end
	end
	return false
end

---Checks if all elements in a table evaluate to true
---@param t table<any, any>
---@return boolean
function table.all(t)
	for _, v in pairs(t) do
		if not v then
			return false
		end
	end
	return true
end

---Zip several arrays into a sequence of returned tuples. It will iterate until the shortest array is exhausted
---@generic T1, T2, T3, T4, T5, T6, T7, T8, T9
---@param t1 T1[]?
---@param t2 T2[]?
---@param t3 T3[]?
---@param t4 T4[]?
---@param t5 T5[]?
---@param t6 T6[]?
---@param t7 T7[]?
---@param t8 T8[]?
---@param t9 T9[]?
---@return fun(): T1, T2, T3, T4, T5, T6, T7, T8, T9
function table.zip(t1, t2, t3, t4, t5, t6, t7, t8, t9)
	local index = 0
	local maxIndex = math.min(
		t1 and #t1 or math.huge,
		t2 and #t2 or math.huge,
		t3 and #t3 or math.huge,
		t4 and #t4 or math.huge,
		t5 and #t5 or math.huge,
		t6 and #t6 or math.huge,
		t7 and #t7 or math.huge,
		t8 and #t8 or math.huge,
		t9 and #t9 or math.huge
	)
	return function()
		index = index + 1
		if index <= maxIndex then
			return t1 and t1[index],
				t2 and t2[index],
				t3 and t3[index],
				t4 and t4[index],
				t5 and t5[index],
				t6 and t6[index],
				t7 and t7[index],
				t8 and t8[index],
				t9 and t9[index]
		end
	end
end

---Iterates and unpacks an array of tuples
---@generic T1, T2, T3, T4, T5, T6, T7, T8, T9
---@param t [ T1, T2, T3, T4, T5, T6, T7, T8, T9 ][]
---@return fun(): T1, T2, T3, T4, T5, T6, T7, T8, T9
function table.unzip(t)
	local index = 0
	return function()
		index = index + 1
		if index <= #t then
			return unpack(t[index])
		end
	end
end
