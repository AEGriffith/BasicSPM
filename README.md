# BasicSPM

This repository contains R scripts for sequential pattern and association rule mining using the `arulesSequences` package in R. The scripts include functionality to clean the input data, create a sequence object for pattern mining, apply sequential pattern mining, extract association rules from itemsets, convert the rules to a data frame, and save the results to a CSV file.

## Repository Structure

```
.
├── pattern_mining_functions.R
├── pattern_mining_analysis.R
└── README.md
```

- **pattern_mining_functions.R**: This script includes the necessary functions for the data cleaning, creating a sequence object, and converting association rules to a data frame.

- **pattern_mining_analysis.R**: This script includes the main analysis pipeline, which utilizes the functions in `pattern_mining_functions.R` for pattern mining.

## Getting Started

1. Clone this repository or download the scripts to your local machine.

2. Install necessary R packages:

```r
install.packages(c("tidyverse", "lubridate", "arulesSequences", "readxl", "janitor"))
```

3. Run `pattern_mining_analysis.R` in R. Make sure to update the parameters to match your data.

## Parameters

- **data_filename**: File path to the Excel data file.

- **save_filename**: File path for the output CSV file.

- **session_id_col**: Name of the column in the data that represents the session identifier.

- **action_col**: Name of the column in the data that represents the action.

- **datetime_col**: Name of the column in the data that contains datetime information.

- **max_length**: Maximum length of a sequence for pattern mining.

- **support**: Minimum support for a sequence to be considered frequent. This is the proportion of total sessions where the action sequence occurs.

- **max_gap**: Maximum gap between items within a sequence.

- **min_gap**: Minimum gap between items within a sequence.

- **confidence**: Minimum confidence for a rule to be considered significant. This is the probability that the action on the right-hand side of the rule will follow the action on the left-hand side within a session.

## Output

The output is a CSV file where each row represents an association rule. The left-hand side (LHS) and right-hand side (RHS) of each rule are in separate columns, along with the rule's support, confidence, and lift.

## Additional Information

For more detailed information about the functions and their parameters, please refer to the comments in the R scripts.

---

This is a simple README. Depending on your needs, you might want to add additional sections such as "Contributing", "License", or more detailed "Usage" instructions.
