sprites = {}
spriteImgs = {}

startedSelecting = false
selectedSprites = {}

N = 10
M = 10
L = 4
dx = nil
dy = nil

testFlag = false

function ifContain(x,y, x1,y1,w,h)
	return	x1 < x and x < x1+w and
			y1 < y and y < y1+h 
end

function love.load(arg)
	-- initialize background
	dx = love.graphics:getWidth()/N
	dy = love.graphics:getHeight()/M

	-- initialize sprites
	for i=1,L do
		if i == 1 then
			newSpriteImg = love.graphics.newImage('assets/blue_gem_7.png')
		elseif i == 2 then
			newSpriteImg = love.graphics.newImage('assets/orange_gem_7.png')
		elseif i == 3 then
			newSpriteImg = love.graphics.newImage('assets/pink_gem_7.png')
		elseif i == 4 then
			newSpriteImg = love.graphics.newImage('assets/yellow_gem_7.png')
		end
		table.insert(spriteImgs, newSpriteImg)
	end

	for i=1,N do
      for j=1,M do
        x0 = (i-1)*dx
        y0 = (j-1)*dy
        color = math.random(L)
        newSprite = { x = x0, y = y0, img = spriteImgs[color], tag = color, dxdt = nil, dydt = nil, x1 = nil, y1 = nil, t = 0, rt = 0 }
		table.insert(sprites, newSprite)
      end
    end
end

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Move sprites w.r.t remaining time
	for i, sprite in ipairs(sprites) do
		if sprite.rt > 0 then
			dxdt = (sprite.x2 - sprite.x1) * (dt/sprite.t)
			dydt = (sprite.y2 - sprite.y1) * (dt/sprite.t)
			sprite.x = sprite.x + dxdt
			sprite.y = sprite.y + dydt
			sprite.rt = sprite.rt - dt
			if sprite.rt < 0 then
				sprite.rt = 0
			end
		end
	end

	--[[ Test regenerate sprites
	if #sprites < 1 then
		for i=1,100 do
		randomX = math.random(spriteImg:getWidth()/2, love.graphics.getWidth() - spriteImg:getWidth()/2)
		randomY = math.random(spriteImg:getWidth()/2, love.graphics.getHeight() - spriteImg:getWidth()/2)
		newSprite = { x = randomX, y = randomY, img = spriteImg, dxdt = nil, dydt = nil, x1 = nil, y1 = nil, t = 0, rt = 0 }
		table.insert(sprites, newSprite)
		end
	end
	--]]
end

selectedTag = {}

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		if not startedSelecting then
			for i, sprite in ipairs(sprites) do
				if ifContain(x,y, sprite.x,sprite.y,dx,dy) then
					
					startedSelecting = true
					selectedTag = sprite.tag 
					table.insert(selectedSprites, i)

					--[[ test remove sprite at mouse point
					px = sprite.x
					py = sprite.y
					table.remove(sprites, i)
					
					-- test move sprites above
					for i, sprite in ipairs(sprites) do
						if sprite.x == px and sprite.y < py then
							-- drop down sprite(s) above 
							sprite.x1 = sprite.x
							sprite.y1 = sprite.y
							sprite.x2 = sprite.x
							sprite.y2 = sprite.y+dy
							sprite.t  = 0.3
							sprite.rt = sprite.t
						end
					end
					--]]

					return
				end
			end
		end

		if startedSelecting then
			for i, sprite in ipairs(sprites) do
				if ifContain(x,y, sprite.x,sprite.y,dx,dy) then
					-- HERE check if it is one of selected sprites
					notSelected = true
					for j, selectedSprite in ipairs(selectedSprites) do
						if i == selectedSprite then
							notSelected = false
						end
					end

					if notSelected and sprite.tag == selectedTag then
						-- presort if selected i is bigger store at the beginning
						k = 1
						for j=1,#selectedSprites do
							if i < selectedSprites[j] then
								k = j+1
							end
						end
						table.insert(selectedSprites, k, i)

						-- if 3 sprites are selected delete 
						if #selectedSprites >= 3 then
							-- IMPORTANT remove bigger index sprite first
							px = {}
							py = {}
							for k, selectedSprite in ipairs(selectedSprites) do
								table.insert(px, sprites[selectedSprite].x)
								table.insert(py, sprites[selectedSprite].y)
								table.remove(sprites, selectedSprite)
							end
							
							-- move sprites above
							for m, sprite in ipairs(sprites) do
								t=0
								for m=1,#px do
									if sprite.x == px[m] and sprite.y < py[m] then
										t = t+1	
									end
								end
								if t>0 then
									-- drop down sprite(s) above 
										sprite.x1 = sprite.x
										sprite.y1 = sprite.y
										sprite.x2 = sprite.x
										sprite.y2 = sprite.y+dy*t
										sprite.t  = 0.3*t
										sprite.rt = sprite.t
								end
							end
							--]]
						
							startedSelecting = false
							selectedSprites = {}
							selectedTag = 0
						end
					else
						startedSelecting = false
						selectedSprites = {}
						selectedTag = 0
					end

					return

				end
			end
		end

	end
end

function love.draw()
	--[[ test draw block cordinates
	for i=1,N do
      for j=1,M do
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", (i-1)*dx+4, (j-1)*dy+4, dx-6, dy-6)
      end
    end
    --]]

    -- draw sprites
    for i, sprite in ipairs(sprites) do
		--love.graphics.draw(sprite.img, sprite.x, sprite.y)
		love.graphics.draw(sprite.img, sprite.x, sprite.y, 0, dx/sprite.img:getWidth(), dy/sprite.img:getHeight() )
		love.graphics.print(i, sprite.x, sprite.y)
	end

	-- draw rect over selected sprites
	for i, selectedSprite in ipairs(selectedSprites) do
		sprite = sprites[selectedSprite]
		love.graphics.setColor(0, 255, 0)
		love.graphics.rectangle( "fill", sprite.x, sprite.y, dx, dy )
		love.graphics.setColor(255, 255, 255)
	end

	-- draw lines over selected sprites
	if #selectedSprites > 1 then
		for i=1, #selectedSprites-1 do
			--love.graphics.draw(sprite.img, sprite.x, sprite.y)
			love.graphics.line(sprites[selectedSprites[i]].x+dx/2, sprites[selectedSprites[i]].y+dy/2, sprites[selectedSprites[i+1]].x+dx/2, sprites[selectedSprites[i+1]].y+dy/2 )
		end
	end

	-- Debug FPS
	if debug then
		love.graphics.setColor(255, 0, 0)
		fps = tostring(love.timer.getFPS())
		love.graphics.print("Current FPS: "..fps, 10, 10)

		for i, selectedSprite in ipairs(selectedSprites) do
			love.graphics.print(selectedSprite, 10+17*(i-1), 20)
		end
		if startedSelecting then
			love.graphics.print("selecting", 10, 30)
		end
		love.graphics.setColor(255, 255, 255)
	end
end