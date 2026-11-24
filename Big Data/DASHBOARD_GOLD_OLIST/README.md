# Dashboard AI/BI — Capa Gold Olist (`03_GOLD_OLIST`)

Definición exportada de un tablero **Databricks AI/BI (Lakeview)** (`*.lvdash.json`) construido sobre las tablas y métricas analíticas del pipeline Olist.

---

## Contenido de la Carpeta

* [`Dashboard from _03_GOLD_OLIST_ 2026-11-24 09_45_01.lvdash (1).json`](./Dashboard%20from%20_03_GOLD_OLIST_%202026-11-24%2009_45_01.lvdash%20(1).json) — Especificación JSON del dashboard con consultas SQL (`datasets`) y diseño visual de widgets (`pages` / `layout`).

---

## Métricas y Visualizaciones Incluidas

El tablero organiza sus componentes visuales (contadores KPI, gráficos de barras, líneas, área y mapa de símbolos) a partir de consultas sobre `workspace.olist_nuevo.silver_*` y tablas/consultas de KPIs en `default`:

* **Ingresos Totales:** Suma redondeada del precio (`SUM(d.price)`) para registros con categoría traducida válida (`product_category_name_english IS NOT NULL`), además de definición de `default.gold_kpi_01_ingresos_totales`.
* **Top 10 Vendedores por Ingresos:** Ranking de los 10 vendedores con mayor facturación (`nombre_vendedor` e `ingresos_totales`), incluyendo consulta de creación de `default.gold_kpi_02_top_vendedores`.
* **Top 10 Categorías por Ingresos:** Ranking de las 10 categorías en inglés (`product_category_name_english`) con mayores ingresos.
* **Evolución Mensual de Ingresos:** Serie temporal mensual (`fecha_mes`, `etiqueta_mes`, `ingresos_totales`) ordenada cronológicamente.
* **Variación Mensual de Ingresos (%):** Comparación mes contra mes (`ingresos_actuales`, `ingresos_anteriores`, `diferencia_ingresos` y `variacion_porcentual`), junto con definición de `default.gold_kpi_05_variacion_mensual`.
* **Distribución Geográfica por Estado:** Coordenadas de latitud y longitud de los 27 estados brasileños (`UF`) asociadas a los ingresos por estado para visualización en mapa.
* **Totales Operativos:** Contadores de `total_vendedores` (y definición de `default.gold_kpi_07_total_vendedores`) y `total_pedidos_entregados` (`order_status = 'delivered'`).
* **Porcentaje de Ventas por Estado:** Gráfico de barras adicional que calcula participación porcentual de ingresos por estado (con consulta de origen `ef.ventas`).

---

## Cómo Importar y Usar en Databricks

1. Asegurar que las tablas requeridas (`silver_*` en `workspace.olist_nuevo` y tablas de KPIs en `default`) existan y estén actualizadas tras ejecutar los notebooks de Bronze, Silver y Gold.
2. En **Databricks**, ir a **Dashboards** → **Create dashboard** / **Import** y seleccionar [`Dashboard from _03_GOLD_OLIST_ 2026-11-24 09_45_01.lvdash (1).json`](./Dashboard%20from%20_03_GOLD_OLIST_%202026-11-24%2009_45_01.lvdash%20(1).json).
3. Asociar un **SQL Warehouse** activo y revisar las consultas de los datasets antes de publicar o refrescar los widgets.
