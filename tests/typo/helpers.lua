local M = {}

function M.create_dir(path)
  path = path or "/tmp/typo.XXXXX"
  return vim.loop.fs_mkdtemp(path)
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
  assert.same(#expected, #actual)
  for _, e in ipairs(expected) do
    assert.truthy(vim.tbl_contains(actual, e))
  end
end

return M
