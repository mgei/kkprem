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


# Grundversicherung ohne Unfall -------------------------------------------

prim |> 
  filter(Tariftyp == "TAR-BASE",
         Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW") |>
  filter(Kanton == "BS") |>
  filter(Geschäftsjahr == 2025) |> 
  ggplot(aes(x = Fra, y = Prämie*12, color = Name)) +
  geom_abline(intercept = (1:100*10^3)/2, slope = -1, linetype = "dashed", size = 0.1) +
  geom_line() +
  # add labels to the right with ggrepel
  geom_text_repel(aes(label = ifelse(Fra == 2500, Name, NA_character_)), 
                  box.padding = 0.5, 
                  point.padding = 0.5,
                  direction = "y", nudge_x = 300, force = 0.1, max.overlaps = 5) +
  # expand x to the right so labels have space
  scale_x_continuous(limit = c(300, 3000), expand = c(0.05, 0),
                     breaks = c(300, 500, 1000, 1500, 2000, 2500)) +
  labs(x = "Franchise [CHF]", y = "Prämie [CHF/Jahr]",
       title = "Franchisevergleich",
       subtitle = "Grundversicherung ohne Unfall, Erwachsene, Basel-Stadt, 2025") +
  theme(legend.position = "none")
