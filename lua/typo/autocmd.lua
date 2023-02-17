local M = {}

local config = require("typo.config")
local utils = require("typo.utils")

--- Checks whether to proceed with finding typo suggestions
---@param path string @path to check
---@param filetype string @filetype of path
---@return boolean @whether to proceed with the check
function M.should_check(path, filetype)
  utils.log(string.format("Checking %s (ft: %s)", path, filetype), vim.log.levels.TRACE)
  if path == "" or vim.tbl_contains(config.autocmd.ignored_filetypes, filetype) then
    return false
  end

  local stat = vim.loop.fs_stat(path)
  utils.log(path .. ": " .. vim.inspect(stat), vim.log.levels.DEBUG)
  -- Use case 1: file does not exist
  if config.autocmd.check_empty_file and stat == nil then
    return true
  end
  -- Use case 2: directory exists
  if config.autocmd.check_dir and stat and stat.type == "directory" then
    return true
  end
  -- Use case 3: file exists
  if config.autocmd.check_additional_files and stat and stat.type == "file" then
    return true
  end
  return false
end

--- Sets up the autocmd if configured to be enabled
function M.setup_autocmd()
  if config.autocmd.enabled then
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = config.autocmd.pattern,
      group = vim.api.nvim_create_augroup("Typo", {}),
      callback = function(opts)
        utils.log(string.format("%s event triggered for %s", opts.event, opts.match), vim.log.levels.TRACE)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(opts.buf) then
            local filetype = vim.api.nvim_buf_get_option(opts.buf, "filetype")
            if not M.should_check(opts.match, filetype) then
              return
            end

            require("typo").check(opts.buf, opts.match, true)
          else
            utils.log("Buffer is no longer valid", vim.log.levels.WARN)
          end
        end)
      end,
    })
  end
end

return M
