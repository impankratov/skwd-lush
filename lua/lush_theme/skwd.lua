-- skwd-lush: matugen-native nvim colorscheme (lush).
-- Feed: ~/.cache/skwd-wall-v2/colors (matugen terminal-sequences ladder).
--
-- Material role per ladder index (see matugen-themes/templates/terminal-sequences):
--   0  surface.dark             editor bg
--   1  error (+15)              red accent
--   2  tertiary (+25)           string/function accent
--   3  tertiary (+20)
--   4  secondary (+25)          type/change accent
--   5  secondary (+20)
--   6  primary (+10)
--   7  on_surface_variant       muted text (LineNr, Comment, non-text)
--   8  surface_container_high   panel bg (Pmenu, StatusLine, CursorLine)
--   9  error (+10)
--   10 tertiary (+10)
--   11 tertiary_fixed (+10)
--   12 secondary (+10)
--   13 secondary_fixed (+10)
--   14 primary (-5)             accent (keywords, selection, search)
--   15 on_surface               fg

local lush = require('lush')
local hsl = lush.hsl

local function getColors()
  local colorTable = {}
  local sep = package.config:sub(1, 1)
  local skwd_colors_path = table.concat({ os.getenv('HOME'), '.cache', 'skwd-wall-v2', 'colors' }, sep)

  local file = io.open(skwd_colors_path, 'r')
  if file then
    local n = 0
    for line in file:lines() do
      line = line:gsub('%s+', '')
      if n < 16 and line:match('^#[%x][%x][%x][%x][%x][%x]$') then
        table.insert(colorTable, line)
        n = n + 1
      end
    end
  end
  return colorTable
end

local colors = getColors()

---@diagnostic disable: undefined-global
local theme = lush(function(injected_functions)
  local sym = injected_functions.sym

  -- Semantic slots from the matugen ladder
  local surface     = hsl(colors[1])  -- 0
  local fg          = hsl(colors[16]) -- 15 (on_surface)

  local function luma(rgb)
    local function f(c)
      c = c / 255
      return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
    end
    return 0.2126 * f(rgb.r) + 0.7152 * f(rgb.g) + 0.0722 * f(rgb.b)
  end
  local bg_luma = luma(surface.rgb)
  local function contrast(c)
    local a, b = luma(c.rgb), bg_luma
    if a < b then a, b = b, a end
    return (a + 0.05) / (b + 0.05)
  end
  -- Raise a token toward fg until it clears a WCAG floor vs the bg.
  -- Wallpaper-proof: works for any emission, light or dark. Never dims.
  local function clamp(c, floor)
    if contrast(c) >= floor then return c end
    local lo, hi = 0, 100
    for _ = 1, 10 do
      local m = (lo + hi) / 2
      if contrast(c.mix(fg, m)) >= floor then hi = m else lo = m end
    end
    return c.mix(fg, hi)
  end

  local error       = hsl(colors[2])  -- 1
  local tertiary    = hsl(colors[3])  -- 2
  local tertiary_2  = hsl(colors[4])  -- 3
  local secondary   = hsl(colors[5])  -- 4
  local secondary_2 = hsl(colors[6])  -- 5
  local primary_d   = hsl(colors[7])  -- 6
  local muted       = hsl(colors[8])  -- 7 (on_surface_variant)
  local surface_hi  = hsl(colors[9])  -- 8 (surface_container_high)
  local error_b     = hsl(colors[10]) -- 9
  local tertiary_d  = hsl(colors[11]) -- 10
  local tertiary_f  = hsl(colors[12]) -- 11 (tertiary_fixed)
  local secondary_d = hsl(colors[13]) -- 12
  local secondary_f = hsl(colors[14]) -- 13 (secondary_fixed)
  local primary     = hsl(colors[15]) -- 14

  -- Enforce minimum contrast for every foreground/accent token. `fg` and
  -- the bg tokens (surface, surface_hi) are excluded — they are the anchor.
  primary    = clamp(primary, 3.5)
  primary_d  = clamp(primary_d, 4.5)
  secondary  = clamp(secondary, 4.5)
  secondary_2 = clamp(secondary_2, 3.5)
  secondary_d = clamp(secondary_d, 3.5)
  secondary_f = clamp(secondary_f, 4.5)
  tertiary   = clamp(tertiary, 4.5)
  tertiary_2 = clamp(tertiary_2, 3.5)
  tertiary_d = clamp(tertiary_d, 3.5)
  tertiary_f = clamp(tertiary_f, 3.5)
  muted      = clamp(muted, 4.5)
  error      = clamp(error, 3.5)
  error_b    = clamp(error_b, 3.5)

  -- Comment-like text: pull muted toward the bg for a dimmer, quieter look,
  -- then keep the 4.5 floor so it stays readable on any wallpaper.
  local comment = clamp(muted.mix(surface, 18), 4.5)
  -- Folded lines sit one step quieter than comments: deeper bg mix, 4.0 floor.
  local folded = clamp(muted.mix(surface, 35), 4.0)
  -- Line numbers: desaturated + pulled toward the bg, still scannable.
  local linenr = clamp(muted.desaturate(70).mix(surface, 65), 3.0)

  return {
    ColorColumn { bg = surface_hi },                                       -- used for the columns set with 'colorcolumn'
    Conceal { bg = "NONE", fg = comment },                                   -- placeholder characters substituted for concealed text (see 'conceallevel')
    Cursor { bg = primary, fg = surface },                                 -- character under the cursor
    lCursor { bg = tertiary, fg = surface },                               -- the character under the cursor when |language-mapping| is used (see 'guicursor')
    CursorIM { bg = tertiary, fg = surface },                              -- like Cursor, but used when in IME mode |CursorIM|
    CursorColumn { bg = surface_hi },                                      -- Screen-column at the cursor, when 'cursorcolumn' is set.
    CursorLine { bg = surface_hi },                                        -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
    Directory { bg = "NONE", fg = secondary },                             -- directory names (and other special names in listings)
    DiffAdd { bg = primary, fg = surface },                                -- diff mode: Added line |diff.txt|
    DiffChange { bg = secondary.mix(surface, 50), fg = fg },               -- diff mode: Changed line |diff.txt|
    DiffDelete { bg = "NONE", fg = error },                                -- diff mode: Deleted line |diff.txt|
    DiffText { DiffAdd },                                                  -- diff mode: Changed text within a changed line |diff.txt|
    DiffTextAdd { DiffAdd },                                               -- diff mode: Added text within a changed line |diff.txt|
    EndOfBuffer { bg = "NONE", fg = surface.lighten(16) }, -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
    TermCursor { bg = tertiary, fg = surface },                            -- cursor in a focused terminal
    ErrorMsg { bg = surface, fg = error },                                 -- error messages on the command line
    VertSplit { bg = "NONE", fg = surface.lighten(8) },                     -- the column separating vertically split windows
    Folded { bg = "NONE", fg = folded },                                    -- line used for closed folds
    FoldColumn { bg = "NONE", fg = folded },                                -- 'foldcolumn'
    SignColumn { bg = "NONE", fg = muted },                                -- column where |signs| are displayed
    IncSearch { bg = primary, fg = surface },                              -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
    Substitute { bg = secondary, fg = surface },                           -- |:substitute| replacement text highlighting
    LineNr { bg = "NONE", fg = linenr },                                    -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    CursorLineNr { bg = surface_hi, fg = fg, gui = "bold" },               -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
    MatchParen { bg = surface_hi, fg = primary, gui = "bold" },            -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    ModeMsg { bg = primary, fg = surface },                                -- 'showmode' message (e.g., "-- INSERT -- ")
    MsgArea { bg = "NONE", fg = fg },                                      -- Area for messages and cmdline
    MsgSeparator { bg = surface, fg = muted },                             -- Separator for scrolled messages, `msgsep` flag of 'display'
    MoreMsg { bg = "NONE", fg = secondary_f, gui = "italic" },             -- |more-prompt|
    NonText { bg = surface, fg = muted.darken(30), ctermbg = none },       -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
    Normal { bg = "NONE", fg = fg, ctermbg = none },                       -- normal text
    NormalFloat { bg = "NONE", fg = fg },                                  -- Normal text in floating windows.
    NormalNC { },                                                          -- Normal text in non-current windows
    Pmenu { bg = surface_hi, fg = fg },                                    -- Popup menu: normal item.
    PmenuSel { bg = primary, fg = surface },                               -- Popup menu: selected item.
    PmenuSbar { fg = "NONE", bg = surface },                               -- Popup menu: scrollbar.
    PmenuThumb { bg = muted, fg = "NONE" },                                -- Popup menu: Thumb of the scrollbar.
    Question { bg = "NONE", fg = primary, gui = "bold" },                  -- |hit-enter| prompt and yes/no questions
    QuickFixLine { bg = surface_hi, fg = fg },                             -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    Search { bg = primary, fg = surface },                                 -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
    CurSearch { bg = primary, fg = surface },                              -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
    SnippetTabStop { bg = surface, fg = fg },                              -- Tabstops in snippets
    SpecialKey { bg = "NONE", fg = comment, gui = "italic" },                -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
    SpellBad { bg = "NONE", fg = "NONE", gui = "undercurl" },              -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap { SpellBad },                                                 -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal { SpellBad },                                               -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare { SpellBad },                                                -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
    StatusLine { bg = surface_hi, fg = fg },                               -- status line of current window
    StatusLineNC { bg = surface, fg = muted },                             -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
    TabLine { StatusLineNC },                                              -- tab pages line, not active tab page label
    TabLineFill { bg = "NONE" },                                           -- tab pages line, where there are no labels
    TabLineSel { StatusLine },                                             -- tab pages line, active tab page label
    Title { bg = "NONE", fg = primary, gui = "bold" },                     -- titles for output from ":set all", ":autocmd" etc.
    Visual { bg = primary, fg = surface },                                 -- Visual mode selection
    VisualNOS { QuickFixLine },                                            -- Visual mode selection when vim is "Not Owning the Selection".
    WarningMsg { bg = "NONE", fg = tertiary_f, gui = "bold" },             -- warning messages
    Whitespace { bg = "NONE", fg = surface.lighten(16), ctermbg = none },   -- listchars whitespace; also IBL inherits this for its indent guides (ibl setup_builtin_hl_groups) — keep in sync with EndOfBuffer/Winseparator
    Winseparator { EndOfBuffer },                                          -- Separator between window splits. Inherts from |hl-VertSplit| by default, which it will replace eventually.    WildMenu { PmenuSel },                                                 -- current match in 'wildmenu' completion
    WinBar { },                                                            -- Window bar of current window
    WinBarNC { },                                                          -- Window bar of not-current windows

    FloatTitle { NormalFloat, fg = primary, gui = "bold" },                -- nvim.dressing rename pop-up title https://github.com/stevearc/dressing.nvim/issues/42
    FloatBorder { NormalFloat, fg = muted },                               -- nvim.dressing rename pop-up border

    Comment { bg = "NONE", fg = comment, gui = "italic" },                   -- Any comment

    Constant { bg = "NONE", fg = secondary_f },                            -- (*) Any constant
    Identifier { bg = "NONE", fg = fg },                                   -- (*) Any variable name
    Function { bg = "NONE", fg = tertiary },                               --   Function name (also: methods for classes)

    Statement { bg = "NONE", fg = primary },                               -- (*) Any statement
    Conditional { bg = "NONE", fg = primary_d },                           --   if, then, else, endif, switch, etc.
    Repeat { bg = "NONE", fg = primary_d },                                --   for, do, while, etc.
    Label { bg = "NONE", fg = fg },                                        --   case, default, etc.

    PreProc { bg = "NONE", fg = secondary_d },                             -- (*) Generic Preprocessor

    Type { bg = "NONE", fg = secondary, gui = "bold" },                    -- (*) int, long, char, etc.

    Special { bg = "NONE", fg = tertiary_f },                              -- (*) Any special symbol

    Underlined { gui = "underline" },                                      -- Text that stands out, HTML links
    Error { bg = surface_hi, fg = error, gui = "bold" },                   -- Any erroneous construct
    Todo { Title },                                                        -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    sym"@string"            { fg = tertiary },                             -- String
    String                  { bg = "NONE", fg = tertiary },                 -- builtin partner of @string (substitute preview etc.)
    sym"@parameter"         { fg = fg },
    sym"@field"             { fg = secondary_f },
    sym"@property"          { fg = secondary_f },
    sym"@constructor"       { fg = tertiary_f },
    sym"@conditional"       { Conditional },
    sym"@repeat"            { Repeat },
    sym"@keyword"           { Statement },
    sym"@type"              { Type },
    sym"@namespace"         { Identifier },
    sym"@include"           { PreProc },
    sym"@preproc"           { PreProc },
    sym"@tag"               { fg = primary },
    sym"@text.literal"      { Comment },
    sym"@text.reference"    { fg = primary },
    sym"@text.title"        { Title },
    sym"@text.uri"          { Underlined, fg = primary },
    sym"@text.todo"         { Todo },

    diffRemoved { fg = error },                                            -- Special
    diffChanged { fg = secondary },                                        -- PreProc
    diffAdded { fg = primary },                                            -- Identifier

    -- nvim-cmp
    CmpItemAbbrMatch { fg = primary, gui = "bold" },
    CmpItemAbbrMatchFuzzy { CmpItemAbbrMatch },
    CmpItemKind { fg = tertiary },
    CmpItemMenu { fg = muted, gui = "italic" },

    -- blink.cmp
    BlinkCmpLabelDeprecated { gui = "strikethrough" },
    BlinkCmpLabelMatch { CmpItemAbbrMatch },
    BlinkCmpLabelDetail { CmpItemKind },
    BlinkCmpLabelDescription { CmpItemKind },
    BlinkCmpKind { Normal },
    BlinkCmpSource { CmpItemMenu },

    -- Lualine
    LualineNormalA { bg = primary, fg = surface, gui = "bold" },
    LualineNormalB { bg = surface_hi, fg = fg },
    LualineNormalC { bg = surface, fg = muted },

    LualineInactiveA { bg = surface, fg = muted },
    LualineInactiveB { LualineInactiveA },
    LualineInactiveC { LualineInactiveA },

    LualineInsertA { bg = tertiary, fg = surface, gui = "bold" },
    LualineVisualA { bg = secondary, fg = surface, gui = "bold" },
    LualineReplaceA { bg = error, fg = surface, gui = "bold" },

    -- Telescope
    TelescopeTitle          { FloatTitle },
    TelescopeSelection      { PmenuSel },
    TelescopeSelectionCaret { TelescopeSelection, fg = primary, gui = "bold" },
    TelescopeMultiSelection { TelescopeSelectionCaret, bg = "NONE", gui = "bold" },
    TelescopeNormal         { NormalFloat },
    TelescopeBorder         { FloatBorder },
    TelescopeMatching       { bg = primary, fg = surface },
    TelescopePromptPrefix   { fg = primary },
    TelescopePromptCounter  { bg = "NONE", fg = secondary },

    TreesitterContext { bg = surface_hi },
    TreesitterContextLineNumber { LineNr, bg = surface_hi },
    TreesitterContextBottom { fg = primary, gui = "underline,bold" },

    -- indent-blankline
    IblIndent { fg = surface.lighten(16) },                                -- regular indent guides (in sync with Whitespace / EndOfBuffer / Winseparator)
    IblWhitespace { IblIndent },                                           -- trailing whitespace
    IblScope { fg = surface.lighten(30) },                                 -- current scope / active level: one step brighter than the guides

    GitSignsAdd { bg = "NONE", fg = primary },
    GitSignsChange { bg = "NONE", fg = secondary },
    GitSignsDelete { bg = "NONE", fg = error },

    GitSignsAddPreview { DiffChange },
    GitSignsDeletePreview { DiffDelete },
    GitSignsCurrentLineBlame { NonText },
    GitSignsAddInline { DiffAdd },
    GitSignsDeleteInline { bg = surface_hi, fg = muted },
    GitSignsChangeInline { GitSignsDeleteInline },
    GitSignsAddLnInline { GitSignsAddInline },
    GitSignsChangeLnInline { GitSignsChangeInline },
    GitSignsDeleteLnInline { GitSignsDeleteInline },
    GitSignsDeleteVirtLn { DiffDelete },
    GitSignsDeleteVirtLnInLine { GitSignsDeleteLnInline },
    GitSignsVirtLnum { GitSignsDeleteVirtLn },

    -- Snacks
    SnacksNormal { Normal },
    SnacksNormalNC { NormalNC },
    SnacksWinBar { WinBar },
    SnacksWinBarNC { WinBarNC },

    SnacksInputNormal { NormalFloat },
    SnacksInputBorder { FloatBorder },
    SnacksInputTitle { FloatTitle },
    SnacksInputIcon { SnacksInputBorder },

    -- Neogit
    NeogitHunkHeader { Type },
    NeogitDiffContext { Normal },
    NeogitDiffAdd { DiffAdd, bg = "NONE" },
    NeogitDiffDelete { DiffDelete, bg = "NONE" },
    NeogitDiffHeader { Type },

    NeogitHunkHeaderHighlight { Pmenu, gui = "bold" },
    NeogitDiffContextHighlight { Normal, bg = surface.lighten(5) },
    NeogitDiffAddHighlight { DiffAdd },
    NeogitDiffDeleteHighlight { DiffDelete },
    NeogitDiffHeaderHighlight { PmenuSel, gui = "bold" },

    NeogitCursorLine { PmenuSel },

    MCPHubDiffAdd { DiffAdd },
    MCPHubDiffDelete { DiffDelete },
    MCPHubDiffChange { DiffChange },

    RenderMarkdownCode { ColorColumn, bg = "NONE" },
    RenderMarkdownCodeInfo { RenderMarkdownCode },
  }
end)

return theme

-- vi:nowrap
