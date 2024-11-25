### plot histogram of tree sizes, colored by borough ###

# load relevant libraries
library(tidyverse)

# load data
tree_data <- read_csv("./data/derived_data/tree_data_cleaned.csv")

# plot histogram of tree sizes, colored by borough
tree_histogram <- tree_data %>% 
  ggplot(aes(x = tree_dbh, colour = boro_name)) + 
  geom_freqpoly(binwidth = 1) + 
  labs(title = "Distribution of tree diameters by borough", 
       x = "Tree diameter (inches)", y = "Count", colour = "borough") + 
  theme_bw() + 
  theme(legend.position = "bottom")

# save plot
ggsave("./figures/tree_diameter_histogram.png", tree_histogram, 
       width = 8, height = 6, dpi = 300)
