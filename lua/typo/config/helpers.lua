local M = {}

local config = require("typo.config")
local default_config = require("typo.config.default")

function M.reset_defaults()
  config._options = default_config
end

function M.update_config(user_config)
  config._options = vim.tbl_deep_extend("force", config._options, user_config)
end

return M
