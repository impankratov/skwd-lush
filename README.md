# skwd-lush

Material-You (matugen / skwd-wall) Neovim colorscheme, lush-based.

Derived from [pywal-lush](https://github.com/impankratov/pywal-lush) (MIT).
Replaces the wal-cache feed with skwd-wall-v2 emission
(`~/.cache/skwd-wall-v2/colors`, 16 ANSI hex lines, same shape as wal
`~/.cache/wal/colors`; loader skips `#` comment lines).

## Requires
- [lush.nvim](https://github.com/rktjmp/lush.nvim)
- skwd-wall-v2 + matugen running (emits `~/.cache/skwd-wall-v2/colors`)

## Install / use
```lua
vim.pack.add({ "https://github.com/impankratov/skwd-lush", "https://github.com/rktjmp/lush.nvim" })
vim.cmd.colorscheme("skwd-lush")
```

Exposes `lush_theme.palette` (color0..15) for e.g. web-devicons auto-colors.
Lualine theme: `require("lualine/themes/skwd")`.
