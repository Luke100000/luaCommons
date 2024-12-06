# Lua Commons

Yet another common-utility-library for Lua.

Require the module to install all base functions:

```lua
require("luaCommons")
```

## String

`string.lua`

## Table

`table.lua`

## Math

`math.lua`

## Love2d

`love2d.lua`

Extension to LÖVEs functions.

## PriorityQueue

`priorityQueue.lua`, `zlib` licence!

An improved and typed version of Siqueira's priority queue.

```lua
---@type PriorityQueue<string>
local queue = PriorityQueue()

--Or shorter
local queue = PriorityQueue:new("string")

queue:put("", 11)
queue:empty()
queue:size()
queue:pop()
queue:peek()
```

## WeightedList

A list with weighted entries, for cases where simple `table.choices` or
`table.samples` is less handy.

```lua
---@type WeightedList<string>
local list = WeightedList()

--Or shorter
local list = WeightedList:new("string")

list:add("value", 1)
list:empty()
list:sample()
list:pick()
```

## Clazz

`clazz.lua`

Another interpretation of classes with single inheritance, type annotated,
supports interfaces, super, and a few extras.

Classes use `__index` for inheritance, and shallow copy for implement.

For improved type detection, [LuaT](https://github.com/Luke100000/LuaT) is
required.

```lua
---Extend from a class
---@class Vehicle : Clazz
local Vehicle = Clazz:extend():implement(Clazz1, Clazz2)

--Define the constructor
function Vehicle:init() end

function Vehicle:member()
    self:super().member(self)
end

--This requires LuaT
local instance = Vehicle()

---This works but does not type check parameters
local instance = Vehicle:new()

instance:instanceOf(Clazz1)
```

super() can be added like constructor injection