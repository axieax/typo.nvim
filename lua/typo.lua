local M = {}

local config = require("typo.config")
local config_helpers = require("typo.config.helpers")
local utils = require("typo.utils")

--- Get possible file typo suggestions beginning with @path
---@param path string @path to check
---@return string[] @possible suggestions filtered to exclude ignored patterns
function M.get_possible_files(path)
  utils.log(string.format("Finding suggestions for %s (ft: %s)", path, vim.bo.filetype), vim.log.levels.TRACE)
  -- escape %, ? and [ characters
  local escaped_path = string.gsub(path, "[%?%*%[]", function(char)
    return "\\" .. char
  end)

  -- extra glob pattern character "?" excludes original path from matches
  local possible = vim.fn.glob(escaped_path .. "?*", 0, 1)
  return vim.tbl_filter(function(path)
    for _, pattern in ipairs(config.ignored_suggestions) do
      if utils.glob_match(path, pattern) then
        return false
      end
    end
    return true
  end, possible)
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
  utils.log("Suggestions: " .. vim.inspect(possible), vim.log.levels.DEBUG)

  if not vim.api.nvim_buf_is_loaded(bufnr) then
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
    utils.edit_file(possible[1], bufnr)
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
          utils.edit_file(item, bufnr)
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
