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

--- Casts an absolute path to a relative path from the cwd
---@param absolute_path string @path to be cast
---@return string @relative reference to @absolute_path
function M.cast_relative_path(absolute_path)
  return vim.fn.fnamemodify(absolute_path, ":p:.")
end

--- Matches @path against @glob_pattern
---@param path string @path to match
---@param glob_pattern string @glob pattern
---@return boolean
function M.glob_match(path, glob_pattern)
  glob_pattern = vim.fn.glob2regpat(glob_pattern)
  glob_pattern = glob_pattern:gsub("^%^", ""):gsub("%$$", "")
  local regex = vim.regex(glob_pattern)
  return regex and regex:match_str(path) ~= nil
end

--- Open @filename and replace @typo_bufnr if configured to
---@param filename string @file to open
---@param typo_bufnr number @bufnr of original buffer to delete
function M.edit_file(filename, typo_bufnr)
  vim.api.nvim_cmd({ cmd = "edit", args = { filename } }, {})
  if config.replace_buffer then
    vim.api.nvim_buf_delete(typo_bufnr, {})
  end
end

return M
