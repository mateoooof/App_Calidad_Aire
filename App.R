library(shiny)
library(bslib)
library(bsicons)
library(leaflet)
library(ggplot2)
library(shinycssloaders)
library(bogotAIR)
library(gganimate)
library(magick)
library(httr2)
library(jsonlite)
library(dplyr)



source("Scripts/data_download_processing.R")
source("Scripts/plots.R")
source("Scripts/analisis_ia.R")
source("Paginas/time_variation.R")
source("Paginas/rose_pollution.R")
source("Paginas/cor_plot.R")
source("Paginas/gif_maker.R")
source("Paginas/Scatter_plot.R")


# Dataset de Estaciones (Coordenadas aproximadas RMCAB)
# --- Dataset de Estaciones Completo (RMCAB) ---
estaciones_bog <- rmcab_aqs[,c("aqs","lat","lon")]
names(estaciones_bog)<-c("nombre","lat","lng")

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
                         
                         # FILA SUPERIOR: MAPA Y BLOQUE 
                         layout_column_wrap(
                           width = 1/2,
                           heights_equal = "row",
                           
                           card(
                             card_header(class = "bg-light", strong("Estaciones de Monitoreo RMCAB")),
                             leafletOutput("mapa_bogota", height = "400px")
                           ),
                           
                           # BLOQUE DERECHO:
                           card(
                             style= "padding:20px; border-radius: 15px;",
                             div(class= "text-center mb-3",
                                 h4("Estado Actual de la Calidad del Aire", style= "font-weight:600")
                                 ),
                             div(class="d-flex justify-content-around align-items-center mb-4",
                                 uiOutput("ica_box_ui"),
                                 uiOutput("contaminante_ui")
                                 ),
                             div(class = "text-center mb-4",
                                 actionButton("generar_estado"," Generar Estado Actual",
                                              icon = icon("play"), class="btn-success btn-lg")
                                 ),
                             div(style = "background-color: #F8F9FA; padding: 15px; border-radius: 10px; border: 1px solid #eee;",
                                 p(strong("Nota técnica:"), " Los valores corresponden al promedio de la red monitoreada el día anterior.", 
                                   style = "font-size: 0.85rem; color: #555; text-align: center;")
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
                             card_header("Dinámica Temporal", class = "bg-primary text-white",style="font-size:1.2rem"),
                             card_body(
                               #Texto arriba
                              div(style = "min-height: 100px;",
                                p(strong("¿En qué momentos del día o la semana se alcanzan los picos críticos de polución?"), 
                                  style = "font-size: 1rem; color: #2E8B57; margin-bottom: 5px;text-align:center"),
                                p("Explora ciclos horarios, diarios y mensuales mediante modelos de variación estadística.", 
                                  style = "font-size: 1rem; color: #666;")
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
                             card_header("Origen y Dispersión", class = "bg-info text-white",style="font-size:1.2rem"),
                             card_body(
                               div(style = "min-height: 100px;",
                                   p(strong("¿Desde qué dirección provienen las masas de aire más contaminadas hacia la estación?"), 
                                     style = "font-size: 1rem; color: #007BFF; margin-bottom: 5px;text-align:center"),
                                   p("Cruza datos de velocidad y dirección del viento para localizar fuentes de emisión potenciales.", 
                                     style = "font-size: 1rem; color: #666;")
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
                             card_header("Relación Multivariada", class = "bg-dark text-white",style="font-size:1.2rem"),
                             card_body(
                               div(style = "min-height: 100px;",
                                   p(strong("¿Cómo influye la humedad o la temperatura en la concentración de material particulado?"), 
                                     style = "font-size: 1rem; color: #343a40; margin-bottom: 5px;text-align:center"),
                                   p("Analiza la dependencia lineal entre variables meteorológicas y contaminantes críticos.", 
                                     style = "font-size: 1rem; color: #666;")
                               ),
                               div(class = "text-center my-3",
                                   tags$img(src = "correlation.png", 
                                            style = "width: 100%; max-height: 200px; object-fit: contain; border-radius: 5px;")
                               )
                             ),
                             card_footer(
                               actionButton("ir_cor", "Ver Matriz de Correlación", class = "btn-outline-dark w-100")
                             )
                           ),
                           # Tarjeta 4: Mapa Animado (GIF)
                           card(
                             card_header("Evolución Espacial", class = "bg-warning text-dark", style="font-size:1.2rem"),
                             card_body(
                               div(style = "min-height: 100px;",
                                   p(strong("¿Cómo se desplaza la nube de contaminación sobre la ciudad durante el día?"), 
                                     style = "font-size: 1rem; color: #856404; margin-bottom: 5px;text-align:center"),
                                   p("Genera un mapa animado de 24 horas para visualizar la dinámica de dispersión horaria.", 
                                     style = "font-size: 1rem; color: #666;")
                               ),
                               div(class = "text-center my-3",
                                   tags$img(src = "map_gif_preview.png", style = "width: 100%; max-height: 200px; object-fit: contain; border-radius: 5px;")
                               )
                             ),
                             card_footer(
                               actionButton("ir_gif", "Generar Mapa Animado", class = "btn-outline-warning w-100")
                             )
                           ),
                           # Tarjeta 5:Correlacion entre dos contaminantes
                           card(
                             card_header("Correlacion Bivariada", class = "bg-success", style="font-size:1.2rem"),
                             card_body(
                               div(style = "min-height: 100px;",
                                   p(strong("¿Cómo se relacionan dos contaminantes entre si?"), 
                                     style = "font-size: 1rem; color: #368062; margin-bottom: 5px;text-align:center"),
                                   p("Explora la dependencia estadistíca de dos contaminantes mediante diagramas de dispersión y coeficientes de correlación.", 
                                     style = "font-size: 1rem; color: #666;")
                               ),
                               div(class = "text-center my-3",
                                   tags$img(src = "CorrelacionBivariada.png", style = "width: 100%; max-height: 200px; object-fit: contain; border-radius: 5px;")
                               )
                             ),
                             card_footer(
                               actionButton("ir_scatter", "Ver correlación bivariada", class = "btn-outline-success w-100")
                             )
                           )
                           
                         )
                     )
    ),
    
    # 1. REFERENCIA A TUS UI EXTERNAS
    # Estos IDs deben coincidir con los que usas en nav_select en el server
    nav_panel_hidden("pagina_analisis", ui_time_variation),
    nav_panel_hidden("pagina_rosa", ui_rose_pollution),
    nav_panel_hidden("pagina_cor", ui_corplot),
    nav_panel_hidden("pagina_gif", ui_gif_maker),
    nav_panel_hidden("pagina_scatter", ui_scatter)
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
                p(strong("Desarrollado por:"), " Andres Franco - Natalia Lopez", style = "margin-bottom: 5px;"),
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
  observeEvent(input$ir_gif, { nav_select("paginas_app", "pagina_gif") })
  observeEvent(input$ir_scatter,{nav_select("paginas_app", "pagina_scatter")})
  
  # Lógica para botones de "Volver" 
  observeEvent(input$volver_inicio, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio2, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio3, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio4, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio5, { nav_select("paginas_app", "inicio") })
  
  #INICIADORES
  observe({
    req(rmcab_aqs)
    #ESTACIONES
    updateSelectInput(session, "station", choices = rmcab_aqs$aqs)
    updateSelectInput(session, "station_rose", choices = rmcab_aqs$aqs)
    updateSelectInput(session, "station_corplot", choices = rmcab_aqs$aqs)
    updateSelectInput(session, "station_scatter", choices = rmcab_aqs$aqs)
    #CONTAMINANTES
    lista_contaminantes <- c("pm10", "pm2.5", "co", "no", "no2", "nox", "so2", "ozono")
    updateSelectInput(session, "pollutant", choices = lista_contaminantes)
    updateSelectInput(session, "pollutant_rose", choices = lista_contaminantes)
    updateSelectInput(session, "pollutant_gif", choices = lista_contaminantes)
    updateSelectInput(session, "Pollutant_x", choices = lista_contaminantes)
    updateSelectInput(session, "Pollutant_y", choices = lista_contaminantes)
  })
  
  
  
  #--- MAPA BOGOTÁ CON LAS 10 ESTACIONES -----
  
  output$mapa_bogota <- renderLeaflet({
    #Icono estacion
    icono_estacion <- makeIcon(
      iconUrl = "broadcasting.png",
      iconWidth = 20, iconHeight = 20,
      iconAnchorX = 17, iconAnchorY = 35
    )
    
    leaflet(estaciones_bog) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -74.10, lat = 4.65, zoom =10.5) %>%
      addMarkers(
        lng = ~lng, lat = ~lat,
        icon = icono_estacion,
        popup = ~nombre,
        label = ~nombre
      )
  })

  
  #---- Contaminante Dominante con Botón y Progreso -----
  
  # 1. Creamos una variable reactiva vacía
  resumen_data <- reactiveVal(NULL)
  
  # 2. Lógica al presionar el botón
  observeEvent(input$generar_estado, {
    
    # Mostramos la barra de progreso en la UI
    withProgress(message = 'Iniciando conexión con RMCAB...', value = 0.1, {
      
      # Llamamos a la función enviándole el objeto de progreso
      res <- get_rmcab_summary(update=setProgress) 
      
      # Guardamos el resultado final
      resumen_data(res)
    })
  })
  
  # 3. Recuadro con el valor del contaminante (Reactivo al botón)
  output$ica_box_ui <- renderUI({
    res <- req(resumen_data()) # Solo aparece cuando le das al botón
    
    div(style= paste0("background-color: ", res$color, "; padding: 15px 35px; border-radius: 12px; text-align: center; border: 1px solid #FDD835;"),
        h1(res$val, style="font-size: 3.5rem; font-weight:800; margin:0;"), # Corregida coma por punto y coma en style
        span("µg/m³ (Promedio)", style = "font-weight: 600; font-size: 1.1rem;")
    )
  })
  
  # 4. Texto del contaminante dominante
  output$contaminante_ui <- renderUI({
    res <- req(resumen_data())
    
    div(class="text-center",
        p("Contaminante Dominante", style = "color: #666; margin-bottom:0; font-size:1.1rem;"),
        h2(res$pol, style = "font-weight:800; font-size: 3rem; color:#333")
    )
  })
  
  # 5. Actualizar estaciones activas
  output$estaciones_count <- renderText({
    res <- resumen_data() 
    if(is.null(res)) return("0 / 19")
    paste0(res$active, " / 19")
  })

  
  #----LOGICA PAGINA: Variacion Temporal----

datos_time_historicos <- reactiveVal(NULL)
esta_cargando_time <- reactiveVal(FALSE)

#Variables IA
v_res_tv_objeto <- reactiveVal(NULL) #Guarda el objeto de openar
texto_analisis_ia <- reactiveVal("") #Guarda la respuesta
esta_analizando_ia <- reactiveVal(FALSE) #Estado de carga de la ia


#Control Dinamico Boton
output$control_time_ui <- renderUI({
  if(esta_cargando_time()){
    div(
      style= "padding:10px; background: #E8F5E9; border-radius: 8px; border: 1px solid #C8E6C9;",
      p("Descargando datos de la RMCAB...", style="font-weight:bold; color: #2e7d32; margin_bottom: 5px"),
      textOutput("mensaje_carga_time")
    )
  }else{
    actionButton("generar_time", "Generar Gráfica",
    icon=icon("chart-line"),
    class="btn-primary",style="width: 100%;font-weight:700;")
  }
})
#Logica descarga al presionar boton
observeEvent(input$generar_time,{
  req(input$dates, input$station)
  
  texto_analisis_ia("")
  v_res_tv_objeto(NULL)
  esta_cargando_time(TRUE)
  
  #Limpiar analisis previo al generar nueva grafica
  texto_analisis_ia("")
  
  withProgress(message = "Conectando con servidor RMCAB...", value=0,{
    #Ejecutamos descarga
    resultado <- try({
      get_data_clean(
        aqs=input$station,
        start_date = format(input$dates[1],"%d-%m-%Y"),
        end_date = format(input$dates[2], "%d-%m-%Y")
      )
    },silent = TRUE)
    
    #Detectar error
    if(inherits(resultado, "try-error") || is.null(resultado) || nrow(resultado)==0){
      message("Error o datos vacíos en:", input$station)
      
      # Notificación visual para el usuario 
      showNotification(
        "La estación seleccionada no reporta datos en este periodo. Por favor, intenta con otra estación o rango de fechas.",
        type = "warning",
        duration = 10
      )
      datos_time_historicos(NULL) 
    }else{
      datos_time_historicos(resultado)
    }
  })
  esta_cargando_time(FALSE)
})
#Renderizar la grafica
output$time_variation_plot<-renderPlot({
  input$generar_time
  
  df<-datos_time_historicos()
  if(is.null(df)){
    return(NULL)
  }
  
  p_sel <- (input$pollutant)
  s_sel <- (input$station)
  
  shiny::validate(
    shiny::need(!is.null(df), "Por favor, selecciona una estación y haz clic en 'Generar Gráfica'"),
    shiny::need(is.data.frame(df), "Hubo un problema técnico al procesar los datos"),
    shiny::need(nrow(df)>0,"La RMCAB no devolvió datos para esta estación en estas fechas."),
    shiny::need(input$pollutant %in% names (df), paste("La estacion", s_sel, "no mide", p_sel))
  )
  #Intentat graficas
  tryCatch({
    res<-plot_time_variation(data = df,pollutant = p_sel)
    v_res_tv_objeto(res)
    return(res)
  }, error= function(e){
    v_res_tv_objeto(NULL)
    validate("Error de graficación: No hay suficientes datos válidos para este contaminante")
  })
  
})

observeEvent(input$btn_analizar_tv, {
  req(v_res_tv_objeto()) 
  texto_analisis_ia(NULL)
  
  # Aislamos para evitar reactividad no deseada
  p_ia <- isolate(input$pollutant)
  s_ia <- isolate(input$station)
  
  texto_analisis_ia("Estableciendo conexión segura con Google...")
  
  # Preparar datos
  res_obj <- v_res_tv_objeto()
  datos_df <- as.data.frame(res_obj$data$day.hour[, c("hour", "Mean")])
  datos_json <- jsonlite::toJSON(datos_df)
  
  tryCatch({
    api_key <- Sys.getenv("GEMINI_API_KEY")
    
    # URL MODIFICADA (Usando gemini-pro que es la ruta más compatible)
    url_ia <- "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    # Construcción manual del cuerpo para asegurar compatibilidad total
    cuerpo <- list(
      contents = list(
        list(parts = list(list(text = paste(
          "Analiza como experto en aire de Bogotá el contaminante", p_ia, 
          "en la estación", s_ia, "con estos datos:", datos_json
        ))))
      )
    )
    
    # Petición usando el método de tubería (pipeline) de httr2
    resp <- httr2::request(url_ia) %>%
      httr2::req_url_query(key = api_key) %>%
      httr2::req_body_json(cuerpo) %>%
      httr2::req_method("POST") %>%
      httr2::req_perform()
    
    # Procesar respuesta
    resultado <- httr2::resp_body_json(resp)
    
    # Extraer texto (con validación de existencia)
    if (!is.null(resultado$candidates)) {
      texto_final <- resultado$candidates[[1]]$content$parts[[1]]$text
      texto_analisis_ia(texto_final)
    } else {
      texto_analisis_ia("El servidor respondió pero no generó texto. Intenta de nuevo.")
    }
    
  }, error = function(e) {
    # Si sigue saliendo 404, el mensaje nos dirá exactamente qué URL falló
    texto_analisis_ia(paste("Error en la ruta del modelo:", e$message))
    message("Error 404 detectado. URL intentada: ", url_ia)
  })
})

output$analisis_ia_out<- renderUI({
  if(texto_analisis_ia()==""){
    p("Haz clic en 'Analizar Gráfica' para generar una interpretacion automática.",
      style = "color: #888; font-style:italic; padding:10px")
  }else{
    div(
      class="analisis-container",
      style="background-color:#f8f9fa; border-left:4px solid #0d6efd; padding:15px; border-radius:px",
      markdown(texto_analisis_ia())
    )
  }
})




#----LOGICA PAGINA: Rosa de Contaminantes----

datos_rose <- reactiveVal(NULL)
esta_cargando_rose <- reactiveVal(FALSE)

#Variables IA
v_res_rp_objeto <- reactiveVal(NULL) #Guarda el objeto de openar
texto_analisis_ia_rp <- reactiveVal("") #Guarda la respuesta
esta_analizando_ia_rp <- reactiveVal(FALSE) #Estado de carga de la ia


#Control Dinamico Boton
output$control_rose_ui <- renderUI({
  if(esta_cargando_rose()){
    div(
      style= "padding:10px; background: #E8F5E9; border-radius: 8px; border: 1px solid #C8E6C9;",
      p("Descargando datos de la RMCAB...", style="font-weight:bold; color: #2e7d32; margin_bottom: 5px"),
      textOutput("mensaje_carga_rose")
    )
  }else{
    actionButton("generar_rose", "Generar Rosa de Contaminantes",
                 icon=icon("wind"),
                 style = "background-color: #0277BD; color: white; border: none; width: 100%; font-weight:700; padding: 10px; border-radius: 5px;")
  }
})
#Logica descarga al presionar boton
observeEvent(input$generar_rose,{
  req(input$dates_rose, input$station_rose)
  
  datos_rose(NULL)
  texto_analisis_ia_rp("")
  v_res_rp_objeto(NULL)
  esta_cargando_rose(TRUE)
  
  
  withProgress(message = "Obteniendo datos meteorologicos...", value=0.5,{
    output$mensaje_carga_rose <- renderText({ 
      paste("Descargando:", input$station_rose) 
    })
    #Ejecutamos descarga
    df <- try({
      get_data_clean(
        aqs=input$station_rose,
        start_date = format(input$dates_rose[1],"%d-%m-%Y"),
        end_date = format(input$dates_rose[2], "%d-%m-%Y")
      )
    },silent = TRUE)
    
    #Detectar error
    if(inherits(df, "try-error") || is.null(df) || (is.data.frame(df) && nrow(df)==0)){
      showNotification(
        paste("La estación seleccionada no reporta datos en este periodo. Por favor, intenta con otra estación o rango de fechas."),
        type = "warning",
        duration = 10
      )
      datos_rose(NULL)
    }else{
      datos_rose(df)
    }
  })
  esta_cargando_rose(FALSE)
})
#Renderizar la grafica
output$plot_rose<-renderPlot({
  input$generar_rose
  
  df<-datos_rose()
  if(is.null(df)){
    return(NULL)
  }
  
  p_sel<- (input$pollutant_rose)
  s_sel <- (input$station_rose)
  
  shiny::validate(
    shiny::need(is.data.frame(df), "Datos no válidos."),
    shiny::need(nrow(df) > 0, "La RMCAB no devolvió datos."),
    
    # Verifica que el contaminante tenga datos numéricos reales
    shiny::need(p_sel %in% names(df) && sum(!is.na(df[[p_sel]])) > 0, 
                paste("La estación", s_sel, "registra el sensor de", toupper(p_sel), 
                      "pero todos los valores en este rango de fechas son nulos (NAs).")),
    
    # Verifica que el viento tenga datos reales
    shiny::need(sum(!is.na(df$ws)) > 0 && sum(!is.na(df$wd)) > 0,
                "Existen columnas de viento pero no hay valores numéricos válidos (NAs).")
  )
  #Intentat graficas
  tryCatch({
    df_clean <- df[!is.na(df$ws) & !is.na(df$wd) & !is.na(df[[p_sel]]), ]
    res<-plot_pollution_rose(data = df,pollutant = p_sel)
    v_res_rp_objeto(res)
    return(res)
  }, error= function(e){
    v_res_rp_objeto(NULL)
    validate("Error de graficación: No hay suficientes datos válidos para este contaminante")
  })
  
})

observeEvent(input$btn_analizar_rp, {
  req(v_res_rp_objeto())
  texto_analisis_ia_rp(NULL)
  
  p_ia <- isolate(input$pollutant_rose)
  s_ia <- isolate(input$station_rose)
  
  texto_analisis_ia_rp("Estableciendo conexión segura con Google...")
  
  # --- PREPARAR DATOS REALES DE LA ROSA ---
  res_obj <- v_res_rp_objeto()
  datos_df <- as.data.frame(res_obj$data)
  
  # Columnas de intervalos de concentración (los bins de color de la rosa)
  cols_intervalos <- grep("^Interval", names(datos_df), value = TRUE)
  
  # Construir tabla resumen: dirección + frecuencia acumulada por bin
  resumen <- datos_df[, c("wd", cols_intervalos), drop = FALSE]
  resumen$direccion_grados <- resumen$wd
  resumen$frecuencia_total_pct <- rowSums(resumen[, cols_intervalos], na.rm = TRUE)
  resumen$wd <- NULL
  
  # Renombrar intervalos con contexto
  n_bins <- length(cols_intervalos)
  for (i in seq_along(cols_intervalos)) {
    names(resumen)[names(resumen) == cols_intervalos[i]] <- paste0("bin_", i, "_de_", n_bins, "_pct")
  }
  
  # Extraer los límites de los bins desde el objeto (si están disponibles en call)
  breaks_info <- tryCatch({
    as.character(res_obj$call)
  }, error = function(e) "no disponible")
  
  datos_json <- jsonlite::toJSON(
    list(
      descripcion = paste(
        "Rosa de contaminantes para", p_ia, "en estacion", s_ia,
        "- Cada fila es un sector de direccion del viento.",
        "Los bins (bin_1 al bin_N) representan categorias de concentracion de menor a mayor.",
        "El valor es el porcentaje de observaciones en esa categoria para esa direccion.",
        "frecuencia_total_pct es el porcentaje total de vientos desde esa direccion."
      ),
      datos_por_sector = resumen
    ),
    auto_unbox = TRUE,
    pretty = FALSE,
    na = "null"
  )
  
  tryCatch({
    api_key <- Sys.getenv("GEMINI_API_KEY")
    url_ia <- "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    prompt_texto <- paste0(
      "Eres un experto en calidad del aire de Bogotá. ",
      "Analiza los datos de una Rosa de Contaminantes para '", p_ia, 
      "' en la estación '", s_ia, "'. ",
      "Cada fila representa un sector de dirección del viento. ",
      "Los bins van de concentración baja (bin_1) a alta (bin_N) y el valor es el porcentaje de observaciones. ",
      "frecuencia_total_pct indica qué tan frecuente es el viento desde esa dirección. ",
      "Por favor: ",
      "1) Identifica las direcciones con mayor concentración del contaminante. ",
      "2) Señala si hay una fuente probable según esas direcciones en el contexto urbano de Bogotá. ",
      "3) Comenta si el viento dominante coincide o no con las mayores concentraciones. ",
      "4) Da una conclusión breve sobre el riesgo para la zona. ",
      "No uses en la descripcion los terminos bin_1 o bin_N o frecuencia_total_pct. Pues el usuario no va a saber que eso, reemplazo el nombre ent erminos que
      entienda la poblacion en general. Debe ser un analisis que cualquier persona pueda entender pero mantiendo en cierto grado lo tecnico",
      "Datos JSON: ", datos_json
    )
    
    cuerpo <- list(
      contents = list(
        list(parts = list(list(text = prompt_texto)))
      )
    )
    
    resp <- httr2::request(url_ia) %>%
      httr2::req_url_query(key = api_key) %>%
      httr2::req_body_json(cuerpo) %>%
      httr2::req_method("POST") %>%
      httr2::req_perform()
    
    resultado <- httr2::resp_body_json(resp)
    
    if (!is.null(resultado$candidates)) {
      texto_final <- resultado$candidates[[1]]$content$parts[[1]]$text
      texto_analisis_ia_rp(texto_final)
    } else {
      texto_analisis_ia_rp("El servidor respondió pero no generó texto. Intenta de nuevo.")
    }
    
  }, error = function(e) {
    texto_analisis_ia_rp(paste("Error al conectar con Gemini:", e$message))
  })
})

output$analisis_ia_out_rp <- renderUI({
  texto <- texto_analisis_ia_rp()
  if (is.null(texto) || texto == "") {
    p("Haz clic en 'Analizar Rosa' para generar una interpretación automática.",
      style = "color: #888; font-style:italic; padding:10px")
  } else {
    div(
      class = "analisis-container",
      style = "background-color:#f8f9fa; border-left:4px solid #0277BD; padding:15px; border-radius:4px",
      markdown(texto)
    )
  }
})







#----LOGICA PAGINA: Correlacion de Contaminantes----

datos_corplot <- reactiveVal(NULL)
esta_cargando_corplot <- reactiveVal(FALSE)

#Variables IA
#Variables IA
v_res_cor_objeto <- reactiveVal(NULL) #Guarda el objeto de openar
texto_analisis_ia_cor <- reactiveVal("") #Guarda la respuesta
esta_analizando_ia <- reactiveVal(FALSE) #Estado de carga de la ia

# Control Dinámico Botón
output$control_corplot_ui <- renderUI({
  if(esta_cargando_corplot()){
    div(
      style= "padding:10px; background: #E8F5E9; border-radius: 8px; border: 1px solid #C8E6C9;",
      p("Descargando datos de la RMCAB...", style="font-weight:bold; color: #2e7d32; margin_bottom: 5px"),
      textOutput("mensaje_carga_corplot")
    )
  } else {
    actionButton("generar_corplot", "Generar Correlación de Contaminantes",
                 icon=icon("table"), 
                 style = "background-color: #455A64; color: white; border: none; width: 100%; font-weight:700; padding: 10px;")
  }
})

# Lógica descarga al presionar botón
observeEvent(input$generar_corplot, {
  req(input$dates_corplot, input$station_corplot)

  datos_corplot(NULL)
  texto_analisis_ia_cor("")
  v_res_cor_objeto(NULL)
  esta_cargando_corplot(TRUE)
  
  withProgress(message = "Obteniendo datos para matriz...", value=0.2, {
    output$mensaje_carga_corplot <- renderText({ 
      paste("Analizando estación:", input$station_corplot) 
    })
    
    # Ejecutamos descarga
    df <- try({
      get_data_clean(
        aqs = input$station_corplot,
        start_date = format(input$dates_corplot[1], "%d-%m-%Y"),
        end_date = format(input$dates_corplot[2], "%d-%m-%Y")
      )
    }, silent = TRUE)
    
    # Detectar error técnico (Bosa/Usme/API)
    if(inherits(df, "try-error") || is.null(df) || (is.data.frame(df) && nrow(df)==0)){
      showNotification(
        paste("La estación no reporta datos suficientes para la matriz de correlación en estas fechas."),
        type = "warning",
        duration = 10
      )
      datos_corplot(NULL)
    } else {
      datos_corplot(df)
    }
  })
  esta_cargando_corplot(FALSE)
})

# Renderizar la gráfica
output$plot_corplot <- renderPlot({
  input$generar_corplot
  
  df <- datos_corplot()
  
  if(is.null(df)) return(NULL)
  
  s_sel <- isolate(input$station_corplot)
  
  # 1. Validaciones de integridad
  shiny::validate(
    shiny::need(is.data.frame(df), "Los datos descargados no son válidos."),
    shiny::need(nrow(df) > 0, "No hay registros para las fechas seleccionadas.")
  )
  
  # 2. FILTRO DE CONTAMINANTES: Aquí quitamos ws, wd, etc.
  lista_blanca <- c("pm10", "pm25", "co", "no", "no2", "nox", "so2", "ozono")
  df_contaminantes <- df[, names(df) %in% lista_blanca, drop = FALSE]
  
  # 3. Validación de columnas suficientes para correlación
  shiny::validate(
    shiny::need(ncol(df_contaminantes) >= 2, 
         "Esta estación no tiene suficientes contaminantes diferentes para establecer una correlación.")
  )
  
  # Intentar graficar
  tryCatch({
    # Usamos el dataframe filtrado
    resultado<- plot_correlation(data = df_contaminantes)
    v_res_cor_objeto(resultado)
    resultado
  }, error = function(e){
    validate("Error de graficación: Los datos actuales no permiten generar la matriz (posibles NAs masivos).")
  })
})

#Analisis IA
observeEvent(input$btn_analizar_cor, {
  req(v_res_cor_objeto()) 
  texto_analisis_ia_cor(NULL)
  
  if(is.null(v_res_cor_objeto()$data)) {
    showNotification("Error: No hay datos en la matriz para analizar.", type = "error")
    return()
  }
  
  res_obj <- v_res_cor_objeto()
  datos_df <- as.data.frame(res_obj$data)
  
  # Aislamos para evitar reactividad no deseada

  s_ia_cor <- isolate(input$station_corplot)
  
  names(datos_df)[1]<- "var1"
  names(datos_df)[2]<- "var2"
  
  if("cor" %in% names(datos_df)){
    names(datos_df)[names(datos_df) == "cor"] <- "valor"
  } else {
    names(datos_df)[3]<-"valor"
  }
  
  
  texto_analisis_ia_cor("Analizando matriz de correalciones")
  
  # Preparar datos
 datos_df <- datos_df[as.character(datos_df$var1) != as.character(datos_df$var2), ]
 datos_df$valor <- round(as.numeric(datos_df$valor), 1)
 datos_df<- datos_df[as.numeric(factor(datos_df$var1))>as.numeric(factor(datos_df$var2)), ]
 datos_json <- jsonlite::toJSON(datos_df)
  
  tryCatch({
    api_key <- Sys.getenv("GEMINI_API_KEY")
    
    # URL MODIFICADA (Usando gemini-pro que es la ruta más compatible)
    url_ia <- "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    # Construcción manual del cuerpo para asegurar compatibilidad total
    cuerpo <- list(
      contents = list(
        list(parts = list(list(text = paste(
          "Actúa como un experto en calidad del aire de la red RMCAB de Bogotá.",
          "Analiza la siguiente matriz de correlación de contaminantes:", datos_json,"para la estacion", s_ia_cor,
          "Explica qué significan las correlaciones más fuertes (cercanas a 1 o -1)",
          "y menciona posibles fuentes comunes o reacciones químicas (como el ciclo fotoquímico NO2-O3) en el contexto de Bogotá."
        ))))
      )
    )
    
    # Petición usando el método de tubería (pipeline) de httr2
    resp <- httr2::request(url_ia) %>%
      httr2::req_url_query(key = api_key) %>%
      httr2::req_body_json(cuerpo) %>%
      httr2::req_method("POST") %>%
      httr2::req_perform()
    
    # Procesar respuesta
    resultado <- httr2::resp_body_json(resp)
    
    # Extraer texto (con validación de existencia)
    if (!is.null(resultado$candidates)) {
      texto_final <- resultado$candidates[[1]]$content$parts[[1]]$text
      texto_analisis_ia_cor(texto_final)
    } else {
      texto_analisis_ia_cor("El servidor respondió pero no generó texto. Intenta de nuevo.")
    }
    
  }, error = function(e) {
    # Si sigue saliendo 404, el mensaje nos dirá exactamente qué URL falló
    texto_analisis_ia_cor(paste("Error en la ruta del modelo:", e$message))
    message("Error 404 detectado. URL intentada: ", url_ia)
  })
})

output$analisis_ia_out_cor<- renderUI({
  if(texto_analisis_ia_cor()==""){
    p("Haz clic en 'Analizar Gráfica' para generar una interpretacion automática.",
      style = "color: #888; font-style:italic; padding:10px")
  }else{
    div(
      class="analisis-container",
      style="background-color:#f8f9fa; border-left:4px solid #0d6efd; padding:15px; border-radius:px",
      markdown(texto_analisis_ia_cor())
    )
  }
})




# PAGINA 4 - GIFT
# datos_gif_path<- reactiveVal(NULL)
# esta_cargando_gif <- reactiveVal(FALSE)
# 
# output$control_gif_ui <-renderUI({
#   if(esta_cargando_gif()){
#     div(style="padding:10px; background: #FFF9C4; border-radius:8px;",
#     p("Renderizando frames...", style="font-weight:bold; color: #F57F17;"),
#     textOutput("mensaje_carga_gif"))
#   }else{
#     actionButton("generar_gif", "Generar Gif Animado", icon = icon("film"),
#     style="background-color:#FBC02D; color:black; font-weight:700; width:100%")
#   }
# })
# 
# observeEvent(input$generar_gif, {
#   req(input$fecha_gif, input$pollutant_gif)
#   esta_cargando_gif(TRUE)
#   
#   withProgress(message = "Preparando mapa animado...", value = 0, {
#     
#     # 1. Descargamos los datos usando tu lógica de resumen adaptada
#     df_gif <- get_data_for_gif(
#       fecha = input$fecha_gif, 
#       contaminante_sel = input$pollutant_gif,
#       update = setProgress # Esto vincula la barra de progreso de Shiny
#     )
#     
#     if(is.null(df_gif) || nrow(df_gif) == 0) {
#       showNotification("No hay datos suficientes para generar el GIF.", type = "warning")
#       esta_cargando_gif(FALSE)
#       return()
#     }
#     
#     # 2. Generamos el GIF (usando la función make_pollution_gif que ya ajustamos)
#     setProgress(value = 0.9, detail = "Renderizando cuadros finales...")
#     path <- make_pollution_gif(df_gif, input$pollutant_gif)
#     
#     datos_gif_path(path)
#   })
#   esta_cargando_gif(FALSE)
# })
# 
# output$gif_plot_output <- renderImage({
#   path <- req(datos_gif_path())
#   list(src = path, contentType = "image/gif", width = "100%", height = "auto")
# }, deleteFile = FALSE)

## ------------------- LOGICA PAGINA: SCATTER -------------------
datos_scatter <- reactiveVal(NULL)
esta_cargando_scatter <- reactiveVal(FALSE)

# ---- Botón dinámico ----
output$control_scatter_ui <- renderUI({
  if (esta_cargando_scatter()) {
    div(
      style = "padding:10px; background: #E8F5E9; border-radius: 8px; border: 1px solid #C8E6C9;",
      p("Descargando datos de la RMCAB...",
        style = "font-weight:bold; color: #2e7d32; margin-bottom: 5px"),
      textOutput("mensaje_carga_scatter")
    )
  } else {
    actionButton(
      "generar_scatter",
      "Generar Diagrama",
      icon = icon("chart-line"),
      style = "background-color: #2E8B57; color: white; border: none; width: 100%; font-weight:700; padding: 10px;"
    )
  }
})
# ---- Descarga al presionar botón ----
observeEvent(input$generar_scatter, {
  req(input$dates_scatter, input$station_scatter)
  esta_cargando_scatter(TRUE)
  withProgress(message = "Descargando datos de la RMCAB...", value = 0.3, {
    output$mensaje_carga_scatter <- renderText({
      paste("Procesando estación:", input$station_scatter)
    })
    df <- try({
      get_data_clean(
        aqs = input$station_scatter,
        start_date = format(input$dates_scatter[1], "%d-%m-%Y"),
        end_date   = format(input$dates_scatter[2], "%d-%m-%Y")
      )
    }, silent = TRUE)
    if (inherits(df, "try-error")) {
      datos_scatter("error_api")
    } else {
      datos_scatter(df)
    }
  })
  esta_cargando_scatter(FALSE)
})
# ---- Renderizado del diagrama ----
output$plot_scatter <- renderPlot({
  df <- datos_scatter()
  if (is.null(df)) return(NULL)
  shiny::validate(
    shiny::need(!inherits(df, "character"),
                paste("La estación", input$station_scatter,
                      "no reporta sensores activos en la RMCAB.")),
    shiny::need(is.data.frame(df) && nrow(df) > 0,
                "La RMCAB no devolvió datos para esta estación en estas fechas."),
    shiny::need(input$Pollutant_x %in% names(df),
                paste("La estación no mide", toupper(input$Pollutant_x))),
    shiny::need(input$Pollutant_y %in% names(df),
                paste("La estación no mide", toupper(input$Pollutant_y)))
  )
  tryCatch({
    ggplot(
      df,
      aes_string(
        x = input$Pollutant_x,
        y = input$Pollutant_y
      )
    ) +
      geom_point(alpha = 0.4, color = "#3B0084") +
      #geom_smooth(method = "lm", se = FALSE, color = "black") + #Lianea de tendencia lineal
      theme_minimal(base_size = 14) +
      labs(
        x = toupper(input$Pollutant_x),
        y = toupper(input$Pollutant_y),
        title = paste("Diagrama de Dispersión - Estación", input$station_scatter),
        subtitle = "Relación estadística entre contaminantes seleccionados"
      )
  }, error = function(e){
    shiny::validate(
      "Error de graficación: Datos insuficientes o con demasiados valores NA."
    )
    
  })
  
})
}

shinyApp(ui, server)

