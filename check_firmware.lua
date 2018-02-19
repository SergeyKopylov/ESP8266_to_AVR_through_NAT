--**************************************************************
-- sending a GET request and get the return value
--Feed the system watchdog.
--In general, if you ever need to use this function, you are doing it wrong :) - https://nodemcu.readthedocs.io/en/dev/en/modules/tmr/#tmrwdclr
tmr.wdclr()

local sketch = "sketch_download"   --Имя файла на ESP8266, куда будет ложиться прошивка (скетч)
local extension = "no_ext"

    if (file.exists(sketch)) then
        md5 = crypto.toHex(crypto.fhash("md5",sketch))
    else
        --файла нету, прописываем 'левый' хэш:
        md5 = "NoSketchFilePresent"
    end

local remaining, used, total=file.fsinfo()
local majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()

http.get("http://192.168.1.2/objects/?script=esp_ota_update&sketch_req=NewSketchChecking",
              "x-esp8266-sta-mac: "..wifi.sta.getmac().."\r\n"..
              "x-esp8266-sta-ip: "..wifi.sta.getip().."\r\n"..
              "x-esp8266-ap-mac: "..wifi.ap.getmac().."\r\n"..
              "x-esp8266-free-space: "..node.heap().."\r\n"..
              "x-esp8266-chip-size: "..node.flashsize().."\r\n"..
              "x-esp8266-chip-id: "..chipid.."\r\n"..
              "x-esp8266-sdk-version: "..majorVer.."."..minorVer.."."..devVer.."\r\n"..
              "x-esp8266-mode: "..wifi.getmode().."\r\n"..
              "x-esp8266-fs-total: "..total.."\r\n"..
              "x-esp8266-fs-used: "..used.."\r\n"..
              "x-esp8266-fs-remaining: "..remaining.."\r\n"..
              "x-esp8266-sketch-md5: "..md5.."\r\n"..
              "x-esp8266-extension: no_ext\r\n"..
              "x-file-name: noname\r\n"..
              "Connection: keep-alive\r\n"..
              "Accept-Charset: utf-8\r\n"..
              "Accept-Encoding: \r\n"..
              "User-Agent: ESP8266-http-Update\r\n".. 
              "Host: homeserver\r\n"..
              "Authorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n"..
              "Accept: */*\r\n\r\n",
              function(code, data, headers)
                    print("code = "..code.."\tdata = "..data)
                    print("x-file-name = ", headers["x-file-name"])
                    print("x-esp8266-extension = ", headers["x-esp8266-extension"])
                    print("content-length = ", headers["content-length"])
if (headers["x-esp8266-extension"] == nil) then
    print("Нет связи с сервером")
    extension = "no_sketch"
elseif (headers["x-esp8266-extension"] == "hex") then
    print("Используемый тип файла прошивки = "..headers["x-esp8266-extension"])
    extension = "hex"
--    sketch = "sketch.hex"
elseif (headers["x-esp8266-extension"] == "bin") then
    print("Используемый тип файла прошивки = "..headers["x-esp8266-extension"])
    extension = "bin"
--    sketch = "sketch.bin"
else
    print("Используемый тип файла прошивки - неизвестен = "..headers["x-esp8266-extension"])
    extension = "unknown"
end
                if (code < 0) then
                    print("HTTP request failed")
                else
                    if (data == "OK") then
--**************************************************************
-- Download a file

tmr.wdclr()

httpDL = require("httpDL")
collectgarbage()

httpDL.download("192.168.1.1", "80", "objects/?script=esp_ota_update", sketch, md5, function(ret_val)
    -- Finished downloading
remaining = nil
flashspeed = nil
flashsize = nil
majorVer = nil
minorVer = nil
flashmode = nil
devVer = nil
md5 = nil
used = nil
flashid = nil
chipid = nil

package.loaded["httpDL"]=nil
httpDL = nil
conn = nil
collectgarbage()

if (ret_val == nil) then
    print("ret_val == nil.. Что-то пошло не так...")
elseif (ret_val == "ok") then
    if (extension == "bin") then
        print("extension = bin")
        -- Начинаем прошивку
        require("Program_Flash")
        --Program_Flash ("sketch.bin")
        Program_Flash ("sketch_download")
        package.loaded["Program_Flash"]=nil
        Program_Flash = nil
    elseif (extension == "hex") then
        print("extension = hex")
        -- Копируем файл прошивки в sketch.hex
        local source = file.open(sketch, "r")
        local destin = file.open("sketch.hex", "w")
        local size = source:seek("end")
        source:seek("set",0)
        destin:seek("set",0)
        destin:write(source:read(size))
        destin:close()
        source:close()
        destin = nil
        source = nil
        -- Начинаем прошивку
        require("Program_Flash")
        Program_Flash ("sketch.hex")
        package.loaded["Program_Flash"]=nil
        Program_Flash = nil
    elseif (extension == "no_sketch") then
        print("extension = no_sketch")
    elseif (extension == "unknown") then
        print("extension = unknown")
    else
        print("Странное значение extension... Что-то пошло не так...")
    end  
elseif (ret_val == "failed") then
    print("ret_val == failed. Downloading was failed! (MD5 does not match)")
else
    print("Странное значение ret_val... Что-то пошло не так...")
end


end)

collectgarbage()
--==============================================================
                    end

                end

    remaining = nil
    flashspeed = nil
    flashsize = nil
    majorVer = nil
    minorVer = nil
    flashmode = nil
    devVer = nil
    md5 = nil
    used = nil
    flashid = nil
    chipid = nil
    collectgarbage()
               
end)
