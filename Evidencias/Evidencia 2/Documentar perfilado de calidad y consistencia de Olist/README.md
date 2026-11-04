# Evidencia 2 - Perfilado de Calidad y Consistencia de Olist

## 1. Descripción

Esta evidencia contiene los scripts SQL y capturas de pantalla utilizados para evaluar la calidad, consistencia e integridad de los datos originales del conjunto de datos Olist.

## 2. Contenido

Se incluyen los siguientes archivos:

- **E-02.sql:** Consulta SQL para validar los registros de pedidos entregados y detectar valores negativos en precios y fletes.
- **E-02.png:** Captura de pantalla de la ejecución de la consulta y sus resultados.
- **PERFILADO DE CALIDAD Y CONSISTENCIA.sql:** Script SQL para realizar el perfilado de datos, conteo de registros y detección de valores nulos.
- **PERFILADO DE CALIDAD Y CONSISTENCIA.png:** Captura de pantalla de los resultados obtenidos durante las pruebas de calidad y consistencia.

## 3. Objetivo:

Verificar la calidad y consistencia de los datos originales de Olist mediante consultas SQL que permitan identificar posibles inconsistencias, valores nulos y errores en los campos cuantitativos.

## 4. Resultados obtenidos

Las pruebas realizadas permitieron verificar:

- El conteo de registros de las principales tablas del conjunto de datos.
- La identificación de valores nulos en campos clave.
- La validación de precios y fletes en pedidos entregados.
- La ausencia de valores negativos y nulos en los campos cuantitativos evaluados.

## 5. Uso en el proyecto

Los resultados del perfilado permiten evaluar la confiabilidad de los datos de origen antes de realizar los procesos de extracción, transformación y carga (ETL), así como la construcción del DataMart Olist y los reportes de Business Intelligence en Power BI.
