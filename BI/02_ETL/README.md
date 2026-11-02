# 02. ETL - OLIST

## 1. Descripción

Esta carpeta contiene los scripts SQL utilizados para realizar los procesos de extracción, transformación y carga (ETL) de los datos del conjunto de datos OLIST hacia el DataMart del proyecto Business Intelligence.

Estos procesos permiten integrar, limpiar, transformar y organizar la información comercial para facilitar su análisis y posterior visualización en Power BI.

## 2. Objetivo

Implementar procesos ETL que permitan trasladar los datos originales de OLIST hacia las tablas dimensionales y la tabla de hechos del DataMart, garantizando la consistencia, integridad y calidad de la información.

## 3. Archivos contenidos

| Archivo | Descripción |
|---|---|
| `ETL-OLIST.sql` | Script principal para la extracción, transformación y carga de datos hacia las dimensiones y la tabla de hechos del DataMart. |
| `ETL_OLIST_ACTUAL_con_perf_counter(SUBIR).sql` | Versión del proceso ETL que incorpora mediciones de rendimiento mediante contadores y registro de tiempos de ejecución. |

## 4. Proceso ETL

### 4.1 Extracción

Se obtienen los datos de las tablas originales del conjunto de datos OLIST, incluyendo información de productos, clientes, vendedores, pedidos y detalles de ventas.

### 4.2 Transformación

Se realizan operaciones de limpieza, conversión de tipos de datos, tratamiento de valores nulos, traducción de categorías y organización de la información para su integración en el modelo dimensional.

### 4.3 Carga

Se insertan los datos procesados en las dimensiones y en la tabla de hechos del DataMart, permitiendo su utilización en consultas analíticas y reportes de Business Intelligence.

## 5. Tecnologías utilizadas

- SQL Server
- Transact-SQL (T-SQL)
- DataMart OLIST
- Procesos ETL
- Modelo dimensional

## 6. Resultados esperados

- Información organizada en las dimensiones del DataMart.
- Datos de ventas integrados en la tabla de hechos.
- Información preparada para el análisis mediante Power BI.
- Procesos ETL verificables y medibles.
