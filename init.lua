---@type string
local root = ...

require(root .. ".math")
require(root .. ".string")
require(root .. ".table")

if love then
	require(root .. ".love2d")
end
