---@class (exact) Clazz
---@field private __super Clazz
---@field private __instances table<Clazz, boolean>
---@field private __unlocked boolean
---@field private __index Clazz
---@overload fun():Clazz
local clazz = {}

clazz.__instances = {}

---@generic T : Clazz
---@param self T
---@return T
function clazz:create()
	return setmetatable({}, self)
end

---Returns the super
---@generic T : Clazz
---@param self T
---@return T
function clazz:super()
	---@diagnostic disable-next-line: undefined-field
	return self.__super
end

---@generic T : Clazz
---@param self T
---@return T
function clazz:new(...)
	local instance = (self --[[@as Clazz]]):create()
	rawset(instance, "__unlocked", true)
	instance:init(...)
	rawset(instance, "__unlocked", nil)
	return instance
end

function clazz:init(...)

end

local function initProxy(self, name, value)
	if name == "new" then
		rawset(self, "init", value)
	else
		rawset(self, name, value)
	end
end

local inheritedMetaMethods = { "__add", "__sub", "__mul", "__div", "__mod", "__unm", "__concat", "__eq", "__lt", "__le",
	"__tostring" }

---Extends that class and returns a child class
---@return Clazz
function clazz:extend()
	assert(self:isClass(), "Can not extend an instance.")

	---@type Clazz
	local c = {
		__super = self,
		__instances = setmetatable({}, { __mode = "k" }),
		__unlocked = false,
		__index = nil,
	}

	c.__index = c

	--Copy and extend instances
	for i, _ in pairs(self.__instances) do
		c.__instances[i] = true
	end
	c.__instances[c] = true

	--While metamethodes are inherited via __index, they are not valid methamethods when not linked explicitly
	for _, method in ipairs(inheritedMetaMethods) do
		c[method] = self[method]
	end

	return setmetatable(c, {
		__call = self.new,
		__tostring = self.__class__tostring,
		__index = self,
		__newindex = initProxy
	})
end

---Implements an array of classes, that is, weakly copies every field of the interfaces and its supers to the class, if that field does not exist yet.
---@param ... Clazz
---@return Clazz
function clazz:implement(...)
	assert(self:isClass(), "Can not implement into an instance.")
	for _, class in ipairs({ ... }) do
		while class do
			self.__instances[class] = true
			---@diagnostic disable-next-line: no-unknown
			for i, v in pairs(class) do
				if not self[i] then
					---@diagnostic disable-next-line: no-unknown
					self[i] = v
				end
			end
			class = class.__super
		end
	end
	return self
end

local function __newindex_lock(self, key, value)
	if self.__unlocked then
		rawset(self, key, value)
	else
		error(
			"Attempt to set field '" ..
			tostring(key) ..
			"' with value '" .. tostring(value) .. "' of a locked " .. (self:isClass() and "class" or "instance") .. ".",
			2)
	end
end

---Locks the class, which prevents new instance fields from being created outside the constructor, and prevents new class fields altogether
---@return Clazz
function clazz:lock()
	assert(self:isClass(), "Can not lock an instance.")
	---@diagnostic disable-next-line: no-unknown
	getmetatable(self).__newindex = __newindex_lock
	return self
end

function clazz:isClass()
	return rawget(self, "__instances")
end

function clazz:instanceOf(class)
	return self.__instances[class] and true or false
end

function clazz:cast(class)
	assert(self:instanceOf(class), "Can not cast to class.")
	return setmetatable(self, class)
end

---@private
function clazz:__class__tostring()
	return "Class"
end

---@private
function clazz:__tostring()
	return "Instance"
end

---@diagnostic disable-next-line: param-type-mismatch
return setmetatable(clazz, {
	__call = clazz.extend,
	__tostring = clazz.__class__tostring
})
