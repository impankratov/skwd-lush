-- skwd-lush lualine theme (matugen/skwd feed).
-- Computes EXPLICIT colors from `~/.cache/skwd-wall-v2/colors` instead of
-- referencing colorscheme groups: lualine resolves its theme only once at
-- setup() and has no ColorScheme hook, so group/link refs freeze on the
-- startup colorscheme and die on `:hi clear`. Explicit colors keep the bar
-- palette-driven and stable across `:colorscheme` switches.
--
-- Ladder (matugen-themes terminal-sequences): index -> material role.
--   0 surface.dark | 1 error | 2 tertiary | 4 secondary | 6 primary(+10)
--   7 on_surface_variant | 8 surface_container_high | 14 primary | 15 on_surface
local function colors()
	local t = {}
	local home = os.getenv('HOME')
	if home then
		local f = io.open(home .. '/.cache/skwd-wall-v2/colors', 'r')
		if f then
			for line in f:lines() do
				line = line:gsub('%s+', '')
				if line:match('^#[%x][%x][%x][%x][%x][%x]$') and #t < 16 then
					t[#t + 1] = line
				end
			end
		end
	end
	return t
end

local c = colors()
local function C(i)
	return c[i + 1] or '#000000'
end

local surface = C(0)
local error = C(1)
local tertiary = C(2)
local secondary = C(4)
local muted = C(7)
local surface_hi = C(8)
local primary = C(14)
local fg = C(15)

return {
	normal = {
		a = { fg = surface, bg = primary, gui = 'bold' },
		b = { fg = fg, bg = surface_hi },
		c = { fg = muted, bg = surface },
	},
	insert = { a = { fg = surface, bg = tertiary, gui = 'bold' } },
	visual = { a = { fg = surface, bg = secondary, gui = 'bold' } },
	replace = { a = { fg = surface, bg = error, gui = 'bold' } },
	inactive = {
		a = { fg = muted, bg = surface },
		b = { fg = muted, bg = surface },
		c = { fg = muted, bg = surface },
	},
}