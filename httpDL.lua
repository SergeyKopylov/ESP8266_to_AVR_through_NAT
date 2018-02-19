-- ESP8266-HTTP Library
-- Written 2014 by Tobias Mädel (t.maedel@alfeld.de) - https://github.com/Manawyrm/ESP8266-HTTP
-- Licensed unter MIT

local moduleName = ... 
local M = {}
_G[moduleName] = M

local buffer = nil

function M.download(host, port, url, path, md5, callback)

	file.remove(path);
	file.open(path, "w+")

	payloadFound = false
	
    -- net.createConnection(arguments...) - Создаёт новый сокет. Когда соединение установлено, будет сгенерировано событие 'connect'.
	conn=net.createConnection(net.TCP, 0) 
        -- Когда клиент к нам подключится, мы тут же для соединения с ним объявим еще одну функцию
        -- по событию receive (что-то получили от клиента). Будет вызвана наша inline функция,
        -- в которую будет передано 2 параметра: conn - думаю, ссылка на клиента, который послал нам запрос,
        -- и payload - думаю, что текст запроса в виде строки


--********************************************************************************************    
	conn:on("receive", function(conn, payload)
        if buffer == nil then
            buffer = payload
        else
            buffer = buffer..payload
        end
    		if (payloadFound == true) then
    			file.write(buffer)
    			file.flush()
print("Длина строки = ",string.len (buffer),"\tскачано: ",file.seek("end"),"байт")
    		else
    			if (string.find(buffer,"\r\n\r\n") ~= nil) then
	    			file.write(string.sub(buffer,string.find(buffer,"\r\n\r\n") + 4))
	    			file.flush()
		    		payloadFound = true
	    		end
	    	end
		buffer = nil
		-- запускаем встроенный сборщик мусора (освобождает всю занятую до этого нашими действиями RAM память)
      	collectgarbage()
	end)
    
	conn:on("disconnection", function(conn) 
		conn = nil
        print("размер файла = ",file.seek("end"))
		file.close()
        print ("Downloading is complete. Start checking MD5:")
--==============================================================
-- Проверяем, что скачанный файл и файл на сервере имеют одинаковый хэш:
http.get("http://192.168.1.2/objects/?script=esp_ota_update&sketch_req=AfterChecking",
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
              "x-esp8266-sketch-md5: "..crypto.toHex(crypto.fhash("md5",path)).."\r\n"..
              "x-esp8266-extension: no_ext\r\n"..
              "Connection: close\r\n"..
              "Accept-Charset: utf-8\r\n"..
              "Accept-Encoding: \r\n"..
              "User-Agent: ESP8266-http-Update\r\n".. 
              "Authorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n"..
              "Accept: */*\r\n\r\n",
              function(code, data)
                print("httpDL.lua: AfterChecking: \n   code: ", code, "\n   data: ", data)
                if (data ==  "MD5_OK") then
                    print("Download OK, MD5 is match")
                    callback("ok")
                else
                    print("Downloading was failed! (MD5 does not match)")
                    callback("failed")
                end

end)
        conn = nil
        -- запускаем встроенный сборщик мусора (освобождает всю занятую до этого нашими действиями RAM память)
        collectgarbage()
--==============================================================

	end)
	
--********************************************************************************************	
	conn:on("connection", function(conn)

remaining, used, total=file.fsinfo()
majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()

		conn:send("GET /"..url.." HTTP/1.0\r\n"..
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
			        "Connection: close\r\n"..
			        "Accept-Charset: utf-8\r\n"..
			        "Accept-Encoding: \r\n"..
              "User-Agent: ESP8266-http-Update\r\n".. 
              "Authorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n"..
			        "Accept: */*\r\n\r\n")

	end)
	conn:connect(port,host)

end
    remaining = nil
    used = nil
    total = nil
    majorVer = nil
    minorVer = nil
    devVer = nil
    chipid = nil
    flashid = nil
    flashsize = nil
    flashmode = nil
    flashspeed = nil
    collectgarbage()
return M
