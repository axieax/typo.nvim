local M = {}

local config = require("typo.config")

--- Logs user warnings
---@param message string @message to log
---@param level integer|nil @log level, defaults to "info"
function M.log(message, level)
  level = level ~= nil and level or vim.log.levels.INFO
  if level >= config.log_level then
    vim.notify("[typo.nvim] " .. message, level)
  end
end

--- Checks whether @path refers to a file that exists on the filesystem
---@param path string @path to check
---@return boolean
function M.is_existent_file(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "file"
end

function M.cast_relative_path(absolute_path)
  return vim.fn.fnamemodify(absolute_path, ":p:.")
end

return M
