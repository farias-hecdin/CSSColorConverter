local M = {}
local hex = require("colorcommander.converters.color_hex")
local rgb = require("colorcommander.converters.color_rgb")
local other = require('colorcommander.converters.color_xyz_and_lab')

M.hexToLch = function(target)
  local a, b, c = hex.hexToRgb(target)
  a, b, c = rgb.rgbToXyz(a, b, c)
  a, b, c = other.xyzToLab(a, b, c)
  return other.labToLch(a, b, c)
end

M.hexToHsl = function(target)
  return hex.hexToHsl(target)
end

M.hexToRgb = function(target)
  return hex.hexToRgb(target)
end

return M
