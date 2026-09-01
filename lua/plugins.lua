-- ~/.config/nvim/lua/plugins.lua

return {
    -- ═══════════════════════════════════════════
    -- 1. Файловый менеджер
    -- ═══════════════════════════════════════════
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,
                    side = "left",
                },
                renderer = {
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                        },
                    },
                },
                filters = {
                    dotfiles = true,
                },
            })
        end,
    },

    -- ═══════════════════════════════════════════
    -- 2. Быстрый поиск файлов
    -- ═══════════════════════════════════════════
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    file_ignore_patterns = {
                        "node_modules",
                        ".git",
                        "target",
                        "build",
                    },
                },
            })
            telescope.load_extension("fzf")
        end,
    },

    -- ═══════════════════════════════════════════
    -- 3. Улучшенный поиск (fzf-стиль)
    -- ═══════════════════════════════════════════
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
            return vim.fn.executable("make") == 1
        end,
    },

    -- ═══════════════════════════════════════════
    -- 4. Автоматические пары
    -- ═══════════════════════════════════════════
    {
        "windwp/nvim-autopairs",
        version = "*",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                fast_wrap = {
                    map = "<M-e>",
                },
            })
        end,
    },

    -- ═══════════════════════════════════════════
    -- 5. Java LSP (jdtls) — НОВЫЙ API
    -- ═══════════════════════════════════════════
    {
        "mfussenegger/nvim-jdtls",
        version = "*",
        lazy = false,
    },

    -- ═══════════════════════════════════════════
    -- 6. Настройка LSP (НОВЫЙ СПОСОБ)
    -- ═══════════════════════════════════════════
    {
        "neovim/nvim-lspconfig",
        version = "*",
        config = function()
            -- Путь к jdtls
            local jdtls_path = vim.fn.stdpath("data") .. "/jdtls"

            -- Находим launcher jar
            local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

            -- Проверяем, что jdtls установлен
            if launcher_jar == "" then
                vim.notify(
                    "jdtls not found! Please download it to: " .. jdtls_path,
                    vim.log.levels.ERROR
                )
                return
            end

            -- ═══════════════════════════════════════════
            -- НОВЫЙ API: vim.lsp.config
            -- ═══════════════════════════════════════════

            vim.lsp.config("jdtls", {
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.level=ERROR",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens",
                    "java.base/java.util=ALL-UNNAMED",
                    "--add-opens",
                    "java.base/java.lang=ALL-UNNAMED",
                    "-jar",
                    launcher_jar,
                    "-configuration",
                    jdtls_path .. "/config_linux",
                    "-data",
                    vim.fn.getcwd() .. "/.jdtls-workspace",
                },
                root_markers = { ".git", "pom.xml", "build.gradle" },
                filetypes = { "java" },
            })

-- Автоматически запускаем LSP ДЛЯ КАЖДОГО Java-файла
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function(args)
        local bufnr = args.buf
        
        -- Проверяем, есть ли клиент ИМЕННО ДЛЯ ЭТОГО БУФЕРА
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
        if #clients == 0 then
            -- Запускаем LSP и ПРИВЯЗЫВАЕМ к этому буферу
            vim.lsp.start({
                name = "jdtls",
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.level=ERROR",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens",
                    "java.base/java.util=ALL-UNNAMED",
                    "--add-opens",
                    "java.base/java.lang=ALL-UNNAMED",
                    "-jar",
                    launcher_jar,
                    "-configuration",
                    jdtls_path .. "/config_linux",
                    "-data",
                    vim.fn.getcwd() .. "/.jdtls-workspace",
                },
                root_dir = vim.fs.root(0, { ".git", "pom.xml", "build.gradle" }),
                -- ЭТО ГЛАВНОЕ: привязываем к конкретному буферу
                bufnr = bufnr,
            })
        end
    end,
})

            -- Горячие клавиши для LSP
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local opts = { buffer = bufnr }

                    vim.keymap.set("n", "gd", function()
                        vim.lsp.buf.definition()
                    end, opts)

                    vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover()
                    end, opts)

                    vim.keymap.set("n", "gr", function()
                        vim.lsp.buf.references()
                    end, opts)

                    vim.keymap.set("n", "rn", function()
                        vim.lsp.buf.rename()
                    end, opts)

                    vim.keymap.set("n", "ca", function()
                        vim.lsp.buf.code_action()
                    end, opts)
                end,
            })
        end,
    },

    -- ═══════════════════════════════════════════
    -- 7. Автодополнение
    -- ═══════════════════════════════════════════
    {
        "hrsh7th/nvim-cmp",
        version = "*",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")

            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol",
                        maxwidth = 50,
                    }),
                },
                experimental = {
                    ghost_text = false,
                },
            })
        end,
    },

    -- ═══════════════════════════════════════════
    -- 8. Сниппеты
    -- ═══════════════════════════════════════════
    {
        "L3MON4D3/LuaSnip",
        version = "*",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
    },
}