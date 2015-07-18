local connection = {}

local function on_connect(conn)
  log("Connected to MQTT: "..BROKER..":"..BRPORT.." as "..CLIENTID)
  m:subscribe(LED_COLOR_TOPIC, 0, function(conn) log("subscribe success") end)
end

local function connect_broker()
  log("Connecting to MQTT broker. Please wait...")
  m:connect(BROKER, BRPORT, 0, on_connect)
end

local function connect_to_router(ssid, pass)
  wifi.sta.getip()
  wifi.setmode(wifi.STATION)
  tmr.delay(250000)
  wifi.sta.config(ssid, pass)
  tmr.delay(1000000)
end

local function on_mqqt_offline(conn)
  log("offline")
  tmr.wdclr()
  m:close()
  tmr.alarm(0, 250, 0, connect_broker)
end

function connection.run(on_message_received)
  connect_to_router(SSID, PASS)
  tmr.alarm(0, 1000, 1,
    function()
      ip = wifi.sta.getip()
      if ip ~= nil then
        log("Connected to "..ip)
        if ip ~= nil then
            -- timer is no longer needed
            tmr.stop(0)
            -- connect to mqtt broker
            m = mqtt.Client(CLIENTID, 120, BRUSER, BRPWD)
            m:on("message", on_message_received)
            m:on("offline", on_mqqt_offline)
            connect_broker()
        end
      else
        log("Connecting to "..SSID)
      end
    end)
end

return connection
