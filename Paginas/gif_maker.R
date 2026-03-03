# Paginas/gif_maker.R

ui_gif_maker <- nav_panel_hidden(
  "pagina_gif",
  layout_sidebar(
    sidebar = sidebar(
      title = "Configurador de GIF",
      bg = "#FFFDE7", 
      
      # Selector de fecha única (para generar las 24 horas de ese día)
      dateInput("fecha_gif", "Selecciona el día:", 
                value = Sys.Date() - 1, 
                language = "es",
                max = Sys.Date() - 1),
      
      # El selector de contaminantes se llena desde el server
      selectInput("pollutant_gif", "Contaminante:", choices = NULL),
      
      hr(),
      # Botón dinámico que cambiará a mensaje de carga
      div(class="text-center mb-3",
          uiOutput("control_gif_ui")),
      
      hr(),
      # Botón para regresar al menú principal
      actionButton("volver_inicio4", "Volver al Menú", 
                   icon = bs_icon("arrow-left"), 
                   style = "background-color: transparent; border: 1px solid #FBC02D; color: #FBC02D; width: 100%; font-weight: 600;")
    ),
    
    card(
      card_header("Mapa Dinámico de Calidad del Aire (24 Horas)"),
      card_body(
        class = "d-flex justify-content-center align-items-center",
        # Importante: para GIFs usamos imageOutput, no plotOutput
        withSpinner(imageOutput("gif_plot_output"), color = "#FBC02D")
      ),
      card_footer(
        p("Nota: La generación del GIF puede tardar entre 15 y 30 segundos debido al procesamiento de imágenes.", 
          style = "font-size: 0.8rem; color: #777; text-align: center;")
      )
    )
  )
)