-- skwd-lush: plugin entry / configuration.
--
-- setup([opts]) merges user options over the defaults and returns the merged
-- table, mirroring the standard nvim plugin API. Call it BEFORE :colorscheme.
-- Defaults:
--   live_reload = false  watch the matugen palette feed and re-source the
--                        theme on ANY change — hover-preview included. Off by
--                        default: reloads via SIGUSR1, which skwd-wall sends
--                        only on apply.

local config = {
	live_reload = false,
}

local M = {}

--- Merge user options and return the active configuration.
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	return config
end

--- Current configuration table.
function M.config()
	return config
end

--- Whether live palette reload is enabled.
function M.is_live_reload_enabled()
	return config.live_reload == true
end

return M