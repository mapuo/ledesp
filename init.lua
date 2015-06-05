dofile("config.lua")

function log(msg)
    if LOG_ENABLE == true then
        print(msg)
    end
end

log("Configuration done! "..node.heap())

local led_module = require("color_module")
log("LED module loaded! "..node.heap())
local conn = require("connection")
log("Conn module loaded! "..node.heap())

led_module.setup()

log("LED module setup! "..node.heap())

conn.run(function(conn, topic, value)
    log(topic .. ":" .. value)
    cmd = string.match(topic, "/(%w+)$")
    log(cmd .. ":" .. value)
    if (cmd ~= nil and value ~= nil) then
        if (cmd == "power") then
            led_module.toggle_power(tonumber(value) == 1)
        elseif (cmd == "red" or cmd == "green" or cmd == "blue") then
            led_module.set_channel(cmd, tonumber(value))
        end
    end
end)

log("Connection module setup! "..node.heap())
