-- Main love2d entry point
Gamestate = require "hump.gamestate"
require "netclient"

World = require "src.world"

local loading = {}
local menu = {}  -- TODO: No menu state implemented yet!
local game = {}

-- -------------
-- Loading State
-- -------------

function loading:enter()
    --net_connect('localhost', 8089)
end

function loading.update(dt)
    -- data = net_recv()
    data = true
    if data then
        -- Todo, ensure we get valid "Hello" from server
        Gamestate.switch(game)
    end
end

-- ----------
-- Game State
-- ----------

function game:enter()
    world = World()
    world:add_ship(0)
end

function game:update(dt)
    world:update(dt)

    thrust = 0
    if love.keyboard.isDown('up') then thrust = thrust + 50
    end
    world.ships[0].thrust = thrust

    turn = 0
    if     love.keyboard.isDown('left')  then turn = turn - 1.5
    elseif love.keyboard.isDown('right') then turn = turn + 1.5
    end
    world.ships[0].turn = turn
end

function game:draw()
    world:draw()
end

-- ---------------
-- Love2d Plumbing
-- ---------------

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(loading)
end
