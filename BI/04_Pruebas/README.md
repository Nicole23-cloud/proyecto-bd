# 04. Pruebas - OLIST

## 1. Descripción

Esta carpeta contiene los scripts SQL y documentos utilizados para realizar las pruebas de validación, calidad de datos y rendimiento del DataMart del proyecto Business Intelligence basado en el conjunto de datos OLIST.

Las pruebas permiten verificar que los datos se encuentren correctamente integrados, que las métricas calculadas sean consistentes y que el sistema responda adecuadamente durante la ejecución de consultas.

## 2. Objetivo

Validar el correcto funcionamiento del DataMart OLIST mediante pruebas de integridad, consistencia, calidad de datos y rendimiento, garantizando la confiabilidad de la información utilizada para el análisis y la toma de decisiones.

## 3. Archivos contenidos

| Archivo | Descripción |
|---|---|
| `Pruebas criterios y metricas.sql` | Contiene consultas SQL para verificar los criterios de validación y las métricas del DataMart. |
| `TIEMPO DE RESPUESTA.txt` | Documenta los resultados obtenidos durante las pruebas de tiempo de respuesta. |
| `exp-olist-benchmark.sql` | Contiene el script utilizado para evaluar el rendimiento mediante pruebas de carga y consultas de referencia. |

## 4. Tipos de pruebas

### 4.1. Pruebas de calidad de datos

Permiten verificar la integridad y consistencia de la información almacenada en las tablas dimensionales y la tabla de hechos.

Se consideran aspectos como:
- Validación de registros nulos.
- Verificación de claves primarias y relaciones.
- Identificación de registros duplicados.
- Validación de consistencia entre dimensiones y tabla de hechos.

### 4.2. Pruebas de criterios y métricas

Permiten comprobar que las métricas utilizadas en el análisis comercial se calculen correctamente y que los resultados obtenidos sean consistentes con la información almacenada.

### 4.3. Pruebas de rendimiento

Evalúan el comportamiento del DataMart durante la ejecución de consultas, considerando el tiempo de respuesta y el volumen de información procesada.

## 5. Procedimiento de ejecución

1. Crear o seleccionar la base de datos `DATAMAR_OLIST`.
2. Verificar que las tablas dimensionales y la tabla de hechos estén correctamente pobladas.
3. Ejecutar el script `Pruebas criterios y metricas.sql`.
4. Registrar los resultados obtenidos y verificar los criterios de validación.
5. Ejecutar el script `exp-olist-benchmark.sql`.
6. Registrar los tiempos de respuesta obtenidos.


## 6. Resultados esperados

- Datos íntegros y consistentes.
- Relaciones correctamente establecidas entre las dimensiones y la tabla de hechos.
- Métricas comerciales calculadas correctamente.
- Consultas ejecutadas sin errores.
- Tiempos de respuesta registrados y documentados.





