
Class = require "hump.class"

actorfactory = require "game.actorfactory"
Ship = require "game.ship"
Bullet = require "game.bullet"

World = Class{}

function World:init(w, h)
    self.actors = {}
    self.users = {}
    self.local_user_id = nil
    self.local_ship_id = nil
    self.w = w
    self.h = h
end

function World:update(dt)
    -- Update the simulation
    dead_actors = {}
    for id, actor in pairs(self.actors) do
        actor:update(dt)

        if actor.p.x > self.w then actor.p.x = actor.p.x - self.w end
        if actor.p.x < 0      then actor.p.x = actor.p.x + self.w end
        if actor.p.y > self.h then actor.p.y = actor.p.y - self.h end
        if actor.p.y < 0      then actor.p.y = actor.p.y + self.h end
        if actor.destroy then
            dead_actors[id] = id
        end
    end

    for id, actor in pairs(dead_actors) do
        self.actors[id] = nil
    end
end

function World:draw()
    -- Update the simulation
    for _, actor in pairs(self.actors) do
        actor:draw()
    end
end

function World:user_joined(user)
    self.users[user] = {}
end

function World:user_left(user)
    ship = self.users[user]['ship']
    if ship ~= nil then
        self.actors[ship] = nil
    end
    self.users[user] = nil;
end

function World:get_local_ship()
    if self.local_ship_id ~= nil then
        return self.actors[self.local_ship_id]
    end
    return nil
end

function World:net_update(data)
    -- Receives a packet from the net (clients only!)
    local cmd, ent, params = data:match('^(%S*) (%S*) (.*)')
    local ent = tonumber(ent)

    if cmd == 'new_actor' then
        atype, state = params:match('^(%S*) (.*)')
        self.actors[ent] = actorfactory.spawn(atype)
        act = self.actors[ent]
        act:deserialize(state)

        print(string.format('New Actor %d(%s) Owner: %d', ent, atype, act.owner))

        if atype == Ship.atype and act.owner == self.local_user_id then
            self.local_ship_id = ent
        end
    elseif cmd == 'up_actor' then
        self.actors[ent]:deserialize(params)
    elseif cmd == 'del_actor' then
        self.actors[ent] = nil
        if ent == self.local_ship_id then
            self.local_ship_id = nil
        end
    end
end

function World:client_msg(user, data)
    -- Receives a packet from the net (server only!)
    local cmd, params = data:match('^(%S*) (.*)')

    if cmd == 'ship_ctrl' then
        ship = self.users[user].ship
        if ship ~= nil then
            local turn, thrust = params:match('^(%-?[%de.]*) (%-?[%de.]*)')
            self.actors[ship].thrust = tonumber(thrust)
            self.actors[ship].turn = tonumber(turn)
        end
    end
    if cmd == 'shoot' then
        ship = self.users[user].ship
        if ship ~= nil then
            bullet = Bullet(user)
            ship = self.actors[ship]
            if ship.shot_cooldown < 0 then
                self.actors[#(self.actors) + 1] = bullet
                bullet.p = ship.p
                bullet.v = ship:get_forward() * 100
                ship.shot_cooldown = ship.fire_rate
            end
        end
    end
    if cmd == 'spawn' then
        if self.users[user].ship == nil then
            ship = #(self.actors) + 1
            self.actors[ship] = Ship(user)
            self.users[user].ship = ship
            print(string.format('Spawning ship %d for user %d', ship, user))
        end
    end
end

return World
