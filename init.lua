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
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/nvim-cmp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            -- reserve a space in the gutter
            -- avoids an annoying layout shift in the screen
            vim.opt.signcolumn = 'yes'

            -- add cmp_nvim_lsp capabilities settings to lspconfig
            -- this should be executed before you configure any language server
            local lspconfig_defaults = require('lspconfig').util.default_config
            lspconfig_defaults.capabilities = vim.tbl_deep_extend(
                'force',
                lspconfig_defaults.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            local ls = require('luasnip')
            ls.add_snippets('markdown', {
                ls.s('dropdown', {
                    ls.t({"<!-- start question -->",
                    "<details>",
                    "<summary>","",""}),
                    ls.i(1,'question'),
                    ls.t({"","",
                    "</summary>",
                    "",""}),
                    ls.i(2,'answer'),
                    ls.t({"","",
                    "</details>"})
                }),
                ls.s('layout', {
                    ls.t({"---",
                    "layout: '@layouts/Layout.astro'",
                    "---",
                    })
                })
            })

            -- setup auto completion
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end
                },

                sources = cmp.config.sources({
                    {name = 'nvim_lsp'},
                    {name = 'luasnip'}
                }),

                mapping = cmp.mapping.preset.insert({
                  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete(),
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
            })

            -- setup keymappings
            vim.keymap.set("n","gd",vim.lsp.buf.definition,{})
            vim.keymap.set("n","gr",vim.lsp.buf.references,{})
            vim.keymap.set("n","gi",vim.lsp.buf.implementation,{})
            vim.keymap.set("n","gh",vim.lsp.buf.hover,{})
            vim.keymap.set("n","gn",vim.lsp.buf.rename,{})
            vim.keymap.set("n", "ge", vim.diagnostic.open_float, {})

            --setup language servers
            require('mason').setup({})
            require('mason-lspconfig').setup({
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                }
            })

            -- turn off pesky zig ftplugin
            vim.cmd("let g:zig_fmt_autosave = 0")

            -- luasnip setup
        end
    },
    {
        "seblyng/roslyn.nvim",
        ft = "cs",
        opts = {}
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                auto_install=true,
                highlight = {enable = true},
                indent = {enable = true}
            })
            vim.treesitter.language.register('go', 'templ')
        end
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

vim.cmd("colorscheme gruvbox-material")
vim.cmd("set termguicolors")

vim.opt.more = false 
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.nu = true

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

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>t', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
vim.keymap.set('n', '<leader>f', builtin.buffers, {})
vim.keymap.set('n', '<leader>c', ':bd<Enter>', {})
vim.keymap.set('n', '<leader>x', ':bufdo bd<Enter>', {})
vim.keymap.set('n', '<leader>w', ':w<Enter>', {})
vim.keymap.set('n', '<leader>w', ':w<Enter>', {})

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', {})

vim.keymap.set('n','<leader>j',open_close_terminal,{})
vim.keymap.set('i','<leader>j',open_close_terminal,{})
vim.keymap.set('t','<leader>j',open_close_terminal,{})

vim.keymap.set('t','<leader>1',function() switch_terminal(1) end,{})
vim.keymap.set('t','<leader>2',function() switch_terminal(2) end,{})
vim.keymap.set('t','<leader>3',function() switch_terminal(3) end,{})
vim.keymap.set('t','<leader>4',function() switch_terminal(4) end,{})
vim.keymap.set('t','<leader>5',function() switch_terminal(5) end,{})
vim.keymap.set('t','<leader>6',function() switch_terminal(6) end,{})
vim.keymap.set('t','<leader>7',function() switch_terminal(7) end,{})
vim.keymap.set('t','<leader>8',function() switch_terminal(8) end,{})
vim.keymap.set('t','<leader>9',function() switch_terminal(9) end,{})

vim.keymap.set('n', '<leader>p',":b#<Enter>", {})
vim.keymap.set('n', '<leader>m',":bn<Enter>", {})
vim.keymap.set('n', '<leader>n',":bp<Enter>", {})
