
Class = require "hump.class"

Ship = require "src.ship"

World = Class{}

function World:init(w, h)
    self.ships = {}
end

function World:update(dt)
    -- Update the simulation
    for _, ship in pairs(self.ships) do
        ship:update(dt)
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
    ent, cmd, params = data:match('^(%S*) (%S*) (.*)')

    if cmd == 'up_ship' then
        if not self.ships[ent] then
            self.ships[ent] = Ship(ent)
        end
        self.ships[ent]:update(params)
    end
    if cmd == 'del_ship' then
        self.ships:remove(ent)
    end
end

function World:client_msg(user, data)
    -- Receives a packet from the net (server only!)
    cmd, params = data:match('^(%S*) (.*)')
    if cmd == 'ship_ctrl' then
        turn, thrust = params:match('^(%S*) (%S*)')
        self.ships[user].thrust = tonumber(thrust)
        self.ships[user].turn = tonumber(turn)
    end
    if cmd == 'spawn' then
        self.ships[user] = Ship(user)
    end
end

return World
