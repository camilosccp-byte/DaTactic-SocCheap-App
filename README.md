# Datactic-SocCheap-App
Con el proposito de dar una aproximacion al area de datos a clubes con presupuesto limitado, he creado este repositorio con el fin de que cualquier integrante del staff ingresando a plataformas como Flashscore, Sofascore etc, use esas metricas y tenga un analisis instantaneo de su rival con ponderaciones a nivel de su propia liga!

# ⚽ TacticalInsight-R: Scouting de Bajo Presupuesto

Una aplicación analítica desarrollada en **R y Shiny** diseñada específicamente para cuerpos técnicos y analistas de fútbol con presupuestos limitados. La herramienta transforma métricas básicas de *eventing* (extraíbles de plataformas gratuitas como Flashscore o Sofascore, o automatizadas mediante VeoCam) en diagnósticos tácticos automatizados sobre el estilo de juego de los equipos rivales.

---

## 💡 El Problema y la Solución

### El Desafío
Los clubes de divisiones menores o ligas amateur no pueden costear licencias anuales de miles de dólares en plataformas de datos de élite (como WyScout o Opta) ni software avanzado de videoanálisis.

### Nuestra Solución
El fútbol es un juego de relaciones estadísticas. Esta app demuestra que cruzando **10 métricas clave de eventos** colectivos, es posible identificar con precisión si un rival juega bajo un modelo de **Asedio/Dominio**, **Transición Directa** o **Posesión Inofensiva**, devolviendo un informe escrito listo para la charla técnica, o en entrenamientos como base de planeación y estratégia!

---

## 🛠️ Arquitectura de Datos e Hiperrealismo Sudamericano

Para probar y validar la aplicación sin depender de APIs de pago, el repositorio incluye un **generador de datos sintéticos avanzados (falsos pero consistentes)**. A diferencia de las simulaciones azarosas tradicionales, este motor aplica reglas de consistencia táctica en **formato largo (espejo)** y cuenta con calibración cultural/deportiva regional:

### 🇧🇷 Modelo Brasil (`data/datos_prueba_liga_brasil.csv`)
*   **Volumen:** 20 equipos reales del Brasileirão Serie A.
*   **Histórico:** 20 temporadas simuladas (2006-2025) con 380 partidos anuales (7,600 partidos totales / 15,200 registros).
*   **Calibración:** Perfil táctico de alta circulación. Medias elevadas de pases totales (~550 en asedio) y un índice superior de pases filtrados entre líneas, reflejando la jerarquía técnica de la élite continental.

### 🇨🇴 Modelo Colombia (`data/datos_prueba_liga_betplay_colombia.csv`)
*   **Volumen:** 20 equipos reales de la Liga BetPlay Dimayor.
*   **Histórico:** 11 años simulados (2015-2025) con 440 partidos anuales (4,840 partidos totales / 9,680 registros).
*   **Hiperrealismo:** El script inyecta automáticamente **las finales (ida y vuelta)** en las últimas dos jornadas (219 y 220) de cada semestre entre los mismos dos equipos finalistas.
*   **Calibración:** Perfil de ritmo mixto y fricción física. Menor volumen general de pases (~460 en asedio) y umbrales más estrictos para pases entre líneas debido a los bloques bajos de la liga.

---

## 📊 Las 10 Métricas Colectivas Clave

La lógica interna de la aplicación evalúa tres dimensiones del juego con balón:

1.  **Control y Territorio:** Posesión (%) y Momentum Ofensivo.
2.  **Distribución y Progresión:** Pases totales, Pases en el último tercio, Pases en el área rival y Pases entre líneas.
3.  **Finalización y Peligro:** Remates al arco, Grandes ocasiones (Big Chances), Goles Esperados (xG) y Goles Esperados en Arco (xGOT).

## 📄 Generación de Reportes Automáticos (Exportación)
La Shiny App incluye un módulo de exportación rápida diseñado para el trabajo de campo:
* **Botón de Descarga Directa:** Permite exportar el diagnóstico táctico generado con un solo clic.
* **Formato Portable (HTML/PDF):** El sistema compila un reporte limpio, estandarizado y responsivo. Esto facilita que el analista lo envíe por WhatsApp/correo al cuerpo técnico o lo imprima para la charla previa al partido en el camerino (u otros espacios que se consideren importantes).

---

## 🚀 Próximos Pasos en el Repositorio

*   [x] Diseño conceptual del MVP táctico.
*   [x] Construcción del motor de simulación y calibración regional (Brasil/Colombia).
*   [ ] Script de cálculo automatizado de percentiles (Umbrales dinámicos).
*   [ ] Interfaz de usuario interactiva en Shiny App.

---

## 🔮 Roadmap y Evolución del Proyecto

💡 **¡Te invitamos a explorar el archivo [Mejoras_Futuras.md](Mejoras_Futuras.md)!**  
Allí detallamos la planificación para las próximas versiones de la plataforma, incluyendo el diseño de una **nueva pestaña de estadísticas individuales** de jugadores (Scouting Granular). Explicamos cómo planeamos integrar datos individuales extraídos de Flashscore (u otras apps de eventing gratuitas) junto con la analítica colectiva para ofrecer un análisis mucho más profundo, integrado y personalizado, manteniendo siempre nuestra filosofía de desarrollo de bajo costo.

*   [ ] Integración de variables avanzadas opcionales (Velocidad de roles defensivos y mapas de calor cualitativos).

