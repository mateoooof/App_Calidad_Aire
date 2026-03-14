# Paginas/teoria.R

ui_teoria <- div(
  class = "container-fluid", # Ocupa todo el ancho
  style = "padding: 40px; font-family: 'Manrope', sans-serif;",
  
  # --- SECCIÓN 1: BIENVENIDA Y CONTEXTO ---
  div(class = "row mb-5 text-center",
      div(class = "col-12",
          h1("Fundamentos y Monitoreo del Aire en Bogotá", 
             style = "font-weight: 800; color: #2E8B57; font-size: 3rem;"),
          p("Entendiendo la Red de Monitoreo (RMCAB) y los contaminantes que respiramos.", 
            style = "font-size: 1.3rem; color: #555;")
      )
  ),
  
  # --- SECCIÓN 2: LA RED RMCAB (Ancho Completo) ---
  div(class = "row mb-5 align-items-center",
      div(class = "col-md-6",
          h3(bs_icon("geo-alt-fill", class="text-success"), " La Red de Monitoreo (RMCAB)", 
             style="font-weight:700;"),
          p("La calidad del aire en Bogotá no es una suposición; es un dato científico. La ", 
            strong("Red de Monitoreo de Calidad del Aire de Bogotá (RMCAB)"), 
            " es un sistema de vigilancia operado por la Secretaría de Ambiente."),
          p("Actualmente, la red cuenta con más de ", strong("20 estaciones automáticas"), 
            " distribuidas estratégicamente por toda la ciudad, desde Guaymaral en el norte hasta Usme en el sur."),
          tags$ul(
            tags$li(strong("Localidades clave:"), " Kennedy, Puente Aranda y Carvajal-Sevillana suelen reportar mayores niveles por su actividad industrial y alto tráfico."),
            tags$li(strong("Ubicación:"), " Las estaciones están en barrios como Las Ferias, Fontibón, Suba, San Cristóbal y el Tunal."),
            tags$li(strong("Tecnología:"), " Cada estación tiene sensores de alta precisión que miden contaminantes y variables del clima (viento, lluvia, temperatura).")
          )
      ),
      div(class = "col-md-6 text-center",
          
          div(style="background: #E8F5E9; border-radius: 20px; padding: 40px; border: 2px dashed #2E8B57;",
              bs_icon("broadcast", size = "5rem", class = "text-success mb-3"),
              h5("Dato en Tiempo Real", style="font-weight:700;"),
              p("Esta aplicación se conecta con los datos abiertos de la red para procesar la información minuto a minuto.")
          )
      )
  ),
  
  # --- SECCIÓN 3: CONTAMINANTES
  
  h3("Los 'Villanos' del Aire", class = "mb-4", 
     style = "font-weight: 700; border-left: 5px solid #2E8B57; padding-left: 15px;"),
  
  layout_column_wrap(
    width = 1/3,
    
    # PM 2.5 y PM 10
    card(
      class = "shadow-sm", style = "border-top: 5px solid #d9534f; height:100%; border-radius:15px",
      card_header(
        class = "bg-transparent",
        style="border_bottom:none; padding-top:15px",
        h5(strong("Material Particulado (PM2.5 / PM10)"), style="margin:0,color#333")
        ),
      card_body(
        style="display:flex; flex-direction:column",
        div(style="min-height:100px; margin-bottom:10px",
            p("El",strong("PM2.5"), "es 100 veces más delgado que un cabello humano. Debido a su tamaño, puede evadir las defensas naturales de la nariz y llegar a los alvéolos.",
              style="font-size:0.95rem; color: #555;") 
        ),
        
        div(style= "height:150px;display: flex; align-items:center;justify-content:center; border-radius:8px; overflow:hidden; margin-bottom:15px",
            tags$img(
              src="pm25_pm10.jpg",
              class = "img-fluid", 
              style = "max-height:180px; width:auto%; object-fit:contain;"
              )
            ),
        card_footer(
          style="min-height:40px",
          tags$small("Efectos: Enfermedades cardiovasculares, asma y reducción de la visibilidad (haze).",
                     style="color:#7f8c8d; font-style:italic")
        )
      )
    ),
    
    
    # Ozono O3
    card(
      class = "shadow-sm", style = "border-top: 5px solid #5bc0de; height:100%; border-radius:15px",
      card_header(
        class = "bg-transparent",
        style="border_bottom:none; padding-top:15px",
        h5(strong("Ozono Troposférico (O3)"), style="margin:0,color#333")
      ),
      card_body(
        style="display:flex; flex-direction:column",
        div(style="min-height:100px; margin-bottom:10px",
            p("No se emite por un tubo de escape; se 'cocina' en el aire. Es el resultado de una reacción química entre los rayos del sol y los gases de los autos. En Bogotá, sus niveles suben cuando el cielo está despejado y hace mucho sol.",
              style="font-size:0.95rem; color: #555;") 
        ),
        
        div(
          class="text-center my-3",
          style= "height:150px;display: flex; align-items:center;justify-content:center; border-radius:8px; overflow:hidden; margin-bottom:15px",
            tags$img(
              src="ozono.jpg",
              class = "img-fluid", 
              style = "max-height:100%; width:auto; object-fit:contain;"
            )
        ),
        card_footer(
          style="min-height:40px",
          tags$small("Es un contaminante secundario y un potente irritante pulmonar.",
                     style="color:#7f8c8d; font-style:italic")
        )
      )
    ),

    # CO y CO2
    card(
      class = "shadow-sm", style = "border-top: 5px solid #f0ad4e;",
      card_header(strong("Gases de Carbono (CO / CO2)")),
      card_body(
        style="display:flex; flex-direction:column",
        div(style="min-height:100px; margin-bottom:10px",
            p("El CO es el 'enemigo invisible': incoloro e inodoro, desplaza el oxígeno en la sangre siendo altamente tóxico. Por su parte, el CO2 no es tóxico directamente, pero actúa como una 'cobija térmica' (Efecto Invernadero) que atrapa el calor en la ciudad.",
              style="font-size:0.95rem; color: #555;") 
        ),
        
        div(
          class="text-center my-3",
          style= "height:150px;display: flex; align-items:center;justify-content:center; border-radius:8px; overflow:hidden; margin-bottom:15px",
          tags$img(
            src="co_co2.jpg",
            class = "img-fluid", 
            style = "max-height:100%; width:auto; object-fit:contain;"
          )
        ),
        card_footer(
          style="min-height:40px",
          tags$small("Fuente: Motores de gasolina y procesos industriales.",
                     style="color:#7f8c8d; font-style:italic")
        )
      )
      ),
    
    # NOx
    card(
      class = "shadow-sm", style = "border-top: 5px solid #5cb85c;",
      card_header(strong("Óxidos de Nitrógeno (NOx)")),
      card_body(
        style="display:flex; flex-direction:column",
        div(style="min-height:100px; margin-bottom:10px",
            p("Son los culpables de esa 'nata' o capa marrón que ves sobre el horizonte de Bogotá en las mañanas. Son gases muy reactivos que, al mezclarse con la humedad del aire, pueden formar ácidos que dañan edificios y plantas.",
              style="font-size:0.95rem; color: #555;") 
        ),
        
        div(
          class="text-center my-3",
          style= "height:150px;display: flex; align-items:center;justify-content:center; border-radius:8px; overflow:hidden; margin-bottom:15px",
          tags$img(
            src="nox.jpg",
            class = "img-fluid", 
            style = "max-height:100%; width:auto; object-fit:contain;"
          )
        ),
        card_footer(
          style="min-height:40px",
          tags$small("Precursores de la lluvia ácida y del ozono superficial.",
                     style="color:#7f8c8d; font-style:italic")
        )
      ),
    ),
    
    
    
    # SO2
    card(
      class = "shadow-sm", style = "border-top: 5px solid #9c27b0;",
      card_header(strong("Dióxido de Azufre (SO2)")),
      card_body(
        style="display:flex; flex-direction:column",
        div(style="min-height:100px; margin-bottom:10px",
            p("Tiene un olor penetrante y sofocante, similar al de un fósforo recién encendido. Proviene de combustibles 'sucios' (con mucho azufre) y es tan fuerte que puede corroer metales y piedras con el paso del tiempo.",
              style="font-size:0.95rem; color: #555;") 
        ),
        
        div(
          class="text-center my-3",
          style= "height:150px;display: flex; align-items:center;justify-content:center; border-radius:8px; overflow:hidden; margin-bottom:15px",
          tags$img(
            src="so2.jpg",
            class = "img-fluid", 
            style = "max-height:100%; width:auto; object-fit:contain;"
          )
        ),
        card_footer(
          style="min-height:40px",
          tags$small("Emitido principalmente por la quema de carbón y diésel pesado.",
                     style="color:#7f8c8d; font-style:italic")
        )
      ),
    
    ),
    # Meteorología
    card(
      class = "shadow-sm", style = "border-top: 5px solid #607d8b;",
      card_header(strong("Variables Meteorológicas")),
      card_body(
        style="display:flex; flex-direction:column",
        div(style="min-height:100px; margin-bottom:10px",
            p("Son los directores de orquesta de la contaminación. El viento puede actuar como una escoba que limpia la ciudad, o la lluvia como una ducha que lava las partículas del aire. Sin ellas, los contaminantes no tendrían hacia dónde ir.",
              style="font-size:0.95rem; color: #555;") 
        ),
        
        div(
          class="text-center my-3",
          style= "height:150px;display: flex; align-items:center;justify-content:center; border-radius:8px; overflow:hidden; margin-bottom:15px",
          tags$img(
            src="meterologico.png",
            class = "img-fluid", 
            style = "max-height:100%; width:auto; object-fit:contain;"
          )
        ),
        card_footer(
          style="min-height:40px",
          tags$small("Velocidad/dirección del viento, humedad y temperatura.",
                     style="color:#7f8c8d; font-style:italic")
        )
      ),
    )
  ),
  
  br(),hr(),br(),
  # --- SECCIÓN: GUÍA DE USUARIO ---
  h3("2. ¿Cómo dominar la Herramienta?", class = "mb-4 mt-5", 
     style = "font-weight: 700; border-left: 5px solid #2E8B57; padding-left: 15px;"),
  
  div(class = "row g-4 justify-content-center",
      
      # Paso 1: Configurar
      div(class = "col-md-3",
          card(
            style = "border: none; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); transition: transform 0.3s ease;",
            class = "h-100 text-center p-4 card-hover",
            div(style = "background: #E8F5E9; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;",
                bs_icon("sliders", size = "1.8rem", class = "text-success")),
            h5(strong("1. Configura"), style = "color: #2E8B57;"),
            p("Define tu zona de interés, el contaminante y el rango de fechas en el panel lateral.", 
              style = "font-size: 0.9rem; color: #666;")
          )
      ),
      
      # Paso 2: Ejecutar
      div(class = "col-md-3",
          card(
            style = "border: none; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); transition: transform 0.3s ease;",
            class = "h-100 text-center p-4 card-hover",
            div(style = "background: #E3F2FD; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;",
                bs_icon("play-circle-fill", size = "1.8rem", class = "text-primary")),
            h5(strong("2. Genera"), style = "color: #0d6efd;"),
            p("Haz clic en 'Generar Gráfica'. La app conectará con la RMCAB para obtener datos en tiempo real.", 
              style = "font-size: 0.9rem; color: #666;")
          )
      ),
      
      # Paso 3: Análisis IA
      div(class = "col-md-3",
          card(
            style = "border: none; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); transition: transform 0.3s ease;",
            class = "h-100 text-center p-4 card-hover",
            div(style = "background: #F3E5F5; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;",
                bs_icon("cpu", size = "1.8rem", style = "color: #9c27b0;")),
            h5(strong("3. Interpreta"), style = "color: #9c27b0;"),
            p("¿Dudas con los resultados? Activa el análisis de IA para obtener una explicación científica.", 
              style = "font-size: 0.9rem; color: #666;")
          )
      ),
      
      # Paso 4: Descubrimiento
      div(class = "col-md-3",
          card(
            style = "border: none; border-radius: 20px; box-shadow: 0 10px 20px rgba(0,0,0,0.05); transition: transform 0.3s ease;",
            class = "h-100 text-center p-4 card-hover",
            div(style = "background: #FFF3E0; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;",
                bs_icon("search", size = "1.8rem", class = "text-warning")),
            h5(strong("4. Descubre"), style = "color: #ef6c00;"),
            p("Navega entre módulos para encontrar patrones y fuentes de emisión en la ciudad.", 
              style = "font-size: 0.9rem; color: #666;")
          )
      )
  ),
  br(),
  
  # --- BOTÓN DE ENTRADA ---
  div(class = "text-center my-5",
      actionButton("empezar_app", "¡Explorar el Panel de Datos!", 
                   class = "btn-success btn-lg", 
                   style = "padding: 20px 80px; font-weight: 800; border-radius: 10px; font-size: 1.5rem; transition: 0.3s;",
                   icon = icon("rocket"))
  )
)