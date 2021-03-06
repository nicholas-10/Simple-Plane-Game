World = Class{}

function World:init(player)
    self.player = player

    -- table of bullets to be inserted into and later looped over
    self.bullets = {}

    -- same thing but for the asteroids
    self.asteroids = {}

    self.objects = {}

    self.shopDistance = 10000
        -- 4 is the boarder, and x and y ar offset by the boarder so you can still see the boarder
    self.powerUpSlot = PicturePanel({x = VIRTUAL_WIDTH - 96 - 4, y = VIRTUAL_HEIGHT - 96 - 4, 
        width = 96, height = 96, boarder = 4})
    self.powerUps = {}

    -- saved powerup saves a function or nil.
    -- gist of it:
    -- if the player has a power up already, then whatever gets picked up will get saved here in a function.
    -- the power up is used by calling this function if a button is pressed.
    -- then it'll be set back to nil, ready to store a new power up 
    -- if there's already a function, it'll get replaced
    self.savedPowerUp = nil

    self.currentlyBossBattle = false

    self.boss = nil
    self.bossHasSpawned = false
end


function World:update(dt)
    if not (self.player.distanceTravelled > self.shopDistance) and not self.currentlyBossBattle then
        -- chance to spawn power up
        if math.random(1, 60) == 1 then
            table.insert(self.objects,
            GameObject{x = math.random(0, VIRTUAL_WIDTH - 32), y = 0 - 32, dx = 0, dy = POWERUP_OBJECT_SPEED, width = 32, height = 32, type = 'points',
            texture = POWER_UPS['points'].texture, image = POWER_UPS['points'].image, animations = Animations{frames = POWER_UPS['points'].frames, interval = POWER_UPS['points'].interval},
                onConsume = function () 
                    self.player.points = self.player.points + 200
                    gAudio['pickup']:stop()
                    gAudio['pickup']:play()    
                end})
        end
        if math.random(1, 360) == 1 then
            table.insert(self.objects,
            GameObject{x = math.random(0, VIRTUAL_WIDTH - 32), y = -32, dx = 0, dy = POWERUP_OBJECT_SPEED, width = 32, height = 32, texture = POWER_UPS['shield'].texture, 
                image = POWER_UPS['shield'].image, type = 'shield', animations = Animations{frames = POWER_UPS['shield'].frames, interval = POWER_UPS['shield'].interval},
                onConsume = function () 
                    gAudio['powerup-1']:stop()
                    gAudio['powerup-1']:play()

     
                    -- save the power up for when player later presses enter
                    
                    self.savedPowerUp = function ()
                        table.insert(self.powerUps, Shield{x = self.player.x + self.player.width * 0.5, y = self.player.y + self.player.height * 0.5, dx = 0, dy = 0, 
                        radius = 64, type = 'shield', shape = 'circle', drawType = 'line'}) 
                        
                    end
                    self.powerUpSlot.texture = gTextures['power-ups']
                    self.powerUpSlot.image = gImages['power-ups'][1]
                    
                        
                end})
        end
        print(self.player.hasPowerUps)
        if math.random(1, 360) == 1 then
            table.insert(self.objects,
            GameObject{x = math.random(0, VIRTUAL_WIDTH - 32), y = -32, dx = 0, dy = POWERUP_OBJECT_SPEED, width = 32, height = 32, r = 0, g = 0.5, b = 0.5, type = 'infinite-bullets',
                texture = POWER_UPS['infinite-bullets'].texture, image = POWER_UPS['infinite-bullets'].image, animations = Animations{frames = POWER_UPS['infinite-bullets'].frames, interval = POWER_UPS['infinite-bullets'].interval},
                onConsume = function ()
                gAudio['powerup-1']:stop()
                gAudio['powerup-1']:play()
        
                    self.savedPowerUp = function ()
                        
                        self.player.ammo = 9999
                        Timer.after(20, function ()
                            self.player.ammo = self.player.maxAmmo
                            
                        end)
                    end

                    self.powerUpSlot.texture = gTextures['power-ups']
                    self.powerUpSlot.image = gImages['power-ups'][3]
                end
            })
        end
        if math.random(1, 360) == 1 then
            table.insert(self.objects,
                GameObject{x = math.random(0, VIRTUAL_WIDTH - 16), y = -16, dx = 0, dy = POWERUP_OBJECT_SPEED, width = 32, height = 32, r = 0, g = 1, b = 0, type = 'speed',
                texture = POWER_UPS['speed'].texture, image = POWER_UPS['speed'].image, animations = Animations{frames = POWER_UPS['speed'].frames, interval = POWER_UPS['speed'].interval},
                    onConsume = function () 
                        gAudio['powerup-1']:stop()
                        gAudio['powerup-1']:play()
           

                        
                        self.savedPowerUp = function ()
                            self.player.speedMulti = 2
                            
                            Timer.after(20, function () 
                                self.player.speedMulti = (1 + 0.1 * (self.player.speedLevel - 1))
                                 
                            end)
                        end
                        self.powerUpSlot.texture = gTextures['power-ups']
                        self.powerUpSlot.image = gImages['power-ups'][2]
                        end
                    
                        
                    })
        end
        if math.random(1, 150) == 1 then
            table.insert(self.objects,
                GameObject({x = math.random(0, VIRTUAL_WIDTH - 64), y = -64, dx = 0, dy = POWERUP_OBJECT_SPEED, animations = Animations{frames = COINS['supeks-coin'].frames, interval = COINS['supeks-coin'].interval}, 
                    shape = 'rectangle', texture = COINS['supeks-coin'].texture, image = COINS['supeks-coin'].image,  type = 'coins', width = 64, height = 64,
                    onConsume = function () 
                        self.player.money = self.player.money + 1 
                        gAudio['coins']:stop()
                        gAudio['coins']:play()
                    end}))
        end
        -- change to spawn asteroids
        if math.random(1, 75) == 1 then
            table.insert(self.asteroids, 
                Asteroid({x = math.random(50, VIRTUAL_WIDTH - 50), y = 0, width = math.random(40, 80), height = math.random(40, 80), pointValue = 500}))
        end
    end

    -- press l to used what ever power up is currently saved
    if (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) and self.savedPowerUp ~= nil then
        gAudio['powerup-2']:stop()
        gAudio['powerup-2']:play()
        self.savedPowerUp()
        self.savedPowerUp = nil
        self.powerUpSlot.texture  = nil
        self.powerUpSlot.image = nil
    end
    -- transition to boss
    -- ideally the 5000 would be a table that is tied to the number of bosses that have been defeated
    if not self.bossHasSpawned and self.player.distanceTravelled > 4999 then
        gStateMachine:change('boss', {player = self.player, world = self})
        self.currentlyBossBattle = true
        self.bossHasSpawned = true
    end
    -- boss related logic
    if self.boss ~= nil then
        for b, bullet in pairs(self.bullets) do
            if bullet:collides(self.boss) then
                self.boss.hp = self.boss.hp - self.player.bulletDamage
                gAudio['explosion']:stop()
                gAudio['explosion']:play()
                table.remove(self.bullets, b)
                -- ideally add an animations
            end
        end
    end 

    for a, asteroid in pairs(self.asteroids) do
        asteroid:update(dt)
        if asteroid:collides(self.player) and not self.player.invulnerable then
            -- takes  a life away
            self.player.lives = self.player.lives - 1
            -- don't need to stop cause player gets invulnerability
            gAudio['damaged']:play()
            -- makes player invulnerable
            self.player.invulnerable = true
            -- makes player vulnerable again after 2 seconds
            Timer.after(2, function() self.player.invulnerable = false end)
            -- game over if you run out of lives
            if self.player.lives <= 0 then
                gStateMachine:change('end', {distance = self.player.distanceTravelled,
                    points = self.player.points, money = self.player.money, playerCraft = self.player.playerCraft})
            end
            -- removes asteroid
            table.remove(self.asteroids, a)
        
        end
    end
    -- updates power ups and the various effects
    for p, powerUp in pairs(self.powerUps) do
        powerUp:update(dt, self.player)
        for a, asteroid in pairs(self.asteroids) do
            if powerUp:collides(asteroid) then
                table.remove(self.powerUps, p)
                table.remove(self.asteroids, a)
                
            end
        end

    end
    -- updates game objects so they move
    for o, object in pairs(self.objects) do
        object:update(dt)
    end

    -- checks if each asteroid has collided with a bullet or not
    for a, asteroid in pairs(self.asteroids) do
        for b, bullet in pairs(self.bullets) do
            -- if so, then remove both objects, add a sound later, and give the player some points
            if bullet:collides(asteroid) then
                gAudio['explosion']:stop()
                gAudio['explosion']:play()
                table.remove(self.bullets, b)
                asteroid.hp = asteroid.hp - self.player.bulletDamage
                if asteroid.hp <= 0 then
                    table.remove(self.asteroids, a)
                    self.player.points = self.player.points + asteroid.pointValue
                end

                
            end
        end
    end

    -- updates the bullets
    for i, bullet in pairs(self.bullets) do
        bullet:update(dt)
    end

    for p, object in pairs(self.objects) do
        if object:collides(self.player) then
            object.onConsume()
            table.remove(self.objects, p)
        end
    end

    -- garbage collection for bullets, asteroids, etc
    for i, bullet in pairs(self.bullets) do
        if bullet.y < -bullet.height then
            -- self.bullets[i] = nil
            --heard that this might cause wierd behaviour, but it hasn't yet, so I'll leave it for now
            table.remove(self.bullets, i)
        end
    end
    for a, asteroid in pairs(self.asteroids) do
        if asteroid.y > VIRTUAL_HEIGHT then
            -- same comment as above
            table.remove(self.asteroids, a)
        end
    end
    for o, object in pairs(self.objects) do
        if object.y > VIRTUAL_HEIGHT then
            table.remove(self.objects, o)
        end
    end
    self.powerUpSlot:update(dt)

    Timer.update(dt)
end

function World:render()
    World:PlayerStatsRender(self.player)
    self.powerUpSlot:render()
    -- renders the bullets
    for i, bullet in pairs(self.bullets) do
        bullet:render()
    end
    -- renders asteroids
    for a, asteroids in pairs(self.asteroids) do
        asteroids:render()
    end

    for o, object in pairs(self.objects) do
        object:render()
    end

    for p, powerUp in pairs(self.powerUps) do
        -- collision debugging
        --love.graphics.rectangle('line', powerUp.x - powerUp.radius, powerUp.y - powerUp.radius, powerUp.radius*2, powerUp.radius * 2)
        powerUp:render(self.player)
    end
end

function World:PlayerStatsRender(player, self)
    love.graphics.setColor(1, 1, 1 ,1)
    for i = 0, player.lives - 1 do 
        love.graphics.draw(gTextures['space-craft'], gImages['lives'], i * 64, 0, 0, 1.5, 1.5)
    end

    -- draws hwo much ammo we have
    love.graphics.setFont(gFonts['small_font'])
    --love.graphics.print('Ammo   : ' .. player.ammo, 0, 60)
    -- prints amount of points we have
    love.graphics.print('Points  : ' .. player.points, 0, 100)
    -- prints how much money we have
    love.graphics.print('Money  : ' .. player.money, 0, 140)
    -- prints distanceTravelled\
    if not (player.currentState == 'shop') then
        love.graphics.printf('Distance: ' .. math.floor(player.distanceTravelled), 0, 0, VIRTUAL_WIDTH, 'right')
    end
    
end