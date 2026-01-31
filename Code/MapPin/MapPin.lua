local env = select(2, ...)
local Config = env.Config
local Sound = env.WPM:Import("wpm_modules\\sound")
local CallbackRegistry = env.WPM:Import("wpm_modules\\callback-registry")
local MapPin = env.WPM:New("@\\MapPin")

local SetSuperTrackedUserWaypoint = C_SuperTrack.SetSuperTrackedUserWaypoint
local IsSuperTrackingAnything = C_SuperTrack.IsSuperTrackingAnything
local ClearAllSuperTracked = C_SuperTrack.ClearAllSuperTracked
local GetHighestPrioritySuperTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType
local CanSetUserWaypointOnMap = C_Map.CanSetUserWaypointOnMap
local SetUserWaypoint = C_Map.SetUserWaypoint
local ClearUserWaypoint = C_Map.ClearUserWaypoint
local HasUserWaypoint = C_Map.HasUserWaypoint
local CreateFrame = CreateFrame
local tostring = tostring

local SessionData = {
    name  = nil,
    mapID = nil,
    x     = nil,
    y     = nil,
    flags = nil
}

local function GetUserWaypointPosition()
    local userWaypoint = C_Map.GetUserWaypoint()
    if not userWaypoint then return nil end

    return userWaypoint.uiMapID, userWaypoint.position
end

local function ApplySavedNavigation(saved)
    if not saved then return SessionData end

    SessionData.name = saved.name
    SessionData.mapID = saved.mapID
    SessionData.x = saved.x
    SessionData.y = saved.y
    SessionData.flags = saved.flags

    return SessionData
end

local function PlayUserNavigationAudio()
    local Setting_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.NewUserNavigation

    if Setting_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation")
        end
    end

    Sound.PlaySound("Main", soundID)
end

function MapPin.ClearUserNavigation()
    if MapPin.IsUserNavigation() then ClearUserWaypoint() end
    MapPin.SetUserNavigation()
end

function MapPin.ClearDestination()
    if MapPin.IsUserNavigation() then
        MapPin.ClearUserNavigation()
    end

    if IsSuperTrackingAnything() then
        ClearAllSuperTracked()
    end
end

function MapPin.SetUserNavigation(name, mapID, x, y, flags)
    SessionData.name = name
    SessionData.mapID = mapID
    SessionData.x = x
    SessionData.y = y
    SessionData.flags = flags
    Config.DBLocal:SetVariable("slashWayCache", SessionData)
end

function MapPin.GetUserNavigation()
    local savedWay = Config.DBLocal:GetVariable("slashWayCache")
    local navigation = ApplySavedNavigation(savedWay)
    if not savedWay then
        Config.DBLocal:SetVariable("slashWayCache", navigation)
    end
    return navigation
end

function MapPin.NewUserNavigation(name, mapID, x, y, flags)
    if not mapID or not x or not y then return end
    if not CanSetUserWaypointOnMap(mapID) then return end

    local pos = CreateVector2D(math.min(x, 100) / 100, math.min(y, 100) / 100)
    local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)

    MapPin.SetUserNavigation(name, mapID, pos.x, pos.y, flags)
    SetUserWaypoint(mapPoint)
    SetSuperTrackedUserWaypoint(true)

    CallbackRegistry.Trigger("MapPin.NewUserNavigation")

    PlayUserNavigationAudio()
end

function MapPin.IsUserNavigation()
    if not HasUserWaypoint() then return false end

    local pinTracked = GetHighestPrioritySuperTrackingType() == Enum.SuperTrackingType.UserWaypoint
    local waypointMapID, waypointPos = GetUserWaypointPosition()
    local currentUserNavigationInfo = MapPin.GetUserNavigation()

    if not waypointMapID or not waypointPos then return false end
    if not currentUserNavigationInfo or not currentUserNavigationInfo.mapID or not currentUserNavigationInfo.x or not currentUserNavigationInfo.y then return false end

    local mapIDMatch = tostring(waypointMapID) == tostring(currentUserNavigationInfo.mapID)
    local xMatch = string.format("%0.1f", waypointPos.x * 100) == string.format("%0.1f", currentUserNavigationInfo.x * 100)
    local yMatch = string.format("%0.1f", waypointPos.y * 100) == string.format("%0.1f", currentUserNavigationInfo.y * 100)

    return (pinTracked and mapIDMatch and xMatch and yMatch)
end

function MapPin.IsUserNavigationFlagged(flag)
    local currentUserNavigationInfo = MapPin.GetUserNavigation()
    if MapPin.IsUserNavigation() and currentUserNavigationInfo and currentUserNavigationInfo.flags == flag then
        return true
    end
    return false
end

function MapPin.ToggleSuperTrackedPinDisplay(shown)
    for pin in WorldMapFrame:EnumeratePinsByTemplate("WaypointLocationPinTemplate") do
        pin:SetAlpha(shown and 1 or 0)
        pin:EnableMouse(shown)
    end
end

do --Automatically clear supertracking when the user waypoint is removed
    local f = CreateFrame("Frame")
    f:RegisterEvent("USER_WAYPOINT_UPDATED")
    f:SetScript("OnEvent", function(self, event, ...)
        if not C_Map.HasUserWaypoint() then
            C_SuperTrack.ClearAllSuperTracked()
        end
    end)
end

local function OnAddonLoad()
    MapPin.GetUserNavigation()
    CallbackRegistry.Trigger("MapPin.Ready")
end

CallbackRegistry.Add("Preload.AddonReady", OnAddonLoad)
