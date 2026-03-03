library(httr2)
library(jsonlite)

#SOLICITUD GENERAL
solicitar_analisis_ia <- function(prompt_texto) {
  # API Key
  api_key <- "AIzaSyD97SL29N_7q3krJOngTAXg8xqzi_N9Ef8" 
  
  #  URL con la llave integrada 
  url <- paste0("")
  
  # Estructura del cuerpo (JSON)
  cuerpo <- list(
    contents = list(
      list(parts = list(list(text = prompt_texto)))
    )
  )
  # 4. Petición usando httr2
  resp <- request(url) %>%
    req_body_json(cuerpo) %>%
    req_method("POST")%>%
    req_error(is_error = function(resp) FALSE) %>%
    req_perform()
  
  codigo_estado <- resp_status(resp)
  
  if(codigo_estado !=200){
    error_detalle <- resp_body_json(resp)
    stop(paste("Error de Google(",codigo_estado, "): ", error_detalle$error$message))
  }
  
  # 5. Obtener respuesta
  resultado <- resp_body_json(resp)
  
  return(resultado$candidates[[1]]$content$parts[[1]]$text)
}
