# cor_plot.R
library(shinycssloaders)

ui_corplot <- nav_panel_hidden(
  "pagina_cor", # ID de esta página
  layout_sidebar(
    sidebar = sidebar(
      title = "Correlacion Contaminantes",
      bg = "#f5f5f5", 
      dateRangeInput("dates_corplot", "Rango de fechas:", 
                     start = Sys.Date() - 7, end = Sys.Date()),
      selectInput("station_corplot", "Estación:", choices = NULL),
      hr(),
      div(class="text-center mb-3",
          uiOutput("control_corplot_ui")),
      hr(),
      actionButton("volver_inicio3", "Volver al Menú", icon = bs_icon("arrow-left"),
                   style = "background-color: transparent; color: #78909C; border: 1px solid #CFD8DC; width: 100%; margin-top: 10px;")
    ),
    card(
      card_header("Correlacion de Contaminantes"),
      card_body(
        withSpinner(plotOutput("plot_corplot", height = "600px"),color = "#78909c"),
        hr(),
        #Seccion para el resutaldo de la IA
        accordion(
          accordion_panel(
            "Analisis Detallado",
            icon = bs_icon("incognito"),
            uiOutput("analisis_ia_out_cor")
          )
        )
      )
  )
)
)