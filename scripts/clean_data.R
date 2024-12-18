### clean and process data ###

# load relevant libraries 
library(tidyverse)

# read in data
tree_data_raw <- read_csv("./data/source_data/2015_Street_Tree_census_-_Tree_Data_20241009.csv")
print(paste0("Number of rows: ", nrow(tree_data_raw)))

## initial data exploration ##
# look at the first few rows of the data
print("First few rows of the data:")
head(tree_data_raw)

# are there any problems?
print("Problems in the data:")
problems(tree_data_raw)  # no problems

# any non-complete cases?
print("Number of non-complete cases:")
nrow(tree_data_raw) - sum(complete.cases(tree_data_raw))  # 40,827 non-complete cases

# what are the non-complete cases?
print("Non-complete cases:")
tree_data_raw[!complete.cases(tree_data_raw),] # columns with missing values: health, spc_latin, spc_common, steward, guards, sidewalk, problems, etc

# basic summary of columns
print("Summary of columns:")
summary(tree_data_raw)

# some really large values of tree_dbh - why? (should be in inches)


## data cleaning ##
# filter to just trees, not stumps
tree_data <- tree_data_raw %>%
  filter(status != "Stump")
print(paste0("Number of rows after filtering out stumps: ", nrow(tree_data)))

# if tree status = dead (and health = NA) -> health = "Dead"
tree_data[tree_data$status %in% c("Dead"),]$health <- "Dead"

# deal with outliers in tree_dbh
tree_data <- tree_data %>%
  filter(tree_dbh < 60) # remove outliers
print(paste0("Number of rows after removing tree_dbh outliers: ", nrow(tree_data)))

# select helpful columns and rename some columns for clarity
tree_data <- tree_data %>%
  select(-stump_diam) %>% # all are 0 because no stumps
  rename(num_stewards = steward,
         guard_help = guards,
         sidewalk_damage = sidewalk,
         trunk_light = trnk_light,
         trunk_other = trnk_other,
         branch_light = brch_light,
         branch_shoe = brch_shoe, 
         branch_other = brch_other,
         boro_code = borocode,
         boro_name = borough,
         council_dist = cncldist,
         nta_code = nta, 
         census_tract = boro_ct)
print("First few rows of the data after filtering and renaming:")
head(tree_data)


## save cleaned data ##
write_csv(tree_data, "./data/derived_data/tree_data_cleaned.csv")