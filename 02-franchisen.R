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

p1 <- prim |> 
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

p1 |> 
  ggsave(filename = "figures/p1-franchisenBS.png", width = 10, height = 6, dpi = 100,
         bg = "white")

# You pay the franchise + 10% up to a max of 700 p.a. out of your pocket
# Plus the insurance premium.

ins_plans <- prim |> 
  filter(Tariftyp == "TAR-BASE",
         Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Kanton == "BS",
         Geschäftsjahr == 2025,
         Name |> str_detect("Assura"))

p2 <- tibble(expenses = seq(0, 5000, by = 100)) |> 
  crossing(ins_plans |> select(Name, Fra, Prämie)) |> 
  # Fra pay: you pay all expenses up to the franchise amount by yourself
  # SB (Selbstbehalt): 10% of the expenses above the Fra up to a max of 700 p.a.
  mutate(FraPay = pmin(expenses, Fra),
         SB = pmax(0, pmin(0.1*(expenses - Fra), 700)),
         InsureePay = 12*Prämie + FraPay + SB) |> 
  ggplot(aes(x = expenses, y = InsureePay, color = factor(Fra))) +
  geom_line() +
  labs(x = "Krankheitskosten [CHF/Jahr]", y = "Kosten [CHF/Jahr]",
       title = "Kostenvergleich (Prämie + Franchise + Selbstbehalt)",
       subtitle = "Grundversicherung bei ASSURA, ohne Unfall, Erwachsene, Basel-Stadt, 2025",
       color = "Franchise") +
  theme(legend.position = c(0.8, 0.3))

p2 |> ggsave(filename = "figures/p2-insureeCosts.png", width = 10, height = 6, dpi = 100,
             bg = "white")

p3 <- tibble(expenses = seq(0, 50000, by = 100)) |> 
  crossing(ins_plans |> select(Name, Fra, Prämie)) |> 
  # Fra pay: you pay all expenses up to the franchise amount by yourself
  # SB (Selbstbehalt): 10% of the expenses above the Fra up to a max of 700 p.a.
  mutate(FraPay = pmin(expenses, Fra),
         SB = pmax(0, pmin(0.1*(expenses - Fra), 700)),
         InsureePay = 12*Prämie + FraPay + SB) |> 
  ggplot(aes(x = expenses, y = InsureePay, color = factor(Fra))) +
  geom_line() +
  labs(x = "Krankheitskosten [CHF/Jahr]", y = "Kosten [CHF/Jahr]",
       title = "Kostenvergleich (Prämie + Franchise + Selbstbehalt)",
       subtitle = "Grundversicherung bei ASSURA, ohne Unfall, Erwachsene, Basel-Stadt, 2025",
       color = "Franchise") +
  theme(legend.position = c(0.8, 0.3))

p3 |> ggsave(filename = "figures/p3-insureeCosts.png", width = 10, height = 6, dpi = 100,
             bg = "white")
  

