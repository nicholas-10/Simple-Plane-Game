require 'src/dependencies'
require 'src/constants'
function love.load()
    math.randomseed(os.time())

    player_craft = math.random(1, 5)

    love.window.setTitle('Space Wars')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    offsetY = 0
    offsetX = 0

    backgroundWidth, backgroundHeight = background:getDimensions()

    -- statemachine implementation
    gStateMachine = StateMachine{
        ['start'] = function () return StartState() end,
        ['play'] = function () return PlayState() end
    }
    gStateMachine:change('start')

    
    
    love.keyboard.keypressed = {}
end
function love.update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    -- if love.keyboard.wasPressed('p') then
    --     PlayerStates:change('reload')
    --     print('adfbaiubuiab')
    -- end

    gStateMachine:update(dt)
    -- background parallax scrolling
    offsetY = offsetY + SCROLL_SPEED * dt
    offsetY = offsetY % (0.5 * backgroundHeight)

    love.keyboard.keypressed = {}
end
function love.resize(w, h)
    return push:resize(w, h)
  end
function love.keypressed(key)

    love.keyboard.keypressed[key] = true
end
function love.keyboard.wasPressed(key)
    return love.keyboard.keypressed[key]
end
function love.draw()
    push:start()
    
    --draw here
    --love.graphics.translate(offsetX, offsetY)
    love.graphics.draw(background, offsetX, - (0.5 * backgroundHeight) +  offsetY)

    gStateMachine:render()
    push:finish()
end