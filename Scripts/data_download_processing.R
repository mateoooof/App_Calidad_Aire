library(bogotAIR)
library(tidyr)
library(dplyr)




#Descargar datos de RMCAB

get_data_clean <- function(aqs, start_date, end_date){
  row <- which(rmcab_aqs$aqs == aqs)
  if (length(row) == 0)return(NULL)
  aqs_code <- rmcab_aqs$code[row[1]]
  # Descarga
  data <- download_rmcab_data(
    aqs_code = aqs_code,
    start_date = start_date,
    end_date = end_date
  )
  # --- VALIDACIÓN CRÍTICA ---
  if (is.null(data) || nrow(data) == 0){ 
    return(NULL)
    }
  
  data$site <- aqs
  data$lat<- rmcab_aqs$lat[row[1]]
  data$lon <- rmcab_aqs$lon[row[1]]
  
  # LIMPIEZA DE NOMBRES Y FORMATOS
  names(data) <- tolower(names(data))
  names(data)[names(data) == "vel_viento"] <- "ws"
  names(data)[names(data) == "dir_viento"] <- "wd"
  # Conversion Numerica
  data$ws <- as.numeric(data$ws)
  data$wd <- as.numeric(data$wd)
  data$date <- as.POSIXct(data$date, tz="UTC")
  # ESCUDO PARA "TRUE/FALSE needed" (Limpiar NAs críticos)
  # Solo dejamos filas que tengan Fecha, Viento y Dirección
  data <- data[!is.na(data$date),]
  
  if (is.null(data) || nrow(data) == 0 ) return(NULL)
  return(as.data.frame(data))
}

#Obtener el contaminante dominante y su concentracion
get_rmcab_summary <- function(update = NULL) {
  # Lista de contaminantes que definiste
  contaminantes_validos <- c("pm10", "pm25", "co", "no", "no2", "nox", "so2", "ozono")
  fecha_ayer <- format(Sys.Date()-1, "%d-%m-%Y")
  
  # Estaciones para el resumen
  estaciones_lista <- rmcab_aqs$aqs
  all_data <- list()
  
  n <- length(estaciones_lista)
  
  for(i in 1:n) {
    est <- estaciones_lista[i]
    
    # --- MENSAJE PARA LA BARRA DE PROGRESO ---
    if (is.function(update)) {
      update(value = i/n, detail = paste("Descargando estación:", est))
    }
    
    # Escudo de error individual por estación
    resultado_estacion <- try({
      get_data_clean(aqs = est, start_date = fecha_ayer, end_date = fecha_ayer)
    }, silent = TRUE)
    
    if(!inherits(resultado_estacion, "try-error") && !is.null(resultado_estacion)) {
      temp <- resultado_estacion
      names(temp) <- tolower(names(temp))
      
      # Filtrado estricto de contaminantes
      columnas_presentes <- intersect(names(temp), contaminantes_validos)
      
      if(length(columnas_presentes) > 0) {
        all_data[[est]] <- temp %>% 
          select(all_of(columnas_presentes)) %>%
          mutate(across(everything(), ~as.numeric(as.character(.x))))
      }
    }
    Sys.sleep(0.4) # Pausa para que el mensaje sea legible
  }
  
  if (length(all_data) == 0) return(NULL)
  
  # Consolidación y promedios
  df_total <- bind_rows(all_data)
  df_total[is.na(df_total)] <- 0
  
  promedios <- df_total %>%
    summarise(across(everything(), ~mean(.x, na.rm = TRUE))) %>%
    pivot_longer(everything(), names_to = "contaminante", values_to = "valor") %>%
    filter(valor > 0) %>% 
    arrange(desc(valor))
  
  if (nrow(promedios) == 0) return(NULL)
  
  dominante <- promedios[1, ]
  
  return(list(
    val = round(dominante$valor, 1), 
    pol = toupper(dominante$contaminante), 
    color = ifelse(dominante$valor > 37, "#FF9800", "#FFEB3B"),
    active = length(all_data)
  ))
}

get_data_for_gif <- function(fecha, contaminante_sel, update = NULL) {
  # Usamos la lista de estaciones de la librería oficial
  estaciones_sin_datos <- c('Bosa', 'Usme')
  estaciones_lista <- bogotAIR::rmcab_aqs$aqs[!bogotAIR::rmcab_aqs$aqs %in% estaciones_sin_datos]
  all_data <- list()
  
  n <- length(estaciones_lista)
  fecha_str <- format(fecha, "%d-%m-%Y")
  
  for(i in 1:n) {
    est <- estaciones_lista[i]
    
    # --- PROGRESO PARA LA UI ---
    if (is.function(update)) {
      update(value = i/n, detail = paste("Descargando estación:", est))
    }
    
    resultado_estacion <- try({
      get_data_clean(aqs = est, start_date = fecha_str, end_date = fecha_str)
    }, silent = TRUE)
    
    if(!inherits(resultado_estacion, "try-error") && !is.null(resultado_estacion)) {
      temp <- resultado_estacion
      names(temp) <- tolower(names(temp))
      
      # Verificamos si la estación mide el contaminante seleccionado
      if(contaminante_sel %in% names(temp)) {
        # Guardamos: Estación, Fecha/Hora y el Valor del contaminante
        all_data[[est]] <- temp %>% 
          select(site, date, all_of(contaminante_sel)) %>%
          mutate(across(all_of(contaminante_sel), ~as.numeric(as.character(.x))))
      }
    }
    Sys.sleep(0.1) # Pausa más corta para que el GIF no tarde tanto en procesar
  }
  
  if (length(all_data) == 0) return(NULL)
  
  # Unimos todo en un solo dataframe
  return(bind_rows(all_data))}
