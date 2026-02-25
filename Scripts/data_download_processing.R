library(bogotAIR)
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
  data <- data[complete.cases(data[, c("date", "ws", "wd")]), ]
  
  if (nrow(data) == 0) return(NULL)
  return(as.data.frame(data))
  
}