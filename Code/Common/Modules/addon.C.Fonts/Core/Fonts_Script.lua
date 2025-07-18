---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Fonts; addon.C.Fonts = NS

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

	do
		function Callback:LoadFonts(loadCustomFonts)
			if loadCustomFonts then
				local localeFonts = addon.C.AddonInfo.Variables.Fonts.FONT_TABLE[NS.Variables.LOCALE]
				for fontName, localeFontInfo in pairs(localeFonts) do
					local fontInfo = Callback.CustomFontUtil:GetFont(fontName)
					NS[fontName] = fontInfo

					--------------------------------

					CallbackRegistry:Trigger("C_FONT_OVERRIDE", fontInfo)
				end
			else
				local localeFonts = addon.C.AddonInfo.Variables.Fonts.FONT_TABLE[NS.Variables.LOCALE]
				for fontName, fontInfo in pairs(localeFonts) do
					NS[fontName] = fontInfo
				end
			end
		end

		function Callback:OverrideFont(fontKey, newFontInfo)
			NS[fontKey] = newFontInfo

			--------------------------------

			CallbackRegistry:Trigger("C_FONT_OVERRIDE", fontKey, newFontInfo)
		end
	end

	--------------------------------
	-- FUNCTIONS (LibSharedMedia)
	--------------------------------

	do
		Callback.LibSharedMedia = {}
		Callback.LibSharedMedia.NAME = "LibSharedMedia-3.0"
		Callback.LibSharedMedia.LIB = nil

		--------------------------------

		function Callback.LibSharedMedia:Load()
			if not C_AddOns.IsAddOnLoaded(Callback.LibSharedMedia.NAME) then C_AddOns.LoadAddOn(Callback.LibSharedMedia.NAME) end

			--------------------------------

			local lib = LibStub and LibStub:GetLibrary(Callback.LibSharedMedia.NAME, true)
			if lib then
				function Callback.LibSharedMedia:GetFonts()
					local results = {}
					local font = lib:HashTable("font")

					for fontName, fontPath in pairs(font) do
						local fontInfo = addon.CS:NewFontInfo(fontName, fontPath, 1)
						table.insert(results, fontInfo)
					end

					return results
				end

				Callback.LibSharedMedia:GetFonts()
			end
		end
	end

	--------------------------------
	-- FUNCTIONS (CustomFontUtil)
	--------------------------------

	do
		Callback.CustomFontUtil = {}

		--------------------------------

		function Callback.CustomFontUtil:GetDefault(key)
			return addon.C.AddonInfo.Variables.Fonts.FONT_TABLE[NS.Variables.LOCALE][key]
		end

		function Callback.CustomFontUtil:GetAllFonts()
			local results = {}
			local default = Callback.CustomFontUtil:GetDefault("CONTENT_DEFAULT")
			local libFonts = Callback.LibSharedMedia:GetFonts()

			table.insert(results, default)
			for i = 1, #libFonts do table.insert(results, libFonts[i]) end

			return results
		end

		function Callback.CustomFontUtil:GetDatabase()
			return addon.C.Database.Variables.DB_GLOBAL.profile.C_FONT_CUSTOM
		end

		function Callback.CustomFontUtil:GetFont(key)
			local db = Callback.CustomFontUtil:GetDatabase()

			-- If font doesn't exist in database, use default
			if not db[key] then db[key] = Callback.CustomFontUtil:GetDefault(key) end

			-- If font doesn't pass integrity check, use default
			if not addon.CS:CheckFontIntegrity(db[key]) then db[key] = Callback.CustomFontUtil:GetDefault(key) end

			-- Return font
			if db[key] then return db[key] end
		end

		function Callback.CustomFontUtil:SetFont(key, fontInfo)
			local db = Callback.CustomFontUtil:GetDatabase()
			db[key] = fontInfo
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:LoadFonts(false)
		Callback.LibSharedMedia:Load()

		C_Timer.After(.1, function()
			Callback:LoadFonts(true)
		end)
	end
end
