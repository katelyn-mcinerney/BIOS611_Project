## Scratch work - read in data and do some basic exploration

# load relevant libraries 
library(tidyverse)
library(maps)
library(sf)

# # read in data
# tree_data <- read_csv("./data/source_data/2015_Street_Tree_census_-_Tree_Data_20241009.csv")
# 
# # look at the first few rows of the data
# head(tree_data)
# 
# # are there any problems?
# problems(tree_data)  # no problems
# 
# # any non-complete cases?
# nrow(tree_data) - sum(complete.cases(tree_data))  # 40,827 non-complete cases
# 
# # what are the non-complete cases?
# tree_data[!complete.cases(tree_data),] # columns with missing values: health, spc_latin, spc_common, steward, guards, sidewalk, problems, etc
# 
# # basic summary of columns
# summary(tree_data)
# 
# # it looks like a lot of the stump diameter and tree_dbh values are 0 - is this a problem?
# tree_data %>% filter(tree_dbh == 0) %>% nrow()  # 17,932 rows with tree_dbh == 0
# tree_data %>% filter(stump_diam == 0) %>% nrow()  # 666,134 rows with stump_diam == 0
# 
# # do some basic visualizations 
# tree_data %>% ggplot(aes(x = tree_dbh)) + 
#   geom_histogram() + 
#   labs(title = "Distribution of tree diameters", 
#        x = "Tree diameter (inches)", y = "Count") # most values are very small - but some really large? issue with units?
# 
# # outliers with tree_dbh
# tree_data %>% filter(tree_dbh > 100) %>% nrow()  # 70 rows with tree_dbh > 100
# # it seems like these are likely errors - tree_dbh is diameter at breast height, so it should be less than 100 inches
# 
# # outliers with stump_diam
# tree_data %>% filter(stump_diam > 100) %>% nrow()  # 10 rows with stump_diam > 100
# # stump diameter should be less than 100 inches

# # plot tree dbh with outliers removed
# tree_data %>% filter(tree_dbh < 75) %>% ggplot(aes(x = tree_dbh)) + 
#   geom_histogram() + 
#   labs(title = "Distribution of tree diameters (outliers removed)", 
#        x = "Tree diameter (inches)", y = "Count") # looks better

# now, let's look at some of the character columns 
table(tree_data$status) # mostly alive
table(tree_data$health) # mostly good health
table(tree_data$spc_latin)
table(tree_data$spc_common) # tons of different species (most common is London planetree)
table(tree_data$steward) # mostly no steward (then 1or2)
table(tree_data$guards) # mostly no guards
table(tree_data$sidewalk) # mostly no damage
table(tree_data$problems) # tons of different problems (lots are overlapping)

# how has tree health changed over time of collection?
tree_data %>% mutate(created_at = as.Date(created_at, format = "%m/%d/%Y")) %>% 
  group_by(created_at, health) %>% mutate(count = n()) %>%
  ggplot(aes(x = created_at, y = count, color = health)) + 
  geom_line() + 
  labs(title = "Tree health over time", x = "Date", y = "Count") # mostly good health
# seems like first few months of 2016 had less "health" measures collected - could be a data collection issue

# how has tree stewardship changed over time of collection?
tree_data %>% mutate(created_at = as.Date(created_at, format = "%m/%d/%Y")) %>% 
  group_by(created_at, steward) %>% mutate(count = n()) %>%
  ggplot(aes(x = created_at, y = count, color = steward)) + 
  geom_line() + 
  labs(title = "Tree stewardship over time", x = "Date", y = "Count") # mostly no steward
# this has the same decrease in stewardship measures in early 2016

# tree health by root problems
table(tree_data$health, tree_data$root_stone) # doesn't seem to matter really
table(tree_data$health, tree_data$root_grate) # also doesn't seem to really matter

# tree health by trunk problems
table(tree_data$health, tree_data$trunk_wire) # doesn't seem to matter really
table(tree_data$health, tree_data$trnk_light) # also doesn't seem to really matter
table(tree_data$health, tree_data$trnk_other) # maybe matters? need to do a test

# tree health by branch problems
table(tree_data$health, tree_data$brch_light) # doesn't seem to matter really
table(tree_data$health, tree_data$brch_shoe) # also doesn't seem to really matter
table(tree_data$health, tree_data$brch_other) # maybe matters? need to do a test

# plot data spatially 
# Basic scatter plot of trees using latitude and longitude
ggplot(tree_data, aes(x = longitude, y = latitude)) +
  geom_point(color = "forestgreen") +
  labs(title = "Tree Locations in New York", x = "Longitude", y = "Latitude") +
  theme_minimal()


# ## use shapefiles for a better map
# trees_sf_raw <- st_read("./data/source_data/2015 Street Tree Census - Tree Data/geo_export_1007bd46-3e59-4990-bf97-4001ac2aacf6.shp")
# borough_boundaries_sf_raw <- st_read("./data/source_data/Borough Boundaries/geo_export_a58cd0c5-58c7-4f7f-9338-5d9569be528d.shp")
# neighborhood_boundaries_sf_raw <- st_read("./data/source_data/2010 Neighborhood Tabulation Areas (NTAs)/geo_export_aef8b682-921e-4e21-9e8c-586c62434166.shp")
# 
# ## update shape files
# borough_boundaries_sf <- borough_boundaries_sf_raw %>%
#   mutate(sq_miles = shape_area/27878400)
# 
# neighborhood_boundaries_sf <- neighborhood_boundaries_sf_raw %>%
#   rename(nta = ntacode,
#          nta_name = ntaname) %>%
#   mutate(sq_miles = shape_area/27878400)
# 
# trees_sf <- trees_sf_raw %>%
#   rename(boro_name = boroname,
#          boro_code = borocode)
# 
# # basic map of tree locations
# ggplot() +
#   geom_sf(data = borough_boundaries_sf, fill = "lightgrey") +
#   geom_sf(data = trees_sf, color = "forestgreen", alpha = 0.5) +
#   labs(title = "Tree Locations in New York") +
#   theme_bw()
# 
# # trees colored by borough
# ggplot() +
#   geom_sf(data = borough_boundaries_sf, fill = "lightgrey") +
#   geom_sf(data = trees_sf, aes(color = boroname), alpha = 0.5) +
#   labs(title = "Tree Density by Borough") +
#   theme_bw()

# trees colored by health
# ggplot() +
#   geom_sf(data = borough_boundaries_sf, fill = "lightgrey") +
#   geom_sf(data = trees_sf, aes(color = health), alpha = 0.5) +
#   labs(title = "Tree Health by Borough") +
#   theme_bw()

# trees colored by species
# ggplot() +
#   geom_sf(data = borough_boundaries_sf, fill = "lightgrey") +
#   geom_sf(data = trees_sf, aes(color = spc_common), alpha = 0.5) +
#   labs(title = "Tree Species by Borough") +
#   theme_bw() +
#   theme(legend.position = "none")

# # density of trees by borough
# tree_density_sf <- tree_data %>%
#   rename(boro_code = borocode, boro_name = borough) %>%
#   group_by(boro_code, boro_name) %>%
#   summarise(count = n()) %>%
#   ungroup() %>%
#   left_join(borough_boundaries_sf, by = c("boro_code", "boro_name")) %>%
#   mutate(boro_density = count / sq_miles)
# 
# ggplot2::ggplot(data = st_as_sf(tree_density_sf), aes(fill = boro_density)) +
#   ggplot2::geom_sf() +
#   ggplot2::scale_fill_viridis_c(alpha = 0.75) +
#   ggplot2::geom_sf_text(aes(label = boro_name),
#     fontface = "bold", check_overlap = TRUE
#   ) +
#   ggplot2::xlab("Longitude") +
#   ggplot2::ylab("Latitude") +
#   ggplot2::labs(
#     title = "The Urban Forest of New York",
#     subtitle = "Number of trees per sq mile",
#     caption = "Source: OpenDataNYC",
#     fill = "Trees per sq mile"
#   ) + 
#   ggplot2::theme_bw()
# 
# # density of trees by neighborhood
# tree_density_nta_sf <- tree_data %>%
#   group_by(nta, nta_name) %>%
#   summarise(count = n()) %>%
#   ungroup() %>%
#   left_join(neighborhood_boundaries_sf, by = c("nta", "nta_name")) %>%
#   mutate(nta_density = count / sq_miles)
# 
# ggplot2::ggplot() +
#   #ggplot2::geom_sf(data = borough_boundaries_sf, aes(color = boro_name), linewidth = 1.5) +
#   ggplot2::geom_sf(data = st_as_sf(tree_density_nta_sf), aes(fill = nta_density)) +
#   ggplot2::scale_fill_viridis_c(alpha = 0.75) +
#   ggplot2::xlab("Longitude") +
#   ggplot2::ylab("Latitude") +
#   ggplot2::labs(
#     title = "The Urban Forest of New York",
#     subtitle = "Number of trees per neighborhood sq mile",
#     caption = "Source: OpenDataNYC",
#     color = "Borough",
#     fill = "Trees per sq mile"
#   ) + 
#   ggplot2::theme_bw()


# # tree health bar chart by borough
# # if tree health = NA -> health = "Dead"
# tree_data[tree_data$status %in% c("Stump", "Dead"),]$health <- "Dead"
# 
# level_order = tree_data %>%
#   group_by(borough) %>%
#   summarize(pct_good = sum(health=="Good")/n(), .groups = "drop") %>%
#   arrange(pct_good) %>% 
#   pull(borough)
# 
# test = mutate(tree_data, borough = factor(borough, levels = level_order), 
#               health = factor(health, levels = c("Dead", "Poor", "Fair", "Good")))
# 
# ggplot(data = test, aes(y = borough, fill = health)) +
#   geom_bar(position = "fill") +
#   labs(title = "Tree Health by Borough", y = "Borough", 
#        x = "Percentage of Trees in Borough", fill = "Tree Health") +
#   scale_x_continuous(labels = scales::percent) +
#   scale_fill_discrete(type = c("red", "orange", "lightgreen", "forestgreen")) +
#   theme_minimal()



species_counts <- tree_data %>% group_by(spc_common) %>% tally() %>% arrange(desc(n))
common <- species_counts %>% pull(spc_common) %>% head(20)
uncommon <- species_counts %>% filter(!(spc_common %in% common)) %>% pull(spc_common)

tree_numeric <- tree_data %>%
  select(tree_id, 4:7, 9:13, 15:23, 29, 37:38) %>%
  mutate(spc_common = {
    s <- spc_common;
    s[s %in% uncommon] <- "other";
    s
  }) %>% distinct()

tree_dummy <- tree_numeric %>% select(-health) %>%
  fastDummies::dummy_cols(., remove_first_dummy = TRUE, remove_selected_columns = TRUE) %>%
  mutate(health = tree_numeric$health) %>%
  mutate(across(c(1,5:52), factor))

colnames(tree_dummy) <- gsub(" ", "_", colnames(tree_dummy))

explanatory <- tree_dummy %>% select(-tree_id, -health) %>% names()
formula <- as.formula(sprintf("health ~ %s", paste(explanatory, collapse = " + ")))

tts <- runif(nrow(tree_dummy)) < 0.6

train <- tree_dummy %>% filter(tts)
test <- tree_dummy %>% filter(!tts)

library(gbm)
library(caret)
model <- gbm(formula, data = train)
prob <- predict(model, newdata = test, type = "response")
pred_y <- factor(max.col(prob[,,1]), levels = 1:4, labels = c("Dead", "Fair", "Good", "Poor"))

summary(model)

confusionMatrix(test$health, pred_y)

#roc_curve <- pROC::roc(test$health, prob)

model_control <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 10, 
  classProbs = TRUE
)
model_cv <- train(formula, data = train, method = "gbm", trControl = model_control, na.action = "na.pass", verbose = FALSE)
