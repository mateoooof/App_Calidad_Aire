library(shiny)
library(bslib)
library(bsicons)
library(leaflet)
library(ggplot2)
library(shinycssloaders)


source("Scripts/data_download_processing.R")
source("Scripts/plots.R")
source("Paginas/time_variation.R")
source("Paginas/rose_pollution.R")
source("Paginas/cor_plot.R")

# Dataset de Estaciones (Coordenadas aproximadas RMCAB)
estaciones_bog <- data.frame(
  nombre = c("Guaymaral", "Suba", "Fontibón", "Las Ferias", "P. Aranda", 
             "Kennedy", "Carvajal-Sevillana", "Tunal", "Usme", "Centro"),
  lat = c(4.783, 4.761, 4.670, 4.690, 4.630, 4.625, 4.595, 4.576, 4.530, 4.609),
  lng = c(-74.043, -74.093, -74.141, -74.086, -74.117, -74.161, -74.148, -74.130, -74.120, -74.072)
)


# Tema profesional con tonos pasteles
my_theme <- bs_theme(
  version = 5,
  bootswatch = "minty",
  primary = "#2E8B57",  
  secondary = "#4682B4", 
  base_font = font_google("Manrope"),
  heading_font = font_google("Montserrat")
)
#--- UI ---

ui <- page_fillable(
  theme = my_theme,
  
  # BARRA SUPERIOR
  div(class = "d-flex justify-content-between align-items-center p-3", 
      style = "background-color: #E0F2F1; border-bottom: 2px solid #B2DFDB;",
      h3("Calidad de Aire Bogotá", style = "margin: 0; color: #2E8B57; font-weight: 700;"),
      tags$img(src = "Logo Unal Sin Fondo.png", height = "45px")
  ),
  
  navset_hidden(
    id = "paginas_app",
    
    # --- PÁGINA 1: INICIO ---
    nav_panel_hidden("inicio",
                     div(style = "width: 100%; padding: 20px;",
                         
                         # FILA SUPERIOR: MAPA Y BLOQUE ICA CUSTOM
                         layout_column_wrap(
                           width = 1/2,
                           heights_equal = "row",
                           
                           card(
                             card_header(class = "bg-light", strong("Red de Monitoreo RMCAB")),
                             leafletOutput("mapa_bogota", height = "400px")
                           ),
                           
                           # BLOQUE DERECHO: ICA CUSTOM (HTML/CSS)
                           card(
                             style = "padding: 20px; border-radius: 15px;",
                             div(class = "text-center mb-3", 
                                 h4("Bogota Air Quality Index (ICA)", style = "font-weight: 600;")
                             ),
                             # Fila: Valor y Contaminante
                             div(class = "d-flex justify-content-around align-items-center mb-4",
                                 div(style = "background-color: #FFEB3B; padding: 15px 35px; border-radius: 12px; text-align: center;",
                                     h1("65", style = "font-size: 3.5rem; font-weight: 800; margin:0;"),
                                     span("Moderate", style = "font-weight: 600;")
                                 ),
                                 div(class = "text-center",
                                     p("Polutante dominante", style = "color: #666; margin-bottom: 0;"),
                                     h2("PM2.5", style = "font-weight: 700;")
                                 )
                             ),
                             # Leyenda
                             div(style = "background-color: #F8F9FA; padding: 15px; border-radius: 10px;",
                                 p("Legend", style = "text-align: center; font-size: 0.8rem; margin-bottom: 5px;"),
                                 div(style = "height: 10px; width: 100%; border-radius: 5px; 
                             background: linear-gradient(to right, #4CAF50 16%, #FFEB3B 33%, #FF9800 50%, #F44336 66%, #9C27B0 83%, #673AB7 100%);"),
                                 div(class = "d-flex justify-content-between", style = "font-size: 0.65rem; margin-top: 5px;",
                                     span("Good"), span("Moderate"), span("Unhealthy"), span("Poor"), span("Very Poor"), span("Severe")
                                 )
                             )
                           )
                         ),
                         
                         br(),
                         h4("Módulos de Análisis Avanzado", style = "text-align: center; margin: 20px 0;"),
                         
                         # FILA INFERIOR: TARJETAS CON TEXTO/IMG Y BOTÓN ANCHO
                         layout_column_wrap(
                           width = 1/3,
                           heights_equal = "row",
                           
                           # Tarjeta 1
                           card(
                             card_header("Dinámica Temporal", class = "bg-primary text-white"),
                             card_body(
                               #Texto arriba
                              div(style = "min-height: 100px;",
                                p(strong("¿En qué momentos del día o la semana se alcanzan los picos críticos de polución?"), 
                                  style = "font-size: 1rem; color: #2E8B57; margin-bottom: 5px;"),
                                p("Explora ciclos horarios, diarios y mensuales mediante modelos de variación estadística.", 
                                  style = "font-size: 0.85rem; color: #666;")
                              ),
                              #Imagen debajo
                              div(class= "text-center my-3",
                                  tags$img(src="timeVariation.png", style = "width: 100%; max-height: 200px; object-fit: contain; border-radius: 5px;")
                              )
                               ),
                             card_footer(
                               actionButton("ir_analisis", "Abrir Análisis Temporal", class = "btn-outline-primary w-100")
                             )
                             ),
                           
                           # Tarjeta 2
                           card(
                             card_header("Origen y Dispersión", class = "bg-info text-white"),
                             card_body(
                               div(style = "min-height: 100px;",
                                   p(strong("¿Desde qué dirección provienen las masas de aire más contaminadas hacia la estación?"), 
                                     style = "font-size: 1rem; color: #007BFF; margin-bottom: 5px;"),
                                   p("Cruza datos de velocidad y dirección del viento para localizar fuentes de emisión potenciales.", 
                                     style = "font-size: 0.85rem; color: #666;")
                               ),
                               div(class = "text-center my-3",
                                   tags$img(src = "pollutionRose.png", 
                                            style = "width: 100%; max-height: 200px; object-fit: contain; border-radius: 5px;")
                               )
                             ),
                             card_footer(
                               actionButton("ir_rosa", "Generar Rosa de Vientos", class = "btn-outline-info w-100")
                             )
                           ),
                           
                           # Tarjeta 3
                           card(
                             card_header("Relación Multivariada", class = "bg-dark text-white"),
                             card_body(
                               div(style = "min-height: 100px;",
                                   p(strong("¿Cómo influye la humedad o la temperatura en la concentración de material particulado?"), 
                                     style = "font-size: 1rem; color: #343a40; margin-bottom: 5px;"),
                                   p("Analiza la dependencia lineal entre variables meteorológicas y contaminantes críticos.", 
                                     style = "font-size: 0.85rem; color: #666;")
                               ),
                               div(class = "text-center my-3",
                                   tags$img(src = "correlation.png", 
                                            style = "width: 100%; max-height: 200px; object-fit: contain; border-radius: 5px;")
                               )
                             ),
                             card_footer(
                               actionButton("ir_cor", "Ver Matriz de Correlación", class = "btn-outline-dark w-100")
                             )
                           )
                         )
                     )
    ),
    
    # 1. REFERENCIA A TUS UI EXTERNAS
    # Estos IDs deben coincidir con los que usas en nav_select en el server
    nav_panel_hidden("pagina_analisis", ui_time_variation),
    nav_panel_hidden("pagina_rosa", ui_rose_pollution),
    nav_panel_hidden("pagina_cor", ui_cor_plot)
  ),
  # --- FOOTER (AÑADIR AL FINAL DE TU UI) ---
  tags$footer(
    style = "background-color: #f8f9fa; padding: 30px 0; border-top: 1px solid #dee2e6; margin-top: 20px;",
    div(class = "container",
        div(class = "row align-items-center",
            # Columna Izquierda: Información de la Red
            div(class = "col-md-4 text-center text-md-start",
                p(strong("Datos RMCAB"), style = "margin-bottom: 5px;"),
                p("Red de Monitoreo de Calidad del Aire de Bogotá.", 
                  style = "font-size: 0.85rem; color: #666;")
            ),
            # Columna Central: Créditos
            div(class = "col-md-4 text-center",
                p(strong("Desarrollado por:"), " Andres Franco", style = "margin-bottom: 5px;"),
                p("© 2026 - Universidad Nacional de Colombia", 
                  style = "font-size: 0.8rem; color: #999; font-style: italic;")
            ),
            # Columna Derecha: Enlaces rápidos (Opcional)
            div(class = "col-md-4 text-center text-md-end",
                a("Manual de Usuario", href = "#", style = "color: #2E8B57; text-decoration: none; font-size: 0.9rem;"),
                br(),
                a("Contacto Soporte", href = "mailto:anfrancor@unal.edu.co", style = "color: #2E8B57; text-decoration: none; font-size: 0.9rem;")
            )
        )
    )
  )
)

server <- function (input, output, session){

  # --- NAVEGACIÓN ---
  # El ID "paginas_app" es el del navset_hidden. 
  # El segundo argumento es el valor del nav_panel_hidden definido arriba.
  observeEvent(input$ir_analisis, { nav_select("paginas_app", "pagina_analisis") })
  observeEvent(input$ir_rosa, { nav_select("paginas_app", "pagina_rosa") })
  observeEvent(input$ir_cor, { nav_select("paginas_app", "pagina_cor") })
  
  # Lógica para botones de "Volver" (Asegúrate que en tus UIs externas se llamen así)
  observeEvent(input$volver_inicio, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio2, { nav_select("paginas_app", "inicio") })
  
  
  # MAPA BOGOTÁ CON LAS 10 ESTACIONES
  output$mapa_bogota <- renderLeaflet({
    #Icono estacion
    icono_estacion <- makeIcon(
      iconUrl = "broadcasting.png",
      iconWidth = 35, iconHeight = 35,
      iconAnchorX = 17, iconAnchorY = 35
    )
    
    leaflet(estaciones_bog) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -74.10, lat = 4.65, zoom = 11) %>%
      addMarkers(
        lng = ~lng, lat = ~lat,
        icon = icono_estacion,
        popup = ~nombre,
        label = ~nombre
      )
  })


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
