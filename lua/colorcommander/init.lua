local M = {}
local CON = require('colorcommander.utils.config')
local INS = require("colorcommander.utils.installation")
local EXT = require('colorcommander.utils.extraction')
local SCR = require("colorcommander.utils.scripts")
local NEA = require('colorcommander.converters.nearest_color')
local vim = vim

M.setup = function(options)
  -- Merge the user-provided options with the default options
  CON.options = vim.tbl_deep_extend("keep", options or {}, CON.options)
  -- Create user commands
  vim.api.nvim_create_user_command("ColorToName", M.get_colorname, {})
  vim.api.nvim_create_user_command("ColorNameInstall", INS.installation, {})
  vim.api.nvim_create_user_command("ColorPaste", function() M.get_color(false, {}) end, {})
  vim.api.nvim_create_user_command("ColorToHsl", function() M.get_color('hsl') end, {})
  vim.api.nvim_create_user_command("ColorToHex", function() M.get_color('hex') end, {})
  vim.api.nvim_create_user_command("ColorToLch", function() M.get_color('lch') end, {})
  vim.api.nvim_create_user_command("ColorToRgb", function() M.get_color('rgb') end, {})
  -- Create keymaps
  if not CON.options.disable_keymaps then
    vim.api.nvim_set_keymap("n", "<leader>cn", ":ColorToName<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cp", ":ColorPaste<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>ch", ":ColorToHsl<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cH", ":ColorToHex<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cl", ":ColorToLch<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cr", ":ColorToRgb<CR>", { noremap = true, silent = true })
  end
  -- Show virtual text (if enabled)
  if CON.options.show_virtual_text then
    M.virtual_text()
  end
end

M.virtual_text = function()
  M.namespace = vim.api.nvim_create_namespace("color-commander")
  -- Change filtype format from "*.css" to "css"
  local filetypes = {}
  local table_insert = table.insert
  for _, filetype in ipairs(CON.options.filetypes) do
    table_insert(filetypes, "*" .. filetype)
  end
  -- Create an autocommand
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
    pattern = filetypes,
    callback = function()
      M.get_color_details()
    end,
  })
end

M.get_color = function(mode, virtual_text)
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Paste the hex value at the cursor position
  local res = EXT.get_hex_value(line_content, virtual_text)
  if mode and res then
    res = EXT.hex_to(mode, res)
  end
  SCR.paste_at_cursor(false, res)
end

M.get_colorname = function()
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Read the JSON file containing the color names
  local color_names = {}
  local ok, data = pcall(SCR.read_json)
  if not ok then vim.print('Error!')
    return
  end
  color_names = data or {}
  -- Find the nearest color name to the target hex value
  local target_hex = EXT.get_hex_value(line_content, nil)
  color_names = NEA.nearest_color(target_hex, color_names)
  if color_names ~= 'nil' then
    local res = SCR.transform_text(color_names.name)
    vim.print('[ColorCommander.nvim] ' .. target_hex .. ' is equal to: ' .. color_names.name)
    -- Transform the color name and paste at the cursor position
    SCR.paste_at_cursor(true, res)
  end
end

M.get_color_details = function()
  local virtual_text = {}
  -- Get the current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  EXT.get_hex_value(line_content, virtual_text)
  -- Check if an extmark already exists
  local extmark = vim.api.nvim_buf_get_extmark_by_id(0, M.namespace, M.namespace, {})
  if extmark ~= nil then
    vim.api.nvim_buf_del_extmark(0, M.namespace, M.namespace)
  end
  -- If there is virtual text to display, create an extmark
  if #virtual_text > 0 then
    vim.api.nvim_buf_set_extmark(0, tonumber(M.namespace), (line - 1), 0,
      {
        virt_text = { { table.concat(virtual_text, " "), "Comment" } },
        id = M.namespace,
        priority = 100,
      }
    )
  end
end

return M
