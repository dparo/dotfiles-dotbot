-- Associate to specific path patterns a filetype
require("filetype").setup {
    overrides = {
        complex = {
            ["*.mutt-.*"] = "mail",
            [".*/.config/i3/config"] = "i3config",
            [".envrc"] = "sh",
            [".direnvrc"] = "sh",
            ["direnvrc"] = "sh",
        },
    },
}

local function augroup(group_name, map)
    local group = vim.api.nvim_create_augroup(group_name, { clear = true })

    for _, tbl in map do
        local event = tbl[1]
        local opts = tbl[2]
        opts.group = group
        vim.api.nvim_create_autocmd(event, opts)
    end
end

-- Skeletons for new files
local skeleton_aucmds = vim.api.nvim_create_augroup("DPARO_SKELETONS", { clear = true })
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{h}", command = [[0r ~/.config/nvim/dparo/skeletons/c.h]] }
)
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{hpp}", command = [[0r ~/.config/nvim/dparo/skeletons/c.hpp]] }
)
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{js}", command = [[0r ~/.config/nvim/dparo/skeletons/js.js]] }
)
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{sh,bash}", command = [[0r ~/.config/nvim/dparo/skeletons/sh.sh]] }
)
vim.api.nvim_create_autocmd({ "BufNewFile" }, {
    group = skeleton_aucmds,
    pattern = ".envrc,.direnvrc,direnvrc",
    command = [[0r ~/.config/nvim/dparo/skeletons/.envrc]],
})
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "Makefile", command = [[0r ~/.config/nvim/dparo/skeletons/Makefile]] }
)

local filetypes_aucmds = vim.api.nvim_create_augroup("DPARO_FILETYPES", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = filetypes_aucmds,
    pattern = "gitcommit,gitrebase,gitconfig",
    callback = function()
        vim.bo.bufhidden = "delete"
    end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = filetypes_aucmds,
    pattern = "gitcommit",
    callback = function()
        vim.bo.wrap = true
    end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = filetypes_aucmds,
    pattern = "gitcommit,markdown",
    callback = function()
        vim.bo.spell = true
    end,
})

-- Stop comment continuation when entering a new line inside a comment
vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { group = filetypes_aucmds, pattern = "", command = [[setlocal formatoptions-=cro]] }
)

vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { group = filetypes_aucmds, pattern = "*.config/i3/config", command = [[silent !i3-msg restart]] }
)
vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { group = filetypes_aucmds, pattern = "*.config/sxhkd/sxhkdrc", command = [[silent !pkill -USR1 -x sxhkd]] }
)

local dparo_augroup = vim.api.nvim_create_augroup("DPARO_LUA", { clear = true })
-- Reload the buffer if it was changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = dparo_augroup,
    pattern = "*",
    command = [[if mode() != 'c' | checktime | endif]],
})

-- Notification after file change
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
    group = dparo_augroup,
    pattern = "*",
    command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None]],
})

-- Reset cursor when vim exits
vim.api.nvim_create_autocmd({ "VimLeave" }, {
    group = dparo_augroup,
    pattern = "*",
    command = [[silent !echo -ne "\033]112\007"]],
})

-- Readjusts window dimension when vim changes size
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = dparo_augroup,
    pattern = "*",
    command = [[tabdo wincmd =]],
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
    group = dparo_augroup,
    pattern = "*",
    command = [[set cursorline]],
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
    group = dparo_augroup,
    pattern = "*",
    command = [[set nocursorline]],
})
