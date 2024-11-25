### plot map - density of trees by neighborhood ###

# load relevant libraries
library(tidyverse)
library(sf)

# load data
tree_data <- read_csv("./data/derived_data/tree_data_cleaned.csv")
neighborhood_boundaries_sf_raw <- st_read("./data/source_data/2010_Neighborhood_Tabulation_Areas_Map_Data/geo_export_aef8b682-921e-4e21-9e8c-586c62434166.shp")

# update datasets
neighborhood_boundaries_sf <- neighborhood_boundaries_sf_raw %>%
    rename(nta_code = ntacode,
           nta_name = ntaname) %>%
    mutate(sq_miles = shape_area/27878400) # make square miles
  
# merge datasets for plot 
tree_density_nta_sf <- tree_data %>%
  group_by(nta_code, nta_name) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  left_join(neighborhood_boundaries_sf, by = c("nta_code", "nta_name")) %>%
  mutate(nta_density = count / sq_miles)

# plot density of trees by neighborhood
tree_density_plot <- ggplot() +
   geom_sf(data = st_as_sf(tree_density_nta_sf), aes(fill = nta_density)) +
   scale_fill_viridis_c(alpha = 0.75) +
   xlab("Longitude") +
   ylab("Latitude") +
   labs(title = "Number of trees per neighborhood sq mile", 
        fill = "Trees per sq mile") + 
   theme_bw()

# save plot
ggsave("./figures/tree_density_by_neighborhood_map.png", plot = tree_density_plot, width = 10, height = 10, units = "in", dpi = 300)