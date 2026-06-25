# ==============================================================================
# ARCHIVO PRINCIPAL: app/app.R
# TAREA: Interfaz y Servidor de la Shiny App (TacticalInsight-R)
# ==============================================================================

library(shiny)
library(shinythemes)
library(dplyr)

# IMPORTAR EL MOTOR ANALÍTICO DESDE TU ARCHIVO INDEPENDIENTE
# Ambos archivos deben estar guardados dentro de la carpeta app/
source("motor_analitico.R")

# ==============================================================================
# 1. INTERFAZ DE USUARIO (UI)
# ==============================================================================
ui <- fluidPage(
  theme = shinytheme("flatly"), # Un diseño limpio, moderno y profesional
  
   titlePanel(
    title = div(
      h1("⚽ DaTactic-SocCheap-App", style = "font-weight: 700; color: #2c3e50;"),
      h4("Scouting y Análisis Táctico de Bajo Presupuesto", style = "color: #7f8c8d; margin-bottom: 25px;")
    ),
    windowTitle = "DaTactic-SocCheap-App"
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 4,
      
      # SECCIÓN 1: CONFIGURACIÓN DE LA LIGA BASE
      tags$h4("1. Contexto Competitivo", style = "font-weight: 600; color: #2c3e50; margin-top: 10px;"),
      selectInput("liga_seleccionada", "Seleccionar Liga de Referencia:",
                  choices = c("Colombia (Ritmo Mixto / Fricción)" = "../data/datos_prueba_liga_betplay_colombia.csv",
                              "Brasil (Élite / Alta Circulación)" = "../data/datos_prueba_liga_brasil.csv",
                              "Subir Base de Datos Propia (.csv)" = "propia")),
      
      # Condicional por si el analista quiere subir su propio archivo CSV histórico
      conditionalPanel(
        condition = "input.liga_seleccionada == 'propia'",
        fileInput("archivo_propio", "Seleccionar archivo CSV de tu liga:", accept = ".csv")
      ),
      hr(style = "border-top: 1px solid #bdc3c7;"),
      
      # SECCIÓN 2: INGRESO DE MÉTRICAS DEL PARTIDO
      tags$h4("2. Métricas del Rival (Eventing)", style = "font-weight: 600; color: #2c3e50;"),
      
      # Bloque Control
      p(strong("Control y Territorio"), style = "color: #16a085; margin-bottom: 5px;"),
      splitLayout(
        numericInput("pos", "Posesión (%)", value = 50, min = 0, max = 100, step = 0.1),
        numericInput("mom", "Momentum", value = 50, min = 0, max = 100, step = 0.1)
      ),
      
      # Bloque Distribución
      p(strong("Distribución y Progresión"), style = "color: #2980b9; margin-top: 10px; margin-bottom: 5px;"),
      splitLayout(
        numericInput("pas", "Pases Totales", value = 400, min = 0),
        numericInput("put", "Pases Úl. Tercio", value = 90, min = 0)
      ),
      splitLayout(
        numericInput("par", "Pases Área Rival", value = 20, min = 0),
        numericInput("pel", "Pases Entre Líneas", value = 8, min = 0)
      ),
      
      # Bloque Finalización
      p(strong("Finalización y Peligro"), style = "color: #c0392b; margin-top: 10px; margin-bottom: 5px;"),
      splitLayout(
        numericInput("rem", "Remates al Arco", value = 4, min = 0),
        numericInput("goc", "Grandes Ocasiones", value = 1, min = 0)
      ),
      splitLayout(
        numericInput("xg", "xG Total", value = 1.2, min = 0, step = 0.01),
        numericInput("xgot", "xGOT Total", value = 1.1, min = 0, step = 0.01)
      ),
      
      br(),
      actionButton("procesar", "Generar Diagnóstico Táctico", class = "btn-primary btn-block", style = "font-weight: 600; padding: 10px;")
    ),
    
    # CUERPO PRINCIPAL: DONDE SE MUESTRA EL REPORTE
    mainPanel(
      width = 8,
      tags$h3("📋 Informe de Inteligencia Analítica", style = "font-weight: 600; color: #2c3e50; margin-top: 10px;"),
      p("El siguiente reporte ha sido construido cruzando las métricas ingresadas contra la distribución estadística y los percentiles de la liga de referencia seleccionada.", style = "color: #7f8c8d;"),
      br(),
      
      # Caja contenedora del texto del diagnóstico
      wellPanel(
        style = "background-color: #ffffff; border-left: 5px solid #34495e; padding: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);",
        htmlOutput("diagnostico_txt")
      ),
      
      br(),
      # Botón interactivo para exportar el reporte
      uiOutput("render_boton_descarga")
    )
  )
)

# ==============================================================================
# 2. LÓGICA DEL SERVIDOR (SERVER)
# ==============================================================================
server <- function(input, output, session) {
  
  # 2.1. Carga reactiva de los percentiles según la liga seleccionada
  umbrales_actuales <- reactive({
    if (input$liga_seleccionada == "propia") {
      req(input$archivo_propio)
      return(calcular_umbrales_liga(input$archivo_propio$datapath))
    } else {
      return(calcular_umbrales_liga(input$liga_seleccionada))
    }
  })
  
  # 2.2. Evento reactivo que se activa SOLO cuando el usuario hace clic en el botón
  reporte_reactivo <- eventReactive(input$procesar, {
    # Agrupar las métricas ingresadas manualmente por el analista en una lista estructurada
    partido_analista <- list(
      posesion = input$pos,
      momentum = input$mom,
      pases = input$pas,
      pases_ultimo_tercio = input$put,
      pases_area_rival = input$par,
      pases_entre_lineas = input$pel,
      grandes_ocasiones = input$goc,
      remates_al_arco = input$rem,
      xG = input$xg,
      xGOT = input$xgot
    )
    
    # Invocar a la segunda función del motor analítico para armar el texto con paste()
    # Cambiamos saltos de línea (\n) por etiquetas HTML (<br>) para que Shiny lo imprima bonito
    texto_raw <- generar_diagnostico_tactico(partido_analista, umbrales_actuales())
    texto_html <- gsub("\n", "<br>", texto_raw)
    
    return(texto_html)
  })
  
  # 2.3. Renderizar el texto en pantalla de forma elegante
  output$diagnostico_txt <- renderUI({
    if (input$procesar == 0) {
      return(p(em("Modifica las métricas en el panel izquierdo y presiona el botón 'Generar Diagnóstico Táctico' para desplegar el informe escrito."), style = "color: #95a5a6;"))
    }
    HTML(reporte_reactivo())
  })
  
  # 2.4. Mostrar el botón de descarga únicamente si el reporte ya ha sido generado
  output$render_boton_descarga <- renderUI({
    if (input$procesar > 0) {
      downloadButton("descargar_reporte", "Exportar Reporte Táctico (HTML)", class = "btn-success", style = "font-weight: 600;")
    }
  })
  
  # 2.5. Manejador de la descarga para exportar a formato portátil limpio
  output$descargar_reporte <- downloadHandler(
    filename = function() {
      paste("Reporte_Tactico_", Sys.Date(), ".html", sep = "")
    },
    content = function(file) {
      # Estructurar una plantilla HTML responsiva e independiente para el navegador
      contenido_html <- paste0(
        "<html><head><meta charset='utf-8'><title>Reporte Táctico Automatizado</title>",
        "<style>body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding: 40px; color: #2c3e50; line-height: 1.6; } h2 { color: #2c3e50; border-bottom: 2px solid #34495e; padding-bottom: 10px; } .footer { margin-top: 40px; font-size: 12px; color: #95a5a6; border-top: 1px solid #ecf0f1; padding-top: 10px; }</style>",
        "</head><body>",
        "<h2>📋 TacticalInsight-R: Informe Estratégico Rival</h2>",
        "<p><strong>Fecha de Generación:</strong> ", Sys.Date(), "</p>",
        "<hr style='border: 0; border-top: 1px solid #ecf0f1;'>",
        "<div>", reporte_reactivo(), "</div>",
        "<div class='footer'>Generado automáticamente mediante TacticalInsight-R. Sistema de Analítica de Fútbol de Bajo Presupuesto.</div>",
        "</body></html>"
      )
      writeLines(contenido_html, file)
    }
  )
}

# LANZAR LA APLICACIÓN
shinyApp(ui = ui, server = server)
