local rf2DashFuncs = {}
local script_dir = "/SCRIPTS/RF2_Dash/"

FS = {FONT_38 = XXLSIZE, FONT_16 = DBLSIZE, FONT_12 = MIDSIZE, FONT_8 = 0, FONT_6 = SMLSIZE}
rf2DashFuncs.inSimu = string.sub(select(2, getVersion()), -4) == "simu"

rf2DashFuncs.isizew = 150
rf2DashFuncs.isizeh = 120
rf2DashFuncs.TextColourTitle = COLOR_THEME_PRIMARY2
rf2DashFuncs.TextColourItem = COLOR_THEME_SECONDARY2

local function formatTime(t1, useDays)
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

function rf2DashFuncs.display_ModelImage(wgt, theBox, lx, ly)
    -- Craft name
    local bCraftName = theBox:box({x = lx, y = ly + 75})
    bCraftName:rectangle({x = 10, y = 20, w = rf2DashFuncs.isizew - 20, h = 20, filled = true, rounded = 8, color = DARKGREY, opacity = 200})
    bCraftName:label({text = function() return wgt.values.craft_name end,  x = 15, y = 20, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})

    -- Model image
    local bImageArea = theBox:box({x = lx, y = ly})
    bImageArea:rectangle({x = 0, y = 0, w = rf2DashFuncs.isizew, h = rf2DashFuncs.isizeh, thickness = 4, rounded = 15, filled = false, color = GREY})
    bImageArea:image({x=0, y=0, w=rf2DashFuncs.isizew, h=rf2DashFuncs.isizeh, fill=false,
        file=function()
            return wgt.values.img_last_name
        end
    })
end

-- RX battery or BEC voltage
function rf2DashFuncs.updateVbec(wgt)
    local vBecUsed = getSourceValue("Vbec")
	if vBecUsed ~= nil then
		wgt.values.vBecUsed = vBecUsed
	end

    if rf2DashFuncs.inSimu then
		wgt.values.vBecUsed = getSourceValue("RxBt")
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

-- To display the current time on the dashboard
-- This is the local time as set in the transmitter, not the time from any of the timers
function rf2DashFuncs.updateCurrentTime(wgt)
	local theDateTime = getDateTime()

	wgt.values.timeCurrent = string.format("%02d:%02d TheNige", theDateTime.hour, theDateTime.min)
end

function rf2DashFuncs.updateCraftName(wgt)
	wgt.values.craft_name = string.gsub(model.getInfo().name, "^>", "")
end

function rf2DashFuncs.updateTimeCount(wgt)
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

-- Current PID profile
function rf2DashFuncs.updateProfiles(wgt)
    local profile_id = getSourceValue("PID#")
	if profile_id == nil then profile_id = 0 end

    if profile_id > 0 then
        wgt.values.profile_id = profile_id
    else
        wgt.values.profile_id = "---"
    end
    wgt.values.profile_id_str = string.format("%s", wgt.values.profile_id)

    -- Current Rate profile
    local rate_id = getSourceValue("RTE#")
    if rate_id == nil then
        wgt.values.rate_id = "---"
    elseif rate_id > 0 then
        wgt.values.rate_id = rate_id
    end
    wgt.values.rate_id_str = string.format("%s", wgt.values.rate_id)
end

local function isArmed()
    local flags = getSourceValue("ARM")
    if flags == nil then return false end

    local armFlag = bit32.band(flags, 0x01)
    return armFlag == 1
end

local function armingDisableFlagsList(flags)
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

function rf2DashFuncs.updateArm(wgt)
    wgt.values.is_arm = isArmed()
	local flags = getSourceValue("ARMD")
    if flags == nil then flags = 0 end

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

local function buildBarGuage(parentBox, wgt, myValues, fPercent, getPercentColor)
    local percent = fPercent(wgt)
    local r = 30
    --local fill_color = myValues.bar_color or GREEN
    local fill_color = (getPercentColor~=nil) and getPercentColor(wgt, percent) or GREEN
    local tw = 4
    local th = 4

    local box = parentBox:box({x=myValues.x, y=myValues.y})
    box:rectangle({x = 0, y = 0, w = myValues.w, h = myValues.h, color = myValues.bg_color, filled = true, rounded = 6, thickness = 8})
    box:rectangle({x = 0, y = 0, w = myValues.w, h = myValues.h, color = WHITE, filled = false, thickness = myValues.fence_thickness or 3, rounded = 8})
    box:rectangle({x = 5, y = 5,
        -- w=0, h=myValues.h,
        filled=true, rounded=4,
        size = function() return math.floor(fPercent(wgt) / 100 * myValues.w) - 10, myValues.h - 10 end,
        color = function() return getPercentColor(wgt, percent) or GREEN end,
    })

    return box
end

function rf2DashFuncs.updateRpm(wgt)
    local Hspd = getSourceValue("Hspd")
	if Hspd == nil then Hspd = 0 end

    if rf2DashFuncs.inSimu then Hspd = 1800 end

    wgt.values.rpm = Hspd
    wgt.values.rpm_str = string.format("%s",Hspd)
end

function rf2DashFuncs.log(fmt, ...)
    print(string.format("[%s] "..fmt, app_name, ...))
    return
end

function rf2DashFuncs.updateGovState(wgt)
    local govState = getSourceValue("Gov")
    if govState == nil then govState = 0 end

	local govStateTxt = ""

    if rf2DashFuncs.inSimu then govState = 8 end

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

function rf2DashFuncs.isFileExist(file_name)
    local hFile = io.open(file_name, "r")
    if hFile == nil then
        rf2DashFuncs.log("rf2_dash: isFileExist: file not exist - %s", file_name)
        return false
    end
    io.close(hFile)
    return true
end

function rf2DashFuncs.displayRatePIDprofile(wgt, theBox, lx, ly)
    --if (lvgl == nil) then log("refresh(nil)") return end
    --local pMain = lvgl.box({x=0, y=0})

    if rf2DashFuncs.inSimu then
        wgt.values.profile_id_str = 3
        wgt.values.rate_id_str = 4
    end

    -- pid profile (bank)
    theBox:build({{type = "box", x = lx, y = ly,
        children = {
            -- {type = "rectangle", x = 0, y = 0, w = 40, h = 50, color = YELLOW},
            {type = "label", text = "Profile", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
            {type = "label", text = function() return wgt.values.profile_id_str end , x = 5, y = 10, font = FS.FONT_16, color = rf2DashFuncs.TextColourItem},
        }
    }})

    -- rate profile
    theBox:build({{type = "box", x = lx + 46, y = ly,
        children = {
            -- {type = "rectangle", x = 0, y = 0, w = 40, h = 50, color = YELLOW},
            {type = "label", text = "Rate", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
            {type = "label", text = function() return wgt.values.rate_id_str end , x = 5, y = 10, font = FS.FONT_16, color = rf2DashFuncs.TextColourItem},
        }
    }})
end

function rf2DashFuncs.updateFlightMode(wgt)
    local fmno, fmname = getFlightMode()

    wgt.values.fmode = fmno
    wgt.values.fmode_str = fmname
end

function rf2DashFuncs.display_GovernorState(wgt, theBox, lx, ly)
    local bGS = theBox:box({x = lx, y = ly})
    bGS:label({text = "Governor State", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle})
    bGS:label({text = function() return wgt.values.govState_str end , x = 0, y = 20, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
end

function rf2DashFuncs.updateELRS(wgt)
    local valRQLY = getSourceValue("RQly")
	if valRQLY ~= nil then wgt.values.rqly = valRQLY end

    local rqly_min = getSourceValue("RQly-")
	if rqly_min == nil then
		rqly_min = 0
	end

    if rqly_min > 0 then
        wgt.values.rqly_min = rqly_min
    end
    wgt.values.rqly_str = string.format("%d%%", wgt.values.rqly)
    wgt.values.rqly_min_str = string.format("%d%%", wgt.values.rqly_min)
end

function rf2DashFuncs.display_statusbar(wgt, lx, ly, txBatBar)
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

function rf2DashFuncs.display_timer(wgt, theBox, lx, ly)
	-- TODO: Open up a menu when pressed. One option "Reset timer"
	-- Use model.resetTime(wgt.options.timer-1) to reset the timer but this only works in App mode
    if (lvgl == nil) then rf2DashFuncs.log("refresh(nil)") return end

    theBox:build({
        {type = "box", x = lx, y = ly, children = {
            {type = "label", text = function() return wgt.values.timer_str end, x = 0, y = 0, font = FS.FONT_38 ,
				color = function() return wgt.values.timerIsNeg and RED or rf2DashFuncs.TextColourItem end},
        }}
    })
end

function rf2DashFuncs.display_FailToArmFlags(wgt, theBox, locx, locy)
    local bFailedArmFlags = theBox:box({x = locx, y = locy, visible = function() return wgt.values.arm_fail end})
    bFailedArmFlags:rectangle({x = 0, y = 0, w = 280, h = 150, color = RED, filled = true, rounded = 8, opacity = 245})
    bFailedArmFlags:label({text = function() return string.format("%s (%s)", wgt.values.arm_disable_flags_txt, wgt.values.arm_fail) end, x = 10, y = 0, font = FS.FONT_8, color = WHITE})
end

function rf2DashFuncs.display_ArmState(wgt, theBox, lx, ly)
    local bArm = theBox:box({x = lx, y = ly})
    bArm:label({x = 22, y = 0, text = function() return wgt.values.is_arm and "ARMED" or "Disarmed" end, font = FS.FONT_12, color = function() return wgt.values.is_arm and RED or GREEN end})
end

function rf2DashFuncs.display_RXVoltage(wgt, theBox, lx, ly, displayGauge)
    -- RX voltage
    local bRXVolts = theBox:box({x = lx, y = ly})
    bRXVolts:label({text = "RX Battery", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle})
    bRXVolts:label({text = function() return string.format("%.02fv", wgt.values.vBecUsed) end , x = 0, y = 12, font = FS.FONT_16, color=function() return wgt.values.vBecColor end})
    if (displayGauge == true) then
      buildBarGuage(bRXVolts, wgt,
        {x = 0, y = 48,w = 110,h = 20,segments_w = 20, color = WHITE, bg_color = GREY, cath_w = 10, cath_h = 8, segments_h = 20, cath = true, fence_thickness = 1},
        function(wgt) return wgt.values.vBecPercent end,
        function(wgt) return wgt.values.vBecColor end
      )
    end
end

function rf2DashFuncs.display_RPM(wgt, theBox, lx, ly, textSize)

    theBox:build({{type = "box", x = lx, y = ly,
        children = {
            {type = "label", text = "RPM", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
            {type = "label", text = function() return wgt.values.rpm_str end, x = 0, y = 10, font = textSize, color = rf2DashFuncs.TextColourItem},
        }
    }})

end

function rf2DashFuncs.display_NoConnection(wgt, lx, ly)
    local bNoConn = lvgl.box({x = lx, y = ly, visible = function() return wgt.is_connected == false end})
    bNoConn:rectangle({x = 5, y = 10, w = rf2DashFuncs.isizew - 10, h = rf2DashFuncs.isizeh - 20, rounded = 8, filled = true, color = BLACK, opacity = 250})
    bNoConn:label({x = 15, y = 90, text = function() return wgt.not_connected_error end , font = FS.FONT_8, color = WHITE})
    bNoConn:image({x = 30, y = 0, w = 90, h = 90, file = script_dir.."img/no_connection_wr.png"})
end

function rf2DashFuncs.updateESCTemperature(wgt)
    local tempTop = wgt.options.tempTop
	local CorF = "c"

    wgt.values.EscT = getSourceValue("Tesc")
    if wgt.values.EscT == nil then wgt.values.EscT = 0 end
    wgt.values.EscT_max = getSourceValue("Tesc+")
    if wgt.values.EscT_max == nil then wgt.values.EscT_max = 0 end

    if rf2DashFuncs.inSimu then
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

-- Transmitter battery voltage
function rf2DashFuncs.updateTXBatVoltage(wgt)
	--wgt.values.vTXVolts = getValue(267)	-- This is the "Batt" sensor
	wgt.values.vTXVolts = getSourceValue("tx-voltage")
    if wgt.values.vTXVolts == nil then wgt.values.vTXVolts = 0 end

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

-- These two variables are used to store the curve number. -1 signifies they haven't been set.
rf2DashFuncs.crvNitro = -1
rf2DashFuncs.crvElec = -1

function rf2DashFuncs.getOurCurves()
	print("--- getOurCurves")
	local success, result = pcall(function()
		-- Your script code here
		-- This code might generate an error
		error("An intentional error occurred!")
	end)

	if not success then
		-- An error occurred, 'result' will contain the error message
		print("Error: " .. result)
		-- You can log the error, display a message to the user, or take corrective action
	else
		-- The script executed successfully, 'result' contains the return value
		print("Script executed successfully.")
	end
    rf2DashFuncs.crvNitro = 0
    rf2DashFuncs.crvElec = 0

end

-- Switches the "Normal" throttle curve from one to another based on 
-- if there is an "_N" or an "_E" at the end of the model name
-- Still todo:
-- * Search for the curves to use. Instruct users to name the curves "NIT" and "LEC" then search for these
-- * Search for the Throttle profile to use.
--
function rf2DashFuncs.switchNormalCurve(wgt)
	print("--- switchNormalCurve")
	local craftname = string.upper(wgt.values.craft_name)
	local changeCurve = 0
	local inNumber = 5   -- The input line number - Zero (0) based
	local inLineNum = 1  -- The line number in the input entry to change
	local crvNitro = 5
	local crvElec  = 1

	local varEorN = string.sub(craftname, string.len(craftname) - 2)
	
	if rf2DashFuncs.crvNitro == -1 then getOurCurves() end
	if rf2DashFuncs.crvElec == -1 then getOurCurves() end

	if varEorN == "_E" then
		changeCurve = crvNitro
	elseif varEorN == "_N" then
		changeCurve = crvElec
	else
		changeCurve = 0
	end
	
	if changeCurve > 0 then
	-- TODO: Change this so that it searches for Throttle 
		local inLineThrottle = model.getInput(inNumber, 1)	-- On my settings, this is Throttle - Normal curve
		inLineThrottle.curveValue = 5
		model.deleteInput(inNumber, inLineNum)
		model.insertInput(inNumber, inLineNum, inLineThrottle)	
	end
end

return rf2DashFuncs