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
local mytimer = tmr.create()
mytimer:register (300000, tmr.ALARM_AUTO, function (t)  
    if (wifi.sta.getip() ~= nil) then
        print ("Запуск проверки наличия новой прошивки")
        dofile ( "check_firmware.lua")
    else
        print("Нет доступной сети WiFi")
    end;
end)
mytimer:start (0)
