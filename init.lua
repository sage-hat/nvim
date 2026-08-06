-- 1. Нумерация строк
vim.opt.number = true

-- 2. Вертикальная граница 80 символов
vim.opt.colorcolumn = "80"

-- 3. Подсветка пробелов и табуляций
vim.opt.list = true
vim.opt.listchars = {
	trail = "·",    -- пробелы в конце строки
	tab = "→ ",        -- табуляция
}
-- 4. Подсветка парных скобок (опционально)
vim.opt.showmatch = true
vim.opt.matchtime = 1
