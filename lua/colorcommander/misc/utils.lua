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

M.read_json = function()
  local fd = read_file(vim.fn.expand('~/.local/share/nvim/colorcommander/colornames.json'))
  return vim.json.decode(fd)
end

M.transform_text = function(input)
  local result = string.lower(input)
  -- Reemplazar espacios y símbolos con guiones
  result = string.gsub(result, "['’]", "")
  return string.gsub(result, "%W", "-")
end

M.paste_at_cursor = function(ask, value)
  local result = 'y'
  if ask == true then
    result = vim.api.nvim_eval("input('[ColorCommander.nvim] Would you like to paste the color name? [y]es [n]o: ')")
  end

  if result == "y" then
    for elem in value do
    vim.cmd("normal! i" .. elem)
    vim.print('[ColorCommander.nvim] Paste: ' .. elem)
    end
  end
end

return M
