library(shiny)

source("R/data_download_processing.R")
source("R/plots.R")

ui <- fluidPage(
  
  titlePanel("Análisis Calidad del Aire"),
  
  sidebarLayout(
    sidebarPanel(
      
      dateRangeInput("dates",
                     "Seleccione rango de fechas",
                     start = Sys.Date()-7,
                     end   = Sys.Date()),
      
      selectInput("station",
                  "Seleccione estación",
                  choices = rmcab_aqs$aqs),
      
      selectInput("pollutant",
                  "Seleccione contaminante",
                  choices = c("pm10","pm2.5")),
      
      selectInput("plot_type",
                  "Seleccione grafica",
                  choices =c("Variacion contaminante con el tiempo", 
                             "Rosa de contaminantes"))
      
    ),
    
    mainPanel(
      plotOutput("main_plot")
    )
  )
)

server <- function(input, output, session){
  
  
  
  output$main_plot <- renderPlot({
    data_reactive <- reactive({
      
      req(input$dates, input$station)
      
      
      get_data_clean(
        aqs = input$station,
        start_date = format(input$dates[1], "%d-%m-%Y"),
        end_date   = format(input$dates[2], "%d-%m-%Y")
      )
    })
    
    req(data_reactive())
    
    if(input$plot_type =="Variacion contaminante con el tiempo"){
      plot_time_variation(
        data = data_reactive(),
        pollutant = input$pollutant
      )
    } else if (input$plot_type == "Rosa de contaminantes"){
      
      plot_pollution_rose(
        data = data_reactive(),
        pollutant = input$pollutant
      )
    }
    
    
  })
  
}

shinyApp(ui, server)