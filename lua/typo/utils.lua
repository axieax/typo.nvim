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

return M
