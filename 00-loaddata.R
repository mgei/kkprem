library(tidyverse)
library(lubridate)
options(timeout = 300)

fix_file_names <- function(file_name) {
  # Fix the incorrect characters using `iconv()` and manual replacements
  new_file_name <- iconv(file_name, from = "latin1", to = "UTF-8")
  
  # You can manually fix specific patterns, e.g., \x84 -> ä, \x81 -> ü
  new_file_name <- gsub("\u0084", "ae", new_file_name, fixed = TRUE)
  new_file_name <- gsub("\u0081", "ue", new_file_name, fixed = TRUE)
  new_file_name <- gsub("\u0094", "oe", new_file_name, fixed = TRUE)
  new_file_name <- gsub("ä", "ae", new_file_name, fixed = TRUE)
  new_file_name <- gsub("ü", "ue", new_file_name, fixed = TRUE)
  new_file_name <- gsub("ö", "oe", new_file_name, fixed = TRUE)
  
  # Return the fixed file name
  return(new_file_name)
}

archive_urls <- c("https://bag-files.opendata.swiss/owncloud/index.php/s/8PI18oOi1X59uO3", # 2011
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/hRqm0C0CZPasv1u", # 2012
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/lFnpuNJl84hzucs", # 2013
                  "http://bar-opendata-ch.s3.amazonaws.com/ch.bag/Praemien/Archiv_Praemien_2014.zip", # 2014
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/UL36nzYZuRrkHDA", # 2015
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/8cUU1beTqcNtk8H", # 2016
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/3FgYDP6uFhfe2jV", # 2017
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/vx33hTA4J0ZcwYf", # 2018
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/JtGQs8Bkp61oCL1", # 2019
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/yTDcw7dBRnfwZj2", # 2020
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/NaxmnWZEdiwopNr", # 2021
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/nfcN79zT5eaJ7yn", # 2022
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/Brbwzs4kWPP83Qm", # 2023
                  "https://bag-files.opendata.swiss/owncloud/index.php/s/5qptAxHT7Pii9WL") # 2024
archive_year <- seq(from = 2011, length.out = length(archive_urls), by = 1)

current_urls <- c("https://opendata.swiss/de/dataset/health-insurance-premiums/resource/1dc14e05-4d27-49ff-92ad-7d27bbf58e5a",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/c2bf27ea-0fc3-472a-bbb3-60a20d3e8d96",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/4d24c3ce-f7c5-4230-aea5-9a4d2a38cb1c",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/b7561d3c-ae33-4085-a8c8-0f5a6c9d7e4d",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/47dbfd7b-985c-4526-9b3e-0dee47c0aef5",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/73edf7fd-bda7-4a42-9301-5bfefbe06c86",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/28827a2d-317a-47d1-a54e-3eee78e1fba0",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/8badbb55-38e2-44f9-8446-c873a147ef73",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/b1453cf3-8517-48b5-ac83-7be374387e1c",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/0b9f074d-d457-4ec0-807d-bcf5596ac60a",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/e2d5b3fc-07a1-447e-8ee1-c813bb81f0cc",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/3c840e91-9746-46d9-9966-0d953292a109",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/4e9648b1-611f-4208-8ff6-26c6079f36d2",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/c7529d7c-92ef-4ba5-a5bf-b9e47d9008ff",
                  "https://opendata.swiss/de/dataset/health-insurance-premiums/resource/b04c9b90-17a8-4570-8656-bc30a44bcedd")
current_files <- c("to whom it may concern.pdf",
                   "Versichertenbestand_CH.xlsx",
                   "Versichertenbestand_CH.csv",
                   "Tarife.xlsx",
                   "Tarife.xls",
                   "Prämien_EU.xlsx",
                   "Prämien_EU.csv",
                   "Prämien_CHEU.xlsx",
                   "Prämien_CH.xlsx",
                   "Prämien_CH.csv",
                   "Erläuterungen zu den Prämiendaten.xlsx",
                   "Einzugsgebiete.xlsx",
                   "Einzugsgebiete.xls",
                   "Eingeschr.-Tät.gebiete.xlsx",
                   "Eingeschr.-Tät.gebiete.xls")

if (!dir.exists("data/zipped")) { dir.create("data/zipped", recursive = TRUE) }
if (!dir.exists("data/unzipped")) { dir.create("data/unzipped", recursive = TRUE) }

# Download and unzip all files, save in data/unzipped then unzip into data/archive, each unzipped has to be added year first to the file name
for (i in 1:(length(archive_urls) +1)) {
  if (i <= length(archive_urls)) {
    # only download if not already downloaded
    if (!file.exists(paste0("data/zipped/archive_", archive_year[i], ".zip"))) {
      cat("Downloading", archive_year[i], "\n")
      download.file(archive_urls[i], destfile = paste0("data/zipped/archive_", archive_year[i], ".zip"))
    }
    cat("Unzipping", archive_year[i], "\n")
    unzip(paste0("data/zipped/archive_", archive_year[i], ".zip"), exdir = paste0("data/unzipped/", archive_year[i]))
  } else { # current year
    cat("current\n")
    if (!dir.exists(paste0("data/unzipped/", (archive_year[i-1]+1)))) { 
      dir.create(paste0("data/unzipped/", (archive_year[i-1]+1)), recursive = TRUE)
    }
    for (j in 1:length(current_urls)) {
      cat("Downloading current", "\n")
      download.file(current_urls[j], destfile = paste0("data/unzipped/", (archive_year[i-1]+1), "/", current_files[j]))
      }
    }
  
  # fix file names, for example replace "Pr\x84mien_CH.xlsx" with "Prämien_CH.xlsx"
  files <- list.files(paste0("data/unzipped/", archive_year[i]), full.names = TRUE)
  for (f in files) {
    new_file_name <- fix_file_names(f)
    # 2014 fix: 
    new_file_name <- gsub("_.csv", ".csv", new_file_name)
    
    # Rename the file if the new name is different
    if (new_file_name != f) {
      file.rename(f, new_file_name)
    }
  }
}

# for (y in 2011:2024) {
#   cat(y, "Versicherte_CH.csv" %in% list.files(paste0("data/unzipped/", y)),
#       "Versichertenbestand_CH.csv" %in% list.files(paste0("data/unzipped/", y)),
#       "\n")
# }


