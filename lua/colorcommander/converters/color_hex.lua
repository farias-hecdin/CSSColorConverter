local M = {}
local rgb = require("colorcommander.converters.color_rgb")

M.hexToRgb = function(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

M.hexToHsl = function(hex)
  local r, g, b = M.hexToRgb(hex)
  return rgb.rgbToHsl(r, g, b)
end

return M
