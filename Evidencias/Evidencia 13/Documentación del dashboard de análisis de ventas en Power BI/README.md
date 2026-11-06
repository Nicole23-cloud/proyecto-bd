# Evidencia 13: Desarrollo del Dashboard de Business Intelligence en Power BI

## 1. Objetivo

Desarrollar un dashboard interactivo en Power BI utilizando la información del DataMart Olist, con la finalidad de analizar el comportamiento de las ventas, los ingresos, los vendedores, las categorías de productos y la distribución geográfica de los pedidos mediante indicadores clave de rendimiento (KPIs) y visualizaciones.

## 2. Descripción

En esta evidencia se desarrolló un dashboard de Business Intelligence en Power BI conectado al modelo dimensional del DataMart Olist.

Se diseñó un panel interactivo que permite visualizar información relevante del negocio mediante tarjetas, gráficos, mapas y filtros dinámicos. Estas visualizaciones facilitan el análisis de los datos y permiten identificar tendencias, comparar resultados y obtener información útil para la toma de decisiones.

## 3. Actividades realizadas

### 3.1. Conexión con el DataMart Olist

Se utilizaron las tablas dimensionales y la tabla de hechos del DataMart para integrar la información necesaria para construir las visualizaciones en Power BI.

Entre las tablas utilizadas se encuentran:

- dim_cliente
- dim_estado_pedido
- dim_producto
- dim_tiempo
- dim_vendedor
- fact_ventas

### 3.2. Implementación de indicadores KPI

Se incorporaron tarjetas para mostrar los principales indicadores del negocio:

- Ingresos Totales: 13.05 millones.
- Artículos Vendidos: 109 mil.
- Pedidos Entregados: 95 mil.
- Total de Vendedores: 3 mil.

Estos indicadores permiten obtener una visión general del rendimiento comercial.

### 3.3. Desarrollo de visualizaciones

Se implementaron diferentes gráficos para analizar la información:

- **Ingresos por categoría de producto:** permite identificar las categorías que generan mayores ingresos.
- **Ingresos totales por estado:** muestra la distribución geográfica de los ingresos mediante un mapa.
- **Evolución mensual de ventas:** permite observar el comportamiento de los ingresos durante los meses.
- **Top 10 vendedores:** identifica a los vendedores con mayores ingresos.
- **Porcentaje de ventas por estado:** representa la participación de las ventas entre los diferentes estados.
- **Variación de ventas por año:** permite comparar los ingresos y sus cambios durante los años analizados.

### 3.4. Implementación de filtros interactivos

Se incorporaron segmentadores para facilitar el análisis de la información:

- Año.
- Estado.
- Categoría de producto.

Estos filtros permiten modificar los datos mostrados en las visualizaciones de acuerdo con los criterios seleccionados.

## 4. Resultados obtenidos

- Se desarrolló un dashboard interactivo en Power BI.
- Se integraron indicadores KPI para el seguimiento del rendimiento comercial.
- Se visualizaron los ingresos por categorías de productos y estados.
- Se identificaron los diez vendedores con mayores ingresos.
- Se representó la evolución mensual y anual de las ventas.
- Se incorporaron filtros para facilitar el análisis dinámico de la información.

## 5. Evidencias de ejecución

Se adjunta la captura de pantalla del dashboard desarrollado en Power BI, donde se muestran los indicadores, gráficos, mapa y filtros implementados.

**Archivo:**
- `E-13.png`

## 6. Conclusión

La Evidencia 13 permitió desarrollar un dashboard de Business Intelligence que transforma los datos almacenados en el DataMart Olist en información visual e interactiva.

Mediante los indicadores KPI, gráficos y filtros implementados en Power BI, se facilita el análisis de las ventas, los ingresos, el comportamiento de los vendedores y la distribución geográfica de los resultados, contribuyendo a una mejor toma de decisiones basada en datos.
