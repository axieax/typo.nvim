local typo = require("typo")
local helpers = require("tests.typo.helpers")
local assert_tbl_same_any_order = helpers.assert_tbl_same_any_order

describe("captures new files", function()
  it("does not capture if there are no other files", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, {})

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({}, suggestions)

    helpers.remove_dir(dir)
  end)

  it("does not capture with no prefix", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "blah" })

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({}, suggestions)

    helpers.remove_dir(dir)
  end)

  it("suggests one file and ignores non matches", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "foo.bar", "blah", "random", "format" })

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({ dir .. "/foo.bar" }, suggestions)

    helpers.remove_dir(dir)
  end)

  it("suggests one dir and ignores non matches", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "blah", "random", "format" })
    helpers.create_dir(dir .. "/foo_dir")

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({ dir .. "/foo_dir" }, suggestions)

    helpers.remove_dir(dir)
  end)

  it("suggests multiple files", function()
    local dir = helpers.create_dir()
    local files = { "foo.bar", "foo.bar.baz", "foo.foo", "foo.txt", "fool" }
    local expected = helpers.files_from_dir(dir, files)
    helpers.create_files(dir, files)

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order(expected, suggestions)

    helpers.remove_dir(dir)
  end)

  it("corrects package", function()
    local dir = helpers.create_dir()
    local files = { "package.json", "package-lock.json" }
    local expected = helpers.files_from_dir(dir, files)
    helpers.create_files(dir, files)

    local suggestions = typo.get_possible_files(dir .. "/package")
    assert_tbl_same_any_order(expected, suggestions)

    helpers.remove_dir(dir)
  end)

  it("corrects index", function()
    local dir = helpers.create_dir()
    local files = { "index.js", "index.test.js" }
    local expected = helpers.files_from_dir(dir, files)
    helpers.create_files(dir, files)

    local suggestions = typo.get_possible_files(dir .. "/index")
    assert_tbl_same_any_order(expected, suggestions)

    helpers.remove_dir(dir)
  end)
end)

describe("captures directories", function()
  it("does not capture if there are no other files", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/test"
    helpers.create_dir(test_dir)

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order({}, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("does not capture with no prefix", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/test"
    helpers.create_dir(test_dir)
    helpers.create_files(tmp_dir, { "blah" })

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order({}, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("suggests one file and ignores non matches", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/foo"
    helpers.create_dir(test_dir)
    helpers.create_files(tmp_dir, { "foo.bar", "blah", "random", "format" })

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order({ tmp_dir .. "/foo.bar" }, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("suggests one dir and ignores non matches", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/foo"
    helpers.create_dir(test_dir)
    local foo_dir = tmp_dir .. "/foo_dir"
    helpers.create_dir(foo_dir)
    helpers.create_files(tmp_dir, { "blah", "random", "format" })

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order({ foo_dir }, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("suggests multiple files", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/foo"
    helpers.create_dir(test_dir)
    local files = { "foo.bar", "foo.bar.baz", "foo.foo", "foo.txt", "fool" }
    local expected = helpers.files_from_dir(tmp_dir, files)
    helpers.create_files(tmp_dir, files)

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order(expected, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("corrects lua module", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/typo"
    helpers.create_dir(test_dir)
    helpers.create_files(tmp_dir, { "typo.lua" })

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order({ tmp_dir .. "/typo.lua" }, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("corrects data", function()
    local tmp_dir = helpers.create_dir()
    local test_dir = tmp_dir .. "/data"
    helpers.create_dir(test_dir)
    helpers.create_files(tmp_dir, { "data_clean.py" })

    local suggestions = typo.get_possible_files(test_dir)
    assert_tbl_same_any_order({ tmp_dir .. "/data_clean.py" }, suggestions)

    helpers.remove_dir(tmp_dir)
  end)

  it("corrects git", function()
    local tmp_dir = helpers.create_dir()
    local git_dir = tmp_dir .. "/.git"
    helpers.create_dir(git_dir)
    local github_dir = tmp_dir .. "/.github"
    helpers.create_dir(github_dir)

    local suggestions = typo.get_possible_files(git_dir)
    assert_tbl_same_any_order({ github_dir }, suggestions)

    helpers.remove_dir(tmp_dir)
  end)
end)

describe("captures additional files", function()
  it("excludes itself as a suggestion", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "foo" })

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({}, suggestions)

    helpers.remove_dir(dir)
  end)

  it("suggests one file and ignores non matches", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "foo", "foo.bar", "blah", "random", "format" })

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({ dir .. "/foo.bar" }, suggestions)

    helpers.remove_dir(dir)
  end)

  it("suggests one dir and ignores non matches", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "foo", "blah", "random", "format" })
    helpers.create_dir(dir .. "/foo_dir")

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order({ dir .. "/foo_dir" }, suggestions)

    helpers.remove_dir(dir)
  end)

  it("suggests multiple files", function()
    local dir = helpers.create_dir()
    local files = { "foo.bar", "foo.bar.baz", "foo.foo", "foo.txt", "fool" }
    local expected = helpers.files_from_dir(dir, files)
    helpers.create_files(dir, files)
    helpers.create_files(dir, { "foo" })

    local suggestions = typo.get_possible_files(dir .. "/foo")
    assert_tbl_same_any_order(expected, suggestions)

    helpers.remove_dir(dir)
  end)

  it("corrects logs", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "app.log", "app.log.20221023" })

    local suggestions = typo.get_possible_files(dir .. "/app.log")
    assert_tbl_same_any_order({ dir .. "/app.log.20221023" }, suggestions)

    helpers.remove_dir(dir)
  end)

  it("corrects backup files", function()
    local dir = helpers.create_dir()
    helpers.create_files(dir, { "config.ini", "config.ini.bak", ".zshrc", ".zshrc.bak" })

    local suggestions = typo.get_possible_files(dir .. "/config.ini")
    assert_tbl_same_any_order({ dir .. "/config.ini.bak" }, suggestions)

    suggestions = typo.get_possible_files(dir .. "/.zshrc")
    assert_tbl_same_any_order({ dir .. "/.zshrc.bak" }, suggestions)

    helpers.remove_dir(dir)
  end)
end)
