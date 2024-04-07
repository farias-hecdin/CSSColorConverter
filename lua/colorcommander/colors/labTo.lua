local M = {}
local U = require("colorcommander.misc.utils")

M.to_lch = function(l, a, b)
  local c = math.sqrt(a^2 + b^2)
  local h = math.deg(math.atan(b, a))

  if h < 0 then
    h = h + 360
  end
  return U.round(l, 2), U.round(c, 2), U.round(h, 2)
end

return M
