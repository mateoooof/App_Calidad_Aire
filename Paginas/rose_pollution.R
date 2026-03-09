# rose_pollution.R
library(shinycssloaders)

ui_rose_pollution <- nav_panel_hidden(
  "pagina_rosa", # ID de esta página
  layout_sidebar(
    sidebar = sidebar(
      title = "Rosa de Contaminantes",
      bg = "#E1F5FE", 
      dateRangeInput("dates_rose", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date()),
      selectInput("station_rose", "Estación:", choices = NULL),
      selectInput("pollutant_rose", "Contaminante:", choices = NULL),
      hr(),
      div(class="text-center mb-3",
          uiOutput("control_rose_ui")),
      hr(),
      #Boton para el analisis
      actionButton("btn_analizar_rp", "Analizar Gráfica",
                   icon=bs_icon("robot"),
                   style = "background-color: #0277BD; color: white; border: none; width: 100%; font-weight:700; padding: 10px; border-radius: 5px;",
                   class="btn-primary w-100",
                   ),
      hr(),
      actionButton("volver_inicio2", "Volver al Menú", icon = bs_icon("arrow-left"),
                   style = "background-color: #E1F5FE; color: #01579B; border: 1px solid #81D4FA; width: 100%; margin-top: 10px; font-weight: 600;")
    ),
    card(
      card_header("Rosa de Vientos y Contaminación"),
      card_body(
        withSpinner(plotOutput("plot_rose", height = "600px"), color="#01579B"),
        hr(),
        #Seccion para el resutaldo de la IA
        accordion(
          accordion_panel(
            "Analisis Detallado",
            icon = bs_icon("incognito"),
            withSpinner(uiOutput("analisis_ia_out_rp"),
                        type=4,
                        color="#01579B",
                        size=0.7)
          )
        )
      )
    )
  )
)