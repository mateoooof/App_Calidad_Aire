# time_variation.R
library(shinycssloaders)
library(bsicons)

ui_time_variation <- nav_panel_hidden(
  "pagina_analisis",
  layout_sidebar(
    sidebar = sidebar(
      title = span(bs_icon("clock-history"), " Análisis Temporal"),
      bg = "#F7F9F7", # Un verde/grisáceo casi imperceptible
      
      dateRangeInput("dates", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date(),
                     language = "es"),
      
      selectInput("station", "Estación de Monitoreo:", choices = NULL),
      selectInput("pollutant", "Contaminante:", choices = NULL),
      
      hr(style = "border-top: 1px solid #C8E6C9;"),
      
      # Botón de Generar (Dinamizado por Server - Sugerencia: usar verde #2E8B57)
      div(class="text-center mb-3",
          uiOutput("control_time_ui")),
      
      # Botón de Análisis IA (Azul Tecnológico Unificado)
      actionButton(
        "btn_analizar_tv", 
        "Interpretación IA",
        icon = bs_icon("cpu-fill"), 
        class = "w-100",
        style = "background-color: #1A73E8; color: white; border: none; font-weight: 700; padding: 12px; border-radius: 8px; box-shadow: 0 4px 6px rgba(26, 115, 232, 0.2);"
      ),
      
      hr(style = "border-top: 1px solid #C8E6C9;"),
      
      # Botón Volver (Estilo minimalista)
      actionButton(
        "volver_inicio", 
        "Volver al Menú", 
        icon = bs_icon("arrow-left-circle"),
        style = "background-color: transparent; color: #455A64; border: 1px solid #CFD8DC; width: 100%; font-weight: 500; border-radius: 6px;"
      )
    ),
    
    # Área Principal
    card(
      full_screen = TRUE,
      card_header(
        div(class="d-flex justify-content-between align-items-center",
            span(bs_icon("calendar3"), " Comportamiento de Contaminantes en el Tiempo"),
            span(class="badge", style="background-color: #E8F5E9; color: #2E7D32;", "Tendencias Históricas"))
      ),
      card_body(
        withSpinner(
          plotOutput("time_variation_plot", height = "580px"),
          color = "#2E8B57", # Verde para la carga de datos ambientales
          type = 7
        ),
        hr(),
        
        # Análisis de la IA con Acordeón
        accordion(
          open = TRUE,
          accordion_panel(
            "Análisis de Ciclos y Patrones",
            icon = bs_icon("graph-up-arrow"),
            div(
            withSpinner(
              uiOutput("analisis_ia_out"),
              type = 4,
              color = "#1A73E8", # Azul para la carga de IA
              size = 0.7
            )
            )
          )
        )
      ),
      style = "border-radius: 12px; border: 1px solid #E8F5E9;"
    )
  )
)