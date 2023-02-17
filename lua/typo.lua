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

--- Find suggestions if there is a typo detected for @current_path
---@param bufnr number @Optional buffer number
---@param current_path string @Optional path to check
---@param from_autocmd @Optional whether this function is called from an autocmd
function M.check(bufnr, current_path, from_autocmd)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  current_path = current_path or vim.api.nvim_buf_get_name(bufnr)
  utils.log(string.format("bufnr: %s, current_path: %s", bufnr, current_path), vim.log.levels.TRACE)

  local possible = M.get_possible_files(current_path)
  possible = vim.tbl_filter(function(path)
    for _, pattern in ipairs(config.ignored_patterns) do
      if glob_match(path, pattern) then
        return false
      end
    end
    return true
  end, possible)
  utils.log("" .. vim.inspect(possible), vim.log.levels.DEBUG)

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
  elseif not from_autocmd then
    utils.log("No typo suggestions", vim.log.levels.INFO)
  end
end

local function autoload()
  config_helpers.reset_defaults()
end
autoload()

--- Custom setup function
---@param user_config table @Optional config overrides
function M.setup(user_config)
  config_helpers.update_config(user_config or {})
  require("typo.autocmd").setup_autocmd()
end

return M
