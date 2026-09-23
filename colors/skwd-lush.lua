-- Derived from impankratov/pywal-lush (MIT). Feed: ~/.cache/skwd-wall-v2/colors (matugen/skwd-wall)
local feed = vim.fn.filereadable(vim.fn.expand("$HOME/.cache/skwd-wall-v2/colors"))

if feed ~= 1 then
	vim.notify(
		"skwd-lush: matugen feed not found at ~/.cache/skwd-wall-v2/colors, using default colorscheme",
		vim.log.levels.WARN
	)
	return
end

vim.opt.background = "dark"
vim.g.colors_name = "skwd"

package.loaded["lush_theme.skwd"] = nil

require("lush")(require("lush_theme.skwd"))
