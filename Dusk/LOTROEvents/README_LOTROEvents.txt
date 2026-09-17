LOTRO Events 0.11.19
====================
Auteur / Author: Dusk

FRANÇAIS
========
LOTRO Events affiche les événements dans une fenêtre dédiée. Au chargement, il peut
aussi annoncer dans le chat uniquement les événements actuellement en cours. Cette
annonce est activable ou désactivable dans les options. Aucun événement à venir ni
aucune notice n'est publiée automatiquement dans le chat.

La fenêtre ne s'ouvre plus automatiquement au chargement. Une icône 32x32 reste
affichée en jeu : clic gauche pour ouvrir/fermer LOTRO Events, et glisser-déposer
pour déplacer l'icône. Sa position est sauvegardée pour tout le compte.

La fenêtre affiche :
  - les événements actuellement actifs ;
  - les événements qui commencent dans les 30 prochains jours ;
  - les dates ponctuelles / notices prévues dans les 30 prochains jours.
Par défaut, les événements de plus de 30 jours sont masqués de la vue Liste ;
ce comportement est réglable dans les options.

Fermer la fenêtre ne masque pas l'icône : elle reste disponible à tout moment.
/events et /lotroevents continuent également d'ouvrir la fenêtre manuellement.

Installation
------------
Copier le dossier "Dusk" dans :
  Documents\The Lord of the Rings Online\Plugins\

Puis en jeu :
  /plugins refresh
  /plugins load LOTROEvents

Commande
--------
  /events        ouvre ou rouvre la fenêtre à tout moment
  /lotroevents   alias de secours de /events

Aucune de ces commandes n'écrit la liste des événements dans le chat.

Options
-------
La roue crantée en haut à droite de la fenêtre ouvre les réglages. Les mêmes
réglages sont également disponibles dans le gestionnaire de plugins de LOTRO.
Ils permettent notamment de gérer l'icône du plugin, l'annonce des événements actifs
dans le chat, l'inclusion facultative des événements de plus de 30 jours dans cette
annonce, la période 7/14/30 jours, les événements longs, l'affichage du calendrier,
la taille/position de la fenêtre et le fuseau horaire. Le mode de fuseau « Automatique »
se base sur la langue du client LOTRO.

Ajouter / modifier le calendrier
--------------------------------
Tu ne modifies normalement que :
  Dusk\LOTROEvents\Calendar.lua

Les heures sont en HEURE SERVEUR LOTRO (US Eastern), comme sur le calendrier
officiel anglais.

Périmètre : les changements de niveau maximum des serveurs légendaires Angmar/Mordor
ne sont volontairement pas suivis : ce sont des jalons de progression de serveur, pas
des événements publics récurrents.
Le cadeau du 19e anniversaire est également exclu volontairement : sa disponibilité
s'étend sur presque une année et ne correspond pas à un événement public récurrent.

Événement déjà connu :
  Event("treasure_bugan", "2027-03-04 10:00", "2027-03-10 03:00");

Le 4e paramètre facultatif true/false contrôle l'annonce automatique dans le chat :
false masque cet événement de l'annonce au chargement, sans le retirer de la fenêtre.

Date sans durée :
  Notice("filbert_fig", "2027-11-04", true);

Pour Notice, le dernier paramètre est obligatoire :
  true = date approximative ; false = date exacte.

ENGLISH
=======
LOTRO Events shows events in a dedicated window. On plugin load it can also announce
only the events that are currently active in chat. This can be enabled or disabled
in the options. Upcoming events and notices are never posted automatically to chat.

The window no longer opens automatically when the plugin loads. A floating 32x32 plugin
icon remains visible in game: left-click it to open/close LOTRO Events and drag it
to move it. Its position is saved for the whole account. The window shows active
events, events starting within the next 30 days, and date-only notices in that
period. Events longer than 30 days are hidden from List view by default and can be
re-enabled in the options. /events and /lotroevents still open the window manually.
Neither command prints the event list to chat.

The optional 4th Event() boolean controls the automatic chat announcement: false
hides that event from the startup chat announcement without removing it from the window.
Events longer than 30 days are excluded from startup chat by default and can be enabled
from the options. Automatic time-zone selection follows the LOTRO client language.

Legendary-server level-cap progression milestones (Angmar/Mordor) are intentionally
out of scope because they are server progression milestones, not recurring public events.
The 19-year Anniversary Gift is also intentionally excluded because its availability
spans almost a full year rather than behaving like a recurring public event.

DEUTSCH
=======
LOTRO Events zeigt Ereignisse in einem eigenen Fenster an. Beim Laden kann das Plugin
zusätzlich ausschließlich aktuell aktive Ereignisse im Chat ankündigen. Diese Funktion
kann in den Optionen ein- oder ausgeschaltet werden; kommende Ereignisse und
Datums-Hinweise werden nie automatisch in den Chat geschrieben. Das Fenster öffnet
sich beim Laden nicht mehr automatisch. Stattdessen bleibt ein verschiebbares 32x32-Symbol sichtbar;
ein Linksklick öffnet oder schließt das Fenster. Die Symbolposition wird für das
gesamte Konto gespeichert.

Das Fenster zeigt aktive Ereignisse, Ereignisse der nächsten 30 Tage und
Datums-Hinweise in diesem Zeitraum. Ereignisse über 30 Tage sind in der Listenansicht
standardmäßig ausgeblendet und können in den Optionen aktiviert werden. /events und
/lotroevents öffnen das Fenster weiterhin manuell. Beide Befehle schreiben keine
Ereignisliste in den Chat.

Der optionale 4. Event()-Parameter true/false steuert die automatische Chat-Ankündigung:
false blendet dieses Ereignis nur aus der Start-Ankündigung aus, nicht aus dem Fenster.
Ereignisse über 30 Tage sind dort standardmäßig ausgeblendet und können in den Optionen
aktiviert werden. Die automatische Zeitzone folgt der Sprache des LOTRO-Clients.

Level-Cap-Fortschritte der legendären Server Angmar/Mordor werden bewusst nicht
erfasst, da sie Server-Fortschrittsmeilensteine und keine wiederkehrenden Events sind.
Das Geschenk zum 19. Jubiläum ist ebenfalls bewusst ausgeschlossen, da es fast ein
ganzes Jahr verfügbar ist und kein wiederkehrendes öffentliches Event darstellt.



CHANGES 0.11.19
- Main window and launcher now use the normal UI layer so native LOTRO panels (including the world map) can appear above them.

CHANGES 0.11.18
- Changed the upcoming events header color to a darker copper orange (#D97A3A) for better contrast with event names.

CHANGES 0.11.17
===============
- Added a localized warning when saved settings cannot be loaded; defaults are used without automatically overwriting the unreadable data.
- If /events is already owned by another plugin but /lotroevents is available, LOTRO Events now explicitly tells the user to use /lotroevents.
- Command-registration exceptions now show the clean localized failure message without raw Lua error text.

CHANGES 0.11.16
===============
- Documentation consistency: English and German now explicitly state that neither upcoming events nor notices are posted automatically to chat.
- No functional Lua changes.

CHANGES 0.11.15
===============
- Documentation/package metadata synchronized with the current release; no functional Lua changes.
- Added the missing 0.11.13 and 0.11.14 changelog entries.

CHANGES 0.11.14
===============
- Moved date-only notices above upcoming events in List view so they stay visible near the top.
- List section order is now Active Events, Notices, then Upcoming Events.

CHANGES 0.11.13
===============
- Added distinct List-view section header colors: active events in green, notices in blue, and upcoming events in orange.

CHANGES 0.11.12
===============
- Enlarged the visible launcher/plugin icon artwork inside the same 32x32 control by
  removing the mostly-transparent 1 px texture padding. The click area and saved
  launcher positioning are unchanged.


CHANGES 0.11.11
===============
- Removed the calendar option for hiding events that span adjacent months; spanning
  events are now always shown while active in the displayed month.
- Renamed the visible icon option to "Show plugin icon" / "Afficher l'icône du plugin".
- Prevents an unload-time silent save from overwriting account settings after a real
  PluginData.Load failure; a later successful explicit save restores normal saving.

CHANGES 0.11.10
===============
- Keeps display-resolution listener failure diagnostics user-friendly by hiding
  the raw Lua error text while preserving the localized warning in chat.

CHANGES 0.11.9
==============
- Reports a clear chat diagnostic if display-resolution monitoring cannot be
  initialized, while leaving the rest of LOTRO Events fully usable.
- Cleans up any partially-created resolution listener after initialization failure.

CHANGES 0.11.8
==============
- Kept the Plugin Manager options root control stable for the full plugin lifetime.
- Rebuilds only the panel's child content when LOTRO resizes the Plugin Manager area,
  avoiding stale/orphaned panel references.
- Removed root-panel replacement from display-resolution handling; the Plugin Manager
  now owns the root panel size and its SizeChanged event drives responsive layout.
- Documented the intentional exclusion of the 19-year Anniversary Gift.

CHANGES 0.11.7
==============
- Fixed Plugin Manager option-view ownership so rebuilding the main LOTRO Events
  window no longer drops the Plugin Manager panel from option synchronization.
- Kept compact Reset Settings text after refresh/disarm on narrow panels.
- Rebuilds the Plugin Manager options panel when the display resolution changes.

CHANGES 0.11.6
==============
- Added compact localized option labels on very narrow panels to avoid horizontal
  clipping on 640x480-class displays.
- Made the LOTRO Plugin Manager options panel responsive instead of fixed at
  720x620; it adapts to the current display whenever the panel is opened.
- Documented that Angmar/Mordor legendary-server level-cap milestones are
  intentionally outside the event calendar scope.

CHANGES 0.11.5
==============
- Fixed the ultra-compact embedded options layout so the final Maintenance
  button stays fully inside the panel on 640x480-class displays.
- Tightened dense-calendar lane spacing on very small rows so five overlapping
  events stay inside their own week instead of bleeding into the next row.
- Reordered the README changelog into strict newest-to-oldest version order.

CHANGES 0.11.4
==============
- Added live display-resolution handling: the launcher is clamped back on screen and
  an open LOTRO Events window is rebuilt to fit the new resolution.
- Added an ultra-compact embedded options layout for very small display heights.
- Restored visible diagnostics when /events and /lotroevents cannot be registered.
- Fixed command-registration result handling when LOTRO returns a boolean status.
- Removed obsolete daily-popup plumbing now that the window is never auto-opened.
- Removed the unused legacy moreSuffix localization strings.
- Reduced unnecessary PluginData writes when the remembered view did not change.
- Settings schema updated to version 11.

CHANGES 0.11.3
==============
- Fixed Default View changing the remembered last-used List/Calendar view.
- /events and /lotroevents now report window-opening Lua errors instead of silently swallowing them.
- Added an option to include/exclude active events longer than 30 days from startup chat; excluded by default.
- Clarified that Automatic time-zone selection follows the LOTRO client language.
- Settings schema bumped to version 10.

CHANGES 0.11.2
==============
- Compact/responsive embedded Options layout for shorter and narrower displays.
- Time-zone changes now refresh the current date from a fresh timestamp.
- Final unload settings save is protected and silent.

CHANGES 0.11.1
==============
- Fixed launcher clicks after moving then locking the icon.
- Refreshes current time when switching views, changing month or pressing Today.
- UTF-8-safe calendar text truncation.
- Keeps the Options view open when rebuilding/resizing the window.
- More distinct deterministic event colors and denser-calendar safeguards.
- Better small-screen clamping and wider timezone selector.

CHANGES 0.11.0
==============
- Restored the optional startup chat announcement.
- Chat output contains only events that are currently active; upcoming events and notices are never posted automatically.
- Added an option to enable/disable active-event chat announcements.
- Startup chat announcement uses a short temporary delay and stays silent when no event is active.

CHANGES 0.10.1
==============
- Reset-all confirmation is automatically disarmed when leaving/reopening the options view.
- Plugin Manager options also reopen with a clean reset confirmation state.
- Settings saves now use PluginData.Save's completion callback and report save failures only when an error occurs.

CHANGES 0.10.0
==============
- Added a gear button in the LOTRO Events window.
- Added the same settings panel to LOTRO's Plugin Manager through GetOptionsPanel.
- General: show/hide launcher, lock launcher, reset launcher position, default view, remember last view.
- List: 7/14/30-day horizon, active events, notices, remaining time, hide events longer than 30 days.
- Calendar: Monday/Sunday week start, notices, long events, month-spanning events, per-event colors.
- Window: Normal/Large size, remember position, center, reset size/position.
- Time zone: Auto, LOTRO server, Europe, United Kingdom.
- Maintenance: reset all settings with confirmation.

CHANGES 0.9.0
=============
- Automatic startup popup disabled.
- Added a draggable 32x32 LOTRO Events launcher icon.
- Left-click the icon to open/close the window.
- Launcher position is saved account-wide.

CHANGES 0.8.2
=============
- Removed the 19-year Anniversary Gift entry.
- Calendar window enlarged for overlapping events.
- Removed +N overflow markers: every event now gets a lane.
- Each event uses a stable distinct calendar color.
- True start/end boundaries are marked with solid colored caps.

CHANGES 0.8.1
=============
- Calendar view redesigned with horizontal multi-day bars, closer to the classic LOTRO calendar layout.
- Event names are no longer repeated in every day cell.
- Up to three overlapping bars are shown per week, with +N overflow markers when needed.

CHANGES 0.8.0
=============
- Added a second Calendar view in the LOTRO Events window.
- New top buttons: List / Calendar.
- The popup still opens once per day and /events still reopens it manually.

CHANGES 0.7.0
=============
- Replaced automatic chat announcements with a dedicated LOTRO-skinned window.
- The window opens immediately, once per local calendar day, account-wide.
- /events and /lotroevents now open the window manually and do not print events.
- The window shows active events plus all events and date-only notices from the
  next 30 calendar days.
- Added a scrollbar for busy months and a Close button; Escape also closes it.
- The legacy Event(..., false) flag now hides long entries only from the automatic
  daily popup; manual /events remains exhaustive.
- Removed the old login delay, auto-announcement and /events next chat workflow.

CHANGES 0.6.3
=============
- Automatic login output now snapshots the current time once and reuses it
  for both the active and upcoming sections. An event starting exactly while
  the announcement is being built can no longer fall between both queries.

CHANGES 0.6.2
=============
- Upcoming event windows now use local calendar days in the selected display
  timezone, exactly like date-only notices. The complete 7th/14th day is
  included even when an event starts later than the current clock time.
- DST changes inside a 7/14-day window can no longer shorten or lengthen the
  effective event horizon.

CHANGES 0.6.1
=============
- Native LOTRO command help now follows the actually registered command name
  when /events or /lotroevents is unavailable because of a conflict.
- Date-only notices now use a true local calendar-day horizon, so entries on
  the 14th day are included correctly regardless of timezone or DST changes.
- In-game help now derives the 14-day window from the same code constant used
  by /events next, avoiding future documentation drift.

CHANGES 0.6.0
=============
- Login announcement now also lists every event starting within the next 7 days.
- /events next now shows every event/date within the next 30 days instead of a
  fixed number of entries. Events starting on the same day are never truncated.
- Date-only notices remain separate from the automatic login upcoming-event list.

CHANGES 0.5.9
=============
- Detects /events and /lotroevents command-name conflicts before registration.
  Any free alias remains usable, and the in-game help automatically follows it.
- Reports partial/failed shell-command registration instead of failing silently.
- Login output now uses a neutral "nothing to announce" message when all active
  entries are intentionally hidden from automatic announcements.

CHANGES 0.5.8
=============
- Added /lotroevents as a safe alias for /events.
- PluginData.Save now uses its completion callback during normal operation so
  asynchronous settings-write failures can be reported instead of staying
  silent.
- Final unload saving stays silent and protected so it cannot interfere with
  cleanup.

CHANGES 0.5.7
=============
- Corrected README/version metadata.
- Cleaned the changelog so removed server-progression notices are no longer
  referenced by specific server-progression names.

CHANGES 0.5.6
=============
- Removed non-event server progression milestones from the embedded calendar.
- Kept useful date-only notices such as Rowan Raspberry, Myrtle Mint and
  Filbert Fig.

CHANGES 0.5.5
=============
- Hardened language detection when Turbine.Language itself is unavailable on a
  historical client build.
- /events next no longer repeats a date-only notice that is already shown as
  today's information.

CHANGES 0.5.4
=============
- Protected PluginData saving with pcall so a write failure cannot crash a
  command or interrupt plugin unload cleanup.
- Unload now removes the shell command before attempting the final settings
  save.
- Fixed the historical language fallback: if GetLanguage() is unavailable, the
  plugin now really tries /hilfe and /aide before falling back to English.
- /events auto off now cancels a still-pending login announcement immediately,
  and changing /events delay during startup reschedules the pending timer.

CHANGES 0.5.3
=============
- Fixed settings migration: a user-selected 3-second delay from 0.5.0/0.5.1 is
  now preserved instead of being changed back to 5 seconds.
- Hardened PluginData loading against invalid/corrupted saved data.
- Added strict boolean validation for Event/NewEvent login flags and
  Notice/NewNotice approximate-date flags.
- Simplified duplicate protection: one canonical key+start check, with no
  redundant exact-duplicate table or double validation pass.
- Added FR/EN/DE README documentation.

Official sources / Sources officielles / Offizielle Quellen
============================================================
Canonical dates/times (US Eastern/server time):
  https://www.lotro.com/news/lotro-public-event-schedule-en


Official name translations:
  https://www.lotro.com/news/lotro-public-event-schedule-fr?locale=fr_FR
  https://www.lotro.com/news/lotro-public-event-schedule-de?locale=de_DE

Important
=========
Standing Stone Games may change schedule dates. Calendar.lua is intentionally
kept simple so those corrections can be made quickly.

The launcher icon is event-driven and does not keep a permanent OnUpdate loop.
The event window still never opens automatically. A short temporary startup delay is used only for the optional active-event chat announcement.

Calendar source
---------------
Canonical schedule (ALL TIMES EASTERN/SERVER TIME):
  https://www.lotro.com/news/lotro-public-event-schedule-en

Translated naming references:
  https://www.lotro.com/news/lotro-public-event-schedule-fr?locale=fr_FR
  https://www.lotro.com/news/lotro-public-event-schedule-de?locale=de_DE

Official event dates and times may change.
