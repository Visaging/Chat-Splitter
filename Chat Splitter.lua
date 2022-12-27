script_name("Chat Splitter")
script_author("Visage A.K.A. Ishaan Dunne")

local script_version = 1.71
local script_version_text = '1.71'

local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local https = require 'ssl.https'
local dlstatus = require('moonloader').download_status
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/Chat%20Splitter.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/Chat-Splitter/main/Chat%20Splitter.txt"
local fa = require 'fAwesome5'
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
        reg = true,
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
    },
    autoupdate = false,
}, 'ChatSplitter.ini')

imgui_window = {
    bEnable = imgui.ImBool(false),
    property = imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize,
    style_dark = function()
        imgui.SwitchContext()
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
    
        style.WindowPadding = imgui.ImVec2(8, 8)
        style.WindowRounding = 6
        style.ChildWindowRounding = 5
        style.FramePadding = imgui.ImVec2(5, 3)
        style.FrameRounding = 3.0
        style.ItemSpacing = imgui.ImVec2(5, 4)
        style.ItemInnerSpacing = imgui.ImVec2(4, 4)
        style.IndentSpacing = 21
        style.ScrollbarSize = 10.0
        style.ScrollbarRounding = 13
        style.GrabMinSize = 8
        style.GrabRounding = 1
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    
        colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
        colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
        colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.ChildWindowBg]          = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
        colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
        colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
        colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
        colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
        colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
        colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
        colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
        colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
        colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
        colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
        colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
        colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
        colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
        colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
        colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
        colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
        colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
        colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
        colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
        colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
        colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
        colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
        colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
    end,
    colorTitle = imgui.ImVec4(0.86, 0.07, 0.23, 1.00),
}

imgui_window.style_dark()

local buffer1 = imgui.ImBuffer(128)
local buffer2 = imgui.ImBuffer(128)
local buffer = imgui.ImBuffer(settings.font.name, 32)
local show = imgui.ImBool(settings.font.show)
local timestamp = imgui.ImBool(settings.font.timestamp)
local reg = imgui.ImBool(settings.font.reg)
local size = imgui.ImInt(settings.font.size)
local lines = imgui.ImInt(settings.font.lines)
local interval = imgui.ImInt(settings.font.interval)
local changePos = false
local flag = 0
local checkboxes = {}
for k, v in pairs(settings.flag) do checkboxes[k] = imgui.ImBool(v) end
local renderMessages = {}

local contextMenu = imgui.ImBool(false)
local cMsg = 0

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        font_config.SizePixels = 15.0;
        font_config.GlyphExtraSpacing.x = 0.1
        font_config.GlyphOffset.y = 1.5
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader\\lib\\fa5.ttf', font_config.SizePixels, font_config, fa_glyph_ranges)
    end
end

function imgui.OnDrawFrame()
    if imgui_window.bEnable.v then
        width, height = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8("Chat Splitter | Settings"), imgui_window.bEnable, imgui_window.property)
            if imgui.Checkbox(u8("Enable additional chat"), show) then settings.font.show = show.v end
            imgui.Separator()
            imgui.Spacing()
            imgui.PushItemWidth(100)
            if imgui.InputText(u8("Font name"), buffer) then settings.font.name = buffer.v font = renderCreateFont(settings.font.name, settings.font.size, flag) end
            if imgui.InputInt(u8("Line spacing"), interval) then settings.font.interval = interval.v font = renderCreateFont(settings.font.name, settings.font.size, flag) end
            if imgui.InputInt(u8("Number of lines"), lines) then settings.font.lines = lines.v end
            if imgui.InputInt(u8("Font size"), size) then settings.font.size = size.v font = renderCreateFont(settings.font.name, settings.font.size, flag) end
            imgui.PopItemWidth()
            if imgui.Checkbox(u8("Time Stamp"), timestamp) then settings.font.timestamp = timestamp.v end
            if imgui.Checkbox(u8("Case Sensitivity"), reg) then settings.font.reg = reg.v end
            imgui.Text(u8("Font Flags: "))
            imgui.BeginGroup()
                local i = 1
                for k, v in pairs(checkboxes) do
                    if k ~= "NONE" then
                        if i % 2 == 0 or i == #flags/2 then imgui.SameLine(100) end
                        if imgui.Checkbox(k:upper(), v) then
                            settings.flag[k] = v.v
                            flag = 0
                            for k, v in pairs(settings.flag) do
                                if v then
                                    flag = flag + flags[k]
                                end
                            end
                            font = renderCreateFont(settings.font.name, settings.font.size, flag)
                        end
                        i = i + 1
                    end
                end
            imgui.EndGroup()
            
            if imgui.Button(fa.ICON_CLIPBOARD_CHECK .. u8(' Chat Selection Menu'), imgui.ImVec2(-1, 25)) then
                imgui.OpenPopup('chatselect')
            end
            if imgui.BeginPopup('chatselect') then
                imgui.Text("Select which chat to split:")
                imgui.Spacing()
                imgui.Text("Staff Chats:")
                imgui.Spacing()
                if imgui.Checkbox(u8('Community Chat'), imgui.ImBool(settings.chats.com)) then settings.chats.com = not settings.chats.com end
                if imgui.Checkbox(u8('Helper Chat'), imgui.ImBool(settings.chats.helper)) then settings.chats.helper = not settings.chats.helper end
                if imgui.Checkbox(u8('Newbie Chat'), imgui.ImBool(settings.chats.newbie)) then settings.chats.newbie = not settings.chats.newbie end
                if imgui.Checkbox(u8('Admin Chat'), imgui.ImBool(settings.chats.admin)) then settings.chats.admin = not settings.chats.admin end
                --[[if imgui.IsItemHovered() then
                    if imgui.IsMouseClicked(0,false) then
                        imgui.CloseCurrentPopup()
                    end
                end]]
                save()
                imgui.EndPopup()
            end

            if imgui.Button(fa.ICON_ARROWS_ALT .. u8(' Reposition'), imgui.ImVec2(-1, 25)) then
                changePos = true
                imgui_window.bEnable.v = false
            end
            if imgui.Button(fa.ICON_TRASH .. u8(' Clear extra chat'), imgui.ImVec2(-1, 25)) then
                renderMessages = {}
            end
            if imgui.Button(fa.ICON_SAVE .. u8(' Save Config'), imgui.ImVec2(-1, 25)) then save() sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} Config Saved!", script.this.name), -1) end
            if imgui.Button(fa.ICON_SYNC .. u8(' Update'), imgui.ImVec2(100, 25)) then update_script(true, true, false, false) end
            imgui.SameLine(nil, 10)
            if imgui.Checkbox(u8('Auto Update'), imgui.ImBool(settings.autoupdate)) then settings.autoupdate = not settings.autoupdate end
            imgui.Spacing()
            imgui.TextDisabled("Author: Visage A.K.A. Ishaan Dunne")
            imgui.SetNextWindowSize(imgui.ImVec2(655, imgui.GetWindowSize().y))
            imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetWindowPos().x + imgui.GetWindowSize().x + 10, imgui.GetWindowPos().y))
            
        imgui.End()
    end
    if contextMenu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(115, 70))
        imgui.SetNextWindowPos(imgui.ImVec2(cMsg[2], cMsg[3]))
        imgui.Begin("##cm", _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
            if imgui.Button(u8("Delete"), imgui.ImVec2(100, 25)) then
                table.remove(renderMessages, cMsg[1])
                cMsg = {}
                contextMenu.v = false
            end
            if imgui.Button(u8("Insert into chat"), imgui.ImVec2(100, 25)) then
                sampSetChatInputText(renderMessages[cMsg[1]][2])
                cMsg = {}
                contextMenu.v = false
            end
            if isKeyJustPressed(0x01) then
                local x, y = getCursorPos()
                if x < cMsg[2] or x > cMsg[2] + 110 and y < imgui.GetWindowPos().y or y > imgui.GetWindowPos().y + 70 then
                    contextMenu.v = false
                end
            end
        imgui.End()
    end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    for k, v in pairs(settings.flag) do
        if v then
            flag = flag + flags[k]
        end
    end
    font = renderCreateFont(settings.font.name, settings.font.size, flag)
    sampRegisterChatCommand("chatsplit", function()
        imgui_window.bEnable.v = not imgui_window.bEnable.v
    end)
    if settings.autoupdate then update_script(true, false, false, false) else update_script(false, false, false, true) end
    sampAddChatMessage("{DFBD68}Chat Splitter by {FFFF00}Visage. {FF0000}[/chatsplit].", -1)
    sampRegisterChatCommand("csforceupdate", function() update_script(false, false, true, false) end)
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
                            contextMenu.v = true
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
                imgui_window.bEnable.v = true
                sampToggleCursor(false)
                save()
            end
        end
        imgui.Process = imgui_window.bEnable.v or contextMenu.v
    end
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        save()
    end
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

            if msg:match("{00FF00}* Junior Admin.+%: {FFFF91}") or msg:match("{FDEE00}* General Admin.+: {FFFF91}") or msg:match("{FFAA65}* Senior Admin.+%: {FFFF91}") or msg:match("{D5010B}* Head Admin.+%: {FFFF91}") or msg:match("{AE00A8}* Management.+%: {FFFF91}") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
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

            --Alerts

            if clr == -86 and msg:match("The player you were spectating has left the server.") then
                chatlog = io.open(getFolderPath(5).."\\GTA San Andreas User Files\\SAMP\\chatlog.txt", "a")
                chatlog:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
                chatlog:close()
                table.insert(renderMessages, {bit.rshift(clr, 8), msg, os.time()})
                return false
            end
        end
    end
end

function rainbow(speed, alpha)
    return math.floor(math.sin(os.clock() * speed) * 127 + 128), math.floor(math.sin(os.clock() * speed + 2) * 127 + 128), math.floor(math.sin(os.clock() * speed + 4) * 127 + 128), alpha
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
				    sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} New version found! Current Version: [{00b7ff}%s{FFFFFF}] Latest Version: [{00b7ff}%s{FFFFFF}]", script.this.name, script_version_text, update_version), 10944256)
                end
            end
        end
    end
    if forceupdate then
        downloadUrlToFile(script_url, script_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} The update was successful!", script.this.name), 10944256)
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
                    sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} New version found! The update is in progress.", script.this.name), 10944256)
                    downloadUrlToFile(script_url, script_path, function(id, status)
                        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} The update was successful!", script.this.name), 10944256)
                            lua_thread.create(function()
                                wait(500) 
                                thisScript():reload()
                            end)
                        end
                    end)
                else
                    if noupdatecheck then
                        sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} No new version found.", script.this.name), 10944256)
                    end
                end
            end
        end
    end
end
