#' ---
#' title: CAT ridership by stop
#' author: Nathan Day <nathancday@@gmail.com>
#' date: 2020-04-15
#' ---

library(leaflet)
library(sf)
library(tidyverse)

# 2019 data
riders <- read_sf("https://opendata.arcgis.com/datasets/e9a9eacb47b54f00b4a63ba6a3cf26b3_28.geojson",
                  coords = c("Longitude", "Latitude")) # takes  minute

stop_volume <- riders %>% 
  filter(!str_detect(Stop, "^Please refer")) %>% 
  mutate(Route = str_remove(Route, " .*"),
         Stop = str_remove(Stop, "Please .*")) %>% 
  count(Stop, Route) %>% 
  mutate(geometry = st_cast(geometry, "POINT", group_or_split = FALSE),
         labs = paste(Stop, Route, n, sep = "<br>")) %>% 
  filter(!Route %in% c("0", "Trolley"))

route_colors <- c("01" = "#e57d3b",
                  "02" = "#925221",
                  "03" = "#2b3585",
                  "04" = "#da3a31",
                  "05" = "#925020",
                  "06" = "#efb042",
                  "07" = "#6c3387",
                  "08" = "#919275",
                  "09" = "#d93d8b",
                  "10" = "#66c2e0",
                  "11" = "#7DBA56",
                  "12" = "#6C338A",
                  "Trolley" = "#2f6a3d")

route_pal <- colorFactor(route_colors, names(route_colors))

leaflet(stop_volume) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addCircleMarkers(
    radius = ~log(n, base = 2),
    color= ~route_pal(Route),
    label= ~lapply(labs, HTML)
  )