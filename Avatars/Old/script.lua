-- Hide vanilla model
vanilla_model.PLAYER:setVisible(false)
models:setSecondaryRenderType("EYES")
-- models:setSecondaryRenderType("Bell")


function events.tick()
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
end
