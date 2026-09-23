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

if #colors < 16 then
	return nil
end

-- ANSI ladder indexed by purpose (matugen-themes terminal-sequences).
-- color0..color15 keys kept for web-devicons.lua (reads color0/8/7/15);
-- semantic aliases expose material purpose.
local P = {
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

P.surface = P.color0
P.error = P.color1
P.tertiary = P.color2
P.secondary = P.color4
P.primary_d = P.color6
P.muted = P.color7
P.surface_hi = P.color8
P.tertiary_f = P.color11
P.secondary_f = P.color13
P.primary = P.color14
P.fg = P.color15

return P