# ==============================================================================
# Motor de Inteligencia Táctica (Cálculo de Percentiles y Generador de Texto)

library(dplyr)

# 1. FUNCIÓN PRINCIPAL: Calcula: percentiles 25 y 75 de la base de datos de la liga
calcular_umbrales_liga <- function(ruta_csv) {
  df_liga <- read.csv(ruta_csv)
  
  # Las 10 métricas colectivas obligatorias <- elegidas luego de un analisis minucioso en diferentes ligas y datos disponibles de apps
  # gratuitas de eventing, listas solo para obtener e ingresar en la calculadora del UI
  metricas_clave <- c("posesion", "momentum", "pases", "pases_ultimo_tercio", 
                      "pases_area_rival", "pases_entre_lineas", "grandes_ocasiones", 
                      "remates_al_arco", "xG", "xGOT")
  
  matriz_umbrales <- list()
  
  for(metrica in metricas_clave) {
    valores <- df_liga[[metrica]]
    limites <- quantile(valores, probs = c(0.25, 0.75), na.rm = TRUE)
    
    # Guardamos los límites extrayendo solo el valor numérico (eliminando etiquetas de %)
    matriz_umbrales[[metrica]] <- list(
      bajo = as.numeric(limites[1]),
      alto = as.numeric(limites[2])
    )
  }
  
  return(matriz_umbrales)
}

# 2. FUNCIÓN COMPLEMENTARIA: Evalúa el partido manual del analista contra los percentiles
generar_diagnostico_tactico <- function(partido_manual, umbrales) {
  # 3 Parrafos para la generacion del diagnóstico táctico final, ya subdividiendo los grupos de las métricas
  # --- PÁRRAFO 1: ESTILO DE JUEGO E INICIATIVA --- 
  p1 <- ""
  if (partido_manual$posesion > umbrales$posesion$alto && partido_manual$pases_area_rival > umbrales$pases_area_rival$alto) {
    p1 <- "El equipo adversario presenta un estilo de juego basado en el ASEDIO y el posicionamiento avanzado. Es un equipo dominador que busca el control del partido mediante la circulación de balón en campo rival, instalando su bloque alto y hundiendo al oponente en su propia área."
  } else if (partido_manual$posesion < umbrales$posesion$bajo && partido_manual$pases_entre_lineas > umbrales$pases_entre_lineas$alto) {
    p1 <- "Estamos ante un equipo de TRANSICIÓN DIRECTA y alta verticalidad. Renuncian deliberadamente a la posesión larga y la elaboración estéril. Su peligro radica en la velocidad para activar pases filtrados inmediatamente tras recuperar el balón, explotando las espaldas defensivas."
  } else if (partido_manual$posesion > umbrales$posesion$alto && partido_manual$pases_area_rival < umbrales$pases_area_rival$bajo) {
    p1 <- "El rival muestra un comportamiento de POSESIÓN INOFENSIVA. Acumulan muchos pases en zonas de inicio y creación (bloque bajo), pero carecen de agresividad, desmarques de ruptura y profundidad para penetrar el bloque defensivo rival."
  } else {
    p1 <- "El rival presenta un comportamiento táctico MIXTO o equilibrado. Se adaptan al contexto del partido, alternando tramos de posesión posicional con transiciones rápidas según los espacios que otorgue el adversario."
  }
  
  # --- PÁRRAFO 2: VOLUMEN DE REMATES Y PEGADA (xG vs xGOT) ---
  p2 <- ""
  ratio_eficiencia <- partido_manual$xG / max(partido_manual$remates_al_arco, 1)
  
  if (partido_manual$grandes_ocasiones > umbrales$grandes_ocasiones$alto && ratio_eficiencia > 0.12) {
    p2 <- "En ataque, su ofensiva es sumamente SELECTIVA Y LETAL. No dependen de un volumen exagerado de tiros lejanos; priorizan la elaboración de la jugada hasta encontrar situaciones francas de gol (Grandes Ocasiones), lo que eleva drásticamente su probabilidad de anotar."
  } else if (partido_manual$remates_al_arco > umbrales$remates_al_arco$alto && partido_manual$xG < umbrales$xG$bajo) {
    p2 <- "Registran un alto volumen de remates, pero con un xG acumulado críticamente bajo. Esto evidencia un síntoma de DESESPERACIÓN u orden táctico deficiente, recurriendo constantemente al disparo de larga distancia o desde posiciones muy incómodas."
  } else if (partido_manual$xG > umbrales$xG$alto && partido_manual$xGOT < umbrales$xGOT$bajo) {
    p2 <- "El equipo posee la capacidad táctica para generar ventajas y dejar a sus delanteros en posiciones claras de gol (alto xG), pero la EJECUCIÓN FINAL O PUNTERÍA ES DEFICIENTE. Sus remates pierden peligro tras ser ejecutados, facilitando el trabajo del arquero."
  } else {
    p2 <- "El volumen de finalización y la calidad de sus remates se mantienen dentro de los parámetros estándar de la competición, mostrando una efectividad regular de cara al arco."
  }
  
  # --- PÁRRAFO 3: RECOMENDACIÓN DE CAMPO ---
  p3 <- "Para el planteamiento del partido propio, se sugiere neutralizar los circuitos lógicos del rival identificados en este reporte, presionar las zonas de inicio detectadas si su repliegue es lento y forzar el juego hacia sus pasillos de menor comodidad estadística."
  
  # Finalmente, unir los párrafos de forma limpia con saltos de línea doble para R
  reporte_completo <- paste(p1, p2, p3, sep = "\n\n")
  return(reporte_completo)
}

}
