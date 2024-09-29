library(tidyverse)
library(lubridate)
library(readxl)

fix_cols <- function(x) {
  x |> 
    mutate(across(any_of("Versicherer"), as.character))
}

rename_cols <- function(x) {
  nms <- names(x)
  
  nms[nms == "G_ID"] <- "Versicherer"
  nms[nms == "C_ID"] <- "Kanton"
  nms[nms == "EJAHR"] <- "Erhebungsjahr"
  nms[nms == "JAHR"] <- "Geschäftsjahr"
  nms[nms == "V_TYP"] <- "Tarif"
  nms[nms == "V_KBEZ"] <- "Tarifbezeichnung"
  nms[nms == "P"] <- "Prämie"
  nms[nms == "C_GRP"] <- "Hoheitsgebiet"
  nms[nms == "Tarif-Typ"] <- "Tariftyp"
  nms[nms == "B"] <- "Durchschnittsbestand"
  
  nms <- iconv(iconv(nms, from = "UTF-8", to = "ISO-8859-1"), from = "ISO-8859-1", to = "UTF-8")
  nms <- gsub("Ã¤", "ä", nms, fixed = TRUE)
  
  names(x) <- nms
  
  return(x)
}

primCH <- bind_rows(read_delim("data/unzipped/2011/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2012/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2013/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2014/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2015/Praemien_CH.csv", delim = ",", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2016/Praemien_CH.csv", delim = ",", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2017/Praemien_CH.csv", delim = ",", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2018/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2019/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2020/Praemien_CH.csv", delim = ",", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2021/Praemien_CH.csv", delim = ",", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2022/Praemien_CH.csv", delim = ",", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2023/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2024/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2025/Praemien_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols())

primCH2 <- primCH |> 
  filter(!is.na(`Prämie`)) |> 
  mutate(Region = ifelse(is.na(Region) & !is.na(R_ID), paste0("PR-REG CH", R_ID), Region)) |> 
  select(-R_ID) |> 
  mutate(Altersklasse = case_when(is.na(Altersklasse) & M_ID == 0 ~ "AKL-KIN",
                                  is.na(Altersklasse) & M_ID == 19 ~ "AKL-JUG",
                                  is.na(Altersklasse) & M_ID == 26 ~ "AKL-ERW",
                                  T ~ Altersklasse)) |> 
  select(-M_ID) |> 
  mutate(Unfalleinschluss = case_when(is.na(Unfalleinschluss) & VAR_ID == "05" ~ "MIT-UNF",
                                      is.na(Unfalleinschluss) & VAR_ID == "06" ~ "OHN-UNF",
                                      T ~ Unfalleinschluss)) |> 
  select(-VAR_ID) |>
  mutate(Tariftyp = str_replace(Tariftyp, "_", "-")) |> 
  mutate(Fra = ifelse(is.na(`F`), str_remove(Franchise, "FRA-") |> as.integer(), `F` |> as.integer()),
         Franchise = ifelse(is.na(Franchise) & !is.na(Fra), paste0("FRA-", Fra), Franchise)) |> 
  select(-`F`) |> 
  mutate(FraStufe = ifelse(is.na(F_STUFE), str_remove(Franchisestufe, "FRAST") |> as.integer(), F_STUFE |> as.integer()),
         Franchisestufe = ifelse(is.na(Franchisestufe) & !is.na(FraStufe), paste0("FRAST", FraStufe), Franchisestufe)) |> 
  select(-F_STUFE) |> 
  mutate(Altersuntergruppe = ifelse(is.na(Altersuntergruppe), V2_ID, Altersuntergruppe),
         Altersuntergruppe = case_when(is.na(Altersuntergruppe) & Altersklasse == "AKL-JUG" ~ "J1",
                                       is.na(Altersuntergruppe) & Altersklasse == "AKL-ERW" ~ "E1",
                                       T ~ Altersuntergruppe)) |> 
  select(-c(V2_TYP, V2_ID, isBASE_V2)) |> 
  mutate(isBaseP = ifelse(is.na(isBaseP), isBASE_P, isBaseP),
         isBaseF = ifelse(is.na(isBaseF), isBASE_F, isBaseF)) |> 
  select(-c(isBASE_P, isBASE_F)) |> 
  mutate(Tariftyp = case_when(is.na(Tariftyp) & str_detect(Tarif, regex("HAM", ignore_case = T)) ~ "TAR-HAM",
                              is.na(Tariftyp) & str_detect(Tarif, regex("BASE", ignore_case = T)) ~ "TAR-BASE",
                              is.na(Tariftyp) & str_detect(Tarif, regex("DIV", ignore_case = T)) ~ "TAR-DIV",
                              is.na(Tariftyp) & str_detect(Tarif, regex("HMO", ignore_case = T)) ~ "TAR-HMO",
                              T ~ Tariftyp)) |> 
  # filter(row_number() > 252) 
  # Sort always NA
  select(-Sort) |> 
  mutate(Versicherer = str_pad(Versicherer, width = 4, side = "left", pad = "0")) |> 
  mutate_if(is.character, stringi::stri_enc_toutf8)

primCH2 |> saveRDS("data/processed/primCH.RDS")

# insurances --------------------------------------------------------------

insurances <- tibble()
files <- list.files("data/insurances", full.names = TRUE)
for (f in files) {
  temp <- read_excel(f, skip = 1, sheet = "Index   Indice   Index ")
  dte <- dmy(str_remove_all(f, ".*_|.xlsx"))
  insurances <- bind_rows(insurances, temp |> mutate(date = dte))
}

insurances <- insurances |> 
  mutate(Nummer = as.integer(Nummer)) |> 
  filter(!is.na(Nummer)) |> 
  arrange(Nummer, desc(date)) |> 
  group_by(Nummer) |> 
  slice_max(date) |> 
  ungroup() |>
  select(Nummer, Name, Ort) |> 
  mutate(Nummer = as.character(Nummer) |> 
           str_pad(width = 4, side = "left", pad = "0"))

insurances |> saveRDS("data/processed/insurances.RDS")


# versicherte -------------------------------------------------------------

versCH <- bind_rows(read_delim("data/unzipped/2011/Versicherte_CH.csv", delim = ";", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2012/Versicherte_CH.csv", delim = ";", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2013/Versicherte_CH.csv", delim = ";", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2014/Versicherte_CH.csv", delim = ";", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2015/Versichertenbestand_CH.csv", delim = ",", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2016/Versichertenbestand_CH.csv", delim = ",", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2017/Versichertenbestand_CH.csv", delim = ",", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2018/Versichertenbestand_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2019/Versichertenbestand_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2020/Versichertenbestand_CH.csv", delim = ",", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2021/Versichertenbestand_CH.csv", delim = ",", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2022/Versichertenbestand_CH.csv", delim = ",", locale=locale(encoding="UTF-8")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2023/Versichertenbestand_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2024/Versichertenbestand_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols(),
                    read_delim("data/unzipped/2025/Versichertenbestand_CH.csv", delim = ";", locale=locale(encoding="latin1")) |> rename_cols() |> fix_cols())

versCH |> saveRDS("data/processed/versCH.RDS")
