# vetiverMLOps
PoC using vetiver as an MLOps solution

This repo is a toy experiment on setting up an MLOps solution using only the R ecosystem and the `vetiver` package.

To know more about it, refer to the series of articles starting [here](https://medium.com/@adrian.joseph/build-an-end-to-end-mlops-solution-with-vetiver-for-r-and-python-part-1-46f1c56e684).

# Usage

To run everything locally, without any real deployment:

**Set up**

The bash script should take up to 5min, depending on your machine.

* `renv::restore()`
* From the Terminal execute `bash ./auxScripts/startAPI.bash` (Mac OS)

**Build the model**

This will take 2 to 3min.

* `source(here::here('model_dev', 'R', 'model_dev.R'))`

**Deploy the model**

This should take around 5min

* Knit the R Markdown `./model_deployment/deployment.Rmd`

**Create some log files**

This step will take around 10min.

* `source(here::here('auxScripts', 'prepare_logs_for_monitoring.R'))`

**Pre-process the logs**

* Knit the R Markdown `./logs_data_processing/log_data_processing.Rmd`

**Start the monitoring app**

* Start the app: `shiny::runApp(here::here('model_monitoring'))`
