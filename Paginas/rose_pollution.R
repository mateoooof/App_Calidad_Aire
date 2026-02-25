# rose_pollution.R
ui_rose_pollution <- nav_panel_hidden(
  "pagina_rosa", # ID de esta página
  layout_sidebar(
    sidebar = sidebar(
      title = "Rosa de Contaminantes",
      bg = "#FFF3E0", # Un color pastel diferente (naranja suave)
      dateRangeInput("dates_rose", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date()),
      selectInput("station_rose", "Estación:", choices = rmcab_aqs$aqs),
      selectInput("pollutant_rose", "Contaminante:", choices = c("pm10", "pm2.5", "o3")),
      hr(),
      actionButton("volver_rosa", "Volver al Menú", icon = bs_icon("arrow-left"))
    ),
    card(
      card_header("Rosa de Vientos y Contaminación"),
      plotOutput("plot_rose", height = "600px") # ID ÚNICO AQUÍ
    )
  )
)