local M = {}

function M.create_dir(path)
  if path then
    local location, err = vim.loop.fs_mkdir(path, 511)
    if err then
      error("Could not create dir: " .. err)
    end
    return location
  end

  local tmp_dir = vim.loop.os_getenv("RUNNER_TEMP") or "/tmp"
  local location, err = vim.loop.fs_mkdtemp(tmp_dir .. "/typo.XXXXXX")
  if err then
    error("Could not create dir: " .. err)
  end
  return location
end

function M.remove_dir(dir)
  if vim.fn.delete(dir, "rf") ~= 0 then
    error("Could not remove dir: " .. dir)
  end
end

function M.create_files(dir, files)
  for _, file in ipairs(files) do
    vim.loop.fs_open(dir .. "/" .. file, "w", 438)
  end
end

function M.files_from_dir(dir, files)
  return vim.tbl_map(function(file)
    return dir .. "/" .. file
  end, files)
end

function M.assert_tbl_same_any_order(expected, actual)
  assert.same(#expected, #actual, "Expected " .. #expected .. " items, got " .. #actual)
  for _, e in ipairs(expected) do
    assert.truthy(vim.tbl_contains(actual, e), "Expected " .. e .. " to be in " .. vim.inspect(actual))
  end
end

return M
