local app_name = "rf2_dashN"
local script_dir = "/SCRIPTS/RF2_Dash/"
local baseDir = "/WIDGETS/rf2_dashN/"

local wgt = {}

wgt.values = {
    craft_name = "Not connected",
    timer_str = "--:--",
    timerIsNeg = false,
    rpm = 0,
    rpm_str = "0",

    --vbat = 0,
    --vcel = 0,
    --cell_percent = 0,
    --volt = 0,
    --curr = 0,
    --curr_max = 0,
    --curr_str = "0",
    --curr_max_str = "0",
    --curr_percent = 0,
    --curr_max_percent = 0,

    --EscT = 0,
    --EscT_max = 0,
    --EscT_str = "0",
    --EscT_max_str = "0",
    --EscT_percent = 0,
    --EscT_max_percent = 0,

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

local function display_FlightMode(theBox, lx, ly)
    theBox:build({{type = "box", x = lx, y = ly,
        children = {
            {type = "label", text = "Flight Mode", x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
            {type = "label", text = function() return wgt.values.fmode_str end , x = 2, y = 10, font = FS.FONT_16 ,color = rf2DashFuncs.TextColourItem},
        }
    }})
end

local function build_ui_nitro(wgt)
    if (wgt == nil) then rf2DashFuncs.log("refresh(nil)") return end;
    if (wgt.options == nil) then rf2DashFuncs.log("refresh(wgt.options=nil)") return end;

    lvgl.clear()

    -- global
    lvgl.rectangle({x = 0, y = 0, w = LCD_W, h = LCD_H, color = lcd.RGB(0x111111), filled = true})
    local pMain = lvgl.box({x = 0, y = 0})

	rf2DashFuncs.displayRatePIDprofile(wgt, pMain, 44, 0)
	rf2DashFuncs.display_timer(wgt, pMain, 135, 50)
	rf2DashFuncs.display_RPM(wgt, pMain, 140, 115, FS.FONT_38)
	display_ModelImage(wgt, pMain, 325, 5)
    rf2DashFuncs.display_NoConnection(wgt, 325, 10)
	rf2DashFuncs.display_FailToArmFlags(wgt, pMain, 100, 25)
	rf2DashFuncs.display_statusbar(wgt, 0, wgt.zone.h - 20, 0)
	rf2DashFuncs.display_RXVoltage(wgt, pMain, 0, 205, false)
	display_FlightMode(pMain, 150, 195)
	rf2DashFuncs.display_ArmState(wgt, pMain, 140, 5)
	rf2DashFuncs.display_GovernorState(wgt, pMain, 325, 130)

    --pMain:build({{type = "box", x = 325, y = 175,
    --    children = {
	--		{type = "label", text = function() return string.format("Max: %s", wgt.values.vTXVoltsMax) end, x = 0, y = 0, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
	--		{type = "label", text = function() return string.format("Min: %s", wgt.values.vTXVoltsMin) end, x = 0, y = 20, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
	--		{type = "label", text = function() return string.format("Warn: %s", wgt.values.vTXVoltsWarn) end, x = 0, y = 40, font = FS.FONT_6, color = rf2DashFuncs.TextColourTitle},
    --    }
    --}})
end

local function updateImage(wgt)
    local newCraftName = wgt.values.craft_name
	
    if newCraftName == wgt.values.img_craft_name_for_image then
        return
    end

    local imageName = script_dir.."/img/"..newCraftName..".png"

    if rf2DashFuncs.isFileExist(imageName) == false then
        imageName = "/IMAGES/".. model.getInfo().bitmap

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
    --rf2DashFuncs.updateCell(wgt)
	rf2DashFuncs.updateGovState(wgt)
    rf2DashFuncs.updateProfiles(wgt)
	rf2DashFuncs.updateFlightMode(wgt)
	rf2DashFuncs.updateELRS(wgt)
    rf2DashFuncs.updateArm(wgt)
	rf2DashFuncs.updateVbec(wgt)

	refreshUINoConn(wgt)
end

---------------------------------------------------------------------------------------

local function update(wgt, options)
    if (wgt == nil) then return end
    wgt.options = options
    wgt.not_connected_error = "Not connected"

    --resetWidgetValues(wgt)

    if wgt.options.rxbatNum == nil or wgt.options.rxbatNum == nan or wgt.options.rxbatNum < 0 then
		wgt.options.rxbatNum = 2
	end
	
	if wgt.options.rxbatNum > 0 then
		wgt.values.vBecMax = wgt.options.rxbatNum * 4.2
		wgt.values.vBecMin = wgt.options.rxbatNum * 3.5
	end
	
	build_ui_nitro(wgt)

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
        --resetWidgetValues(wgt)
		-- Refresh items that don't rely on being connected
		refreshUINoConn(wgt)
        return
    end
	
    refreshUI(wgt)
end

return {create=create, update=update, background=background, refresh=refresh}