local M = {}
local O = require('options')
local U = require('utils.utils')
local convert = require('convert')
local rgb = require("utils.color_rgb")
local hex = require("utils.color_hex")
local hsl = require("utils.color_hsl")
local lch = require("utils.color_lch")

local plugin_name = "[ColorCommander.nvim]"

-- Check if a file or directory exists in this path (Thanks to: https://stackoverflow.com/a/40195356)
local exists = function(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end

-- Check if a directory exists in this path
local isdir = function(path)
  -- "/" works on both Unix and Windows
  return exists(path)
end

local download_file = function(url, file)
  -- Thank to: https://www.reddit.com/r/neovim/comments/pa4yle/help_with_async_in_lua/
  local job = require('plenary.job')

  job:new({
    command = 'curl',
    args = { url, '-s', '-o', file },
    on_start = function()
      vim.print(plugin_name .. ' Downloading colornames.json...')
    end,
    on_exit = function(j, exit_code)
      local type = plugin_name .. " Success!"

      if exit_code ~=0 then
        type = plugin_name .. " Error!"
      end
      vim.print(type)
    end,
  }):start()
end

-- Modules to export ----------------------------------------------------------

M.core = function()
  local path, dirname = vim.fn.expand('~/.local/share/nvim/'), "colorcommander"
  local dir, err = isdir(path .. dirname)

  if not dir then
    os.execute("mkdir " .. path .. dirname)
    download_file(
      "https://unpkg.com/color-name-list@10.16.0/dist/colornames.json",
      path .. dirname .. '/colornames.json'
    )
  else
    vim.print(plugin_name .. ' The colorname.json file has been downloaded.')
  end
end

-- Get Hex color
M.get_hex_value = function(line_content, virtual_text)
  local res = nil

  if "rgb" == line_content:match("rgb") then
    res = U.convert_color_to_hex(line_content, "rgb%((%d+), (%d+), (%d+)%)", rgb.rgbToHex, virtual_text)
  end
  if "hsl" == line_content:match("hsl") then
    res = U.convert_color_to_hex(line_content, "hsl%((%d+), (%d+)%p?, (%d+)%p?%)", hsl.hslToHex, virtual_text)
  end
  if "lch" == line_content:match("lch") then
    res = U.convert_color_to_hex(line_content, "lch%((%d*%.?%d+)%p? (%d*%.?%d+) (%d*%.?%d+)%)", lch.lchToHex, virtual_text)
  end
  if "#" == line_content:match("#") then
    res = line_content:match("#[%x][%x][%x][%x][%x][%x]")

    if virtual_text ~= nil then
      if type(res) ~= 'nil' then
        local value = M.hex_text(O.options.show_virtual_text_to_hex, res)
        table.insert(virtual_text, value)
        res = value
      end
    end
  end

  return res
end

function M.hex_text(options, target)
  if options == 'lch' then
    local l, c, h = convert.hexToLch(target)
    return 'lch('..l ..'% ' ..c ..' ' ..h ..')'
  end
end

return M
