local white_module = {}

pin = 1
brightness = 100

function white_module.setup()
    pwm.setup(pin, 1000, 0)
    pwm.start(pin)
    white_module.set_brightness(brightness)
end

function white_module.toggle_power(power)
    if power == true then
        white_module.setup()
    else
        pwm.stop(pin)
    end
end

function white_module.set_brightness(percent)
    percent = check_percent(percent)
    local value = from_percent(percent)
    pwm.setduty(pin, value)
    brightness = percent
end

function check_percent(percent)
    if (percent > 100) then percent = 100 end
    if (percent < 0) then percent = 0 end
    return percent
end

function from_percent(percent)
    return (percent * 1023) / 100
end

function to_percent(value)
    return (value / 1023) * 100
end

return white_module