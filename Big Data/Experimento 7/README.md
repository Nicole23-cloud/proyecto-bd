# Experimento 07 - Procesamiento distribuido, filtrado y agregación anual en OLIST (Big Data)

## 1. Objetivo
Evaluar el rendimiento y la consistencia del procesamiento distribuido en Databricks (PySpark) al leer los archivos crudos de pedidos e ítems de Olist desde un volumen de Unity Catalog, filtrar únicamente los pedidos entregados (`delivered`), realizar la unión (`inner join`) y generar una agregación anual de ítems, ventas y fletes (2016–2018).

## 2. Configuración
| Parámetro | Valor |
|---|---|
| Plataforma | Databricks Free Edition (Serverless / PySpark) |
| Origen de datos | Unity Catalog Volume (`/Volumes/workspace/bd26058/experiment`) |
| Datasets evaluados | `olist_orders_dataset.csv` (`99,441` filas) y `olist_order_items_dataset.csv` (`112,650` filas) |
| Regla de filtrado | `order_status == "delivered"` |
| Clave de unión | `order_id` (`inner join`) |
| Medición de tiempos | Módulo `time` (`time.time()`) en segundos |
| Notebook | `Experimento_7_Nb.ipynb` |

## 3. Procedimiento
1. **Lectura e inferencia de esquema.** Se cargaron ambos archivos CSV desde `/Volumes/workspace/bd26058/experiment` con `header=True` e `inferSchema=True`, midiendo el tiempo de lectura y conteo inicial de registros (`99,441` pedidos y `112,650` ítems).
2. **Filtrado y unión (`join`).** Se filtraron los pedidos con estado `delivered` y se realizó un `inner join` por `order_id` contra `df_items` para conservar únicamente los ítems asociados a pedidos entregados.
3. **Agregación anual.** A partir de `order_purchase_timestamp` se extrajo el año (`anio`) y se calcularon el total de ítems entregados, la suma de `price` (`venta_total`) y la suma de `freight_value` (`flete_total`) ordenados cronológicamente.

## 4. Resultados

### 4.1 Tiempos y depuración de registros
| Etapa del flujo | Métrica obtenida |
|---|---|
| Pedidos iniciales (`olist_orders_dataset.csv`) | `99,441` registros |
| Ítems iniciales (`olist_order_items_dataset.csv`) | `112,650` registros |
| Tiempo de lectura + conteo inicial | `3.48 s` |
| Ítems válidos en pedidos `delivered` | `110,197` registros (`97.82 %`) |
| Ítems descartados (estados distintos a `delivered`) | `2,453` registros (`2.18 %`) |
| Tiempo de filtro + join + agregación | `1.20 s` |

### 4.2 Resumen anual de ventas y fletes (pedidos entregados)
| Año | Total ítems entregados | Venta total | Flete total |
|---|---:|---:|---:|
| `2016` | `317` | `40,470.98` | `6,182.76` |
| `2017` | `49,556` | `5,962,902.01` | `958,633.23` |
| `2018` | `60,324` | `7,218,125.12` | `1,233,459.65` |
| **Total (2016–2018)** | **`110,197`** | **`13,221,498.11`** | **`2,198,275.64`** |

## 5. Comparación y análisis
- **Tiempos de ejecución.** La lectura inicial desde CSV con inferencia automática de tipos y conteo tomó `3.48 s`, mientras que la transformación completa (`filter` + `inner join` + `groupBy` anual) se resolvió en `1.20 s` sobre cómputo Serverless de Databricks.
- **Calidad y depuración de datos.** Al cruzar los `112,650` ítems originales contra los pedidos con estado `delivered`, se depuraron `2,453` ítems (`2.18 %`) correspondientes a pedidos cancelados, en tránsito u otros estados no entregados, evitando sobreestimar las ventas reales.
- **Evolución temporal.** Se observa el crecimiento operativo del catálogo entre `2016` (`317` ítems), `2017` (`49,556` ítems) y `2018` (`60,324` ítems).

## 6. Conclusiones
- PySpark en Databricks permite ingestar, filtrar, cruzar y agregar más de 112 mil registros desde archivos CSV crudos en menos de 5 segundos totales (`3.48 s` de lectura y `1.20 s` de transformación).
- Aplicar el filtro `order_status == "delivered"` antes del `join` reduce el volumen de datos a cruzar y garantiza que las métricas anuales reflejen únicamente ventas concretadas.
- Para escenarios de mayor escala o consultas recurrentes, conviene persistir los datasets limpios en tablas Delta dentro de Unity Catalog para evitar el costo de relectura e inferencia de esquema en CSV.

## 7. Evidencias
- Notebook de Databricks: [`Experimento_7_Nb.ipynb`](Experimento_7_Nb.ipynb)
- Primera captura (lectura y conteo inicial): [`primera captura.jpg`](primera%20captura.jpg)
- Segunda captura (filtrado, unión y agregación anual): [`segunda captura.jpg`](segunda%20captura.jpg)
