library(tidyverse)
library(tidymodels)
library(pins)

# assume that there is a pin with the data:
board <- board_local(versioned = TRUE)

flights <- board %>%
  pins::pin_read(name = 'raw_data')

weather <- board %>%
  pins::pin_read(name = 'weather')

late_threshold_min <- 30

flight_data <- flights %>%
  mutate(
    # Convert the arrival delay to a factor
    arr_delay = ifelse(arr_delay >= late_threshold_min, "late", "on_time"),
    arr_delay = factor(arr_delay),
    # We will use the date (not date-time) in the recipe below
    date = lubridate::as_date(time_hour)
  ) %>%
  # Include the weather data
  inner_join(weather, by = c("origin", "time_hour")) %>%
  # Only retain the specific columns we will use
  select(dep_time, flight, origin, dest, air_time, distance,
         carrier, date, arr_delay, time_hour) %>%
  # Exclude missing data
  na.omit() %>%
  # For creating models, it is better to have qualitative columns
  # encoded as factors (instead of character strings)
  mutate_if(is.character, as.factor)




# Fix the random numbers by setting the seed
# This enables the analysis to be reproducible when random numbers are used
set.seed(222)
# Put 3/4 of the data into the training set
data_split <- initial_split(flight_data, prop = .99)

# Create data frames for the two sets:
train_data <- training(data_split)
keep_out  <- testing(data_split)

# we also create a keep_out set to be used later as mock real data
data_split <- initial_split(train_data, prop = 3/4)

# Create data frames for the two sets:
train_data <- training(data_split)
test_data  <- testing(data_split)


flights_rec <-
  recipe(arr_delay ~ ., data = train_data) %>%
  update_role(flight, time_hour, new_role = "ID") %>%
  step_date(date, features = c("dow", "month")) %>%
  step_holiday(date,
               holidays = timeDate::listHolidays("US"),
               keep_original_cols = FALSE) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors())


lr_mod <-
  logistic_reg() %>%
  set_engine("glm")


flights_wflow <-
  workflow() %>%
  add_model(lr_mod) %>%
  add_recipe(flights_rec)


flights_fit <-
  flights_wflow %>%
  fit(data = train_data)

board %>% pins::pin_write(x = train_data, name = 'train_data')
board %>% pins::pin_write(x = test_data, name = 'test_data')
board %>% pins::pin_write(x = keep_out, name = 'keep_out')
