
Class = require "hump.class"
vector = require "hump.vector"
json = require "json"

actorfactory = require "game.actorfactory"


Bullet = Class{}
Bullet.atype = 'bullet'

function Bullet:init(owner)
    self.net_temporary = true

    self.owner = owner

    self.p = vector(0, 0)
    self.v = vector(0, 0)

    self.life = 5
end

function Bullet:update(dt)
    self.p = self.p + self.v * dt
    self.life = self.life - dt

    if self.life < 0 then
        self.destroy = true
    end
end

function Bullet:draw()
    love.graphics.points(self.p.x, self.p.y)
end

function Bullet:serialize()
    return json.encode({
        px = self.p.x, py = self.p.y,
        vx = self.v.x, vy = self.v.y,
        owner = self.owner
    })
end

function Bullet:deserialize(srl)
    -- TODO: Lag correction/prediction here!
    data = json.decode(srl)

    self.p.x, self.p.y = tonumber(data.px), tonumber(data.py)
    self.v.x, self.v.y = tonumber(data.vx), tonumber(data.vy)

    self.owner = tonumber(data.owner)
end

actorfactory.register(Bullet.atype, Bullet)
return Bullet
