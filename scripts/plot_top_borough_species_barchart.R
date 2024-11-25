### plot most 5 most popular species in each borough as a percent of their total trees ###

# load libraries
library(tidyverse)

# read in data
tree_data <- read_csv("./data/derived_data/tree_data_cleaned.csv")

# calculate the percent of each species in each borough
borough_species_percent <- tree_data %>%
  group_by(boro_name, spc_common) %>%
  summarise(n = n()) %>%
  mutate(percent = n / sum(n) * 100) %>%
  arrange(desc(percent)) %>%
  group_by(boro_name) %>%
  top_n(5, percent)

# order borough by total percentage in plot
level_order = borough_species_percent %>%
  group_by(boro_name) %>%
  summarize(total_percent = sum(percent), .groups = "drop") %>%
  arrange(desc(total_percent)) %>% 
  pull(boro_name)

# reorder the factor levels
borough_species_percent$boro_name <- factor(borough_species_percent$boro_name, levels = level_order)

# london planetree and japanese zelkova are too long - make labels wrapped
borough_species_percent[borough_species_percent$spc_common == c("London planetree"),]$spc_common <- "London \n planetree"
borough_species_percent[borough_species_percent$spc_common == c("Japanese zelkova"),]$spc_common <- "Japanese \n zelkova"

# arrange df and add labels to order by species in each group
borough_species_percent <- borough_species_percent %>%
  ungroup() %>%
  arrange(boro_name, percent) %>%
  mutate(ID = rep(c(1:5), 5))

# plot the top 5 species in each borough
top_borough_species <- ggplot(data = borough_species_percent, 
                              aes(x = boro_name, y = percent, group = ID, fill = spc_common)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0(spc_common, ", ", round(percent,1), "%")), size = 3, position = position_stack(vjust = 0.7), color = "white", fontface = "bold") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Top 5 Species in Each Borough as a Percent of Total Trees",
       y = "Percent of Total Trees", fill = "Species") +
  theme_bw() +
  theme(axis.title.x = element_blank(), legend.position = "none") 

# save plot
ggsave("./figures/top_borough_species_barchart.png", plot = top_borough_species, 
       width = 10, height = 6, units = "in", dpi = 300)