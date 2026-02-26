# cor_plot.R
ui_cor_plot <- nav_panel_hidden(
  "pagina_cor", # ID de esta página
  layout_sidebar(
    sidebar = sidebar(
      title = "Correlación Contaminantes",
      bg = "#C6EAF7", 
      dateRangeInput("dates_cor", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date()),
      selectInput("station_cor", "Estación:", choices = rmcab_aqs$aqs),
      
      hr(),
      actionButton("volver_cor", "Volver al Menú", icon = bs_icon("arrow-left"))
    ),
    card(
      card_header("Correlación de Contaminantes"),
      plotOutput("plot_cor", height = "600px") # ID ÚNICO AQUÍ
    )
  )
)