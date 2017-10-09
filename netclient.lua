-- Network client manager
local socket = require 'socket'

NET_DEBUG = false

function net_connect(address, port)
    tcp = socket.tcp()
    tcp:connect(address, port)
end

function net_disconnect()
    tcp:close()
end

function net_send(msg)
    if NET_DEBUG and msg then
        print('>>>'..msg)
    end
    tcp:send(msg)
end

function net_sendfmt(fmt, ...)
    net_send(string.format(fmt, unpack(arg)))
end

function net_recv()
    msg =  tcp:receive('*l')
    if NET_DEBUG and msg then
        print('<<<'..msg)
    end
    return msg
end
