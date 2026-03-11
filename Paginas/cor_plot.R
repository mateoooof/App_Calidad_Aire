# cor_plot.R
library(shinycssloaders)
library(bsicons)

ui_corplot <- nav_panel_hidden(
  "pagina_cor",
  layout_sidebar(
    sidebar = sidebar(
      title = span(bs_icon("grid-3x3"), " Correlación Lineal"),
      bg = "#f8f9fa", # Un gris casi blanco para mayor limpieza
      
      dateRangeInput("dates_corplot", "Periodo de Análisis:", 
                     start = Sys.Date() - 7, end = Sys.Date(),
                     language = "es", separator = " a "),
      
      selectInput("station_corplot", "Estación de Monitoreo:", 
                  choices = NULL),
      
      hr(style = "border-top: 1px solid #dee2e6;"),
      
      # Botón de Generar (Dinamizado por Server)
      div(class="text-center mb-3",
          uiOutput("control_corplot_ui")),
      
      # Botón de Análisis IA con el nuevo color Tecnológico
      actionButton(
        "btn_analizar_cor", 
        "Analizar Matriz",
        icon = bs_icon("cpu"), # Cambiado a CPU para diferenciar de la otra página
        class = "w-100",
        style = "background-color: #1A73E8; color: white; border: none; font-weight: 700; padding: 12px; border-radius: 8px; box-shadow: 0 2px 5px rgba(26,115,232,0.2);"
      ),
      
      hr(style = "border-top: 1px solid #dee2e6;"),
      
      # Botón Volver con estilo minimalista
      actionButton(
        "volver_inicio3", 
        "Volver al Menú", 
        icon = bs_icon("chevron-left"),
        style = "background-color: transparent; color: #78909C; border: 1px solid #CFD8DC; width: 100%; font-weight: 500; border-radius: 6px;"
      )
    ),
    
    # Área Principal de Contenido
    card(
      full_screen = TRUE,
      card_header(
        div(class="d-flex justify-content-between align-items-center",
            span(bs_icon("table"), " Matriz de Correlación de Pearson"),
            span(class="badge rounded-pill", style="background-color: #e8f0fe; color: #1a73e8;", "Multivariado"))
      ),
      card_body(
        withSpinner(
          plotOutput("plot_corplot", height = "580px"),
          color = "#1A73E8",
          type = 5
        ),
        hr(),
        
        # Acordeón de Análisis IA con estilo moderno
        accordion(
          open = TRUE,
          accordion_panel(
            "Interpretación Científica de la Matriz",
            icon = bs_icon("stars"), # Icono de 'brillo/IA'
            div(
            withSpinner(
              uiOutput("analisis_ia_out_cor"),
              type = 4,
              color = "#1A73E8",
              size = 0.7
            )
            )
          )
        )
      ),
      style = "border-radius: 12px; border: 1px solid #e0e0e0; box-shadow: 0 4px 12px rgba(0,0,0,0.03);"
    )
  )
)