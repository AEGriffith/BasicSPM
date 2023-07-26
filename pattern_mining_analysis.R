# Load necessary library
library(readxl)
library(arulesSequences)

# Import custom functions from the pattern_mining_functions.R file
source("pattern_mining_functions.R")

# Define Parameters for sequence mining
# File path to the excel data
data_filename <- "summative study/data/df_user_interaction_with_nodes.xlsx" # Will need to change #1 if not using excel file
save_filename <- "sequence_rules.csv" # Will need to change # 7 if not saving as a csv file

# Define column names for session_id, action_id, and datetime in the data
session_id_col <- "Username"
action_col <- "Action"
datetime_col <- "DateTime"

# Parameters for the 'cspade' function
# max_length: maximum length of a sequence
# support: minimum support for a sequence to be counted; The proportion of total sessions where action sequence 'A' occurs. This is a measure of how common or popular 'A' is in our session logs.
# max_gap: maximum gap between items within a sequence
# min_gap: minimum gap between items within a sequence
# confidence: minimum confidence for a rule to be counted; The probability that action 'B' will follow action 'A' within a session. This measures how often 'B' occurs given that 'A' has already occurred.
# see https://cran.r-project.org/web/packages/arulesSequences/arulesSequences.pdf page 27 for more details
max_length <- 4
support <- 0.2
max_gap <- 2
min_gap <- 1
confidence <- 0.5


# 1. Load the data
# Depending on the format of your data, the read function will differ.
# Here I use read_excel from readxl package as an example.
data <- read_excel(data_filename)

# 2. Clean the data
# Use the clean_data function from pattern_mining_functions.R.
# I tried to make it general but you'll likely need to modify it a bit to fit your data.
cleaned_data <- clean_data(data = data, session_id = session_id_col, date_time = datetime_col)

# 2.1. (Optional) Create subset for each condition
# Filter the data by condition
# obviously, this is specific to my data, so you will need to change this for your conditions
cleaned_data_cai <- cleaned_data %>%
  filter(ui == "CAI")

cleaned_data_standard <- cleaned_data %>%
  filter(ui == "standard")

# 3. Create sequence object
# Use the create_sequence_object function from pattern_mining_functions.R.
sequences <- create_sequence_object(data = cleaned_data_cai, session_id_col = session_id_col, action_col = action_col)

# 4. Apply sequential pattern mining
# Use the 'cspade' function from arulesSequences package for the actual pattern mining.
itemsets <- cspade(sequences, parameter = list(support = support, maxlen = max_length, mingap = min_gap, maxgap = max_gap), control = list(verbose = TRUE))

# 5. Extract association rules from the itemsets
# Use the ruleInduction function from arulesSequences package.
sequence_rules <- ruleInduction(itemsets, confidence = confidence)

# 6. Convert the association rules to a data frame
# Use the split_rules_to_df function from pattern_mining_functions.R
sequence_rules_df <- split_rules_to_df(sequence_rules)

# 7. Save the data frame to a csv file
write.csv(sequence_rules_df, save_filename, row.names = FALSE)

# 8. View the top 5 rules sorted by lift
# Lift: The ratio of observed support to expected support for 'A' and 'B' occurring together. A lift greater than 1 suggests 'B' is likely to follow 'A' more often than would be expected if 'A' and 'B' were independent.
sequence_rules_df[order(sequence_rules_df$lift, decreasing = TRUE),][1:5,]

# Now you can work with sequence_rules_df, which is a data frame where each row represents a rule.
# The LHS and RHS of each rule are in separate columns, along with the rule's support, confidence, and lift.