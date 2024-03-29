local default_config = {
  -- open the selected correct file in the current buffer
  replace_buffer = true,
  -- file patterns which shouldn't be suggested (e.g. "package-lock.json")
  ignored_suggestions = { "*.swp" },
  -- display logs with this severity or higher
  log_level = vim.log.levels.INFO,
  autocmd = {
    enabled = true,
    pattern = "*",
    ignored_filetypes = {},
    auto_select = false,

    check_new_file = true, -- non-existent file `foo` opened but `foo.bar` exists
    check_directory = true, -- dir `foo` opened but `foo.lua` exists
    check_additional_files = false, -- file `foo` exists, but file `foo.bar` also exists
  },
}

return default_config
