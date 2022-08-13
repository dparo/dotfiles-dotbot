require "funcs"
require "dparo.options"
require "dparo.keymaps"
require "dparo.plugins"


vim.cmd [[ exe "source" $MY_CONFIG_PATH . "/setupColorscheme.vim" ]]

require "dparo.autocommands"

vim.cmd [[ "source" $MY_CONFIG_PATH . "/abbr.vim" ]]
