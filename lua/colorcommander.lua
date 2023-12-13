local M = {}
local O = require('utils.config')
local C = require("utils.installation")
local E = require('utils.extraction')
local U = require("utils.scripts")
local N = require('converters.nearest_color')

local plugin_name = "[ColorCommander.nvim]"

M.setup = function(options)
  O.options = vim.tbl_deep_extend("keep", options or {}, O.options)
  -- Create commands
  vim.api.nvim_create_user_command("ColorToName", M.get_colorname, {})
  vim.api.nvim_create_user_command("ColorNameInstall", C.installation, {})
  vim.api.nvim_create_user_command("ColorPaste", M.get_color, {})
  -- and keymaps
  if not O.options.disable_keymaps then
    vim.api.nvim_set_keymap("n", "<leader>cn", ":ColorToName<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>cp", ":ColorPaste<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>ch", ":ColorToHex<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>cH", ":ColorToHsl<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>cr", ":ColorToRgb<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>cl", ":ColorToLch<CR>", { noremap = true, silent = true })
  end

  if O.options.show_virtual_text then
    M.virtual_text()
  end
  return O.options
end

M.virtual_text = function()
  M.namespace = vim.api.nvim_create_namespace("color-commander")
  -- Change filtype format from "*.css" to "css"
  local filetypes = {}
  local table_insert = table.insert
  for _, filetype in ipairs(O.options.filetypes) do
    table_insert(filetypes, "*" .. filetype)
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
    pattern = filetypes,
    callback = function()
      M.get_color_details()
    end,
  })
end

M.get_color = function()
  local virtual_text = {}
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

  local res = E.get_hex_value(line_content, virtual_text)
  U.paste_at_cursor(false, res)
end

M.get_colorname = function()
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

  local target_hex = E.get_hex_value(line_content, nil)
  local res = nil

  local color_names = U.read_json() or nil
  if not color_names then
    vim.print('Error!')
    return
  end

  color_names = N.nearest_color(target_hex, color_names)
  if color_names ~= 'nil' then
    res = color_names.name
    vim.print(plugin_name .. ' ' .. target_hex .. ' is equal to: ' .. res)

    res = U.transform_text(res)
    U.paste_at_cursor(true, res)
  end
end

M.get_color_details = function()
  local virtual_text = {}
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  E.get_hex_value(line_content, virtual_text)

  -- Check if an extmark already exists
  local extmark = vim.api.nvim_buf_get_extmark_by_id(0, M.namespace, M.namespace, {})
  if extmark ~= nil then
    vim.api.nvim_buf_del_extmark(0, M.namespace, M.namespace)
  end
  -- Config extmark
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
