local M = {}

local config = require("typo.config")
local config_helpers = require("typo.config.helpers")
local utils = require("typo.utils")

function M.get_possible_files(path)
  utils.log(string.format("Finding suggestions for %s (ft: %s)", path, vim.bo.filetype), vim.log.levels.TRACE)
  -- escape %, ? and [ characters
  local escaped_path = string.gsub(path, "[%?%*%[]", function(char)
    return "\\" .. char
  end)
  -- extra glob pattern character "?" excludes original path from matches
  return vim.fn.glob(escaped_path .. "?*", 0, 1)
end

-- TEMP: match glob pattern directly (like autocmd-event)
local function glob_match(path, pattern)
  pattern = vim.fn.glob2regpat(pattern)
  pattern = pattern:gsub("^%^", ""):gsub("%$$", "")
  local regex = vim.regex(pattern)
  return regex and regex:match_str(path) ~= nil
end

--- Open @filename and replace @typo_bufnr if configured to
---@param filename string @file to open
---@param typo_bufnr number @bufnr of original buffer to delete
local function edit_file(filename, typo_bufnr)
  vim.api.nvim_cmd({ cmd = "edit", args = { filename } }, {})
  if config.replace_buffer then
    vim.api.nvim_buf_delete(typo_bufnr, {})
  end
end

--- Find suggestions if there is a typo detected for @current_path
---@param bufnr number|nil @Optional buffer number
---@param current_path string|nil @Optional path to check
---@param from_autocmd|nil @Optional whether this function is called from an autocmd
function M.check(bufnr, current_path, from_autocmd)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  current_path = current_path or vim.api.nvim_buf_get_name(bufnr)
  utils.log(string.format("Checking bufnr: %s, current_path: %s", bufnr, current_path), vim.log.levels.TRACE)

  local possible = M.get_possible_files(current_path)
  possible = vim.tbl_filter(function(path)
    for _, pattern in ipairs(config.ignored_patterns) do
      if glob_match(path, pattern) then
        return false
      end
    end
    return true
  end, possible)
  utils.log("Suggestions: " .. vim.inspect(possible), vim.log.levels.DEBUG)

  if not vim.api.nvim_buf_is_valid(bufnr) then
    utils.log("Buffer is no longer valid", vim.log.levels.DEBUG)
  end

  local should_auto_select = from_autocmd
    and #possible == 1
    and config.autocmd.auto_select
    and not utils.is_existent_file(current_path)
  if should_auto_select then
    utils.log(
      string.format(
        "Auto-select: %s -> %s",
        utils.cast_relative_path(current_path),
        utils.cast_relative_path(possible[1])
      ),
      vim.log.levels.INFO
    )
    edit_file(possible[1], bufnr)
    return
  end

  if #possible > 0 then
    vim.schedule(function()
      vim.ui.select(possible, {
        prompt = "Did you mean?",
        format_item = function(item)
          return utils.cast_relative_path(item)
        end,
      }, function(item)
        if item ~= nil then
          edit_file(item, bufnr)
        end
      end)
    end)
  elseif not from_autocmd then
    utils.log("No typo suggestions", vim.log.levels.INFO)
  end
end

--- Custom setup function
---@param user_config table|nil @Optional config overrides
function M.setup(user_config)
  config_helpers.update_config(user_config or {})
  require("typo.autocmd").setup_autocmd()
end

local function autoload()
  config_helpers.reset_defaults()
  M.setup()
end
autoload()

return M
