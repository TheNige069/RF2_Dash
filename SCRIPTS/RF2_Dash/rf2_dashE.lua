local app_name = "rf2_dashE"
local script_dir = "/SCRIPTS/RF2_Dash/"
local baseDir = "/WIDGETS/rf2_dashE/"

local wgt = {}

local function loadFuncs()
	if not rf2DashFuncs then
		rf2DashFuncs = loadScript(script_dir .. "rf2_dashFunc.lua")
	end
	return rf2DashFuncs()
end
local rf2DashFuncs = loadFuncs()

local img_box = nil
local err_img = bitmap.open(script_dir.."img/no_connection_wr.png")

local function build_ui_electric(wgt)
    local txtColor = wgt.options.textColor
    local titleGreyColor = LIGHTGREY
    local dx = 20

    lvgl.clear()

    -- global
    lvgl.rectangle({x = 0, y = 0, w = LCD_W, h = LCD_H, color = lcd.RGB(0x111111), filled = true})
    local pMain = lvgl.box({x = 0, y = 0})

	-- Model image
    local bImageArea = pMain:box({x = 325, y = 5})
	img_box = bImageArea:rectangle({x = 0, y = 0, w = rf2DashFuncs.isizew, h = rf2DashFuncs.isizeh, thickness = 4, rounded = 15, filled = false, color = GREY})
	
    -- Craft name
    local bCraftName = pMain:box({x = 325, y = 80})
    bCraftName:rectangle({x = 10, y = 20, w = rf2DashFuncs.isizew - 20, h = 20, filled = true, rounded = 8, color = DARKGREY, opacity = 200})
    bCraftName:label({text = function() return wgt.values.craft_name end,  x = 15, y = 20, font = FS.FONT_8, color = wgt.options.textColor})

    display_NoConnection(wgt, 325, 10)

	local boxSize = ({x = 0, y = 0, h = 180, w = 180})
    local g_thick = 20
    local gm_thick = 10
    local g_angle_min = 140
    local g_angle_max = 400
	local centre_x = (boxSize.w / 2) - g_thick --+ boxSize.x
	local centre_y = (boxSize.h / 2) - gm_thick --+ boxSize.y
    local g_rad = math.min((boxSize.w / 2), (boxSize.h / 2)) - g_thick - 2
    local gm_rad =  g_rad - g_thick --+ (g_thick / 2)
	
    --local bCurr = pMain:box({x = boxSize.x, y = boxSize.y})
    local bCurr = lvgl.box({x = boxSize.x, y = boxSize.y})

    bCurr:label({text = "Current",  x = 0, y = 0, font = FS.FONT_6, color = LIGHTGREY})
    -- Current value
	bCurr:label({x = centre_x - g_thick, y = (boxSize.h / 2) - g_thick, text = function() return wgt.values.curr_str end, font = FS.FONT_8, color = wgt.options.textColor})
    -- Max current value
	bCurr:label({x = centre_x - g_thick, y = centre_y + 30, text = function() return wgt.values.curr_max_str end, font = FS.FONT_8, color = wgt.options.textColor})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = g_angle_max, rounded = true, color = lcd.RGB(0x222222)})
    bCurr:arc({x = centre_x, y = centre_y, radius = gm_rad, thickness = gm_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.curr_max_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0xFF623F), opacity = 180})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.curr_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0xFF623F)})
	
	boxSize = ({x = 170, y = 0, h = 180, w = 180})
	centre_x = (boxSize.w / 2) - g_thick --+ boxSize.x
	centre_y = (boxSize.h / 2) - gm_thick --+ boxSize.y

    g_rad = math.min((boxSize.w / 2), (boxSize.h / 2)) - g_thick - 2
    gm_rad =  g_rad - g_thick --+ (g_thick / 2)
	
    --local bCapa = pMain:box({x = boxSize.x, y = boxSize.y})
    local bCapa = lvgl.box({x = boxSize.x, y = boxSize.y})

    bCapa:label({text = "MA Used",  x = 0, y = 0, font = FS.FONT_6, color = LIGHTGREY})
    -- Capacity percentage left
	bCapa:label({x = centre_x - g_thick, y = (boxSize.h / 2) - (2 * g_thick), text = function() return wgt.values.capa_percent.."%" end, font = FS.FONT_8, color = wgt.options.textColor})
    -- Capacity used 
	bCapa:label({x = centre_x - g_thick-10, y = (boxSize.h / 2) - g_thick, text = function() return wgt.values.capa_str end, font = FS.FONT_8, color = wgt.options.textColor})
    -- Max Capacity
	bCapa:label({x = centre_x - g_thick-7, y = centre_y + 30, text = function() return wgt.values.capa_max_str end, font = FS.FONT_8, color = wgt.options.textColor})
    bCapa:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = g_angle_max, rounded = true, color = lcd.RGB(0x222222)})
    bCapa:arc({x = centre_x, y = centre_y, radius = gm_rad, thickness = gm_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.capa_max_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0x62FF3F), opacity = 180})
    bCapa:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.capa_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0x62FF3F)})

    -- rpm
    lvgl.build({{type = "box", x = 10, y = 140,
        children = {
            {type = "label", text = "RPM", x = 0, y = 0, font = FS.FONT_6, color = LIGHTGREY},
            {type = "label", text = function() return wgt.values.rpm_str end, x = 0, y = 10, font = FS.FONT_16, color = wgt.options.textColor},
        }
    }})
	
	display_BatteryVoltage(wgt, pMain, 200, 140)
		
	display_GovernorState(wgt, pMain, 325, 140)

	display_ArmState(wgt, pMain, 160, 200)
	
	display_RXVoltage(wgt, pMain, 0, 205, false)
	
	displayRatePIDprofile(wgt, pMain, 90, 205)
	display_timer(wgt, pMain, 310, 190)

	build_statusbar(wgt, 0, wgt.zone.h - 20, 0)
	build_FailToArmFlags(wgt, pMain, 100, 25)

end

-- To display the current time on the dashboard
-- This is the local time as set in the transmitter, not the time from any of the timers
local function updateCurrentTime(wgt)
	local theDateTime = getDateTime()
	
	wgt.values.timeCurrent = string.format("%02d:%02d TheNige069", theDateTime.hour, theDateTime.min)
	
end

local function updateCraftName(wgt)
	wgt.values.craft_name = string.gsub(model.getInfo().name, "^>", "")	
end

local function updateTimeCount(wgt)
	if wgt.options.FlightTimer < 0 then 
		wgt.options.FlightTimer = 1
	end
	
	local timerNumber = wgt.options.FlightTimer - 1

	if timerNumber < 0 then 
		return
	end
	
    local t1 = model.getTimer(timerNumber)
    local time_str, isNegative = formatTime(t1, wgt.options.use_days)
	
    wgt.values.timer_str = time_str
    wgt.values.timerIsNeg = isNegative
end

local function updateRpm(wgt)
    local Hspd = getValue("Hspd")
	
    if inSimu then Hspd = 1800 end
	
    wgt.values.rpm = Hspd
    wgt.values.rpm_str = string.format("%s",Hspd)
end

local function updateCell(wgt)
    local vbat = getValue("Vbat")

    if inSimu then
        vbat = 22.2
    end

    wgt.values.vbat = vbat
end

local function updateFlightMode(wgt)
    local fmno, fmname = getFlightMode()

    wgt.values.fmode = fmno
    wgt.values.fmode_str = fmname
end

-- Current PID profile
local function updateProfiles(wgt)
    local profile_id = getValue("PID#")
	
    if profile_id > 0 then
        wgt.values.profile_id = profile_id
    else
        wgt.values.profile_id = "---"
    end
    wgt.values.profile_id_str = string.format("%s", wgt.values.profile_id)

    -- Current Rate profile
    local rate_id = getValue("RTE#")
    if rate_id > 0 then
        wgt.values.rate_id = rate_id
    else
        wgt.values.rate_id = "---"
    end
    wgt.values.rate_id_str = string.format("%s", wgt.values.rate_id)
end

local function updateCurr(wgt)
    local curr_top = wgt.options.currTop
    local curr = getValue("Curr")
    local curr_max = getValue("Curr+")
	curr_max = math.max(curr_max, curr)

    if inSimu then
        curr = 205
        curr_max = 255
    end
	
    wgt.values.curr = curr
    wgt.values.curr_max = curr_max
    wgt.values.curr_percent = math.min(100, math.floor(100 * (curr / curr_top)))
    wgt.values.curr_max_percent = math.min(100, math.floor(100 * (curr_max / curr_top)))
    wgt.values.curr_str = string.format("%dA", wgt.values.curr)
    --wgt.values.curr_max_str = string.format("+%dA", wgt.values.curr_max)
    wgt.values.curr_max_str = string.format("%dA", wgt.values.curr_max)
end

function isArmed()
    local flags = getValue("ARM")
    if flags == nil then
        return false
    end

    local armFlag = bit32.band(flags, 0x01)
    return armFlag == 1
end

local function updateArm(wgt)
    wgt.values.is_arm = isArmed()
	local flags = getValue("ARMD")

    local flagList = armingDisableFlagsList(flags)
	
    wgt.values.arm_disable_flags_list = flagList
    wgt.values.arm_disable_flags_txt = ""
    wgt.values.arm_fail = false

    if flagList ~= nil then
        if (#flagList == 0) then
            wgt.values.arm_fail = false
        else
            wgt.values.arm_fail = true
            for i in pairs(flagList) do
                wgt.values.arm_disable_flags_txt = wgt.values.arm_disable_flags_txt .. flagList[i] .. "\n"
            end
        end
    end
end

local function updateThr(wgt)
    wgt.values.thr = getValue("Thr")
    wgt.values.thr_max = getValue("Thr+")

    if inSimu then
        wgt.values.thr = 82
        wgt.values.thr_max = 96
    end
end

local function updateELRS(wgt)
    wgt.values.rqly = getValue("RQly")
    local rqly_min = getValue("RQly-")
    if rqly_min > 0 then
        wgt.values.rqly_min = rqly_min
    end
    wgt.values.rqly_str = string.format("%d%%", wgt.values.rqly)
    wgt.values.rqly_min_str = string.format("%d%%", wgt.values.rqly_min)
end

local function updateTemperature(wgt)
    local tempTop = wgt.options.tempTop

    wgt.values.EscT = getValue("EscT")
    wgt.values.EscT_max = getValue("EscT+")

    if inSimu then
        wgt.values.EscT = 60
        wgt.values.EscT_max = 75
    end
    wgt.values.EscT_str = string.format("%d°c", wgt.values.EscT)
    wgt.values.EscT_max_str = string.format("+%d°c", wgt.values.EscT_max)

    wgt.values.EscT_percent = math.min(100, math.floor(100 * (wgt.values.EscT / tempTop)))
    wgt.values.EscT_max_percent = math.min(100, math.floor(100 * (wgt.values.EscT_max / tempTop)))
end

-- RX battery or BEC voltage
local function updateVbec(wgt)
	wgt.values.vBecUsed = getValue("Vbec")
	
    if inSimu then 
		wgt.values.vBecUsed = getValue("RxBt")
	end

	if wgt.values.vBecMax < 1 then
		wgt.values.vBecMax = 8.4
	end
	if wgt.values.vBecMin < 1 then
		wgt.values.vBecMin = 7.4
	end
	
    if wgt.values.vBecUsed == nil or wgt.values.vBecUsed == nan or wgt.values.vBecUsed < 0 then
        wgt.values.vBecUsed = 8.4
    end
	
    wgt.values.vBecPercent = math.floor(100 - (100 * (wgt.values.vBecMax - wgt.values.vBecUsed) // (wgt.values.vBecMax - wgt.values.vBecMin)))
	
	if wgt.values.vBecPercent > 100 then wgt.values.vBecPercent = 100 end
	
    local p = wgt.values.vBecPercent
    if (p < 10) then
        wgt.values.vBecColor = RED
    elseif (p < 40) then
        wgt.values.vBecColor = ORANGE
    elseif (p < 60) then
        wgt.values.vBecColor = lcd.RGB(0x00963A) --GREEN
    else
        wgt.values.vBecColor = GREEN
    end

    wgt.values.vBecPercent_txt = string.format("%d%%", wgt.values.vBecPercent)
end

-- Transmitter battery voltage
local function updateTXBatVoltage(wgt)
	--wgt.values.vTXVolts = getValue(267)	-- This is the "Batt" sensor
	wgt.values.vTXVolts = getValue(wgt.options.TXBatterySensor)

	wgt.values.vTXVoltsMax = getGeneralSettings().battMax
	wgt.values.vTXVoltsMin = getGeneralSettings().battMin 
	wgt.values.vTXVoltsWarn = getGeneralSettings().battWarn 

	local warnPercent = math.ceil(100 - (100 * (wgt.values.vTXVoltsMax - wgt.values.vTXVoltsWarn) // (wgt.values.vTXVoltsMax - wgt.values.vTXVoltsMin)))

    wgt.values.vTXVoltsPercent = math.floor(100 - (100 * (wgt.values.vTXVoltsMax - wgt.values.vTXVolts) // (wgt.values.vTXVoltsMax - wgt.values.vTXVoltsMin)))
	
	if wgt.values.vTXVoltsPercent > 100 then wgt.values.vTXVoltsPercent = 100 end
	
    local p = wgt.values.vTXVoltsPercent
    if (p < warnPercent) then
        wgt.values.vTXVoltsColor = RED
    elseif (p < 40) then
        wgt.values.vTXVoltsColor = ORANGE
    elseif (p < 60) then
        wgt.values.vTXVoltsColor = lcd.RGB(0x00963A) --GREEN
    else
        wgt.values.vTXVoltsColor = GREEN
    end

    wgt.values.vTXVoltsPercent_txt = string.format("%d%%", wgt.values.vTXVoltsPercent)
end

local function updateImage(wgt)
    local newCraftName = wgt.values.craft_name
	
    if newCraftName == wgt.values.img_craft_name_for_image then
        return
    end

    local imageName = script_dir .. "/img/" .. newCraftName..".png"

    if isFileExist(imageName) == false then
        imageName = "/IMAGES/" .. model.getInfo().bitmap

        if imageName == "" or isFileExist(imageName) == false then
            imageName = script_dir.."img/rf2_logo.png"
        end
    end

    if imageName ~= wgt.values.img_last_name then
        img_box:clear()
		img_box:image({file = imageName, x = 0, y = 0, w = rf2DashFuncs.isizew, h = rf2DashFuncs.isizeh, fill = false})

        wgt.values.img_last_name = imageName
        wgt.values.img_craft_name_for_image = newCraftName
    end
end

local function resetWidgetValues(wgt)
    wgt.values = {
        craft_name = "Not connected",
        timer_str = "--:--",
		timerIsNeg = false,
        rpm = 0,
        rpm_str = "0",

        vbat = 0,
        --vcel = 0,
        cell_percent = 0,
        volt = 0,
        curr = 0,
        curr_max = 0,
        curr_str = "0",
		curr_max_str = "0",
        curr_percent = 0,
        curr_max_percent = 0,

		capa = 0,
		capa_max = 0,
		capa_percent = 0,
		capa_max_percent = 0,
		capa_str = "0",
		capa_max_str = "0",

        EscT = 0,
        EscT_max = 0,
        EscT_str = "0",
        EscT_max_str = "0",
        EscT_percent = 0,
        EscT_max_percent = 0,

        img_last_name = "---",
        img_craft_name_for_image = "---",
		
		profile_id_str = "--",
		rate_id_str = "--",
		
        rqly = 0,
        rqly_min = 0,
        rqly_str = 0,
        rqly_min_str = 0,

        thr = 0,
        thr_max = 0,

		fmode = 0,
		fmode_str = "----",
		
        vBecMax = 8.4,
		vBecMin = 7 ,
        vBecUsed = 0,
        vBecPercent = 0,
        vBecPercent_txt = "---%%",
		vBecColor = RED,
		
		vTXVolts = 0,
		vTXVoltsMax = -1, --8.4,
		vTXVoltsMin = -1, --6.6,
		vTXVoltsWarn = -1, --7.0,
		vTXVoltsPercent = 0,
		vTXVoltsColor = RED,
		vTXVoltsPercent_txt = "---%%",
		
		--click_x = 0,
		--click_y = 0,
		--textTouch = "---",
		timeCurrent = "TheNige: --:--",
		
		govState = 0, 
		govState_str = "---",
    }
end

local function refreshUINoConn(wgt)
	updateCurrentTime(wgt)
	updateTXBatVoltage(wgt)
end

local function refreshUI(wgt)
    updateCraftName(wgt)
    updateImage(wgt)
    updateTimeCount(wgt)
    updateRpm(wgt)
    updateCell(wgt)
    updateCurr(wgt)
	updateMAUsed(wgt)
	updateGovState(wgt)
    updateProfiles(wgt)
	updateFlightMode(wgt)
	updateELRS(wgt)
    updateArm(wgt)
    updateThr(wgt)
	updateVbec(wgt)

    updateTemperature(wgt)
	
	refreshUINoConn(wgt)
end

---------------------------------------------------------------------------------------

local function update(wgt, options)
    if (wgt == nil) then return end
    wgt.options = options
    wgt.not_connected_error = "Not connected"

    resetWidgetValues(wgt)

--    if wgt.options.rxbatNumCells == nil or wgt.options.rxbatNumCells == nan or wgt.options.rxbatNumCells < 0 then
--		wgt.options.rxbatNumCells = 2
--	end
	
--	if wgt.options.rxbatNumCells > 0 then
--		wgt.values.vBecMax = wgt.options.rxbatNumCells * 4.2
--		wgt.values.vBecMin = wgt.options.rxbatNumCells * 3.5
--	end
	
    build_ui_electric(wgt)
	
    return wgt
end

local function create(zone, options)
    wgt.zone = zone
    wgt.options = options
    return update(wgt, options)
end

local function background(wgt)
end

local function refresh(wgt, event, touchState)
    if (wgt == nil) then return end

    wgt.is_connected = (getRSSI() > 0)
    -- wgt.not_connected_error = "Not connected"

    if wgt.is_connected == false then
        resetWidgetValues(wgt)
		-- Refresh items that don't rely on being connected
		refreshUINoConn(wgt)
        return
    end
	
    refreshUI(wgt)
end

return {create=create, update=update, background=background, refresh=refresh}