---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.WaypointSystem; addon.WaypointSystem = NS

--------------------------------

NS.Prefabs = {}

--------------------------------
-- PREFABS
--------------------------------

function NS.Prefabs:Load()
	do -- GENERAL
		do -- CONTEXT FRAME
			PrefabRegistry:Add("WaypointSystem.General.ContextFrame", function(parent, frameStrata, frameLevel, name)
				local Frame = CreateFrame("Frame", name, parent)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						Frame.Content = CreateFrame("Frame", "$parent.Content", Frame)
						Frame.Content:SetPoint("CENTER", Frame)
						Frame.Content:SetFrameStrata(frameStrata)
						Frame.Content:SetFrameLevel(frameLevel + 1)
						addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

						local Content = Frame.Content

						--------------------------------

						do -- BACKGROUND
							Content.Background = CreateFrame("Frame", "$parent.Background", Content)
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, 0, 0)

							local Background = Content.Background

							--------------------------------

							do -- FOREGROUND
								Background.Foreground, Background.ForegroundTexture = addon.C.FrameTemplates:CreateTexture(Background, frameStrata, NS.Variables.PATH .. "waypoint-context.png", "$parent.Foreground")
								Background.Foreground:SetPoint("CENTER", Background)
								Background.Foreground:SetFrameStrata(frameStrata)
								Background.Foreground:SetFrameLevel(frameLevel + 4)
								addon.C.API.FrameUtil:SetDynamicSize(Background.Foreground, Background, 0, 0)
							end

							do -- BACKGROUND
								Background.Background, Background.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Background, frameStrata, NS.Variables.PATH .. "waypoint-context-background.png", "$parent.Background")
								Background.Background:SetPoint("CENTER", Background)
								Background.Background:SetFrameStrata(frameStrata)
								Background.Background:SetFrameLevel(frameLevel + 3)
								addon.C.API.FrameUtil:SetDynamicSize(Background.Background, Background, -12.5, -12.5)
							end
						end

						do -- MAIN
							Content.Main = CreateFrame("Frame", "$parent.Main", Content)
							Content.Main:SetPoint("CENTER", Content)
							Content.Main:SetFrameStrata(frameStrata)
							Content.Main:SetFrameLevel(frameLevel + 10)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Main, Content, function(relativeWidth, relativeHeight) return relativeHeight * .5 end, function(relativeWidth, relativeHeight) return relativeHeight * .5 end)

							local Main = Content.Main

							--------------------------------

							do -- IMAGE FRAME
								Main.ImageFrame = CreateFrame("Frame", "$parent.ImageFrame", Main)
								Main.ImageFrame:SetPoint("CENTER", Main)
								Main.ImageFrame:SetFrameStrata(frameStrata)
								Main.ImageFrame:SetFrameLevel(frameLevel + 11)
								addon.C.API.FrameUtil:SetDynamicSize(Main.ImageFrame, Main, 0, 0)

								local ImageFrame = Main.ImageFrame

								--------------------------------

								do -- BACKGROUND
									ImageFrame.Background, ImageFrame.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(ImageFrame, frameStrata, nil, "$parent.Background")
									ImageFrame.Background:SetPoint("CENTER", ImageFrame)
									ImageFrame.Background:SetFrameStrata(frameStrata)
									ImageFrame.Background:SetFrameLevel(frameLevel + 12)
									addon.C.API.FrameUtil:SetDynamicSize(ImageFrame.Background, ImageFrame, 0, 0)
								end
							end
						end
					end
				end

				do -- REFERENCES
					-- CORE
					Frame.REF_CONTENT = Frame.Content
					Frame.REF_BACKGROUND = Frame.Content.Background
					Frame.REF_MAIN = Frame.Content.Main

					-- BACKGROUND
					Frame.REF_BACKGROUND_FOREGROUND = Frame.REF_BACKGROUND.Foreground
					Frame.REF_BACKGROUND_FOREGROUND_TEXTURE = Frame.REF_BACKGROUND.ForegroundTexture
					Frame.REF_BACKGROUND_BACKGROUND = Frame.REF_BACKGROUND.Background
					Frame.REF_BACKGROUND_BACKGROUND_TEXTURE = Frame.REF_BACKGROUND.BackgroundTexture

					-- CONTENT
					Frame.REF_MAIN_IMAGE = Frame.REF_MAIN.ImageFrame
					Frame.REF_MAIN_IMAGE_BACKGROUND = Frame.REF_MAIN_IMAGE.Background
					Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE = Frame.REF_MAIN_IMAGE.BackgroundTexture
				end

				do -- ANIMATIONS
					do -- SHOW
						function Frame:ShowWithAnimation_StopEvent()

						end

						function Frame:ShowWithAnimation()

						end
					end

					do -- HIDE
						function Frame:HideWithAnimation_StopEvent()

						end

						function Frame:HideWithAnimation()

						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetImage(texture)
								Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE:SetTexture(texture)
							end

							function Frame:SetAtlas(atlas)
								Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE:SetAtlas(atlas)
							end

							function Frame:Recolor(color)
								Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE:SetDesaturated(true)
								Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE:SetVertexColor(color.r, color.g, color.b, color.a)
							end

							function Frame:Decolor()
								Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE:SetDesaturated(false)
								Frame.REF_MAIN_IMAGE_BACKGROUND_TEXTURE:SetVertexColor(1, 1, 1, 1)
							end

							function Frame:SetTint(color)
								Frame.REF_BACKGROUND_FOREGROUND_TEXTURE:SetVertexColor(color.r, color.g, color.b, color.a)
								Frame.REF_BACKGROUND_BACKGROUND_TEXTURE:SetVertexColor(color.r, color.g, color.b, color.a)
							end

							function Frame:SetInfo(image, tintColor, opacity)
								if image.type == "ATLAS" then
									Frame:SetAtlas(image.path)
								else
									Frame:SetImage(image.path)
								end

								--------------------------------

								Frame:SetTint(tintColor)
								if image.recolor then Frame:Recolor(tintColor) else Frame:Decolor() end
								if opacity then Frame.Content:SetAlpha(opacity) else Frame.Content:SetAlpha(1) end
							end
						end

						do -- LOGIC

						end
					end

					do -- EVENTS

					end
				end

				do -- SETUP

				end

				--------------------------------

				return Frame
			end)
		end
	end

	do -- PINPOINT
		do -- ARROW
			PrefabRegistry:Add("WaypointSystem.Pinpoint.ArrowFrame", function(parent, frameStrata, frameLevel, data, name)
				local size, offset = data.size, data.offset

				--------------------------------

				local Frame = CreateFrame("Frame", name, parent)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						Frame.Content = CreateFrame("Frame", "$parent.Content", Frame)
						Frame.Content:SetPoint("CENTER", Frame)
						Frame.Content:SetFrameStrata(frameStrata)
						Frame.Content:SetFrameLevel(frameLevel + 1)
						addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

						local Content = Frame.Content

						--------------------------------

						do -- LAYOUT GROUP
							Content.LayoutGroup, Content.LayoutGroup_Sort = addon.C.FrameTemplates:CreateLayoutGroup(Content, { point = "TOP", direction = "vertical", resize = false, padding = offset, distribute = false, distributeResizeElements = false, excludeHidden = true, autoSort = true, customOffset = nil, customLayoutSort = nil }, "$parent.LayoutGroup")
							Content.LayoutGroup:SetPoint("CENTER", Content)
							Content.LayoutGroup:SetFrameStrata(frameStrata)
							Content.LayoutGroup:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.LayoutGroup, Content, 0, 0)
							Frame.LGS_Content = Content.LayoutGroup_Sort

							local LayoutGroup = Content.LayoutGroup

							--------------------------------

							do -- ELEMENTS
								local function CreateArrow(name)
									local Arrow = PrefabRegistry:Create("WaypointSystem.Pinpoint.ArrowFrame.Element", Content, frameStrata, frameLevel + 3, name)
									Arrow:SetSize(size, size)
									Arrow:SetFrameStrata(frameStrata)
									Arrow:SetFrameLevel(frameLevel + 3)

									--------------------------------

									return Arrow
								end

								for i = 1, 3 do
									local Arrow = CreateArrow("$parent." .. "Arrow" .. i)
									LayoutGroup["Arrow" .. i] = Arrow

									--------------------------------

									LayoutGroup:AddElement(Arrow)
								end
							end
						end
					end
				end

				do -- ANIMATIONS
					do -- PLAYBACK
						local PlaybackSession = {
							["playbackID"] = nil,
							["loopTimer"] = nil
						}

						function Frame:Animation_Playback_Start_StopEvent()

						end

						function Frame:Animation_Playback_Start()
							PlaybackSession.playbackID = addon.C.API.Util:gen_hash()

							--------------------------------

							if PlaybackSession.loopTimer then
								PlaybackSession.loopTimer:Cancel()
							end

							for i = 1, #Frame.Elements do
								Frame.Elements[i]:Animation_Playback_Pre()
							end

							Frame:Animation_Playback_Cycle()
							PlaybackSession.loopTimer = C_Timer.NewTicker(1.5, function()
								Frame:Animation_Playback_Cycle()
							end, nil)
						end

						function Frame:Animation_Playback_Stop_StopEvent()

						end

						function Frame:Animation_Playback_Stop()

						end

						function Frame:Animation_Playback_Cycle()
							for i = 1, #Frame.Elements do
								addon.C.Libraries.AceTimer:ScheduleTimer(function() Frame.Elements[i]:Animation_Playback(PlaybackSession.playbackID) end, i * .125)
							end
						end
					end
				end

				do -- LOGIC
					Frame.Elements = {
						[1] = Frame.Content.LayoutGroup.Arrow1,
						[2] = Frame.Content.LayoutGroup.Arrow2,
						[3] = Frame.Content.LayoutGroup.Arrow3
					}

					--------------------------------

					do -- FUNCTIONS
						do -- SET
							function Frame:SetTint(tintColor)
								for i = 1, #Frame.Elements do
									Frame.Elements[i]:SetTint(tintColor)
								end
							end
						end

						do -- LOGIC

						end
					end

					do -- EVENTS

					end
				end

				--------------------------------

				return Frame
			end)

			PrefabRegistry:Add("WaypointSystem.Pinpoint.ArrowFrame.Element", function(parent, frameStrata, frameLevel, name)
				local Frame = CreateFrame("Frame", name, parent)
				Frame:SetFrameStrata(frameStrata)
				Frame:SetFrameLevel(frameLevel)

				--------------------------------

				do -- ELEMENTS
					do -- CONTENT
						Frame.Content = CreateFrame("Frame", "$parent.Content", Frame)
						Frame.Content:SetPoint("CENTER", Frame)
						Frame.Content:SetFrameStrata(frameStrata)
						Frame.Content:SetFrameLevel(frameLevel + 1)
						addon.C.API.FrameUtil:SetDynamicSize(Frame.Content, Frame, 0, 0)

						local Content = Frame.Content

						--------------------------------

						do -- BACKGROUND
							Content.Background, Content.BackgroundTexture = addon.C.FrameTemplates:CreateTexture(Content, frameStrata, NS.Variables.PATH .. "pinpoint-arrow.png", "$parent.Background")
							Content.Background:SetPoint("CENTER", Content)
							Content.Background:SetFrameStrata(frameStrata)
							Content.Background:SetFrameLevel(frameLevel + 2)
							addon.C.API.FrameUtil:SetDynamicSize(Content.Background, Content, 0, 0)
						end
					end
				end

				do -- ANIMATIONS
					do -- PLAYBACK
						function Frame:Animation_Playback_StopEvent()
							return not Frame:IsShown()
						end

						function Frame:Animation_Playback()
							do -- START
								addon.C.Animation:Alpha({ ["frame"] = Frame.Content, ["duration"] = 1, ["from"] = 0, ["to"] = 1, ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.Animation_Playback_StopEvent })
								addon.C.Animation:Translate({ ["frame"] = Frame.Content, ["duration"] = 2, ["from"] = 7.5, ["to"] = -7.5, ["axis"] = "y", ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.Animation_Playback_StopEvent })
							end

							do -- END
								addon.C.Libraries.AceTimer:ScheduleTimer(function()
									if not Frame:Animation_Playback_StopEvent() then
										addon.C.Animation:Alpha({ ["frame"] = Frame.Content, ["duration"] = 1, ["from"] = Frame.Content:GetAlpha(), ["to"] = 0, ["ease"] = "EaseExpo_Out", ["stopEvent"] = Frame.Animation_Playback_StopEvent })
									end
								end, .375)
							end
						end

						function Frame:Animation_Playback_Pre()
							addon.C.Animation:CancelAll(Frame.Content)

							--------------------------------

							Frame.Content:SetAlpha(0)
							Frame.Content:SetPoint("CENTER", Frame, "CENTER", 0, 15)
						end
					end
				end

				do -- LOGIC
					do -- FUNCTIONS
						do -- SET
							function Frame:SetTint(tintColor)
								Frame.Content.BackgroundTexture:SetVertexColor(tintColor.r, tintColor.g, tintColor.b, tintColor.a)
							end
						end

						do -- LOGIC

						end
					end

					do -- EVENTS

					end
				end

				do -- SETUP

				end

				--------------------------------

				return Frame
			end)
		end
	end
end
