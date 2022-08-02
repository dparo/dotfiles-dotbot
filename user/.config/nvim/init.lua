-- Get the config file path containing the init.lua
local configPath = vim.api.nvim_call_function('stdpath', {'config'})
local dataPath = vim.api.nvim_call_function('stdpath', {'data'})

-- Set MY_CONFIG_PATH environment variable to point to my config directory
vim.env.MY_CONFIG_PATH = configPath .. '/dparo'

local function filename_escape(p)
    return vim.api.nvim_call_function('fnameescape', { p })
end

vim.o.shell = 'zsh'

-- The shada file remembers the last state of vim: command line history, search history, file marks
vim.o.shadafile = dataPath .. '/shada/main.shada'

vim.cmd [[
    filetype indent on
    filetype plugin on
    syntax enable
]]


-- Setup the LUA package path so that require-ing works
package.path = configPath .. '/?.lua;' .. package.path

-- Another possible path to setup in order to avoid typing `require(USER/myThingy)` and just type `require(myThing)`
---- package.path = vim.env.MY_CONFIG_PATH .. '/?.lua;' .. package.path

local function fileexists(p)
    return vim.api.nvim_call_function('filereadable', {
        filename_escape(p)
    })
end


-- Try source init.vim if it exists, or require-ing init.lua file if it exists.
_G.reload_nvim_config = function()
    local initVim = vim.env.MY_CONFIG_PATH .. '/init.vim'
    local initLua = vim.env.MY_CONFIG_PATH .. '/init.lua'

    if fileexists(initVim) then
        vim.cmd('source ' .. filename_escape(initVim))
    elseif fileexists(initLua) then
        require(initLua)
    end
end


reload_nvim_config()
