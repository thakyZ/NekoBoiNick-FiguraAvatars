---@module  "Random Bottom Fuck Utils" <UwUtils>
---@version v1.0.0
---@see     Neko_Boi_Nick @ https://github.com/thakyZ
---Cum Dumpster

local ID = "UwUtils"
local VER = "1.0.0"
local FIG = { "0.1.0-rc.14", "0.1.4" }

local last_printed = {}; ---@type table

function DoPrint(...)
  local args = { ... }
  if #args ~= #last_printed then
    for i = 1, #args do
      if args[i] ~= last_printed[i] and last_printed[i] ~= nil then
        return
      end
    end
    print(table.unpack(args))
    last_printed = args
  end
end
