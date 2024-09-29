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
