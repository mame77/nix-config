local vue_plugin = require("lsp_utils").vue_ts_plugin()
local filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" }

local config = {
    filetypes = filetypes,
}

if vue_plugin then
    table.insert(filetypes, "vue")
    config.init_options = {
        plugins = {
            vue_plugin,
        },
    }
end

return config
