anim8 = require 'lib/anim8'
push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

require 'src/StateMachine'
require 'src/Util'

require 'src/States/BaseState'
require 'src/States/PlayState'
require 'src/States/StartState'

background = love.graphics.newImage('graphics/space.png')

gTextures = {
    ['space-craft'] = love.graphics.newImage('graphics/space-craft.png') 
}

gImages = {
    ['player'] =love.graphics.newQuad(702, 118, 85, 61, gTextures['space-craft']:getDimensions())
    --['player'] = love.graphics.newQuad(0, 0, 32, 32, gTextures['space-craft']:getDimensions())
}
gFonts = {
    ['large_font'] = love.graphics.newFont('fonts/font.ttf', 128),
    ['small_font'] = love.graphics.newFont('fonts/font.ttf', 32)
}