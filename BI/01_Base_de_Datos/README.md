# 01. Base de Datos - OLIST

## 1. Descripción

Esta carpeta contiene los scripts SQL utilizados para la creación, configuración y preparación de la base de datos del proyecto Business Intelligence basado en el conjunto de datos OLIST.

La base de datos permite almacenar y organizar la información necesaria para realizar procesos de integración, análisis y visualización de datos comerciales.

## 2. Objetivo

Diseñar e implementar una estructura de DataMart que permita organizar la información de ventas de OLIST, facilitando el análisis de datos y la generación de indicadores para la toma de decisiones.

## 3. Tecnologías utilizadas

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Lenguaje SQL / T-SQL
- Modelo dimensional
- GitHub para el control de versiones

## 4. Contenido de la carpeta

| Archivo | Descripción |
|---|---|
| `OLIST_TABLAS_DATAMART.sql` | Script para la creación y configuración de las tablas dimensionales y la tabla de hechos del DataMart. |

## 5. Modelo dimensional

El DataMart utiliza un modelo dimensional compuesto por tablas de dimensiones y una tabla de hechos.

### Dimensiones

- `dim_producto`: almacena información de los productos.
- `dim_cliente`: contiene información de los clientes.
- `dim_vendedor`: almacena información de los vendedores.
- `dim_tiempo`: permite analizar las ventas por fechas.
- `dim_estado_pedido`: contiene información sobre los estados de los pedidos.

### Tabla de hechos

- `fact_ventas`: almacena los registros de ventas y las métricas necesarias para el análisis comercial.

## 6. Proceso de implementación

1. Crear o seleccionar la base de datos del DataMart.
2. Ejecutar el script de creación de tablas.
3. Verificar la estructura de las dimensiones y la tabla de hechos.
4. Comprobar las claves primarias y relaciones entre las tablas.
5. Preparar la base de datos para el proceso ETL.

## 7. Resultado esperado

Contar con una base de datos estructurada y preparada para recibir los datos transformados del dataset OLIST, permitiendo su posterior análisis mediante herramientas de Business Intelligence.

## 8. Responsable

Proyecto académico de Business Intelligence - OLIST.
