<h1 align="center">🙈 typo.nvim</h1>
<p align="center"><i>Did you mean to open this file instead?</i></p>
<p align="center">
  <a href="https://github.com/neovim/neovim">
    <img alt="Neovim Version" src="https://img.shields.io/static/v1?label=&message=%3E%3D0.7&style=for-the-badge&logo=neovim&color=green&labelColor=302D41"/>
  </a>
  <a href="https://github.com/axieax/typo.nvim/stargazers">
    <img alt="Repo Stars" src="https://img.shields.io/github/stars/axieax/typo.nvim?style=for-the-badge&color=yellow&label=%E2%AD%90&labelColor=302D41"/>
  </a>
  <a href="https://github.com/axieax/typo.nvim">
    <img alt="Repo Size" src="https://img.shields.io/github/repo-size/axieax/typo.nvim?label=&color=orange&logo=hackthebox&style=for-the-badge&logoColor=lightgray&labelColor=302D41"/>
  </a>
</p>

✨ Typo.nvim is a plugin which addresses common typos when opening files in [Neovim](https://neovim.io), suggesting files you probably meant to load instead. This plugin can be configured to detect the following typos:

1. **Accidentally creating a new file**

- Non-existent file `foo` was opened, but `foo.bar` exists.
- Default: enabled
- Examples:
  * `package` opened instead of `package.json` or `package-lock.json`
  * `index` opened instead of `index.js` or `index.test.js`

2. **Accidentally opening a directory instead of a file**

- Directory `foo` was opened, but `foo.lua` exists.
- Default: enabled
- Examples:
  * Lua module `plugin` directory opened instead of `plugin.lua` file
  * `data` directory opened instead of `data_clean.py` file
  * `.git` directory opened instead of `.github` directory

3. **Check additional files**

- Existent file `foo.bar` opened, but `foo.bar.baz` also exists
- Default: disabled
- Examples:
  * `help.ts` opened instead of `help.tsx`
  * `app.log` opened instead of its backup `app.log.20221023`
  * `.zshrc` opened instead of its backup `.zshrc.bak`

... and more to come! This plugin can be easily extensible to detect additional typos due to its design.

https://user-images.githubusercontent.com/62098008/220934819-d3de6e00-9d48-41c4-8a5a-c450df435404.mp4

## 📦 Installation

Install this plugin with your package manager of choice.

- [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use("axieax/typo.nvim")
```

- [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
"axieax/typo.nvim"
```

## ⚙️ Configuration

This plugin works out of the box, so no configuration is required unless you want to adjust certain options with `require("typo").setup()`. Here are the default options users can customize by passing a new table overriding desired fields, to the `setup` function:

```lua
{
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
},
```

## 🗺️ Mappings

This plugin exposes a public API for manually run a typo check on the current buffer. You can set a keymap for this with `vim.keymap.set`, for example:

```lua
vim.keymap.set("n", "\\<Tab>", function()
  require("typo").check()
end, { desc = "Typo check" })
```

## 🚧 Stay Updated

More features are continually being added to this plugin (see [🗺️ Roadmap](https://github.com/axieax/typo.nvim/issues/1)). Feel free to file an issue or create a PR for any features / fixes :)

It is recommended to subscribe to the [🙉 Breaking Changes](https://github.com/axieax/typo.nvim/issues/2) thread to be updated on potentially breaking changes to this plugin, as well as resolution strategies.
