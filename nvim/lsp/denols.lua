return {
    root_dir = function(bufnr, on_dir)
        local root_markers = { "deno.json", "deno.jsonc", "deno.lock" }
        root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
            or vim.list_extend(root_markers, { '.git' })

        local non_deno_path = vim.fs.root(
            bufnr,
            { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
        )
        local project_root = vim.fs.root(bufnr, root_markers)
        if non_deno_path and (not project_root or #non_deno_path >= #project_root) then
            return
        end

        on_dir(project_root or vim.fn.getcwd())
    end,
}
