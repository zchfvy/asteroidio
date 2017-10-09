-- Main love2d entry point
Gamestate = require "hump.gamestate"
require "netclient"

World = require "src.world"

local connecting = {}
local menu = {}  -- TODO: No menu state implemented yet!
local game = {}

updaterate = 0.1
join_retransmit = 0.5

-- -------------
-- Loading State
-- -------------


function connecting:enter()
    net_connect('localhost', 8089)

    net_timer = join_retransmit
end

function connecting:update(dt)

    if net_timer > 0 then
        net_timer = net_timer - dt -- always delay at least one frame
    else
        net_timer = join_retransmit
        net_send('join 0') --- ping in order to say hello
        repeat
            data, msg = net_recv()
            if data then
                -- Todo, ensure we get valid "Hello" from server
                client_id = tonumber(data)
                print('Connected as '..client_id)
                Gamestate.switch(game)
            end
        until not data
    end

end

-- ----------
-- Game State
-- ----------

function game:enter()
    print('entering gamestate')
    world = World()
    net_sendfmt('input spawn 0')

    t = 0
end

function game:update(dt)
    world:update(dt)

    if world.ships[client_id] ~= nil then
        thrust = 0
        if love.keyboard.isDown('up') then thrust = thrust + 50
        end
        world.ships[client_id].thrust = thrust

        turn = 0
        if     love.keyboard.isDown('left')  then turn = turn - 1.5
        elseif love.keyboard.isDown('right') then turn = turn + 1.5
        end
        world.ships[client_id].turn = turn
    end

    t = t + dt

    if t > updaterate then
        if turn and thrust then
            net_sendfmt('input ship_ctrl %d %d', turn, thrust)
        end
        net_send('update 0')

        t = t - updaterate
    end

    repeat
        data, msg = net_recv()

        if data then
            world:net_update(data)
        end
    until not data
end

function game:draw()
    world:draw()
end

-- ---------------
-- Love2d Plumbing
-- ---------------

function love.load()
    print('lodaing...')
    Gamestate.registerEvents()
    Gamestate.switch(connecting)
end
