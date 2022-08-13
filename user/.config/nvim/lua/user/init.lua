local M = {}
_G.user = M

M.utils = require "user.utils"
_G.user.utils = M.utils

require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.theme"
require "user.autocommands"
require "user.abbreviations"
