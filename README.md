#  Monitoreo de Calidad del Aire - Bogotá (RMCAB)

Esta es una aplicación interactiva desarrollada en **R Shiny** para la visualización y análisis técnico de los datos de la Red de Monitoreo de Calidad del Aire de Bogotá (RMCAB). El proyecto integra herramientas avanzadas de análisis ambiental y está diseñado para facilitar la interpretación de contaminantes en la ciudad.

##  Estructura del Proyecto

La aplicación sigue una arquitectura modular para facilitar el mantenimiento:

* **`app.R`**: El archivo principal que ejecuta la aplicación.
* **`functions/`**: Scripts con la lógica de descarga de datos (Secretaría de Ambiente) y procesamiento matemático.
* **`modules/`**: Archivos exclusivos para cada pestaña de visualización.
* **`renv.lock`**: Archivo de control de versiones de las librerías para asegurar que todos trabajemos con el mismo entorno.

##  Funcionalidades Actuales

* 📍 **Mapa Interactivo**: Ubicación de estaciones con el contaminante predominante en las últimas 24h.
* 📈 **Time Variation**: Análisis temporal de las concentraciones.
* 🌹 **Pollution Rose**: Relación entre la dirección del viento y la concentración de contaminantes.
* 📉 **Corplot**: Matriz de correlación entre variables ambientales.
* 🎬 **Mapa Animado (En desarrollo)**: Visualización temporal de la dispersión de contaminantes.

##  Instalación y Configuración

Si es tu primera vez colaborando, sigue estos pasos para clonar el proyecto y configurar tu entorno:

1.  **Clonar el repositorio:**
    Desde RStudio: `File > New Project > Version Control > Git` y pega la URL de este repo.

2.  **Restaurar el entorno (Librerías):**
    Este proyecto utiliza `renv`. Para instalar todas las dependencias necesarias con las versiones exactas, ejecuta en la consola de R:
    ```r
    install.packages("renv")
    renv::restore()
    ```

##  Guía de Colaboración

Para mantener el código organizado y evitar conflictos, seguimos este flujo:

1.  **Pull**: Antes de empezar, descarga los últimos cambios con la **flecha azul**.
2.  **Branch**: Crea una rama nueva para tus cambios (ej: `feature-mejora-mapa`). **Nunca** trabajes directamente sobre `main`.
3.  **Commit & Push**: Sube tus cambios con un mensaje descriptivo.
4.  **Pull Request**: Abre un PR en GitHub para que revisemos los cambios antes de integrarlos a la versión final.

---
