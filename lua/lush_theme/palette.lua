local lush = require("lush")
local hsl = lush.hsl

local function getColors()
	local colorTable = {}
	local n = 0
	local home = os.getenv("HOME")
	local skwd_colors = home .. "/.cache/skwd-wall-v2/colors"
	local file = io.open(skwd_colors, "r")
	if file then
		for line in file:lines() do
			line = line:gsub("%s+", "")
			if n < 16 and line:match("^#[%x][%x][%x][%x][%x][%x]$") then
				table.insert(colorTable, line)
				n = n + 1
			end
		end
	end
	return colorTable
end

local colors = getColors()

return {
	color0 = tostring(hsl(colors[1])),
	color1 = tostring(hsl(colors[2])),
	color2 = tostring(hsl(colors[3])),
	color3 = tostring(hsl(colors[4])),
	color4 = tostring(hsl(colors[5])),
	color5 = tostring(hsl(colors[6])),
	color6 = tostring(hsl(colors[7])),
	color7 = tostring(hsl(colors[8])),
	color8 = tostring(hsl(colors[9])),
	color9 = tostring(hsl(colors[10])),
	color10 = tostring(hsl(colors[11])),
	color11 = tostring(hsl(colors[12])),
	color12 = tostring(hsl(colors[13])),
	color13 = tostring(hsl(colors[14])),
	color14 = tostring(hsl(colors[15])),
	color15 = tostring(hsl(colors[16])),
}
