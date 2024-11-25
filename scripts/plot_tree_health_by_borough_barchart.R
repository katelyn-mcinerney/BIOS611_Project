### plot tree health by borough ###

# load libraries
library(tidyverse)

# load data
tree_data <- read_csv("./data/derived_data/tree_data_cleaned.csv")

# tree health bar chart by borough

# factorize the borough names to order plot
level_order = tree_data %>%
  group_by(boro_name) %>%
  summarize(pct_good = sum(health=="Good")/n(), .groups = "drop") %>%
  arrange(pct_good) %>% 
  pull(boro_name)

# order the plots by borough and within by health levels
tree_data_factor <- tree_data %>%
  mutate(boro_name = factor(boro_name, levels = level_order), 
         health = factor(health, levels = c("Dead", "Poor", "Fair", "Good")))

# make the plot
tree_health_by_borough <- ggplot(data = tree_data_factor, aes(y = boro_name, fill = health)) +
  geom_bar(position = "fill") +
  labs(title = "Tree Health by Borough",
       y = "Borough",
       x = "Percentage of Trees in Borough",
       fill = "Tree Health") +
  scale_x_continuous(labels = scales::percent) +
  scale_fill_discrete(type = c("red", "orange", "lightgreen", "forestgreen")) +
  theme_bw()

# save the plot
ggsave("./figures/tree_health_by_borough_barchart.png", tree_health_by_borough, 
       width = 10, height = 6, units = "in", dpi = 300)