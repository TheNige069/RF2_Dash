local M = {

    options = {
        {"rxbatNum"			, CHOICE, 2, {"1-1s Lipo (4.2v)", "2-2s Lipo (8.4v)", "3-3s Lipo (12.6v)"} },
        {"textColorTitle"	, COLOR	, lcd.RGB(0xC0C4C0) }, --LIGHTGREY
        {"textColor"		, COLOR	, WHITE },
        {"FlightTimer"		, CHOICE, 1 , {"1-Timer 1", "2-Timer 2", "3-Timer 3"} },
		{"TXBatterySensor"	, SOURCE, 267},
    },

    translate = function(name)
        local translations = {
			rxbatNum = "RX battery max voltage",
            textColor = "Text color",
			textColorTitle = "Title text color",
			FlightTimer = "What timer to display", 
			TXBatterySensor = "Radio Transmitter battery",
        }
        return translations[name]
    end
}

return M
