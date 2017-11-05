
Class = require "hump.class"
vector = require "hump.vector"
json = require "json"

actorfactory = require "game.actorfactory"

Ship = Class{}
Ship.atype = 'ship'

function Ship:init(owner)
    self.owner = owner or nil

    self.p = vector(x or 0, y or 0)
    self.v = vector(0, 0)
    self.rot = 0

    self.thrust = 0
    self.turn = 0

    self.shot_cooldown = 0
    self.fire_rate = 0.5

    self.atype = Ship.atype
end

function Ship:get_forward()
    return vector.fromPolar(self.rot, 1)
end

function Ship:update(dt)
    self.rot = self.rot + self.turn * dt
    local accel = vector.fromPolar(self.rot, self.thrust)
    self.v = self.v + accel * dt
    self.p = self.p + self.v * dt

    self.shot_cooldown = self.shot_cooldown - dt
end

function Ship:serialize()
    return json.encode({
        px = self.p.x, py = self.p.y,
        vx = self.v.x, vy = self.v.y,
        rot = self.rot,
        thrust = self.thrust,
        owner = self.owner
    })
end

function Ship:deserialize(srl)
    -- TODO: Lag correction/prediction here!
    data = json.decode(srl)

    self.p.x, self.p.y = tonumber(data.px), tonumber(data.py)
    self.v.x, self.v.y = tonumber(data.vx), tonumber(data.vy)

    self.rot = tonumber(data.rot)
    self.thrust = tonumber(data.thrust)

    self.owner = tonumber(data.owner)
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

actorfactory.register(Ship.atype, Ship)
return Ship
