library(tidyverse)
library(lubridate)
library(arulesSequences)
library(readxl)
library(janitor)


####### Clean the data ########

#' Clean data by standardizing column names, parsing date_time,
#' arranging by session_id and datetime, grouping by session_id,
#' and adding a time difference column.
#'
#' @param data A data frame containing the data to be cleaned.
#' @param session_id_col A string that is the name of the column in 'data' used for grouping,
#'                  which should be a session identifier (e.g., user_id).
#' @param datetime A string that is the name of the column in 'data' containing the datetime information.
#'
#' @return A cleaned data frame with an additional 'time_diff' column showing the
#'         time difference in seconds between each row and the previous row for each session.
#'
#' @examples
#' clean_data(data = data, session_id_col = "user_id", datetime = "date_time")
clean_data <- function(data, session_id_col, date_time){
    options(digits.secs=4)
  # Convert user-input column names to match clean column names
    session_id_col <- janitor::make_clean_names({ { session_id_col } })
    date_time <- janitor::make_clean_names({ { date_time } })
  cleaned_data <- data %>%
    janitor::clean_names() %>%
    mutate(datetime = lubridate::ymd_hms(!!sym(date_time))) %>%
    arrange(!!sym(session_id_col), datetime) %>%
    group_by(!!sym(session_id_col)) %>%
    mutate(time_diff = as.numeric(datetime - lag(datetime), units = "secs")) %>%
    ungroup()

  return (cleaned_data)
}


######### Create sequences #########

#' Create a sequence object for arulesSequences
#'
#' This function creates a sequence object which can be used with the arulesSequences package in R.
#' It takes a data frame, a session identifier, and the name of an action column as inputs.
#' It processes the data and constructs a transaction data set which is needed for sequence analysis in arulesSequences.
#'
#' @param data A data frame that includes session identifiers and action information.
#' @param session_id_col The name of the column in data that represents the session identifier.
#' @param action_col The name of the column in data that represents the action.
#'
#' @return A transactions object that includes sequence and event IDs and is ready for use with arulesSequences.
#'
#' @examples
#' create_sequence_object(data = cleaned_data, session_id_col = "user_id", action_col = "action")
create_sequence_object <- function(data, session_id_col, action_col) {
  # Convert user-input column names to match clean column names
  session_id_col <- janitor::make_clean_names({{session_id_col}})
  action_col <- janitor::make_clean_names({{action_col}})

  # Create a sequence object
  sequences <- data %>%
    arrange(!!sym(session_id_col), datetime) %>%
    group_by(!!sym(session_id_col)) %>%
    mutate(sequence_action = !!sym(action_col),
           event_id = row_number()) %>%
    ungroup()

  # Create a mapping for unique session_id's
  session_id_mapping <- as.integer(as.factor(sequences[[session_id_col]]))

  # Replace session_id with mapped integers
  sequences[[session_id_col]] <- session_id_mapping

  # Create event_id for each event
  sequences <- sequences %>%
    group_by(!!sym(session_id_col)) %>%
    mutate(event_id = row_number()) %>%
    ungroup()

  # Replace spaces in sequence_action with underscores
  sequences$sequence_action <- str_replace_all(sequences$sequence_action, " ", "_")

  # Convert to factor
  sequences$sequence_action <- as.factor(sequences$sequence_action)

  # Ensure that session_id and event_id are integer
  sequences[[session_id_col]] <- as.integer(sequences[[session_id_col]])
  sequences$event_id <- as.integer(sequences$event_id)

  # Construct the Transactions Data Set for arulesSequences
  sessions <- as(sequences %>%
                  transmute(items = sequence_action), "transactions")
  transactionInfo(sessions)$sequenceID <- sequences[[session_id_col]]
  transactionInfo(sessions)$eventID <- sequences$event_id

  return(sessions)
}


######### Convert association rules to a data frame #########

#' Convert association rules to a data frame
#'
#' This function takes association rules as an input, converts them to a data frame, and splits each rule into its left-hand side (LHS) and
#' right-hand side (RHS) components. This makes it easier to analyze and interpret the rules.
#'
#' @param rules The output from a call to the 'apriori' function in the arules package. These are the association rules to be converted and split.
#'
#' @return A data frame where each row represents a rule. The LHS and RHS of each rule are in separate columns, along with the rule's support, confidence, and lift.
split_rules_to_df <- function(rules) {
  # convert rules to data frame
  df_rules <- as(rules, "data.frame")

  # convert the "rules" to character using format() function
  rules_str <- df_rules$rule

  # split the "rules_str" at ' => ' and create a list column
  df_rules$split_rules <- strsplit(rules_str, ' => ', fixed = TRUE)

  # create new columns for LHS and RHS
  df_rules$LHS <- sapply(df_rules$split_rules, function(x) x[1])
  df_rules$RHS <- sapply(df_rules$split_rules, function(x) x[2])

  # remove the "split_rules" column if not needed
  df_rules$split_rules <- NULL

  return(df_rules)
}

