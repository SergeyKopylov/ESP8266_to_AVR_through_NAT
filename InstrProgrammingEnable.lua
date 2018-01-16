tmr.wdclr()

spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8,320,spi.FULLDUPLEX)

httpDL = require("program_load")
collectgarbage()

--ProgrammingEnable ()
--tmr.delay(1000)
--InstrProgrammingEnable ()

Programming ("sketch.bin")

program_load = nil
package.loaded["program_load"]=nil
collectgarbage()