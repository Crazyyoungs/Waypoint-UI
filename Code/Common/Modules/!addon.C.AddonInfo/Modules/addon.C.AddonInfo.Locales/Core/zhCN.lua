-- ♡ Translation // huchang47

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.zhCN = {}
local NS = L.zhCN; L.zhCN = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "zhCN" then
		return
	end

	--------------------------------
	-- GENERAL
	--------------------------------

	do

	end

	--------------------------------
	-- WAYPOINT SYSTEM
	--------------------------------

	do
		-- PINPOINT
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "可交任务"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "当前地图ID: "
		L["SlashCommand - /way - Map ID - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (X) - Prefix"] = "X: "
		L["SlashCommand - /way - Position - Axis (X) - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (Y) - Prefix"] = ", Y: "
		L["SlashCommand - /way - Position - Axis (Y) - Suffix"] = ""
	end

	--------------------------------
	-- CONFIG
	--------------------------------

	do
		L["Config - General"] = "通用"
		L["Config - General - Title"] = "通用"
		L["Config - General - Title - Subtext"] = "自定义全局的设置。"
		L["Config - General - Preferences"] = "偏好设置"
		L["Config - General - Preferences - Meter"] = "单位使用米，而不是码"
		L["Config - General - Preferences - Meter - Description"] = "将测量单位更改为公制。"
		L["Config - General - Reset"] = "重置"
		L["Config - General - Reset - Button"] = "重置为默认设置"
		L["Config - General - Reset - Confirm"] = "您确定要重置所有设置吗？"
		L["Config - General - Reset - Confirm - Yes"] = "确定"
		L["Config - General - Reset - Confirm - No"] = "取消"

		L["Config - WaypointSystem"] = "路径点"
		L["Config - WaypointSystem - Title"] = "路径点"
		L["Config - WaypointSystem - Title - Subtext"] = "管理在世界状态时，任务目标点的行为。"
		L["Config - WaypointSystem - Type"] = "启用"
		L["Config - WaypointSystem - Type - Both"] = "所有"
		L["Config - WaypointSystem - Type - Waypoint"] = "路径点"
		L["Config - WaypointSystem - Type - Pinpoint"] = "标记点"
		L["Config - WaypointSystem - General"] = "通用"
		L["Config - WaypointSystem - General - Transition Distance"] = "标记点距离"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "标记点显示的最大距离。"
		L["Config - WaypointSystem - General - Hide Distance"] = "最小距离"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "超出距离后隐藏路径点和标记点。"
		L["Config - WaypointSystem - Waypoint"] = "路径点"
		L["Config - WaypointSystem - WaypointFooterType"] = "额外信息"
		L["Config - WaypointSystem - WaypointFooterType - Both"] = "所有"
		L["Config - WaypointSystem - WaypointFooterType - Distance"] = "距离"
		L["Config - WaypointSystem - WaypointFooterType - ETA"] = "抵达时间"
		L["Config - WaypointSystem - WaypointFooterType - None"] = "无"
		L["Config - WaypointSystem - WaypointFooterOpacity"] = "透明度"
		L["Config - WaypointSystem - WaypointScale"] = "路径点大小"
		L["Config - WaypointSystem - WaypointScale - Description"] = "路径点的大小会跟随距离变化。此选项用于调整整体大小。"
		L["Config - WaypointSystem - WaypointMinScale"] = "最小%"
		L["Config - WaypointSystem - WaypointMinScale - Description"] = "可缩小到的最小百分比。"
		L["Config - WaypointSystem - WaypointMaxScale"] = "最大%"
		L["Config - WaypointSystem - WaypointMaxScale - Description"] = "可放大到的最大百分比。"
		L["Config - WaypointSystem - Pinpoint"] = "标记点"
		L["Config - WaypointSystem - PinpointScale"] = "标记点大小"
		L["Config - WaypointSystem - PinpointDetail"] = "显示扩展信息"
		L["Config - WaypointSystem - PinpointDetail - Description"] = "包含额外的信息，例如名称/描述。"

		L["Config - Appearance"] = "外观"
		L["Config - Appearance - Title"] = "外观"
		L["Config - Appearance - Title - Subtext"] = "自定义用户界面的外观。"

		L["Config - Audio"] = "音效"
		L["Config - Audio - Title"] = "音效"
		L["Config - Audio - Title - Subtext"] = "管理Waypoint UI的音效选项。"
		L["Config - Audio - General"] = "通用"
		L["Config - Audio - General - EnableGlobalAudio"] = "启用音效"

		L["Config - About"] = "关于"
		L["Config - About - Contributors"] = "贡献者"
		L["Config - About - Developer"] = "开发者"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - ZamestoTV - Description"] = "翻译者 — 俄语"
		L["Contributors - huchang47 - Description"] = "翻译者 — 简体中文"
		L["Contributors - BlueNightSky - Description"] = "翻译者 — 繁体中文"
		L["Contributors - Crazyyoungs - Description"] = "翻译者 — 韩语"
		L["Contributors - y45853160 - Description"] = "编码者 — 修复Bug"
	end
end

NS:Load()
