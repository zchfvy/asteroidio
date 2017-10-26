
Class = require "hump.class"

actorfactory = require "game.actorfactory"
Ship = require "game.ship"

World = Class{}

function World:init(w, h)
    self.actors = {}
    self.w = w
    self.h = h
end

function World:update(dt)
    -- Update the simulation
    for _, actor in pairs(self.actors) do
        actor:update(dt)
        if actor.p.x > self.w then actor.p.x = actor.p.x - self.w end
        if actor.p.x < 0      then actor.p.x = actor.p.x + self.w end
        if actor.p.y > self.h then actor.p.y = actor.p.y - self.h end
        if actor.p.y < 0      then actor.p.y = actor.p.y + self.h end
    end
end

function World:draw()
    -- Update the simulation
    for _, actor in pairs(self.actors) do
        actor:draw()
    end
end

function World:add_ship(user)
    self.actors[user] = Ship(user)
end

function World:user_left(user)
    self.actors[user] = ni;
end

function World:net_update(data)
    -- Receives a packet from the net (clients only!)
    local cmd, ent, params = data:match('^(%S*) (%S*) (.*)')
    local ent = tonumber(ent)

    if cmd == 'new_actor' then
        self.actors[ent] = actorfactory.spawn(params, ent)
    elseif cmd == 'up_actor' then
        self.actors[ent]:deserialize(params)
    elseif cmd == 'del_actor' then
        self.actors[ent] = nil
    end
end

function World:client_msg(user, data)
    -- Receives a packet from the net (server only!)
    local cmd, params = data:match('^(%S*) (.*)')
    if cmd == 'ship_ctrl' then
        local turn, thrust = params:match('^(%-?[%de.]*) (%-?[%de.]*)')
        self.actors[user].thrust = tonumber(thrust)
        self.actors[user].turn = tonumber(turn)
    end
    if cmd == 'spawn' then
        self.actors[user] = Ship(user)
    end
end

return World
