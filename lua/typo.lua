local M = {}

local config = {
  -- General settings
  check_dir = true, -- dir `foo` opened but `foo.lua` exists
  check_empty_file = true, -- non-existent file `foo` opened but `foo.bar` exists
  check_additional_files = false, -- file `foo` exists, but file `foo.bar` also exists
  -- NOTE: above should not work for autocmd? only manual?
  replace_buffer = true,
  ignored_patterns = { "package-lock.json", "*/client/*", "*.swp" },
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

local function should_check(path)
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

function M.check(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local current_path = vim.api.nvim_buf_get_name(bufnr)
  if not should_check(current_path) then
    return
  end

  -- if it has a file extension, then don't worry, but if it doesn't
  -- manually prompt, ignore this case?

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

  if #possible > 0 then
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
  end
end

-- Folder with lua

-- Can activate with key bind, or autocmd (config)
-- Expose an API which can be mapped - if you want to check

-- Actually (general, new file)

-- config - activate on new file (doesn't exist), on keybind, or on folder

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})

  if config.autocmd.enabled then
    local typo = vim.api.nvim_create_augroup("Typo", {})
    vim.api.nvim_create_autocmd("BufOpen", {
      pattern = config.autocmd.pattern,
      group = typo,
      callback = function()
        -- TODO: overrides
        M.check()
      end,
    })
  end
end

return M
