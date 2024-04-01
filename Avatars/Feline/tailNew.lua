-- config
local tailConfig = {
   model = models.Feline.Body.tail,

   velocityStrength = vec(3, 3, 1), -- left right, up down, forward backward

   rotVelocityStrength = 2,
   rotVelocityLimit = 20,

   verticalVelocityMin = -20,
   verticalVelocityMax = 1,

   bounce = 0.08, -- how bouncy tail will be
   stiff = 0.17, -- how stiff should tail be 
   waterStiff = 0.5, -- how stiff should tail be underwater
   waterStrength = 0.5, -- how much water will affect tail

   idleSpeed = vec(0, 0, 0), -- how fast should tail move when nothing is happening
   idleStrength = vec(0, 0, 0), -- how much should tail move
   walkSpeed = vec(0, 0.5, 0), -- how much faster should tail move when walking
   walkStrength = vec(0, 6, 0), -- how much tail will move when walking
   walkLimit = 0.31, -- maximum speed that will be used for walkSpeed, set it to 0 to disable
   wagSpeed = vec(0.1, 0.2, 0.1), -- how fast tail moves when wagging with tail
   wagStrength = vec(10, 20, 10), -- how much it should move
   enableWag = {}, -- if any variable in this table is true tail will wag

   tailOffset = 12, -- offset for wag or something
   tailDelay = 6, -- amount of ticks last tail part will be delayed from first one
}

keybinds:newKeybind("tail - wag", "key.keyboard.v")
   :onPress(function() pings.tailWag(true)
      animations.Feline.sway:stop()
      animations.Feline.curl:play() end)
   :onRelease(function() pings.tailWag(false)
      animations.Feline.sway:play()
      animations.Feline.curl:stop() end)

function pings.tailWag(x)
   tailConfig.enableWag.keybind = x
end

-- end of config, magic code starts here
local parts = {}
local defaultRot = {}
local rot, oldRot = {}, {}
local vel = vec(0, 0, 0, 0)
local wagTime, oldWagTime = vec(0, 0, 0), vec(0, 0, 0)
local wagSpeed = vec(0, 0, 0)
local wagStrength, oldWagStrength = vec(0, 0, 0), vec(0, 0, 0)
local tailY = 0

-- find parts
do
   local currentPart = tailConfig.model
   local n, i = currentPart:getName():match("^(.-)(-?%d*)$")
   i = tonumber(i) or 1
   while currentPart do
      table.insert(parts, currentPart)
      table.insert(defaultRot, currentPart:getRot())
      i = i + 1
      currentPart = currentPart[n .. i]
   end
   tailY = parts[1]:getPivot().y / 16
end

-- set default rot tail 
for i = 1, tailConfig.tailDelay do
   rot[i], oldRot[i] = vec(0, 0, 0, 1), vec(0, 0, 0, 1)
end

local function getUnderwaterlevel(pos)
   local y = -1
   for i = -1, 2 do
      local bl = world.getBlockState(pos + vec(0, i, 0))
      if #bl:getFluidTags() >= 1 then
         local waterHeight = 0.85 - (bl.properties.level or 0) / 10
         y = i + waterHeight - pos.y % 1
      end
   end
   return y
end

-- tick
function events.tick()
   -- update rot
   rot[0] = rot[1]
   for i = tailConfig.tailDelay, 1, -1 do
      oldRot[i] = rot[i]
      rot[i] = rot[i - 1]:copy()
   end
   -- update variables
   oldWagTime = wagTime
   oldWagStrength = wagStrength
   -- player velocity
   local bodyRot = player:getBodyYaw(1)
   local playerVelRaw = vectors.rotateAroundAxis(bodyRot, player:getVelocity(), vec(0, 1, 0))
   local bodyVel = (bodyRot - player:getBodyYaw(0) + 180) % 360 - 180
   bodyVel = math.clamp(bodyVel * tailConfig.rotVelocityStrength * 0.2, -tailConfig.rotVelocityLimit, tailConfig.rotVelocityLimit)
   local wagWalkSpeed = tailConfig.walkLimit == 0 and 0 or math.clamp(playerVelRaw.z * tailConfig.velocityStrength.z / tailConfig.walkLimit, 0, 1)
   -- water level
   local tailPos = player:getPos():add(0, tailY, 0)
   local waterLevel = getUnderwaterlevel(tailPos)
   local inWater = math.clamp(waterLevel + 0.5, 0, 1) * tailConfig.waterStrength
   -- body pitch
   local bodyPitch = 0
   local playerPose = player:getPose()
   if playerPose == "SWIMMING" then
      bodyPitch = -90 - (waterLevel > 0 and player:getRot().x or 0)
      inWater = inWater * 0.5
   elseif playerPose == "FALL_FLYING" or playerPose == "SPIN_ATTACK" then
      bodyPitch = -90 - player:getRot().x
      wagWalkSpeed = 0
   end
   playerVelRaw = vectors.rotateAroundAxis(bodyPitch, playerVelRaw, vec(1, 0, 0))
   -- set velocity strength
   local playerVel = playerVelRaw * tailConfig.velocityStrength
   -- apply velocity
   vel = vel * (1 - math.lerp(tailConfig.stiff, tailConfig.waterStiff, inWater))
   vel = vel + (vec(0, 0, 0, 1) - rot[1]) * tailConfig.bounce
   rot[1] = rot[1] + vel

   rot[1].x = rot[1].x + math.clamp(playerVel.y * 5 - inWater * 4, tailConfig.verticalVelocityMin, tailConfig.verticalVelocityMax)
   rot[1].y = rot[1].y + bodyVel * math.max(1 - math.abs(playerVelRaw.x) * 4, 0) + math.clamp(playerVel.x * 20, -2, 2)
   rot[1].w = rot[1].w * math.clamp(1 - playerVel.z - math.abs(bodyVel) * 0.02 + playerVel.y * 0.25 - inWater * 0.25, 0, 1)

   -- wag
   local targetWagSpeed = math.lerp(tailConfig.idleSpeed, tailConfig.walkSpeed, wagWalkSpeed)
   local targetWagStrength = math.lerp(tailConfig.idleStrength, tailConfig.walkStrength, wagWalkSpeed)
   for _, v in pairs(tailConfig.enableWag) do
      if v then
         targetWagSpeed = tailConfig.wagSpeed
         targetWagStrength = tailConfig.wagStrength
         break
      end
   end
   wagSpeed = math.lerp(wagSpeed, targetWagSpeed, 0.15)
   wagStrength = math.lerp(wagStrength, targetWagStrength, 0.15)
   wagTime = wagTime + wagSpeed * (1 - inWater * 0.25)
end

-- render
local function getPartRot(i, delta, time, strength)
   local k = math.floor((i - 1) / #parts * tailConfig.tailDelay) + 1
   local r = math.lerp(oldRot[k], rot[k], delta or 1)
   return r.xyz + defaultRot[i] * r.w + (time - tailConfig.tailOffset * i):applyFunc(math.sin) * strength
end

function events.render(delta)
   local time = math.lerp(oldWagTime, wagTime, delta)
   local strength = math.lerp(oldWagStrength, wagStrength, delta)
   for i, v in pairs(parts) do
      v:setRot(getPartRot(i, delta, time, strength))
   end
end