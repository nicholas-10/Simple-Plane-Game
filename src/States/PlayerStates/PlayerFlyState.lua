PlayerFlyState = Class{__includes = BasePlayerState}

function PlayerFlyState:init(player, world)
    self.player = player
    self.world = world
    self.player.currentState = 'fly'
end
function PlayerFlyState:update(dt)
    BaseUpdateMovement(dt, self.player)

    if love.keyboard.isDown('space') and not self.player.readyingNextShot then
        -- inserts into the bullets table in the world and instance of a bullet
        table.insert(self.world.bullets, Bullet(self.player))

        -- substracts ammo by 1
        self.player.ammo = self.player.ammo - 1
        self.player.readyingNextShot = true
        Timer.after(0.5, function () self.player.readyingNextShot = false end)
        -- plays audio but stops it first so the sounds don't mix
        gAudio['bullets']:stop()
        gAudio['bullets']:play()
    end

    if self.player.ammo == 0 then
        PlayerStates:change('reload')
    end

    if self.world.currentlyBossBattle == false then
        self.player.distanceTravelled = self.player.distanceTravelled +  PLAYER_SPEED * self.player.speedMulti * dt
    end
    --Timer.update(dt)
end
function PlayerFlyState:render()
    self.player:render()
    --love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
end