import "Turbine";
import "Turbine.UI";
import "Turbine.UI.Lotro";

import "Dusk.LOTROEvents.Localization";
import "Dusk.LOTROEvents.Time";
import "Dusk.LOTROEvents.Calendar";

DuskLOTROEvents = DuskLOTROEvents or {};

local SETTINGS_KEY = "LOTROEvents_Settings";
local SETTINGS_VERSION = 12;
local LAUNCHER_SIZE = 32;
local LAUNCHER_RESOURCE = "Dusk/LOTROEvents/Resources/LOTROEvents.tga";
local GEAR_RESOURCE = "Dusk/LOTROEvents/Resources/Gear.tga";
local LONG_EVENT_DAYS = 30;
local CHAT_ANNOUNCE_DELAY = 5;
local WINDOW_REFRESH_SECONDS = 60;
local CALENDAR_COVERAGE_WARNING_DAYS = 30;

local WINDOW_NORMAL_WIDTH = 820;
local WINDOW_NORMAL_HEIGHT = 700;
local WINDOW_LARGE_WIDTH = 960;
local WINDOW_LARGE_HEIGHT = 820;
local WINDOW_MIN_WIDTH = 700;
local WINDOW_MIN_HEIGHT = 600;

local ACTIVE_HEADER_COLOR = "67F3AD";
local UPCOMING_HEADER_COLOR = "D97A3A";
local NOTICES_HEADER_COLOR = "8CC6FF";
local NAME_COLOR = "D6B35F";
local DATE_COLOR = "FFFFFF";
local DURATION_COLOR = "67F3AD";
local BULLET_COLOR = "34D6C5";
local MUTED_COLOR = "C8C8C8";
local NOTICE_COLOR = "8CC6FF";
local CELL_BORDER_COLOR = Turbine.UI.Color(1.0, 0.35, 0.35, 0.35);
local CELL_BACK_COLOR = Turbine.UI.Color(0.92, 0.02, 0.02, 0.02);
local CELL_OTHER_MONTH_BACK_COLOR = Turbine.UI.Color(0.92, 0.01, 0.01, 0.01);
local CELL_TODAY_BORDER_COLOR = Turbine.UI.Color(1.0, 0.95, 0.72, 0.18);
local CELL_TODAY_BACK_COLOR = Turbine.UI.Color(0.20, 0.95, 0.72, 0.18);
local PANEL_BACK_COLOR = Turbine.UI.Color(1.0, 0.00, 0.00, 0.00);

local function GetClientLanguage()
    local ok, language = pcall(function()
        return Turbine.Engine.GetLanguage();
    end);

    if (ok and language ~= nil) then
        return language;
    end

    return nil;
end

local clientLanguage = GetClientLanguage();
local localeKey = "en";
local Language = Turbine.Language or {};

if (Language.French ~= nil and clientLanguage == Language.French) then
    localeKey = "fr";
elseif (Language.German ~= nil and clientLanguage == Language.German) then
    localeKey = "de";
elseif (Language.EnglishGB ~= nil and clientLanguage == Language.EnglishGB) then
    localeKey = "enGB";
else
    local languageNumber = tonumber(clientLanguage);

    if (languageNumber == 268435459) then
        localeKey = "fr";
    elseif (languageNumber == 268435460) then
        localeKey = "de";
    elseif (languageNumber == 268435457) then
        localeKey = "enGB";
    elseif (languageNumber ~= 2) then
        local okDe, isDe = pcall(function()
            return Turbine.Shell.IsCommand("hilfe");
        end);
        local okFr, isFr = pcall(function()
            return Turbine.Shell.IsCommand("aide");
        end);

        if (okDe and isDe) then
            localeKey = "de";
        elseif (okFr and isFr) then
            localeKey = "fr";
        end
    end
end

local textLocaleKey = localeKey;
if (textLocaleKey == "enGB") then
    textLocaleKey = "en";
end

local L = DuskLOTROEvents.Localization[textLocaleKey]
    or DuskLOTROEvents.Localization.en;
local Time = DuskLOTROEvents.Time;

local DEFAULT_SETTINGS = {
    settingsVersion = SETTINGS_VERSION,
    timeZone = "auto",
    launcherVisible = true,
    launcherLocked = false,
    iconX = nil,
    iconY = nil,
    defaultView = "list",
    rememberLastView = true,
    chatAnnounceActive = true,
    chatAnnounceLongEvents = false,
    lastView = "list",
    listDays = 30,
    listShowActive = true,
    listShowNotices = true,
    listShowDuration = true,
    listHideLongEvents = true,
    calendarWeekStart = "monday",
    calendarShowNotices = true,
    calendarShowLongEvents = true,
    calendarColorPerEvent = true,
    windowSize = "large",
    rememberWindowPosition = true,
    windowX = nil,
    windowY = nil,
};

local function CopyDefaultSettings()
    local result = {};
    for key, value in pairs(DEFAULT_SETTINGS) do
        result[key] = value;
    end
    return result;
end

local settings = CopyDefaultSettings();

local loadOk, savedSettings = pcall(function()
    return Turbine.PluginData.Load(Turbine.DataScope.Account, SETTINGS_KEY);
end);
local settingsLoadFailed = not loadOk;

local function SavedBoolean(key)
    if (type(savedSettings) == "table" and type(savedSettings[key]) == "boolean") then
        return savedSettings[key];
    end
    return nil;
end

if (loadOk and type(savedSettings) == "table") then
    if (savedSettings.timeZone == "auto" or savedSettings.timeZone == "server"
        or savedSettings.timeZone == "eu" or savedSettings.timeZone == "uk") then
        settings.timeZone = savedSettings.timeZone;
    end

    local booleanKeys = {
        "launcherVisible", "launcherLocked", "rememberLastView", "chatAnnounceActive",
        "chatAnnounceLongEvents", "listShowActive", "listShowNotices", "listShowDuration",
        "listHideLongEvents", "calendarShowNotices",
        "calendarShowLongEvents",
        "calendarColorPerEvent", "rememberWindowPosition"
    };
    for _, key in ipairs(booleanKeys) do
        local value = SavedBoolean(key);
        if (value ~= nil) then settings[key] = value; end
    end

    if (savedSettings.defaultView == "list" or savedSettings.defaultView == "calendar") then
        settings.defaultView = savedSettings.defaultView;
    end
    if (savedSettings.lastView == "list" or savedSettings.lastView == "calendar") then
        settings.lastView = savedSettings.lastView;
    end
    if (savedSettings.listDays == 7 or savedSettings.listDays == 14 or savedSettings.listDays == 30) then
        settings.listDays = savedSettings.listDays;
    end
    if (savedSettings.calendarWeekStart == "monday" or savedSettings.calendarWeekStart == "sunday") then
        settings.calendarWeekStart = savedSettings.calendarWeekStart;
    end
    if (savedSettings.windowSize == "normal" or savedSettings.windowSize == "large") then
        settings.windowSize = savedSettings.windowSize;
    end

    local numericKeys = { "iconX", "iconY", "windowX", "windowY" };
    for _, key in ipairs(numericKeys) do
        if (tonumber(savedSettings[key]) ~= nil) then
            settings[key] = tonumber(savedSettings[key]);
        end
    end
end

settings.settingsVersion = SETTINGS_VERSION;

local function SaveSettings()
    local callOk, callError = pcall(function()
        Turbine.PluginData.Save(
            Turbine.DataScope.Account,
            SETTINGS_KEY,
            settings,
            function(succeeded, message)
                if (succeeded == false) then
                    settingsLoadFailed = true;
                    pcall(function()
                        Turbine.Shell.WriteLine(
                            "[LOTRO Events] " .. tostring(L.saveFailed or "Settings save failed:")
                                .. " " .. tostring(message or "unknown error")
                        );
                    end);
                else
                    settingsLoadFailed = false;
                end
            end
        );
    end);

    if (not callOk) then
        settingsLoadFailed = true;
        pcall(function()
            Turbine.Shell.WriteLine(
                "[LOTRO Events] " .. tostring(L.saveFailed or "Settings save failed:")
                    .. " " .. tostring(callError or "unknown error")
            );
        end);
    end
end

local function SaveSettingsSilently()
    -- If PluginData.Load itself failed, do not overwrite the unreadable/unknown
    -- account data on unload. A later successful explicit SaveSettings clears
    -- this guard via its completion callback.
    if (settingsLoadFailed) then
        return;
    end
    pcall(function()
        Turbine.PluginData.Save(
            Turbine.DataScope.Account,
            SETTINGS_KEY,
            settings
        );
    end);
end

local function GetDisplayZone()
    return Time.ResolveDisplayZone(settings.timeZone, localeKey);
end

local function GetNow()
    return Turbine.Engine.GetLocalTime();
end

local function SafeText(value)
    local text = tostring(value or "");
    text = string.gsub(text, "[\r\n]", " ");
    text = string.gsub(text, "<", "[");
    text = string.gsub(text, ">", "]");
    return text;
end

local function Color(hex, value)
    return "<rgb=#" .. hex .. ">" .. SafeText(value) .. "</rgb>";
end

local function BoldColor(hex, value)
    return "<rgb=#" .. hex .. "><b>" .. SafeText(value) .. "</b></rgb>";
end

local function ChatPrefix()
    return Color("55DFFF", "[LOTRO Events]");
end

local function WriteChatLine(text)
    Turbine.Shell.WriteLine(ChatPrefix() .. " " .. tostring(text or ""));
end

if (settingsLoadFailed) then
    WriteChatLine(L.settingsLoadFailed);
end

local function FormatText(template, value)
    return string.format(template, value);
end

local function GetEventName(item)
    local names = DuskLOTROEvents.EventNames[item.nameKey];
    if (names == nil) then
        return item.nameKey or "?";
    end
    return names[textLocaleKey] or names.en or item.nameKey or "?";
end

local function FormatDuration(seconds)
    if (seconds < 0) then
        seconds = 0;
    end

    if (seconds < 60) then
        return L.lessThanMinute;
    end

    local minutes = math.floor(seconds / 60);
    local days = math.floor(minutes / 1440);
    minutes = minutes - (days * 1440);

    local hours = math.floor(minutes / 60);
    minutes = minutes - (hours * 60);

    local function Unit(value, suffix)
        if (localeKey == "en" or localeKey == "enGB") then
            return tostring(value) .. suffix;
        end
        return tostring(value) .. " " .. suffix;
    end

    if (days > 0) then
        if (hours > 0) then
            return Unit(days, L.day) .. " " .. Unit(hours, L.hour);
        end
        return Unit(days, L.day);
    end

    if (hours > 0) then
        if (minutes > 0) then
            return Unit(hours, L.hour) .. " " .. Unit(minutes, L.minute);
        end
        return Unit(hours, L.hour);
    end

    return Unit(minutes, L.minute);
end

local function DateKey(year, month, day)
    return (year * 10000) + (month * 100) + day;
end

local function IsLeapYear(year)
    return ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0);
end

local DAYS_IN_MONTH = {
    31, 28, 31, 30, 31, 30,
    31, 31, 30, 31, 30, 31
};

local function GetDaysInMonth(year, month)
    if (month == 2 and IsLeapYear(year)) then
        return 29;
    end
    return DAYS_IN_MONTH[month];
end

local function DateToEpochUTC(year, month, day, hour, minute, second)
    local days = 0;

    if (year >= 1970) then
        for y = 1970, year - 1 do
            days = days + (IsLeapYear(y) and 366 or 365);
        end
    else
        for y = year, 1969 do
            days = days - (IsLeapYear(y) and 366 or 365);
        end
    end

    for m = 1, month - 1 do
        days = days + GetDaysInMonth(year, m);
    end

    days = days + (day - 1);

    return (days * 86400)
        + ((hour or 0) * 3600)
        + ((minute or 0) * 60)
        + (second or 0);
end

local function DayOfWeek(year, month, day)
    local days = math.floor(DateToEpochUTC(year, month, day, 0, 0, 0) / 86400);
    return (days + 4) % 7; -- Sunday = 0, Monday = 1, ...
end


local function IsLongEvent(event)
    if (event == nil or event.starts == nil or event.ends == nil) then
        return false;
    end
    return (event.ends - event.starts) > (LONG_EVENT_DAYS * 86400);
end

local function GetActiveEvents(now)
    local active = {};

    for _, event in ipairs(DuskLOTROEvents.Events) do
        if (now >= event.starts and now < event.ends
            and (not settings.listHideLongEvents or not IsLongEvent(event))) then
            table.insert(active, event);
        end
    end

    table.sort(active, function(a, b)
        if (a.ends == b.ends) then
            return GetEventName(a) < GetEventName(b);
        end
        return a.ends < b.ends;
    end);

    return active;
end

local function GetChatActiveEvents(now)
    local active = {};

    for _, event in ipairs(DuskLOTROEvents.Events) do
        if (now >= event.starts and now < event.ends
            and event.announceAtLogin ~= false
            and (settings.chatAnnounceLongEvents == true or not IsLongEvent(event))) then
            table.insert(active, event);
        end
    end

    table.sort(active, function(a, b)
        if (a.ends == b.ends) then
            return GetEventName(a) < GetEventName(b);
        end
        return a.ends < b.ends;
    end);

    return active;
end

local function AnnounceActiveEventsInChat()
    if (settings.chatAnnounceActive ~= true) then
        return;
    end

    local now = GetNow();
    local active = GetChatActiveEvents(now);
    if (#active == 0) then
        return;
    end

    if (#active == 1) then
        WriteChatLine(L.chatActiveOne);
    else
        WriteChatLine(string.format(L.chatActiveMany, #active));
    end

    for _, event in ipairs(active) do
        Turbine.Shell.WriteLine(
            " • "
            .. SafeText(GetEventName(event))
            .. " » "
            .. SafeText(L.ends) .. " "
            .. Color("FFFFFF", Time.FormatDate(event.ends, localeKey, GetDisplayZone()))
            .. " ("
            .. SafeText(L.inWord) .. " "
            .. Color("63E6A5", FormatDuration(event.ends - now))
            .. ")"
        );
    end
end

local function GetUpcomingEvents(now, days)
    local upcoming = {};
    local zone = GetDisplayZone();
    local year, month, day = Time.GetDateParts(now, zone);
    local horizonYear, horizonMonth, horizonDay = Time.AddCalendarDays(year, month, day, days);
    local horizonKey = DateKey(horizonYear, horizonMonth, horizonDay);

    for _, event in ipairs(DuskLOTROEvents.Events) do
        local eventYear, eventMonth, eventDay = Time.GetDateParts(event.starts, zone);
        local eventKey = DateKey(eventYear, eventMonth, eventDay);

        if (event.starts > now and eventKey <= horizonKey
            and (not settings.listHideLongEvents or not IsLongEvent(event))) then
            table.insert(upcoming, event);
        end
    end

    table.sort(upcoming, function(a, b)
        if (a.starts == b.starts) then
            return GetEventName(a) < GetEventName(b);
        end
        return a.starts < b.starts;
    end);

    return upcoming;
end

local function GetNotices(now, days)
    local notices = {};
    local zone = GetDisplayZone();
    local year, month, day = Time.GetDateParts(now, zone);
    local todayKey = DateKey(year, month, day);
    local horizonYear, horizonMonth, horizonDay = Time.AddCalendarDays(year, month, day, days);
    local horizonKey = DateKey(horizonYear, horizonMonth, horizonDay);

    for _, notice in ipairs(DuskLOTROEvents.Notices) do
        local noticeKey = DateKey(notice.year, notice.month, notice.day);
        if (noticeKey >= todayKey and noticeKey <= horizonKey) then
            table.insert(notices, notice);
        end
    end

    table.sort(notices, function(a, b)
        local aKey = DateKey(a.year, a.month, a.day);
        local bKey = DateKey(b.year, b.month, b.day);
        if (aKey == bKey) then
            return GetEventName(a) < GetEventName(b);
        end
        return aKey < bKey;
    end);

    return notices;
end

local function AppendSectionHeader(lines, text, colorHex)
    if (#lines > 0) then
        table.insert(lines, "");
    end
    table.insert(lines, BoldColor(colorHex or ACTIVE_HEADER_COLOR, text));
    table.insert(lines, "");
end

local function AppendEvent(lines, event, label, timestamp, now)
    table.insert(lines, Color(BULLET_COLOR, "•") .. " " .. Color(NAME_COLOR, GetEventName(event)));
    local detail = "  " .. Color(MUTED_COLOR, label)
        .. " " .. Color(DATE_COLOR, Time.FormatDate(timestamp, localeKey, GetDisplayZone()));
    if (settings.listShowDuration) then
        detail = detail
            .. Color(MUTED_COLOR, "  —  " .. L.inWord .. " ")
            .. Color(DURATION_COLOR, FormatDuration(timestamp - now));
    end
    table.insert(lines, detail);
    table.insert(lines, "");
end

local function AppendNotice(lines, notice)
    local label = notice.approximate and L.approximateDate or L.dateLabel;
    table.insert(lines, Color(BULLET_COLOR, "•") .. " " .. Color(NOTICE_COLOR, GetEventName(notice)));
    table.insert(lines,
        "  " .. Color(MUTED_COLOR, label)
        .. " " .. Color(DATE_COLOR, Time.FormatPlainDate(notice.year, notice.month, notice.day, localeKey))
    );
    table.insert(lines, "");
end

local function BuildWindowText(now)
    local lines = {};
    local days = settings.listDays or 30;
    local active = GetActiveEvents(now);
    local upcoming = GetUpcomingEvents(now, days);
    local notices = GetNotices(now, days);

    if (settings.listShowActive) then
        AppendSectionHeader(lines, L.activeHeader, ACTIVE_HEADER_COLOR);
        if (#active == 0) then
            table.insert(lines, Color(MUTED_COLOR, L.noActive));
            table.insert(lines, "");
        else
            for _, event in ipairs(active) do
                AppendEvent(lines, event, L.ends, event.ends, now);
            end
        end
    end

    if (settings.listShowNotices and #notices > 0) then
        AppendSectionHeader(lines, FormatText(L.noticesHeader, days), NOTICES_HEADER_COLOR);
        for _, notice in ipairs(notices) do
            AppendNotice(lines, notice);
        end
    end

    AppendSectionHeader(lines, FormatText(L.upcomingHeader, days), UPCOMING_HEADER_COLOR);
    if (#upcoming == 0) then
        table.insert(lines, Color(MUTED_COLOR, FormatText(L.noUpcoming, days)));
        table.insert(lines, "");
    else
        for _, event in ipairs(upcoming) do
            AppendEvent(lines, event, L.starts, event.starts, now);
        end
    end

    return table.concat(lines, "\n");
end

local eventWindow = nil;
local bodyBackground = nil;
local listPanel = nil;
local listContentLabel = nil;
local listScrollBar = nil;
local calendarPanel = nil;
local optionsPanel = nil;
local closeButton = nil;
local listButton = nil;
local calendarButton = nil;
local gearButton = nil;
local previousMonthButton = nil;
local nextMonthButton = nil;
local todayButton = nil;
local monthTitleLabel = nil;
local weekdayHeaderLabels = {};
local calendarDynamicControls = {};
local launcherWindow = nil;
local launcherIcon = nil;
local launcherTrigger = nil;
local optionViews = {};
local RebuildEventWindow = nil;

local currentView = "list";
local currentCalendarYear = nil;
local currentCalendarMonth = nil;
local currentWindowNow = nil;
local lastCalendarTodayKey = nil;
local nextWindowRefreshTime = nil;

local function ClearCalendarControls()
    for _, control in ipairs(calendarDynamicControls) do
        pcall(function()
            control:SetParent(nil);
        end);
    end
    calendarDynamicControls = {};
end

local function TrackCalendarControl(control)
    table.insert(calendarDynamicControls, control);
    return control;
end

local function Utf8Length(value)
    local length = 0;
    local index = 1;
    local byteLength = string.len(value);

    while (index <= byteLength) do
        local byte = string.byte(value, index) or 0;
        local step = 1;
        if (byte >= 240) then
            step = 4;
        elseif (byte >= 224) then
            step = 3;
        elseif (byte >= 192) then
            step = 2;
        end
        index = index + step;
        length = length + 1;
    end

    return length;
end

local function Utf8Prefix(value, maxChars)
    if (maxChars <= 0) then
        return "";
    end

    local index = 1;
    local count = 0;
    local byteLength = string.len(value);

    while (index <= byteLength and count < maxChars) do
        local byte = string.byte(value, index) or 0;
        local step = 1;
        if (byte >= 240) then
            step = 4;
        elseif (byte >= 224) then
            step = 3;
        elseif (byte >= 192) then
            step = 2;
        end
        index = index + step;
        count = count + 1;
    end

    return string.sub(value, 1, math.min(byteLength, index - 1));
end

local function TruncateText(text, maxLength)
    local value = SafeText(text);
    if (Utf8Length(value) <= maxLength) then
        return value;
    end
    if (maxLength <= 3) then
        return Utf8Prefix(value, maxLength);
    end
    return Utf8Prefix(value, maxLength - 3) .. "...";
end

local function GetCalendarMonthTitle(year, month)
    local monthNames = L.monthNames or DuskLOTROEvents.Localization.en.monthNames;
    return tostring(monthNames[month] or month) .. " " .. tostring(year);
end

local function GetWeekdayHeaders()
    local headers = L.weekdayHeaders or DuskLOTROEvents.Localization.en.weekdayHeaders;
    if (settings.calendarWeekStart == "sunday") then
        return { headers[7], headers[1], headers[2], headers[3], headers[4], headers[5], headers[6] };
    end
    return headers;
end

local CALENDAR_BAR_HEIGHT = 13;
local CALENDAR_BAR_GAP = 2;
local NOTICE_BAR_BACK_COLOR = Turbine.UI.Color(0.72, 0.08, 0.28, 0.52);
local NOTICE_BAR_EDGE_COLOR = Turbine.UI.Color(1.00, 0.24, 0.64, 1.00);
local NOTICE_BAR_TEXT_COLOR = Turbine.UI.Color(1.00, 0.88, 0.95, 1.00);

local function HsvToRgb(hue, saturation, value)
    local h = (hue % 360) / 60;
    local sector = math.floor(h);
    local fraction = h - sector;
    local p = value * (1 - saturation);
    local q = value * (1 - (saturation * fraction));
    local t = value * (1 - (saturation * (1 - fraction)));

    if (sector == 0) then return value, t, p; end
    if (sector == 1) then return q, value, p; end
    if (sector == 2) then return p, value, t; end
    if (sector == 3) then return p, q, value; end
    if (sector == 4) then return t, p, value; end
    return value, p, q;
end

local function GetEventPaletteColor(nameKey, alpha)
    local text = tostring(nameKey or "event");
    local hash = 216613;

    -- Deterministic hash without bitwise operators, with small enough arithmetic
    -- to remain exact on Lua 5.1's usual double-precision number type.
    for index = 1, string.len(text) do
        hash = (hash * 131 + string.byte(text, index) + (index * 17)) % 1000003;
    end

    -- Use hue plus small saturation/value variation so event types are much less
    -- likely to share the exact same color while keeping every bar readable.
    local hue = hash % 360;
    local saturation = 0.52 + ((math.floor(hash / 360) % 18) / 100);
    local value = 0.70 + ((math.floor(hash / 6480) % 16) / 100);
    local red, green, blue = HsvToRgb(hue, saturation, value);
    return Turbine.UI.Color(alpha or 1.0, red, green, blue);
end

local function GetCalendarEventColor(nameKey, alpha)
    if (settings.calendarColorPerEvent) then
        return GetEventPaletteColor(nameKey, alpha);
    end
    return Turbine.UI.Color(alpha or 1.0, 0.26, 0.55, 0.32);
end

local function BuildMonthSegments(year, month)
    local segmentsByWeek = { {}, {}, {}, {}, {}, {} };
    local maxLaneByWeek = { 0, 0, 0, 0, 0, 0 };
    local preferredLaneByKey = {};
    local zone = GetDisplayZone();
    local daysInMonth = GetDaysInMonth(year, month);
    local firstDow = DayOfWeek(year, month, 1);
    local firstOffset;
    if (settings.calendarWeekStart == "sunday") then
        firstOffset = firstDow;
    else
        firstOffset = (firstDow + 6) % 7;
    end

    local function AddSpan(kind, key, name, firstDay, lastDay, startMarkerDay, endMarkerDay)
        if (lastDay < 1 or firstDay > daysInMonth) then
            return;
        end

        firstDay = math.max(1, firstDay);
        lastDay = math.min(daysInMonth, lastDay);

        local firstIndex = firstOffset + (firstDay - 1);
        local lastIndex = firstOffset + (lastDay - 1);

        for week = 0, 5 do
            local weekStart = week * 7;
            local weekEnd = weekStart + 6;
            local segmentStart = math.max(firstIndex, weekStart);
            local segmentEnd = math.min(lastIndex, weekEnd);

            if (segmentStart <= segmentEnd) then
                local segmentStartDay = segmentStart - firstOffset + 1;
                local segmentEndDay = segmentEnd - firstOffset + 1;
                table.insert(segmentsByWeek[week + 1], {
                    kind = kind,
                    key = key,
                    text = name,
                    startColumn = segmentStart - weekStart,
                    endColumn = segmentEnd - weekStart,
                    isStart = (startMarkerDay ~= nil and segmentStartDay == startMarkerDay),
                    isEnd = (endMarkerDay ~= nil and segmentEndDay == endMarkerDay),
                });
            end
        end
    end

    for _, event in ipairs(DuskLOTROEvents.Events) do
        if (settings.calendarShowLongEvents or not IsLongEvent(event)) then
            local startYear, startMonth, startDay = Time.GetDateParts(event.starts, zone);
            local endYear, endMonth, endDay = Time.GetDateParts(event.ends - 1, zone);
            local startKey = DateKey(startYear, startMonth, startDay);
            local endKey = DateKey(endYear, endMonth, endDay);
            local monthStartKey = DateKey(year, month, 1);
            local monthEndKey = DateKey(year, month, daysInMonth);

            local overlapsMonth = endKey >= monthStartKey and startKey <= monthEndKey;
            if (overlapsMonth) then
                local firstDay = 1;
                local lastDay = daysInMonth;
                local startMarkerDay = nil;
                local endMarkerDay = nil;

                if (startYear == year and startMonth == month) then
                    firstDay = startDay;
                    startMarkerDay = startDay;
                end
                if (endYear == year and endMonth == month) then
                    lastDay = endDay;
                    endMarkerDay = endDay;
                end

                AddSpan(
                    "event",
                    event.nameKey,
                    GetEventName(event),
                    firstDay,
                    lastDay,
                    startMarkerDay,
                    endMarkerDay
                );
            end
        end
    end

    if (settings.calendarShowNotices) then
        for _, notice in ipairs(DuskLOTROEvents.Notices) do
            if (notice.year == year and notice.month == month) then
            local prefix = notice.approximate and "~ " or "* ";
            AddSpan(
                "notice",
                "notice:" .. tostring(notice.nameKey),
                prefix .. GetEventName(notice),
                notice.day,
                notice.day,
                notice.day,
                notice.day
            );
            end
        end
    end

    for week = 1, 6 do
        local segments = segmentsByWeek[week];
        table.sort(segments, function(a, b)
            if (a.startColumn == b.startColumn) then
                local aSpan = a.endColumn - a.startColumn;
                local bSpan = b.endColumn - b.startColumn;
                if (aSpan == bSpan) then
                    return a.text < b.text;
                end
                return aSpan > bSpan;
            end
            return a.startColumn < b.startColumn;
        end);

        local occupied = {};

        local function LaneIsFree(lane, segment)
            occupied[lane] = occupied[lane] or {};
            for column = segment.startColumn, segment.endColumn do
                if (occupied[lane][column] == true) then
                    return false;
                end
            end
            return true;
        end

        for _, segment in ipairs(segments) do
            local assignedLane = nil;
            local preferred = preferredLaneByKey[segment.key];

            if (preferred ~= nil and LaneIsFree(preferred, segment)) then
                assignedLane = preferred;
            else
                local lane = 1;
                while (assignedLane == nil) do
                    if (LaneIsFree(lane, segment)) then
                        assignedLane = lane;
                    else
                        lane = lane + 1;
                    end
                end
            end

            segment.lane = assignedLane;
            preferredLaneByKey[segment.key] = assignedLane;
            maxLaneByWeek[week] = math.max(maxLaneByWeek[week], assignedLane);

            occupied[assignedLane] = occupied[assignedLane] or {};
            for column = segment.startColumn, segment.endColumn do
                occupied[assignedLane][column] = true;
            end
        end
    end

    return segmentsByWeek, maxLaneByWeek, firstOffset;
end

local function SetTabButtonState(button, isActive)
    if (button == nil) then
        return;
    end
    pcall(function()
        button:SetEnabled(not isActive);
    end);
end

local RefreshListContent = nil;
local RefreshCalendarContent = nil;
local DisarmAllOptionResets = nil;

local function UpdateViewVisibility()
    local isList = (currentView == "list");
    local isCalendar = (currentView == "calendar");
    local isOptions = (currentView == "options");

    if (listPanel ~= nil) then listPanel:SetVisible(isList); end
    if (calendarPanel ~= nil) then calendarPanel:SetVisible(isCalendar); end
    if (optionsPanel ~= nil) then optionsPanel:SetVisible(isOptions); end

    if (previousMonthButton ~= nil) then previousMonthButton:SetVisible(isCalendar); end
    if (nextMonthButton ~= nil) then nextMonthButton:SetVisible(isCalendar); end
    if (todayButton ~= nil) then todayButton:SetVisible(isCalendar); end
    if (monthTitleLabel ~= nil) then monthTitleLabel:SetVisible(isCalendar); end

    SetTabButtonState(listButton, isList);
    SetTabButtonState(calendarButton, isCalendar);
    if (gearButton ~= nil) then
        pcall(function() gearButton:SetEnabled(not isOptions); end);
    end
end

local function RememberView(view)
    if ((view == "list" or view == "calendar") and settings.rememberLastView
        and settings.lastView ~= view) then
        settings.lastView = view;
        SaveSettings();
    end
end

local function SwitchToView(view)
    if (view ~= "list" and view ~= "calendar" and view ~= "options") then
        return;
    end

    -- A reset confirmation is valid only while the current options view stays open.
    -- Entering or leaving the options page always starts with a clean confirmation state.
    if ((view == "options" or currentView == "options") and DisarmAllOptionResets ~= nil) then
        DisarmAllOptionResets();
    end

    currentView = view;
    RememberView(view);

    if (view == "list" or view == "calendar") then
        currentWindowNow = GetNow();
    end

    if (view == "list") then
        RefreshListContent();
    elseif (view == "calendar") then
        RefreshCalendarContent();
    end
    UpdateViewVisibility();
end

RefreshListContent = function()
    if (listContentLabel ~= nil and currentWindowNow ~= nil) then
        listContentLabel:SetText(BuildWindowText(currentWindowNow));
    end
end

RefreshCalendarContent = function()
    if (calendarPanel == nil or currentCalendarYear == nil or currentCalendarMonth == nil) then
        return;
    end

    ClearCalendarControls();

    if (monthTitleLabel ~= nil) then
        monthTitleLabel:SetText(GetCalendarMonthTitle(currentCalendarYear, currentCalendarMonth));
    end

    local headers = GetWeekdayHeaders();
    for i = 1, #weekdayHeaderLabels do
        weekdayHeaderLabels[i]:SetText(headers[i] or "");
    end

    local panelWidth = calendarPanel:GetWidth();
    local panelHeight = calendarPanel:GetHeight();
    local topOffset = 28;
    local headerHeight = 20;
    local gridTop = topOffset + headerHeight + 4;
    local gridHeight = panelHeight - gridTop;
    local cellWidth = math.floor(panelWidth / 7);
    local cellHeight = math.floor(gridHeight / 6);

    local segmentsByWeek, maxLaneByWeek, firstOffset = BuildMonthSegments(
        currentCalendarYear,
        currentCalendarMonth
    );
    local daysInMonth = GetDaysInMonth(currentCalendarYear, currentCalendarMonth);
    local todayYear, todayMonth, todayDay = Time.GetDateParts(currentWindowNow or GetNow(), GetDisplayZone());
    lastCalendarTodayKey = DateKey(todayYear, todayMonth, todayDay);

    -- Draw the month grid first. Leading/trailing cells intentionally stay blank,
    -- matching the compact LOTRO calendar layout used as the visual reference.
    for week = 0, 5 do
        for column = 0, 6 do
            local cellIndex = (week * 7) + column;
            local dayNumber = cellIndex - firstOffset + 1;
            local isCurrentMonth = (dayNumber >= 1 and dayNumber <= daysInMonth);
            local isToday = isCurrentMonth
                and currentCalendarYear == todayYear
                and currentCalendarMonth == todayMonth
                and dayNumber == todayDay;
            local left = column * cellWidth;
            local top = gridTop + (week * cellHeight);
            local width = (column == 6) and (panelWidth - left) or cellWidth;
            local height = (week == 5) and (panelHeight - top) or cellHeight;

            local border = TrackCalendarControl(Turbine.UI.Control());
            border:SetParent(calendarPanel);
            border:SetPosition(left, top);
            border:SetSize(width, height);
            border:SetBackColor(isToday and CELL_TODAY_BORDER_COLOR or CELL_BORDER_COLOR);
            border:SetMouseVisible(false);

            local fill = TrackCalendarControl(Turbine.UI.Control());
            fill:SetParent(border);
            local borderInset = isToday and 2 or 1;
            fill:SetPosition(borderInset, borderInset);
            fill:SetSize(width - (borderInset * 2), height - (borderInset * 2));
            if (isToday) then
                fill:SetBackColor(CELL_TODAY_BACK_COLOR);
            else
                fill:SetBackColor(isCurrentMonth and CELL_BACK_COLOR or CELL_OTHER_MONTH_BACK_COLOR);
            end
            fill:SetMouseVisible(false);

            if (isCurrentMonth) then
                local dayLabel = TrackCalendarControl(Turbine.UI.Label());
                dayLabel:SetParent(fill);
                dayLabel:SetPosition(4, 2);
                dayLabel:SetSize(width - 8, 16);
                dayLabel:SetFont(Turbine.UI.Lotro.Font.Verdana12);
                dayLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
                dayLabel:SetForeColor(Turbine.UI.Color(1.0, 1.0, 1.0, 1.0));
                dayLabel:SetText(tostring(dayNumber));
                dayLabel:SetMouseVisible(false);
            end
        end
    end

    -- Draw every event. There is intentionally no +N overflow marker: lanes are
    -- allocated dynamically so every overlapping event remains visible.
    for week = 1, 6 do
        local weekTop = gridTop + ((week - 1) * cellHeight);
        local laneCount = math.max(1, maxLaneByWeek[week] or 1);
        local availableForBars = math.max(12, cellHeight - 22);
        local laneStep = CALENDAR_BAR_HEIGHT + CALENDAR_BAR_GAP;

        if ((laneCount * laneStep) > availableForBars) then
            -- A 37px calendar row on very small displays can legitimately need
            -- five lanes. A 4px minimum step pushes the fifth bar into the next
            -- week; 3px keeps every lane within its own row.
            laneStep = math.max(3, math.floor(availableForBars / laneCount));
        end

        local barHeight = math.max(3, math.min(CALENDAR_BAR_HEIGHT, laneStep - 1));

        for _, segment in ipairs(segmentsByWeek[week]) do
            local left = (segment.startColumn * cellWidth) + 3;
            local right = ((segment.endColumn + 1) * cellWidth) - 3;
            if (segment.endColumn == 6) then
                right = panelWidth - 3;
            end
            local width = math.max(8, right - left);
            local top = weekTop + 20 + ((segment.lane - 1) * laneStep);

            local bar = TrackCalendarControl(Turbine.UI.Control());
            bar:SetParent(calendarPanel);
            bar:SetPosition(left, top);
            bar:SetSize(width, barHeight);

            local edgeColor;
            if (segment.kind == "notice") then
                bar:SetBackColor(NOTICE_BAR_BACK_COLOR);
                edgeColor = NOTICE_BAR_EDGE_COLOR;
            else
                bar:SetBackColor(GetCalendarEventColor(segment.key, 0.72));
                edgeColor = GetCalendarEventColor(segment.key, 1.00);
            end
            bar:SetMouseVisible(false);

            -- Only the true event boundaries receive a solid colored cap.
            -- Week-to-week continuation segments deliberately have no fake cap.
            if (segment.isStart) then
                local startCap = TrackCalendarControl(Turbine.UI.Control());
                startCap:SetParent(bar);
                startCap:SetPosition(0, 0);
                startCap:SetSize(math.min(4, width), barHeight);
                startCap:SetBackColor(edgeColor);
                startCap:SetMouseVisible(false);
            end

            if (segment.isEnd) then
                local endCap = TrackCalendarControl(Turbine.UI.Control());
                endCap:SetParent(bar);
                endCap:SetPosition(math.max(0, width - 4), 0);
                endCap:SetSize(math.min(4, width), barHeight);
                endCap:SetBackColor(edgeColor);
                endCap:SetMouseVisible(false);
            end

            local label = TrackCalendarControl(Turbine.UI.Label());
            label:SetParent(bar);
            label:SetPosition(segment.isStart and 6 or 3, 0);
            label:SetSize(math.max(2, width - (segment.isStart and 9 or 6)), barHeight);
            label:SetFont(Turbine.UI.Lotro.Font.Verdana12);
            label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);
            if (segment.kind == "notice") then
                label:SetForeColor(NOTICE_BAR_TEXT_COLOR);
            else
                label:SetForeColor(Turbine.UI.Color(1.00, 1.00, 1.00, 1.00));
            end

            local maxChars = math.max(5, math.floor(width / 7));
            label:SetText(TruncateText(segment.text, maxChars));
            label:SetMouseVisible(false);
        end
    end
end

local function RefreshWindowContent()
    -- Rebuild only the visible view. The hidden view is refreshed on demand when
    -- the user switches to it, which avoids recreating the full calendar while
    -- only the list or options page is being used.
    if (currentView == "list") then
        RefreshListContent();
    elseif (currentView == "calendar") then
        RefreshCalendarContent();
    end
    UpdateViewVisibility();
end

local function SetCurrentMonthFromNow(now)
    local year, month = Time.GetDateParts(now, GetDisplayZone());
    currentCalendarYear = year;
    currentCalendarMonth = month;
end

local function ChangeCalendarMonth(delta)
    currentWindowNow = GetNow();
    if (currentCalendarYear == nil or currentCalendarMonth == nil) then
        SetCurrentMonthFromNow(currentWindowNow);
    end

    currentCalendarMonth = currentCalendarMonth + delta;
    while (currentCalendarMonth < 1) do
        currentCalendarMonth = currentCalendarMonth + 12;
        currentCalendarYear = currentCalendarYear - 1;
    end
    while (currentCalendarMonth > 12) do
        currentCalendarMonth = currentCalendarMonth - 12;
        currentCalendarYear = currentCalendarYear + 1;
    end

    RefreshCalendarContent();
end

local function GetConfiguredWindowSize()
    if (settings.windowSize == "normal") then
        return WINDOW_NORMAL_WIDTH, WINDOW_NORMAL_HEIGHT;
    end
    return WINDOW_LARGE_WIDTH, WINDOW_LARGE_HEIGHT;
end

local function GetDefaultLauncherPosition()
    local x = 20;
    local y = math.max(20, Turbine.UI.Display:GetHeight() - LAUNCHER_SIZE - 80);
    return x, y;
end

local function ApplyLauncherVisibility()
    if (launcherWindow ~= nil) then
        launcherWindow:SetVisible(settings.launcherVisible == true);
    end
end

local function ResetLauncherPosition()
    settings.iconX = nil;
    settings.iconY = nil;
    if (launcherWindow ~= nil) then
        local x, y = GetDefaultLauncherPosition();
        launcherWindow:SetPosition(x, y);
    end
end

local function CenterEventWindow()
    if (eventWindow == nil) then
        settings.windowX = nil;
        settings.windowY = nil;
        return;
    end
    local displayWidth = Turbine.UI.Display:GetWidth();
    local displayHeight = Turbine.UI.Display:GetHeight();
    local x = math.floor((displayWidth - eventWindow:GetWidth()) / 2);
    local y = math.floor((displayHeight - eventWindow:GetHeight()) / 2);
    eventWindow:SetPosition(math.max(0, x), math.max(0, y));
    settings.windowX = eventWindow:GetLeft();
    settings.windowY = eventWindow:GetTop();
end

local function RefreshAllOptionViews()
    for _, view in ipairs(optionViews) do
        if (view.Refresh ~= nil) then
            view:Refresh();
        end
    end
end

DisarmAllOptionResets = function()
    for _, view in ipairs(optionViews) do
        if (view.DisarmReset ~= nil) then
            view:DisarmReset();
        end
    end
end

local function ApplyOptionsRuntime(rebuildWindow)
    ApplyLauncherVisibility();
    SaveSettings();

    if (rebuildWindow and RebuildEventWindow ~= nil) then
        RebuildEventWindow();
    elseif (eventWindow ~= nil) then
        currentWindowNow = GetNow();
        RefreshWindowContent();
    end

    RefreshAllOptionViews();
end

local function DisplayViewName(value)
    if (value == "calendar") then return L.calendarTab; end
    return L.listTab;
end

local function DisplayWeekStart(value)
    if (value == "sunday") then return L.weekStartSunday; end
    return L.weekStartMonday;
end

local function DisplayWindowSize(value)
    if (value == "normal") then return L.windowSizeNormal; end
    return L.windowSizeLarge;
end

local function DisplayTimeZone(value)
    if (value == "server") then return L.timeZoneServer; end
    if (value == "eu") then return L.timeZoneEurope; end
    if (value == "uk") then return L.timeZoneUK; end
    return L.timeZoneAuto;
end

local function BuildOptionsPanel(parent, width, height, embedded, compactEnabled)
    local view = {
        parent = parent,
        refreshing = false,
        controls = {},
        resetArmed = false,
        embedded = embedded == true,
    };
    table.insert(optionViews, view);

    parent:SetSize(width, height);
    parent:SetBackColor(PANEL_BACK_COLOR);

    -- Compact layout is enabled for the in-window options panel and for the
    -- Plugin Manager panel on small displays. Keep this separate from the
    -- "embedded" ownership flag so Plugin Manager views are not discarded when
    -- the main LOTRO Events window is rebuilt.
    local useCompactLayout = (compactEnabled == true) or (embedded == true);
    local ultraCompactLayout = useCompactLayout and height < 380;
    local compactLayout = useCompactLayout and height < 450;
    local compactTextLayout = useCompactLayout and width < 620;

    local function OptionText(normalKey, compactKey)
        if (compactTextLayout and compactKey ~= nil and L[compactKey] ~= nil) then
            return L[compactKey];
        end
        return L[normalKey];
    end
    local sectionHeight = ultraCompactLayout and 17 or (compactLayout and 20 or 22);
    local sectionStep = ultraCompactLayout and 18 or (compactLayout and 22 or 26);
    local checkboxHeight = ultraCompactLayout and 17 or (compactLayout and 22 or 24);
    local checkboxStep = ultraCompactLayout and 18 or (compactLayout and 24 or 28);
    local cycleButtonHeight = ultraCompactLayout and 18 or (compactLayout and 21 or 22);
    local cycleStep = ultraCompactLayout and 19 or (compactLayout and 25 or 29);
    local actionHeight = ultraCompactLayout and 18 or (compactLayout and 21 or 22);
    local actionStep = ultraCompactLayout and 19 or (compactLayout and 25 or 29);
    -- Ultra-compact mode is used by the embedded options panel on 640x480-class
    -- displays. The regular section gap would place the final Maintenance button
    -- a few pixels outside the panel, so the existing control step provides the
    -- separation on its own in this mode.
    local sectionGap = ultraCompactLayout and 0 or (compactLayout and 4 or 8);

    local function AddSection(text, x, y, w)
        local label = Turbine.UI.Label();
        label:SetParent(parent);
        label:SetPosition(x, y);
        label:SetSize(w, sectionHeight);
        label:SetFont(Turbine.UI.Lotro.Font.Verdana14);
        label:SetForeColor(Turbine.UI.Color(1.0, 0.90, 0.78, 0.42));
        label:SetText(text);
        return y + sectionStep;
    end

    local function AddCheckbox(key, textLabel, x, y, w, rebuildWindow)
        local control = Turbine.UI.Lotro.CheckBox();
        control:SetParent(parent);
        control:SetPosition(x, y);
        control:SetSize(w, checkboxHeight);
        control:SetFont(Turbine.UI.Lotro.Font.Verdana12);
        control:SetText(textLabel);
        control.CheckedChanged = function(sender, args)
            if (view.refreshing) then return; end
            settings[key] = sender:IsChecked();
            if (key == "rememberWindowPosition") then
                if (settings[key] and eventWindow ~= nil) then
                    settings.windowX = eventWindow:GetLeft();
                    settings.windowY = eventWindow:GetTop();
                elseif (not settings[key]) then
                    settings.windowX = nil;
                    settings.windowY = nil;
                end
            elseif (key == "rememberLastView" and settings[key]) then
                if (currentView == "list" or currentView == "calendar") then
                    settings.lastView = currentView;
                end
            end
            ApplyOptionsRuntime(rebuildWindow == true);
        end
        view.controls[key] = control;
        return y + checkboxStep;
    end

    local function AddCycle(key, textLabel, x, y, labelWidth, buttonWidth, values, displayFn, rebuildWindow, onChanged)
        local label = Turbine.UI.Label();
        label:SetParent(parent);
        label:SetPosition(x, y + (ultraCompactLayout and 0 or (compactLayout and 1 or 2)));
        label:SetSize(labelWidth, 20);
        label:SetFont(Turbine.UI.Lotro.Font.Verdana12);
        label:SetForeColor(Turbine.UI.Color(1.0, 0.86, 0.86, 0.86));
        label:SetText(textLabel);

        local button = Turbine.UI.Lotro.Button();
        button:SetParent(parent);
        button:SetPosition(x + labelWidth + 6, y);
        button:SetSize(buttonWidth, cycleButtonHeight);
        button.Click = function(sender, args)
            local current = settings[key];
            local index = 1;
            for i, value in ipairs(values) do
                if (value == current) then index = i; break; end
            end
            index = index + 1;
            if (index > #values) then index = 1; end
            settings[key] = values[index];
            if (onChanged ~= nil) then onChanged(); end
            ApplyOptionsRuntime(rebuildWindow == true);
        end
        view.controls[key] = { button = button, displayFn = displayFn };
        return y + cycleStep;
    end

    local function AddAction(textLabel, x, y, w, action)
        local button = Turbine.UI.Lotro.Button();
        button:SetParent(parent);
        button:SetPosition(x, y);
        button:SetSize(w, actionHeight);
        button:SetText(textLabel);
        button.Click = function(sender, args)
            action(sender);
        end
        return button, y + actionStep;
    end

    local halfWidth = math.floor(width / 2);
    local leftX = (width < 700) and 12 or 18;
    local rightX = halfWidth + 6;
    local colWidth = math.max(160, math.min(330, halfWidth - 24));
    local standardButtonWidth = math.max(88, math.min(120, math.floor(colWidth * 0.40)));
    local standardLabelWidth = math.max(60, colWidth - standardButtonWidth - 6);
    local timeZoneButtonWidth = math.max(105, math.min(150, math.floor(colWidth * 0.50)));
    local timeZoneLabelWidth = math.max(55, colWidth - timeZoneButtonWidth - 6);
    local actionWidth = math.min(210, colWidth);
    local wideActionWidth = math.min(250, colWidth);
    local yLeft = ultraCompactLayout and 3 or (compactLayout and 6 or 10);
    local yRight = ultraCompactLayout and 3 or (compactLayout and 6 or 10);

    yLeft = AddSection(L.optionsGeneral, leftX, yLeft, colWidth);
    yLeft = AddCheckbox("launcherVisible", L.optionLauncherVisible, leftX, yLeft, colWidth, false);
    yLeft = AddCheckbox("launcherLocked", OptionText("optionLauncherLocked", "optionLauncherLockedCompact"), leftX, yLeft, colWidth, false);
    local resetIconButton;
    resetIconButton, yLeft = AddAction(OptionText("optionResetLauncher", "optionResetLauncherCompact"), leftX, yLeft, actionWidth, function()
        ResetLauncherPosition();
        SaveSettings();
        RefreshAllOptionViews();
    end);
    yLeft = AddCycle("defaultView", L.optionDefaultView, leftX, yLeft, standardLabelWidth, standardButtonWidth,
        { "list", "calendar" }, DisplayViewName, false, function()
            -- Changing the default view must not overwrite the actual last-used
            -- view while "remember last view" is enabled.
            if (not settings.rememberLastView) then
                settings.lastView = settings.defaultView;
            end
        end);
    yLeft = AddCheckbox("rememberLastView", OptionText("optionRememberLastView", "optionRememberLastViewCompact"), leftX, yLeft, colWidth, false);
    yLeft = AddCheckbox("chatAnnounceActive", OptionText("optionChatAnnounce", "optionChatAnnounceCompact"), leftX, yLeft, colWidth, false);
    yLeft = AddCheckbox("chatAnnounceLongEvents", string.format(OptionText("optionChatAnnounceLongEvents", "optionChatAnnounceLongEventsCompact"), LONG_EVENT_DAYS), leftX, yLeft, colWidth, false);

    yLeft = yLeft + sectionGap;
    yLeft = AddSection(L.optionsList, leftX, yLeft, colWidth);
    yLeft = AddCycle("listDays", L.optionUpcomingDays, leftX, yLeft, standardLabelWidth, standardButtonWidth,
        { 7, 14, 30 }, function(v) return tostring(v) .. " " .. L.daysWord; end, false);
    yLeft = AddCheckbox("listShowActive", L.optionShowActive, leftX, yLeft, colWidth, false);
    yLeft = AddCheckbox("listShowNotices", OptionText("optionShowNotices", "optionShowNoticesCompact"), leftX, yLeft, colWidth, false);
    yLeft = AddCheckbox("listShowDuration", L.optionShowDuration, leftX, yLeft, colWidth, false);
    yLeft = AddCheckbox("listHideLongEvents", string.format(OptionText("optionHideLongEvents", "optionHideLongEventsCompact"), LONG_EVENT_DAYS), leftX, yLeft, colWidth, false);

    yRight = AddSection(L.optionsCalendar, rightX, yRight, colWidth);
    yRight = AddCycle("calendarWeekStart", L.optionWeekStart, rightX, yRight, standardLabelWidth, standardButtonWidth,
        { "monday", "sunday" }, DisplayWeekStart, false);
    yRight = AddCheckbox("calendarShowNotices", OptionText("optionShowNotices", "optionShowNoticesCompact"), rightX, yRight, colWidth, false);
    yRight = AddCheckbox("calendarShowLongEvents", L.optionCalendarLongEvents, rightX, yRight, colWidth, false);
    yRight = AddCheckbox("calendarColorPerEvent", OptionText("optionDifferentColors", "optionDifferentColorsCompact"), rightX, yRight, colWidth, false);

    yRight = yRight + sectionGap;
    yRight = AddSection(L.optionsWindow, rightX, yRight, colWidth);
    yRight = AddCycle("windowSize", L.optionWindowSize, rightX, yRight, standardLabelWidth, standardButtonWidth,
        { "normal", "large" }, DisplayWindowSize, true);
    yRight = AddCheckbox("rememberWindowPosition", OptionText("optionRememberWindowPosition", "optionRememberWindowPositionCompact"), rightX, yRight, colWidth, false);
    local centerButton;
    centerButton, yRight = AddAction(L.optionCenterWindow, rightX, yRight, actionWidth, function()
        CenterEventWindow();
        SaveSettings();
        RefreshAllOptionViews();
    end);
    local resetWindowButton;
    resetWindowButton, yRight = AddAction(OptionText("optionResetWindow", "optionResetWindowCompact"), rightX, yRight, wideActionWidth, function()
        settings.windowSize = DEFAULT_SETTINGS.windowSize;
        settings.windowX = nil;
        settings.windowY = nil;
        ApplyOptionsRuntime(true);
    end);

    yRight = yRight + sectionGap;
    yRight = AddSection(L.optionsTimeZone, rightX, yRight, colWidth);
    yRight = AddCycle("timeZone", L.optionTimeZone, rightX, yRight, timeZoneLabelWidth, timeZoneButtonWidth,
        { "auto", "server", "eu", "uk" }, DisplayTimeZone, false, function()
            if (currentWindowNow ~= nil) then
                currentWindowNow = GetNow();
                SetCurrentMonthFromNow(currentWindowNow);
            end
        end);

    yRight = yRight + sectionGap;
    yRight = AddSection(L.optionsMaintenance, rightX, yRight, colWidth);
    local resetAllText = OptionText("optionResetAll", "optionResetAllCompact");
    local resetAllButton;
    resetAllButton, yRight = AddAction(resetAllText, rightX, yRight, wideActionWidth, function(sender)
        if (not view.resetArmed) then
            view.resetArmed = true;
            sender:SetText(L.optionConfirmResetAll);
            return;
        end
        view.resetArmed = false;
        settings = CopyDefaultSettings();
        ResetLauncherPosition();
        ApplyOptionsRuntime(true);
    end);
    view.resetAllButton = resetAllButton;
    view.resetAllText = resetAllText;

    function view:DisarmReset()
        self.resetArmed = false;
        if (self.resetAllButton ~= nil) then
            self.resetAllButton:SetText(self.resetAllText);
        end
    end

    function view:Refresh()
        self.refreshing = true;
        local boolKeys = {
            "launcherVisible", "launcherLocked", "rememberLastView", "chatAnnounceActive",
            "chatAnnounceLongEvents", "listShowActive", "listShowNotices", "listShowDuration", "listHideLongEvents",
            "calendarShowNotices", "calendarShowLongEvents",
            "calendarColorPerEvent", "rememberWindowPosition"
        };
        for _, key in ipairs(boolKeys) do
            local control = self.controls[key];
            if (control ~= nil) then control:SetChecked(settings[key] == true); end
        end
        local cycleKeys = {
            "defaultView", "listDays", "calendarWeekStart", "windowSize", "timeZone"
        };
        for _, key in ipairs(cycleKeys) do
            local item = self.controls[key];
            if (item ~= nil) then item.button:SetText(item.displayFn(settings[key])); end
        end
        if (self.resetAllButton ~= nil and not self.resetArmed) then
            self.resetAllButton:SetText(self.resetAllText);
        end
        self.refreshing = false;
    end

    view:Refresh();
    return view;
end

local function CreateWindow()
    if (eventWindow ~= nil) then
        return;
    end

    local displayWidth = Turbine.UI.Display:GetWidth();
    local displayHeight = Turbine.UI.Display:GetHeight();

    local configuredWidth, configuredHeight = GetConfiguredWindowSize();
    local availableWidth = math.max(1, displayWidth - 20);
    local availableHeight = math.max(1, displayHeight - 40);
    local width = math.min(configuredWidth, availableWidth);
    local height = math.min(configuredHeight, availableHeight);

    if (availableWidth >= WINDOW_MIN_WIDTH) then
        width = math.max(WINDOW_MIN_WIDTH, width);
    end
    if (availableHeight >= WINDOW_MIN_HEIGHT) then
        height = math.max(WINDOW_MIN_HEIGHT, height);
    end

    eventWindow = Turbine.UI.Lotro.Window();
    -- Keep LOTRO Events on the normal UI layer so native panels such as the world map can cover it.
    eventWindow:SetZOrder(0);
    eventWindow:SetSize(width, height);
    local centerX = math.max(0, math.floor((displayWidth - width) / 2));
    local centerY = math.max(0, math.floor((displayHeight - height) / 2));
    if (settings.rememberWindowPosition and settings.windowX ~= nil and settings.windowY ~= nil) then
        local maxX = math.max(0, displayWidth - width);
        local maxY = math.max(0, displayHeight - height);
        local x = math.max(0, math.min(maxX, math.floor(settings.windowX)));
        local y = math.max(0, math.min(maxY, math.floor(settings.windowY)));
        eventWindow:SetPosition(x, y);
    else
        eventWindow:SetPosition(centerX, centerY);
    end
    eventWindow:SetText("LOTRO Events");
    eventWindow:SetResizable(false);
    eventWindow:SetVisible(false);

    bodyBackground = Turbine.UI.Control();
    bodyBackground:SetParent(eventWindow);
    bodyBackground:SetPosition(14, 42);
    bodyBackground:SetSize(width - 28, height - 92);
    bodyBackground:SetBackColor(PANEL_BACK_COLOR);
    bodyBackground:SetMouseVisible(false);

    listButton = Turbine.UI.Lotro.Button();
    listButton:SetParent(bodyBackground);
    listButton:SetSize(90, 22);
    listButton:SetPosition(10, 6);
    listButton:SetText(L.listTab);
    listButton.Click = function(sender, args)
        SwitchToView("list");
    end

    calendarButton = Turbine.UI.Lotro.Button();
    calendarButton:SetParent(bodyBackground);
    calendarButton:SetSize(90, 22);
    calendarButton:SetPosition(108, 6);
    calendarButton:SetText(L.calendarTab);
    calendarButton.Click = function(sender, args)
        SwitchToView("calendar");
    end

    gearButton = Turbine.UI.Button();
    gearButton:SetParent(bodyBackground);
    gearButton:SetSize(24, 24);
    gearButton:SetPosition(bodyBackground:GetWidth() - 34, 5);
    gearButton:SetBackground(GEAR_RESOURCE);
    gearButton.Click = function(sender, args)
        SwitchToView("options");
        RefreshAllOptionViews();
    end

    listPanel = Turbine.UI.Control();
    listPanel:SetParent(bodyBackground);
    listPanel:SetPosition(8, 34);
    listPanel:SetSize(bodyBackground:GetWidth() - 16, bodyBackground:GetHeight() - 70);
    listPanel:SetBackColor(PANEL_BACK_COLOR);

    listContentLabel = Turbine.UI.Label();
    listContentLabel:SetParent(listPanel);
    listContentLabel:SetPosition(10, 10);
    listContentLabel:SetSize(listPanel:GetWidth() - 30, listPanel:GetHeight() - 20);
    listContentLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
    listContentLabel:SetTextAlignment(Turbine.UI.ContentAlignment.TopLeft);
    listContentLabel:SetMultiline(true);
    listContentLabel:SetMarkupEnabled(true);
    listContentLabel:SetSelectable(true);
    listContentLabel:SetBackColor(PANEL_BACK_COLOR);

    listScrollBar = Turbine.UI.Lotro.ScrollBar();
    listScrollBar:SetParent(listPanel);
    listScrollBar:SetOrientation(Turbine.UI.Orientation.Vertical);
    listScrollBar:SetPosition(listPanel:GetWidth() - 14, 10);
    listScrollBar:SetSize(10, listPanel:GetHeight() - 20);
    listContentLabel:SetVerticalScrollBar(listScrollBar);

    calendarPanel = Turbine.UI.Control();
    calendarPanel:SetParent(bodyBackground);
    calendarPanel:SetPosition(8, 34);
    calendarPanel:SetSize(bodyBackground:GetWidth() - 16, bodyBackground:GetHeight() - 70);
    calendarPanel:SetBackColor(PANEL_BACK_COLOR);

    optionsPanel = Turbine.UI.Control();
    optionsPanel:SetParent(bodyBackground);
    optionsPanel:SetPosition(8, 34);
    optionsPanel:SetSize(bodyBackground:GetWidth() - 16, bodyBackground:GetHeight() - 70);
    optionsPanel:SetBackColor(PANEL_BACK_COLOR);
    BuildOptionsPanel(optionsPanel, optionsPanel:GetWidth(), optionsPanel:GetHeight(), true, true);

    previousMonthButton = Turbine.UI.Lotro.Button();
    previousMonthButton:SetParent(calendarPanel);
    previousMonthButton:SetSize(26, 20);
    previousMonthButton:SetPosition(0, 2);
    previousMonthButton:SetText("<");
    previousMonthButton.Click = function(sender, args)
        ChangeCalendarMonth(-1);
    end

    nextMonthButton = Turbine.UI.Lotro.Button();
    nextMonthButton:SetParent(calendarPanel);
    nextMonthButton:SetSize(26, 20);
    nextMonthButton:SetPosition(calendarPanel:GetWidth() - 26, 2);
    nextMonthButton:SetText(">");
    nextMonthButton.Click = function(sender, args)
        ChangeCalendarMonth(1);
    end

    todayButton = Turbine.UI.Lotro.Button();
    todayButton:SetParent(calendarPanel);
    todayButton:SetSize(84, 20);
    todayButton:SetPosition(calendarPanel:GetWidth() - 118, 2);
    todayButton:SetText(L.today);
    todayButton.Click = function(sender, args)
        currentWindowNow = GetNow();
        SetCurrentMonthFromNow(currentWindowNow);
        RefreshCalendarContent();
    end

    monthTitleLabel = Turbine.UI.Label();
    monthTitleLabel:SetParent(calendarPanel);
    monthTitleLabel:SetPosition(34, 2);
    monthTitleLabel:SetSize(calendarPanel:GetWidth() - 160, 20);
    monthTitleLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);
    monthTitleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    monthTitleLabel:SetForeColor(Turbine.UI.Color(1.0, 0.90, 0.78, 0.42));

    local headers = GetWeekdayHeaders();
    local weekdayWidth = math.floor(calendarPanel:GetWidth() / 7);
    for index = 1, 7 do
        local label = Turbine.UI.Label();
        label:SetParent(calendarPanel);
        label:SetPosition((index - 1) * weekdayWidth, 28);
        label:SetSize(weekdayWidth, 18);
        label:SetFont(Turbine.UI.Lotro.Font.Verdana12);
        label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
        label:SetForeColor(Turbine.UI.Color(1.0, 0.90, 0.78, 0.42));
        label:SetText(headers[index] or "");
        weekdayHeaderLabels[index] = label;
    end

    closeButton = Turbine.UI.Lotro.Button();
    closeButton:SetParent(bodyBackground);
    closeButton:SetSize(110, 22);
    closeButton:SetPosition(math.floor((bodyBackground:GetWidth() - 110) / 2), bodyBackground:GetHeight() - 28);
    closeButton:SetText(L.close);
    closeButton.Click = function(sender, args)
        if (settings.rememberWindowPosition) then
            settings.windowX = eventWindow:GetLeft();
            settings.windowY = eventWindow:GetTop();
            SaveSettings();
        end
        eventWindow:SetWantsUpdates(false);
        nextWindowRefreshTime = nil;
        eventWindow:SetVisible(false);
    end

    eventWindow:SetWantsKeyEvents(true);
    eventWindow:SetWantsUpdates(false);

    eventWindow.Update = function(sender, args)
        local gameTime = Turbine.Engine.GetGameTime();

        if (nextWindowRefreshTime == nil) then
            nextWindowRefreshTime = gameTime + WINDOW_REFRESH_SECONDS;
            return;
        end

        if (gameTime < nextWindowRefreshTime) then
            return;
        end

        nextWindowRefreshTime = gameTime + WINDOW_REFRESH_SECONDS;

        if (not sender:IsVisible()) then
            sender:SetWantsUpdates(false);
            nextWindowRefreshTime = nil;
            return;
        end

        currentWindowNow = GetNow();

        if (currentView == "list") then
            -- Remaining-time labels and active/upcoming state stay current while
            -- the list remains open.
            RefreshListContent();
        elseif (currentView == "calendar") then
            -- The calendar itself is static inside a day. Rebuild it only when
            -- the displayed "today" date actually changes.
            local year, month, day = Time.GetDateParts(currentWindowNow, GetDisplayZone());
            local todayKey = DateKey(year, month, day);
            if (todayKey ~= lastCalendarTodayKey) then
                RefreshCalendarContent();
            end
        end
    end

    eventWindow.KeyDown = function(sender, args)
        if (args.Action == Turbine.UI.Lotro.Action.Escape) then
            if (settings.rememberWindowPosition) then
                settings.windowX = sender:GetLeft();
                settings.windowY = sender:GetTop();
                SaveSettings();
            end
            sender:SetWantsUpdates(false);
            nextWindowRefreshTime = nil;
            sender:SetVisible(false);
        end
    end

    eventWindow.PositionChanged = function(sender, args)
        if (settings.rememberWindowPosition) then
            settings.windowX = sender:GetLeft();
            settings.windowY = sender:GetTop();
        end
    end

    -- Treat the native X button as "hide" so the reusable window object is not
    -- destroyed and the launcher can open it again immediately.
    eventWindow.Closing = function(sender, args)
        if (settings.rememberWindowPosition) then
            settings.windowX = sender:GetLeft();
            settings.windowY = sender:GetTop();
            SaveSettings();
        end
        args.Cancel = true;
        sender:SetWantsUpdates(false);
        nextWindowRefreshTime = nil;
        sender:SetVisible(false);
    end
end

local function ShowEventWindow(now)
    CreateWindow();
    if (DisarmAllOptionResets ~= nil) then
        DisarmAllOptionResets();
    end
    currentWindowNow = now or GetNow();
    SetCurrentMonthFromNow(currentWindowNow);

    if (settings.rememberLastView and (settings.lastView == "list" or settings.lastView == "calendar")) then
        currentView = settings.lastView;
    else
        currentView = settings.defaultView;
    end

    RefreshWindowContent();
    eventWindow:SetVisible(true);
    nextWindowRefreshTime = Turbine.Engine.GetGameTime() + WINDOW_REFRESH_SECONDS;
    eventWindow:SetWantsUpdates(true);
end

DuskLOTROEvents.ShowWindow = function()
    ShowEventWindow();
end

RebuildEventWindow = function()
    if (eventWindow == nil) then
        return;
    end

    local wasVisible = eventWindow:IsVisible();
    local previousView = currentView;
    if (settings.rememberWindowPosition and settings.windowX ~= nil and settings.windowY ~= nil) then
        settings.windowX = eventWindow:GetLeft();
        settings.windowY = eventWindow:GetTop();
    end
    eventWindow:SetWantsUpdates(false);
    nextWindowRefreshTime = nil;
    eventWindow:SetVisible(false);
    ClearCalendarControls();

    local keptViews = {};
    for _, view in ipairs(optionViews) do
        if (not view.embedded) then table.insert(keptViews, view); end
    end
    optionViews = keptViews;

    eventWindow = nil;
    bodyBackground = nil;
    listPanel = nil;
    listContentLabel = nil;
    listScrollBar = nil;
    calendarPanel = nil;
    optionsPanel = nil;
    closeButton = nil;
    listButton = nil;
    calendarButton = nil;
    gearButton = nil;
    previousMonthButton = nil;
    nextMonthButton = nil;
    todayButton = nil;
    monthTitleLabel = nil;
    weekdayHeaderLabels = {};

    if (wasVisible) then
        ShowEventWindow();
        if (previousView == "options") then
            SwitchToView("options");
            RefreshAllOptionViews();
        elseif (previousView == "list" or previousView == "calendar") then
            SwitchToView(previousView);
        end
    end
end

local function ToggleEventWindow()
    if (eventWindow ~= nil and eventWindow:IsVisible()) then
        if (settings.rememberWindowPosition) then
            settings.windowX = eventWindow:GetLeft();
            settings.windowY = eventWindow:GetTop();
            SaveSettings();
        end
        eventWindow:SetWantsUpdates(false);
        nextWindowRefreshTime = nil;
        eventWindow:SetVisible(false);
    else
        ShowEventWindow();
    end
end

local registeredCommandNames = {
    events = false,
    lotroevents = false,
};

local function GetPrimaryCommand()
    if (registeredCommandNames.events) then
        return "/events";
    elseif (registeredCommandNames.lotroevents) then
        return "/lotroevents";
    end
    return "/events";
end

local eventsCommand = Turbine.ShellCommand();

function eventsCommand:Execute(command, arguments)
    local ok, err = pcall(function()
        ShowEventWindow();
    end);

    if (not ok) then
        pcall(function()
            Turbine.Shell.WriteLine(
                "[LOTRO Events] " .. tostring(L.openFailed or "Unable to open window:")
                    .. " " .. tostring(err or "unknown error")
            );
        end);
    end
end

function eventsCommand:GetHelp()
    return string.format(L.longHelp, GetPrimaryCommand());
end

function eventsCommand:GetShortHelp()
    return L.shortHelp;
end

local commandRegistered = false;
local requestedNames = {};
local nameOrder = { "events", "lotroevents" };
local eventsCommandInUse = false;

for _, name in ipairs(nameOrder) do
    local inUse = false;
    local ok, result = pcall(function()
        return Turbine.Shell.IsCommand(name);
    end);
    if (ok and result == true) then
        inUse = true;
        if (name == "events") then
            eventsCommandInUse = true;
        end
    end
    if (not inUse) then
        table.insert(requestedNames, name);
    end
end

if (#requestedNames > 0) then
    local addOk, result = pcall(function()
        return Turbine.Shell.AddCommand(table.concat(requestedNames, ":"), eventsCommand);
    end);

    if (addOk) then
        local registeredCount = #requestedNames;
        if (type(result) == "number") then
            registeredCount = result;
            commandRegistered = registeredCount > 0;
        elseif (type(result) == "boolean") then
            commandRegistered = result;
            registeredCount = result and #requestedNames or 0;
        else
            -- Some LOTRO client builds return nil on successful registration.
            commandRegistered = true;
        end

        local statusKnown = false;
        local anyRegistered = false;
        for _, name in ipairs(requestedNames) do
            local ok, inUse = pcall(function()
                return Turbine.Shell.IsCommand(name);
            end);
            if (ok) then
                statusKnown = true;
                registeredCommandNames[name] = inUse == true;
                anyRegistered = anyRegistered or registeredCommandNames[name];
            end
        end

        -- Keep a positive AddCommand result even if a client build cannot
        -- immediately reflect plugin commands through IsCommand(). Conversely,
        -- a positive IsCommand() result can confirm success when AddCommand
        -- returns an unusual value.
        if (statusKnown and anyRegistered) then
            commandRegistered = true;
        elseif (not statusKnown and commandRegistered) then
            for i = 1, math.min(registeredCount, #requestedNames) do
                registeredCommandNames[requestedNames[i]] = true;
            end
        end

        if (not commandRegistered) then
            WriteChatLine(L.commandRegistrationFailed);
        elseif (eventsCommandInUse) then
            WriteChatLine(L.commandEventsUnavailable);
        end
    else
        WriteChatLine(L.commandRegistrationFailed);
    end
else
    WriteChatLine(L.commandUnavailable);
end

local function ClampLauncherPosition(x, y)
    local displayWidth = Turbine.UI.Display:GetWidth();
    local displayHeight = Turbine.UI.Display:GetHeight();
    local maxX = math.max(0, displayWidth - LAUNCHER_SIZE - 1);
    local maxY = math.max(0, displayHeight - LAUNCHER_SIZE - 1);

    x = math.floor(tonumber(x) or 0);
    y = math.floor(tonumber(y) or 0);

    if (x < 0) then x = 0; end
    if (y < 0) then y = 0; end
    if (x > maxX) then x = maxX; end
    if (y > maxY) then y = maxY; end

    return x, y;
end

local function SaveLauncherPosition()
    if (launcherWindow == nil) then
        return;
    end

    settings.iconX = launcherWindow:GetLeft();
    settings.iconY = launcherWindow:GetTop();
    SaveSettings();
end

local function CreateLauncherIcon()
    if (launcherWindow ~= nil) then
        return;
    end

    launcherWindow = Turbine.UI.Window();
    launcherWindow:SetSize(LAUNCHER_SIZE, LAUNCHER_SIZE);
    launcherWindow:SetOpacity(1.0);
    launcherWindow:SetVisible(settings.launcherVisible == true);
    launcherWindow:SetMouseVisible(true);
    -- Keep the launcher on the normal UI layer so native LOTRO panels can cover it.
    launcherWindow:SetZOrder(0);

    local defaultX, defaultY = GetDefaultLauncherPosition();
    local x, y = ClampLauncherPosition(settings.iconX or defaultX, settings.iconY or defaultY);
    launcherWindow:SetPosition(x, y);

    launcherIcon = Turbine.UI.Control();
    launcherIcon:SetParent(launcherWindow);
    launcherIcon:SetSize(LAUNCHER_SIZE, LAUNCHER_SIZE);
    launcherIcon:SetPosition(0, 0);
    launcherIcon:SetBackground(LAUNCHER_RESOURCE);
    launcherIcon:SetMouseVisible(false);

    launcherTrigger = Turbine.UI.Button();
    launcherTrigger:SetParent(launcherWindow);
    launcherTrigger:SetSize(LAUNCHER_SIZE, LAUNCHER_SIZE);
    launcherTrigger:SetPosition(0, 0);
    launcherTrigger:SetZOrder(1);

    local dragging = false;
    local moved = false;
    local startX = 0;
    local startY = 0;

    launcherTrigger.MouseDown = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left) then
            moved = false;
            dragging = false;
            if (not settings.launcherLocked) then
                dragging = true;
                startX = args.X;
                startY = args.Y;
            end
        end
    end

    launcherTrigger.MouseMove = function(sender, args)
        if (not dragging) then
            return;
        end

        local dx = args.X - startX;
        local dy = args.Y - startY;

        if (moved or math.abs(dx) > 3 or math.abs(dy) > 3) then
            moved = true;
            local newX = launcherWindow:GetLeft() + dx;
            local newY = launcherWindow:GetTop() + dy;
            newX, newY = ClampLauncherPosition(newX, newY);
            launcherWindow:SetPosition(newX, newY);
        end
    end

    launcherTrigger.MouseUp = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left) then
            dragging = false;
            if (moved) then
                SaveLauncherPosition();
            end
        end
    end

    launcherTrigger.MouseClick = function(sender, args)
        if (args.Button == Turbine.UI.MouseButton.Left) then
            if (not moved) then
                ToggleEventWindow();
            end
            moved = false;
        end
    end

    launcherTrigger.MouseEnter = function(sender, args)
        launcherWindow:SetOpacity(1.0);
    end

    launcherTrigger.MouseLeave = function(sender, args)
        launcherWindow:SetOpacity(1.0);
    end
end

local displaySizeListener = nil;
local pluginOptionsPanel = nil;
local pluginOptionsContent = nil;
local pluginOptionsView = nil;
local RebuildPluginOptionsContent = nil;

local function HandleDisplaySizeChanged()
    if (launcherWindow ~= nil) then
        local x, y = ClampLauncherPosition(launcherWindow:GetLeft(), launcherWindow:GetTop());
        launcherWindow:SetPosition(x, y);
        settings.iconX = x;
        settings.iconY = y;
    end

    if (eventWindow ~= nil) then
        RebuildEventWindow();
    end

    -- The LOTRO Plugin Manager owns the size of the root options panel.
    -- Keep that root object stable; its SizeChanged handler rebuilds only
    -- the inner content when the manager actually gives it a new size.
end

local function CreateDisplaySizeListener()
    -- LOTRO exposes no native Display.SizeChanged event. A tiny stretched window
    -- receives SizeChanged when the display resolution changes; defer one frame
    -- so Display:GetWidth()/GetHeight() already report the new dimensions.
    local listener = nil;
    local ok = pcall(function()
        listener = Turbine.UI.Window();
        listener:SetMouseVisible(false);
        listener:SetStretchMode(0);
        listener:SetSize(1, 1);
        listener:SetStretchMode(1);
        listener:SetSize(2, 2);
        listener.ignoreSizeChangedEvents = 2;

        listener.SizeChanged = function(sender, args)
            if sender.ignoreSizeChangedEvents > 0 then
                sender.ignoreSizeChangedEvents = sender.ignoreSizeChangedEvents - 1;
                return;
            end
            sender:SetSize(2, 2);
            sender.ignoreSizeChangedEvents = 1;
            sender:SetWantsUpdates(true);
        end

        listener.Update = function(sender, args)
            sender:SetWantsUpdates(false);
            HandleDisplaySizeChanged();
        end

        listener:SetVisible(true);
        displaySizeListener = listener;
    end);

    if (not ok) then
        displaySizeListener = nil;
        if (listener ~= nil) then
            pcall(function()
                listener:SetWantsUpdates(false);
                listener:SetVisible(false);
            end);
        end

        local message = L.displaySizeListenerFailed
            or "Display-resolution monitoring could not be initialized.";
        WriteChatLine(message);
        return false;
    end

    return true;
end

local chatAnnounceTimer = Turbine.UI.Control();
chatAnnounceTimer:SetWantsUpdates(false);
chatAnnounceTimer.targetTime = nil;

chatAnnounceTimer.Update = function(sender, args)
    if (sender.targetTime ~= nil and Turbine.Engine.GetGameTime() >= sender.targetTime) then
        sender:SetWantsUpdates(false);
        sender.targetTime = nil;
        AnnounceActiveEventsInChat();
    end
end

local function GetLatestCalendarEnd()
    local latest = nil;

    for _, event in ipairs(DuskLOTROEvents.Events) do
        if (event.ends ~= nil and (latest == nil or event.ends > latest)) then
            latest = event.ends;
        end
    end

    for _, notice in ipairs(DuskLOTROEvents.Notices) do
        if (notice.ends ~= nil and (latest == nil or notice.ends > latest)) then
            latest = notice.ends;
        end
    end

    return latest;
end

local function WarnIfCalendarCoverageLow()
    local latest = GetLatestCalendarEnd();
    if (latest == nil) then
        return;
    end

    local now = GetNow();
    local formattedEnd = Time.FormatDate(latest, localeKey, GetDisplayZone());

    if (latest <= now) then
        WriteChatLine(string.format(L.calendarCoverageExpired, formattedEnd));
    elseif ((latest - now) <= (CALENDAR_COVERAGE_WARNING_DAYS * 86400)) then
        WriteChatLine(string.format(L.calendarCoverageExpiring, formattedEnd));
    end
end

local function StartChatAnnouncement()
    if (settings.chatAnnounceActive ~= true) then
        return;
    end

    if (CHAT_ANNOUNCE_DELAY <= 0) then
        AnnounceActiveEventsInChat();
        return;
    end

    chatAnnounceTimer.targetTime = Turbine.Engine.GetGameTime() + CHAT_ANNOUNCE_DELAY;
    chatAnnounceTimer:SetWantsUpdates(true);
end

CreateLauncherIcon();
CreateDisplaySizeListener();
WarnIfCalendarCoverageLow();
StartChatAnnouncement();

if (plugin ~= nil) then
    local function RemoveOptionView(target)
        if (target == nil) then return; end
        for i = #optionViews, 1, -1 do
            if (optionViews[i] == target) then
                table.remove(optionViews, i);
                return;
            end
        end
    end

    local function GetPluginOptionsPanelSize()
        local displayWidth = Turbine.UI.Display:GetWidth();
        local displayHeight = Turbine.UI.Display:GetHeight();
        local width = math.min(720, math.max(500, displayWidth - 120));
        local height = math.min(620, math.max(300, displayHeight - 160));
        return width, height;
    end

    local function EnsurePluginOptionsPanel()
        if (pluginOptionsPanel ~= nil) then
            return;
        end

        local width, height = GetPluginOptionsPanelSize();
        pluginOptionsPanel = Turbine.UI.Control();
        pluginOptionsPanel:SetSize(width, height);
        pluginOptionsPanel:SetBackColor(PANEL_BACK_COLOR);

        -- LOTRO's Plugin Manager keeps the object returned by GetOptionsPanel().
        -- Never replace this root control. When LOTRO resizes it, rebuild only
        -- the child content against the new dimensions.
        pluginOptionsPanel.SizeChanged = function(sender, args)
            if (RebuildPluginOptionsContent ~= nil) then
                RebuildPluginOptionsContent();
            end
        end
    end

    RebuildPluginOptionsContent = function()
        EnsurePluginOptionsPanel();

        local width = pluginOptionsPanel:GetWidth();
        local height = pluginOptionsPanel:GetHeight();
        if (width <= 0 or height <= 0) then
            return;
        end

        if (pluginOptionsContent ~= nil and
            pluginOptionsContent:GetWidth() == width and
            pluginOptionsContent:GetHeight() == height and
            pluginOptionsView ~= nil) then
            pluginOptionsView:Refresh();
            return;
        end

        RemoveOptionView(pluginOptionsView);
        pluginOptionsView = nil;

        if (pluginOptionsContent ~= nil) then
            pcall(function()
                pluginOptionsContent:SetVisible(false);
                pluginOptionsContent:SetParent(nil);
            end);
        end

        pluginOptionsContent = Turbine.UI.Control();
        pluginOptionsContent:SetParent(pluginOptionsPanel);
        pluginOptionsContent:SetPosition(0, 0);
        pluginOptionsContent:SetSize(width, height);
        pluginOptionsContent:SetBackColor(PANEL_BACK_COLOR);
        pluginOptionsView = BuildOptionsPanel(pluginOptionsContent, width, height, false, true);
    end

    EnsurePluginOptionsPanel();
    RebuildPluginOptionsContent();

    plugin.GetOptionsPanel = function(self)
        -- Always return the exact same root object. The Plugin Manager may keep
        -- this reference for as long as the plugin is loaded.
        EnsurePluginOptionsPanel();
        RebuildPluginOptionsContent();
        if (pluginOptionsView ~= nil and pluginOptionsView.DisarmReset ~= nil) then
            pluginOptionsView:DisarmReset();
        end
        if (pluginOptionsView ~= nil) then
            pluginOptionsView:Refresh();
        end
        return pluginOptionsPanel;
    end

    plugin.Unload = function(sender, args)
        if (chatAnnounceTimer ~= nil) then
            chatAnnounceTimer:SetWantsUpdates(false);
            chatAnnounceTimer.targetTime = nil;
        end
        if (eventWindow ~= nil) then
            eventWindow:SetWantsUpdates(false);
            nextWindowRefreshTime = nil;
        end
        if (displaySizeListener ~= nil) then
            pcall(function()
                displaySizeListener:SetWantsUpdates(false);
                displaySizeListener:SetVisible(false);
            end);
        end
        if (commandRegistered) then
            pcall(function()
                Turbine.Shell.RemoveCommand(eventsCommand);
            end);
        end
        if (launcherWindow ~= nil) then
            settings.iconX = launcherWindow:GetLeft();
            settings.iconY = launcherWindow:GetTop();
        end
        if (eventWindow ~= nil and settings.rememberWindowPosition) then
            settings.windowX = eventWindow:GetLeft();
            settings.windowY = eventWindow:GetTop();
        end
        SaveSettingsSilently();
    end
end

