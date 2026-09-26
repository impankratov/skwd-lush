-- skwd-lush: optional live feed watcher.
--
-- skwd-wall updates ~/.cache/skwd-wall-v2/colors on every palette change, but
-- only signals SIGUSR1 on apply. During hover-preview the feed is rewritten
-- with correct colors yet nvim is never notified, so the theme stays stale.
--
-- require("skwd-lush").setup({ live_reload = true }) makes nvim watch the feed
-- and re-source the theme on ANY write — apply and preview alike. Off by
-- default: without it, nvim relies on SIGUSR1 and only re-tints on apply. When
-- the watcher is active it owns the reload, so the SIGUSR1 autocmd should be
-- skipped to avoid double reloads.
--
-- The daemon rewrites the feed both in place and atomically (tmp + rename),
-- and the render burst touches several files, so a single fsevent can land
-- mid-write. Every reload is gated on a complete 16-line hex ladder (mirroring
-- config/scripts/reload-nvim-theme.sh) and retried briefly until the feed
-- settles, so a partial ladder fails soft instead of crashing on hsl(nil).

local uv = vim.uv or vim.loop

local M = {}

local feed = vim.fn.expand("$HOME/.cache/skwd-wall-v2/colors")
local feed_dir = vim.fn.fnamemodify(feed, ":h")

local watching = false
local debounce
local fs_handle
local retry_timer

local function feed_ready()
	local ok, lines = pcall(vim.fn.readfile, feed)
	if not ok then
		return false
	end
	local valid = 0
	for _, line in ipairs(lines) do
		if line:match("^#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
			valid = valid + 1
		end
	end
	return valid >= 16
end

--- Re-source skwd-lush from the current feed. Safe to call from anywhere:
--- it is a no-op unless the feed carries a complete ladder, and it retries
--- briefly to outlast a partial render burst. Mirrors the SIGUSR1 handler
--- (drops the cached palette module, runs :colorscheme).
function M.reload()
	vim.schedule(function()
		local attempts = 0
		local function attempt()
			attempts = attempts + 1
			if feed_ready() then
				package.loaded["lush_theme.palette"] = nil
				package.loaded["lush_theme.skwd"] = nil
				vim.cmd.colorscheme("skwd-lush")
				vim.cmd("redraw!")
				return
			end
			if attempts >= 40 then
				return
			end
			if retry_timer and not retry_timer:is_closing() then
				retry_timer:stop()
			else
				retry_timer = uv.new_timer()
			end
			retry_timer:start(50, 0, function()
				retry_timer:stop()
				retry_timer:close()
				retry_timer = nil
				vim.schedule(attempt)
			end)
		end
		attempt()
	end)
end

local function do_reload()
	if not debounce then
		return
	end
	debounce:stop()
	debounce:close()
	debounce = nil
	-- fs_event callbacks run in a fast event context where :colorscheme / API
	-- calls are forbidden (E5560). Defer to the main loop, then re-source.
	vim.schedule(M.reload)
end

local function on_event(err, fname)
	if err then
		return
	end
	if fname and vim.fn.fnamemodify(fname, ":t") ~= "colors" then
		return
	end

	if debounce and not debounce:is_closing() then
		debounce:stop()
	else
		debounce = uv.new_timer()
	end
	debounce:start(100, 0, do_reload)
end

--- Start watching the feed. Idempotent. Returns true when the watcher is up.
function M.start()
	if watching then
		return true
	end
	if vim.fn.isdirectory(feed_dir) ~= 1 or vim.fn.filereadable(feed) ~= 1 then
		vim.notify(
			"skwd-lush: feed not found at " .. feed .. ", feed watcher disabled",
			vim.log.levels.WARN
		)
		return false
	end

	-- Watch the directory, not the file: the daemon rewrites the feed in
	-- place and file-level fsevents have been unreliable across the preview
	-- renderer's write pattern. Directory events filter on the basename.
	fs_handle = uv.new_fs_event()
	fs_handle:start(feed_dir, {}, on_event)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("skwd_lush_watch", {}),
		once = true,
		callback = function()
			M.stop()
		end,
	})

	watching = true
	return true
end

--- Stop the watcher.
function M.stop()
	if fs_handle then
		fs_handle:stop()
		fs_handle:close()
		fs_handle = nil
	end
	if debounce and not debounce:is_closing() then
		debounce:stop()
		debounce:close()
	end
	debounce = nil
	watching = false
end

function M.is_active()
	return watching
end

return M