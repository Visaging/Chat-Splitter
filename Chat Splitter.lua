script_name("Chat Splitter")
script_author("Visage A.K.A. Ishaan Dunne")

local script_version = 1.77
local script_version_text = '1.77'

local imgui, ffi = require 'mimgui', require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local fa = require 'fAwesome5'
local https = require 'ssl.https'
local dlstatus = require('moonloader').download_status
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/Chat%20Splitter.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/Chat%20Splitter.txt"
local updatelogs_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/update_logs.txt"
local flags = require 'moonloader'.font_flag
local events = require 'samp.events'

local settings = inicfg.load({
    font = {
        show = false,
        name = "Calibrib",
        size = 10,
        interval = 19,
        x = 300,
        y = 300,
        timestamp = true,
        lines = 6,
    },
    flag = {
        NONE      = false,
        BOLD      = true,
        ITALICS   = false,
        BORDER    = true,
        SHADOW    = false,
        UNDERLINE = false,
        STRIKEOUT = false,
    },
    chats = {
        helper    = false,
        com       = false,
        newbie    = false,
        admin     = false,
        facr      = false,
        facd      = false,
        family    = false,
        donator   = false,
        global    = false,
        portable  = false,
    },
    autoupdate = false,
}, 'ChatSplitter.ini')

local changePos = false
local flag = 0
local checkboxes = {}
local renderMessages = {}
local cMsg = 0

local _menu, _contextMenu, updatelogs = false, false, false

imgui.OnInitialize(function()
    style()

    local config = imgui.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 14.0, config, iconRanges)

	imgui.GetIO().ConfigWindowsMoveFromTitleBarOnly = true
	imgui.GetIO().IniFilename = nil
end)

imgui.OnFrame(function() return _menu and not isGamePaused() end,
function()
    width, height = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(275, 430), imgui.Cond.FirstUseEver)
    imgui.BeginCustomTitle(u8"Chat Splitter | Settings", 30, main_win, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)

        imgui.BeginChild("##69", imgui.ImVec2(265, 590), true)
            imgui.SetCursorPos(imgui.ImVec2(65, 5))
            if imgui.Checkbox("Enable Chat Splitter", new.bool(settings.font.show)) then settings.font.show = not settings.font.show end
            imgui.Separator()
            imgui.SetCursorPos(imgui.ImVec2(5, 35))
            imgui.BeginChild("##1", imgui.ImVec2(255, 120), true)
            imgui.PushItemWidth(100)
                tfont = new.char[256](settings.font.name)
                imgui.TextColoredRGB("Font name: ") imgui.SameLine(105)
                if imgui.InputText('##tfont', tfont, sizeof(tfont)) then settings.font.name = u8:decode(str(tfont)) applyfont() end
                tlinespace = new.int(settings.font.interval)
                imgui.Text("Line spacing: ") imgui.SameLine(105)
                if imgui.DragInt('##tlinespace', tlinespace) then settings.font.interval = tlinespace[0] applyfont() end imgui.SameLine(nil, 5) if imgui.Button('+##1') then settings.font.interval = settings.font.interval + 1 applyfont() end imgui.SameLine(nil, 5) if imgui.Button('-##1') then settings.font.interval = settings.font.interval - 1 applyfont() end
                tnlines = new.int(settings.font.lines)
                imgui.Text("Number of lines: ") imgui.SameLine(105)
                if imgui.DragInt('##tnlines', tnlines) then settings.font.lines = tnlines[0] applyfont() end imgui.SameLine(nil, 5) if imgui.Button('+##2') then settings.font.lines = settings.font.lines + 1 applyfont() end imgui.SameLine(nil, 5) if imgui.Button('-##2') then settings.font.lines = settings.font.lines - 1 applyfont() end
                tfsize = new.int(settings.font.size)
                imgui.Text("Font Size: ") imgui.SameLine(105)
                if imgui.DragInt('##tfsize', tfsize) then settings.font.size = tfsize[0] applyfont() end imgui.SameLine(nil, 5) if imgui.Button('+##3') then settings.font.size = settings.font.size + 1 applyfont() end imgui.SameLine(nil, 5) if imgui.Button('-##3') then settings.font.size = settings.font.size - 1 applyfont() end
                if imgui.Checkbox(u8('Timestamps'), new.bool(settings.font.timestamp)) then settings.font.timestamp = not settings.font.timestamp end
            imgui.EndChild()
            imgui.SetCursorPos(imgui.ImVec2(5, 160))
            imgui.BeginChild("##2", imgui.ImVec2(255, 100), true)
                imgui.Text("Font Flags:")
                imgui.BeginGroup()
                for k, v in pairs(settings.flag) do checkboxes[k] = new.bool(v) end
                local i = 1
                for k, v in pairs(checkboxes) do
                    if k ~= "NONE" then
                        if i % 2 == 0 or i == #flags/2 then imgui.SameLine(100) end
                        if imgui.Checkbox(k:upper(), v) then
                            settings.flag[k] = not settings.flag[k]
                            flag = 0
                            for k, v in pairs(settings.flag) do
                                if v then
                                    flag = flag + flags[k]
                                end
                            end
                            applyfont()
                        end
                        i = i + 1
                    end
                end
            imgui.EndGroup()
            imgui.EndChild()
            imgui.SetCursorPos(imgui.ImVec2(5, 265))
            imgui.BeginChild("##3", imgui.ImVec2(255, 190), true)
                if imgui.Button(fa.ICON_FA_CLIPBOARD_CHECK .. u8' Chat Selection Menu', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('chatselect') end
                if imgui.BeginPopup('chatselect') then
                        imgui.BeginChild("##4", imgui.ImVec2(255, 310), true)
                            imgui.Text("Select which chat to split:")
                            imgui.Separator()
                            imgui.Spacing()
                            imgui.Text("General Chats:")
                            imgui.Spacing()
                            if imgui.Checkbox(u8('Global Chat'), new.bool(settings.chats.global)) then settings.chats.global = not settings.chats.global end
                            if imgui.Checkbox(u8('Donator Chat'), new.bool(settings.chats.donator)) then settings.chats.donator = not settings.chats.donator end
                            if imgui.Checkbox(u8('Portable Radio Chat'), new.bool(settings.chats.portable)) then settings.chats.portable = not settings.chats.portable end
                            imgui.Spacing()
                            imgui.Separator()
                            imgui.Spacing()
                            imgui.Text("Staff Chats:")
                            imgui.Spacing()
                            if imgui.Checkbox(u8('Community Chat'), new.bool(settings.chats.com)) then settings.chats.com = not settings.chats.com end
                            if imgui.Checkbox(u8('Helper Chat'), new.bool(settings.chats.helper)) then settings.chats.helper = not settings.chats.helper end
                            if imgui.Checkbox(u8('Newbie Chat'), new.bool(settings.chats.newbie)) then settings.chats.newbie = not settings.chats.newbie end
                            if imgui.Checkbox(u8('Admin Chat'), new.bool(settings.chats.admin)) then settings.chats.admin = not settings.chats.admin end
                            if imgui.IsItemHovered() then imgui.SetTooltip('This includes all admin related chats.') end
                            imgui.Spacing()
                            imgui.Separator()
                            imgui.Spacing()
                            imgui.Text("Faction/Gang Chats:")
                            imgui.Spacing()
                            if imgui.Checkbox(u8('Faction Radio'), new.bool(settings.chats.facr)) then settings.chats.facr = not settings.chats.facr end
                            if imgui.Checkbox(u8('Department Radio'), new.bool(settings.chats.facd)) then settings.chats.facd = not settings.chats.facd end
                            if imgui.IsItemHovered() then imgui.SetTooltip('This includes hospital wanted alert(s).') end
                            if imgui.Checkbox(u8('Family Chat'), new.bool(settings.chats.family)) then settings.chats.family = not settings.chats.family end
                            save()
                        imgui.EndChild()
                    imgui.EndPopup()
                end
                if imgui.Button(fa.ICON_FA_ARROWS_ALT .. u8' Reposition', imgui.ImVec2(-1, 25)) then changePos = true _menu = false end
                if imgui.Button(fa.ICON_FA_TRASH .. u8' Clear extra chat', imgui.ImVec2(-1, 25)) then renderMessages = {} end
                if imgui.Button(fa.ICON_FA_CLIPBOARD_LIST .. u8' Update Logs', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('updatelogs') end
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
                if imgui.Button(fa.ICON_FA_SAVE .. u8' Save Config', imgui.ImVec2(-1, 25)) then save() sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} Config Saved!", script.this.name), -1) end
                if imgui.Button(fa.ICON_FA_COG .. u8' Update Settings', imgui.ImVec2(-1, 25)) then imgui.OpenPopup('updatemenu') end
                if imgui.BeginPopup('updatemenu') then
                    imgui.BeginChild("##5", imgui.ImVec2(255, 90), true)
                        if imgui.Button(fa.ICON_FA_SYNC .. u8' Update', imgui.ImVec2(-1, 25)) then update_script(true, true, false, false) end
                        if imgui.IsItemHovered() then imgui.SetTooltip('This will check for updates, if found will download it.') end
                        if imgui.Button(fa.ICON_FA_DOWNLOAD .. u8' Force Update', imgui.ImVec2(-1, 25)) then update_script(false, false, true, false) end
                        if imgui.Checkbox(u8('Auto Update'), new.bool(settings.autoupdate)) then settings.autoupdate = not settings.autoupdate end
                    imgui.EndChild()
                imgui.EndPopup()
                end
            imgui.EndChild()
        imgui.Spacing()
        imgui.Separator()
        imgui.SetCursorPos(imgui.ImVec2(30, 470))
        imgui.TextDisabled("Author: Visage A.K.A. Ishaan Dunne")
        imgui.EndChild()
    imgui.End()
end)

imgui.OnFrame(function() return _contextMenu and not isGamePaused() end,
function()
    imgui.SetNextWindowPos(imgui.ImVec2(cMsg[2], cMsg[3]))
    imgui.Begin("##cm", _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
        if imgui.Button(u8("Delete"), imgui.ImVec2(100, 25)) then table.remove(renderMessages, cMsg[1]) cMsg = {} _contextMenu = false end
        if imgui.Button(u8("Insert into chat"), imgui.ImVec2(100, 25)) then sampSetChatInputText(renderMessages[cMsg[1]][2]) cMsg = {} _contextMenu = false end
        if isKeyJustPressed(0x01) then
            local x, y = getCursorPos()
            if x < cMsg[2] or x > cMsg[2] + 110 and y < imgui.GetWindowPos().y or y > imgui.GetWindowPos().y + 70 then
                _contextMenu = false
            end
        end
    imgui.End()
end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    for k, v in pairs(settings.flag) do
        if v then
            flag = flag + flags[k]
        end
    end
    applyfont()
    sampRegisterChatCommand("chatsplit", function() _menu = not _menu end)
    updatelogs = https.request(updatelogs_url)
    if settings.autoupdate then update_script(true, false, false, false) else update_script(false, false, false, true) end
    sampAddChatMessage("{DFBD68}Chat Splitter by {FFFF00}Visage. {FF0000}[/chatsplit].", -1)
    while true do
        wait(0)
        if settings.font.show and sampIsChatVisible() then
            if #renderMessages > settings.font.lines then
                table.remove(renderMessages, 1)
            end
            local y = settings.font.y
            for k, v in ipairs(renderMessages) do
                if k <= settings.font.lines then
                    local text = settings.font.timestamp and os.date("[%H:%M:%S] ", v[3]) .. v[2] or v[2]
                    local mx, my = getCursorPos()
                    if sampIsCursorActive() and mx >= settings.font.x and mx <= settings.font.x + renderGetFontDrawTextLength(font, text) and my >= y and my <= y + renderGetFontDrawHeight(font) then
                        local size = renderGetFontDrawHeight(font)
                        renderDrawPolygon(settings.font.x - 10, y + size / 2 + 2, size/2, size/2, 50, 0, join_argb(rainbow(2, 255)))
                        if isKeyJustPressed(0x02) then
                            local x, y = getScreenResolution()
                            if y - my < 55 then
                                cMsg = {k, mx, my - 55}
                            else
                                cMsg = {k, mx, my}
                            end
                            _contextMenu = true
                        end
                    end
                    renderFontDrawText(font, text, settings.font.x, y, bit.bor(v[1], 0xFF000000))
                    y = y + settings.font.interval
                end
            end
        end
        if changePos then
            sampToggleCursor(true)
            settings.font.x, settings.font.y = getCursorPos()
            if isKeyJustPressed(0x01) then
                changePos = false
                _menu = true
                sampToggleCursor(false)
                save()
            end
        end
    end
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        save()
    end
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
    if settings.font.show then
        if settings.chats.helper and clr == -1511456854 then
            if msg:match("*** .*") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.com and clr == 869072810 then
            if msg:match("** .+Admin.+%:") or msg:match("*** .+Helper.+%:") or msg:match("*** Former Admin") or msg:match("** Helper Manager") or msg:match("** Management") or msg:match("** Asst. Management") or msg:match("** Assistant Management") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.newbie and clr == 2108620799 then
            if msg:match("** .*") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.admin then

            --Admin Chat (/a)
            if clr == -86 then
                if msg:match("* Secret Admin.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
                if msg:match("* Junior Admin.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
                if msg:match("* General Admin.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
                if msg:match("* Senior Admin.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
                if msg:match("* Head Admin.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
                if msg:match("* Ast. Management.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
                if msg:match("* Management.+%:") then
                    chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                    chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                    chatlog:close()
                    table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                    return false
                end
            end

            --Flags & Requests

            if clr == -65366 and (msg:match("Outstanding.+flag%: {FFFFFF}.+%(ID %d+%) %| Reason%:.+%(.+%).") or msg:match("Login notice%: {FFFFFF}.+%(ID %d+%) has previously been reported for .+") or msg:match(".+has denied.+name change request")) then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end

            -- Reports

            if clr == -5963606 and msg:match("____________________ REPORTS _____________________") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -5963606 and msg:match("___________________________________________________") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -28161 and msg:match(".+%(ID%: %d+%) %| RID%: %d+ %| Report%:.+%| Expires in%: %d+ minutes.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -28161 and (msg:match("Report from %[%d+%].+%(RID%: %d+%)%:.+") or msg:match("There.+{FF0606}.+pending.+{FFFF91} that.+expiring %- please check /reports and respond.")) then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -16382209 and msg:match("A report from.+%(ID %d+%) was not answered after 5 minutes and has expired. Please attend to reports before they expire.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end

            -- AdmCmd & AdmWarning

            if clr == -1439485014 and msg:match("AdmWarning%:.+") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if  msg:match("AdmCmd%:.+") and (clr == -8388353 or clr == -10270806) then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end

            --On-Duty & Off-Duty

            if clr == -86 and msg:match(".+%(ID %d+ %- .+%) is now.+as a.+Admin.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -86 and msg:match(".+%(ID %d+ %- .+%) is now.+as a.+Admin.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -65366 and (msg:match("You are now off%-duty as admin, and only have access to /admins /check /jail /ban /sban /kick /skick /showflags /reports /nrn") or msg:match("You are now on%-duty as admin and have access to all your commands, see /ah.")) then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -16382209 and msg:match("Please remember to turn off any hacks you may have.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -86 and msg:match(".+%(.+%) has logged in as a.+Admin.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end

            --Alerts

            if clr == -86 and msg:match("The player you were spectating has left the server.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -65366 and msg:match("Checking.+for desync, please wait") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -65366 and msg:match("%[BANK%].+%(IP%:.+%) has transferred.+to.+%(IP%:.+%).") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -65366 and msg:match(".+%(IP%:.+%) has sold.+%(IP%:.+%).+of materials in this session.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -65366 and msg:match(".+%(IP%:.+%) has paid.+%(IP%:.+%).+in this session.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
            if clr == -65366 and msg:match("%[ATM%].+%(IP%:.+%) has transferred.+to.+%(IP%:.+%).") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.facr and clr == -1920073729 then
            if msg:match("** ") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.facd and clr == -2686902 then
            if msg:match("** ") or msg:match(".+has reported.+as a wanted person.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.portable and clr == 1845194239 then
            if msg:match("**.Radio %(.+% kHz%).%**.+%:") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.global and clr == -5963606 then
            if msg:match("%(%(") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.family and clr == 33357768 then
            if msg:match("** ") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
        if settings.chats.donator and clr == -1210979584 then
            if msg:match("%(%(") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
    end
end

function imgui.CenterTextColoredRGB(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.TextColoredRGB(text)
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

function rainbow(speed, alpha)
    return math.floor(math.sin(os.clock() * speed) * 127 + 128), math.floor(math.sin(os.clock() * speed + 2) * 127 + 128), math.floor(math.sin(os.clock() * speed + 4) * 127 + 128), alpha
end

function applyfont()
    font = renderCreateFont(settings.font.name, settings.font.size, flag)
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
