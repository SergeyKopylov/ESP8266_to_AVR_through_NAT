print ( "Waiting ...")

wifi.setmode(wifi.STATION)
local cfg={}
cfg.ssid="WiFi"
cfg.pwd="wifi_password"
wifi.sta.config(cfg)
cfg = nil
collectgarbage()
tmr.delay(2000)

-- Каждые 5 минут запускаем функцию проверки наличия новой прошивки
tmr.register (0, 30000, tmr.ALARM_AUTO, function (t) tmr.unregister (0); print ("Запуск проверки наличия новой прошивки"); dofile ( "check_firmware.lua") end)
tmr.start (0)

