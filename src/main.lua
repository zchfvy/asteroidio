-- Main love2d entry point
Gamestate = require "hump.gamestate"
require "netclient"

World = require "game.world"

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
        print('Attempting Connection...')
        net_send('join 0') --- ping in order to say hello
        repeat
            data, msg = net_recv()
            if data then
                -- Todo, ensure we get valid "Hello" from server
                client_id, wx, wy = data:match('^(%S*) (%S*) (%S*)')
                client_id = tonumber(client_id)
                wx, wy = tonumber(wx), tonumber(wy)
                world = World(wx, wy)
                world.local_user_id = client_id
                love.window.setMode(wx, wy)
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
    net_sendfmt('input spawn 0')

    t = 0
end

function game:update(dt)
    world:update(dt)

    local turn, thrust = 0, 0

    local_ship = world:get_local_ship()
    if local_ship ~= nil then
        if love.keyboard.isDown('up') then thrust = thrust + 50
        end
        local_ship.thrust = thrust

        if     love.keyboard.isDown('left')  then turn = turn - 1.5
        elseif love.keyboard.isDown('right') then turn = turn + 1.5
        end
        local_ship.turn = turn

        if love.keyboard.isDown('x') then
            net_send('input shoot 0')
        end
    end

    t = t + dt

    if t > updaterate then
        if turn and thrust then
            net_sendfmt('input ship_ctrl %d %d', turn, thrust)
        end
        net_send('update 0')

        t = t - updaterate
    end

    local data, msg
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
