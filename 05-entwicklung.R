library(tidyverse)
library(lubridate)
library(scales)
library(ggrepel)
theme_set(theme_minimal())
invisible(Sys.setlocale("LC_TIME", "en_US.UTF-8"))

prim <- readRDS("data/processed/primCH.RDS")
insurances <- readRDS("data/processed/insurances.RDS")

prim <- prim |> 
  left_join(insurances |> 
              select(-Ort), 
            by = c("Versicherer" = "Nummer")) |> 
  select(Versicherer, Name, everything())

lowest_all <- prim |> 
  filter(Kanton == "BS",
         Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Fra == 2500) |> 
  distinct(Geschäftsjahr, Prämie) |>
  group_by(Geschäftsjahr) |>
  slice_min(Prämie, n = 5) |> 
  mutate(rank = paste0("Alt. ", rank(Prämie)))

lowest_regular <- prim |> 
  filter(Kanton == "BS",
         Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Fra == 2500,
         Tariftyp == "TAR-BASE") |> 
  distinct(Geschäftsjahr, Prämie) |> 
  group_by(Geschäftsjahr) |>
  slice_min(Prämie, n = 5) |> 
  mutate(rank = paste0("Standard ", rank(Prämie)))

p10 <- bind_rows(lowest_all, lowest_regular) |> 
  ggplot(aes(x = Geschäftsjahr, y = Prämie, color = rank)) +
  geom_line() +
  geom_point() +
  labs(title = "Prämienentwicklung in Basel-Stadt",
       subtitle = "Tiefste Prämien für Erwachsene ohne Unfallversicherung (Franchise 2500)",
       x = NULL,
       y = "Monatsprämie in CHF",
       color = "Rang") +
  # scale_y_continuous(labels = scales::dollar) +
  scale_color_manual(values = c("Alt. 1" = "red1", "Alt. 2" = "red2", "Alt. 3" = "red3", "Alt. 4" = "red4", "Alt. 5" = "black",
                                "Standard 1" = "blue1", "Standard 2" = "blue2", "Standard 3" = "blue3", "Standard 4" = "blue4", "Standard 5" = "gray")) +
  scale_x_continuous(breaks = 2011:2030)

p10 |> ggsave(filename = "figures/p10-entwicklungBS.png", width = 10, height = 6, dpi = 100,
             bg = "white")

lowest_regular |> 
  ungroup() |> 
  filter(rank == "Standard 1") |> 
  mutate(chg = Prämie/lag(Prämie)-1) |> 
  drop_na() |> 
  summarise(chg_total = prod(1+chg)-1) # 88% increase

lowest_all |> 
  ungroup() |> 
  filter(rank == "Alt. 1") |> 
  mutate(chg = Prämie/lag(Prämie)-1) |> 
  drop_na() |> 
  summarise(chg_total = prod(1+chg)-1) # 80% increase




# same but 300 f franchise ------------------------------------------------


lowest_all <- prim |> 
  filter(Kanton == "BS",
         Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Fra == 300) |> 
  distinct(Geschäftsjahr, Prämie) |>
  group_by(Geschäftsjahr) |>
  slice_min(Prämie, n = 5) |> 
  mutate(rank = paste0("Alt. ", rank(Prämie)))

lowest_regular <- prim |> 
  filter(Kanton == "BS",
         Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Fra == 300,
         Tariftyp == "TAR-BASE") |> 
  distinct(Geschäftsjahr, Prämie) |> 
  group_by(Geschäftsjahr) |>
  slice_min(Prämie, n = 5) |> 
  mutate(rank = paste0("Standard ", rank(Prämie)))

p11 <- bind_rows(lowest_all, lowest_regular) |> 
  ggplot(aes(x = Geschäftsjahr, y = Prämie, color = rank)) +
  geom_line() +
  geom_point() +
  labs(title = "Prämienentwicklung in Basel-Stadt",
       subtitle = "Tiefste Prämien für Erwachsene ohne Unfallversicherung (Franchise 300)",
       x = NULL,
       y = "Monatsprämie in CHF",
       color = "Rang") +
  # scale_y_continuous(labels = scales::dollar) +
  scale_color_manual(values = c("Alt. 1" = "red1", "Alt. 2" = "red2", "Alt. 3" = "red3", "Alt. 4" = "red4", "Alt. 5" = "black",
                                "Standard 1" = "blue1", "Standard 2" = "blue2", "Standard 3" = "blue3", "Standard 4" = "blue4", "Standard 5" = "gray")) +
  scale_x_continuous(breaks = 2011:2030)

p11 |> ggsave(filename = "figures/p11-entwicklungBS300.png", width = 10, height = 6, dpi = 100,
              bg = "white")

lowest_regular |> 
  ungroup() |> 
  filter(rank == "Standard 1") |> 
  mutate(chg = Prämie/lag(Prämie)-1) |> 
  drop_na() |> 
  summarise(chg_total = prod(1+chg)-1) # 60% increase

lowest_all |> 
  ungroup() |> 
  filter(rank == "Alt. 1") |> 
  mutate(chg = Prämie/lag(Prämie)-1) |> 
  drop_na() |> 
  summarise(chg_total = prod(1+chg)-1) # 58% increase


