local M = {}

local read_file = function(file)
  local fd = assert(io.open(file, "r"))
  local data = fd:read("*a")
  fd:close()
  return data
end

-- Modules to export ----------------------------------------------------------

M.convert_color_to_hex = function(line_content, pattern, conversion_function, table_to_insert)
  local x, y, z = line_content:match(pattern)
  local res = nil

  if x and y and z then
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    res = conversion_function(x, y, z)
    if table_to_insert ~= nil then
      table.insert(table_to_insert, res)
    end
  end
  return res
end

M.read_json = function()
  local data = read_file(vim.fn.expand('~/.local/share/nvim/colorcommander/colornames.json'))
  return vim.json.decode(data)
end

M.transform_text = function(input)
  local lower = string.lower(input)
  -- Reemplazar espacios y símbolos con guiones
  local res = string.gsub(lower, "['’]", "")
  res = string.gsub(res, "%W", "-")
  return res
end

M.paste_at_cursor = function(value)
  local res = vim.api.nvim_eval(" input('[ColorCommander.nvim] Would you like to paste the color name? [y]es [n]o: ')")
  if res == "y" then
    vim.cmd("normal! i" .. value)
  end
end

return M
