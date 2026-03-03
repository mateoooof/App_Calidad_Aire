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



source("Scripts/data_download_processing.R")
source("Scripts/plots.R")
source("Scripts/analisis_ia.R")
source("Paginas/time_variation.R")
source("Paginas/rose_pollution.R")
source("Paginas/cor_plot.R")
source("Paginas/gif_maker.R")


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
                           )
                           
                         )
                     )
    ),
    
    # 1. REFERENCIA A TUS UI EXTERNAS
    # Estos IDs deben coincidir con los que usas en nav_select en el server
    nav_panel_hidden("pagina_analisis", ui_time_variation),
    nav_panel_hidden("pagina_rosa", ui_rose_pollution),
    nav_panel_hidden("pagina_cor", ui_corplot),
    nav_panel_hidden("pagina_gif", ui_gif_maker)
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
  
  # Lógica para botones de "Volver" 
  observeEvent(input$volver_inicio, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio2, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio3, { nav_select("paginas_app", "inicio") })
  observeEvent(input$volver_inicio4, { nav_select("paginas_app", "inicio") })
  
  #INICIADORES
  observe({
    req(rmcab_aqs)
    #ESTACIONES
    updateSelectInput(session, "station", choices = rmcab_aqs$aqs)
    updateSelectInput(session, "station_rose", choices = rmcab_aqs$aqs)
    updateSelectInput(session, "station_corplot", choices = rmcab_aqs$aqs)
    #CONTAMINANTES
    lista_contaminantes <- c("pm10", "pm2.5", "co", "no", "no2", "nox", "so2", "ozono")
    updateSelectInput(session, "pollutant", choices = lista_contaminantes)
    updateSelectInput(session, "pollutant_rose", choices = lista_contaminantes)
    updateSelectInput(session, "pollutant_gif", choices = lista_contaminantes)
    
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
  
  texto_analisis_ia_rp("")
  v_res_rp_objeto(NULL)
  esta_cargando_rose(TRUE)
  
  #Limpiar analisis previo al generar nueva grafica
  texto_analisis_ia_rp("")
  
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



#----LOGICA PAGINA: Correlacion de Contaminantes----

datos_corplot <- reactiveVal(NULL)
esta_cargando_corplot <- reactiveVal(FALSE)

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
  esta_cargando_corplot(TRUE)
  datos_corplot(NULL)
  
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
    plot_correlation(data = df_contaminantes)
  }, error = function(e){
    validate("Error de graficación: Los datos actuales no permiten generar la matriz (posibles NAs masivos).")
  })
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

  
}
shinyApp(ui, server)
