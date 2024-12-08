### do the different tree problems predict tree health? ###

# load libraries
library(tidyverse)
library(gbm)
library(caret)
library(fastDummies)
library(adabag)

# load the data
tree_data <- read_csv("./data/derived_data/tree_data_cleaned.csv")


## prepare data for classification 
# reduce dimensions of species from 132 -> 20 (+ "other")
species_counts <- tree_data %>% group_by(spc_common) %>% tally() %>% arrange(desc(n))
common <- species_counts %>% pull(spc_common) %>% head(20)
uncommon <- species_counts %>% filter(!(spc_common %in% common)) %>% pull(spc_common)

# select specific columns (numeric ones like tree_dbh and lat/long and then species, problems cols)
tree_numeric <- tree_data %>%
  select(tree_id, 4:7, 9:13, 15:23, 29, 37:38) %>%
  mutate(spc_common = {
    s <- spc_common;
    s[s %in% uncommon] <- "other";
    s
  }) %>% distinct()

# make "dummy" version of dataset (re-encode yes/no vars)
tree_dummy <- tree_numeric %>% select(-health, -tree_id) %>%
  fastDummies::dummy_cols(., remove_first_dummy = TRUE, remove_selected_columns = TRUE) %>%
  mutate(health = tree_numeric$health,
         tree_id = tree_numeric$tree_id) %>%
  mutate(across(c(4:51), factor))

# makek sure no white space in colnames (looking at you spc_common)
colnames(tree_dummy) <- gsub(" ", "_", colnames(tree_dummy))


## run adaboost caret analysis ##
# prep data
# classification can't handle missing values - means we'll lose all the "dead" cases :(
tree_dummy_caret <- tree_dummy[complete.cases(tree_dummy), ]
tree_dummy_caret$health <- factor(tree_dummy_caret$health, levels = c("Fair", "Good", "Poor"))

# remove columns with no variation
tree_dummy_caret <- tree_dummy_caret %>% select(where(function(x) length(unique(x)) > 1))

# update explanatory and formula
explanatory_caret <- tree_dummy_caret %>% select(-tree_id, -health) %>% names()
formula_caret <- as.formula(sprintf("health ~ %s", paste(explanatory_caret, collapse = " + ")))

# 70/30 train test split
set.seed(998) # set seed for reproducibility
indexes=createDataPartition(tree_dummy_caret$health, p=.70, list = F)
train_caret = tree_dummy_caret[indexes, ]
test_caret = tree_dummy_caret[-indexes, ]

# model training control - 5-fold CV repeated 1 time
model_control <- trainControl(
  method = "repeatedcv",
  number = 3,
  repeats = 1 
)

# model tuning grid
model_grid <- expand.grid(mfinal = (1:3)*3,
                          maxdepth = c(1,3),
                          coeflearn = c("Breiman"))

# run model on training data
set.seed(1234) # set seed for reproducibility
model_cv <- caret::train(formula_caret, data = train_caret, 
                         method = "AdaBoost.M1",
                         trControl = model_control, tuneGrid = model_grid)

# save model
save(model_cv, file = "./figures/model_cv.rda")


## summary stats from analysis
# plots of model results
model_accuracy <- ggplot(model_cv) + theme_bw()
model_kappa <- ggplot(model_cv, metric = "Kappa") + theme_bw()

ggsave("./figures/ADABOOST_model_accuracy.png", model_accuracy, width = 6, height = 6, dpi = 300)
ggsave("./figures/ADABOOST_model_kappa.png", model_kappa, width = 6, height = 6, dpi = 300)

# predict test data
prob_caret <- predict(model_cv, test_caret)

# confusion matrix
save(prob_caret, file = "./figures/model_prediction.rda")
save(test_caret, file = "./figures/model_test_data.rda")

# variable importance
var_import <- varImp(model_cv, scale = FALSE)
var_import_plot <- ggplot(var_import, top = 10) + 
                         labs(title = "Top 10 most important variables for \n ADABOOST 'health' classification") + theme_bw()

ggsave("./figures/ADABOOST_var_importance.png", var_import_plot, width = 8, height = 6, dpi = 300)


## pca of numeric data (w/ no missings)
tree_data_pca <- tree_dummy_caret %>%
  select(-tree_id, -health) %>%
  mutate(across(everything(), as.numeric)) %>%
  prcomp(center = TRUE, scale. = TRUE)

pca_plot <- ggplot(tree_data_pca$x %>% as_tibble() %>% select(PC1, PC2) %>%
                     mutate(tree_id = tree_dummy_caret$tree_id) %>% 
                     left_join(tree_numeric[, c("tree_id", "boro_name")], by = "tree_id"),
                  aes(PC1, PC2, color = boro_name)) +
  geom_point() +
  labs(color = "Borough", title = "PCA of Tree Data by Borough") +
  theme_bw()

ggsave("./figures/pca_tree_data.png", pca_plot, width = 8, height = 6, dpi = 300)
