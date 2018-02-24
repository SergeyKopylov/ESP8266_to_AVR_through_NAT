function Program_Flash (ext)
local back --callback для сообщений debug на сервер

    tmr.wdclr()
    
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8,320,spi.FULLDUPLEX)
    
    require("program_load")
    collectgarbage()
    
    ProgrammingEnable ()

    if InstrProgrammingEnable () == 1 then
    
        InstrFlashErase()
        tmr.delay(1000)

        if (ext == "hex") then
            print("Прошивка HEX-файла")
            Programming_hex ("sketch_download")
        elseif (ext == "bin") then
            print("Прошивка BIN-файла")
            Programming_bin ("sketch_download")
        else
            print("Неизвестное расширение прошивки!")
        end
    
    else
        print("\tNo connection!!! Stop reading\n")
    end
    
    ProgrammingDisable ()
    
    program_load = nil
    package.loaded["program_load"]=nil
    
    InstrProgrammingEnable = nil
    ProgrammingDisable = nil
    ProgrammingEnable = nil
    InstrFlashErase = nil
    InstrStorePAGE = nil
    InstrWriteFLASH = nil
    Programming_bin = nil
    ReadFlash = nil
    print_bit = nil
    Programming_hex = nil
    ReadProgramMemoryPAGE = nil
    BlankBinFile = nil
    collectgarbage()
end
