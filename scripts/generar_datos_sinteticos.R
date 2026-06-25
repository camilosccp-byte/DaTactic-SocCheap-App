
# SCRIPT CALIBRADO REGIONALMENTE: BRASIL (ÉLITE) VS COLOMBIA (RITMO MIXTO)

library(dplyr)
library(tidyr)

set.seed(42)

# Función de transformación a formato largo (Mantiene estructura)
formato_largo <- function(df) {
  tl <- df %>% select(id_partido, temporada, torneo, equipo = equipo_local, rival = equipo_visitante, posesion = posesion_local, momentum = momentum_local, pases = pases_local, pases_ultimo_tercio = pases_ut_local, pases_area_rival = pases_area_local, pases_entre_lineas = pases_lineas_local, grandes_ocasiones = grandes_oc_local, remates_al_arco = remates_arco_local, xG = xG_local, xGOT = xGOT_local) %>% mutate(condicion = "Local")
  tv <- df %>% select(id_partido, temporada, torneo, equipo = equipo_visitante, rival = equipo_local, posesion = posesion_visitante, momentum = momentum_visitante, pases = pases_visitante, pases_ultimo_tercio = pases_ut_visitante, pases_area_rival = pases_area_visitante, pases_entre_lineas = pases_lineas_visitante, grandes_ocasiones = grandes_oc_visitante, remates_al_arco = remates_arco_visitante, xG = xG_visitante, xGOT = xGOT_visitante) %>% mutate(condicion = "Visitante")
  bind_rows(tl, tv) %>% arrange(id_partido, condicion) %>% mutate(across(where(is.numeric), ~ ifelse(.x < 0, 0, .x)))
}

# ==============================================================================
# 1. MOTOR Y GENERACIÓN: BRASIL (Parámetros de Alta Circulación y Precisión)

equipos_brasil <- c("Flamengo", "Palmeiras", "Sao Paulo", "Corinthians", "Atletico Mineiro", "Gremio", "Internacional", "Fluminense", "Botafogo", "Cruzeiro", "Santos", "Athletico Paranaense", "Bahia", "Fortaleza", "Vasco da Gama", "Red Bull Bragantino", "Cuiaba", "Goias", "Coritiba", "America Mineiro")
anos_br <- 2006:2026; partidos_por_ano_br <- 380; total_partidos_br <- length(anos_br) * partidos_por_ano_br

base_br <- data.frame(id_partido = 1:total_partidos_br, temporada = rep(anos_br, each = partidos_por_ano_br), torneo = "Serie A") %>%
  rowwise() %>% mutate(equipo_local = sample(equipos_brasil, 1), equipo_visitante = sample(setdiff(equipos_brasil, equipo_local), 1), perfil_local = sample(c("Asedio", "Directo", "Posesion_Inofensiva"), 1)) %>% ungroup()

br_simulado <- base_br %>% rowwise() %>% mutate(
  posesion_local = case_when(perfil_local == "Asedio" ~ round(runif(1, 58, 72), 1), perfil_local == "Directo" ~ round(runif(1, 34, 43.9), 1), TRUE ~ round(runif(1, 52, 60), 1)),
  posesion_visitante = 100 - posesion_local,
  momentum_local = case_when(perfil_local == "Asedio" ~ round(runif(1, 68, 88), 1), perfil_local == "Directo" ~ round(runif(1, 28, 42), 1), TRUE ~ round(runif(1, 50, 58), 1)),
  momentum_visitante = 100 - momentum_local,
  
  # ALTA CIRCULACIÓN BRASIL (Media 550 pases en Asedio)
  
  pases_local = case_when(perfil_local == "Asedio" ~ round(rnorm(1, 550, 30)), perfil_local == "Directo" ~ round(rnorm(1, 330, 20)), TRUE ~ round(rnorm(1, 490, 25))),
  pases_visitante = round((100 - posesion_local) * 8.4 + rnorm(1, 0, 20)),
  pases_ut_local = round(pases_local * runif(1, 0.23, 0.29)), pases_ut_visitante = round(pases_visitante * runif(1, 0.19, 0.25)),
  pases_area_local = case_when(perfil_local == "Asedio" ~ round(pases_ut_local * runif(1, 0.26, 0.34)), perfil_local == "Directo" ~ round(pases_ut_local * runif(1, 0.32, 0.42)), TRUE ~ round(pases_ut_local * runif(1, 0.11, 0.16))),
  pases_area_visitante = round(pases_ut_visitante * runif(1, 0.16, 0.24)),
  
  # ALTOS PASES ENTRE LÍNEAS EN BRASIL (Media 16)
  
  pases_lineas_local = ifelse(perfil_local == "Directo", round(rnorm(1, 16, 2)), round(rnorm(1, 9, 1.5))),
  pases_lineas_visitante = round(rnorm(1, 9, 2)),
  grandes_oc_local = case_when(perfil_local == "Asedio" ~ sample(1:4, 1), perfil_local == "Directo" ~ sample(2:5, 1), TRUE ~ sample(0:2, 1)), grandes_oc_visitante = sample(0:3, 1),
  remates_arco_local = case_when(perfil_local == "Asedio" ~ round(rnorm(1, 7.2, 1)), perfil_local == "Directo" ~ round(rnorm(1, 5.2, 1)), TRUE ~ round(rnorm(1, 3.5, 0.8))), remates_arco_visitante = round(rnorm(1, 4.2, 1)),
  xG_local = round((grandes_oc_local * 0.36) + (remates_arco_local * runif(1, 0.07, 0.12)), 2), xG_visitante = round((grandes_oc_visitante * 0.36) + (remates_arco_visitante * runif(1, 0.06, 0.11)), 2),
  xGOT_local = round(xG_local * runif(1, 0.80, 1.30), 2), xGOT_visitante = round(xG_visitante * runif(1, 0.75, 1.25), 2)
) %>% ungroup() %>% formato_largo()

write.csv(br_simulado, "datos_prueba_liga_brasil.csv", row.names = FALSE)

# ==============================================================================
# 2. MOTOR Y GENERACIÓN: COLOMBIA (Parámetros de Fricción, Menos Pases y Menos Filtrados)


equipos_colombia <- c("Atletico Nacional", "Millonarios", "Santa Fe", "Junior", "America de Cali", "Deportivo Cali", "Independiente Medellin", "Deportes Tolima", "Once Caldas", "Deportivo Pereira", "Deportivo Pasto", "La Equidad", "Envigado", "Aguilas Doradas", "Atletico Bucaramanga", "Jaguares", "Alianza", "Patriotas", "Boyaca Chico", "Fortaleza CEIF")
anos_co <- 2015:2026; partidos_por_semestre_co <- 220; total_partidos_co <- length(anos_co) * 440

base_co <- data.frame(id_partido = 1:total_partidos_co, temporada = rep(anos_co, each = 440), torneo = rep(c("Apertura", "Finalizacion"), each = 220, length.out = total_partidos_co)) %>% group_by(temporada, torneo) %>% mutate(idx_semestre = row_number()) %>% ungroup()
finalistas_por_torneo <- base_co %>% select(temporada, torneo) %>% distinct() %>% rowwise() %>% mutate(
  finalistas = list(sample(equipos_colombia, 2, replace = FALSE)),
  f1 = finalistas[1],
  f2 = finalistas[2]
) %>% ungroup() %>% select(-finalistas)

base_co_finalisimo <- base_co %>% left_join(finalistas_por_torneo, by = c("temporada", "torneo")) %>% rowwise() %>% mutate(
  equipo_local = case_when(idx_semestre == 219 ~ f1, idx_semestre == 220 ~ f2, TRUE ~ sample(equipos_colombia, 1)), 
  equipo_visitante = case_when(idx_semestre == 219 ~ f2, idx_semestre == 220 ~ f1, TRUE ~ sample(setdiff(equipos_colombia, equipo_local), 1)), 
  perfil_local = sample(c("Asedio", "Directo", "Posesion_Inofensiva"), 1)
) %>% select(id_partido, temporada, torneo, equipo_local, equipo_visitante, perfil_local)

co_simulado <- base_co_finalisimo %>% rowwise() %>% mutate(
  posesion_local = case_when(perfil_local == "Asedio" ~ round(runif(1, 55, 67), 1), perfil_local == "Directo" ~ round(runif(1, 36, 45.9), 1), TRUE ~ round(runif(1, 50, 58), 1)),
  posesion_visitante = 100 - posesion_local,
  momentum_local = case_when(perfil_local == "Asedio" ~ round(runif(1, 62, 80), 1), perfil_local == "Directo" ~ round(runif(1, 32, 46), 1), TRUE ~ round(runif(1, 48, 56), 1)),
  momentum_visitante = 100 - momentum_local,
  
  # MENOR VOLUMEN DE PASES COLOMBIA (Media 460 en Asedio debido a la fricción)
  
  pases_local = case_when(perfil_local == "Asedio" ~ round(rnorm(1, 460, 25)), perfil_local == "Directo" ~ round(rnorm(1, 310, 20)), TRUE ~ round(rnorm(1, 420, 20))),
  pases_visitante = round((100 - posesion_local) * 7.6 + rnorm(1, 0, 20)),
  pases_ut_local = round(pases_local * runif(1, 0.19, 0.25)), pases_ut_visitante = round(pases_visitante * runif(1, 0.17, 0.23)),
  pases_area_local = case_when(perfil_local == "Asedio" ~ round(pases_ut_local * runif(1, 0.21, 0.28)), perfil_local == "Directo" ~ round(pases_ut_local * runif(1, 0.26, 0.35)), TRUE ~ round(pases_ut_local * runif(1, 0.09, 0.13))),
  pases_area_visitante = round(pases_ut_visitante * runif(1, 0.12, 0.20)),
  
  # MENOS PASES ENTRE LÍNEAS EN COLOMBIA (Media 11 en Directo por mayor bloque bajo)
  
  pases_lineas_local = ifelse(perfil_local == "Directo", round(rnorm(1, 11, 1.5)), round(rnorm(1, 6, 1))),
  pases_lineas_visitante = round(rnorm(1, 6, 1.5)),
  grandes_oc_local = case_when(perfil_local == "Asedio" ~ sample(1:3, 1), perfil_local == "Directo" ~ sample(1:4, 1), TRUE ~ sample(0:2, 1)), grandes_oc_visitante = sample(0:2, 1),
  remates_arco_local = case_when(perfil_local == "Asedio" ~ round(rnorm(1, 5.8, 1)), perfil_local == "Directo" ~ round(rnorm(1, 4.3, 0.8)), TRUE ~ round(rnorm(1, 2.8, 0.7))), remates_arco_visitante = round(rnorm(1, 3.4, 1)),
  xG_local = round((grandes_oc_local * 0.33) + (remates_arco_local * runif(1, 0.05, 0.09)), 2), xG_visitante = round((grandes_oc_visitante * 0.33) + (remates_arco_visitante * runif(1, 0.05, 0.09)), 2),
  xGOT_local = round(xG_local * runif(1, 0.70, 1.20), 2), xGOT_visitante = round(xG_visitante * runif(1, 0.70, 1.15), 2)
) %>% ungroup() %>% formato_largo()

write.csv(co_simulado, "datos_prueba_liga_betplay_colombia.csv", row.names = FALSE)

cat("¡Datasets calibrados regionalmente creados con éxito!\n")
