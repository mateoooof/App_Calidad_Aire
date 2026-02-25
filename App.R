library(shiny)
library(bslib)
library(bsicons)

source("Scripts/data_download_processing.R")
source("Scripts/plots.R")
source("Paginas/time_variation.R")
source("Paginas/rose_pollution.R")

# Tema profesional con tonos pasteles
my_theme <- bs_theme(
  version = 5,
  bootswatch = "minty",
  primary = "#98FB98",  
  secondary = "#87CEEB", 
  base_font = font_google("Inter"),
  heading_font = font_google("Montserrat")
)

ui <- page_fillable(
  theme = my_theme,
  
  # BARRA SUPERIOR PERSONALIZADA (No es un nav_panel, es un header fijo)
  div(class = "d-flex justify-content-between align-items-center p-3", 
      style = "background-color: #E0F2F1; border-bottom: 2px solid #B2DFDB;",
      h3("Calidad de Aire Bogotá", style = "margin: 0; color: #2E8B57; font-weight: 700;"),
      tags$img(src = "Logo Unal Sin Fondo.png", 
               height = "45px")
  ),
  
  # CONTENEDOR DE PÁGINAS OCULTAS
  navset_hidden(
    id = "paginas_app",
    
    # --- PÁGINA 1: INICIO ---
    nav_panel_hidden("inicio",
                     layout_column_wrap(
                       width = 1,
                       style = "max-width: 1000px; margin: 0 auto; padding: 40px;",
                       
                       div(class = "text-center mb-5",
                           h1("Sobre la aplicación", style = "color: #2E8B57;"),
                           p("Esta plataforma integra datos en tiempo real de las estaciones 
                             de monitoreo distribuidas estratégicamente por toda Bogotá y la 
                             Sabana (RMCAB). Nuestra herramienta permite realizar una vigilancia 
                             técnica de la calidad del aire mediante el procesamiento estadístico
                             de contaminantes críticos y variables meteorológicas. A través 
                             de modelos atmosféricos y herramientas analíticas avanzadas, 
                             transformamos datos brutos en información clave para entender el
                             comportamiento del aire en nuestra ciudad.", 
                             style = "font-size: 1.2rem; color: #666; text-align: justify; font-weight: bold")
                       ),
          
                       layout_column_wrap(
                         width = 1/2,
                         # TARJETA 1: ANÁLISIS
                         card(
                           fill = FALSE,
                           card_header(strong("Variación Temporal", style = "text-align:center"), class = "bg-primary"),
                           card_body(
                             p("¿Cómo cambian los contaminantes en el tiempo?", style = "font-weight: bold; text_align:justify"),
                             actionButton("ir_analisis", "Ir a Análisis", class = "btn-outline-dark w-100", icon = bs_icon("graph-up"))
                           )
                         ),
                         # TARJETA 2: OTRA FUNCIÓN (Ejemplo)
                         card(
                           fill = FALSE,
                           card_header(strong("Rosa de Contaminantes"), class = "bg-info text-white"),
                           card_body(
                             p("¿De dónde viene la contaminación según el viento?",  style = "font-weight: bold; text_align:justify"),
                             actionButton("ir_rosa", "Ver Rosa", class = "btn-outline-dark w-100", icon = bs_icon("compass"))
                           )
                         )
                       )
                     )
    ),
    ui_time_variation,
    ui_rose_pollution
  ),
  tags$footer(
    style = "background-color: #f8f9fa; padding: 20px; border-top: 1px solid #dee2e6; margin-top: auto;",
    div(class = "container text-center",
        p(strong("Desarrollado por:"), " Tu Nombre / Institución", style = "margin-bottom: 5px;"),
        p("Datos oficiales de la Red de Monitoreo de Calidad del Aire de Bogotá (RMCAB).", style = "font-size: 0.9em; color: #666;"),
        p("© 2026 - Herramienta de Análisis Atmosférico Avanzado", style = "font-size: 0.8em; color: #999; font-style: italic;")
    )
  )
)
server <- function (input, output, session){

  # NAVEGACIÓN
  observeEvent(input$ir_analisis, { nav_select("paginas_app", "pagina_analisis") })
  observeEvent(input$ir_rosa, { nav_select("paginas_app", "pagina_rosa") })
  
  observeEvent(input$volver_inicio, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_rosa, { nav_select("paginas_app", "inicio") })
  
  #LOGICA: Variacion Temporal

  data_time <- reactive({
      req(input$dates, input$station)
      
    get_data_clean(
        aqs = input$station,
        start_date=format(input$dates[1], "%d-%m-%Y"),
        end_date = format(input$dates[2],"%d-%m-%Y")
      )
    })
  output$time_variation_plot <- renderPlot({
    df <- data_time()
    validate(
      need(!is.null(df) && nrow(df) > 0, 
           "No hay datos suficientes (viento o contaminantes) para esta estación en el rango seleccionado. 
          Por favor, intenta con otra estación o cambia el rango de fechas.")
    )
    plot_time_variation(data=df, pollutant = input$pollutant)
  })
  
  #LOGICA: Rosa de contaminantes
  data_rose<-reactive({
    req(input$dates_rose, input$station_rose, input$pollutant_rose)
    get_data_clean(
      aqs = input$station_rose,
      start_date = format(input$dates_rose[1], "%d-%m-%Y"),
      end_date = format(input$dates_rose[2], "%d-%m-%Y")
    )
  })
  output$plot_rose <- renderPlot({
    df<-data_rose()
    # Este mensaje reemplaza el error de R por un mensaje amigable
    validate(
      need(!is.null(df) && nrow(df) > 0, 
           "No hay datos suficientes (viento o contaminantes) para esta estación en el rango seleccionado. 
          Por favor, intenta con otra estación o cambia el rango de fechas.")
    )
    plot_pollution_rose(data = df,pollutant = input$pollutant_rose)
  })
  
}
shinyApp(ui, server)
