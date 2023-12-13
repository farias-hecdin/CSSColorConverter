local M = {}
local O = require('utils.config')
local U = require('utils.scripts')
local CNT = require('utils.controller')
local rgb = require("converters.color_rgb")
local hsl = require("converters.color_hsl")
local lch = require("converters.color_lch")

-- Get Hex color
M.get_hex_value = function(line_content, virtual_text)
  local res = nil

  if "rgb" == line_content:match("rgb") then
    res = U.convert_color_to_hex(line_content, "rgb%((%d+), (%d+), (%d+)%)", rgb.rgbToHex, virtual_text)
  elseif "hsl" == line_content:match("hsl") then
    res = U.convert_color_to_hex(line_content, "hsl%((%d+), (%d+)%p?, (%d+)%p?%)", hsl.hslToHex, virtual_text)
  elseif "lch" == line_content:match("lch") then
    res = U.convert_color_to_hex(line_content, "lch%((%d*%.?%d+)%p? (%d*%.?%d+) (%d*%.?%d+)%)", lch.lchToHex, virtual_text)
  elseif "#" == line_content:match("#") then
    res = line_content:match("#[%x][%x][%x][%x][%x][%x]")
    if virtual_text ~= nil then
      if type(res) ~= 'nil' then
        local value = M.hex_to(O.options.show_virtual_text_to_hex, res)
        table.insert(virtual_text, value)
        res = value
      end
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
