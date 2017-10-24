
Class = require "hump.class"
vector = require "hump.vector"
json = require "json"

Ship = Class{}

function Ship:init(owner, x, y)
    self.owner = owner

    self.p = vector(x or 0, y or 0)
    self.v = vector(0, 0)
    self.rot = 0

    self.thrust = 0
    self.turn = 0
end

function Ship:update(dt)
    self.rot = self.rot + self.turn * dt
    local accel = vector.fromPolar(self.rot, self.thrust)
    self.v = self.v + accel * dt
    self.p = self.p + self.v * dt
end

function Ship:serialize()
    return json.encode({
        _type = 'ship',
        px = self.p.x, py = self.p.y,
        vx = self.v.x, vy = self.v.y,
        rot = self.rot,
        thrust = self.thrust
    })
end

function Ship:deserialize(srl)
    -- TODO: Lag correction/prediction here!
    data = json.decode(srl)

    self.p.x, self.p.y = tonumber(data.px), tonumber(data.py)
    self.v.x, self.v.y = tonumber(data.vx), tonumber(data.vy)

    self.rot = tonumber(data.rot)
    self.thrust = tonumber(data.thrust)
end

function Ship:draw()
    love.graphics.push()
    love.graphics.translate(self.p.x, self.p.y)
    love.graphics.rotate(self.rot + math.pi/2)

    love.graphics.line(
          0, -15,
        -10,  15,
         10,  15,
          0,   -15)

    love.graphics.pop()
end

return Ship
