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
      
      conditionalPanel(
        condition = "input.liga_seleccionada == 'propia'",
        fileInput("archivo_propio", "Seleccionar archivo CSV de tu liga:", accept = ".csv")
      ),
      hr(style = "border-top: 1px solid #bdc3c7;"),
      
      # SECCIÓN 2: PESTAÑAS DE INGRESO (DIRECTO VS CALCULADORA DE 5 FECHAS)
      tags$h4("2. Datos del Rival (Eventing)", style = "font-weight: 600; color: #2c3e50;"),
      
      tabsetPanel(
        id = "metodo_ingreso",
        
        # PESTAÑA A: INGRESO MANUAL DIRECTO
        tabPanel("Ingreso Directo",
                 br(),
                 p(strong("Control y Territorio"), style = "color: #16a085; margin-bottom: 5px;"),
                 # Dejamos solo la posesión, el momentum se calcula solo
                 numericInput("pos", "Posesión (%) del Rival", value = 50, min = 0, max = 100, step = 0.1),
                 
                 p(strong("Distribución y Progresión"), style = "color: #2980b9; margin-top: 10px; margin-bottom: 5px;"),
                 splitLayout(
                   numericInput("pas", "Pases Totales", value = 400, min = 0),
                   numericInput("put", "Pases Úl. Tercio", value = 90, min = 0)
                 ),
                 splitLayout(
                   numericInput("par", "Pases Área Rival", value = 20, min = 0),
                   numericInput("pel", "Pases Entre Líneas", value = 8, min = 0)
                 ),
                 
                 p(strong("Finalización y Peligro"), style = "color: #c0392b; margin-top: 10px; margin-bottom: 5px;"),
                 # Añadimos los remates del Oponente para poder hacer la fórmula del espejo de tiros
                 splitLayout(
                   numericInput("rem", "Remates al Arco Rival", value = 5, min = 0),
                   numericInput("rem_op", "Remates al Arco Oponente", value = 5, min = 0)
                 ),
                 splitLayout(
                   numericInput("goc", "Grandes Ocasiones Rival", value = 1, min = 0),
                   numericInput("xg", "xG Total Rival", value = 1.2, min = 0, step = 0.01)
                 ),
                 numericInput("xgot", "xGOT Total Rival", value = 1.1, min = 0, step = 0.01)
        ),
        
        # PESTAÑA B: CALCULADORA DE PROMEDIOS (ÚLTIMAS 5 JORNADAS)
        tabPanel("📊 Calculadora 5 Fechas",
                 br(),
                 p(em("Pega los valores de las últimas 5 jornadas separados por comas."), style = "font-size:12px; color:#7f8c8d;"),
                 textInput("c_pos", "Posesión % Rival", value = "50, 50, 50, 50, 50"),
                 textInput("c_pas", "Pases Totales Rival", value = "400, 400, 400, 400, 400"),
                 textInput("c_put", "Pases Último Tercio", value = "90, 90, 90, 90, 90"),
                 textInput("c_par", "Pases Área Rival", value = "20, 20, 20, 20, 20"),
                 textInput("c_pel", "Pases Entre Líneas", value = "8, 8, 8, 8, 8"),
                 textInput("c_rem", "Remates al Arco Rival", value = "5, 5, 5, 5, 5"),
                 textInput("c_rem_op", "Remates al Arco Oponente", value = "5, 5, 5, 5, 5"), # Necesario para la fórmula
                 textInput("c_goc", "Grandes Ocasiones Rival", value = "1, 1, 1, 1, 1"),
                 textInput("c_xg", "xG Total Rival", value = "1.2, 1.2, 1.2, 1.2, 1.2"),
                 textInput("c_xgot", "xGOT Total Rival", value = "1.1, 1.1, 1.1, 1.1, 1.1")
        )
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
  reporte_reactivo <- eventReactive(input$procesar, {  # Función interna para promediar strings separados por comas
    # Función interna para promediar strings separados por comas
    obtener_promedio <- function(input_string) {
      numeros <- as.numeric(unlist(strsplit(input_string, ",")))
      return(mean(numeros, na.rm = TRUE))
    }
      
      # 1. Recolectar las variables base según la pestaña activa
      if (input$metodo_ingreso == "📊 Calculadora 5 Fechas") {
        v_pos <- obtener_promedio(input$c_pos)
        v_pas <- obtener_promedio(input$c_pas)
        v_put <- obtener_promedio(input$c_put)
        v_par <- obtener_promedio(input$c_par)
        v_pel <- obtener_promedio(input$c_pel)
        v_rem <- obtener_promedio(input$c_rem)
        v_rem_op <- obtener_promedio(input$c_rem_op)
        v_goc <- obtener_promedio(input$c_goc)
        v_xg  <- obtener_promedio(input$c_xg)
        v_xgot <- obtener_promedio(input$c_xgot)
      } else {
        v_pos <- input$pos
        v_pas <- input$pas
        v_put <- input$put
        v_par <- input$par
        v_pel <- input$pel
        v_rem <- input$rem
        v_rem_op <- input$rem_op
        v_goc <- input$goc
        v_xg  <- input$xg
        v_xgot <- input$xgot
      }
      
      # 2. APLICACIÓN AUTOMÁTICA DE LA FÓRMULA DE MOMENTUM (IDT)
      # Evitamos división por cero si no hay remates en el partido
      total_tiros <- max(v_rem + v_rem_op, 1)
      ratio_tiros <- v_rem / total_tiros
      
      calculo_momentum <- (v_pos * 0.4) + (ratio_tiros * 40) + (v_goc * 5)
      v_mom <- min(max(calculo_momentum, 0), 100) # Forzar tope entre 0 y 100
      
      # 3. Construir la lista final que va hacia el motor analítico
      partido_analista <- list(
        posesion = v_pos,
        momentum = v_mom, # ¡Automatizado!
        pases = v_pas,
        pases_ultimo_tercio = v_put,
        pases_area_rival = v_par,
        pases_entre_lineas = v_pel,
        grandes_ocasiones = v_goc,
        remates_al_arco = v_rem,
        xG = v_xg,
        xGOT = v_xgot
      )
      
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
