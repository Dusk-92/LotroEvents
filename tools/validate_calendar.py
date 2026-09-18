#!/usr/bin/env python3
"""Static validation for LOTRO Events calendar/release data."""

from __future__ import annotations

import re
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CALENDAR = ROOT / "Dusk" / "LOTROEvents" / "Calendar.lua"
LOCALIZATION = ROOT / "Dusk" / "LOTROEvents" / "Localization.lua"
PLUGIN = ROOT / "Dusk" / "LOTROEvents.plugin"
README = ROOT / "Dusk" / "LOTROEvents" / "README_LOTROEvents.txt"

errors: list[str] = []


def read(path: Path) -> str:
    if not path.is_file():
        errors.append(f"Missing required file: {path.relative_to(ROOT)}")
        return ""
    return path.read_text(encoding="utf-8")


calendar = read(CALENDAR)
localization = read(LOCALIZATION)
plugin = read(PLUGIN)
readme = read(README)

# Ignore full-line Lua comments so documentation examples are not treated as data.
calendar_active = "\n".join(
    line for line in calendar.splitlines() if not line.lstrip().startswith("--")
)

event_re = re.compile(
    r'\bEvent\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"'
    r'(?:\s*,\s*(true|false))?\s*\)'
)
notice_re = re.compile(
    r'\bNotice\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*(true|false)\s*\)'
)
new_event_re = re.compile(
    r'\bNewEvent\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,'
    r'\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"'
    r'(?:\s*,\s*(true|false))?\s*\)'
)
new_notice_re = re.compile(
    r'\bNewNotice\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,'
    r'\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*(true|false)\s*\)'
)

events = [
    {"key": m.group(1), "start": m.group(2), "end": m.group(3)}
    for m in event_re.finditer(calendar_active)
]
notices = [
    {"key": m.group(1), "date": m.group(2)}
    for m in notice_re.finditer(calendar_active)
]
new_events = [
    {"key": m.group(1), "start": m.group(5), "end": m.group(6)}
    for m in new_event_re.finditer(calendar_active)
]
new_notices = [
    {"key": m.group(1), "date": m.group(5)}
    for m in new_notice_re.finditer(calendar_active)
]

all_events = events + new_events
all_notices = notices + new_notices

seen_events: set[tuple[str, str]] = set()
for item in all_events:
    identity = (item["key"], item["start"])
    if identity in seen_events:
        errors.append(f"Duplicate event key/start: {identity[0]} @ {identity[1]}")
    seen_events.add(identity)

    try:
        start = datetime.strptime(item["start"], "%Y-%m-%d %H:%M")
        end = datetime.strptime(item["end"], "%Y-%m-%d %H:%M")
    except ValueError as exc:
        errors.append(f"Invalid event date for {item['key']}: {exc}")
        continue
    if end <= start:
        errors.append(
            f"Event end is not after start: {item['key']} "
            f"({item['start']} -> {item['end']})"
        )

seen_notices: set[tuple[str, str]] = set()
for item in all_notices:
    identity = (item["key"], item["date"])
    if identity in seen_notices:
        errors.append(f"Duplicate notice key/date: {identity[0]} @ {identity[1]}")
    seen_notices.add(identity)
    try:
        datetime.strptime(item["date"], "%Y-%m-%d")
    except ValueError as exc:
        errors.append(f"Invalid notice date for {item['key']}: {exc}")

# Event-name keys.
event_names_part = localization.split("DuskLOTROEvents.EventNames = {", 1)
if len(event_names_part) != 2:
    errors.append("Unable to locate DuskLOTROEvents.EventNames")
    defined_keys: set[str] = set()
else:
    defined_keys = set(
        re.findall(r"^    ([a-z0-9_]+)\s*=\s*\{\s*$", event_names_part[1], re.M)
    )

used_keys = {item["key"] for item in events + notices}
# NewEvent/NewNotice define their own names at runtime.
runtime_defined = {item["key"] for item in new_events + new_notices}
missing_keys = sorted(used_keys - defined_keys)
unused_keys = sorted(defined_keys - used_keys - runtime_defined)
if missing_keys:
    errors.append("Calendar keys missing from EventNames: " + ", ".join(missing_keys))
if unused_keys:
    errors.append("Unused EventNames keys: " + ", ".join(unused_keys))

# Check every static EventNames block has EN/FR/DE strings.
if len(event_names_part) == 2:
    blocks = list(
        re.finditer(
            r"^    ([a-z0-9_]+)\s*=\s*\{\s*\n(.*?)^    \},\s*$",
            event_names_part[1],
            re.M | re.S,
        )
    )
    for match in blocks:
        key = match.group(1)
        body = match.group(2)
        for lang in ("en", "fr", "de"):
            if not re.search(rf'^        {lang}\s*=\s*"[^"]+"', body, re.M):
                errors.append(f"EventNames.{key} is missing {lang}")

# UI-localization parity.
def ui_keys(lang: str) -> set[str]:
    marker = f"    {lang} = {{"
    start = localization.find(marker)
    if start < 0:
        errors.append(f"Missing localization table: {lang}")
        return set()
    end = localization.find("\n    },", start)
    if end < 0:
        errors.append(f"Unable to parse localization table: {lang}")
        return set()
    block = localization[start:end]
    return set(re.findall(r"^        ([A-Za-z0-9_]+)\s*=", block, re.M))


en_keys = ui_keys("en")
for lang in ("fr", "de"):
    keys = ui_keys(lang)
    missing = sorted(en_keys - keys)
    extra = sorted(keys - en_keys)
    if missing:
        errors.append(f"{lang} localization missing keys: " + ", ".join(missing))
    if extra:
        errors.append(f"{lang} localization has extra keys: " + ", ".join(extra))

# Release version consistency.
plugin_match = re.search(r"<Version>([^<]+)</Version>", plugin)
readme_match = re.search(r"^LOTRO Events ([^\r\n]+)", readme, re.M)
plugin_version = plugin_match.group(1) if plugin_match else None
readme_version = readme_match.group(1) if readme_match else None

if not plugin_version:
    errors.append("Unable to read version from LOTROEvents.plugin")
if not readme_version:
    errors.append("Unable to read version from README_LOTROEvents.txt")
if plugin_version and readme_version and plugin_version != readme_version:
    errors.append(
        f"Version mismatch: plugin={plugin_version}, README={readme_version}"
    )
if plugin_version and f"CHANGES {plugin_version}" not in readme:
    errors.append(f"README changelog has no CHANGES {plugin_version} section")

if errors:
    print("LOTRO Events validation FAILED:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print(
    "LOTRO Events validation OK — "
    f"{len(all_events)} events, {len(all_notices)} notices, "
    f"{len(defined_keys) + len(runtime_defined)} event-name keys, "
    f"version {plugin_version}."
)
