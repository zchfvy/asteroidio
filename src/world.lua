
Class = require "hump.class"

Ship = require "src.ship"

World = Class{}

function World:init(w, h)
    self.ships = {}
    self.w = w
    self.h = h
end

function World:update(dt)
    -- Update the simulation
    for _, ship in pairs(self.ships) do
        ship:update(dt)
        if ship.p.x > self.w then ship.p.x = ship.p.x - self.w end
        if ship.p.x < 0      then ship.p.x = ship.p.x + self.w end
        if ship.p.y > self.h then ship.p.y = ship.p.y - self.h end
        if ship.p.y < 0      then ship.p.y = ship.p.y + self.h end
    end
end

function World:draw()
    -- Update the simulation
    for _, ship in pairs(self.ships) do
        ship:draw()
    end
end

function World:add_ship(user)
    self.ships[user] = Ship(user)
end

function World:net_update(data)
    -- Receives a packet from the net (clients only!)
    cmd, ent, params = data:match('^(%S*) (%S*) (.*)')
    ent = tonumber(ent)

    if cmd == 'up_ship' then
        if self.ships[ent] == nil then
            self.ships[ent] = Ship(ent)
        end
        self.ships[ent]:deserialize(params)
    end
    if cmd == 'del_ship' then
        self.ships:remove(ent)
    end
end

function World:client_msg(user, data)
    -- Receives a packet from the net (server only!)
    cmd, params = data:match('^(%S*) (.*)')
    if cmd == 'ship_ctrl' then
        turn, thrust = params:match('^(%-?[%de.]*) (%-?[%de.]*)')
        self.ships[user].thrust = tonumber(thrust)
        self.ships[user].turn = tonumber(turn)
    end
    if cmd == 'spawn' then
        self.ships[user] = Ship(user)
    end
end

return World
