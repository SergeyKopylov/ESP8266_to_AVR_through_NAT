-- Отличная статья по записи прошивки через SPI: https://habrahabr.ru/post/152052/
-- Пин-маппинг - см. https://nodemcu.readthedocs.io/en/master/en/modules/gpio/#gpiomode
-- Он не соответствует реальным GPIO!!!
--[[
-------------------------------------------------|
IO index   | ESP8266 pin   |  Я использовал как: |
-------------------------------------------------|
0*         | GPIO16        |  RESET              |
1          | GPIO5         |                     |
2          | GPIO4         |                     |
3          | GPIO0         |                     |
4          | GPIO2         |                     |
5          | GPIO14        |  CLK                |
6          | GPIO12        |  MISO               |
7          | GPIO13        |  MOSI               |
8          | GPIO15        |                     |
9          | GPIO3         |                     |
10         | GPIO1         |                     |
11         | GPIO9         |                     |
12         | GPIO10        |                     |
--------------------------------------------------
[*] D0(GPIO16) can only be used as gpio read/write.
    No support for open-drain/interrupt/pwm/i2c/ow.
]]

function InstrProgrammingEnable () -- instruction for MC "enable programming"

-- Включение режима программирования - см: https://habrahabr.ru/post/152052/

p=0
while p<31 do --нахуа повторять это 31 раз????!!!!!
p=p+1

--[[
Команда на включение режима программирования:
10101100 01010011 xxxxxxxx xxxxxxxx (0xAC,0x53, 0xXX,0xXX)
]]
pin=7  
gpio.write(pin, gpio.LOW)
spi.send(1, 0xAC,0x53)
read = spi.recv( 1, 8)
print("read = ", string.byte(read)) 
spi.send(1,0,0)
gpio.write(pin, gpio.HIGH)

--[[
Во время передачи третьего байта контроллер должен переслать обратно второй байт
(01010011 = 0x53 = 83 [dec]). Если это произошло, значит, все хорошо, команда принята,
контроллер ждет дальнейших инструкций. Если ответ отличается, нужно перезагрузить МК
и попробовать все сначала.
]]
     if (string.byte(read)== 83) -- 83[dec] = 0x53 
        then     
        print("connection established") 
        p=33 --что это?????
            if(p==31)
            then 
            print("no connection")
            end
        end
    end
end


function ProgrammingDisable ()

 --END OF RESET FOR MK
pin=0
gpio.mode(pin, gpio.INPUT)

--pin=11 --CS MASTER for SPI - не используется!!!
--gpio.mode(pin, gpio.INPUT)

pin=5 --CLK MASTER for SPI
gpio.mode(pin, gpio.INPUT)

pin=6 --MISO MASTER  for SPI
gpio.mode(pin, gpio.INPUT)

pin=7 --MOSI MASTER for SPI
gpio.mode(pin, gpio.INPUT)
end


function ProgrammingEnable ()
pin=0-- RESET FOR MK
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)

pin=0--POZITIV FOR 4MSEC RESET FOR MK
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.HIGH)

tmr.delay(1000)
--tmr.delay(100000)
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.LOW)

tmr.delay(25000)
end



function InstrFlashErase() 

pin=7  
gpio.write(pin, gpio.LOW)
spi.send(1,0xAC,0x80,0,0)
gpio.write(pin, gpio.HIGH)
tmr.delay(15000)

pin=0--RESET FOR MK
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.HIGH)
tmr.delay(20000) -- ATMEGA328P_AU.pdf, п.27.8.82 - Wait for at least 20 ms and enable
-- serial programming by sending the Programming Enable serial instruction to pin MOSI
gpio.write(pin, gpio.LOW)

print( "FLASH is erased")
InstrProgrammingEnable () 
end



function InstrStorePAGE(H, address, data)

pin=7  
gpio.write(pin, gpio.LOW)
spi.send(1,H,0,address,data)
gpio.write(pin, gpio.HIGH)
tmr.delay(500)
end



function InstrWriteFLASH(page_address_low,page_address_high)

pin=7  
gpio.write(pin, gpio.LOW)
spi.send(1,0x4C,page_address_high,page_address_low,0)
gpio.write(pin, gpio.HIGH)
tmr.delay(5000)-- иногда не прописываются флэш при малых задержках
end




function Programming (payload)
fd = file.open(payload, "r")
--pin=11--CS MASTER for SPI
--gpio.mode(pin, gpio.OUTPUT, gpio.PULLUP)
--pin=4--LED LIGHTS ON LOW
--gpio.mode(pin, gpio.OUTPUT)
--gpio.write(pin, gpio.LOW)
--data_1kb = file.readline()
--print(string.len(data_1kb))
--print("data_1kb = ", data_1kb)
--[[ ATMEGA328P_AU.pdf, п. 27.5 Page Size:
Device		Flash Size	Page Size	PCWORD	No.of Pages	PCPAGE	PCMSB
ATmega48PA 	2K words	32 words 	PC[4:0]   64 		PC[10:5] 10
		 (4K bytes) 
ATmega88PA 	4K words	32 words 	PC[4:0]   128 		PC[11:5] 11
		 (8K bytes) 
ATmega168PA 	8K words	64 words 	PC[5:0]   128 		PC[12:6] 12
		 (16K bytes) 
ATmega328P 	16K words	64 words 	PC[5:0]   256 		PC[13:6] 13
		 (32K bytes) 
]]
-- Получается - размер одной страницы = 64 слова = 128 байт =
-- = 128*8 бит = 1024 бит = 1 кБайт

page_size_in_words = 64
page_size_in_bytes = page_size_in_words*2

--page_count = 7 -- пишем 1 килобайт 

page_count = fd:seek("end")/1024

print("file length = ", fd:seek("end"))
print("file length/1024+1 = ", fd:seek("end")/1024+1)

--for qty = 0, fd:seek("end")-1, 1 do --кол-во килобайт в файле


    for k =0  ,page_count ,1 do--quantity of pages

print ("node.heap = ", node.heap())

        print("k = ",k)

        for i=0 , page_size_in_bytes, 2 do-- -1
            print("i = ",i)
            address = i/2
--            data=data_1kb:byte(i+1+128*k)
fd:seek("set",i+page_size_in_bytes*k)
qw = fd:read(1)
print("fd:read[",i+page_size_in_bytes*k, "]", qw)
data = qw:byte(1) -- Может это и не нужная информация!!
-- Проверить загрузку без этого преобразования!

--print("data=data_1kb:byte(i+1+128*k): ",data)
            if data == nil 
            then
                data = 0xff
            end
print("fd:read[",i+page_size_in_bytes*k, "]", data)
            --InstrStorePAGE(0x40,address,data)
print("InstrStorePAGE(0x40",address,data,")")
--[[
            --  tmr.delay(100)--  otherwise not in time write
            data =data_1kb:byte(i+1+1+128*k)
fd:seek("set",qty+1)
print("fd:read(1)", fd:read(1))
print("data =data_1kb:byte(i+1+1+128*k): ",data)
            if data == nil then
                data = 0xff
            end
            --InstrStorePAGE(0x48,address,data)
print("InstrStorePAGE(0x48,",address,data,")")
            --    tmr.delay(100)
        end

        page_address_low=bit.band(k ,3)*64 -- 3 это двоичное 11
print("page_address_low = ",page_address_low)
        page_address_high=k/4+frame1024*2
print("page_address_high = ",page_address_high)

        tmr.delay(1000)
        --InstrWriteFLASH(page_address_low,page_address_high)
print("InstrWriteFLASH(",page_address_low,page_address_high,")")
-- Запись идёт по одной странице за раз
-- После записи одной страницы - нужно ждать сигнала RDY/BSY.
-- Если этот сигнал не используется - нужно ждать время  tWD_FLASH
-- перед записью новой страницы.
-- ATMEGA328P_AU.pdf, п. 27.8.2 Serial Programming Algorithm, Table 27-18
-- tWD_FLASH = 4.5 ms
-- tWD_EEPROM = 3.6 ms
-- tWD_ERASE = 9.0 ms
]]
    
--    end
collectgarbage()
tmr.delay(1000)
end

--tmr.wdclr()

file.close()

--pin=4--LED
--gpio.mode(pin, gpio.OUTPUT)
--gpio.write(pin, gpio.HIGH)
end
