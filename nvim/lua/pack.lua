vim.api.nvim_create_user_command('PackClean', function()
    local plugins = {}
    for _, plugin in ipairs(vim.pack.get()) do
        table.insert(plugins, plugin.spec.name)
    end
    vim.pack.del(plugins)
    vim.cmd.restart()
end, {})
