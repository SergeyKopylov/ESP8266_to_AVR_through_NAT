function Program_Flash (sketch)
    tmr.wdclr()
    
    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8,320,spi.FULLDUPLEX)
    
    require("program_load")
    collectgarbage()
    
    ProgrammingEnable ()
    --tmr.delay(1000)
    if InstrProgrammingEnable () == 1 then
    
        InstrFlashErase()
        tmr.delay(1000)

        local str = ""
        str = string.sub(sketch,-3)
        if (str == "hex") then
            print("Прошивка HEX-файла")
            Programming_hex (sketch)
--[[        elseif (str == "bin") then
            print("Прошивка BIN-файла")
            Programming_bin (sketch)]]
        else
--            print("Неизвестный формат файла прошивки")
            print("Прошивка BIN-файла")
            Programming_bin (sketch)
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
