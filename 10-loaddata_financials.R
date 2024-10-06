library(tidyverse)
library(lubridate)
library(scales)
library(readxl)

get_first_digit <- function(x) {
  # if NA or 1 digit, return as is
  if (is.na(x)) {
    return(NA)
  }
  x <- as.character(x)
  if (nchar(x) == 1) {
    return(x)
  }
  substr(x, 1, 1) |> as.integer()
}

vers <- readxl::read_xlsx("data/finrep/Bilanzen und Betriebsrechnungen 2023-2022.xlsx", 
                          range = "B7:D58",
                          sheet = "Title")
vers <- setNames(vers[[1]], vers[[3]])
sheets <- readxl::excel_sheets("data/finrep/Bilanzen und Betriebsrechnungen 2023-2022.xlsx")
findata <- tibble()
for (s in sheets[2:(length(sheets)-1)]) {
  print(s)
  data <- readxl::read_xlsx("data/finrep/Bilanzen und Betriebsrechnungen 2023-2022.xlsx", sheet = s,
                            skip = 6)
  
  data <- data |>
    unite(col = Feld, 1:8, sep = "", na.rm = T) |> 
    select(Feld, `2023` = `2023 (CHF)`, `2022` = `2022 (CHF)`) |> 
    separate(col = Feld, into = c("Konto", "Beschreibung"), sep = " ", extra = "merge") |> 
    mutate(across(where(is.character), str_squish)) |> 
    mutate(Konto = as.integer(Konto),
           `2023` = as.double(`2023`),
           `2022` = as.double(`2022`)) |> 
    mutate(BAGNr = s)
  
  findata <- bind_rows(findata, data)
}

get_first_digit_V <- Vectorize(get_first_digit)

findata_bs <- findata |> 
  filter(!is.na(Beschreibung)) |> 
  mutate(Name = recode(BAGNr, !!!vers)) |> 
  filter(get_first_digit_V(Konto) < 3)

findata_is <- findata |> 
  filter(!is.na(Beschreibung)) |> 
  mutate(Name = recode(BAGNr, !!!vers)) |> 
  filter(get_first_digit_V(Konto) >= 3 | is.na(get_first_digit_V(Konto)))

findata_bs |> saveRDS("data/processed/findata_bs.RDS")
findata_is |> saveRDS("data/processed/findata_is.RDS")
