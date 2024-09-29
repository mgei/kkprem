# Krankenkassen Prämien

- Entwicklung
- Franchisen
- Regionale Unterschiede

## Daten

* Aktuell: https://www.priminfo.admin.ch/de/downloads/aktuell
* Archiv: https://opendata.swiss/de/dataset/health-insurance-premiums
* Versicherer: https://www.bag.admin.ch/bag/de/home/versicherungen/krankenversicherung/krankenversicherung-versicherer-aufsicht/verzeichnisse-krankenundrueckversicherer.html

`00-loaddata.R` to download data
`01-data.R` to process data

Required edits:

* change `archive_urls` according to https://opendata.swiss/de/dataset/health-insurance-premiums
* change `current_url` and `current_files` according to https://opendata.swiss/de/dataset/health-insurance-premiums

## Franchisen

`02-franchisen.R`

![](figures/p1-franchisenBS.png)

![](figures/p2-insureeCosts.png)

![](figures/p3-insureeCosts.png)

## Prämien

`03-praemien.R`

Billigste Versicherung in BS bei hoher Franchise (Erwachsene, ohne Unfall)?

![](figures/p4-billigsteBS.png)

![](figures/p5-sanitasCompactOneBS.png)

Kinder?

![](figures/p6-billigsteBS.png)

![](figures/p7-agrismartBS.png)

![](figures/p8-qualimedBS.png)

Unfall-Zusatz kostet im Schnitt rund 6.5% mehr. Warum aber Unfall bei Kinder? Was passiert wenn Kind verunfallt und kein Unfall-Zusatz abgeschlossen wurde?

## Versicherte

`04-versicherte.R`

![](figures/p9-marktanteil.png)

