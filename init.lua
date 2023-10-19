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
        end
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                variant = "moon"
            })
        end,
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
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/nvim-cmp',
            'L3MON4D3/LuaSnip',
        },
        config = function()
            local lsp = require("lsp-zero")
            lsp.nvim_lua_ls()
            
            lsp.on_attach(function(client,bufnr)
                local opts = {buffer= bufnr,remap = false}
                lsp.default_keymaps({buffer = bufnr})
            end)

            lsp.setup()

            vim.diagnostic.config({
                virtual_text = true
            })

            require('mason').setup({}) 
            require('mason-lspconfig').setup({
                handlers = {
                    lsp.default_setup,
                }
            })

            vim.keymap.set("n","gd",vim.lsp.buf.definition,{})
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup{
                direction = "tab"
            }
        end
    },
}
require("lazy").setup(plugins)

--vim.cmd("colorscheme tokyonight-storm")
vim.cmd("colorscheme rose-pine")

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


function switchBuffers(tabNum)
    if string.find(vim.api.nvim_buf_get_name(0),"term://") == nil then
        vim.cmd("BufferGoto " .. tabNum)
    else
        vim.cmd("ToggleTerm" .. tabNum)
    end
end

vim.cmd([[
    function! CleanNoNameEmptyBuffers()
        let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
        if !empty(buffers)
            exe 'bd '.join(buffers, ' ')
        else
            echo 'No buffer deleted'
        endif
    endfunction
]])

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>t', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>c', ':bd!<Enter>', {})
vim.keymap.set('n', '<leader>x', ':bufdo bd<Enter>', {})
vim.keymap.set('n', '<leader>w', ':w<Enter>', {})
vim.keymap.set('n', '<leader>j', ':ToggleTerm<Enter>', {})
vim.keymap.set("n","<leader>o", ":cdo e<Enter> <Esc><C-w>j :bd<Enter> :call CleanNoNameEmptyBuffers()<Enter>" ,{})
vim.keymap.set('n', '<leader>1', function() switchBuffers("1") end, {})
vim.keymap.set('n', '<leader>2', function() switchBuffers("2") end, {})
vim.keymap.set('n', '<leader>3', function() switchBuffers("3") end, {})
vim.keymap.set('n', '<leader>4', function() switchBuffers("4") end, {})
vim.keymap.set('n', '<leader>5', function() switchBuffers("5") end, {})
vim.keymap.set('n', '<leader>6', function() switchBuffers("6") end, {})
vim.keymap.set('n', '<leader>7', function() switchBuffers("7") end, {})
vim.keymap.set('n', '<leader>8', function() switchBuffers("8") end, {})
vim.keymap.set('n', '<leader>9', function() switchBuffers("9") end, {})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>",{})
vim.keymap.set('n', '<leader>p',":b#<Enter>", {})
vim.keymap.set('n', '<leader>m',":bn<Enter>", {})
vim.keymap.set('n', '<leader>n',":bp<Enter>", {})
