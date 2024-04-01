-- requirements
require("UwUtils")

-- config --
local config = {
  long_hair = models.CatBoi.root.Head.Long, ---@type ModelPart model part of long hair
  head = models.CatBoi.root.Head, ---@type ModelPart model part of long hair

  velocityStrength = 10,
}

-- code --
if not config.long_hair then
  error("no model part for long hair found")
end
if not config.head then
  error("no model part for long hair found")
end

local defaultLongHairRot = config.long_hair:getRot() ---@type Vector3
local rot = vec(0, 0, 0, 0) ---@type Vector4
local oldRot = vec(0, 0, 0, 0) ---@type Vector4
local vel = vec(0, 0, 0, 0) ---@type Vector4
local oldPlayerRot = nil ---@type Vector4|nil

function events.tick()
  -- set old rot
  oldRot = rot
  -- head velocity
  local playerRot = player:getRot() ---@type Vector2
  if not oldPlayerRot then
    oldPlayerRot = playerRot
  end
  rot.x = math.clamp(playerRot.x, -90, 55)
end

function events.render(delta)
  config.long_hair:setRot(oldRot.x, 0, 0)
end
