local M = {

    options = {
        {"textColorTitle"	    , COLOR	, lcd.RGB(0xC0C4C0) }, --LIGHTGREY
        {"textColor"	    	, COLOR	, WHITE },
        {"FlightTimer"		    , CHOICE, 1 , {"1-Timer 1", "2-Timer 2", "3-Timer 3"} },
        {"tempTop"      	    , VALUE ,  90, 30, 150 },
        {"currTop"              , VALUE , 250, 40, 300 },
        {"BattCapa"             , VALUE , 5000, 0, 10000 },
        {"BattCapMin"           , VALUE , 30, 0, 100 },
		{"BatteryCallout"	    , VALUE , 10, 10, 50},
		{"FlightBattery"	    , SOURCE, 267},
		{"FlightBatteryCap" 	, SOURCE, 267},
		{"FlightBatteryVolt"	, SOURCE, 267},
    },

    translate = function(name)
        local translations = {
            textColor = "Text color",
			textColorTitle = "Title text color",
			FlightTimer = "What timer to display", 
            tempTop = "Max ESC Temp",
            currTop = "Max Current",
			BattCapa = "Battery Capacity",
			BattCapMin = "Battery Capacity min %",
			BatteryCallout = "How often to callout battery %",
            FlightBattery = "Main flight battery source",
			FlightBatteryCap = "Battery Capacity source",
			FlightBatteryVolt = "Battery Voltage source",
        }
        return translations[name]
    end
}

return M
