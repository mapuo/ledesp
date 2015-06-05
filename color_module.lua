local color_module = {}

config_file = "led_status.lua"

local function load_config()
    local f = file.open(config_file, "r")
    file.close()
    if f ~= nil then dofile(config_file) end
end

local function save_config()
    tmr.stop(1)
    tmr.alarm(1, 1700, 0, function()
        file.open(config_file,"w+")
        file.writeline("LED_POWER="..tostring(LED_POWER))
        file.write("LED_COLOR={")
        local first = true
        for channel, percent in pairs(LED_COLOR) do
            if first == false then file.write(",") end
            file.write(channel.."="..percent)
            first = false
        end
        file.write("} -- color\n")
        file.flush()
        file.close()
    end)
end

local function check_percent(percent)
    if (percent > 100) then percent = 100 end
    if (percent < 0) then percent = 0 end
    return percent
end

local function from_percent(percent)
    return (percent * 1023) / 100
end

local function to_percent(value)
    return (value / 1023) * 100
end

function color_module.setup()
    load_config()
    color_module.toggle_power(LED_POWER)
    color_module.set_color(LED_COLOR)
end

function color_module.toggle_power(power)
    if power == true then
        for channel, pin in pairs(LED_PINS) do
            pwm.setup(pin, 1000, 0)
            pwm.start(pin)
        end
    else
        for channel, pin in pairs(LED_PINS) do
            pwm.stop(pin)
        end
    end
    LED_POWER = power
    save_config()
end

function color_module.set_color(color)
    --if LED_POWER == false then return nil end
    for channel, percent in pairs(color) do
        color_module.set_channel(channel, percent)
    end
    LED_COLOR = color
    save_config()
end

function color_module.set_channel(channel, percent)
    --if LED_POWER == false then return nil end
    percent = check_percent(percent)
    local value = from_percent(percent)
    pwm.setduty(LED_PINS[channel], value)
    LED_COLOR[channel] = percent
    save_config()
end

return color_module
