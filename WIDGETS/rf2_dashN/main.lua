-- Nitro oriented dashboard
local app_name = "rf2_dashN"
local script_dir = "/SCRIPTS/RF2_Dash/"
local widg_dir = "/WIDGETS/rf2_dashN/"

local rf2dash = nil
local rf2dash_opt = assert(loadScript(script_dir..app_name .. "_opt.lua", "tcd"))()

local function create(zone, options)
    rf2dash = assert(loadScript(script_dir..app_name .. ".lua", "tcd"))()
    return rf2dash.create(zone, options)
end
local function update(wgt, options) return rf2dash.update(wgt, options) end
local function refresh(wgt)         return rf2dash.refresh(wgt)    end
local function background(wgt)      return rf2dash.background(wgt) end

return {name=app_name, options=rf2dash_opt.options, translate=rf2dash_opt.translate, create=create, update=update, refresh=refresh, background=background, useLvgl=true}
