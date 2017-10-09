local copas = require('copas')
local websocket = require('websocket')

local World = require 'src.world'

NET_DEBUG = false

world = World()


function send(ws, msg)
    if NET_DEBUG then
        print('>>>'..msg)
    end
    ws:send(msg..'\n', 2)
end

function sendfmt(ws, fmt, ...)
    send(ws, string.format(fmt, unpack(arg)))
end

function run_websock(ws)
    while running do
        data = ws:receive()
        if data then
            if NET_DEBUG then
                print('<<<'..data)
            end
            cmd, params = data:match('^(%S*) (.*)')
            if cmd == 'join' and ws.id == nil then
                ws.id = math.random(999999)
                print('New Client '..ws.id)
            end

            if cmd == 'join' then
                sendfmt(ws, '%d', ws.id)
            elseif ws.id == nil then
                send(ws, 'ERROR: unjoined client')
            elseif cmd == 'input' then
                world:client_msg(ws.id, params)
            elseif cmd == 'update' then
                for id, ship in pairs(world.ships) do
                    sendfmt(ws, 'up_ship %d %s', id, ship:serialize())
                end
            end
        else
            ws:close()
        end
    end
end


local server = websocket.server.copas.listen{
    port = 8089,
    protocols = {
        binary = run_websock
    }
}

while true do
    running = true
    copas.step(0.1)
    running = false

    world:update(0.1)
end
