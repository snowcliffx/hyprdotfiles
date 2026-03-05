vim.g.mapleader = " " -- Set <Leader> key to <Space>

-- Enable line numbers
vim.opt.number = true

-- Set tab settings
vim.opt.tabstop = 4      -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4   -- Number of spaces for auto-indent
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.winborder = 'rounded'

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)

vim.diagnostic.config({
  virtual_text = true, -- Set to false if you find it noisy
  signs = true,        -- Show icons in the gutter
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.cmd("set completeopt+=noselect")

require("config.lazy")

vim.lsp.enable('clangd')

require("luau-lsp").setup {
    automatic_enable = {
        exclude = { "luau_lsp" },
    },

    sourcemap = {
        enabled = true,
        autogenerate = true, -- automatic generation when the server is initialized
        rojo_project_file = "default.project.json",
        sourcemap_file = "sourcemap.json",
    },

    plugin = {
        enabled = true,
        port = 3667,
    },

    fflags = {
        enable_new_solver = true, -- enables the fflags required for luau's new type solver
    },
}
