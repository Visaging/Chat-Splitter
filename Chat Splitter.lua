script_name("Chat Splitter")
script_author("Visage A.K.A. Ishaan Dunne")

local script_version = 1.79
local script_version_text = '1.79'

require"lib.moonloader"
require"lib.sampfuncs"

local imgui, ffi = require 'mimgui', require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local https = require 'ssl.https'
local dlstatus = require('moonloader').download_status
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/Chat%20Splitter.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/Chat%20Splitter.txt"
local updatelogs_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/update_logs.txt"
local events = require 'samp.events'
local vk = require 'vkeys'

local settings = inicfg.load({
    font = {
        show = false,
        name = 'calibrib.ttf',
        size = 14,
        timestamp = true,
        lines = 12,
    },
    helper = {false,1},
    com = {false,1},
    newbie = {false,1},
    admin = {false,1},
    facr = {false,1},
    facd = {false,1},
    family = {false,1},
    donator = {false,1},
    global = {false,1},
    portable = {false,1},
    news = {false,1},
    pos1={548,792},
    pos2={29,758},
    autoupdate = false,
}, 'ChatSplitter.ini')

local changePos = false
local changePos2 = false
local temppos = {}
local temppos2 = {}
local renderMessages = {}
local renderMessages2 = {}

local _menu, updatelogs = false, false
fontSize = imgui.new.int(tonumber(settings.font.size))
local a = tonumber(settings.font.lines)
chatLinesCount, linesCount = a, imgui.new.int(a)

imgui.OnInitialize(function()
    fonts = {}
	fontsArray = {}
    fontChanged, fontSizeChanged = false, false
    style()

    imgui.GetIO().IniFilename = nil
	imgui.GetStyle().WindowBorderSize = 0
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\'..settings.font.name, fontSize[0], nil, glyph_ranges)

    local search, file = findFirstFile(getFolderPath(0x14) .. '\\*.ttf')
	while file do
		table.insert(fonts, file)
		if file == settings.font.name then fontSelected = imgui.new.int(#fonts - 1) end
		file = findNextFile(search)
	end

	fontsArray = imgui.new['const char*'][#fonts](fonts)
	fontSize[0] = imgui.GetIO().Fonts.ConfigData.Data[0].SizePixels
end)

imgui.OnFrame(function() return _menu and not isGamePaused() end,
function()
    width, height = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(275, 410), imgui.Cond.FirstUseEver)
    imgui.BeginCustomTitle("Chat Splitter | Settings", 30, main_win, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)
        imgui.BeginChild("##69", imgui.ImVec2(265, 365), true)
            imgui.SetCursorPos(imgui.ImVec2(65, 5))
            if imgui.Checkbox("Enable Chat Splitter", new.bool(settings.font.show)) then settings.font.show = not settings.font.show end
            imgui.Separator()
            imgui.SetCursorPos(imgui.ImVec2(5, 35))
            imgui.BeginChild("##1", imgui.ImVec2(255, 100), true)
            imgui.PushItemWidth(100)
                local font = imgui.GetIO().Fonts.Fonts.Data[0]
                imgui.Text("Font: ") imgui.SameLine(105)
                if imgui.Combo(u8'##Font', fontSelected, fontsArray, #fonts) then
                    fontChanged = true
                    settings.font.name = fonts[fontSelected[0] + 1]
                end
                imgui.Text("Font Size: ") imgui.SameLine(105)
                if imgui.SliderInt(u8'##Font size', fontSize, 4, 30) then
                    fontSizeChanged = true
                    settings.font.size = fontSize[0]
                end
                imgui.Text("Number of lines: ") imgui.SameLine(105)
                if imgui.SliderInt(u8'##Number of lines', linesCount, 4, 72) then
                    chatLinesCount = linesCount[0]
                    settings.font.lines = linesCount[0]
                end
                if imgui.Checkbox(u8('Timestamps'), new.bool(settings.font.timestamp)) then settings.font.timestamp = not settings.font.timestamp end
            imgui.EndChild()
            imgui.SetCursorPos(imgui.ImVec2(5, 140))
            imgui.BeginChild("##3", imgui.ImVec2(255, 190), true)
                if imgui.Button(u8' Chat Selection Menu', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('chatselect') end
                if imgui.BeginPopup('chatselect') then
                        imgui.BeginChild("##4", imgui.ImVec2(255, 310), true)
                            imgui.Text("Select which chat to split:")
                            imgui.Separator()
                            imgui.Spacing()
                            imgui.Text("General Chats:")
                            imgui.Spacing()
                            if imgui.Checkbox(u8('Global Chat'), new.bool(settings.global[1])) then settings.global[1] = not settings.global[1] end imgui.cswitch(settings.global, 'global')
                            if imgui.Checkbox(u8('Donator Chat'), new.bool(settings.donator[1])) then settings.donator[1] = not settings.donator[1] end imgui.cswitch(settings.donator, 'donator')
                            if imgui.Checkbox(u8('Portable Radio Chat'), new.bool(settings.portable[1])) then settings.portable[1] = not settings.portable[1] end imgui.cswitch(settings.portable, 'portable')
                            if imgui.Checkbox(u8('News Chat'), new.bool(settings.news[1])) then settings.news[1] = not settings.news[1] end imgui.cswitch(settings.news, 'news')
                            imgui.Spacing()
                            imgui.Separator()
                            imgui.Spacing()
                            imgui.Text("Staff Chats:")
                            imgui.Spacing()
                            if imgui.Checkbox(u8('Community Chat'), new.bool(settings.com[1])) then settings.com[1] = not settings.com[1] end imgui.cswitch(settings.com, 'com')
                            if imgui.Checkbox(u8('Helper Chat'), new.bool(settings.helper[1])) then settings.helper[1] = not settings.helper[1] end imgui.cswitch(settings.helper, 'helper')
                            if imgui.Checkbox(u8('Newbie Chat'), new.bool(settings.newbie[1])) then settings.newbie[1] = not settings.newbie[1] end imgui.cswitch(settings.newbie, 'newbie')
                            if imgui.Checkbox(u8('Admin Chat'), new.bool(settings.admin[1])) then settings.admin[1] = not settings.admin[1] end imgui.cswitch(settings.admin, 'admin')
                            if imgui.IsItemHovered() then imgui.SetTooltip('This includes all admin related chats.') end
                            imgui.Spacing()
                            imgui.Separator()
                            imgui.Spacing()
                            imgui.Text("Faction/Gang Chats:")
                            imgui.Spacing()
                            if imgui.Checkbox(u8('Faction Radio'), new.bool(settings.facr[1])) then settings.facr[1] = not settings.facr[1] end imgui.cswitch(settings.facr, 'facr')
                            if imgui.Checkbox(u8('Department Radio'), new.bool(settings.facd[1])) then settings.facd[1] = not settings.facd[1] end imgui.cswitch(settings.facd, 'facd')
                            if imgui.IsItemHovered() then imgui.SetTooltip('This includes hospital wanted alert(s).') end
                            if imgui.Checkbox(u8('Family Chat'), new.bool(settings.family[1])) then settings.family[1] = not settings.family[1] end imgui.cswitch(settings.family, 'family')
                            save()
                        imgui.EndChild()
                    imgui.EndPopup()
                end
                if imgui.Button(u8'Reposition', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('reposchat') end
                if imgui.BeginPopup('reposchat') then
                    imgui.BeginChild("##6", imgui.ImVec2(255, 65), true)
                        if imgui.Button(u8'Reposition Chat 1', imgui.ImVec2(-1, 25)) then changePos = not changePos sampAddChatMessage('Press {FF0000}'..vk.id_to_name(VK_S)..' {FFFFFF}to save the position.', -1) end
                        if imgui.Button(u8'Reposition Chat 2', imgui.ImVec2(-1, 25)) then changePos2 = not changePos2 sampAddChatMessage('Press {FF0000}'..vk.id_to_name(VK_S)..' {FFFFFF}to save the position.', -1) end
                    imgui.EndChild()
                imgui.EndPopup()
                end
                if imgui.Button(u8'Clear extra chat', imgui.ImVec2(-1, 25)) then renderMessages = {} renderMessages2 = {} end
                if imgui.Button(u8'Update Logs', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('updatelogs') end
                if imgui.BeginPopup('updatelogs') then
                        imgui.BeginChild("##4", imgui.ImVec2(400, 350), true)
                            imgui.SetCursorPos(imgui.ImVec2(85, 5))
                            imgui.Text("Update Logs - Current Version: "..script_version_text)
                            imgui.NewLine()
                            updatelogs_text = updatelogs:match(".+")
                            if updatelogs_text ~= nil then
                                imgui.Text(updatelogs_text)
                            end
                        imgui.EndChild()
                    imgui.EndPopup()
                end
                if imgui.Button(u8'Save Config', imgui.ImVec2(-1, 25)) then save() sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} Config Saved!", script.this.name), -1) end
                if imgui.Button(u8'Update Settings', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('updatemenu') end
                if imgui.BeginPopup('updatemenu') then
                    imgui.BeginChild("##5", imgui.ImVec2(255, 90), true)
                        if imgui.Button(u8'Update', imgui.ImVec2(-1, 25)) then update_script(true, true, false, false) end
                        if imgui.IsItemHovered() then imgui.SetTooltip('This will check for updates, if found will download it.') end
                        if imgui.Button(u8'Force Update', imgui.ImVec2(-1, 25)) then update_script(false, false, true, false) end
                        if imgui.Checkbox(u8('Auto Update'), new.bool(settings.autoupdate)) then settings.autoupdate = not settings.autoupdate end
                    imgui.EndChild()
                imgui.EndPopup()
                end
            imgui.EndChild()
        imgui.Spacing()
        imgui.Separator()
        imgui.SetCursorPos(imgui.ImVec2(30, 345))
        imgui.TextDisabled("Author: Visage A.K.A. Ishaan Dunne")
        imgui.EndChild()
    imgui.End()
end)

local chat = imgui.OnFrame(function() return settings.font.show and not isGamePaused() and not isPauseMenuActive() and sampIsChatVisible() and not sampIsScoreboardOpen() end,
function()
    if fontChanged then
        fontChanged = false
        local glyphRanges = imgui.GetIO().Fonts.Fonts.Data[0].ConfigData.GlyphRanges
        local fontPath = ('%s\\%s'):format(getFolderPath(0x14), fonts[fontSelected[0] + 1])
        imgui.GetIO().Fonts:Clear()
        imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, fontSize[0], nil, glyphRanges)
        imgui.InvalidateFontsTexture()
    end
    if fontSizeChanged then
        fontSizeChanged = false
        local fonts = imgui.GetIO().Fonts.ConfigData
        for i = 0, fonts:size() - 1 do
            fonts.Data[i].SizePixels = fontSize[0]
        end
        imgui.GetIO().Fonts:ClearTexData()
        imgui.InvalidateFontsTexture()
    end
end, function(self)
	imgui.SetNextWindowPos(imgui.ImVec2(changePos and temppos[1] or settings.pos1[1], changePos and temppos[2] or settings.pos1[2]), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(1020, imgui.GetTextLineHeightWithSpacing() * chatLinesCount + 50 + 2), imgui.Cond.FirstUseEver)
	imgui.Begin("splitwindow##1", nil, imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBackground)
    if not sampIsChatInputActive() then
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PopStyleColor()
    elseif sampIsChatInputActive() then
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.00, 0.00, 0.00, 1.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabHovered, imgui.ImVec4(0.41, 0.41, 0.41, 1.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabActive, imgui.ImVec4(0.51, 0.51, 0.51, 1.00))
        imgui.PopStyleColor()
    end
    imgui.BeginChild('##content', imgui.ImVec2(0, imgui.GetTextLineHeightWithSpacing() * chatLinesCount), false, imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoBackground)
        if renderMessages ~= nil then
            for k, v in ipairs(renderMessages) do
                local text = settings.font.timestamp and os.date(v[1].."[%H:%M:%S] ", v[3]) .. v[2] or v[1]..v[2]
                imgui.TextColoredRGB(text)
                if not sampIsChatInputActive() then imgui.SetScrollY(imgui.GetScrollMaxY()) end
            end
        end
    imgui.EndChild()
	imgui.End()
end)

local chat2 = imgui.OnFrame(function() return settings.font.show and (renderMessages2~=nil) and not isGamePaused() and not isPauseMenuActive() and sampIsChatVisible() and not sampIsScoreboardOpen() end,
function()
    if fontChanged then
        fontChanged = false
        local glyphRanges = imgui.GetIO().Fonts.Fonts.Data[0].ConfigData.GlyphRanges
        local fontPath = ('%s\\%s'):format(getFolderPath(0x14), fonts[fontSelected[0] + 1])
        imgui.GetIO().Fonts:Clear()
        imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, fontSize[0], nil, glyphRanges)
        imgui.InvalidateFontsTexture()
    end
    if fontSizeChanged then
        fontSizeChanged = false
        local fonts = imgui.GetIO().Fonts.ConfigData
        for i = 0, fonts:size() - 1 do
            fonts.Data[i].SizePixels = fontSize[0]
        end
        imgui.GetIO().Fonts:ClearTexData()
        imgui.InvalidateFontsTexture()
    end
end, function(self2)
	imgui.SetNextWindowPos(imgui.ImVec2(changePos2 and temppos2[1] or settings.pos2[1], changePos2 and temppos2[2] or settings.pos2[2]), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(1020, imgui.GetTextLineHeightWithSpacing() * chatLinesCount + 50 + 2), imgui.Cond.FirstUseEver)
	imgui.Begin("splitwindow##2", nil, imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBackground)
    if not sampIsChatInputActive() then
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
        imgui.PopStyleColor()
    elseif sampIsChatInputActive() then
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0.12, 0.12, 0.12, 1.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.00, 0.00, 0.00, 1.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabHovered, imgui.ImVec4(0.41, 0.41, 0.41, 1.00))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrabActive, imgui.ImVec4(0.51, 0.51, 0.51, 1.00))
        imgui.PopStyleColor()
    end
    imgui.BeginChild('##content2', imgui.ImVec2(0, imgui.GetTextLineHeightWithSpacing() * chatLinesCount), false, imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoBackground)
        if renderMessages2 ~= nil then
            for k, v in ipairs(renderMessages2) do
                local text = settings.font.timestamp and os.date(v[1].."[%H:%M:%S] ", v[3]) .. v[2] or v[1]..v[2]
                imgui.TextColoredRGB(text)
                if not sampIsChatInputActive() then imgui.SetScrollY(imgui.GetScrollMaxY()) end
            end
        end
    imgui.EndChild()
	imgui.End()
end)
chat.HideCursor = true
chat2.HideCursor = true

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("chatsplit", function() _menu = not _menu end)
    updatelogs = https.request(updatelogs_url)
    if settings.autoupdate then update_script(true, false, false, false) else update_script(false, false, false, true) end
    sampAddChatMessage("{DFBD68}Chat Splitter by {FFFF00}Visage. {FF0000}[/chatsplit].", -1)
    while true do wait(0)
        if changePos then
            _menu = false
            sampToggleCursor(true)
            if isKeyJustPressed(VK_S) then 
                changePos = false
                local x, y = getCursorPos()
                settings.pos1[1] = x
                settings.pos1[2] = y
                sampToggleCursor(false)
                _menu = true
            else 
                temppos[1], temppos[2] = getCursorPos() 
            end
        end
        if changePos2 then
            _menu = false
            sampToggleCursor(true)
            if isKeyJustPressed(VK_S) then 
                changePos2 = false
                local x, y = getCursorPos()
                settings.pos2[1] = x
                settings.pos2[2] = y
                sampToggleCursor(false)
                _menu = true
            else 
                temppos2[1], temppos2[2] = getCursorPos() 
            end
        end
    end
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        save()
    end
end

function imgui.cswitch(n1, n2)
    if n1[1] then
        imgui.SameLine() 
        if imgui.Button((n1[2]==1) and u8'Chat 1##'..n2 or (n1[2]==2) and u8'Chat 2##'..n2, imgui.ImVec2(60, 17)) then 
            if n1[2]==1 then n1[2] = 2 elseif n1[2]==2 then n1[2] = 1 end
        end
    end
end

function renderswitch(chat, clr, msg)
    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
    chatlog:close()
    if chat[2]==1 then table.insert(renderMessages, {"{"..string.sub(bit.tohex(clr), 1, 6).."}",msg, os.time()}) elseif chat[2]==2 then table.insert(renderMessages2, {"{"..string.sub(bit.tohex(clr), 1, 6).."}",msg, os.time()}) end
end

function imgui.CustomButton(name, color, colorHovered, colorActive, size)
    local clr = imgui.Col
    imgui.PushStyleColor(clr.Button, color)
    imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
    imgui.PushStyleColor(clr.ButtonActive, colorActive)
    if not size then size = imgui.ImVec2(0, 0) end
    local result = imgui.Button(name, size)
    imgui.PopStyleColor(3)
    return result
end

function imgui.BeginCustomTitle(title, titleSizeY, var, flags)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
    imgui.Begin(title, var, imgui.WindowFlags.NoTitleBar + (flags or 0))
    imgui.SetCursorPos(imgui.ImVec2(0, 0))
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddRectFilled(p, imgui.ImVec2(p.x + imgui.GetWindowSize().x, p.y + titleSizeY), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.TitleBgActive]), imgui.GetStyle().WindowRounding, 1 + 2)
    imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(title).x / 2, titleSizeY / 2 - imgui.CalcTextSize(title).y / 2))
    imgui.Text(title)
    imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowSize().x - (titleSizeY - 10) - 5, 5))
    imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, imgui.GetStyle().WindowRounding)
    if imgui.Button('X##CLOSEBUTTON.WINDOW.'..title, imgui.ImVec2(titleSizeY - 10, titleSizeY - 10)) then _menu = false end
    imgui.SetCursorPos(imgui.ImVec2(5, titleSizeY + 5))
    imgui.PopStyleVar(3)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5, 5))
end

function join_argb(a, r, g, b) -- by FYP
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function events.onServerMessage(clr, msg)
    --table.insert(renderMessages, {"{"..string.sub(bit.tohex(clr), 1, 6).."}",msg, os.time()})
    if settings.font.show then
        if settings.helper[1] and clr == -1511456854 then if msg:match("*** .*") then renderswitch(settings.helper, clr, msg) return false end end
        if settings.com[1] and clr == 869072810 then if msg:match("** .+Admin.+%:") or msg:match("*** .+Helper.+%:") or msg:match("*** Former Admin") or msg:match("** Helper Manager") or msg:match("** Management") or msg:match("** Asst. Management") or msg:match("** Assistant Management") then renderswitch(settings.com, clr, msg) return false end end
        if settings.newbie[1] and clr == 2108620799 then if msg:match("** .*") then renderswitch(settings.newbie, clr, msg) return false end end
        
        if settings.admin[1] then

            --Admin Chat (/a)
            if clr == -86 then
                if msg:match("* Secret Admin.+%:") then renderswitch(settings.admin, clr, msg) return false end
                if msg:match("* Junior Admin.+%:") then renderswitch(settings.admin, clr, msg) return false end
                if msg:match("* General Admin.+%:") then renderswitch(settings.admin, clr, msg) return false end
                if msg:match("* Senior Admin.+%:") then renderswitch(settings.admin, clr, msg) return false end
                if msg:match("* Head Admin.+%:") then renderswitch(settings.admin, clr, msg) return false end
                if msg:match("* Ast. Management.+%:") then renderswitch(settings.admin, clr, msg) return false end
                if msg:match("* Management.+%:") then renderswitch(settings.admin, clr, msg) return false end
            end

            --Flags & Requests

            if clr == -65366 and (msg:match("Outstanding.+flag%: {FFFFFF}.+%(ID %d+%) %| Reason%:.+%(.+%).") or msg:match("Login notice%: {FFFFFF}.+%(ID %d+%) has previously been reported for .+") or msg:match(".+has denied.+name change request")) then renderswitch(settings.admin, clr, msg) return false end

            -- Reports

            if clr == -5963606 and msg:match("____________________ REPORTS _____________________") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -5963606 and msg:match("___________________________________________________") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -28161 and msg:match(".+%(ID%: %d+%) %| RID%: %d+ %| Report%:.+%| Expires in%: %d+ minutes.") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -28161 and (msg:match("Report from %[%d+%].+%(RID%: %d+%)%:.+") or msg:match("There.+{FF0606}.+pending.+{FFFF91} that.+expiring %- please check /reports and respond.")) then renderswitch(settings.admin, clr, msg) return false end
            if clr == -16382209 and msg:match("A report from.+%(ID %d+%) was not answered after 5 minutes and has expired. Please attend to reports before they expire.") then renderswitch(settings.admin, clr, msg) return false end

            -- AdmCmd & AdmWarning

            if clr == -1439485014 and msg:match("AdmWarning%:.+") then renderswitch(settings.admin, clr, msg) return false end
            if  msg:match("AdmCmd%:.+") and (clr == -8388353 or clr == -10270806) then renderswitch(settings.admin, clr, msg) return false end

            --On-Duty & Off-Duty

            if clr == -86 and msg:match(".+%(ID %d+ %- .+%) is now.+as.+") then renderswitch(settings.admin, clr, msg) return fals
            if clr == -65366 and (msg:match("You are now off%-duty as admin, and only have access to /admins /check /jail /ban /sban /kick /skick /showflags /reports /nrn") or msg:match("You are now on%-duty as admin and have access to all your commands, see /ah.")) then renderswitch(settings.admin, clr, msg) return false end
            if clr == -16382209 and msg:match("Please remember to turn off any hacks you may have.") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -86 and msg:match(".+%(.+%) has logged in as a.+Admin.") then renderswitch(settings.admin, clr, msg) return false end

            --Alerts

            if clr == -86 and msg:match("The player you were spectating has left the server.") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -65366 and msg:match("Checking.+for desync, please wait") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -65366 and msg:match("%[BANK%].+%(IP%:.+%) has transferred.+to.+%(IP%:.+%).") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -65366 and msg:match(".+%(IP%:.+%) has.+%(IP%:.+%).+in this session.") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -65366 and msg:match("%[ATM%].+%(IP%:.+%) has transferred.+to.+%(IP%:.+%).") then renderswitch(settings.admin, clr, msg) return false end
            if clr == -65366 and msg:match("WARNING%: .+%(IP%:.+%) tried to login whilst banned and has been auto%-banned.") then renderswitch(settings.admin, clr, msg) return false end
        end
        if settings.facr[1] and clr == -1920073729 then if msg:match("** ") then renderswitch(settings.facr, clr, msg) return false end end
        if settings.facd[1] and clr == -2686902 then if msg:match("** ") or msg:match(".+has reported.+as a wanted person.") then renderswitch(settings.facd, clr, msg) return false end end
        if settings.portable[1] and clr == 1845194239 then if msg:match("**.Radio %(.+% kHz%).%**.+%:") then renderswitch(settings.portable, clr, msg) return false end end
        if settings.global[1] and clr == -5963606 then if msg:match("%(%(") then renderswitch(settings.global, clr, msg) return false end end
        if settings.family[1] and clr == 33357768 then if msg:match("** ") then renderswitch(settings.family, clr, msg) return false end end
        if settings.donator[1] and clr == -1210979584 then if msg:match("%(%(") then renderswitch(settings.donator, clr, msg) return false end end
        if settings.news[1] and clr == -1697828182 then if msg:match("NR .+%:") or msg:match("Live News Reporter .+%:") or msg:match("Live Interview Guest .+%:") then renderswitch(settings.news, clr, msg) return false end end
    end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col
    
    local designText = function(text__)
        local pos = imgui.GetCursorPos()
        if sampGetChatDisplayMode() == 2 then
            for i = 1, 1 do
                imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
            end
        end
        imgui.SetCursorPos(pos)
    end
    
    local text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

    local color = colors[col.Text]
    local start = 1
    local a, b = text:find('{........}', start)   
    
    while a do
        local t = text:sub(start, a - 1)
        if #t > 0 then
            designText(t)
            imgui.TextColored(color, t)
            imgui.SameLine(nil, 0)
        end

        local clr = text:sub(a + 1, b - 1)
        if clr:upper() == 'STANDART' then color = colors[col.Text]
        else
            clr = tonumber(clr, 16)
            if clr then
                local r = bit.band(bit.rshift(clr, 24), 0xFF)
                local g = bit.band(bit.rshift(clr, 16), 0xFF)
                local b = bit.band(bit.rshift(clr, 8), 0xFF)
                local a = bit.band(clr, 0xFF)
                color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
            end
        end

        start = b + 1
        a, b = text:find('{........}', start)
    end
    imgui.NewLine()
    if #text >= start then
        imgui.SameLine(nil, 0)
        designText(text:sub(start))
        imgui.TextColored(color, text:sub(start))
    end
end

function save()
    inicfg.save(settings, 'ChatSplitter.ini')
end

function update_script(norupdate, noupdatecheck, forceupdate, updaterem)
    if updaterem then
        local update_text = https.request(update_url)
	    if update_text ~= nil then
		    update_version = update_text:match("version: (.+)")
		    if update_version ~= nil then
			    if tonumber(update_version) > script_version then
				    sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} New version found! Current Version: [{00b7ff}%s{FFFFFF}] Latest Version: [{00b7ff}%s{FFFFFF}]", script.this.name, script_version_text, update_version), -1)
                end
            end
        end
    end
    if forceupdate then
        downloadUrlToFile(script_url, script_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} The update was successful!", script.this.name), -1)
                lua_thread.create(function()
                    wait(500) 
                    thisScript():reload()
                end)
            end
        end)
    end
    if norupdate then
        local update_text = https.request(update_url)
        if update_text ~= nil then
            update_version = update_text:match("version: (.+)")
            if update_version ~= nil then
                if tonumber(update_version) > script_version then
                    sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} New version found! The update is in progress.", script.this.name), -1)
                    downloadUrlToFile(script_url, script_path, function(id, status)
                        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} The update was successful!", script.this.name), -1)
                            lua_thread.create(function()
                                wait(500) 
                                thisScript():reload()
                            end)
                        end
                    end)
                else
                    if noupdatecheck then
                        sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} No new version found.", script.this.name), -1)
                    end
                end
            end
        end
    end
end

function style()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(8, 8)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 2)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(4, 4)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().IndentSpacing = 5
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().TabBorderSize = 0

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end
