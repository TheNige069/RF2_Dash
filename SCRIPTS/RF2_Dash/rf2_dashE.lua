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
    bCraftName:label({text = function() return wgt.values.craft_name end,  x = 15, y = 20, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})

    display_NoConnection(wgt, 325, 10)
	display_AmpsGauge(wgt, pMain, {x = 0, y = 0, h = 180, w = 180}, lcd.RGB(0xFF623F))
	display_MAHUsedGauge(wgt, pMain, {x = 170, y = 0, h = 180, w = 180}, lcd.RGB(0x62FF3F))
	displayRPM(wgt, pMain, 1, 140, FS.FONT_16)
	displayESCTemperature(wgt, pMain, 110, 140)
	display_BatteryVoltage(wgt, pMain, 200, 140)	
	display_GovernorState(wgt, pMain, 325, 140)
	display_ArmState(wgt, pMain, 160, 200)
	display_RXVoltage(wgt, pMain, 0, 205, false)
	displayRatePIDprofile(wgt, pMain, 90, 205)
	display_timer(wgt, pMain, 290, 190)
	build_statusbar(wgt, 0, wgt.zone.h - 20, 0)
	build_FailToArmFlags(wgt, pMain, 100, 25)
end

local function updateRpm(wgt)
    local Hspd = getValue("Hspd")
	
    if inSimu then Hspd = 1800 end
	
    wgt.values.rpm = Hspd
    wgt.values.rpm_str = string.format("%s",Hspd)
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

local function updateELRS(wgt)
    wgt.values.rqly = getValue("RQly")
    local rqly_min = getValue("RQly-")
    if rqly_min > 0 then
        wgt.values.rqly_min = rqly_min
    end
    wgt.values.rqly_str = string.format("%d%%", wgt.values.rqly)
    wgt.values.rqly_min_str = string.format("%d%%", wgt.values.rqly_min)
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