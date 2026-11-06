# Documentación de la Base de Datos OLTP y Data Mart – Proyecto Olist

**Proyecto:** Integración de Datos Olist – Solución BI  
**Motor de base de datos:** Microsoft SQL Server  
**Herramienta:** SQL Server Management Studio (SSMS)

## 1. Descripción

Esta carpeta contiene los archivos correspondientes a la base de datos transaccional OLTP y la estructura del Data Mart del proyecto Olist. Incluye los scripts SQL necesarios para la carga de información, creación de tablas y configuración de la base de datos analítica.

## 2. Organización de archivos

| Archivo | Descripción |
|---|---|
| `OLIST_OLTP_por_lotes (v).part01.rar` | Primera parte del archivo comprimido de la base de datos OLTP. |
| `OLIST_OLTP_por_lotes (v).part02.rar` | Segunda parte del archivo comprimido de la base de datos OLTP. |
| `OLIST_OLTP_por_lotes (v).part03.rar` | Tercera parte del archivo comprimido de la base de datos OLTP. |
| `ETL-OLIST (Corregido).sql` | Script correspondiente al proceso ETL del proyecto. |
| `OLIST_TABLAS_DATAMART (corregido).sql` | Script de creación y estructuración de las tablas del Data Mart. |
| `Prueba Datamart.sql` | Script utilizado para realizar pruebas y verificar el funcionamiento del Data Mart. |

## 3. Procedimiento de ejecución

### Paso 1. Obtener la base de datos OLTP

- Descargar las tres partes del archivo comprimido.
- Colocar los archivos en una misma carpeta.
- Extraer el contenido desde la primera parte (`part01.rar`) utilizando WinRAR o 7-Zip.
- Restaurar o cargar la base de datos en SQL Server.

### Paso 2. Crear el Data Mart

- Abrir SQL Server Management Studio.
- Ejecutar el archivo `OLIST_TABLAS_DATAMART (corregido).sql`.
- Verificar la creación de la base de datos `OLIST_DATAMART` y sus respectivas tablas.

### Paso 3. Ejecutar el proceso ETL

- Abrir el archivo `ETL-OLIST (Corregido).sql`.
- Ejecutar el script correspondiente al proceso de extracción, transformación y carga de datos.
- Verificar la transferencia de información desde la base OLTP hacia el Data Mart.

### Paso 4. Realizar pruebas

- Abrir el archivo `Prueba Datamart.sql`.
- Ejecutar las consultas de validación.
- Comprobar que las tablas contengan información y que los datos se encuentren disponibles para su análisis.

## 4. Resultado esperado

Contar con una base de datos transaccional OLTP y un Data Mart estructurado y poblado, preparados para el desarrollo de procesos de inteligencia de negocios y visualización de indicadores mediante Power BI.

## 5. Importancia

La organización de estos archivos permite mantener un control de los scripts, facilitar la implementación del proyecto y disponer de los recursos necesarios para reproducir el proceso de integración de datos Olist.
