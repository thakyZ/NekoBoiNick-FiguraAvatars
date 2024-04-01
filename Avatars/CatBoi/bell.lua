-- config --
local config = {
    bell = models.CatBoi.root.Body.Collar.Bell, -- model part of bell on the collar

    velocityStrength = 10,

    extraVelocity = 0,     -- rotates bell by this angle when crouching
    useExtraVelocity = {}, -- if any of variables in this table is true extraAngle will be used even when not crouching

    addVelocity = {},      -- adds angle to bell rotation
}

-- code --
if not config.bell then
    error("no model part for bell found")
end

local defaultBellRot = config.bell:getRot() ---@type Vector3
local rot = vec(0, 0, 0, 0) ---@type Vector4
local oldRot = rot ---@type Vector4
local vel = vec(0, 0, 0, 0) ---@type Vector4
local oldVel = vec(0, 0, 0, 0) ---@type Vector4
local oldPlayerRot = nil ---@type Vector4|nil

function events.tick()
    -- set oldRot
    oldRot = rot
    -- set target rotation velocity
    local targetRotVel = 0 ---@type number
    if player:getPose() == "CROUCHING" then
        targetRotVel = config.extraVelocity
    elseif player:getPose() == "FALL_FLYING" then
        targetRotVel = config.extraVelocity
    elseif player:getVelocity().x > 0 or player:getVelocity().y > 0 or player:getVelocity().z > 0 then
        targetRotVel = config.extraVelocity
    elseif player:getRot().x > 0 or player:getRot().y > 0 then
        targetRotVel = config.extraVelocity
    else
        for _, v in pairs(config.useExtraVelocity) do
            if v then
                targetRotVel = config.extraVelocity
                break
            end
        end
    end
    for _, v in pairs(config.addVelocity) do
        targetRotVel = targetRotVel + v
    end
    -- player velocity
    local playerRot = player:getRot() ---@type Vector2
    if not oldPlayerRot then
        oldPlayerRot = playerRot
    end
    local playerRotVel = (playerRot - oldPlayerRot) * 0.75 * config.velocityStrength
    oldPlayerRot = playerRot
    local playerVel = player:getVelocity() ---@type Vector3
    playerVel = vectors.rotateAroundAxis(playerRot.x, playerVel, vec(1, 0, 0))
    playerVel = vectors.rotateAroundAxis(-playerRot.y, playerVel, vec(0, 1, 0))
    playerVel = playerVel * config.velocityStrength * 40
    -- update velocity and rotation
    vel = vel * 0.6 + (vec(0, 0, 0, targetRotVel) - rot) * 0.2
    rot = rot + vel
    rot.x = rot.x + math.clamp(playerVel.z + playerRotVel.x, -14, 14)
    rot.z = rot.z + math.clamp(-playerVel.x, -6, 6)
    rot.w = rot.w + math.clamp(playerVel.y * 0.25, -4, 4)
end

function events.render(delta)
    local currentRot = math.lerp(oldRot, rot, delta)
    config.bell:setRot(defaultBellRot + currentRot.xyz + currentRot.__w)
end

return config -- by Auria & Neko Boi Nick <3
