---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.EventListener; addon.C.EventListener = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	--------------------------------
	-- EVENTS
	--------------------------------

	do
		local _ = CreateFrame("Frame")
		_:RegisterEvent("UI_SCALE_CHANGED")
		_:RegisterEvent("GLOBAL_MOUSE_DOWN")
		_:RegisterEvent("GLOBAL_MOUSE_UP")
		_:RegisterEvent("CINEMATIC_START")
		_:RegisterEvent("CINEMATIC_STOP")
		_:RegisterEvent("PLAY_MOVIE")
		_:RegisterEvent("STOP_MOVIE")
		_:SetScript("OnEvent", function(self, event, ...)
			if event == "GLOBAL_MOUSE_DOWN" then
				CallbackRegistry:Trigger("EVENT_MOUSE_DOWN", ...)
			elseif event == "GLOBAL_MOUSE_UP" then
				CallbackRegistry:Trigger("EVENT_MOUSE_UP", ...)
			end

			if event == "UI_SCALE_CHANGED" then
				CallbackRegistry:Trigger("UI_SCALE_CHANGED", ...)
			end

			if event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
				CallbackRegistry:Trigger("EVENT_CINEMATIC_START", ...)
			elseif event == "CINEMATIC_STOP" or event == "STOP_MOVIE" then
				CallbackRegistry:Trigger("EVENT_CINEMATIC_STOP", ...)
			end
		end)
	end

	--------------------------------
	-- SETUP
	--------------------------------
end
