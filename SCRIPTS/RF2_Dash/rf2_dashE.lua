local app_name = "rf2_dashE"
local script_dir = "/SCRIPTS/RF2_Dash/"
local baseDir = "/WIDGETS/rf2_dashE/"

local wgt = {}

local WHITE = lcd.RGB(255, 255, 255)

wgt.values = {
    craft_name = "Not connected",
    timer_str = "--:--",
    timerIsNeg = false,
    rpm = 0,
    rpm_str = "0",

    vbat = 0,
    vbatOnConnect = nil,  -- Voltage on connection
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

    img_box = nil,
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

    colourMAHGauge = lcd.RGB(0x62FF3F),
    colourMAHGaugeInner = WHITE, --lcd.RGB(0x62FF3F),
    
    needToRebuildUI = true
}

local function loadFuncs()
	if not rf2DashFuncs then
		rf2DashFuncs = assert(loadScript(script_dir .. "rf2_dashFunc.lua"))
	end
	return rf2DashFuncs()
end
local rf2DashFuncs = loadFuncs()

--local img_box = nil
local err_img = bitmap.open(script_dir.."img/no_connection_wr.png")

local function calEndAngle(percent, minAngle, maxAngle)
	if percent == nil then return 0 end
	local v = ((percent / 100) * (maxAngle - minAngle)) + minAngle
	return v
end

local function display_AmpsGauge(wgt, theBox, boxSize, gaugeColour)
    local g_thick = 20
    local gm_thick = 10
    local g_angle_min = 140
    local g_angle_max = 400
    local centre_x = (boxSize.w / 2) - g_thick --+ boxSize.x
    local centre_y = (boxSize.h / 2) - gm_thick --+ boxSize.y
    local g_rad = math.min((boxSize.w / 2), (boxSize.h / 2)) - g_thick - 2
    local gm_rad =  g_rad - g_thick --+ (g_thick / 2)

    local bCurr = theBox:box({x = boxSize.x, y = boxSize.y})

    bCurr:label({text = "Amps",  x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle})
    -- Current value
    bCurr:label({x = centre_x - g_thick, y = (boxSize.h / 2) - g_thick, text = function() return wgt.values.curr_str end, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
    -- Max current value
    bCurr:label({x = centre_x - g_thick, y = centre_y + 20, text = function() return wgt.values.curr_max_str end, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = g_angle_max, rounded = true, color = lcd.RGB(0x222222)})
    bCurr:arc({x = centre_x, y = centre_y, radius = gm_rad, thickness = gm_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.curr_max_percent, g_angle_min, g_angle_max) end, color = gaugeColour, opacity = 180})
    bCurr:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.curr_percent, g_angle_min, g_angle_max) end, color = gaugeColour})
end

local function calcNumCells(theVoltage)

    local topCellVoltage = 1
    
    if (theVoltage == nil or theVoltage == 0) and (wgt.values.vbat ~= nil or wgt.values.vbat > 0) then theVoltage = wgt.values.vbat end

    if wgt.options.BattType == 1 then
        topCellVoltage = 4.3 -- lipo
    elseif wgt.options.BattType == 2 then
        topCellVoltage = 4.45 -- hv lipo
    elseif wgt.options.BattType == 3 then
        topCellVoltage = 4.30 -- lion
    elseif wgt.options.BattType == 4 then
        topCellVoltage = 3.5 -- life_po4
    else
        topCellVoltage = 4.3 -- default to lipo
    end

    for i = 1, 14 do
        rf2DashFuncs.log("calcNumCells %s | %s", theVoltage, topCellVoltage * i)
        if theVoltage < topCellVoltage * i then
            rf2DashFuncs.log("calcNumCells %s --> %s", theVoltage, i)
            return i
        end
    end

    rf2DashFuncs.log("calcNumCells: no match found: " .. theVoltage)
    return 1
end

local function calcInitialBattVoltage()
    if wgt.is_connected then
        if ((wgt.values.colourMAHGaugeInner == nil or wgt.values.colourMAHGaugeInner == WHITE) and wgt.values.vbatOnConnect ~= nil) then
            local colourMAHGaugeInner = lcd.RGB(0x000000)

            if rf2DashFuncs.inSimu then 
                wgt.values.vbatOnConnect = 23.2 
            end
            local cellCount = getSourceValue("Cel#") or 0
            rf2DashFuncs.log("calcInitialBattVoltage: cellCount: %s", cellCount)

            if (cellCount == 0) then cellCount = calcNumCells(wgt.values.vbatOnConnect) end
            rf2DashFuncs.log("calcInitialBattVoltage: cellCount: %s", cellCount)

            if (wgt.values.vbatOnConnect < (cellCount * 3.818)) then
                colourMAHGaugeInner = lcd.RGB(255, 0, 0)    -- 0xFF0000
                rf2DashFuncs.log("Battery voltage less than 40%%")
            elseif (wgt.values.vbatOnConnect < (cellCount * 4.021)) then
                colourMAHGaugeInner = lcd.RGB(255, 136, 104) -- 0xFF866A
                rf2DashFuncs.log("Battery voltage less than 80%%")
            else
                colourMAHGaugeInner = lcd.RGB(0, 255, 0) -- 0x00FF00
                rf2DashFuncs.log("Battery voltage greater than 80%%")
            end
            wgt.values.colourMAHGaugeInner = colourMAHGaugeInner
            --rf2DashFuncs.log("Battery voltage colour wgt:  " .. wgt.colourMAHGaugeInner)
            wgt.values.needToRebuildUI = true
        end
    end
end

local function display_MAHUsedGauge(wgt, theBox, boxSize, gaugeColour)
    local g_thick = 20
    local gm_thick = 10
    local g_angle_min = 140
    local g_angle_max = 400
    local centre_x = (boxSize.w / 2) - g_thick --+ boxSize.x
    local centre_y = (boxSize.h / 2) - gm_thick --+ boxSize.y
    local g_rad = math.min((boxSize.w / 2), (boxSize.h / 2)) - g_thick - 2
    local gm_rad =  g_rad - g_thick --+ (g_thick / 2)
	
    local bCapa = theBox:box({x = boxSize.x, y = boxSize.y})

    bCapa:label({text = "MA Used",  x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle})
    -- Capacity percentage
	--bCapa:label({x = centre_x - g_thick, y = (boxSize.h / 2) - (2 * g_thick), text = function() return wgt.values.capa_percent.."%" end, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
	bCapa:label({x = centre_x - g_thick, y = (boxSize.h / 2) - (2 * g_thick), text = function() if wgt.values.capaRem_percent == nil then wgt.values.capaRem_percent = 0 end return wgt.values.capaRem_percent .. "%" end, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
    -- Capacity used 
	bCapa:label({x = centre_x - g_thick-10, y = (boxSize.h / 2) - g_thick, text = function() return wgt.values.capa_str end, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
    -- Max Capacity
	bCapa:label({x = centre_x - g_thick-12, y = centre_y + 30, text = function() return wgt.values.capa_max_str end, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
    -- Background outer ring
    bCapa:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = g_angle_max, rounded = true, color = lcd.RGB(0x222222)})
    -- Inner ring
    -- Change inner ring colour based on initial voltage. If it's above 80% then green, orange if > 40%, anything below 40% is red
    bCapa:arc({x = centre_x, y = centre_y, radius = gm_rad, thickness = gm_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.capa_max_percent, g_angle_min, g_angle_max) end, color = wgt.values.colourMAHGaugeInner, opacity = 180})
    -- Used capacity ring
    bCapa:arc({x = centre_x, y = centre_y, radius = g_rad, thickness = g_thick, startAngle = g_angle_min, endAngle = function() return calEndAngle(wgt.values.capaRem_percent, g_angle_min, g_angle_max) end, color = gaugeColour})
end

local function displayESCTemperature(wgt, theBox, lx, ly)
    local escT = theBox:box({x = lx, y = ly})
    escT:label({text = "ESC Temp", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle})
    escT:label({text = function() return wgt.values.EscT_str end , x = 0, y = 15, font = FS.FONT_12, color = rf2DashFuncs.TextColourItem})
end

local function display_BatteryVoltage(wgt, theBox, lx, ly)
    local bRXVolts = theBox:box({x = lx, y = ly})
    bRXVolts:label({text = "Batt Voltage", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle})
    bRXVolts:label({text = function() return string.format("%.02fv", wgt.values.vbat) end , x = 0, y = 15, font = FS.FONT_12, color = wgt.values.colourMAHGaugeInner})
end

local function display_ModelImage(wgt, theBox, lx, ly)
    -- Model image
    local bImageArea = theBox:box({x = lx, y = ly})
    bImageArea:rectangle({x = 0, y = 0, w = rf2DashFuncs.isizew, h = rf2DashFuncs.isizeh, thickness = 4, rounded = 15, filled = false, color = GREY})
    local bImg = bImageArea:box({})
    wgt.values.img_box = bImg

    -- Craft name
    local bCraftName = theBox:box({x = lx, y = ly + 75})
    bCraftName:rectangle({x = 10, y = 20, w = rf2DashFuncs.isizew - 20, h = 20, filled = true, rounded = 8, color = DARKGREY, opacity = 200})
    bCraftName:label({text = function() return wgt.values.craft_name end,  x = 15, y = 20, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})
end

local function build_ui_electric(wgt)
    local dx = 20

    if wgt.values.colourMAHGaugeInner == nil or wgt.values.colourMAHGaugeInner == WHITE then calcInitialBattVoltage(wgt) end

    lvgl.clear()

    -- global
    lvgl.rectangle({x = 0, y = 0, w = LCD_W, h = LCD_H, color = lcd.RGB(0x111111), filled = true})
    local pMain = lvgl.box({x = 0, y = 0})

	-- Model image
	display_ModelImage(wgt, pMain, 325, 5)
    --local bImageArea = pMain:box({x = 325, y = 5})
	--wgt.values.img_box = bImageArea:rectangle({x = 0, y = 0, w = rf2DashFuncs.isizew, h = rf2DashFuncs.isizeh, thickness = 4, rounded = 15, filled = false, color = GREY})
	
    -- Craft name
    --local bCraftName = pMain:box({x = 325, y = 80})
    --bCraftName:rectangle({x = 10, y = 20, w = rf2DashFuncs.isizew - 20, h = 20, filled = true, rounded = 8, color = DARKGREY, opacity = 200})
    --bCraftName:label({text = function() return wgt.values.craft_name end,  x = 15, y = 20, font = FS.FONT_8, color = rf2DashFuncs.TextColourItem})

    rf2DashFuncs.display_NoConnection(wgt, 325, 10)
	display_AmpsGauge(wgt, pMain, {x = 0, y = 0, h = 180, w = 180}, lcd.RGB(0xFF623F))
	display_MAHUsedGauge(wgt, pMain, {x = 170, y = 0, h = 180, w = 180}, lcd.RGB(0x62FF3F))
	rf2DashFuncs.display_RPM(wgt, pMain, 1, 140, FS.FONT_16)
	displayESCTemperature(wgt, pMain, 110, 140)
	display_BatteryVoltage(wgt, pMain, 200, 140)
	rf2DashFuncs.display_GovernorState(wgt, pMain, 325, 130)
	rf2DashFuncs.display_ArmState(wgt, pMain, 160, 200)
	rf2DashFuncs.display_RXVoltage(wgt, pMain, 0, 205, false)
	rf2DashFuncs.displayRatePIDprofile(wgt, pMain, 90, 205)
	rf2DashFuncs.display_timer(wgt, pMain, 290, 190)
	rf2DashFuncs.display_statusbar(wgt, 0, wgt.zone.h - 20, 0)
	rf2DashFuncs.display_FailToArmFlags(wgt, pMain, 100, 25)
end

-- If capa_percent is divisible by BatteryCallout then let them know
local announcedBatPercent = false

local function readoutBatteryPercentage(wgt)
	if (wgt.options.BatteryCallout == 0) then wgt.options.BatteryCallout = 10 end

	if (math.fmod(wgt.values.capaRem_percent, wgt.options.BatteryCallout) == 0)  then
		if (announcedBatPercent == false) then 
			playNumber(wgt.values.capaRem_percent, 13, 0)
		end
		announcedBatPercent = true
	else
		announcedBatPercent = false
	end
end

function updateCell(wgt)
    local vbat = getSourceValue("Vbat") or 0.0

    if (wgt.values.vbatOnConnect == nil) then wgt.values.vbatOnConnect = vbat end
    if rf2DashFuncs.inSimu then wgt.values.vbatOnConnect = 22.29 end

    --if vbat == nil then vbat = 0 end

    if rf2DashFuncs.inSimu then
        vbat = 22.2
    end

    wgt.values.vbat = vbat
end

local function updateMAUsed(wgt)
    local capa_top = wgt.options.capacityTop
    local capa = getSourceValue("Capa")
    if capa == nil then capa = 0 end

    local capa_max = wgt.options.BattCapa --getValue("Capa+")
	capa_max = math.max(capa_max, capa)

    --BattCapMin %
    local battCapCanUse = ((100 - wgt.options.BattCapMin) / 100) * capa_max

    wgt.values.capa = capa
    --wgt.values.capaRem = capa_max - capa
    --wgt.values.capaRem_percent = math.min(100, math.floor(100 * (wgt.values.capaRem / capa_max)))
    wgt.values.capaRem = battCapCanUse - capa
    wgt.values.capaRem_percent = math.min(100, math.floor(100 * (wgt.values.capaRem / battCapCanUse)))
    if (wgt.values.capaRem_percent < 0) then wgt.values.capaRem_percent = 0 end

    wgt.values.capa_max = capa_max
    wgt.values.capa_percent = math.min(100, math.floor(100 * (capa / capa_max)))
    wgt.values.capa_max_percent = math.min(100, math.floor(100 * (capa_max / capa_max)))
    --wgt.values.capa_str = string.format("%0000dma", wgt.values.capa)
    wgt.values.capa_str = string.format("%0000dma", wgt.values.capaRem)
    wgt.values.capa_max_str = string.format("%0000dma", wgt.values.capa_max)

    readoutBatteryPercentage(wgt)
end

local function updateCurr(wgt)
    local curr_top = wgt.options.currTop
    local curr = getSourceValue("Curr")
    if curr == nil then curr = 0 end

    local curr_max = getSourceValue("Curr+")
    if curr_max == nil then curr_max = 0 end

	curr_max = math.max(curr_max, curr)

    if rf2DashFuncs.inSimu then
        curr = 205
        curr_max = 255
    end
	
    wgt.values.curr = curr
    wgt.values.curr_max = curr_max
    wgt.values.curr_percent = math.min(100, math.floor(100 * (curr / curr_top)))
    wgt.values.curr_max_percent = math.min(100, math.floor(100 * (curr_max / curr_top)))
    wgt.values.curr_str = string.format("%0.01fA", wgt.values.curr)
    wgt.values.curr_max_str = string.format("%0.01fA", wgt.values.curr_max)
end

local function updateImage(wgt)
    local newCraftName = wgt.values.craft_name
	
    if newCraftName == wgt.values.img_craft_name_for_image then
        return
    end

    local imageName = script_dir .. "/img/" .. newCraftName..".png"

    if rf2DashFuncs.isFileExist(imageName) == false then
        imageName = "/IMAGES/" .. model.getInfo().bitmap

        if imageName == "" or rf2DashFuncs.isFileExist(imageName) == false then
            imageName = script_dir.."img/rf2_logo.png"
        end
    end

    if imageName ~= wgt.values.img_last_name then
        wgt.values.img_box:clear()
		wgt.values.img_box:image({file = imageName, x = 0, y = 0, w = rf2DashFuncs.isizew, h = rf2DashFuncs.isizeh, fill = false})

        wgt.values.img_last_name = imageName
        wgt.values.img_craft_name_for_image = newCraftName
    end
end

local function refreshUINoConn(wgt)
	rf2DashFuncs.updateCurrentTime(wgt)
	rf2DashFuncs.updateTXBatVoltage(wgt)
end

local function refreshUI(wgt)
    rf2DashFuncs.updateCraftName(wgt)
    updateImage(wgt)
    rf2DashFuncs.updateTimeCount(wgt)
    rf2DashFuncs.updateRpm(wgt)
    updateCell(wgt)
    updateCurr(wgt)
	updateMAUsed(wgt)
	rf2DashFuncs.updateGovState(wgt)
    rf2DashFuncs.updateProfiles(wgt)
	rf2DashFuncs.updateFlightMode(wgt)
	rf2DashFuncs.updateELRS(wgt)
    rf2DashFuncs.updateArm(wgt)
	rf2DashFuncs.updateVbec(wgt)
    rf2DashFuncs.updateESCTemperature(wgt)

	refreshUINoConn(wgt)
end

---------------------------------------------------------------------------------------

local function update(wgt, options)
    if (wgt == nil) then return end
    wgt.options = options
    wgt.not_connected_error = "Not connected"

    --resetWidgetValues(wgt)
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
        wgt.values.needToRebuildUI = true
        --resetWidgetValues(wgt)
		-- Refresh items that don't rely on being connected
		refreshUINoConn(wgt)
        return
    else
	    --rf2DashFuncs.log("refresh - Connected")
        calcInitialBattVoltage(wgt) 
        if (wgt.values.needToRebuildUI == true) then
            build_ui_electric(wgt)
            wgt.values.needToRebuildUI = false
        end
    end
	
    refreshUI(wgt)
end

return {create=create, update=update, background=background, refresh=refresh}