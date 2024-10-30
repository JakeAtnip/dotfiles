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
    {
        'nanotee/zoxide.vim'
    },
    {
        'akinsho/toggleterm.nvim', 
        version = "*", 
        config = function()
            require("toggleterm").setup{}
            return true
        end
    },
    {
        'justinmk/vim-sneak'
    },
    {
        'sainnhe/gruvbox-material',
        config = function()
            vim.g["gruvbox_material_background"] = "soft"
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
            vim.treesitter.language.register('go', 'templ')
        end
    },
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        -- lsp setup
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

            -- auto complete key bindings
            local cmp = require'cmp'
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete(),
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
            })

            -- lsp key bindings
            vim.keymap.set("n","gd",vim.lsp.buf.definition,{})
            vim.keymap.set("n","gr",vim.lsp.buf.references,{})
            vim.keymap.set("n","gi",vim.lsp.buf.implementation,{})
            vim.keymap.set("n","gh",vim.lsp.buf.hover,{})
            vim.keymap.set("n","gn",vim.lsp.buf.rename,{})
            
            --turn off those annoying snippets for rust
            require'lspconfig'.rust_analyzer.setup{
              settings = {
                ["rust-analyzer"] = {
                  completion = {
                    postfix = {
                      enable = false
                    },
                    addCallArgumentSnippets = false
                  }
                }
              }
            }
        end,
    },
    {
        'mvllow/modes.nvim',
        tag = 'v0.2.0',
        config = function()
            require('modes').setup()
        end
    },
}
require("lazy").setup(plugins)

-- colors
vim.cmd("colorscheme gruvbox-material")
vim.cmd("set termguicolors")

-- general editor configs
vim.opt.more = false 
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.nu = true

-- ############################### START TERMINAL FUNCTIONS ##############################
--if buffer is not terminal buffer then \1, \2, ... does nothing
--if buffer is terminal buffer then \1, \2, ... switches to the appropriate term
--if \j is typed then the terminal is closed if its open, if its closed then
--the last opened term is reopened

function terminal_exists(term_num)
    local term_substring = "term://"
    local term_endswith = "#" .. tostring(term_num)

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(buf)
        local first_part_buf_name = string.sub(buf_name,1,#term_substring)
        local last_part_buf_name = string.sub(buf_name,#buf_name-#term_endswith+1,#buf_name)
        print(first_part_buf_name)
        print(last_part_buf_name)
        if (first_part_buf_name == term_substring) and (last_part_buf_name == term_endswith) then
            return true
        end
    end

    return false
end

function current_buffer_is_term_buffer()
    local cur_buf_name = vim.api.nvim_buf_get_name(0)
    local term_substring = "term://"
    local cmd = ""
    local first_part_buf_name = string.sub(cur_buf_name,1,#term_substring)
    return first_part_buf_name == term_substring
end

_G.last_term_num = 1
function switch_terminal(term_num)
    _G.last_term_num = term_num

    if current_buffer_is_term_buffer() then
        vim.cmd("ToggleTermToggleAll")
        vim.cmd("ToggleTerm" .. tostring(term_num) .. " size=60")

        --get us back in terminal mode
        vim.defer_fn(function()
            vim.cmd("startinsert")
        end, 10)
    end
end

_G.previous_mode = "n"
function open_close_terminal()
    if current_buffer_is_term_buffer() then
        vim.cmd("ToggleTermToggleAll")

        --make sure when are in the mode we were last in
        vim.defer_fn(function()
            if _G.previous_mode == 'n' then
                vim.cmd("stopinsert")  -- Go to normal mode before opening terminal
            else
                vim.cmd("startinsert")  -- Stay in insert mode if it was previously
            end
        end, 10)
    else
        if not terminal_exists(_G.last_term_num) then
            _G.last_term_num = 1
        end

        _G.previous_mode = vim.fn.mode()
        vim.cmd("ToggleTerm" .. tostring(_G.last_term_num) .. " size=60")
    end

end
-- ######################### END TERMINAL FUNCTIONS #####################################

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>t', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
vim.keymap.set('n', '<leader>f', builtin.buffers, {})

-- helper keybindings
vim.keymap.set('n', '<leader>c', ':bd<Enter>', {})
vim.keymap.set('n', '<leader>x', ':bufdo bd<Enter>', {})
vim.keymap.set('n', '<leader>w', ':w<Enter>', {})
vim.keymap.set('n', '<leader>w', ':w<Enter>', {})

-- escape terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', {})

-- open and close terminal
vim.keymap.set('n','<leader>j',open_close_terminal,{})
vim.keymap.set('i','<leader>j',open_close_terminal,{})
vim.keymap.set('t','<leader>j',open_close_terminal,{})

-- switch terminals only in terminal mode
vim.keymap.set('t','<leader>1',function() switch_terminal(1) end,{})
vim.keymap.set('n','<leader>1',function() switch_terminal(1) end,{})
vim.keymap.set('t','<leader>2',function() switch_terminal(2) end,{})
vim.keymap.set('n','<leader>2',function() switch_terminal(2) end,{})
vim.keymap.set('t','<leader>3',function() switch_terminal(3) end,{})
vim.keymap.set('n','<leader>3',function() switch_terminal(3) end,{})
vim.keymap.set('t','<leader>4',function() switch_terminal(4) end,{})
vim.keymap.set('n','<leader>4',function() switch_terminal(4) end,{})
vim.keymap.set('t','<leader>5',function() switch_terminal(5) end,{})
vim.keymap.set('n','<leader>5',function() switch_terminal(5) end,{})
vim.keymap.set('t','<leader>6',function() switch_terminal(6) end,{})
vim.keymap.set('n','<leader>6',function() switch_terminal(6) end,{})
vim.keymap.set('t','<leader>7',function() switch_terminal(7) end,{})
vim.keymap.set('n','<leader>7',function() switch_terminal(7) end,{})
vim.keymap.set('t','<leader>8',function() switch_terminal(8) end,{})
vim.keymap.set('n','<leader>8',function() switch_terminal(8) end,{})
vim.keymap.set('t','<leader>9',function() switch_terminal(9) end,{})
vim.keymap.set('n','<leader>9',function() switch_terminal(9) end,{})

-- helpers for switching between prior buffers
vim.keymap.set('n', '<leader>p',":b#<Enter>", {})
vim.keymap.set('n', '<leader>m',":bn<Enter>", {})
vim.keymap.set('n', '<leader>n',":bp<Enter>", {})
