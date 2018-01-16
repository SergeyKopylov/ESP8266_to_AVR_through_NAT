print ( "Waiting ...")

wifi.setmode(wifi.STATION)
local cfg={}
cfg.ssid="ASUS"
cfg.pwd="76543210"
wifi.sta.config(cfg)
cfg = nil
collectgarbage()

tmr.register (0, 5000, tmr.ALARM_SINGLE, function (t) tmr.unregister (0); print ( "Starting ..."); dofile ( "example.lua") end)
tmr.start (0)
