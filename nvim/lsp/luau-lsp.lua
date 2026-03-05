return {
    cmd = {'luau-lsp', 'lsp'},
    root_markers = {"default.project.json"},
    filetypes = {'luau', 'lua'},

    settings = {
        ["luau-lsp"] = {
            completion = {
                fillCallArguments = true,
            },
        }
    }
}
