# vetiverMLOps
PoC using vetiver as an MLOps solution

This repo is a toy experiment on setting up an MLOps solution using only the R ecosystem and the `vetiver` package.

To know more about it, refer to the series of articles starting here LINK

# Usage

To run everything locally, without any real deployment:

**Set up**

* `renv::restore()`
* From the Terminal execute `bash ./auxScripts/startAPI.bash` (Mac OS)

**Build the model**

* `source(here::here('model_dev', 'R', 'model_dev.R'))`

**Deploy the model**

* Knit the R Markdown `./model_deployment/deployment.Rmd`

### Coming soon

**Create some log files**

* Source the file `./auxScripts/prepare_logs_for_monitoring.R`

**Pre-process the logs**

* Knit the R Markdown `./logs_data_processing/log_data_processing.Rmd`

**Start the monitoring app**

* Start the app in `./model_monitoring/app.R`
