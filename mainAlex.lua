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

	-- Inicialización de los jugadores.
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

	-- Inicialización del puntaje de cada jugador.
	player1Score = 0
	player2Score = 0

	-- Inicialización de la pelota.
	ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)		

	gameState = 'start'
end

function love.update(dt)
	
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
			gameState = 'play'
		else
			gameState = 'start'
			
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
			'Hello Start State!',			-- text to render
			0,						-- starting X
			20, --VIRTUAL_HEIGHT/2 - 6,	-- starting Y (halfway down the screen)
			VIRTUAL_WIDTH,			-- # of pixels to center within
			'center'				-- alignment mode: {'center', 'left', 'right'}
			)
	else
		love.graphics.printf(
			'Hello Play State!',			-- text to render
			0,						-- starting X
			20, --VIRTUAL_HEIGHT/2 - 6,	-- starting Y (halfway down the screen)
			VIRTUAL_WIDTH,			-- # of pixels to center within
			'center'				-- alignment mode: {'center', 'left', 'right'}
			)
	end

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