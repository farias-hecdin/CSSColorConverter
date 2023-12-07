local M = {}
local U = require("utils.utils")

function M.xyzToLab(x, y, z)
  local D65 = {95.047, 100, 108.883}

  local xn = x / D65[1]
  local yn = y / D65[2]
  local zn = z / D65[3]

  local f = function(v)
    return v > 0.008856 and v^(1 / 3) or v * 7.787 + 16 / 116
  end

  local fx = f(xn)
  local fy = f(yn)
  local fz = f(zn)

  local l = 116 * fy - 16
  local a = 500 * (fx - fy)
  local b = 200 * (fy - fz)

  return l, a, b
end

function M.labToLch(l, a, b)
  local c = math.sqrt(a^2 + b^2)
  local h = math.deg(math.atan2(b, a))

  if h < 0 then
    h = h + 360
  end
  return U.round(l, 2), U.round(c, 2), U.round(h, 2)
end

return M
