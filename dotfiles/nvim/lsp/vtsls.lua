local vue_plugin = require("lsp_utils").vue_ts_plugin()
local filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" }

local config = {
    filetypes = filetypes,
}

if vue_plugin then
    table.insert(filetypes, "vue")
    config.settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    vue_plugin,
                },
            },
        },
    }
end

return config
