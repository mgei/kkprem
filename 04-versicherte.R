library(tidyverse)
library(lubridate)
library(scales)
library(ggrepel)
theme_set(theme_minimal())
invisible(Sys.setlocale("LC_TIME", "en_US.UTF-8"))

insurances <- readRDS("data/processed/insurances.RDS")
vers <- readRDS("data/processed/versCH.RDS")

merge_top <- function(df, n = 10) {
  top_vers <- df |> 
    group_by(Versicherer) |> 
    summarise(Durchschnittsbestand = sum(Durchschnittsbestand, na.rm = T)) |> 
    slice_max(Durchschnittsbestand, n = n) |> 
    pull(Versicherer)
  
  df |> 
    group_by(Geschäftsjahr, 
             Name = ifelse(Versicherer %in% top_vers, Name, "andere")) |> 
    summarise(Durchschnittsbestand = sum(Durchschnittsbestand, na.rm = T))
}

p9 <- vers |> 
  left_join(insurances,
            by = c("Versicherer" = "Nummer")) |> 
  mutate(Name = replace_na(Name, "unbekannt")) |> 
  filter(Kanton != "CH") |> 
  # keep top 10 by Durchschnittsbestand individually, take others together as "andere" (sum)
  merge_top(n = 11) |> 
  group_by(Geschäftsjahr) |> 
  mutate(Marktanteil = Durchschnittsbestand / sum(Durchschnittsbestand, na.rm = T)) |> 
  # select(-Durchschnittsbestand) |> 
  # pivot_wider(names_from = Name, values_from = Marktanteil)
  ungroup() |> 
  complete(Name, Geschäftsjahr, fill = list(Marktanteil = 0)) |> 
  ggplot(aes(x = Geschäftsjahr, y = Marktanteil, fill = Name)) +
  geom_area() +
  scale_fill_brewer(palette = "Set3") +
  labs(title = "Marktanteile der grössten Krankenversicherer in der Schweiz",
       subtitle = "Top 10 Krankenversicherer nach Durchschnittsbestand Versicherte",
       x = "Geschäftsjahr",
       y = "Marktanteil",
       fill = "Versicherer") +
  scale_y_continuous(labels = percent)

p9 |> ggsave(filename = "figures/p9-marktanteil.png", width = 10, height = 6, dpi = 100,
             bg = "white")
