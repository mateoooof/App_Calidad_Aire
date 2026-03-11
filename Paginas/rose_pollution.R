# rose_pollution.R
library(shinycssloaders)
library(bsicons)

ui_rose_pollution <- nav_panel_hidden(
  "pagina_rosa",
  layout_sidebar(
    sidebar = sidebar(
      title = span(bs_icon("compass"), " Análisis de Vientos"),
      # Un azul muy suave para la sidebar que combina con el tema meteorológico
      bg = "#F0F9FF", 
      
      dateRangeInput("dates_rose", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date(),
                     language = "es"),
      
      selectInput("station_rose", "Estación:", choices = NULL),
      selectInput("pollutant_rose", "Contaminante:", choices = NULL),
      
      hr(style = "border-top: 1px solid #BAE6FD;"),
      
      # Botón de Generar (Asegúrate de ponerle un azul medio en el server)
      div(class="text-center mb-3",
          uiOutput("control_rose_ui")),
      
      # Botón de Análisis IA (Azul Profundo Tecnológico)
      actionButton(
        "btn_analizar_rp", 
        "Interpretar Rosa",
        icon = bs_icon("magic"), 
        class = "w-100",
        style = "background-color: #0369A1; color: white; border: none; font-weight: 700; padding: 12px; border-radius: 8px; box-shadow: 0 4px 6px rgba(3, 105, 161, 0.2);"
      ),
      
      hr(style = "border-top: 1px solid #BAE6FD;"),
      
      # Botón Volver con estilo "Ghost"
      actionButton(
        "volver_inicio2", 
        "Volver al Menú", 
        icon = bs_icon("arrow-left-short"),
        style = "background-color: transparent; color: #0369A1; border: 1px solid #BAE6FD; width: 100%; font-weight: 600; border-radius: 6px;"
      )
    ),
    
    # Área Principal
    card(
      full_screen = TRUE,
      card_header(
        div(class="d-flex justify-content-between align-items-center",
            span(bs_icon("wind"), " Rosa de Contaminación Atmosférica"),
            span(class="badge", style="background-color: #E0F2FE; color: #0369A1;", "Dirección y Magnitud"))
      ),
      card_body(
        withSpinner(
          plotOutput("plot_rose", height = "580px"),
          color = "#0369A1",
          type = 6 # Tipo de spinner diferente para variar
        ),
        hr(),
        
        # Análisis de la IA
        accordion(
          open = TRUE,
          accordion_panel(
            "Análisis de Procedencia de Contaminantes",
            icon = bs_icon("robot"),
            div(
            withSpinner(
              uiOutput("analisis_ia_out_rp"),
              type = 4,
              color = "#0369A1",
              size = 0.7
            )
            )
          )
        )
      ),
      style = "border-radius: 15px; border: 1px solid #E0F2FE;"
    )
  )
)