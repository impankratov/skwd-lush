-- Derived from impankratov/pywal-lush (MIT). Feed: ~/.cache/skwd-wall-v2/colors (matugen/skwd-wall)
vim.opt.background = "dark"
vim.g.colors_name = "skwd"

package.loaded["lush_theme.skwd"] = nil

require("lush")(require("lush_theme.skwd"))
