local M = {}

function M.vue_ts_plugin()
    local bun_install = os.getenv("BUN_INSTALL")
    if not bun_install then
        return nil
    end

    local vue_language_server_path = bun_install .. "/install/global/node_modules/@vue/language-server"
    if not vim.uv.fs_stat(vue_language_server_path) then
        return nil
    end

    return {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
        configNamespace = "typescript",
    }
end

return M
