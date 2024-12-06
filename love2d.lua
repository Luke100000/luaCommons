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
