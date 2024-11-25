### basic plot of trees spatially, borders = boroughs ###

# load relevant libraries
library(tidyverse)
library(sf)

# load data
trees_sf_raw <- st_read("./data/source_data/2015_Street_Tree_Census_Map_Data/geo_export_1007bd46-3e59-4990-bf97-4001ac2aacf6.shp")
borough_boundaries_sf_raw <- st_read("./data/source_data/Borough_Boundaries_Map_Data/geo_export_a58cd0c5-58c7-4f7f-9338-5d9569be528d.shp")

# update borough boundaries to include square miles as the area
borough_boundaries_sf <- borough_boundaries_sf_raw %>%
  mutate(sq_miles = shape_area/27878400)

# update tree_data shapefile to have the correct names
trees_sf <- trees_sf_raw %>%
  rename(boro_name = boroname,
         boro_code = borocode)

# plot trees
tree_map <- ggplot() +
  geom_sf(data = borough_boundaries_sf, fill = "lightgrey") +
  geom_sf(data = trees_sf, color = "forestgreen", alpha = 0.5) +
  labs(title = "Tree Locations in New York", subtitle = "Boundaries by Borough",
       x = "Longitude", y = "Latitude") +
  theme_bw()

# save plot
ggsave("./figures/basic_tree_map.png", plot = tree_map, 
       width = 10, height = 10, units = "in", dpi = 300)