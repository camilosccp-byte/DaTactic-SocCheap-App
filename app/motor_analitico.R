# ==============================================================================
# MOTOR ESTADÍSTICO: CÁLCULO DE PERCENTILES DINÁMICOS

library(dplyr)

# 1. FUNCIÓN PRINCIPAL: Calcula los percentiles 25 y 75 de la base de datos
calcular_umbrales_liga <- function(ruta_csv) {
  # Leer el archivo (ya sea el sintético del repositorio o el subido por el usuario)
  df_liga <- read.csv(ruta_csv)
  
  # Seleccionar solo las 10 métricas colectivas obligatorias
  metricas_clave <- c("posesion", "momentum", "pases", "pases_ultimo_tercio", 
                      "pases_area_rival", "pases_entre_lineas", "grandes_ocasiones", 
                      "remates_al_arco", "xG", "xGOT")
  
  # Crear una lista vacía para almacenar los límites de cada métrica
  matriz_umbrales <- list()
  
  for(metrica in metricas_clave) {
    # Extraer el vector de datos de la métrica actual
    valores <- df_liga[[metrica]]
    
    # Calcular los percentiles 25 (Límite Bajo) y 75 (Límite Alto)
    limites <- quantile(valores, probs = c(0.25, 0.75), na.rm = TRUE)
    
    # Guardar en nuestra matriz de configuración
    matriz_umbrales[[metrica]] <- list(
      bajo = limites[1],
      alto = limites[2]
    )
  }
  
  return(matriz_umbrales)
}
