local rf2DashFuncs = {}
local script_dir = "/SCRIPTS/RF2_Dash/"

FS = {FONT_38 = XXLSIZE, FONT_16 = DBLSIZE, FONT_12 = MIDSIZE, FONT_8 = 0, FONT_6 = SMLSIZE}
inSimu = string.sub(select(2,getVersion()), -4) == "simu"

rf2DashFuncs.isizew = 150
rf2DashFuncs.isizeh = 120

function formatTime(t1, useDays)
    --log("rf2_dash: formatTime")
    local dd_raw = t1.value
    local isNegative = false
    if dd_raw < 0 then
      isNegative = true
      dd_raw = math.abs(dd_raw)
    end

    local dd = math.floor(dd_raw / 86400)
    dd_raw = dd_raw - dd * 86400
    local hh = math.floor(dd_raw / 3600)
    dd_raw = dd_raw - hh * 3600
    local mm = math.floor(dd_raw / 60)
    dd_raw = dd_raw - mm * 60
    local ss = math.floor(dd_raw)

    local time_str
    if dd == 0 and hh == 0 then
      -- less then 1 hour, 59:59
      time_str = string.format("%02d:%02d", mm, ss)

    elseif dd == 0 then
      -- lass then 24 hours, 23:59:59
      time_str = string.format("%02d:%02d:%02d", hh, mm, ss)
    else
      -- more than 24 hours
      if wgt.options.use_days == 0 then
        -- 25:59:59
        time_str = string.format("%02d:%02d:%02d", dd * 24 + hh, mm, ss)
      else
        -- 5d 23:59:59
        time_str = string.format("%dd %02d:%02d:%02d", dd, hh, mm, ss)
      end
    end
    if isNegative then
      time_str = '-' .. time_str
    end
    return time_str, isNegative
end

function armingDisableFlagsList(flags)
    --local flags = getValue("ARMD")
    local result = {}
    local t = ""

    if flags == nil then
        return nil
    end

    for i = 0, 25 do
        if bit32.band(flags, bit32.lshift(1, i)) ~= 0 then
            if i == 0 then table.insert(result, "No Gyro") end
            if i == 1 then table.insert(result, "Failsafe is active") end
            if i == 2 then table.insert(result, "No valid receiver signal is detected") end
            if i == 3 then table.insert(result, "The FAILSAFE switch was activated") end
            if i == 4 then table.insert(result, "Box Fail Safe") end
            if i == 5 then table.insert(result, "Governor") end
            --if i == 6 then table.insert(result, "Crash Detected") end
            if i == 7 then table.insert(result, "Throttle not idle") end

            if i == 8 then table.insert(result, "Craft is not level enough") end
            if i == 9 then table.insert(result, "Arming too soon after power on") end
            if i == 10 then table.insert(result, "No Pre Arm") end
            if i == 11 then table.insert(result, "System load is too high") end
            if i == 12 then table.insert(result, "Calibrating") end
            if i == 13 then table.insert(result, "CLI is active") end
            if i == 14 then table.insert(result, "CMS Menu") end
            if i == 15 then table.insert(result, "BST") end

            if i == 16 then table.insert(result, "MSP connection is active") end
            if i == 17 then table.insert(result, "Paralyze mode activate") end
            if i == 18 then table.insert(result, "GPS") end
            if i == 19 then table.insert(result, "Resc") end
            if i == 20 then table.insert(result, "RPM Filter") end
            if i == 21 then table.insert(result, "Reboot Required") end
            if i == 22 then table.insert(result, "DSHOT Bitbang") end
            if i == 23 then table.insert(result, "Accelerometer calibration required") end
			
            if i == 24 then table.insert(result, "ESC/Motor Protocol not configured") end
            if i == 25 then table.insert(result, "Arm Switch") end
        end
    end
    return result
end

function buildBarGuage(parentBox, wgt, myValues, fPercent, getPercentColor)
    local percent = fPercent(wgt)
    local r = 30
    local fill_color = myValues.bar_color or GREEN
    local fill_color= (getPercentColor~=nil) and getPercentColor(wgt, percent) or GREEN
    local tw = 4
    local th = 4

    local box = parentBox:box({x=myValues.x, y=myValues.y})
    box:rectangle({x=0, y=0, w=myValues.w, h=myValues.h, color=myValues.bg_color, filled=true, rounded=6, thickness=8})
    box:rectangle({x=0, y=0, w=myValues.w, h=myValues.h, color=WHITE, filled=false, thickness=myValues.fence_thickness or 3, rounded=8})
    box:rectangle({x=5, y=5,
        -- w=0, h=myValues.h,
        filled=true, rounded=4,
        size =function() return math.floor(fPercent(wgt) / 100 * myValues.w)-10, myValues.h-10 end,
        color=function() return getPercentColor(wgt, percent) or GREEN end,
    })

    return box
end

function log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
    return
end

function updateGovState(wgt)
    local govState = getValue("Gov")
	local govStateTxt = ""

    if inSimu then govState = 8 end
	
	if  govState == 0 then
		govStateTxt = "Throttle off"	-- GOV_STATE_THROTTLE_OFF
	elseif govState == 1 then
    	govStateTxt = "Throttle Idle"	-- GOV_STATE_THROTTLE_IDLE
	elseif govState == 2 then
    	govStateTxt = "Spooling up"		-- GOV_STATE_SPOOLUP
	elseif govState == 3 then
    	govStateTxt = "Recovery"		-- GOV_STATE_RECOVERY
	elseif govState == 4 then
    	govStateTxt = "Gov. Active"		-- GOV_STATE_ACTIVE
	elseif govState == 5 then
    	govStateTxt = "Throttle Hold"	-- GOV_STATE_THROTTLE_HOLD
	elseif govState == 6 then
    	govStateTxt = "Gov. Fallback"	-- GOV_STATE_FALLBACK
	elseif govState == 7 then
    	govStateTxt = "Autorotation"	-- GOV_STATE_AUTOROTATION
	elseif govState == 8 then
    	govStateTxt = "Bailing Out"		-- GOV_STATE_BAILOUT
	else --if govState == 9
    	govStateTxt = "Gov. Disabled"	-- GOV_STATE_DISABLED
	end
	
    wgt.values.govState = govState
    wgt.values.govState_str = govStateTxt
end

function calEndAngle(percent, minAngle, maxAngle)
	if percent == nil then return 0 end
	local v = ((percent / 100) * (maxAngle - minAngle)) + minAngle
	return v
end

function isFileExist(file_name)
    local hFile = io.open(file_name, "r")
    if hFile == nil then
        log("rf2_dash: isFileExist: file not exist - %s", file_name)
        return false
    end
    io.close(hFile)
    return true
end

function display_CurrentGauge(wgt, theBox, boxSize)
    local g_thick = 20
    local gm_thick = 10
    local g_angle_min = 140
    local g_angle_max = 400
    local centre_x = (boxSize.w / 2) - g_thick --+ boxSize.x
    local centre_y = (boxSize.h / 2) - gm_thick --+ boxSize.y
    local g_rad = math.min((boxSize.w / 2), (boxSize.h / 2)) - g_thick - 2
    local gm_rad =  g_rad - g_thick --+ (g_thick / 2)

    local bCurr = theBox:box({x = boxSize.x, y = boxSize.y})

    bCurr:label({text = "Current",  x = 0, y = 0, font = FS.FONT_6, color = LIGHTGREY})
    -- Current value
    bCurr:label({x = centre_x - g_thick, y = (boxSize.h / 2) - g_thick, text = function() return wgt.values.curr_str end, font = FS.FONT_8, color = wgt.options.textColor})
    -- Max current value
    bCurr:label({x = centre_x - g_thick, y = centre_y + 20, text = function() return wgt.values.curr_max_str end, font = FS.FONT_8, color = wgt.options.textColor})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = g_angle_max, rounded = true, color = lcd.RGB(0x222222)})
    bCurr:arc({x = centre_x, y = centre_y, radius = gm_rad, thickness = gm_thick, startAngle = g_angle_min, endAngle = function() return rf2DashFuncs.calEndAngle(wgt.values.curr_max_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0xFF623F), opacity = 180})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = function() return rf2DashFuncs.calEndAngle(wgt.values.curr_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0xFF623F)})
end

function display_MAHUsedGauge(wgt, theBox, boxSize)
    local g_thick = 20
    local gm_thick = 10
    local g_angle_min = 140
    local g_angle_max = 400

    local centre_x = (boxSize.w / 2) - g_thick --+ boxSize.x
    local centre_y = (boxSize.h / 2) - gm_thick --+ boxSize.y

    local g_rad = math.min((boxSize.w / 2), (boxSize.h / 2)) - g_thick - 2
    local gm_rad =  g_rad - g_thick --+ (g_thick / 2)
    --local g_y = boxSize.y --+ 50
	
    local bCurr = theBox:box({x = boxSize.x, y = boxSize.y})
    --local bCurr = lvgl.box({x = boxSize.x, y = boxSize.y})

    bCurr:label({text = "MA Used",  x = 0, y = 0, font = FS.FONT_6, color = LIGHTGREY})
    -- Current value
    bCurr:label({x = centre_x - g_thick, y = (boxSize.h / 2) - g_thick, text = function() return wgt.values.curr_str end, font = FS.FONT_8, color = wgt.options.textColor})
    -- Max current value
    bCurr:label({x = centre_x - g_thick, y = centre_y + 20, text = function() return wgt.values.curr_max_str end, font = FS.FONT_8, color = wgt.options.textColor})
	
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = g_angle_max, rounded = true, color = lcd.RGB(0x222222)})
    bCurr:arc({x = centre_x, y = centre_y, radius = gm_rad, thickness = gm_thick, startAngle = g_angle_min, endAngle = function() return rf2DashFuncs.calEndAngle(wgt.values.curr_max_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0x62FF3F), opacity = 180})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = function() return rf2DashFuncs.calEndAngle(wgt.values.curr_percent, g_angle_min, g_angle_max) end, color = lcd.RGB(0x62FF3F)})

end

function displayRatePIDprofile(wgt, theBox, lx, ly)
    --if (lvgl == nil) then log("refresh(nil)") return end
    --local pMain = lvgl.box({x=0, y=0})

    profileID = wgt.values.profile_id_str
    rateID = wgt.values.rate_id_str
    if inSimu then 
        profileID = 3 
        rateID = 4 
    end

    -- pid profile (bank)
    theBox:build({{type = "box", x = lx, y = ly,
        children = {
            -- {type = "rectangle", x = 0, y = 0, w = 40, h = 50, color = YELLOW},
            {type = "label", text = "Profile", x = 0, y = 0, font = FS.FONT_6, color = wgt.options.textColorTitle},
            {type = "label", text = profileID , x = 5, y = 10, font = FS.FONT_16, color = wgt.options.textColor},
        }
    }})

    -- rate profile
    theBox:build({{type = "box", x = lx + 46, y = ly,
        children = {
            -- {type = "rectangle", x = 0, y = 0, w = 40, h = 50, color = YELLOW},
            {type = "label", text = "Rate", x = 0, y = 0, font = FS.FONT_6, color = wgt.options.textColorTitle},
            {type = "label", text = rateID , x = 5, y = 10, font = FS.FONT_16, color = wgt.options.textColor},
        }
    }})
end

function display_GovernorState(wgt, theBox, lx, ly)
    local bGS = theBox:box({x = lx, y = ly})
    bGS:label({text = "Governor State", x = 0, y = 0, font = FS.FONT_6, color = wgt.options.textColorTitle})
    bGS:label({text = function() return wgt.values.govState_str end , x = 0, y = 20, font = FS.FONT_8 ,color = wgt.options.textColor})
end

function build_statusbar(wgt, lx, ly, txBatBar)
	if (lvgl == nil) then log("refresh(nil)") return end
    local bStatusBar = lvgl.box({x = lx, y = ly})
	
    local statusBarColor = lcd.RGB(0x0078D4)
    bStatusBar:rectangle({x = 0, y = 0, w = wgt.zone.w, h = 20, color = statusBarColor, filled = true})
	bStatusBar:rectangle({x = 25, y = 0, w = 70, h = 20, color = RED, filled = true, visible = function() return (wgt.values.rqly_min < 80) end })
    --bStatusBar:label({x = 3, y = 2, text = function() return string.format("elrs RQly-: %s%%", wgt.values.rqly_min) end, font = function() return (wgt.values.rqly_min >=  80) and FS.FONT_6 or FS.FONT_6 end, color=WHITE})
    bStatusBar:label({x = 2  , y = 2, text = function() return string.format("elrs RQly-: %s%%", wgt.values.rqly_min) end, font = FS.FONT_6, color = WHITE})
    bStatusBar:label({x = 140, y = 2, text = function() return string.format("TPwr+: %smw", getValue("TPWR+")) end, font = FS.FONT_6, color = WHITE})
	if (txBatBar == 1) then
		buildBarGuage(bStatusBar, wgt,
			{x = 255, y = 0, w = 100, h = 20, segments_w = 20, color = WHITE, bg_color = GREY, cath_w = 10, cath_h = 8, segments_h = 20, cath = true, fence_thickness = 1},
			function(wgt) return wgt.values.vTXVoltsPercent end,
			function(wgt) return wgt.values.vTXVoltsColor end
		)
	end
    bStatusBar:label({x = 260, y = 2, text = function() return string.format("TX Batt: %.0f%%", wgt.values.vTXVoltsPercent) end, font = FS.FONT_6, color = WHITE})
    bStatusBar:label({x = 375, y = 2, text = function() return wgt.values.timeCurrent end, font = FS.FONT_6, color = YELLOW})
end

function display_timer(wgt, theBox, lx, ly)
	-- TODO: Open up a menu when pressed. One option "Reset timer"
	-- Use model.resetTime(wgt.options.timer-1) to reset the timer but this only works in App mode
    if (lvgl == nil) then log("refresh(nil)") return end

    theBox:build({
        {type = "box", x = lx, y = ly, children = {
            {type = "label", text = function() return wgt.values.timer_str end, x = 0, y = 0, font = FS.FONT_38 ,
				color = function() return wgt.values.timerIsNeg and RED or wgt.options.textColor end},
        }}
    })
end

function build_FailToArmFlags(wgt, theBox, locx, locy)
    local bFailedArmFlags = theBox:box({x = locx, y = locy, visible = function() return wgt.values.arm_fail end})
    bFailedArmFlags:rectangle({x = 0, y = 0, w = 280, h = 150, color = RED, filled = true, rounded = 8, opacity = 245})
    bFailedArmFlags:label({text = function() return string.format("%s (%s)", wgt.values.arm_disable_flags_txt, wgt.values.arm_fail) end, x = 10, y = 0, font = FS.FONT_8, color = WHITE})
end

function display_ArmState(wgt, theBox, lx, ly)
    local bArm = theBox:box({x = lx, y = ly})
    bArm:label({x = 22, y = 0, text = function() return wgt.values.is_arm and "ARMED" or "Disarmed" end, font = FS.FONT_12, color = function() return wgt.values.is_arm and RED or GREEN end})
end

function display_RXVoltage(wgt, theBox, lx, ly, displayGauge)
    -- RX voltage
    local bRXVolts = theBox:box({x = lx, y = ly})
    bRXVolts:label({text = "RX Battery", x = 0, y = 0, font = FS.FONT_6, color = wgt.options.textColorTitle})
    bRXVolts:label({text = function() return string.format("%.02fv", wgt.values.vBecUsed) end , x = 0, y = 12, font = FS.FONT_16, color=function() return wgt.values.vBecColor end})
    if (displayGauge == true) then
      buildBarGuage(bRXVolts, wgt,
        {x = 0, y = 48,w = 110,h = 20,segments_w = 20, color = WHITE, bg_color = GREY, cath_w = 10, cath_h = 8, segments_h = 20, cath = true, fence_thickness = 1},
        function(wgt) return wgt.values.vBecPercent end,
        function(wgt) return wgt.values.vBecColor end
      )
    end
end

function updateMAUsed(wgt)
    local capa_top = wgt.options.capacityTop
    local capa = getValue("Capa")
    local capa_max = wgt.options.BattCapa --getValue("Capa+")
	capa_max = math.max(capa_max, capa)

    if inSimu then
        --capa = 0
        --capa_max = 5000
    end
	
    wgt.values.capa = capa
    wgt.values.capa_max = capa_max
    wgt.values.capa_percent = math.min(100, math.floor(100 * (capa / capa_max)))
    wgt.values.capa_max_percent = math.min(100, math.floor(100 * (capa_max / capa_max)))
    wgt.values.capa_str = string.format("%0000dma", wgt.values.capa)
    wgt.values.capa_max_str = string.format("%0000dma", wgt.values.capa_max)
end

function display_BatteryVoltage(wgt, theBox, lx, ly)
    local bRXVolts = theBox:box({x = lx, y = ly})
    bRXVolts:label({text = "Batt Voltage", x = 0, y = 0, font = FS.FONT_6, color = wgt.options.textColorTitle})
    bRXVolts:label({text = function() return string.format("%.02fv", wgt.values.vbat) end , x = 0, y = 15, font = FS.FONT_12, color = GREEN})
end

function display_NoConnection(wgt, lx, ly)
    local bNoConn = lvgl.box({x = lx, y = ly, visible = function() return wgt.is_connected == false end})
    bNoConn:rectangle({x = 5, y = 10, w = rf2DashFuncs.isizew - 10, h = rf2DashFuncs.isizeh - 20, rounded = 8, filled = true, color = BLACK, opacity = 250})
    bNoConn:label({x = 15, y = 90, text = function() return wgt.not_connected_error end , font = FS.FONT_8, color = WHITE})
    bNoConn:image({x = 30, y = 0, w = 90, h = 90, file = script_dir.."img/no_connection_wr.png"})
end

function updateCurr(wgt)
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
    wgt.values.curr_max_str = string.format("%dA", wgt.values.curr_max)
end

function updateTemperature(wgt)
    local tempTop = wgt.options.tempTop
	local CorF = "c"

    wgt.values.EscT = getValue("EscT")
    wgt.values.EscT_max = getValue("EscT+")

    if inSimu then
        wgt.values.EscT = 60
        wgt.values.EscT_max = 75
    end

	if getGeneralSettings().imperial > 0 then 
		CorF = "f" 
		wgt.values.EscT = (wgt.values.EscT * 1.8) + 32.0
		wgt.values.EscT_max = (wgt.values.EscT_max * 1.8) + 32.0
	end
	
    wgt.values.EscT_str = string.format("%d°%s", wgt.values.EscT, CorF)
    wgt.values.EscT_max_str = string.format("+%d°%s", wgt.values.EscT_max, CorF)

    wgt.values.EscT_percent = math.min(100, math.floor(100 * (wgt.values.EscT / tempTop)))
    wgt.values.EscT_max_percent = math.min(100, math.floor(100 * (wgt.values.EscT_max / tempTop)))
end

function updateCell(wgt)
    local vbat = getValue("Vbat")

    if inSimu then
        vbat = 22.2
    end

    wgt.values.vbat = vbat
end

-- Transmitter battery voltage
function updateTXBatVoltage(wgt)
	--wgt.values.vTXVolts = getValue(267)	-- This is the "Batt" sensor
	wgt.values.vTXVolts = getValue("tx-voltage")

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


return rf2DashFuncs