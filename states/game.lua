function game_load()

	paused = false
	
	highscore = 0

	objects = {}

	objects["ship"] = {}
	objects["bullet"] = {}
	objects["fruit"] = {}
	objects["powerup"] = {}

	splats = {}
	backgroundImages = {}

	objects["ship"][1] = newShip( (love.graphics.getWidth() / scale) / 2 - 20, 100, 4, "top")

	local keys = {}
	for k, v in pairs(controls) do
		if v == " " then
			keys[k] = "SPACEBAR"
		else
			keys[k] = v
		end
	end

	if game_joystick then
		keys[1] = "Analog Left"
		keys[2] = "Right"
		keys[3] = "Up"
		keys[4] = "A or X"
		keys[5] = "B or Y"
	end

	instructions = 
	{
		keys[1] .. ", " .. keys[2] .. ",\nand " .. keys[3] .. " to move",
		keys[4] .. " TO SHOOT",
		"ESCAPE TO PAUSE",
		keys[5] .. " TO ACTIVATE\nSHIELD",
		"SHOOT AS MANY FRUITS\nAS YOU CAN!",
		"READY?",
		"3..",
		"2..",
		"1..",
		"GO!!"
	}

	instructiontimer = 0
	instructiontimeri = 1
	gameover = false

	start_game = false
	state = "game"

	gamescore = 0

	game_randomStaticPlanet()

	game_playsound(bgm)

	restart_key = "'r'"
	if game_joystick then
		restart_key = "start"
	end

	timeout = 0
end

function game_randomStaticPlanet()
	local a = math.random(#staticBGs)
	
	planetScreen = screens[math.random(#screens)]
	local w = 400
	if planetScreen == "bottom" then
		w = 320
	end
	planetX = math.random(0, w - 50)
	planetY = math.random(0, 190)
	planetimg = staticBGs[a]

	local b = math.random(#staticBGs)
	while b == a do
		b = math.random(#staticBGs)
	end
	
	local w = 400
	if planetScreen == "bottom" then
		w = 320
	end
	planet2Screen = screens[math.random(#screens)]
	planet2X = math.random(0, w - 50)
	planet2Y = math.random(0, 190)
	planetimg2 = staticBGs[b]
	
	
	objects["fruit"] = {}
	splats = {}
	powerups = {}
end

function game_garbageCollect()
	for k = #objects["fruit"], 1, -1 do
		if objects["fruit"][k].remove then
			table.remove(objects["fruit"], k)
		end
	end

	for k = #objects["bullet"], 1, -1 do
		if objects["bullet"][k].remove then
			table.remove(objects["bullet"], k)
		end
	end

	for k = #objects["powerup"], 1, -1 do
		if objects["powerup"][k].remove then
			table.remove(objects["powerup"], k)
		end
	end

	for k = #splats, 1, -1 do
		if splats[k].remove then
			table.remove(splats, k)
		end
	end
end

function game_update(dt)

	if paused then
		return
	end

	if gameover then
		for k, v in pairs(splats) do
			v:update(dt)
		end

		if timeout < 3 then
			timeout = timeout + dt
		else
			menu_load(true)
		end

		return
	end

	physics:update(dt)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end
	end

	if not start_game then
		instructiontimer = instructiontimer + dt / 1.5
		instructiontimeri = math.floor(instructiontimer%#instructions)+1

		if instructiontimer > 10 then
			fruitTimer = newRecursionTimer(math.random(2, 4),
				function()
					local posx = {4, love.graphics.getWidth() / scale}
					local posy = math.random(4, love.graphics.getHeight() / scale)

					table.insert(objects["fruit"], newFruit(posx[math.random(#posx)], posy, screens[math.random(#screens)]))
				end
			)

			start_game = true
			instructiontimer = 0
		end
	else
		fruitTimer:update(dt)
	end

	for k, v in ipairs(stars) do
		v:update(dt)
	end

	for k, v in ipairs(splats) do
		v:update(dt)
	end

	for k, v in pairs(backgroundImages) do
		v:update(dt)
	end

	game_garbageCollect()
end

function addScore(points)
	gamescore = math.max(gamescore + points, 0)
end

function game_draw()

	for k, v in ipairs(stars) do
		v:draw()
	end

	love.graphics.setScreen(planetScreen)
	
	love.graphics.draw(planetimg, planetX, planetY)
	
	love.graphics.setScreen(planet2Screen)
	
	love.graphics.draw(planetimg2, planet2X, planet2Y)
	
	love.graphics.setFont(hudfont)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
			--love.graphics.rectangle("line", w.x, w.y, w.width, w.height)
		end
	end

	for k, v in pairs(objects["powerup"]) do
		if v.drawshield then
			v:drawshield()
		end
	end

	love.graphics.setScreen("top")

	if paused then
		love.graphics.setColor(0, 0, 0, 120)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(menubuttonfont)
		love.graphics.print("GAME PAUSED", (love.graphics.getWidth() / scale) / 2 - menubuttonfont:getWidth("GAME PAUSED") / 2, (love.graphics.getHeight() / scale) / 2 - menubuttonfont:getHeight("GAME PAUSED") / 2)
		love.graphics.setFont(hudfont)
	end

	if gameover then
		love.graphics.setFont(menubuttonfont)
		love.graphics.print("GAME OVER", (love.graphics.getWidth() / scale) / 2 - menubuttonfont:getWidth("GAME OVER") / 2, (love.graphics.getHeight() / scale) / 2 - menubuttonfont:getHeight("GAME OVER") / 2)
		--love.graphics.print("PRESS " .. restart_key .. " TO RESTART", (love.graphics.getWidth() / scale) / 2 - menubuttonfont:getWidth("PRESS " .. restart_key .. " TO RESTART") / 2, (love.graphics.getHeight() / scale) / 2 - menubuttonfont:getHeight("PRESS " .. restart_key .. " TO RESTART") / 2 + 32)
		love.graphics.setFont(hudfont)
	end

	love.graphics.print("Score: " .. gamescore, 2, 2)

	love.graphics.print("Hi-Score: " .. highscore, (love.graphics.getWidth() / scale) - hudfont:getWidth("Hi-Score: " .. highscore) - 2, 2)

	if not start_game then
		love.graphics.setFont(mediumfont)
		love.graphics.print(instructions[instructiontimeri], (love.graphics.getWidth() / scale) / 2 - mediumfont:getWidth(instructions[instructiontimeri]) / 2, (love.graphics.getHeight() / scale) / 2 - mediumfont:getHeight(instructions[instructiontimeri]) / 2)
	end
	
	for k, v in ipairs(splats) do
		v:draw()
	end

	for k, v in pairs(backgroundImages) do
		v:draw()
	end
end

function game_keypressed(key)
	if not gameover then
		if not paused then
			if objects["ship"][1] then
				objects["ship"][1]:move(key)
			end
		end

		if key == "escape" and start_game then
			paused = not paused
		end
	end
end

function game_joystickaxis(joy, axis, value)
	if objects["ship"][1] then
		objects["ship"][1]:joystickAxis(joy, axis, value)
	end
end

function game_keyreleased(key)
	if objects["ship"][1] then
		objects["ship"][1]:stopMove(key)
	end
end

function game_playsound(audio)
end