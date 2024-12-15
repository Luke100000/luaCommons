---@class WeightedList<T> : { add: fun(self: WeightedList<T>, entry: T, weight: number), sample: (fun():T), empty: (fun():boolean), pick: (fun():T) }
---@field private entries any[]
---@field private weights number[]
---@field private totalWeight number
---@overload fun(T): WeightedList<any>
local WeightedList = {}

---@generic T
---@param T `T`
---@return WeightedList<T>
function WeightedList:new(T)
	local l = {}
	l.entries = {}
	l.weights = {}
	l.totalWeight = 0
	setmetatable(l, self)
	return l
end

function WeightedList:add(entry, weight)
	assert(weight and weight >= 0, "Weight must be positive")
	table.insert(self.entries, entry)
	table.insert(self.weights, weight)
	self.totalWeight = self.totalWeight + weight
end

---@private
function WeightedList:sampleIndex()
	local r = math.random() * self.totalWeight
	local i = 1
	while r > self.weights[i] do
		r = r - self.weights[i]
		i = i + 1
	end
	return i
end

function WeightedList:sample()
	if #self.entries == 0 then
		return nil
	end

	local i = self:sampleIndex()
	return self.entries[i]
end

function WeightedList:empty()
	return #self.entries == 0
end

function WeightedList:pick()
	if #self.entries == 0 then
		return nil
	end

	local i = self:sampleIndex()
	self.totalWeight = self.totalWeight - table.remove(self.weights, i)
	return table.remove(self.entries, i)
end

---@private
WeightedList.__index = WeightedList

---@diagnostic disable-next-line: param-type-mismatch
setmetatable(WeightedList, {
	__call = function(_, T)
		return WeightedList:new(T)
	end,
})

return WeightedList
