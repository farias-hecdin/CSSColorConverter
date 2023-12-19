local M = {}
local O = require('colorcommander.utils.config')
local U = require('colorcommander.utils.scripts')
local CNT = require('colorcommander.utils.controller')
local rgb = require("colorcommander.converters.color_rgb")
local hsl = require("colorcommander.converters.color_hsl")
local lch = require("colorcommander.converters.color_lch")

-- Get Hex color
M.get_hex_value = function(line_content, virtual_text)
  local res = nil

  if string.match(line_content, "rgb") then
    res = U.convert_color_to_hex(line_content, "rgb%((%d+), (%d+), (%d+)%)", rgb.rgbToHex, virtual_text)
  elseif string.match(line_content, "hsl") then
    res = U.convert_color_to_hex(line_content, "hsl%((%d+), (%d+)%p?, (%d+)%p?%)", hsl.hslToHex, virtual_text)
  elseif string.match(line_content, "lch") then
    res = U.convert_color_to_hex(line_content, "lch%((%d*%.?%d+)%p? (%d*%.?%d+) (%d*%.?%d+)%)", lch.lchToHex, virtual_text)
  elseif string.match(line_content, "#") then
    res = line_content:match("#[%x][%x][%x][%x][%x][%x]")

    if virtual_text ~= nil then
      local value = M.hex_to(O.options.show_virtual_text_to_hex, res)
      table.insert(virtual_text, value)
      res = value
    end
  else
    res = nil
  end
  return res
end

M.hex_to = function(options, target)
  if options == 'lch' then
    local l, c, h = CNT.hexToLch(target)
    return 'lch('..l ..'% ' ..c ..' ' ..h ..')'
  elseif options == 'hsl' then
    local h, s, l = CNT.hexToHsl(target)
    return 'hsl(' ..h ..', ' ..s ..'%, ' ..l ..'%)'
  elseif options == 'rgb' then
    local r, g, b = CNT.hexToRgb(target)
    return 'rgb(' ..r ..', ' ..g ..', ' ..b ..')'
  else
    return
  end
end

return M
