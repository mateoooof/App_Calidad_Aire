library(bogotAIR)
get_data_clean <- function(aqs, start_date, end_date){
  row <- which(rmcab_aqs$aqs == aqs)
  aqs_code <- rmcab_aqs$code[row]
  
  data <- download_rmcab_data(
    aqs_code = aqs_code,
    start_date = start_date,
    end_date = end_date
  )
  
  data$site <- aqs
  data$lat<- rmcab_aqs$lat[row]
  data$lon <- rmcab_aqs$lon[row]
  
  names(data)[names(data) == "vel_viento"] <- "ws"
  names(data)[names(data) == "dir_viento"] <- "wd"
  
  data$date <- as.POSIXct(data$date, tz="UTC")
  
  return(as.data.frame(data))
  
}