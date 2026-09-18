# LOTRO Events

Plugin LOTRO de calendrier d’événements par **Dusk**.

Version actuelle : **0.11.20**

LOTRO Events affiche les événements actifs, les prochains événements et les dates ponctuelles dans une fenêtre dédiée avec vues **Liste** et **Calendrier**. L’addon prend en charge les clients anglais, français et allemands, ainsi que l’heure serveur LOTRO, l’Europe et le Royaume-Uni avec gestion des changements d’heure.

## Installation

Copie le dossier `Dusk` dans :

```text
Documents\The Lord of the Rings Online\Plugins\
```

Puis en jeu :

```text
/plugins refresh
/plugins load LOTROEvents
```

Commandes disponibles :

- `/events`
- `/lotroevents`

## Fichiers principaux

- `Dusk/LOTROEvents/Calendar.lua` — calendrier des événements.
- `Dusk/LOTROEvents/Localization.lua` — textes EN/FR/DE.
- `Dusk/LOTROEvents/Time.lua` — conversions horaires et DST.
- `Dusk/LOTROEvents/Main.lua` — interface et logique du plugin.
- `Dusk/LOTROEvents/README_LOTROEvents.txt` — documentation complète et historique des versions.

## Validation

Le dépôt contient un contrôle automatique du calendrier :

```bash
python3 tools/validate_calendar.py
```

Il vérifie notamment les doublons, les dates invalides, les clés de traduction, la parité EN/FR/DE et la cohérence de version.

## Source du calendrier

Les horaires sont enregistrés en **heure serveur LOTRO / US Eastern**, à partir du calendrier public officiel anglais de Standing Stone Games.

Les dates officielles pouvant changer, `Calendar.lua` reste volontairement simple à mettre à jour.
