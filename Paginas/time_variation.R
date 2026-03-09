# time_variation.R
library(shinycssloaders)


ui_time_variation <- nav_panel_hidden(
  "pagina_analisis", # Este es el ID al que saltará el botón
  layout_sidebar(
    sidebar = sidebar(
      title = "Parámetros de Consulta",
      bg = "#F1F8E9",
      dateRangeInput("dates", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date()),
      selectInput("station", "Estación:", 
                  choices = NULL),
      selectInput("pollutant", "Contaminante:", 
                  choices = NULL),
      hr(),
      div(class="text-center mb-3",
          uiOutput("control_time_ui")),
      hr(),
      
      #Boton para el analisis
      actionButton("btn_analizar_tv", "Analizar Gráfica",
                   icon=bs_icon("robot"),
                   class="btn-primary w-100"),
      
      hr(),
      actionButton("volver_inicio", "Volver al Menú", 
                   icon = bs_icon("arrow-left"))
    ),
    card(
      card_header("Resultado del Análisis Temporal"),
      card_body(
        withSpinner(plotOutput("time_variation_plot", height = "600px"),color = "#2E8B57"),
        hr(),
        #Seccion para el resutaldo de la IA
        accordion(
          accordion_panel(
            "Analisis Detallado",
            icon = bs_icon("incognito"),
            withSpinner(uiOutput("analisis_ia_out"),
                        type=4,
                        color="#2E8B57",
                        size=0.7)
          )
        )
      )
    )
  )
)