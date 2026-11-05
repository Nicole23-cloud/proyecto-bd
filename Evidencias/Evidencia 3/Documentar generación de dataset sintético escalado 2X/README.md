# Evidencia 3 - Generación de Dataset Sintético Escalado (2X)

## 1. Descripción

Esta evidencia contiene el script SQL y las capturas de pantalla utilizadas para generar un dataset sintético escalado al doble (2X) del volumen original de la tabla de hechos `fact_ventas`, perteneciente al DataMart Olist.

## 2. Contenido

Se incluyen los siguientes archivos:

- **GENERACIÓN DE DATASET SINTÉTICO ESCALADO (2X).sql:** Script SQL para crear la tabla `fact_ventas_2x`, insertar los registros originales y duplicarlos mediante identificadores sintéticos.
- **GENERACIÓN DE DATASET SINTÉTICO ESCALADO (2X).png:** Captura de pantalla de la ejecución del script y los resultados de la verificación del volumen de registros.

## 3. Objetivo

Generar un dataset sintético con el doble de registros que la tabla original `fact_ventas`, manteniendo la estructura y los valores de sus campos, para realizar pruebas de carga y evaluar el rendimiento del DataMart Olist.

## 4. Resultados obtenidos

La ejecución del script permitió obtener los siguientes resultados:

- Dataset original (`fact_ventas`): 108,905 registros.
- Dataset sintético escalado (`fact_ventas_2x`): 217,810 registros.
- Factor de escalamiento: 2X.

Se verificó que la tabla sintética contiene el doble de registros que la tabla original.

## 5. Uso en el proyecto

El dataset sintético se utiliza para realizar pruebas de rendimiento y carga sobre el DataMart Olist, permitiendo evaluar el comportamiento de las consultas SQL y los procesos de análisis ante un mayor volumen de información.
