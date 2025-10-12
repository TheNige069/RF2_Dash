local M = {

    options = {
        {"showTotalVoltage"	, BOOL	, 1      }, -- 0=Show as average Lipo cell level, 1=show the total voltage (voltage as is)
        {"rxbatNum"			, CHOICE, 2, {"1-1s Lipo (4.2v)", "2-2s Lipo (8.4v)", "3-3s Lipo (12.6v)"} },
--        {"rxbatMax"			, VALUE	, 8, 1, 12 },
--        {"rxbatMax2"		, SLIDER , 8.4, 0.1, 1, 12 },
        {"guiStyle"			, CHOICE, 2 , {"1-Electric", "2-Nitro"} },
        {"textColorTitle"	, COLOR	, lcd.RGB(0xC0C4C0) }, --LIGHTGREY
        {"textColor"		, COLOR	, WHITE },
        {"FlightTimer"		, CHOICE, 1 , {"1-Timer 1", "2-Timer 2", "3-Timer 3"} },
		{"TXBatterySensor"	, SOURCE, 267},
        {"tempTop"      	, VALUE ,  90 , 30,150 },
        {"currTop"      , VALUE , 150 , 40,300 },
    },

    translate = function(name)
        local translations = {
            showTotalVoltage = "Show total voltage",
			rxbatNum = "RX battery max voltage",
--			rxbatMax2 = "RX battery max voltage2",
            guiStyle = "GUI style Electric or Nitro specific",
            textColor = "Text color",
			textColorTitle = "Title text color",
			FlightTimer = "What timer to display", 
			TXBatterySensor = "Radio Transmitter battery",
            tempTop="Max ESC Temp",
            currTop="Max Current",
        }
        return translations[name]
    end
}

return M
