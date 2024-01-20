local function _set()
  local c = require("darkmatter")
    -- syn_begin: matlab
    -- builtin:
   c.link("matlabSemicolon", "Fg")
   c.link("matlabFunction", "RedItalic")
   c.link("matlabImplicit", "Green")
   c.link("matlabDelimiter", "Fg")
   c.link("matlabOperator", "Operator")
   c.link("matlabArithmeticOperator", "Red")
   c.link("matlabArithmeticOperator", "Red")
   c.link("matlabRelationalOperator", "Red")
   c.link("matlabRelationalOperator", "Red")
   c.link("matlabLogicalOperator", "Red")
end

local M = {}
function M.set()
  _set()
end

return M

