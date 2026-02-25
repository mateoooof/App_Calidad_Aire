library(shiny)
library(bslib)
library(bsicons)

source("Scripts/data_download_processing.R")
source("Scripts/plots.R")

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
                           p("Esta plataforma utiliza datos oficiales de la RMCAB para generar análisis técnicos 
              mediante modelos atmosféricos y herramientas estadísticas avanzadas.", 
                             style = "font-size: 1.2rem; color: #666;")
                       ),
                       hr(),
                       layout_column_wrap(
                         width = 1/2,
                         # TARJETA 1: ANÁLISIS
                         card(
                           card_header("Análisis de Estaciones", class = "bg-primary"),
                           card_body(
                             p("Visualiza series de tiempo y tendencias de contaminantes por estación."),
                             actionButton("ir_analisis", "Ir a Análisis", class = "btn-outline-dark w-100", icon = bs_icon("graph-up"))
                           )
                         ),
                         # TARJETA 2: OTRA FUNCIÓN (Ejemplo)
                         card(
                           card_header("Información Técnica", class = "bg-info text-white"),
                           card_body(
                             p("Consulta la documentación sobre los sensores y métodos de medición."),
                             actionButton("ir_info", "Ver Detalles", class = "btn-outline-light w-100", icon = bs_icon("info-circle"))
                           )
                         )
                       )
                     )
    ),
    
    # --- PÁGINA 2: ANÁLISIS DE ESTACIONES ---
    nav_panel_hidden("pagina_analisis",
                     layout_sidebar(
                       sidebar = sidebar(
                         title = "Parámetros de Consulta",
                         bg = "#F1F8E9",
                         dateRangeInput("dates", "Rango de fechas:", 
                                        start = Sys.Date()-7, end = Sys.Date()),
                         selectInput("station", "Estación:", 
                                     choices = rmcab_aqs$aqs),
                         selectInput("pollutant", "Contaminante:", 
                                     choices = c("pm10", "pm25", "o3", "no2")),
                         selectInput("plot_type","Tipo de Gráfico:",
                                     choices = c("Variacion contaminante con el tiempo","Rosa de contaminantes")),
                         #actionButton("update_plot", "Generar Gráfica", class = "btn-success w-100"),
                         hr(),
                         actionButton("volver_inicio", "Volver al Menú", icon = bs_icon("arrow-left"), class = "btn-link")
                       ),
                       
                       card(
                         card_header("Resultado"),
                         card_body(
                           # Aquí se mostrará la gráfica
                           plotOutput("main_plot", height = "600px")
                         )
                       )
                     )
    )
  )
)
server <- function (input, output, session){

  # NAVEGACIÓN
  observeEvent(input$ir_analisis, { updateNavsetIndicator("paginas_app", "pagina_analisis") })
  observeEvent(input$volver_inicio, { updateNavsetIndicator("paginas_app", "inicio") })
  
  # TU LÓGICA INTEGRADA (Optimizada)
  # Es mejor definir el reactivo fuera del renderPlot para mayor eficiencia
  data_reactive <- reactive({
    req(input$dates, input$station)
    
    # Llamada a tu función en data_dowload_processing.r
    get_data_clean(
      aqs = input$station,
      start_date = format(input$dates[1], "%d-%m-%Y"),
      end_date   = format(input$dates[2], "%d-%m-%Y")
    )
  })
  
  output$main_plot <- renderPlot({
    df <- data_reactive()
    req(df) # Asegura que haya datos antes de graficar
    
    # Llamada a tus funciones en plots.r
    if(input$plot_type == "Variacion contaminante con el tiempo"){
      plot_time_variation(
        data = df,
        pollutant = input$pollutant
      )
    } else if (input$plot_type == "Rosa de contaminantes"){
      plot_pollution_rose(
        data = df,
        pollutant = input$pollutant
      )
    }
  })
  
}

shinyApp(ui, server)
