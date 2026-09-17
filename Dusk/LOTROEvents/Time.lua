-- LOTRO Events - date/time engine
--
-- Calendar.lua stores event start/end times in official LOTRO SERVER TIME
-- (US Eastern), exactly as shown by the official English schedule.
-- This file converts them to UTC and formats them for EN/EN-GB/FR/DE clients.
-- Display timezone is configurable independently from the client language.
-- Normal users should only need to edit Calendar.lua.

DuskLOTROEvents = DuskLOTROEvents or {};
DuskLOTROEvents.Events = {};
DuskLOTROEvents.Notices = {};
DuskLOTROEvents.Time = {};

local Time = DuskLOTROEvents.Time;
local seenEventStarts = {};
local seenNotices = {};

local MONTHS_EN = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
};

local DAYS_IN_MONTH = {
    31, 28, 31, 30, 31, 30,
    31, 31, 30, 31, 30, 31
};

local function IsLeapYear(year)
    return ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0);
end

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

local function EpochToDate(timestamp, offsetSeconds)
    local total = math.floor(timestamp + (offsetSeconds or 0));
    local days = math.floor(total / 86400);
    local secondsOfDay = total - (days * 86400);

    if (secondsOfDay < 0) then
        days = days - 1;
        secondsOfDay = secondsOfDay + 86400;
    end

    local year = 1970;

    if (days >= 0) then
        while true do
            local yearDays = IsLeapYear(year) and 366 or 365;
            if (days < yearDays) then
                break;
            end
            days = days - yearDays;
            year = year + 1;
        end
    else
        repeat
            year = year - 1;
            days = days + (IsLeapYear(year) and 366 or 365);
        until (days >= 0);
    end

    local month = 1;
    while true do
        local monthDays = GetDaysInMonth(year, month);
        if (days < monthDays) then
            break;
        end
        days = days - monthDays;
        month = month + 1;
    end

    local day = days + 1;
    local hour = math.floor(secondsOfDay / 3600);
    secondsOfDay = secondsOfDay - (hour * 3600);
    local minute = math.floor(secondsOfDay / 60);
    local second = secondsOfDay - (minute * 60);

    return year, month, day, hour, minute, second;
end

-- Sunday = 0, Monday = 1, ... Saturday = 6.
local function DayOfWeek(year, month, day)
    local days = math.floor(DateToEpochUTC(year, month, day, 0, 0, 0) / 86400);
    return (days + 4) % 7; -- 1970-01-01 was Thursday.
end

local function NthSunday(year, month, occurrence)
    local firstDow = DayOfWeek(year, month, 1);
    local firstSunday = 1 + ((7 - firstDow) % 7);
    return firstSunday + ((occurrence - 1) * 7);
end

local function LastSunday(year, month)
    local lastDay = GetDaysInMonth(year, month);
    local lastDow = DayOfWeek(year, month, lastDay);
    return lastDay - (lastDow % 7);
end

local function ParseDateTime(text)
    local year, month, day, hour, minute = string.match(
        tostring(text or ""),
        "^(%d%d%d%d)%-(%d%d)%-(%d%d)%s+(%d%d):(%d%d)$"
    );

    year = tonumber(year);
    month = tonumber(month);
    day = tonumber(day);
    hour = tonumber(hour);
    minute = tonumber(minute);

    if (year == nil or month == nil or day == nil or hour == nil or minute == nil) then
        error("LOTRO Events: invalid date '" .. tostring(text) .. "'. Expected YYYY-MM-DD HH:MM");
    end

    if (month < 1 or month > 12) then
        error("LOTRO Events: invalid month in '" .. tostring(text) .. "'.");
    end

    if (day < 1 or day > GetDaysInMonth(year, month)) then
        error("LOTRO Events: invalid day in '" .. tostring(text) .. "'.");
    end

    if (hour < 0 or hour > 23 or minute < 0 or minute > 59) then
        error("LOTRO Events: invalid time in '" .. tostring(text) .. "'.");
    end

    return year, month, day, hour, minute;
end

local function ParsePlainDate(text)
    local year, month, day = string.match(
        tostring(text or ""),
        "^(%d%d%d%d)%-(%d%d)%-(%d%d)$"
    );

    year = tonumber(year);
    month = tonumber(month);
    day = tonumber(day);

    if (year == nil or month == nil or day == nil) then
        error("LOTRO Events: invalid date '" .. tostring(text) .. "'. Expected YYYY-MM-DD");
    end

    if (month < 1 or month > 12) then
        error("LOTRO Events: invalid month in '" .. tostring(text) .. "'.");
    end

    if (day < 1 or day > GetDaysInMonth(year, month)) then
        error("LOTRO Events: invalid day in '" .. tostring(text) .. "'.");
    end

    return year, month, day;
end

local function AddOneDay(year, month, day)
    day = day + 1;
    if (day > GetDaysInMonth(year, month)) then
        day = 1;
        month = month + 1;
        if (month > 12) then
            month = 1;
            year = year + 1;
        end
    end
    return year, month, day;
end

-- US Eastern local DST validation/conversion. Ambiguous/nonexistent local times
-- are rejected instead of silently guessing.
local function IsEasternDSTLocal(year, month, day, hour)
    local startDay = NthSunday(year, 3, 2);
    local endDay = NthSunday(year, 11, 1);

    if (month > 3 and month < 11) then
        return true;
    end

    if (month < 3 or month > 11) then
        return false;
    end

    if (month == 3) then
        if (day < startDay) then
            return false;
        elseif (day > startDay) then
            return true;
        end

        if (hour == 2) then
            error("LOTRO Events: nonexistent US Eastern local time during DST switch (02:xx).");
        end
        return hour >= 3;
    end

    -- November: 01:xx occurs twice when daylight time ends.
    if (day < endDay) then
        return true;
    elseif (day > endDay) then
        return false;
    end

    if (hour == 1) then
        error("LOTRO Events: ambiguous US Eastern local time during DST switch (01:xx).");
    end
    return hour < 1;
end

function Time.ServerLocalDateToEpoch(text)
    local year, month, day, hour, minute = ParseDateTime(text);
    local offset = IsEasternDSTLocal(year, month, day, hour) and (-4 * 3600) or (-5 * 3600);

    -- local time = UTC + offset, so UTC = local - offset.
    return DateToEpochUTC(year, month, day, hour, minute, 0) - offset;
end

local function GetEasternOffset(timestamp)
    local year = select(1, EpochToDate(timestamp, 0));
    local dstStartDay = NthSunday(year, 3, 2);
    local dstEndDay = NthSunday(year, 11, 1);
    local dstStart = DateToEpochUTC(year, 3, dstStartDay, 7, 0, 0);
    local dstEnd = DateToEpochUTC(year, 11, dstEndDay, 6, 0, 0);

    if (timestamp >= dstStart and timestamp < dstEnd) then
        return -4 * 3600;
    end

    return -5 * 3600;
end

local function GetCentralEuropeanOffset(timestamp)
    local year = select(1, EpochToDate(timestamp, 0));
    local dstStartDay = LastSunday(year, 3);
    local dstEndDay = LastSunday(year, 10);
    local dstStart = DateToEpochUTC(year, 3, dstStartDay, 1, 0, 0);
    local dstEnd = DateToEpochUTC(year, 10, dstEndDay, 1, 0, 0);

    if (timestamp >= dstStart and timestamp < dstEnd) then
        return 2 * 3600;
    end

    return 1 * 3600;
end

local function GetBritishOffset(timestamp)
    local year = select(1, EpochToDate(timestamp, 0));
    local dstStartDay = LastSunday(year, 3);
    local dstEndDay = LastSunday(year, 10);
    local dstStart = DateToEpochUTC(year, 3, dstStartDay, 1, 0, 0);
    local dstEnd = DateToEpochUTC(year, 10, dstEndDay, 1, 0, 0);

    if (timestamp >= dstStart and timestamp < dstEnd) then
        return 1 * 3600;
    end

    return 0;
end

function Time.ResolveDisplayZone(requestedZone, localeKey)
    if (requestedZone == "server" or requestedZone == "eu" or requestedZone == "uk") then
        return requestedZone;
    end

    -- Auto mode provides a sensible display timezone for each client language.
    if (localeKey == "fr" or localeKey == "de") then
        return "eu";
    elseif (localeKey == "enGB") then
        return "uk";
    end

    return "server";
end

local function GetDisplayOffset(timestamp, zoneKey)
    if (zoneKey == "eu") then
        return GetCentralEuropeanOffset(timestamp);
    elseif (zoneKey == "uk") then
        return GetBritishOffset(timestamp);
    end

    return GetEasternOffset(timestamp);
end

function Time.GetDateParts(timestamp, zoneKey)
    return EpochToDate(timestamp, GetDisplayOffset(timestamp, zoneKey));
end

-- Add calendar days without involving a timezone or DST transition. This is
-- used for date-only notices, whose horizon is a local calendar date rather
-- than an exact number of elapsed seconds.
function Time.AddCalendarDays(year, month, day, days)
    local offsetDays = math.floor(tonumber(days) or 0);
    local timestamp = DateToEpochUTC(year, month, day, 0, 0, 0)
        + (offsetDays * 86400);
    return EpochToDate(timestamp, 0);
end

function Time.FormatDate(timestamp, localeKey, zoneKey)
    local offset = GetDisplayOffset(timestamp, zoneKey or Time.ResolveDisplayZone("auto", localeKey));

    local year, month, day, hour, minute = EpochToDate(timestamp, offset);

    if (localeKey == "fr") then
        return string.format("%02d/%02d/%04d %02d:%02d", day, month, year, hour, minute);
    end

    if (localeKey == "de") then
        return string.format("%02d.%02d.%04d %02d:%02d", day, month, year, hour, minute);
    end

    if (localeKey == "enGB") then
        return string.format("%d %s %04d %02d:%02d", day, MONTHS_EN[month], year, hour, minute);
    end

    local suffix = (hour >= 12) and "PM" or "AM";
    local hour12 = hour % 12;
    if (hour12 == 0) then
        hour12 = 12;
    end

    return string.format("%s %d, %04d %d:%02d %s",
        MONTHS_EN[month], day, year, hour12, minute, suffix);
end

function Time.FormatPlainDate(year, month, day, localeKey)
    if (localeKey == "fr") then
        return string.format("%02d/%02d/%04d", day, month, year);
    end

    if (localeKey == "de") then
        return string.format("%02d.%02d.%04d", day, month, year);
    end

    if (localeKey == "enGB") then
        return string.format("%d %s %04d", day, MONTHS_EN[month], year);
    end

    return string.format("%s %d, %04d", MONTHS_EN[month], day, year);
end

function Time.ServerDateDayRange(text)
    local year, month, day = ParsePlainDate(text);
    local nextYear, nextMonth, nextDay = AddOneDay(year, month, day);
    local startText = string.format("%04d-%02d-%02d 00:00", year, month, day);
    local endText = string.format("%04d-%02d-%02d 00:00", nextYear, nextMonth, nextDay);

    return Time.ServerLocalDateToEpoch(startText), Time.ServerLocalDateToEpoch(endText), year, month, day;
end

local function ValidateNameKey(nameKey)
    if (type(nameKey) ~= "string" or nameKey == "") then
        error("LOTRO Events: event key must be a non-empty string.");
    end
end

local function ValidateNames(englishName, frenchName, germanName)
    if (type(englishName) ~= "string" or englishName == ""
        or type(frenchName) ~= "string" or frenchName == ""
        or type(germanName) ~= "string" or germanName == "") then
        error("LOTRO Events: EN/FR/DE names must all be non-empty strings.");
    end
end

local function ValidateOptionalBoolean(value, fieldName)
    if (value ~= nil and type(value) ~= "boolean") then
        error("LOTRO Events: " .. fieldName .. " must be true, false, or omitted.");
    end
end

local function ValidateBoolean(value, fieldName)
    if (type(value) ~= "boolean") then
        error("LOTRO Events: " .. fieldName .. " must be true or false.");
    end
end

local function BuildEventTimes(nameKey, startText, endText)
    local starts = Time.ServerLocalDateToEpoch(startText);
    local ends = Time.ServerLocalDateToEpoch(endText);

    if (ends <= starts) then
        error("LOTRO Events: end date must be after start date for '" .. tostring(nameKey) .. "'.");
    end

    return starts, ends;
end

local function CheckEventDuplicate(nameKey, starts)
    local startKey = nameKey .. "|" .. tostring(starts);
    if (seenEventStarts[startKey]) then
        error("LOTRO Events: duplicate event '" .. tostring(nameKey) .. "' with the same start date/time.");
    end

    return startKey;
end

local function InsertEvent(nameKey, starts, ends, announceAtLogin, startKey)
    seenEventStarts[startKey] = true;

    table.insert(DuskLOTROEvents.Events, {
        nameKey = nameKey,
        starts = starts,
        ends = ends,
        announceAtLogin = (announceAtLogin ~= false),
    });
end

local function BuildNoticeDate(dateText)
    return Time.ServerDateDayRange(dateText);
end

local function CheckNoticeDuplicate(nameKey, year, month, day)
    local duplicateKey = nameKey .. "|" .. tostring(year) .. "-" .. tostring(month) .. "-" .. tostring(day);

    if (seenNotices[duplicateKey]) then
        error("LOTRO Events: duplicate notice '" .. tostring(nameKey) .. "' on the same date.");
    end

    return duplicateKey;
end

local function InsertNotice(nameKey, starts, ends, year, month, day, approximate, duplicateKey)
    seenNotices[duplicateKey] = true;

    table.insert(DuskLOTROEvents.Notices, {
        nameKey = nameKey,
        starts = starts,
        ends = ends,
        year = year,
        month = month,
        day = day,
        approximate = approximate,
    });
end

function DuskLOTROEvents.Event(nameKey, startText, endText, announceAtLogin)
    ValidateNameKey(nameKey);
    ValidateOptionalBoolean(announceAtLogin, "announceAtLogin");

    if (DuskLOTROEvents.EventNames == nil or DuskLOTROEvents.EventNames[nameKey] == nil) then
        error("LOTRO Events: unknown event key '" .. tostring(nameKey) .. "'. Use NewEvent(...) for a new event.");
    end

    local starts, ends = BuildEventTimes(nameKey, startText, endText);
    local startKey = CheckEventDuplicate(nameKey, starts);
    InsertEvent(nameKey, starts, ends, announceAtLogin, startKey);
end

function DuskLOTROEvents.Notice(nameKey, dateText, approximate)
    ValidateNameKey(nameKey);
    ValidateBoolean(approximate, "approximate");

    if (DuskLOTROEvents.EventNames == nil or DuskLOTROEvents.EventNames[nameKey] == nil) then
        error("LOTRO Events: unknown notice key '" .. tostring(nameKey) .. "'. Use NewNotice(...) for a new notice.");
    end

    local starts, ends, year, month, day = BuildNoticeDate(dateText);
    local duplicateKey = CheckNoticeDuplicate(nameKey, year, month, day);
    InsertNotice(nameKey, starts, ends, year, month, day, approximate, duplicateKey);
end

function DuskLOTROEvents.NewEvent(nameKey, englishName, frenchName, germanName, startText, endText, announceAtLogin)
    ValidateNameKey(nameKey);
    ValidateNames(englishName, frenchName, germanName);
    ValidateOptionalBoolean(announceAtLogin, "announceAtLogin");

    if (DuskLOTROEvents.EventNames == nil) then
        DuskLOTROEvents.EventNames = {};
    end

    if (DuskLOTROEvents.EventNames[nameKey] ~= nil) then
        error("LOTRO Events: event key '" .. tostring(nameKey) .. "' already exists.");
    end

    -- Validate everything before mutating EventNames, then insert without
    -- repeating the duplicate check.
    local starts, ends = BuildEventTimes(nameKey, startText, endText);
    local startKey = CheckEventDuplicate(nameKey, starts);

    DuskLOTROEvents.EventNames[nameKey] = {
        en = englishName,
        fr = frenchName,
        de = germanName,
    };

    InsertEvent(nameKey, starts, ends, announceAtLogin, startKey);
end

function DuskLOTROEvents.NewNotice(nameKey, englishName, frenchName, germanName, dateText, approximate)
    ValidateNameKey(nameKey);
    ValidateNames(englishName, frenchName, germanName);
    ValidateBoolean(approximate, "approximate");

    if (DuskLOTROEvents.EventNames == nil) then
        DuskLOTROEvents.EventNames = {};
    end

    if (DuskLOTROEvents.EventNames[nameKey] ~= nil) then
        error("LOTRO Events: notice key '" .. tostring(nameKey) .. "' already exists.");
    end

    -- Validate everything before mutating EventNames, then insert without
    -- repeating the duplicate check.
    local starts, ends, year, month, day = BuildNoticeDate(dateText);
    local duplicateKey = CheckNoticeDuplicate(nameKey, year, month, day);

    DuskLOTROEvents.EventNames[nameKey] = {
        en = englishName,
        fr = frenchName,
        de = germanName,
    };

    InsertNotice(nameKey, starts, ends, year, month, day, approximate, duplicateKey);
end
