library(shiny)
library(plotly)
library(tidyverse)
board <- pins::board_local()
metadata <- unlist(board %>% pins::pin_meta('flights_fit'))
allRequests <- board %>% pins::pin_read('requests')
allResponses <- board %>% pins::pin_read('responses')
performance <- board %>% pins::pin_read('performance')
model_versions <- board %>% pins::pin_versions('flights_fit')

ui <- fluidPage(

  # Application title
  titlePanel("Model monitoring"),

  fluidPage(
    fluidRow(
      wellPanel(
        tableOutput("latestModelMetadata")
      ),
      wellPanel(
        tableOutput("modelHistory")
      ),
      wellPanel(
        plotOutput("predsDistPlot")
      ),
      wellPanel(
        tableOutput("predsDistTable")
      ),
      wellPanel(
        plotOutput("hitCount")
      ),
      wellPanel(
        plotOutput("accuracyPlot")
      ),
      wellPanel(
        plotOutput("performancePlot")
      ),
      wellPanel(
        includeMarkdown(here::here("model_dev", "model_card", "model_card.Rmd"))
      )
    ))
)

server <- function(input, output) {

  output$latestModelMetadata <- renderTable({
    metadata <- as.data.frame(metadata)
    metadata$field <- row.names(metadata)
    metadata <- metadata[, c(2,1)]
    metadata
  })

  output$modelHistory <- renderTable({
    model_versions$created <- as.character(model_versions$created)
    model_versions
  })

  output$predsDistPlot <- renderPlot({
    respCount <- allResponses %>%
      group_by(dateIs, .pred_class) %>%
      summarize(n = n()) %>%
      mutate(as.character(dateIs))

    g1 <- ggplot(data = respCount, aes(x = interaction(dateIs, .pred_class), y = n, fill = factor(.pred_class))) +
      geom_bar(stat = 'identity') +
      annotate("text", x = 1:6, y = - 40,
               label = rep(unique(respCount$dateIs), 2)) +
      theme_classic() +
      theme(plot.margin = unit(c(1, 1, 4, 1), "lines"),
            axis.title.x = element_blank(),
            axis.text.x = element_blank()
      ) +
      guides(fill=guide_legend(title="Prediction class")) +
      ggtitle('Distribution of predictions across days')

    g1
  })

  output$predsDistTable <- renderTable({
    respCount <- allResponses %>%
      group_by(dateIs, .pred_class) %>%
      summarize(n = n()) %>%
      mutate(dateIs = as.character(dateIs))

    respCount
  })

  output$hitCount <- renderPlot({
    respCount <- allResponses %>%
      group_by(dateIs) %>%
      summarize(n = n())

    g1 <- ggplot(respCount) +
      aes(x = dateIs, y = n) +
      geom_line(colour = "#112446") +
      labs(x = "Day", y = "n", title = "Hits count by day") +
      theme_minimal()

    g1
  })


  output$accuracyPlot <- renderPlot({
    finalDf <- data.frame(preds = as.factor(allResponses$.pred_class),
                          truths = as.factor((allRequests$arr_delay)),
                          dateIs = allResponses$dateIs)

    finalDf <- split(finalDf, finalDf$dateIs)
    finalDf <- lapply(finalDf, function(d){
      acc <- d %>% yardstick::accuracy(preds, truths)
      df <- data.frame(acc = acc$.estimate,
                       dateIs = unique(d$dateIs))
    })

    finalDf <- bind_rows(finalDf)

    g1 <- ggplot(finalDf) +
      aes(x = dateIs, y = acc) +
      geom_line(colour = "#112446", linewidth = 2) +
      labs(x = "Day", y = "n", title = "Accuracy by day") +
      ylim(c(0,1)) +
      theme_minimal() +
      geom_hline(yintercept=0.8, linetype="dashed",
                 color = "red", linewidth = 2)
    g1
  })

  output$performancePlot <- renderPlot({
    ggplot(performance) +
      aes(x = user.self) +
      geom_histogram(bins = 30L, fill = "#112446") +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
