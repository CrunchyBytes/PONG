-- require = import, 'push' es el archivo que se importa.
push = require 'push'
-- Importar archivos/clases 'class.lua'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	-- Filtro que le da efecto pixeleado
	love.graphics.setDefaultFilter('nearest', 'nearest')
	
	-- Generar seed de aleatoriedad.
	math.randomseed(os.time())
	
	-- Se carga una nueva fuente, llamada "font.ttf" en el directorio actual, y de tamaño 8.
	smallFont = love.graphics.newFont("font.ttf", 8)
	love.graphics.setFont(smallFont)

	scoreFont = love.graphics.newFont("font.ttf", 32)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { --game resolution, window resolution, fullscreen
		fullscreen = false,
		resizable = false,
		vsync = true
	})

	-- Audio
	paddle_hit = love.audio.newSource("Audio/paddle_hit.wav", "stream")
	match_victory = love.audio.newSource("Audio/match_victory.wav", "stream")
	point_scored = love.audio.newSource("Audio/point_scored.wav", "stream")
	ceiling_colision = love.audio.newSource("Audio/ceiling_colision.wav", "stream")

	-- Inicialización de los jugadores.
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

	-- Inicialización del puntaje de cada jugador.
	player1Score = 0
	player2Score = 0

	-- Inicialización de la pelota.
	ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)		

	-- Variable que lleva registro de quién sacará el servicio.
	servingPlayer = 1
	
	gameState = 'start'

	numberOfSets = 3
	winningPlayer = 0
end

function love.update(dt)
	-- Revisa si está en saque
	if gameState == 'serve' then
		-- 
		if servingPlayer == 1 then
			ball.dx = math.random(100, 150)
			--servingPlayer = 2
		else
			ball.dx = -math.random(100, 150)
			--servingPlayer = 2
		end
		ball.dy = math.random(-50, 50)

	elseif gameState == 'play' then
		-- Detectar colisiones con el borde inferior y superior de la pantalla.
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy

			love.audio.play(ceiling_colision)
		end

		if ball.y >= VIRTUAL_HEIGHT - ball.height then
			ball.y = VIRTUAL_HEIGHT - ball.height
			ball.dy = -ball.dy

			love.audio.play(ceiling_colision)
		end

		-- Detectar colisiones con los jugadores.
		if ball:collides(player1) then
			love.audio.play(paddle_hit)
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + ball.width + 1 -- En caso de que el desplazamiento sea mínimo, y registre múltiples colisiones.

			if ball.dy <0 then
				ball.dy = -math.random(10, 150) -- Hacer que el rebote a velocidades aleatorias.
			else
				ball.dy = math.random(10, 150)
			end
		end

		if ball:collides(player2) then
			love.audio.play(paddle_hit)
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - ball.width - 1 -- En caso de que el desplazamiento sea mínimo, y registre múltiples colisiones.

			if ball.dy <0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end
	end

	-- Actualizar score de cada jugador.
	-- Jugador 2 anota: incrementa su contador, y saca el jugador contrario.
	if ball.x < 0 then
		love.audio.play(point_scored)
		player2Score = player2Score + 1
		servingPlayer = 1
		ball:reset()

		if player2Score == numberOfSets then
			winningPlayer = 2
			gameState = 'finish'
		else
			--ball:reset()
			gameState = 'serve' --'start'
		end
	end

	-- Jugador 1 anota
	if ball.x > VIRTUAL_WIDTH then
		love.audio.play(point_scored)
		player1Score = player1Score + 1
		servingPlayer = 2
		ball:reset()

		if player1Score == numberOfSets then
			winningPlayer = 1
			gameState = 'finish'
		else			
			gameState = 'serve' --'start'
		end
	end

	-- Movimiento del jugador 1.
	if love.keyboard.isDown('w') then -- @param: cuál tecla es presionada.
		player1.dy = -PADDLE_SPEED
		--player1Y = math.max(0, player1Y - (dt * PADDLE_SPEED))
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
		--player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + (dt * PADDLE_SPEED)) -- Se le resta 20 a VIRTUAL_HEIGHT debido a que es la altura de la paleta.
	else
		--El jugador se queda en su lugar si no tiene presionado ninguna de las dos teclas.
		player1.dy = 0
	end

	-- Movimiento del jugador 2.
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
		--player2Y = math.max(0, player2Y - (dt * PADDLE_SPEED))
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
		--player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + (dt * PADDLE_SPEED))
	else
		--El jugador se queda en su lugar si no tiene presionado ninguna de las dos teclas.
		player2.dy = 0
	end
	


	if gameState == 'play' then
		-- Llamar a la función update de la pelota.
		ball:update(dt) 
		-- Coordenada en x en la pelota es la anterior + un desplazamiento definido.
		--ballX = ballX + (ballDX * dt)
		--ballY = ballY + (ballDY * dt)
	end

	-- Llamar a las funciones update de cada jugador, para actualizar sus posiciones.
	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	
	-- Cuando cargue el juego (presiona enter), la pelota se empieza a mover	
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve' --'play' --SERVE

		elseif gameState == 'serve' then
			gameState = 'play'

		-- Si el juego terminó, inícialo nuevamente desde el estado 'serve'
		elseif gameState == 'finish' then
			gameState = 'serve'
			
			-- Reinicia puntajes.
			player1Score = 0
			player2Score = 0

			-- Resetea la posición de la pelota.
			ball:reset()

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayerw = 1
			end

		else
			gameState = 'start' -- review
			
			-- Se reinician las coordenadas de la pelota.
			ball:reset()

			--[[ballX = VIRTUAL_WIDTH/2 - 2
			ballY = VIRTUAL_HEIGHT/2 - 2

			ballDX = math.random(2) == 1 and 100 or -100 --Operador ternario en Lua.
			ballDY = math.random(-50, 50)
			]]
		end
	end
end

function love.draw()
	push:apply("start")

	love.graphics.setFont(smallFont)
	
	-- Welcoming text
	if gameState == 'start' then
		love.graphics.printf(
			'Welcome to PONG!\nPress Enter to continue.',			-- text to render
			0,						-- starting X
			20, --VIRTUAL_HEIGHT/2 - 6,	-- starting Y (halfway down the screen)
			VIRTUAL_WIDTH,			-- # of pixels to center within
			'center'				-- alignment mode: {'center', 'left', 'right'}
			)

	elseif gameState == 'serve' then
		love.graphics.printf(
			'Player ' ..tostring(servingPlayer) ..'\'s turn. \nPress Enter to serve.',			-- text to render
			0,						-- starting X
			20, --VIRTUAL_HEIGHT/2 - 6,	-- starting Y (halfway down the screen)
			VIRTUAL_WIDTH,			-- # of pixels to center within
			'center'				-- alignment mode: {'center', 'left', 'right'}
			)

	elseif gameState == 'play' then
		-- empty, for now
	
	elseif gameState == 'finish' then
		love.graphics.setFont(scoreFont)
		love.graphics.printf(
			'Congratulations!',			-- text to render
			0,						-- starting X
			20, --VIRTUAL_HEIGHT/2 - 6,	-- starting Y (halfway down the screen)
			VIRTUAL_WIDTH,			-- # of pixels to center within
			'center'				-- alignment mode: {'center', 'left', 'right'}
			)

		love.graphics.setFont(smallFont)
		love.graphics.printf(
			'Player ' ..tostring(winningPlayer) ..' wins!! \nPress Enter to play again.',			-- text to render
			0,						-- starting X
			50, --VIRTUAL_HEIGHT/2 - 6,	-- starting Y (halfway down the screen)
			VIRTUAL_WIDTH,			-- # of pixels to center within
			'center'				-- alignment mode: {'center', 'left', 'right'}
			)
	end -- revisar otros estados.

	love.graphics.setFont(scoreFont)
	
	-- Score Player 1
	love.graphics.print(
		tostring(player1Score),
		VIRTUAL_WIDTH / 2 - 50,
		VIRTUAL_HEIGHT / 3
		)

	-- Score Player 2
	love.graphics.print(
		tostring(player2Score),
		VIRTUAL_WIDTH / 2 + 30,
		VIRTUAL_HEIGHT / 3
		)

	-- Render left paddle
	player1:render()
	--love.graphics.rectangle('fill', 10, player1Y, 5, 20) -- mode={fill, line}, x, y, width, height

	-- Render right paddle
	player2:render()
	--love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20) -- mode={fill, line}, x, y, width, height

	-- Render pong ball, a la mitad y al centro de la pantalla
	ball:render()
	--love.graphics.rectangle('fill', ballX, ballY, 4, 4)--VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4) -- mode={fill, line}, x, y, width, height

	push:apply("end")

	
end