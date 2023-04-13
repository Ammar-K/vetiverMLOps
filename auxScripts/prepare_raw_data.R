library(tidyverse)
library(pins)
library(nycflights13)

# clean up local board
board <- pins::board_local(versioned = TRUE)
allPins <- board %>%
  pins::pin_list()
for (i in allPins){
  board %>%
    pins::pin_delete(i)
}


board %>% pins::pin_write(x = nycflights13::flights,
                          name = 'raw_data')

board %>% pins::pin_write(x = nycflights13::weather,
                          name = 'weather')

