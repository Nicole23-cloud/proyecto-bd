# Evidencia 14: Despliegue y Demostración Funcional del Dashboard en Power BI

**Proyecto:** Integración de Datos Olist – Solución BI  
**Base de datos:** OLIST_DATAMART  
**Herramientas:** SQL Server Management Studio (SSMS) y Power BI Desktop.

## 1. Objetivo

Documentar el despliegue y funcionamiento del dashboard desarrollado en Power BI, conectado al Data Mart OLIST_DATAMART, permitiendo visualizar indicadores clave de ventas, ingresos, productos, vendedores y distribución geográfica.

## 2. Requisitos previos

- Microsoft SQL Server 2019 o superior.
- SQL Server Management Studio (SSMS).
- Power BI Desktop.
- Base de datos OLIST_DATAMART creada y poblada mediante el proceso ETL.
- Archivo OLIST.pbix.

## 3. Procedimiento de despliegue

**Paso 1. Verificación de la base de datos**

Ingresar a SQL Server Management Studio y comprobar que la base de datos OLIST_DATAMART se encuentre creada y contenga las tablas dimensionales y la tabla de hechos.

**Paso 2. Apertura del dashboard**

Abrir el archivo OLIST.pbix mediante Power BI Desktop.

**Paso 3. Configuración del origen de datos**

Verificar que la conexión del informe apunte al servidor SQL Server local y a la base de datos OLIST_DATAMART.

**Paso 4. Actualización de información**

Actualizar los datos del informe para recuperar la información almacenada en el Data Mart y comprobar que los indicadores se visualicen correctamente.

**Paso 5. Visualización del dashboard**

Comprobar el funcionamiento de los indicadores, gráficos y filtros interactivos del informe.

## 4. Componentes del Dashboard

El dashboard presenta los siguientes elementos:

- **Ingresos Totales:** muestra el importe total generado por las ventas.
- **Artículos Vendidos:** representa la cantidad de artículos comercializados.
- **Pedidos Entregados:** muestra el número de pedidos entregados.
- **Total Vendedores:** presenta la cantidad de vendedores registrados.
- **Ingresos por Categoría de Producto:** permite comparar los ingresos según las categorías.
- **Distribución Geográfica:** representa los ingresos por ubicación geográfica.
- **Evolución Mensual de Ventas:** permite analizar el comportamiento de los ingresos a lo largo del tiempo.
- **Top 10 Vendedores:** identifica a los vendedores con mayores ingresos.
- **Porcentaje de Ventas por Estado:** muestra la distribución de las ventas por estado.
- **Variación de Ventas:** permite comparar el comportamiento de las ventas entre años.

## 5. Demostración funcional

Se verificó la presentación de los indicadores y gráficos del dashboard, así como la disponibilidad de filtros por año, estado y categoría de producto, permitiendo realizar análisis dinámicos de la información comercial.

## 6. Resultado obtenido

Se logró desplegar el dashboard de Power BI conectado al Data Mart OLIST_DATAMART, permitiendo visualizar y analizar los principales indicadores de rendimiento comercial mediante gráficos, tarjetas e información interactiva.

## 7. Evidencias

- Captura del dashboard desplegado en Power BI Desktop.
- Archivo PBIX correspondiente al informe desarrollado.
- Manual de despliegue y demostración funcional.
