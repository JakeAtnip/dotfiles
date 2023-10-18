local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

plugins = {
    'justinmk/vim-sneak',
    {
        'sainnhe/gruvbox-material',
        config = function()
            vim.g["gruvbox_material_background"] = "soft"
            vim.cmd("colorscheme gruvbox-material")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                auto_install=true,
                highlight = {enable = true},
            })
        end
    },
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
        config = function()
            require("ibl").setup()
        end
    },
    {
        'romgrk/barbar.nvim',
        dependencies = {'nvim-tree/nvim-web-devicons'},
        config = function()
            require('bufferline').setup {
                animation = false,
                icons = {
                    buffer_index = true,
                },
            }
        end,
    },
}
require("lazy").setup(plugins)

vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=true })

vim.opt.more = false 
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.nu = true

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>t', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>c', ':bd<Enter>', {})
vim.keymap.set('n', '<leader>1' ,':BufferGoto 1<Enter>', {}) 
vim.keymap.set('n', '<leader>2' ,':BufferGoto 2<Enter>', {})
vim.keymap.set('n', '<leader>3' ,':BufferGoto 3<Enter>', {})
vim.keymap.set('n', '<leader>4' ,':BufferGoto 4<Enter>', {})
vim.keymap.set('n', '<leader>5' ,':BufferGoto 5<Enter>', {})
vim.keymap.set('n', '<leader>6' ,':BufferGoto 6<Enter>', {})
vim.keymap.set('n', '<leader>7' ,':BufferGoto 7<Enter>', {})
vim.keymap.set('n', '<leader>8' ,':BufferGoto 8<Enter>', {})
vim.keymap.set('n', '<leader>9' ,':BufferGoto 9<Enter>', {})


vim.keymap.set('n', '<leader>p',":b#<Enter>", {})
