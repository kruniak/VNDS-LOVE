require "lib/script"
pprint = require "lib/pprint"
TESound = require "lib/tesound"
Talkies = require "lib/talkies"
Talkies.font = love.graphics.newFont("inter.otf", 32)
Talkies.padding = 20
export *
interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
images = {}
sx, sy = 0,0
getScaling = (drawable,canvas) ->
	sx = love.graphics.getWidth() / drawable\getWidth()
	sy = love.graphics.getHeight() / drawable\getHeight()
	return sx, sy

next_msg = () ->
	ins = interpreter\next_instruction!
	--pprint(ins)
	switch ins.type
		when "bgload"
			if ins.path\sub(-1) == "~" then background = nil
			else if love.filesystem.getInfo(ins.path)
				background = love.graphics.newImage(ins.path)
			next_msg!
		when "text"
			if ins.text == "~" or ins.text == "!"
				Talkies.say("", "", {oncomplete: () -> next_msg!})
			else
				Talkies.say("", ins.text, {oncomplete: () -> next_msg!})
		when "choice"
			opts = {}
			for i,choice in ipairs ins.choices
				table.insert(opts, {choice, 
				() -> 
					interpreter\choose(i)
					next_msg!
				})
			Talkies.say("", "Choose", {options: opts})

		
		when "setimg"
			if love.filesystem.getInfo(ins.path)
				table.insert(images, love.graphics.newImage(ins.path))
		when "sound"
			if ins.path\sub(-1) == "~" then TEsound.stop("sound")
			else if ins.n
				if ins.n == -1 then TEsound.playLooping(ins.path, "static", {"sound"})
				else TEsound.playLooping(ins.path, "static", {"sound"}, ins.n)
			else TEsound.play(ins.path, "static",{"sound"})
			next_msg!
		when "music"
			if ins.path\sub(-1) == "~" then TEsound.stop("music")
			else if love.filesystem.getInfo(ins.path)
				TEsound.playLooping(ins.path, "stream", {"music"})
			next_msg!
		--when "delay"
		--when "cleartext"
		else next_msg!
love.load = ->
	next_msg!

love.draw = ->
	if background then 
		sx, sy = getScaling(background)
		love.graphics.draw(background, 0,0,0,sx,sy)
	for image in *images
		love.graphics.draw(image)
    Talkies.draw!

love.update = (dt) ->
	Talkies.update(dt)
	TEsound.cleanup()

love.keypressed = (key) ->
  if key == "space" then Talkies.onAction()
  else if key == "up" then Talkies.prevOption()
  else if key == "down" then Talkies.nextOption()

love.gamepadpressed = (joy, button) ->
	if button == "a" then Talkies.onAction()
	else if button == "dpup" then Talkies.prevOption()
	else if button == "dpdown" then Talkies.nextOption()