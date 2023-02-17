local M = {}

-- BUG: doesn't play well with neo-tree netrw hijack
-- TODO: handle cwd changes?
-- EXT: search for other similar filenames in entire project directory? (e.g. different init.lua)
-- BUG: check_additional_files infinite loop (whether select or not --> new autocmd)
-- TODO: see if there is a way to not check additional files if just opened from another typo
-- e.g. test/ --> test.lua --> test.lua.txt
-- TODO: find a pattern for directory
-- EXT: ignore if file already has a file extension (only activate if not)

local config = {
  -- General settings
  check_dir = true, -- dir `foo` opened but `foo.lua` exists
  check_empty_file = true, -- non-existent file `foo` opened but `foo.bar` exists
  check_additional_files = false, -- file `foo` exists, but file `foo.bar` also exists
  -- NOTE: above should not work for autocmd? only manual?
  replace_buffer = true,
  ignored_patterns = { "package-lock.json", "*/client/*", "*.swp" },
  ignored_filetypes = { "TelescopePrompt", "neo-tree" },
  -- Autocmd-specific settings
  autocmd = {
    enabled = true,
    pattern = "*",
    -- TODO: move settings here instead of global
    -- and make opts passed into manual call?
  },
}

--[[
Use cases:
1. file `foo` doesn't exist, but `foo.txt` does
2. dir `foo` was opened, but may mean `foo.lua` (only when a dir is opened)
3. file `foo.bar` was opened, but `foo.bar.baz` exists (also suggest??)
]]

local function should_check(path, filetype)
  print("checking", path, filetype, vim.tbl_contains(config.ignored_filetypes, filetype))
  if path == "" or vim.tbl_contains(config.ignored_filetypes, filetype) then
    return false
  end

  local stat = vim.loop.fs_stat(path)
  -- Use case 1: file does not exist
  if config.check_empty_file and stat == nil then
    return true
  end
  -- Use case 2: directory exists
  if config.check_dir and stat and stat.type == "directory" then
    return true
  end
  -- Use case 3: file exists
  if config.check_additional_files and stat and stat.type == "file" then
    return true
  end
  return false
end

function M.get_possible_files(path)
  print("hi", path, vim.bo.filetype)
  -- NOTE: extra glob pattern character "?" excludes original path from matches
  return vim.fn.glob(path .. "?*", 0, 1)
end

-- TEMP: match glob pattern directly (like autocmd-event)
local function glob_match(path, pattern)
  pattern = vim.fn.glob2regpat(pattern)
  pattern = pattern:gsub("^%^", ""):gsub("%$$", "")
  local regex = vim.regex(pattern)
  return regex and regex:match_str(path) ~= nil
end

function M.check(bufnr, current_path)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  current_path = current_path or vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if not should_check(current_path, filetype) then
    return
  end

  local possible = M.get_possible_files(current_path)
  possible = vim.tbl_filter(function(path)
    -- filter ignored patterns
    for _, pattern in ipairs(config.ignored_patterns) do
      if glob_match(path, pattern) then
        return false
      end
    end
    return true
  end, possible)
  vim.pretty_print(possible)

  if #possible > 0 and vim.api.nvim_buf_is_valid(bufnr) then
    vim.schedule(function()
      vim.ui.select(possible, {
        prompt = "Did you mean?",
        format_item = function(item)
          return vim.fn.fnamemodify(item, ":t")
        end,
      }, function(item)
        if item ~= nil then
          vim.api.nvim_cmd({ cmd = "edit", args = { item } }, {})
          if config.replace_buffer then
            vim.api.nvim_buf_delete(bufnr, {})
          end
        end
      end)
    end)
  end
end

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})

  if config.autocmd.enabled then
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = config.autocmd.pattern,
      group = vim.api.nvim_create_augroup("Typo", {}),
      callback = function(opts)
        -- TODO: overrides??
        -- vim.pretty_print("Event", opts)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(opts.buf) then
            M.check(opts.buf, opts.match)
          end
        end)
      end,
    })
  end
end

return M
