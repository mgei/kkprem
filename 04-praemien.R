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

# Billigste Versicherungen und Modelle ------------------------------------

p4 <- prim |> 
  filter(Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Geschäftsjahr == 2025,
         Fra == 2500,
         Kanton == "BS") |> 
  mutate(Name = paste(Name, Tarifbezeichnung)) |> 
  slice_min(Prämie, n = 30) |> 
  ggplot(aes(y = 12*Prämie, x = reorder(Name, Prämie), fill = Tarifbezeichnung)) +
  geom_col() +
  geom_text(aes(label = paste0(Tarifbezeichnung, ", MPr ", Prämie)), y = 0, hjust = 0, size = 3) +
  coord_flip() +
  labs(x = NULL, y = "Prämie [CHF/Jahr]",
       title = "Billigste Krankenkassen und Modelle",
       subtitle = "Grundversicherung ohne Unfall, Erwachsene, Franchise 2500, Basel-Stadt, 2025") +
  theme(legend.position = "none")

p4 |> ggsave(filename = "figures/p4-billigsteBS.png", width = 10, height = 6, dpi = 100,
             bg = "white")

# SANITAS CompactOne

ins_plans <- prim |> 
  filter(Unfalleinschluss == "OHN-UNF",
         Altersklasse == "AKL-ERW",
         Name |> str_detect("Sanitas"),
         Tarifbezeichnung == "CompactOne",
         Kanton == "BS",
         Geschäftsjahr == 2025)

p5 <- tibble(expenses = seq(0, 5000, by = 100)) |> 
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
       subtitle = "Sanitas CompactOne (Medgate Modell), ohne Unfall, Erwachsene, Basel-Stadt, 2025",
       color = "Franchise") +
  theme(legend.position = c(0.8, 0.3))

p5 |> ggsave(filename = "figures/p5-sanitasCompactOneBS.png", width = 10, height = 6, dpi = 100,
             bg = "white")


# kinder BS ---------------------------------------------------------------

p6 <- prim |> 
  filter(Unfalleinschluss == "MIT-UNF",
         Altersklasse == "AKL-KIN", 
         Geschäftsjahr == 2025,
         Fra == 600,
         Kanton == "BS",
         Altersuntergruppe == "K1") |> 
  mutate(Name = paste(Name, Tarifbezeichnung)) |> 
  slice_min(Prämie, n = 30) |> 
  ggplot(aes(y = 12*Prämie, x = reorder(Name, Prämie), fill = Tarifbezeichnung)) +
  geom_col() +
  geom_text(aes(label = paste0(Tarifbezeichnung, ", MPr ", Prämie)), y = 0, hjust = 0, size = 3) +
  coord_flip() +
  labs(x = NULL, y = "Prämie [CHF/Jahr]",
       title = "Billigste Krankenkassen und Modelle",
       subtitle = "Grundversicherung mit Unfall, Kinder, Franchise 600, Basel-Stadt, 2025") +
  theme(legend.position = "none")

p6 |> ggsave(filename = "figures/p6-billigsteBS.png", width = 10, height = 6, dpi = 100,
             bg = "white")


# Agrisano AGRIsmart

ins_plans <- prim |> 
  filter(Unfalleinschluss == "MIT-UNF",
         Altersklasse == "AKL-KIN",
         Name |> str_detect("Agrisano"),
         Tarifbezeichnung == "AGRIsmart",
         Kanton == "BS",
         Geschäftsjahr == 2025,
         Altersuntergruppe == "K1") # 1. Kind

p7 <- tibble(expenses = seq(0, 1000, by = 100)) |> 
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
       subtitle = "Agrisano AGRIsmart (Medgate Modell), mit Unfall, Kinder, Basel-Stadt, 2025",
       color = "Franchise") +
  theme(legend.position = c(0.8, 0.3))

p7 |> ggsave(filename = "figures/p7-agrismartBS.png", width = 10, height = 6, dpi = 100,
             bg = "white")

# Assura Qualimed

ins_plans <- prim |> 
  filter(Unfalleinschluss == "MIT-UNF",
         Altersklasse == "AKL-KIN",
         Name |> str_detect("Assura"),
         Tarifbezeichnung == "Qualimed",
         Kanton == "BS",
         Geschäftsjahr == 2025,
         Altersuntergruppe == "K1") # 1. Kind

p8 <- tibble(expenses = seq(0, 1000, by = 100)) |> 
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
       subtitle = "Agrisano AGRIsmart (Medgate Modell), mit Unfall, Kinder, Basel-Stadt, 2025",
       color = "Franchise") +
  theme(legend.position = c(0.8, 0.3))

p8 |> ggsave(filename = "figures/p8-qualimedBS.png", width = 10, height = 6, dpi = 100,
             bg = "white")


# Kind mit/ohne Unfall

prim |> 
  filter(Altersklasse == "AKL-KIN",
         Geschäftsjahr == 2025,
         Kanton == "BS",
         Altersuntergruppe == "K1",
         Fra == 600) |> 
  mutate(Name = paste(Name, Tarifbezeichnung)) |> 
  select(Name, Prämie, Unfalleinschluss) |> 
  pivot_wider(names_from = Unfalleinschluss, values_from = Prämie) |> 
  mutate(cost_unfall = `MIT-UNF` - `OHN-UNF`,
         cost_unfall_perc = 100*cost_unfall/`OHN-UNF`) |> 
  ggplot(aes(x = `OHN-UNF`, y = cost_unfall_perc, label = Name)) +
  geom_point() +
  geom_text_repel()
  
  slice_min(Prämie, n = 30)
  ggplot(aes(y = 12*Prämie, x = reorder(Name, Prämie), fill = Tarifbezeichnung)) +
  geom_col() +
  geom_text(aes(label = paste0(Tarifbezeichnung, ", MPr ", Prämie)), y = 0, hjust = 0, size = 3) +
  coord_flip() +
  labs(x = NULL, y = "Prämie [CHF/Jahr]",
       title = "Billigste Krankenkassen und Modelle",
       subtitle = "Grundversicherung, Kinder, Basel-Stadt, 2025") +
  theme(legend.position = "none")
