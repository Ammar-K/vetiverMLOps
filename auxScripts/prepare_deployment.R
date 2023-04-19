source(here::here('model_dev', 'R', 'model_dev.R'))

vetiver_flights_fit <- vetiver::vetiver_model(
  model = flights_fit, model_name = 'flights_fit',
  description = 'Flights model',
  metadata = list(developer = 'Name.Surname',
                  team = 'Team.Name',
                  contact = 'name.surname@company.com'))

board %>% vetiver::vetiver_pin_write(vetiver_model = vetiver_flights_fit)

# nuke logs. comment this out if you want to keep old logs
unlink(here::here('logs'), recursive = TRUE, force = TRUE)
logFolders <- c('deployment', 'performance', 'requests', 'responses')
for (i in logFolders){
  dir.create(here::here('logs', i), recursive = TRUE)
}
