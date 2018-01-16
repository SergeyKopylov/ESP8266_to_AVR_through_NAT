--**************************************************************
-- sending a GET request and get the return value

--Feed the system watchdog.
--In general, if you ever need to use this function, you are doing it wrong :) - https://nodemcu.readthedocs.io/en/dev/en/modules/tmr/#tmrwdclr
tmr.wdclr()
collectgarbage()
sketch = "sketch.bin"   --Имя файла на ESP8266, куда будет ложиться прошивка (скетч)
    if (file.exists(sketch)) then
        md5 = crypto.toHex(crypto.fhash("md5",sketch))
    else
        --файла нету, прописываем 'левый' хэш:
        md5 = "NoSketchFilePresent"
    end

remaining, used, total=file.fsinfo()
majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()

http.get("http://192.168.1.69/objects/?script=esp_ota_update&sketch_req=NewSketchCheking",
              "x-ESP8266-STA-MAC: "..wifi.sta.getmac().."\r\n"..
              "x-ESP8266-STA-IP: "..wifi.sta.getip().."\r\n"..
              "x-ESP8266-AP-MAC: "..wifi.ap.getmac().."\r\n"..
              "x-ESP8266-free-space: "..node.heap().."\r\n"..
              "x-ESP8266-chip-size: "..node.flashsize().."\r\n"..
              "x-ESP8266-chip-id: "..chipid.."\r\n"..
              "x-ESP8266-sdk-version: "..majorVer.."."..minorVer.."."..devVer.."\r\n"..
              "x-ESP8266-mode: "..wifi.getmode().."\r\n"..
              "x-ESP8266-fs-total: "..total.."\r\n"..
              "x-ESP8266-fs-used: "..used.."\r\n"..
              "x-ESP8266-fs-remaining: "..remaining.."\r\n"..
              "x-ESP8266-sketch-md5: "..md5.."\r\n"..
              "Connection: close\r\n"..
              "Accept-Charset: utf-8\r\n"..
              "Accept-Encoding: \r\n"..
              "User-Agent: ESP8266-http-Update\r\n".. 
              "Accept: */*\r\n\r\n",
              function(code, data)
                    print(code, data)
                if (code < 0) then
                    print("HTTP request failed")
                else
                    if (data == "OK") then
--**************************************************************
-- Download a file

tmr.wdclr()

httpDL = require("httpDL")
collectgarbage()

httpDL.download("192.168.1.69", "80", "objects/?script=esp_ota_update", sketch, md5, function (payload)
    -- Finished downloading
end)

httpDL = nil
package.loaded["httpDL"]=nil
collectgarbage()
--==============================================================
                    end

                end

end)



