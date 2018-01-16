local moduleName = ... 
local M = {}
_G[moduleName] = M

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
    		if (payloadFound == true) then
    			file.write(payload)
    			file.flush()
    		else
    			if (string.find(payload,"\r\n\r\n") ~= nil) then
	    			file.write(string.sub(payload,string.find(payload,"\r\n\r\n") + 4))
	    			file.flush()
		    		payloadFound = true
	    		end
	    	end

		payload = nil
		-- запускаем встроенный сборщик мусора (освобождает всю занятую до этого нашими действиями RAM память)
      	collectgarbage()
	end)
    
	conn:on("disconnection", function(conn) 
		conn = nil
		file.close()
		callback("ok")
        print ("Downloading is complete. Start checking MD5:")
--==============================================================
-- Проверяем, что скачанный файл и файл на сервере имеют одинаковый хэш:
http.get("http://192.168.1.69/objects/?script=esp_ota_update&sketch_req=AfterChecking",
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
              "x-ESP8266-sketch-md5: "..crypto.toHex(crypto.fhash("md5",sketch)).."\r\n"..
              "Connection: close\r\n"..
              "Accept-Charset: utf-8\r\n"..
              "Accept-Encoding: \r\n"..
              "User-Agent: ESP8266-http-Update\r\n".. 
              "Accept: */*\r\n\r\n",
              function(code, data)
                print("httpDL.lua: AfterChecking: \n   code: ", code, "\n   data: ", data)
                if (data ==  "MD5_OK") then
                    print("Download OK, MD5 is match")
                else
                    print("Downloading was failed! (MD5 does not match)")
                end

end)
        conn = nil
        callback("ok")
        -- запускаем встроенный сборщик мусора (освобождает всю занятую до этого нашими действиями RAM память)
        collectgarbage()
--==============================================================

	end)
	
--********************************************************************************************	
	conn:on("connection", function(conn)

remaining, used, total=file.fsinfo()
majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()

		conn:send("GET /"..url.." HTTP/1.0\r\n"..
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
			  "Accept: */*\r\n\r\n")
--[[
print ("conn:send(GET /"..url.." HTTP/1.0\r\n"..
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
              "Accept: */*\r\n\r\n")
]]

	end)
	conn:connect(port,host)
end
return M
