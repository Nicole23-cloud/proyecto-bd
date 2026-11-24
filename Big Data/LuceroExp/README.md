# Experimento de Escalabilidad en Databricks

Este directorio contiene las pruebas de rendimiento realizadas sobre el conjunto de datos de clientes utilizando Apache Spark en Databricks.

## Objetivo
Evaluar cómo responde el motor de procesamiento de Spark al duplicar la carga de registros en consultas de agregación.

## Desarrollo del experimento
1. **Análisis exploratorio (EDA):** Revisión de la estructura, tipos de datos y distribución inicial de la tabla de clientes.
2. **Escenario base (99,441 filas):** Ejecución de consultas de agregación sobre el dataset original para obtener una línea base de tiempo de respuesta.
3. **Escenario duplicado (198,882 filas):** Duplicación del volumen de registros utilizando `UNION ALL` y re-ejecución de las mismas consultas de agregación.
4. **Visualización:** Generación de gráficos comparativos en Databricks para contrastar los resultados obtenidos en ambos escenarios.

## Resultados
Al duplicar la cantidad de filas (de 99,441 a 198,882), los tiempos de ejecución de las consultas se mantuvieron estables y sin degradación significativa, comprobando que el procesamiento distribuido en Spark escala de forma eficiente para este volumen de datos.
