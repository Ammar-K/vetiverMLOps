#THIS WILL TAKE A FEW MINUTES (5 to 10min)

# start the plumber from the bash first
########################
board <- pins::board_local()

# OPTIONAL: clean logs
for (i in c('requests', 'responses','performance')){
  unlink(here::here('logs', i), force = TRUE, recursive = TRUE)
  dir.create(here::here('logs', i))
}

# call the model with the data we saved
keep_out <- board %>% pins::pin_read('keep_out')

# split it three to mock 3 different days
set.seed(222)
data_split <- initial_split(keep_out, prop = .33)
days <- list()
# Create data frames for the two sets:
days$day1 <- training(data_split)
tmpDf  <- testing(data_split)

# we also create a keep_out set to be used later as mock real data
data_split <- initial_split(tmpDf, prop = .5)

# Create data frames for the two sets:
days$day2 <- training(data_split)
days$day3  <- testing(data_split)

for(i in 1:3){
  for (k in seq(1:nrow(days[[i]]))){
    preds <- httr::POST("http://127.0.0.1:4023/predict_flights",
                        body = jsonlite::toJSON(days[[i]][k,]),
                        encode = "json")
  }
  file.rename(here::here('logs', 'requests',
                         paste0(as.character(Sys.Date()), '.log')),
              here::here('logs', 'requests',
                         paste0(as.character(Sys.Date()+i), '.log')))
  file.rename(here::here('logs', 'responses',
                         paste0(as.character(Sys.Date()), '.log')),
              here::here('logs', 'responses',
                         paste0(as.character(Sys.Date()+i), '.log')))
  file.rename(here::here('logs', 'performance',
                         paste0(as.character(Sys.Date()), '.log')),
              here::here('logs', 'performance',
                         paste0(as.character(Sys.Date()+i), '.log')))
}

