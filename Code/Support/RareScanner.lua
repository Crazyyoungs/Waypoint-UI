local env = select(2, ...)
local Config = env.Config
local CallbackRegistry = env.WPM:Import("wpm_modules\\callback-registry")
local MapPin = env.WPM:Import("@\\MapPin")
local Support = env.WPM:Import("@\\Support")
local Support_TomTom = env.WPM:Import("@\\Support\\TomTom")
local Support_RareScanner = env.WPM:New("@\\Support\\RareScanner")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("RSSupportEnabled") == true end


local SessionWaypointInfo = { name = nil, mapID = nil, x = nil, y = nil }
local RareScannerWaypointSupportOverride = { active = false, mode = nil, original = nil, node = nil }

local function NormalizeCoordinate(coord)
    coord = tonumber(coord)
    if not coord or coord < 0 then return nil end
    if coord <= 1 then
        return coord * 100
    end
    while coord > 100 do
        coord = coord / 100
    end
    return coord
end

local function CaptureWaypointInfo(scannerButton)
    if not scannerButton then return nil end

    local mapID = tonumber(scannerButton.mapID)
    local x = NormalizeCoordinate(scannerButton.x)
    local y = NormalizeCoordinate(scannerButton.y)
    if not mapID or not x or not y then return nil end

    local titleText = scannerButton.Title and scannerButton.Title.GetText and scannerButton.Title:GetText() or nil
    SessionWaypointInfo.name = scannerButton.name or titleText
    SessionWaypointInfo.mapID = mapID
    SessionWaypointInfo.x = x
    SessionWaypointInfo.y = y

    return SessionWaypointInfo
end

local function GetRareScannerGeneralConfigNode()
    local db = _G.RareScannerDB
    if type(db) ~= "table" then return nil end
    if type(db.general) == "table" then return db.general end

    if type(db.profileKeys) == "table" and type(db.profiles) == "table" then
        local name = UnitName("player")
        local realm = GetRealmName()
        local fullKey = name and realm and (name .. " - " .. realm) or nil
        local profileName = (fullKey and db.profileKeys[fullKey]) or (name and db.profileKeys[name]) or nil
        local profile = profileName and db.profiles[profileName]
        if type(profile) == "table" and type(profile.general) == "table" then
            return profile.general
        end

        for _, p in pairs(db.profiles) do
            if type(p) == "table" and type(p.general) == "table" then
                return p.general
            end
        end
    end

    return nil
end

function Support_RareScanner.PlaceWaypointAtSession()
    MapPin.NewUserNavigation(SessionWaypointInfo.name, SessionWaypointInfo.mapID, SessionWaypointInfo.x, SessionWaypointInfo.y, "RareScanner_Waypoint")
end

function Support_RareScanner.NotifyTomTom()
    Support_TomTom.IgnoreWaypoint(SessionWaypointInfo.mapID, SessionWaypointInfo.x, SessionWaypointInfo.y)
end

function Support_RareScanner.DisableRareScannerIngameWaypointSupport()
    if RareScannerWaypointSupportOverride.active then return end

    local RSConfigDB = _G.RSConfigDB
    if type(RSConfigDB) == "table" and type(RSConfigDB.IsWaypointsSupportEnabled) == "function" and type(RSConfigDB.SetWaypointsSupportEnabled) == "function" then
        RareScannerWaypointSupportOverride.original = RSConfigDB.IsWaypointsSupportEnabled() == true
        RSConfigDB.SetWaypointsSupportEnabled(false)
        RareScannerWaypointSupportOverride.active = true
        RareScannerWaypointSupportOverride.mode = "api"
        RareScannerWaypointSupportOverride.node = nil
        return
    end

    local general = GetRareScannerGeneralConfigNode()
    if general and general.enableWaypointsSupport ~= nil then
        RareScannerWaypointSupportOverride.original = general.enableWaypointsSupport == true
        general.enableWaypointsSupport = false
        RareScannerWaypointSupportOverride.active = true
        RareScannerWaypointSupportOverride.mode = "table"
        RareScannerWaypointSupportOverride.node = general
    end
end

function Support_RareScanner.RestoreRareScannerIngameWaypointSupport()
    if not RareScannerWaypointSupportOverride.active then return end

    if RareScannerWaypointSupportOverride.mode == "api" then
        local RSConfigDB = _G.RSConfigDB
        if type(RSConfigDB) == "table" and type(RSConfigDB.SetWaypointsSupportEnabled) == "function" then
            RSConfigDB.SetWaypointsSupportEnabled(RareScannerWaypointSupportOverride.original == true)
        end
    elseif RareScannerWaypointSupportOverride.mode == "table" and RareScannerWaypointSupportOverride.node then
        RareScannerWaypointSupportOverride.node.enableWaypointsSupport = RareScannerWaypointSupportOverride.original == true
    end

    RareScannerWaypointSupportOverride.active = false
    RareScannerWaypointSupportOverride.mode = nil
    RareScannerWaypointSupportOverride.original = nil
    RareScannerWaypointSupportOverride.node = nil
end

local function TryPlaceWaypoint(scannerButton, manuallyFired)
    if not IsModuleEnabled() then return end
    if not CaptureWaypointInfo(scannerButton) then return end

    if manuallyFired or Config.DBGlobal:GetVariable("RSAutoReplaceWaypoint") == true then
        Support_RareScanner.PlaceWaypointAtSession()
    end
end

local function OnAddonLoad()
    local scannerButton = _G["RARESCANNER_BUTTON"]

    if IsModuleEnabled() then
        Support_RareScanner.DisableRareScannerIngameWaypointSupport()
    end

    scannerButton:HookScript("PreClick", function(self, button)
        if button == "RightButton" then return end
        if not IsModuleEnabled() then return end
        if not CaptureWaypointInfo(self) then return end

        Support_RareScanner.NotifyTomTom()
    end)

    scannerButton:HookScript("OnMouseUp", function(self, button)
        if button == "RightButton" then return end
        TryPlaceWaypoint(self, true)
    end)

    scannerButton.CloseButton:HookScript("OnClick", function()
        if MapPin.IsUserNavigationFlagged("RareScanner_Waypoint") then
            MapPin.ClearUserNavigation()
        end
    end)

    hooksecurefunc(scannerButton, "ShowButton", function(self)
        TryPlaceWaypoint(self, false)
        Support_RareScanner.NotifyTomTom()
    end)

    local UnloadEvent = CreateFrame("Frame")
    UnloadEvent:RegisterEvent("ADDONS_UNLOADING")
    UnloadEvent:SetScript("OnEvent", function()
        if MapPin.IsUserNavigationFlagged("RareScanner_Waypoint") then
            MapPin.ClearUserNavigation()
        end
        Support_RareScanner.RestoreRareScannerIngameWaypointSupport()
    end)
end

Support.Add("RareScanner", OnAddonLoad)
