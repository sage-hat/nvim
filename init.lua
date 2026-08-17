-- 1. Bootstrap lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)


--  Нумерация строк
vim.opt.number = true

-- Размер табуляции в пробелах
vim.opt.tabstop = 4

-- Размер отступа при нажатии >>
vim.opt.shiftwidth = 4

-- Превращать табуляцию в пробелы
vim.opt.expandtab = true

-- Не переносить длинные строки визуально
vim.opt.wrap = false

-- Включить цвета (терминал)
 vim.opt.termguicolors = true

-- Вертикальная граница 80 символов
vim.opt.colorcolumn = "80"

-- Подсветка пробелов и табуляций
vim.opt.list = true
vim.opt.listchars = {
    trail = "·",    -- пробелы в конце строки
    tab = "→ ",        -- табуляция
}
-- Подсветка парных скобок
vim.opt.showmatch = true 
vim.opt.matchtime = 1

-- После того, как загружена цветовая схема
vim.cmd([[
  highlight SpecialKey guifg=#ff0000 ctermfg=red
  highlight NonText guifg=#ff4444 ctermfg=red
]])

-- 3. Загрузка плагинов

require("lazy").setup({
    -- Указываем, где искать список плагинов
    spec = {
        { import = "plugins" },
    },
    -- Настройки lazy.nvim
    install = {
        colorscheme = { "habamax" },
    },
    checker = {
        enabled = false,  -- автоматическая проверка обновлений
    },
    change_detection = {
        notify = false,  -- не показывать уведомления об изменениях в конфиге
    },
})

vim.diagnostic.config({
    virtual_text = true,   -- ← ЭТО ВКЛЮЧАЕТ ТЕКСТ ОШИБОК
    signs = true,
    underline = true,
    severity_sort = true,
})

-- 4. Горячие клавиши (после загрузки плагинов)

-- Файловый менеджер
vim.keymap.set("n", "<C-e>", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<C-r>", ":NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

-- Поиск файлов
vim.keymap.set("n", "<C-p>", function()
    require("telescope.builtin").find_files()
end, { desc = "Find files" })

vim.keymap.set("n", "<C-f>", function()
    require("telescope.builtin").live_grep()
end, { desc = "Grep in files" })

vim.keymap.set("n", "<C-;>", function()
    require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Find in current file" })

-- Управление сворачиванием
vim.keymap.set("n", "za", "za", { desc = "Toggle fold" })        -- открыть/закрыть блок
vim.keymap.set("n", "zR", "zR", { desc = "Open all folds" })    -- развернуть всё
vim.keymap.set("n", "zM", "zM", { desc = "Close all folds" })   -- свернуть всё
vim.keymap.set("n", "zj", "zj", { desc = "Next fold" })         -- перейти к следующему блоку
vim.keymap.set("n", "zk", "zk", { desc = "Previous fold" })     -- перейти к предыдущему

-- ═══════════════════════════════════════════
-- Подсветка не-ASCII символов
-- ═══════════════════════════════════════════

-- Создаем группу автокоманд, чтобы правило не дублировалось
local non_ascii_group = vim.api.nvim_create_augroup("HighlightNonASCII", { clear = true })

-- Задаем цвет подсветки (красный фон)
vim.cmd([[highlight NonASCII guibg=Red ctermbg=Red]])

-- Применяем правило подсветки при открытии любого файла
vim.api.nvim_create_autocmd("BufReadPost", {
  group = non_ascii_group,
  pattern = "*",
  callback = function()
    vim.fn.matchadd("NonASCII", "[^\\x00-\\x7F]")
  end,
})
-- ═══════════════════════════════════════════
-- Сворачивание блоков кода
-- ═══════════════════════════════════════════

vim.opt.foldmethod = "syntax"     -- сворачивание по синтаксису (для Java)
vim.opt.foldenable = true         -- включить сворачивание
vim.opt.foldlevelstart = 99       -- не сворачивать всё при открытии
vim.opt.foldnestmax = 10          -- максимальная глубина вложенности

-- ═══════════════════════════════════════════
-- Смещение при прокрутке
-- ═══════════════════════════════════════════

vim.opt.scrolloff = 5   -- минимальное количество строк над/под курсором