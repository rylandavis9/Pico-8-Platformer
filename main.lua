
player = {}
function _init()
		
  init_player()
  gravity = .15
		friction = .85
		terminalv = 3
		current_frame = 1

end
function init_player()
  player.homex = 64
  player.homey = 48
  player.x = 64            
  player.y = 48            
  player.vx = 0         
  player.vy = .1
  player.jump = -3         
  player.speed = 2            
  player.sprite = 1        
		player.h = 8
		player.w = 8 
		player.grounded = false
		player.walk_anim = {17, 33}
		player.up_anim = 18
		player.down_anim = 34
		player.anim_speed = 0.15
		player.frame_timer = 0
		player.facing = 1
 
 
end
function is_colliding(x, y, w, h, flag)
 		 local left_tile = x \ 8
    local right_tile = (x + w - 1) \ 8
    local top_tile = y \ 8
    local bottom_tile = (y + h - 1) \ 8

    
    if fget(mget(left_tile, top_tile), flag) or
       fget(mget(right_tile, top_tile), flag) or
       fget(mget(left_tile, bottom_tile), flag) or
       fget(mget(right_tile, bottom_tile), flag)
    then
        return true
    end

    return false
end

function respawn_enemies()

end

function handle_anim()
    
    if player.vx > 0 then
        player.facing = 1
    elseif player.vx < 0 then
        player.facing = -1
    end

    
    if player.vx != 0 and player.vy == 0 then
        player.frame_timer += player.anim_speed
        local frame_index = flr(player.frame_timer) % #player.walk_anim + 1
        current_frame = player.walk_anim[frame_index]
    elseif player.vy < 0 then
    				curent_frame = player.up_anim
    elseif player.vy > 0 then
    				current_frame = player.down_anim
    else
        
        current_frame = 1
        player.frame_timer = 0 -- reset timer for next movement
    end
end

function death_collide()
				if is_colliding(player.x + player.vx, player.y, player.w, player.h, 2) then
        return true
    end

   	if  is_colliding(player.x, player.y + player.vy, player.w, player.h, 2) then
        return true
    end

end

function checkpoint()
				if is_colliding(player.x + player.vx, player.y, player.w, player.h, 3) then
        return true
    end

   	if  is_colliding(player.x, player.y + player.vy, player.w, player.h, 3) then
        return true
    end
end

function handle_death()
				player.x = player.homex
				player.y = player.homey
				respawn_enemies()	
end

function handle_camera()
			 local camx = 0
			 local camy = 0
			 if player.x - 64 >= 0 then camx = player.x - 64 end
			 if player.y - 64 >= 0 then camy = player.y - 64 end
				camera(camx, camy)
end

function _update()
    
    if btn(0) then
        player.vx += -player.speed
    elseif btn(1) then
        player.vx += player.speed
    else
        player.vx = player.vx * friction
    end

  		if btnp(2) and player.grounded then
        player.vy = player.jump
        player.grounded = false
    end

    if abs(player.vx) < .05 then player.vx = 0 end
    
    player.vy += gravity -- a lower, more typical gravity value for smooth jumping
    
 		 if abs(player.vx) > player.speed then
      		player.vx = player.speed * sgn(player.vx)
    end
    if player.vy > terminalv then
      		player.vy = terminalv
    end

    if not is_colliding(player.x + player.vx, player.y, player.w, player.h, 1) then
        player.x += player.vx
    else
        -- stop horizontal movement on collision
        player.vx = 0
    end

    
    if not is_colliding(player.x, player.y + player.vy, player.w, player.h, 1) then
    				player.y += player.vy
        player.grounded = false
    else
        
        while not is_colliding(player.x, player.y + sgn(player.vy), player.w, player.h, 1) do
            player.y += sgn(player.vy)
        end
        player.vy = 0
        player.grounded = true
    end
   
    if death_collide() then handle_death() end
				if checkpoint() then
								player.homex = player.x
								player.homey = player.y
				end 
				handle_anim()		
end

function _draw()
    cls()
    handle_camera()
    map(0, 0, 0, 0, player.x + 8, player.y + 8)
  
    spr(current_frame, player.x, player.y, 1, 1, player.facing == -1)
end
