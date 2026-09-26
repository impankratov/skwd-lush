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

-- Optional live palette reload (OFF by default). Enable before :colorscheme
-- with require("skwd-lush").setup({ live_reload = true }). When active, nvim
-- watches ~/.cache/skwd-wall-v2/colors and re-sources the theme on ANY write
-- (apply AND hover-preview). Without it, nvim relies on SIGUSR1, which skwd-wall
-- sends only on apply.
if require("skwd-lush").is_live_reload_enabled() then
	vim.schedule(function()
		require("lush_theme.skwd_watch"):start()
	end)
end
