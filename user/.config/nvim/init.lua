-- Get the config file path containing the init.lua
local configPath = vim.api.nvim_call_function("stdpath", { "config" })
local dataPath = vim.api.nvim_call_function("stdpath", { "data" })

-- Set MY_CONFIG_PATH environment variable to point to my config directory
vim.env.MY_CONFIG_PATH = configPath .. "/dparo"

vim.o.shell = "zsh"

-- The shada file remembers the last state of vim: command line history, search history, file marks
vim.o.shadafile = dataPath .. "/shada/main.shada"

vim.cmd [[
    filetype indent on
    filetype plugin on
    syntax enable
]]

-- Setup the LUA package path so that require-ing works
package.path = configPath .. "/?.lua;" .. package.path

require "dparo.init"
