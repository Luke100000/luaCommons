---@return string
local function getRoot()
    local str = debug.getinfo(2, "S").source
    return str:match("(.*[/\\])") or ""
end
local root = getRoot()

---Recursively delete files
---@param item string
function love.filesystem.removeRecursive(item)
	if love.filesystem.getInfo(item, "directory") then
		for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
			love.filesystem.removeRecursive(item .. '/' .. child)
		end
	end
	love.filesystem.remove(item)
end

---Get the size of a file or directory (recursively)
---@param item string
function love.filesystem.getSize(item)
	if love.filesystem.getInfo(item, "directory") then
		local size = 0
		for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
			size = size + love.filesystem.getSize(item .. '/' .. child)
		end
		return size
	else
		local i = love.filesystem.getInfo(item)
		return i and i.size or 0
	end
end

---Copy a file
---@source https://forum.cockos.com/showthread.php?t=244397
---@param source string
---@param target string
---@return boolean
function love.filesystem.copyFile(source, target)
	local sourceFile = io.open(source, "rb")
	local targetFile = io.open(target, "wb")
	local sourceSize, targetSize = 0, 0
	if not sourceFile or not targetFile then
		return false
	end
	while true do
		local block = sourceFile:read(2 ^ 13)
		if not block then
			sourceSize = sourceFile:seek("end")
			break
		end
		targetFile:write(block)
	end
	sourceFile:close()
	targetSize = targetFile:seek("end")
	targetFile:close()
	return targetSize == sourceSize
end

---@class ORAImage
---@field images table<string, ORAImageLayer>

---@class ORAImageLayer
---@field x number
---@field y number
---@field opacity number
---@field visible boolean
---@field compositeOp string
---@field image love.Image
---@field imageData love.ImageData

---Load an ORA image
---@param path string
---@return ORAImage
function love.graphics.newORAImage(path)
	local fileData = love.filesystem.newFileData(path)
	assert(fileData, "File not found: " .. path)
	assert(love.filesystem.mount(fileData, path .. "_mounted"), "Failed to mount " .. path)
	local meta = love.filesystem.read(path .. "_mounted/stack.xml")

	---@type SLAXML
	local XML = require(root .. ".xml")
	local t = XML:dom(meta)

	---@type ORAImage
	local oraImage = {
		images = {}
	}
	for _, image in ipairs(t.kids) do
		if image.type == "element" then
			for _, stack in ipairs(image.kids) do
				if stack.type == "element" then
					for _, layer in ipairs(stack.kids) do
						if layer.type == "element" then
							local imageData = love.image.newImageData(path .. "_mounted/" .. layer.attr["src"])
							oraImage.images[tostring(layer.attr["name"])] = {
								x = tonumber(layer.attr["x"]) or 0,
								y = tonumber(layer.attr["y"]) or 0,
								opacity = tonumber(layer.attr["opacity"]) or 1,
								visible = layer.attr["visibility"] == "visible",
								compositeOp = layer.attr["composite-op"] or "svg:source-over",
								image = love.graphics.newImage(imageData),
								imageData = imageData
							}
						end
					end
				end
			end
		end
	end

	return oraImage
end
