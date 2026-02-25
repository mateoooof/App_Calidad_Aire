# time_variation.R

ui_time_variation <- nav_panel_hidden(
  "pagina_analisis", # Este es el ID al que saltará el botón
  layout_sidebar(
    sidebar = sidebar(
      title = "Parámetros de Consulta",
      bg = "#F1F8E9",
      dateRangeInput("dates", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date()),
      # Nota: rmcab_aqs debe estar cargado o disponible
      selectInput("station", "Estación:", 
                  choices = rmcab_aqs$aqs),
      selectInput("pollutant", "Contaminante:", 
                  choices = c("pm10", "pm2.5", "o3", "no2")),
      hr(),
      actionButton("volver_inicio", "Volver al Menú", 
                   icon = bs_icon("arrow-left"), class = "btn-link")
    ),
    card(
      card_header("Resultado"),
      card_body(
        plotOutput("time_variation_plot", height = "600px")
      )
    )
  )
)