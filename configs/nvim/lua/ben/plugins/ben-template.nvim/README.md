# Plugin skeleton

## Development

## Import the plugin

```lua
local M = {
  { dir = "~/.dotfiles/configs/nvim/lua/ben/plugins/ben-tempplate.nvim",
    name = "ben-template",
    config = function()
      require("ben-template")
    end,
  },
}

return M
```
