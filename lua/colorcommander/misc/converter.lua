local M = {}
local CC_config = require('colorcommander.misc.config')
local rgb = require("colorcommander.colors.rgbTo")
local hex = require("colorcommander.colors.hexTo")
local xyz = require("colorcommander.colors.xyzTo")
local lab = require("colorcommander.colors.labTo")
local hsl = require("colorcommander.colors.hslTo")
local lch = require("colorcommander.colors.lchTo")

M.color_value = function(line_content, virtual_text, mode)
  local color_formats = {
    { key = "rgb", pattern = "rgb%(%d+, %d+, %d+%)", value = "rgb%((%d+), (%d+), (%d+)%)" },
    { key = "hsl", pattern = "hsl%(%d+, %d+%p?, %d+%p?%)", value = "hsl%((%d+), (%d+)%p?, (%d+)%p?%)" },
    { key = "lch", pattern = "lch%(%d+%.?%d+%p? %d+%.?%d+ %d+%.?%d+%)", value = "lch%((%d+%.?%d+)%p? (%d+%.?%d+) (%d+%.?%d+)%)" },
    { key = "#", pattern = "#[%x][%x][%x][%x][%x][%x]", value = "" }
  }

  local target_format = mode or string.lower(CC_config.options.target_color_format)

  local result = {}
  for _, format in ipairs(color_formats) do
    local matches = string.gmatch(line_content, format.pattern)

    for input in matches do
      local current_format = format.key
      local n1, n2, n3 = 0, 0, 0
      -- to HEX
      if target_format == "hex" then
        if current_format == "rgb" then
          result[#result + 1] = rgb.to_hex(select(1, string.match(input, format.value)))
        elseif current_format == "hsl" then
          result[#result + 1] = hsl.to_hex(select(1, string.match(input, format.value)))
        elseif current_format == "lch" then
          result[#result + 1] = lch.to_hex(select(1, string.match(input, format.value)))
        else
          result[#result + 1] = input
        end
      -- to RGB
      elseif target_format == "rgb" then
        if current_format == "#" then
          n1, n2, n3 = hex.to_rgb(input)
          result[#result + 1] = string.format('rgb(%d, %d, %d)', n1, n2, n3)
        elseif current_format == "hsl" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = hex.to_rgb(hsl.to_hex(tonumber(x), tonumber(y), tonumber(z)))
          result[#result + 1] = string.format('rgb(%d, %d, %d)', n1, n2, n3)
          end
        elseif current_format == "lch" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = hex.to_rgb(lch.to_hex(tonumber(x), tonumber(y), tonumber(z)))
          result[#result + 1] = string.format('rgb(%d, %d, %d)', n1, n2, n3)
          end
        else
          result[#result + 1] = input
        end
      -- to HSL
      elseif target_format == "hsl" then
        if current_format == "rgb" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = rgb.to_hsl(tonumber(x), tonumber(y), tonumber(z))
            result[#result + 1] = string.format('hsl(%d, %d, %d)', n1, n2, n3)
          end
        elseif current_format == "lch" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = rgb.to_hsl(hex.to_rgb(lch.to_hex(tonumber(x), tonumber(y), tonumber(z))))
            result[#result + 1] = string.format('hsl(%d, %d, %d)', n1, n2, n3)
          end
        elseif current_format == "#" then
          n1, n2, n3 = rgb.to_hsl(hex.to_rgb(input))
          result[#result + 1] = string.format('hsl(%d, %d, %d)', n1, n2, n3)
        else
          result[#result + 1] = input
        end
      -- to LCH
      elseif target_format == "lch" then
        if current_format == "#" then
          n1, n2, n3 = hex.to_rgb(input)
          n1, n2, n3 = lab.to_lch(xyz.to_lab(rgb.to_xyz(n1, n2, n3)))
            result[#result + 1] = string.format('lch(%d%, %d, %d)', n1, n2, n3)
        elseif current_format == "rgb" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = lab.to_lch(xyz.to_lab(rgb.to_xyz(tonumber(x), tonumber(y), tonumber(z))))
            result[#result + 1] = string.format('lch(%d%, %d, %d)', n1, n2, n3)
          end
        elseif current_format == "hsl" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = lab.to_lch(xyz.to_lab(rgb.to_xyz(hex.to_rgb(hsl.to_hex(tonumber(x), tonumber(y), tonumber(z))))))
            result[#result + 1] = string.format('lch(%d%, %d, %d)', n1, n2, n3)
          end
        else
          result[#result + 1] = input
        end
      end
    end
  end

  if not mode then
    for i = 1, #result do
      table.insert(virtual_text, result[i])
    end
  end

  return result
end

return M
