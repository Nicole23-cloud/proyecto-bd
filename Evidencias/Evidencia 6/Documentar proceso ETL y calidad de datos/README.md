# Evidencia 6 - Proceso ETL, Auditoría y Verificación de Calidad de Datos de Olist

## 1. Descripción

Esta evidencia contiene los scripts SQL y las capturas de pantalla utilizados para implementar y verificar el proceso de extracción, transformación y carga (ETL) del DataMart Olist, así como los mecanismos de auditoría y las pruebas de calidad de los datos.

Se busca garantizar la integridad, consistencia y confiabilidad de la información almacenada en el DataMart antes de su utilización en los procesos de análisis y visualización de datos.

## 2. Contenido

Se incluyen los siguientes archivos:

- **ETL-OLIST (Corregido).sql:** Script SQL que implementa el procedimiento almacenado para ejecutar el proceso ETL, registrar la información de auditoría y controlar los resultados de la carga de datos.
- **E-06.png:** Captura de pantalla de la ejecución del proceso ETL y de los resultados obtenidos en las tablas de auditoría, errores y métricas.
- **Uditoria.sql:** Script SQL utilizado para consultar y verificar los registros de auditoría generados durante las ejecuciones del proceso ETL.
- **Uditoria.png:** Captura de pantalla de los resultados de las consultas de auditoría.
- **Verificacion de duplicados.sql:** Script SQL utilizado para identificar posibles registros duplicados en la tabla de hechos `fact_ventas`.
- **Verificacion de duplicados.png:** Captura de pantalla de la ejecución de la consulta de verificación de duplicados.
- **Verificacion nulos.sql:** Script SQL utilizado para identificar y evaluar valores nulos en campos clave de las tablas del DataMart.
- **Verificacion nulos.png:** Captura de pantalla de los resultados de las pruebas de valores nulos.

## 3. Objetivo

Implementar y validar el proceso ETL del DataMart Olist mediante procedimientos almacenados, mecanismos de auditoría y pruebas de calidad de datos, con la finalidad de garantizar la correcta carga, integridad y confiabilidad de la información.

## 4. Resultados obtenidos

Las pruebas realizadas permitieron obtener los siguientes resultados:

- Ejecución satisfactoria del proceso ETL.
- Registro de las ejecuciones del proceso en la tabla `auditoria_etl`.
- Registro de métricas de carga en la tabla `metricas_etl`.
- Control y registro de posibles errores mediante la tabla `errores_etl`.
- Verificación de registros duplicados en la tabla `fact_ventas`.
- Evaluación de valores nulos en campos clave de las tablas `dim_cliente`, `dim_vendedor` y `fact_ventas`.
- Validación de la consistencia entre los registros de origen y destino.

Según las capturas de las pruebas realizadas, las tablas evaluadas presentan un 100 % de completitud en los campos verificados y no se identificaron registros duplicados en la consulta ejecutada.

## 5. Uso en el proyecto

El proceso ETL permite integrar y organizar los datos originales de Olist en el DataMart, mientras que los mecanismos de auditoría y las pruebas de calidad permiten supervisar las cargas y verificar la confiabilidad de la información.

Estos resultados sirven como base para los procesos posteriores de análisis multidimensional y elaboración de reportes en Power BI.

## 6. Tecnologías utilizadas

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL (T-SQL)
- DataMart Olist
- GitHub para el almacenamiento y documentación de evidencias
