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
--*************************************************
--******* Локальные переменные этой функции *******
local ATmega = 0
-- ATmega = 48,  если ATmega48PA
-- ATmega = 88,  если ATmega88PA
-- ATmega = 168, если ATmega168PA
-- ATmega = 328,  если ATmega328P
--*************************************************


--##############################################################################################
function InstrProgrammingEnable () -- instruction for MC "enable programming"

local sign_1, sign_1_int, sign_2, sign_2_int, sign_3, sign_3_int, pin, read

-- Включение режима программирования - см: https://habrahabr.ru/post/152052/
pin=7 --MOSI MASTER for SPI
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
-- Считывание идентификатора процессора
        sign_1_int = 0; sign_2_int = 0; sign_3_int = 0
        sign_1 = ""; sign_2 = ""; sign_3 = ""
        
        spi.send(1, 0x30,0x00,0x00)
        sign_1 = spi.recv( 1, 8)
        --print("Идентификатор_1 = ",string.format("%X",string.byte(sign_1)))
        sign_1_int = tonumber(string.format("%d",string.byte(sign_1)))
        spi.send(1,0x00)

        spi.send(1, 0x30,0x00, 0x01)
        sign_2 = spi.recv( 1, 8)
        --print("Идентификатор_2 = ",string.format("%X",string.byte(sign_2)))
        sign_2_int = tonumber(string.format("%d",string.byte(sign_2)))
        spi.send(1,0x00)

        spi.send(1, 0x30,0x00, 0x02)
        sign_3 = spi.recv( 1, 8)
        --print("Идентификатор_3 = ",string.format("%X",string.byte(sign_3)))
        sign_3_int = tonumber(string.format("%d",string.byte(sign_3)))
        spi.send(1,0x00)

    if (sign_1_int == 0x1E) and (sign_2_int == 0x92) and (sign_3_int == 0x0A) then
        print("\nОбнаружен микроконтроллер ATmega48PA\n")
    elseif (sign_1_int == 0x1E) and (sign_2_int == 0x93) and (sign_3_int == 0x0F) then
        print("\nОбнаружен микроконтроллер ATmega88PA\n")
    elseif (sign_1_int == 0x1E) and (sign_2_int == 0x94) and (sign_3_int == 0x0B) then
        print("\nОбнаружен микроконтроллер ATmega168PA\n")
    elseif (sign_1_int == 0x1E) and (sign_2_int == 0x95) and (sign_3_int == 0x0F) then
        print("\nОбнаружен микроконтроллер ATmega328P\n")
    else
        print("Обнаружен неизвестный микроконтроллер!!!")
        collectgarbage()
        return 0
    end

else
    print("no connection")
    collectgarbage()
    return 0
end
collectgarbage()
return 1

end
--===========================================================================================================

--###########################################################################################################
function ProgrammingDisable ()

local pin
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
--===========================================================================================================


--###########################################################################################################
function ProgrammingEnable ()

local pin
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
--===========================================================================================================

--###########################################################################################################
function InstrFlashErase() 

local pin
pin=7  --MOSI MASTER for SPI 
gpio.write(pin, gpio.LOW)
spi.send(1,0xAC,0x80,0x00,0x00)
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
InstrProgrammingEnable = nil
end
--===========================================================================================================

--###########################################################################################################
function InstrStorePAGE(H, address, data)

local pin
pin=7 --MOSI MASTER for SPI  
gpio.write(pin, gpio.LOW)
spi.send(1,H,0,address,data)
gpio.write(pin, gpio.HIGH)
tmr.delay(500)

end
--===========================================================================================================

--###########################################################################################################
function InstrWriteFLASH(page_address_low,page_address_high)

local pin
pin=7 --MOSI MASTER for SPI  
gpio.write(pin, gpio.LOW)
spi.send(1,0x4C,page_address_high,page_address_low,0)
gpio.write(pin, gpio.HIGH)
tmr.delay(4500)-- иногда не прописываются флэш при малых задержках

end
--===========================================================================================================

--###########################################################################################################
function ReadProgramMemoryPAGE (page_address_low,page_address_high)

--[[ ATMEGA328P_AU.pdf, п. 27.5 Page Size:
Device        Flash Size  Page Size   PCWORD  No.of Pages PCPAGE  PCMSB
ATmega48PA  2K words    32 words    PC[4:0]   64        PC[10:5] 10
             (4K bytes) 
ATmega88PA  4K words    32 words    PC[4:0]   128       PC[11:5] 11
             (8K bytes) 
ATmega168PA 8K words    64 words    PC[5:0]   128       PC[12:6] 12
             (16K bytes) 
ATmega328P  16K words   64 words    PC[5:0]   256       PC[13:6] 13
             (32K bytes) 
]]
-- Получается - размер одной страницы = 64 слова = 128 байт =
-- = 128*8 бит = 1024 бит = 1 кБайт

    local    word = ""
    local    q = 1
    local LSB, MSB, addr
    
    for i=0, 63, 1 do -- 63 = 128/2-1 - это размер страницы памяти ATmega328P


        spi.send(1, 0x20, page_address_high,page_address_low+i)
        LSB = (spi.recv( 1, 8))
        spi.send(1,0x00)
if LSB == nil then LSB = 0x00 end
--print("LSB = "..LSB)

        spi.send(1, 0x28,page_address_high,page_address_low+i)
        MSB = spi.recv( 1, 8)
        spi.send(1,0x00)
if MSB == nil then MSB = 0x00 end
--print("MSB = "..MSB)

        addr = (bit.lshift(bit.band(page_address_high, 0xFF), 8) + bit.band(page_address_low, 0xFF))*2
--        word = string.format('%x', tonumber(string.sub(LSB,1,1)),10).." "..string.format('%x', tonumber(string.sub(MSB,1,1)),10).." "
        word = word..string.format('%02X', string.byte(string.sub(LSB,1,1))).." "..string.format('%02X', string.byte(string.sub(MSB,1,1))).." "
--print("q = "..q)
        if q >= 8 then
            print("addr: 0x"..string.format('%04X', addr+(i-7)*2)..", \t"..word)
            q = 0
            word = ""
        end
        
        q = q + 1
--        tmr.delay(50)
    end
collectgarbage()
end
--===========================================================================================================

--###########################################################################################################
function Programming_bin (FlashFile)

if file.exists(FlashFile) then
    print("Open file: ",FlashFile)
    fd_bin = file.open(FlashFile, "r")
else
    print("No sketch file!!! : ",FlashFile)
    return

end

--pin=7 --MOSI MASTER for SPI  
--gpio.mode(pin, gpio.OUTPUT, gpio.PULLUP)

--[[ ATMEGA328P_AU.pdf, п. 27.5 Page Size:
Device		Flash Size	Page Size	PCWORD	No.of Pages	PCPAGE	PCMSB
ATmega48PA 	2K words	32 words 	PC[4:0]   64 		PC[10:5] 10
		     (4K bytes) 
ATmega88PA 	4K words	32 words 	PC[4:0]   128 		PC[11:5] 11
		     (8K bytes) 
ATmega168PA 8K words	64 words 	PC[5:0]   128 		PC[12:6] 12
		     (16K bytes) 
ATmega328P 	16K words	64 words 	PC[5:0]   256 		PC[13:6] 13
		     (32K bytes) 
]]
-- Получается - размер одной страницы = 64 слова = 128 байт =
-- = 128*8 бит = 1024 бит = 1 кБайт

local page_size_in_words = 64
local page_size_in_bytes = page_size_in_words*2

--page_count = 7 -- пишем 1 килобайт 

local page_count = (fd_bin:seek("end")/page_size_in_bytes)-1
print("Число страниц = ", page_count+1)

print("Размер файла = ", fd_bin:seek("end")," байт")

--for qty = 0, fd:seek("end")-1, 1 do --кол-во килобайт в файле

    --spi.send(1,0x00)

    for k =0  ,page_count ,1 do--quantity of pages
--    for k =0  ,2 ,1 do--quantity of pages

--print ("node.heap = ", node.heap())

--        print("k = ",k)

        for i=0 , page_size_in_bytes-1, 2 do
--            print("i = ",i)
            address = i/2

fd_bin:seek("set",i+page_size_in_bytes*k)
local character = fd_bin:read(1)
--print("fd:read[",i+page_size_in_bytes*k, "]", qw)
--data = qw:byte(1) 
--data = qw--:byte(1) -- Так не работает!!!
            if character == nil 
            then
                data = 0xff
            else
                data = character:byte(1) 
            end
--print("fd:read[",i+page_size_in_bytes*k, "]", data)
            InstrStorePAGE(0x40,address,data)
--print("InstrStorePAGE(0x40",address,data,")")
            tmr.delay(100)--  otherwise not in time write


fd_bin:seek("set",i+1+page_size_in_bytes*k)
character = fd_bin:read(1)
--print("fd:read[",i+1+page_size_in_bytes*k, "]", qw)
--data = qw:byte(1)
            if character == nil 
            then
                data = 0xff
            else
                data = character:byte(1) 
            end
--print("fd:read[",i+1+page_size_in_bytes*k, "]", data)
            InstrStorePAGE(0x48,address,data)
--print("InstrStorePAGE(0x48",address,data,")")
            tmr.delay(100)

        --tmr.delay(1000)
    end

        
        page_address_low=bit.band(k ,3)*64 -- 3 это двоичное 11
--print("page_address_low = ",page_address_low)
        page_address_high=k/4--+frame1024*2
--print("page_address_high = ",page_address_high)

        InstrWriteFLASH(page_address_low,page_address_high)
--print("InstrWriteFLASH(",page_address_low,page_address_high,")")
print("Записана страница памяти № ",k+1,"\t из ",page_count+1,"\t страниц ")
--[[       
-- Запись идёт по одной странице за раз
-- После записи одной страницы - нужно ждать сигнала RDY/BSY.
-- Если этот сигнал не используется - нужно ждать время  tWD_FLASH
-- перед записью новой страницы.
-- ATMEGA328P_AU.pdf, п. 27.8.2 Serial Programming Algorithm, Table 27-18
-- tWD_FLASH = 4.5 ms
-- tWD_EEPROM = 3.6 ms
-- tWD_ERASE = 9.0 ms
]]
    
collectgarbage()
--tmr.delay(4500)
end

fd_bin:close()
fd_bin = nil
--InstrStorePAGE = nil
--InstrWriteFLASH = nil
collectgarbage()
end
--===========================================================================================================

--###########################################################################################################
function Programming_hex (FlashFile)

    if file.exists(FlashFile) then
        print("Open file: ",FlashFile)
        fd_hex = file.open(FlashFile, "r")
    else
        print("No sketch file!!! : ",FlashFile)
        return
    end

    local _BinFile = "sketch.bin" -- Файл для записи сформированного bin-файла из hex-файла

--[[ ATMEGA328P_AU.pdf, п. 27.5 Page Size:
Device        Flash Size  Page Size   PCWORD  No.of Pages PCPAGE  PCMSB
ATmega48PA  2K words    32 words    PC[4:0]   64        PC[10:5] 10
             (4K bytes) 
ATmega88PA  4K words    32 words    PC[4:0]   128       PC[11:5] 11
             (8K bytes) 
ATmega168PA 8K words    64 words    PC[5:0]   128       PC[12:6] 12
             (16K bytes) 
ATmega328P  16K words   64 words    PC[5:0]   256       PC[13:6] 13
             (32K bytes) 
]]
-- Получается - размер одной страницы = 64 слова = 128 байт = 128*8 бит = 1024 бит = 1 кБайт

    local page_size_in_words = 64
    local page_size_in_bytes = page_size_in_words*2

    local char_count = fd_hex:seek("end")
    print("Число символов в hex-файле = ", char_count)

    fd_hex:seek("set",0)    --Сначала нужно установить курсор, иначе file.readline() не работает

    local row_count = 0
    while (fd_hex:readline() ~= nil) do
        row_count = row_count + 1
    end
    print("Число строк в hex-файле = ", row_count)


    local byte_count = 0
    local position = 0
    local CRC = ""
    local cur_value = 0

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Проверка контрольной суммы @@@@@@@@@@@@@@@@@@@@@@@@@@@@
    print("*********** Старт проверки контрольной суммы CRC ***********")

    fd_hex:seek("set",0)    --Сначала нужно установить курсор, иначе file.readline() не работает
    for q=1, row_count, 1 do
        fd_hex:seek("cur",1)
        local character = "0x"..fd_hex:read(2)
        if (tonumber(character,10) == nil) then
            print("Ошибка данных в файле!!!")
            CRC = "WRONG_CHARACTER"
            break
        end
        cur_value = tonumber(character,10) 
        byte_count = byte_count + cur_value
        fd_hex:seek("cur",-3)   --возвращаем курсор обратно на место (до того, как отбросили первый символ ":"
        position = fd_hex:seek("cur")
        local cur_string = fd_hex:readline()
        fd_hex:seek("set",position+1)
        local crc_val = 0 --Переменная для проверки контрольной суммы в строке
        for w=1,  cur_value+5,1 do  --считываем все байты в строке. 
    -- +5 - это Record Length (1 байт), Address (2 байта), Record Type (1 байт), Checksum (1 байт)
            character = "0x"..fd_hex:read(2)
            if (tonumber(character,10) == nil) then
                print("Ошибка данных в файле!!!")
                CRC = "WRONG_CHARACTER"
                break
            end
            local crc_val = crc_val + tonumber(character,16)
            crc_val = bit.band(crc_val,0xFF)    -- Отбрасываем значения больше 0xFF
        end
        if (crc_val == 0) then
            CRC = "OK"
        elseif (CRC == "") then
            print("CRC NOT OK!!!")
            CRC = "FAIL"
            break
        else    --CRC = WRONG_CHARACTER
            break
        end
        fd_hex:seek("set",position)
        fd_hex:readline()
    end

    print("CRC = "..CRC)
    print("********* Проверка контрольной суммы CRC завершена *********")
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    print("Число байт в hex-файле для прошивки = ", byte_count)

    local page_count = (fd_hex:seek("end")/page_size_in_bytes)-1
    print("Число страниц = ", page_count+1)

    print("Размер файла = ", fd_hex:seek("end")," байт")

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Запись данных в страницу @@@@@@@@@@@@@@@@@@@@@@@@@@@@
    fd_hex:seek("set",0)

    local byte_in_page = 0
    local total_byte_written = 0
    local status = ""
    local address_on_page = 0
    local offset_new = 0
    local offset_prev = 0
    local byte_in_row = 0
    local byte_in_row_prev = 0
    local page_address_low = 0
    local page_address_high = 0
    position = 0    -- Обнуляем переменную для запоминания текущей позиции курсора с файле            

-- Создаём пустой файл в 32кБ
    BlankBinFile (_BinFile)
    BlankBinFile = nil

print("Начинаем записывать данные из hex-файла в bin-файл")
    local wr = file.open(_BinFile, "r+")

    for e = 1, row_count, 1 do
--print("Текущая позиия курсора = "..fd:seek("cur"))
--        position = fd:seek("cur")
--print(file.readline())
--fd:seek("set",position)
        fd_hex:seek("cur",1)
        local data = "0x"..fd_hex:read(2)
        byte_in_row = tonumber(data,10)

-- считываем адрес для записи
        data = "0x"..fd_hex:read(4)
        offset = tonumber(data,10)

-- считываем тип записи:
--[[
'00' Data Record (запись, содержащая данные)
'01' End of File Record (запись, сигнализирующая о конце файла)
'02' Extended Segment Address Record (запись адреса расширенного сегмента)
'03' Start Segment Address Record (запись адреса начала сегмента)
'04' Extended Linear Address Record (запись расширенного линейного адреса)
'05' Start Linear Address Record (запись адреса начала линейного адреса)
]]        
        data = "0x"..fd_hex:read(2)
--        if (data == nil) then break end
--print("data = "..data)
        local Rec_Type = 0
        Rec_Type = tonumber(data,10)
--print("Rec_Type = "..Rec_Type)


        if (Rec_Type == 0) then
            wr:seek("set", offset)
--print("offset 0x"..string.format('%04X', offset))
--print("cursor pos.= 0x"..string.format('%04X', wr:seek("cur")))
            local value = 0
            for a = 1, byte_in_row, 1 do
                data = "0x"..fd_hex:read(2)
                value = tonumber(data,10)
                wr:write(string.char(value))
--print("addr: 0x"..string.format('%04X', wr:seek("cur")).."\tvalue = "..string.format('%02X', value))
            end
        end
            
        local cur_string = fd_hex:readline()  -- Дочитываем строку до конца, 
        -- чтобы переместить курсор на начало следующей строки
        print("Записана строка : "..e.."\tиз "..row_count.." строк")
    end
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

wr:close()
wr = nil

fd_hex:close()
fd_hex = nil

--InstrStorePAGE = nil
--InstrWriteFLASH = nil   
ReadProgramMemoryPAGE = nil 
collectgarbage()

print("\n***************************************")
print("**** Начинаем заливать прошивку... ****\n")
Programming_bin (_BinFile)
print("\n******** Прошивка залита в МК *********")
print("***************************************")

end
--====================================================================================


--###########################################################################################################
function ReadFlash (FlashFile)

if file.exists(FlashFile) then
    print("remove old file: ",FlashFile)
    file.remove(FlashFile)
end

fd = file.open(FlashFile, "a+")

local    word = ""
local    q = 0
local    low_byte = 0
local    high_byte = 0

for i=0, 16383, 1 do -- 16383 = 32768/2-1 - это размер памяти ATmega328P (32 КБайт)


    local low = bit.band(i,0xFF)
    local high = bit.band(bit.rshift(i, 8),0xFF)
    spi.send(1, 0x20,high,low)
    local LSB = (spi.recv( 1, 8))
    spi.send(1,0x00)

    low = bit.band(i,0xFF)
    high = bit.band(bit.rshift(i, 8),0xFF)
    spi.send(1, 0x28,high,low)
    local MSB = spi.recv( 1, 8)
    spi.send(1,0x00)

    word = string.sub(LSB,1,1)..string.sub(MSB,1,1)
    
    file.write(word)
--    print("word [",i,"] = ", word)
print("Считано слово памяти № ",i+1,"\t из 16384 слов ")


collectgarbage()
tmr.delay(500)
end
--    file.flush()
file.close()
fd = nil
end
--===========================================================================================================

--###########################################################################################################
function print_bit(payload)
    local str = ""
    for b=8 , 1 , -1 do
        str = str .. string.format("%d", bit.band(bit.rshift(payload,(b - 1)),1))
        --print(string.format("%d", (bit.rshift(bit.band(payload,b),(b - 1)))))
    end
return str
end
--===========================================================================================================

--###########################################################################################################
--**************************************** Формируем пустой BIN-файл ****************************************
function BlankBinFile (BinFile)

    if file.exists(BinFile) then
        print("remove old file: ",BinFile)
        file.remove(BinFile)
    end

print("------------------------\nСоздаём пустой BIN-файл\n")

    local wr = file.open(BinFile, "a+")

    local char = 0
    local str = ""
    char = string.char(0xFF)

    for k = 1, 128, 1 do
        str = str..char
    end
    
    wr:seek("set",0)

    for i=1, 256, 1 do -- 256*128=32768 - это размер памяти ATmega328P (32 КБайт)
        wr:write(str)
    end

    wr:close()
print("Формирование пустого BIN-файла в 32кБ завершено\n------------------------\n")
    wr = nil
    collectgarbage()
end
--===========================================================================================================

