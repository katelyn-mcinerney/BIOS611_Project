### plot histogram of tree sizes, colored by borough ###

# load relevant libraries
library(tidyverse)

# load data
tree_data <- read_csv("./data/derived_data/tree_data_cleaned.csv")

# plot histogram of tree sizes, colored by borough
tree_histogram_borough <- tree_data %>% 
  ggplot(aes(x = tree_dbh, colour = boro_name)) + 
  geom_density(linewidth = 1) + 
  labs(title = "Distribution of tree diameters by borough", 
       x = "Tree diameter (inches)", y = "Density", colour = "Borough") + 
  theme_bw() + 
  theme(legend.position = "bottom")

# save plot
ggsave("./figures/tree_diameter_by_borough_histogram.png", tree_histogram_borough, 
       width = 8, height = 6, dpi = 300)

# plot histogram of tree sizes, colored by health
tree_histogram_health <- tree_data %>% 
  ggplot(aes(x = tree_dbh, colour = health)) + 
  geom_density(linewidth = 1) + 
  labs(title = "Distribution of tree diameters by health", 
       x = "Tree diameter (inches)", y = "Density", colour = "Health") + 
  scale_colour_discrete(type = c("red", "lightgreen", "forestgreen",  "orange")) +
  theme_bw() + 
  theme(legend.position = "bottom")

# save plot
ggsave("./figures/tree_diameter_by_health_histogram.png", tree_histogram_health, 
       width = 8, height = 6, dpi = 300)
