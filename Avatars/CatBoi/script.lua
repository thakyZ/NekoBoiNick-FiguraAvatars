-- requirements
require("GSAnimBlend")
require("UwUtils")

local validNames = { "nekoboinick", "thakyZ" }

-- animations.CatBoi.sway:setBlendTime(5)
-- animations.CatBoi.curl:setBlendTime(5)

-- animations.CatBoi.sway:play()

-- Hide vanilla model
vanilla_model.PLAYER:setVisible(false)
models.CatBoi.Skull:setVisible(true)
models:setSecondaryRenderType("EYES")


--- Checks if name is in variable validNames
---@see validNames
---@param name string The name to check
---@return boolean
function CheckIfHas(name)
  local sub_name = name:gsub("'s Head", "") ---@type string
  local contains = table.contains(validNames, sub_name) ---@type boolean
  return contains
end

function events.skull_render(delta, block, item, entity, mode)
  if not player:isLoaded() then
    if block then
      local blockData = block:getEntityData()
      if blockData then
        local checked = CheckIfHas(blockData.SkullOwner.Name) --- @type boolean
        if blockData and checked then
          return true
        end
      end
    elseif item then
      local itemData = item:getName()
      local checked = CheckIfHas(itemData) --- @type boolean
      if checked then
        if mode == "HEAD" then
          models.CatBoiHead.Item:setVisible(true)
          return true
        else
          return false
        end
      else
        if mode == "HEAD" then
          models.CatBoi.Head:setVisible(false)
          vanilla_model.PLAYER:setVisible(true)
          return false
        end
      end
    elseif entity then
      local entityData = entity:getNbt()
      local checked = CheckIfHas(entityData.tag.SkullOwner.Name) --- @type boolean
      print("checkede =", checked)
      if checked then
        models.CatBoiHead.Item:setVisible(true)
        return true
      end
    end
    models.CatBoi.Head:setVisible(true)
  end
  return false
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function events.tick()
  if player:isLoaded() then
    local item = player:getItem(6) ---@type ItemStack?
    if item then
      if item.id:match("minecraft:%w+_head") then
        if not CheckIfHas(item:getName()) then
          vanilla_model.HELMET:setVisible(true)
          models.CatBoi.root.Head:setVisible(false)
        else
          vanilla_model.HELMET:setVisible(false)
          models.CatBoi.root.Head:setVisible(true)
        end
      else
        vanilla_model.HELMET:setVisible(true)
        models.CatBoi.root.Head:setVisible(true)
      end
    else
      vanilla_model.HELMET:setVisible(true)
      models.CatBoi.root.Head:setVisible(true)
    end
    --[[
    local crouching = player:getPose() == "CROUCHING"
    -- This detects if you are crouching and stores it into crouch.
    -- So: crouch == true when crouching, and crouch == false when you're not crouching
    local walking = player:getVelocity().xz:length() > .01
    -- walking == true when moving, and walking == false when still (or going directly up/down as we excluded the y axis)
    local sprinting = player:isSprinting()
    -- If you want to find more player functions, check out the Player Global page

    -- Now we're going to use a lot of logic to figure out when animations should/shouldn't play
    animations.model_figure.idle:setPlaying(not walking and not crouching)
    -- You're idle when not walking and not crouching
    animations.model_figure.walk:setPlaying(walking and not crouching and not sprinting)
    -- You're walking when... walking and not crouching, but you want to make sure you're not sprinting either
    animations.model_figure.walk:setPlaying(sprinting and not crouching)
    -- You probably can catch my drift by now
    animations.model_figure.crouch:setPlaying(crouching)
    ]]
  end
end
