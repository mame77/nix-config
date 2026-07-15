-- default
require("pack")
vim.opt.mouse = ""
vim.opt.guicursor = ""
vim.opt.termguicolors = true

-- ui
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 6
vim.opt.wrap = false
vim.opt.pumborder = "rounded"
vim.opt.winborder = "rounded"

-- indent
vim.opt.tabstop = 4
vim.opt.swapfile = false
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.smartcase = true
vim.opt.splitright = true
vim.diagnostic.config({ virtual_text = { current_line = true, }, })

-- auto completion
vim.opt.complete = 'o'
vim.opt.pumheight = 10
vim.opt.completeopt = { "menuone", "noinsert" }
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method('textDocument/completion') then
            client.server_capabilities.completionProvider.triggerCharacters = nil
            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = true,
                convert = function(item)
                    return {
                        abbr = item.label:gsub('%b()', ''),
                        menu = '',
                    }
                end,
            })
        end
    end,
})
vim.keymap.set('i', '<CR>', function()
    return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true })

-- vim pack
vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter',    version = 'main' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
    { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
    { src = 'https://github.com/nvim-mini/mini.pick' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
    { src = 'https://github.com/folke/noice.nvim' },
    { src = 'https://github.com/petertriho/nvim-scrollbar' },
    { src = 'https://github.com/catppuccin/nvim' },
});

-- require
require("scrollbar").setup({
    handlers = { cursor = false },
    handle = { color = "#CCCCCC" },
})
require('gitsigns').setup()
require('mini.pick').setup()
require("noice").setup({ presets = { command_palette = true } })
require("ibl").setup({ indent = { char = '│' }, scope = { enabled = false }, })
require('oil').setup({ view_options = { show_hidden = true, }, win_options = { winbar = "%#@attribute.builtin#%{substitute(v:lua.require('oil').get_current_dir(), '^' . $HOME, '~', '')}", }, })

-- treesitter
require('nvim-treesitter').install({ 'lua', 'go', 'vue', 'html', 'scss', 'css', 'typescript', 'javascript', 'tsx' });
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'lua', 'go', 'vue', 'html', 'scss', 'css', 'typescript', 'javascript', 'tsx', 'jsx' },
    callback = function() vim.treesitter.start() end,
})

-- keymaps
vim.g.mapleader = ' '
vim.keymap.set('n', 'grd', vim.lsp.buf.definition);
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float);
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
vim.keymap.set('n', '<leader>o', vim.cmd.Oil);
vim.keymap.set('n', '<leader>l', vim.lsp.buf.format);
vim.keymap.set('n', '<leader>f', ':Pick files<CR>');
vim.keymap.set('n', '<leader>g', ':Pick grep<CR>');
vim.keymap.set('n', '<leader>b', ':Pick buffers<CR>');
vim.keymap.set('n', '<leader>u', ':vsp<CR>:Pick files<CR>')
vim.keymap.set('n', '<leader>d', function() vim.diagnostic.setqflist({ vim.diagnostic.severity.ERROR }) end);

--lsp
vim.lsp.enable('gopls')
if vim.fn.executable('vtsls') == 1 then
    vim.lsp.enable('vtsls')
else
    vim.lsp.enable('ts_ls')
end
vim.lsp.enable('lua_ls')
vim.lsp.enable('bashls')
vim.lsp.enable('yamlls')
vim.lsp.enable('emmet_ls')
if vim.fn.executable('vue-language-server') == 1 then
    vim.lsp.enable('vue_ls')
end
if vim.fn.executable('deno') == 1 then
    vim.lsp.enable('denols')
end

-- colorscheme
vim.cmd('colorscheme catppuccin-mocha')

-- transparency
vim.api.nvim_set_hl(0, 'Normal',     { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn',  { bg = 'none' })
vim.api.nvim_set_hl(0, 'FoldColumn',  { bg = 'none' })
vim.api.nvim_set_hl(0, 'LineNr',      { bg = 'none' })
vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = 'none' })
vim.opt.winblend = 10
