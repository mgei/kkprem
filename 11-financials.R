library(tidyverse)
library(lubridate)
library(scales)
library(ggrepel)
theme_set(theme_minimal())

findata_bs <- readRDS("data/processed/findata_bs.RDS")
findata_is <- readRDS("data/processed/findata_is.RDS")

findata_bs |> 
  filter(Beschreibung == "Eigenkapital") |> 
  ggplot(aes(x = reorder(Name, `2023`), y = `2023`/1e6, fill = Name)) +
  geom_col() +
  coord_flip() +
  labs(x = NULL, y = "Eigenkapital [Mio. CHF]",
       title = "Eigenkapital der Krankenversicherer",
       subtitle = "Bilanz 2023") +
  theme(legend.position = "none")
