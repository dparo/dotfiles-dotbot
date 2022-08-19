-- Get the config file path containing the init.lua
local configPath = vim.api.nvim_call_function("stdpath", { "config" })
local dataPath = vim.api.nvim_call_function("stdpath", { "data" })
local cachePath = vim.api.nvim_call_function("stdpath", { "cache" })

vim.o.shell = "zsh"

-- The shada file remembers the last state of vim: command line history, search history, file marks
vim.o.shadafile = cachePath .. "/shada"
vim.o.undodir = cachePath .. "/nvim/undo"

vim.cmd [[
    filetype indent on
    filetype plugin on
    syntax enable
]]

-- Setup the LUA package path so that require-ing works
package.path = configPath .. "/?.lua;" .. package.path
