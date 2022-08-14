
-- Speed up loading Lua modules in Neovim to improve startup time
vim.defer_fn(function()
    pcall(require, "impatient")
end, 0)

require "core"
require "user"
