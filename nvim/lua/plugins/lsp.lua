return {
    -- Mason (unchanged)
    {
        "williamboman/mason.nvim",
        opts = { ui = { border = "rounded" } },
        config = true,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = "mason.nvim",
        opts = { ensure_installed = { "lua_ls", "rust_analyzer" } },
    },


    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        config = function()
            local on_attach = function(_, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                end

                map("gd", vim.lsp.buf.definition, "Go to definition")
                map("K", vim.lsp.buf.hover, "Hover documentation")
                map("<leader>ca", vim.lsp.buf.code_action, "Code action")
                map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")

                local clients = vim.lsp.get_clients({ bufnr = bufnr })

                for _, c in ipairs(clients) do
                    if c.supports_method("textDocument/formatting") then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
                            callback = function()
                                vim.lsp.buf.format({ async = false })
                            end,
                        })

                        break
                    end
                end
            end

            local caps = vim.lsp.protocol.make_client_capabilities()
            caps = vim.tbl_deep_extend("force", caps, require("cmp_nvim_lsp").default_capabilities())

            vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_markers = { ".luarc.json", ".luacheckrc", ".git" },
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
                on_attach = on_attach,
                capabilities = caps,
            }

            vim.lsp.config.rust_analyzer = {
                cmd = { "rust-analyzer" },
                filetypes = { "rust" },
                root_markers = { "Cargo.toml" },
                settings = {
                    ["rust-analyzer"] = {
                        cargo = { allFeatures = true },
                        checkOnSave = true,
                        procMacro = { enable = true },
                    },
                },
                on_attach = on_attach,
                capabilities = caps,
            }

            -- start the servers
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("rust_analyzer")

            -- nicer diagnostic borders
            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                signs = true,
                underline = true,
                float = { border = "rounded", source = "always" },
            })
            vim.lsp.handlers.hover = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
            vim.lsp.handlers.signature_help = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),

                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }),
            })
        end,
    },


}
