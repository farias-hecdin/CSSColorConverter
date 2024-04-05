local vLog = require("colorcommander.log").info

local M = {}
local vim = vim

local function read_file(file)
  local fd = assert(io.open(file, "r"))
  local data = fd:read("*a")
  fd:close()
  return data
end

M.round = function(number, decimals)
  local power = 10 ^ decimals
  return math.floor(number * power + 0.5) / power
end

-- !---------------------------------------------------------------------------:

M.convert_color_to_hex = function(line_content, pattern, conversion_function, table_to_insert)
  local res = nil
  local a, b, c

  for x, y, z in string.gmatch(line_content, pattern) do
    if x and y and z then
      a, b, c = tonumber(x), tonumber(y), tonumber(z)
      res = conversion_function(a, b, c)
      if table_to_insert ~= nil then
        table.insert(table_to_insert, res)
      end
    end
  end
  vLog(table_to_insert)
  return res
end

M.read_json = function()
  local fd = read_file(vim.fn.expand('~/.local/share/nvim/colorcommander/colornames.json'))
  return vim.json.decode(fd)
end

M.transform_text = function(input)
  local res = string.lower(input)
  -- Reemplazar espacios y símbolos con guiones
  res = string.gsub(res, "['’]", "")
  return string.gsub(res, "%W", "-")
end

M.paste_at_cursor = function(ask, value)
  local res = 'y'
  if ask == true then
    res = vim.api.nvim_eval("input('[ColorCommander.nvim] Would you like to paste the color name? [y]es [n]o: ')")
  end
  if res == "y" then
    vim.cmd("normal! i" .. value)
    vim.print('[ColorCommander.nvim] Paste: ' .. value)
  end
end

return M
