# Scatter_plot.R
library(shinycssloaders)
library(bsicons)

ui_scatter <- nav_panel_hidden(
  "pagina_scatter", 
  layout_sidebar(
    sidebar = sidebar(
      title = span(bs_icon("graph-up-arrow"), " Correlación Bivariada"),
      bg = "#F5F3FF", # Fondo lila muy tenue para la sidebar
      
      dateRangeInput("dates_scatter", "Rango de fechas",
                     start = Sys.Date() - 7, end = Sys.Date(),
                     language = "es"),
      hr(style = "border-top: 1px solid #DDD6FE;"),
      
      selectInput("station_scatter", "Estación:", choices = NULL),
      selectInput("Pollutant_x", "Contaminante eje X:", choices = NULL),
      selectInput("Pollutant_y", "Contaminante eje Y:", choices = NULL),
      
      hr(style = "border-top: 1px solid #DDD6FE;"),
      
      # Botón Generar (Asegúrate de ponerle #4F46E5 en el server)
      div(class="text-center mb-3",
          uiOutput("control_scatter_ui")),
      
      # Botón para el análisis IA (Morado/Índigo Unificado)
      actionButton(
        "btn_analizar_scatter", 
        "Analizar Gráfica",
        icon = bs_icon("robot"),
        class = "w-100",
        style = "background-color: #4F46E5; color: white; border: none; font-weight: 700; padding: 12px; border-radius: 8px; box-shadow: 0 4px 6px rgba(79, 70, 229, 0.2);"
      ),
      
      hr(style = "border-top: 1px solid #DDD6FE;"),
      
      # Botón volver
      actionButton(
        "volver_inicio5", "Volver al menú",
        icon = bs_icon("arrow-left-short"),
        style = "background-color: transparent; color: #4F46E5; border: 1px solid #DDD6FE; width: 100%; margin-top: 10px; font-weight: 500;"
      )
    ),
    
    # Área Principal
    card(
      full_screen = TRUE,
      card_header(
        div(class="d-flex justify-content-between align-items-center",
            span(bs_icon("diagram-3"), " Análisis de Dispersión Atmosférica"),
            # Badge en color morado
            span(class="badge", style="background-color: #EDE9FE; color: #4338CA;", "Relación Bivariada"))
      ),
      card_body(
        # Spinner en color índigo
        withSpinner(plotOutput("plot_scatter", height = "550px"), color = "#4F46E5"),
        hr(),
        
        # Sección de IA con Acordeón estilizado
        accordion(
          open = TRUE,
          accordion_panel(
            "Interpretación Experta (IA)",
            icon = bs_icon("stars"), 
            div(
            withSpinner(
              uiOutput("analisis_ia_scatter_out"),
              type = 4,
              color = "#4F46E5",
              size = 0.7
            )
            )
          )
        )
      ),
      style = "border-radius: 15px; border: 1px solid #EDE9FE;"
    )
  )
)