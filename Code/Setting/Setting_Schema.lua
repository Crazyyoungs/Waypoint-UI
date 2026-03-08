--[[
    widgetName:                         string
    widgetDecsription:                  Setting_Define.Descriptor
    widgetType:                         Setting_Enum.WidgetType
    widgetTransparent:                  boolean

    Shared:
        key:                            string
        set:                            function

    Tab:
        widgetTab_isFooter:             boolean

    Title:
        widgetTitle_info:               Setting_Define.TitleInfo

    Container:
        widgetContainer_isNested:       boolean

    Text:

    Range:
        widgetRange_min:                number|function
        widgetRange_max:                number|function
        widgetRange_step:               number|function
        widgetRange_textFormatting      string (%s: value)
        widgetRange_textFormattingFunc: function

    Button:
        widgetButton_text:              string
        widgetButton_refreshOnClick:    boolean

    CheckButton:

    SelectionMenu:
        widgetSelectionMenu_data:       table|function
        widgetSelectionMenu_get:        function
        widgetSelectionMenu_set:        function

    Color Input:

    Input:
        widgetInput_placeholder:        string|function

    disableWhen:                        function
    showWhen:                           function
    indent:                             number
    children:                           table
]]

local env = select(2, ...)
local Config = env.Config
local L = env.L
local Path = env.WPM:Import("wpm_modules\\path")
local Sound = env.WPM:Import("wpm_modules\\sound")
local UIFont = env.WPM:Import("wpm_modules\\ui-font")
local SharedUtil = env.WPM:Import("@\\SharedUtil")
local Waypoint_Enum = env.WPM:Import("@\\Waypoint\\Enum")
local Setting_Define = env.WPM:Import("@\\Setting\\Define")
local Setting_Enum = env.WPM:Import("@\\Setting\\Enum")
local Setting_Preload = env.WPM:Import("@\\Setting\\Preload")
local Setting_Schema = env.WPM:New("@\\Setting\\Schema")

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local SETTING_PROMPT = _G[Setting_Preload.FRAME_NAME].Prompt

local function HandleAccept()
    Config.DBGlobal:Wipe()
    ReloadUI()
end

local RESET_SETTING_PROMPT_INFO = {
    text         = L["CONFIG_GENERAL_OTHER_RESETPROMPT"],
    options      = {
        {
            text     = L["CONFIG_GENERAL_OTHER_RESETPROMPT_YES"],
            callback = HandleAccept
        },
        {
            text     = L["CONFIG_GENERAL_OTHER_RESETPROMPT_NO"],
            callback = nil
        }
    },
    hideOnEscape = true,
    timeout      = 10
}

do -- Schema
    local function AlwaysTrue() return true end
    local function AlwaysFalse() return false end
    local function CalculateDistance(yds) return function() return SharedUtil:CalculateDistance(yds) end end
    local function FormatDistance(value) return SharedUtil:FormatDistance(value) end
    local function FormatPercentage(value) return string.format("%0.0f", value * 100) .. "%" end
    local function GetIcon(name) return Path.Root .. "\\Art\\Setting\\Icon\\" .. name .. ".png" end

    Setting_Schema.SCHEMA = {
        {
            widgetName = L["CONFIG_GENERAL"],
            widgetType = Setting_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName       = L["CONFIG_GENERAL_TITLE"],
                    widgetType       = Setting_Enum.WidgetType.Title,
                    widgetTitle_info = Setting_Define.TitleInfo{ imagePath = GetIcon("Cog"), text = L["CONFIG_GENERAL_TITLE"], subtext = L["CONFIG_GENERAL_TITLE_SUBTEXT"] }
                },
                {
                    widgetName = L["CONFIG_GENERAL_PREFERENCES"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName               = L["CONFIG_GENERAL_PREFERENCES_FONT"],
                            widgetType               = Setting_Enum.WidgetType.SelectionMenu,
                            widgetSelectionMenu_data = function()
                                UIFont.CustomFont:RefreshFontList()
                                return UIFont.CustomFont:GetFontNames()
                            end,
                            widgetSelectionMenu_get  = function(value)
                                return UIFont.CustomFont.GetFontIndexForPath(value)
                            end,
                            widgetSelectionMenu_set  = function(index)
                                return UIFont.CustomFont.GetFontPathForIndex(index)
                            end,
                            key                      = "fontPath"
                        },
                        {
                            widgetName        = L["CONFIG_GENERAL_PREFERENCES_METER"],
                            widgetDescription = Setting_Define.Descriptor{ imageType = nil, imagePath = nil, description = L["CONFIG_GENERAL_PREFERENCES_METER_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "PrefMetric"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_GENERAL_OTHER"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName        = nil,
                            widgetType        = Setting_Enum.WidgetType.Button,
                            widgetButton_text = L["CONFIG_GENERAL_OTHER_RESETBUTTON"],
                            set               = function() SETTING_PROMPT:Open(RESET_SETTING_PROMPT_INFO) end
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_WAYPOINTSYSTEM"],
            widgetType = Setting_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName       = L["CONFIG_WAYPOINTSYSTEM_TITLE"],
                    widgetType       = Setting_Enum.WidgetType.Title,
                    widgetTitle_info = Setting_Define.TitleInfo{ imagePath = GetIcon("Waypoint"), text = L["CONFIG_WAYPOINTSYSTEM_TITLE"], subtext = L["CONFIG_WAYPOINTSYSTEM_TITLE_SUBTEXT"] }
                },
                {

                    widgetType               = Setting_Enum.WidgetType.SelectionMenu,
                    widgetTransparent        = true,
                    widgetSelectionMenu_data = {
                        L["CONFIG_WAYPOINTSYSTEM_TYPE_BOTH"],
                        L["CONFIG_WAYPOINTSYSTEM_TYPE_WAYPOINT"],
                        L["CONFIG_WAYPOINTSYSTEM_TYPE_PINPOINT"]
                    },
                    key                      = "WaypointSystemType"
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_GENERAL"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_GENERAL_ALWAYSSHOW"],
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_ALWAYSSHOW_DESCRIPTION"] },
                            key               = "AlwaysShow"
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_GENERAL_RIGHTCLICKTOCLEAR"],
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_RIGHTCLICKTOCLEAR_DESCRIPTION"] },
                            key               = "RightClickToClear"
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_GENERAL_BACKGROUNDPREVIEW"],
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_BACKGROUNDPREVIEW_DESCRIPTION"] },
                            key               = "BackgroundPreview"
                        },
                        {
                            widgetName                     = L["CONFIG_WAYPOINTSYSTEM_GENERAL_TRANSITION_DISTANCE"],
                            widgetDescription              = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_TRANSITION_DISTANCE_DESCRIPTION"] },
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetRange_min                = CalculateDistance(50),
                            widgetRange_max                = CalculateDistance(500),
                            widgetRange_step               = CalculateDistance(5),
                            widgetRange_textFormattingFunc = FormatDistance,
                            key                            = "DistanceThresholdPinpoint",
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end
                        },
                        {
                            widgetName                     = L["CONFIG_WAYPOINTSYSTEM_GENERAL_HIDE_DISTANCE"],
                            widgetDescription              = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_GENERAL_HIDE_DISTANCE_DESCRIPTION"] },
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetRange_min                = CalculateDistance(1),
                            widgetRange_max                = CalculateDistance(100),
                            widgetRange_step               = 1,
                            widgetRange_textFormattingFunc = FormatDistance,
                            key                            = "DistanceThresholdHidden"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_WAYPOINT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Waypoint end,
                    children   = {
                        {
                            widgetName               = L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE"],
                            widgetType               = Setting_Enum.WidgetType.SelectionMenu,
                            widgetSelectionMenu_data = {
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_BOTH"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_DISTANCE"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_ARRIVALTIME"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_DESTINATIONNAME"],
                                L["CONFIG_WAYPOINTSYSTEM_WAYPOINT_FOOTER_TYPE_NONE"]
                            },
                            key                      = "WaypointDistanceTextType"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_PINPOINT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Pinpoint end,
                    children   = {
                        {
                            widgetName = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_INFO"],
                            widgetType = Setting_Enum.WidgetType.CheckButton,
                            key        = "PinpointInfo"
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_INFO_EXTENDED"],
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_INFO_EXTENDED_DESCRIPTION"] },
                            indent            = 1,
                            key               = "PinpointInfoExtended",
                            showWhen          = function() return Config.DBGlobal:GetVariable("PinpointInfo") == true end
                        },
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_SHOWINQUESTAREA"],
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_PINPOINT_SHOWINQUESTAREA_DESCRIPTION"] },
                            key               = "PinpointAllowInQuestArea"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_WAYPOINTSYSTEM_NAVIGATOR"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName        = L["CONFIG_WAYPOINTSYSTEM_NAVIGATOR_ENABLE"],
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_WAYPOINTSYSTEM_NAVIGATOR_ENABLE_DESCRIPTION"] },
                            indent            = 0,
                            key               = "NavigatorShow"
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_APPEARANCE"],
            widgetType = Setting_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName       = L["CONFIG_APPEARANCE_TITLE"],
                    widgetType       = Setting_Enum.WidgetType.Title,
                    widgetTitle_info = Setting_Define.TitleInfo{ imagePath = GetIcon("Brush"), text = L["CONFIG_APPEARANCE_TITLE"], subtext = L["CONFIG_APPEARANCE_TITLE_SUBTEXT"] }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_WAYPOINT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Waypoint or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end,
                    children   = {
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_SCALE"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetDescription              = Setting_Define.Descriptor{ description = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_DESCRIPTION"] },
                            widgetRange_min                = 0.5,
                            widgetRange_max                = 5,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointScale"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MIN"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetDescription              = Setting_Define.Descriptor{ description = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MIN_DESCRIPTION"] },
                            widgetRange_min                = 0.125,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.125,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointScaleMin",
                            indent                         = 1
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MAX"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetDescription              = Setting_Define.Descriptor{ description = L["CONFIG_APPEARANCE_WAYPOINT_SCALE_MAX_DESCRIPTION"] },
                            widgetRange_min                = 1,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointScaleMax",
                            indent                         = 1
                        },
                        {
                            widgetName = L["CONFIG_APPEARANCE_WAYPOINT_BEAM"],
                            widgetType = Setting_Enum.WidgetType.CheckButton,
                            key        = "WaypointBeam"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_BEAM_ALPHA"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            showWhen                       = function()
                                return Config.DBGlobal:GetVariable("WaypointBeam") ==
                                    true
                            end,
                            indent                         = 1,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointBeamAlpha"
                        },
                        {
                            widgetName = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER"],
                            widgetType = Setting_Enum.WidgetType.CheckButton,
                            key        = "WaypointDistanceText",
                            showWhen   = function() return Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER_SCALE"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                            indent                         = 1,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointDistanceTextScale"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER_ALPHA"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                            indent                         = 1,
                            widgetRange_min                = 0,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointDistanceTextAlpha"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_WAYPOINT_FOOTER_SUBTEXTALPHA"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            showWhen                       = function() return Config.DBGlobal:GetVariable("WaypointDistanceText") == true and Config.DBGlobal:GetVariable("waypointwaypointDistanceTextType") ~= Waypoint_Enum.WaypointDistanceTextType.None end,
                            indent                         = 1,
                            widgetRange_min                = 0,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "WaypointDistanceSubtextAlpha"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_PINPOINT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.Pinpoint or Config.DBGlobal:GetVariable("WaypointSystemType") == Waypoint_Enum.WaypointSystemType.All end,
                    children   = {
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_PINPOINT_SCALE"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetRange_min                = 0.5,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "PinpointScale",
                            indent                         = 0
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_NAVIGATOR"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("NavigatorShow") == true end,
                    children   = {
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_NAVIGATOR_SCALE"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            indent                         = 0,
                            widgetRange_min                = 0.5,
                            widgetRange_max                = 2,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "NavigatorScale"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_NAVIGATOR_ALPHA"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 1,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "NavigatorAlpha"
                        },
                        {
                            widgetName                     = L["CONFIG_APPEARANCE_NAVIGATOR_DISTANCE"],
                            widgetType                     = Setting_Enum.WidgetType.Range,
                            widgetRange_min                = 0.1,
                            widgetRange_max                = 3,
                            widgetRange_step               = 0.1,
                            widgetRange_textFormattingFunc = FormatPercentage,
                            key                            = "NavigatorDistance"
                        },
                        {
                            widgetName        = L["CONFIG_APPEARANCE_NAVIGATOR_DYNAMICDISTANCE"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_APPEARANCE_NAVIGATOR_DYNAMICDISTANCE_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "NavigatorDynamicDistance"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_APPEARANCE_COLOR"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    children   = {
                        {
                            widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR"],
                            widgetType = Setting_Enum.WidgetType.CheckButton,
                            key        = "CustomColor"
                        },
                        {
                            widgetName               = L
                                ["Config - Appearance - Color - CustomColor - Quest - Complete - Default"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Setting_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestComplete"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Setting_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestCompleteTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestComplete")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L
                                ["Config - Appearance - Color - CustomColor - Quest - Complete - Repeatable"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Setting_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestCompleteRepeatable"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Setting_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestCompleteRepeatableTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteRepeatable")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteRepeatableTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L
                                ["Config - Appearance - Color - CustomColor - Quest - Complete - Important"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Setting_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestCompleteImportant"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Setting_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestCompleteImportantTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteImportant")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestCompleteImportantTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_QUEST_INCOMPLETE"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Setting_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorQuestIncomplete"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Setting_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorQuestIncompleteTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorQuestIncomplete")
                                        Config.DBGlobal:ResetVariable("CustomColorQuestIncompleteTint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_OTHER"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("CustomColor") == true end,
                            children                 = {
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_COLOR"],
                                    widgetType = Setting_Enum.WidgetType.ColorInput,
                                    key        = "CustomColorOther"
                                },
                                {
                                    widgetName = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_TINTICON"],
                                    widgetType = Setting_Enum.WidgetType.CheckButton,
                                    key        = "CustomColorOtherTint",
                                    indent     = 1
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_APPEARANCE_COLOR_CUSTOMCOLOR_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable("CustomColorOther")
                                        Config.DBGlobal:ResetVariable("CustomColorOtherTint")
                                    end
                                }
                            }
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_AUDIO"],
            widgetType = Setting_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName       = L["CONFIG_AUDIO_TITLE"],
                    widgetType       = Setting_Enum.WidgetType.Title,
                    widgetTitle_info = Setting_Define.TitleInfo{ imagePath = GetIcon("SpeakerOn"), text = L["CONFIG_AUDIO_TITLE"], subtext = L["CONFIG_AUDIO_TITLE_SUBTEXT"] }
                },
                {
                    widgetName = L["CONFIG_AUDIO_GENERAL"],
                    widgetType = Setting_Enum.WidgetType.Container,

                    children   = {
                        {
                            widgetName = L["CONFIG_AUDIO_GENERAL_ENABLEGLOBALAUDIO"],
                            widgetType = Setting_Enum.WidgetType.CheckButton,
                            key        = "AudioGlobal"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_AUDIO_CUSTOMIZE"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return Config.DBGlobal:GetVariable("AudioGlobal") == true end,
                    children   = {
                        {
                            widgetName = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO"],
                            widgetType = Setting_Enum.WidgetType.CheckButton,
                            key        = "AudioCustom"
                        },
                        {
                            widgetName               = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_WAYPOINTSHOW"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                            children                 = {
                                {
                                    widgetName              = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_SOUND_ID"],
                                    widgetType              = Setting_Enum.WidgetType.Input,
                                    widgetInput_placeholder = L
                                        ["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"],
                                    key                     = "AudioCustomShowWaypoint",
                                    set                     = function(_, value)
                                        if tonumber(value) then
                                            Config.DBGlobal:SetVariable("AudioCustomShowWaypoint", tonumber(value))
                                        else
                                            Config.DBGlobal:SetVariable("AudioCustomShowWaypoint", "")
                                        end
                                    end
                                },
                                {
                                    widgetType        = Setting_Enum.WidgetType.Button,
                                    widgetButton_text = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PREVIEW"],
                                    set               = function()
                                        Sound.PlaySound("Preview",
                                            Config.DBGlobal:GetVariable("AudioCustomShowWaypoint"))
                                    end
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable(
                                            "AudioCustomShowWaypoint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PINPOINTSHOW"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                            children                 = {
                                {
                                    widgetName              = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_SOUND_ID"],
                                    widgetType              = Setting_Enum.WidgetType.Input,
                                    widgetInput_placeholder = L
                                        ["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"],
                                    key                     = "AudioCustomShowPinpoint",
                                    set                     = function(_, value)
                                        if tonumber(value) then
                                            Config.DBGlobal:SetVariable("AudioCustomShowPinpoint", tonumber(value))
                                        else
                                            Config.DBGlobal:SetVariable("AudioCustomShowPinpoint", "")
                                        end
                                    end
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PREVIEW"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Sound.PlaySound("Preview",
                                            Config.DBGlobal:GetVariable("AudioCustomShowPinpoint"))
                                    end
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable(
                                            "AudioCustomShowPinpoint")
                                    end
                                }
                            }
                        },
                        {
                            widgetName               = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_NEWUSERNAVIGATION"],
                            widgetType               = Setting_Enum.WidgetType.Container,
                            widgetContainer_isNested = true,
                            showWhen                 = function() return Config.DBGlobal:GetVariable("AudioCustom") == true end,
                            children                 = {
                                {
                                    widgetName              = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_SOUND_ID"],
                                    widgetType              = Setting_Enum.WidgetType.Input,
                                    widgetInput_placeholder = L
                                        ["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"],
                                    key                     = "AudioCustomNewUserNavigation",
                                    set                     = function(_, value)
                                        if tonumber(value) then
                                            Config.DBGlobal:SetVariable("AudioCustomNewUserNavigation", tonumber(value))
                                        else
                                            Config.DBGlobal:SetVariable("AudioCustomNewUserNavigation", "")
                                        end
                                    end
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_PREVIEW"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Sound.PlaySound("Preview",
                                            Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation"))
                                    end
                                },
                                {
                                    widgetType                  = Setting_Enum.WidgetType.Button,
                                    widgetButton_text           = L["CONFIG_AUDIO_CUSTOMIZE_USECUSTOMAUDIO_RESET"],
                                    widgetButton_refreshOnClick = true,
                                    set                         = function()
                                        Config.DBGlobal:ResetVariable(
                                            "AudioCustomNewUserNavigation")
                                    end
                                }
                            }
                        }
                    }
                }
            }
        },
        {
            widgetName = L["CONFIG_EXTRAFEATURE"],
            widgetType = Setting_Enum.WidgetType.Tab,
            children   = {
                {
                    widgetName       = L["CONFIG_EXTRAFEATURE_TITLE"],
                    widgetType       = Setting_Enum.WidgetType.Title,
                    widgetTitle_info = Setting_Define.TitleInfo{ imagePath = GetIcon("List"), text = L["CONFIG_EXTRAFEATURE_TITLE"], subtext = L["CONFIG_EXTRAFEATURE_TITLE_SUBTEXT"] }
                },
                {
                    widgetName = L["CONFIG_EXTRAFEATURE_PIN"],
                    widgetType = Setting_Enum.WidgetType.Container,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_PIN_AUTOTRACKPLACEDPIN"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_PIN_AUTOTRACKPLACEDPIN_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "AutoTrackPlacedPinEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_PIN_AUTOTRACKCHATLINKPIN"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_PIN_AUTOTRACKCHATLINKPIN_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "AutoTrackChatLinkPinEnabled",
                            showWhen          = function() return Config.DBGlobal:GetVariable("AutoTrackPlacedPinEnabled") == false end,
                            indent            = 1
                        },
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_PIN_GUIDEPINASSISTANT"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_PIN_GUIDEPINASSISTANT_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "GuidePinAssistantEnabled"
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTRAFEATURE_TOMTOMSUPPORT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("TomTom") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_TOMTOMSUPPORT_ENABLE"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_TOMTOMSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "TomTomSupportEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_TOMTOMSUPPORT_AUTOREPLACEWAYPOINT"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_TOMTOMSUPPORT_AUTOREPLACEWAYPOINT_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "TomTomAutoReplaceWaypoint",
                            showWhen          = function() return Config.DBGlobal:GetVariable("TomTomSupportEnabled") == true end,
                            indent            = 1
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTRAFEATURE_DUGISSUPPORT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("DugisGuideViewerZ") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_DUGISSUPPORT_ENABLE"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_DUGISSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "DugisSupportEnabled"
                        },
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_DUGISSUPPORT_AUTOREPLACEWAYPOINT"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_DUGISSUPPORT_AUTOREPLACEWAYPOINT_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "DugisAutoReplaceWaypoint",
                            showWhen          = function() return Config.DBGlobal:GetVariable("DugisSupportEnabled") == true end,
                            indent            = 1
                        }
                    }
                },
                {
                    widgetName = L["CONFIG_EXTRAFEATURE_SILVERDRAGONSUPPORT"],
                    widgetType = Setting_Enum.WidgetType.Container,
                    showWhen   = function() return IsAddOnLoaded("SilverDragon") end,

                    children   = {
                        {
                            widgetName        = L["CONFIG_EXTRAFEATURE_SILVERDRAGONSUPPORT_ENABLE"],
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONFIG_EXTRAFEATURE_SILVERDRAGONSUPPORT_ENABLE_DESCRIPTION"] },
                            widgetType        = Setting_Enum.WidgetType.CheckButton,
                            key               = "SilverDragonSupportEnabled"
                        }
                    }
                }
            }
        },
        {
            widgetName         = L["CONFIG_ABOUT"],
            widgetType         = Setting_Enum.WidgetType.Tab,
            widgetTab_isFooter = true,
            children           = {
                {
                    widgetName       = L["CONFIG_ABOUT"],
                    widgetType       = Setting_Enum.WidgetType.Title,
                    widgetTitle_info = Setting_Define.TitleInfo{ imagePath = env.ICON_ALT, text = env.NAME, subtext = env.VERSION_STRING }
                },
                {
                    widgetName        = L["CONFIG_ABOUT_CONTRIBUTORS"],
                    widgetType        = Setting_Enum.WidgetType.Container,
                    widgetTransparent = true,
                    children          = {
                        {
                            widgetName        = L["CONTRIBUTORS_ZAMESTOTV"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_ZAMESTOTV_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_HUCHANG47"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_HUCHANG47_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_BLUENIGHTSKY"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_BLUENIGHTSKY_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_CRAZYYOUNGS"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_CRAZYYOUNGS_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_KLEP"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_KLEP_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_KROFFY"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_KROFFY_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_CATHTAIL"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_CATHTAIL_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_LARSJ02"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_LARSJ02_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_DABEAR78"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_DABEAR78_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_GOTZIKO"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_GOTZIKO_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_Y45853160"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_Y45853160_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_LEMIESZEK"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_LEMIESZEK_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_BADBOYBARNY"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_BADBOYBARNY_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_CHRISTINXA"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_CHRISTINXA_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_HECTORZAGA"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_HECTORZAGA_DESCRIPTION"] },
                            widgetTransparent = true
                        },
                        {
                            widgetName        = L["CONTRIBUTORS_SYVERGISWOLD"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetDescription = Setting_Define.Descriptor{ description = L["CONTRIBUTORS_SYVERGISWOLD_DESCRIPTION"] },
                            widgetTransparent = true
                        }
                    }
                },
                {
                    widgetName        = L["CONFIG_ABOUT_DEVELOPER"],
                    widgetType        = Setting_Enum.WidgetType.Container,
                    widgetTransparent = true,
                    children          = {
                        {
                            widgetName        = L["CONFIG_ABOUT_DEVELOPER_ADAPTIVEX"],
                            widgetType        = Setting_Enum.WidgetType.Text,
                            widgetTransparent = true
                        }
                    }
                }
            }
        }
    }
end
