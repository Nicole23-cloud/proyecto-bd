# Pipeline Medallion — Dataset Olist (Databricks / PySpark)

Pipeline de procesamiento de datos en **Databricks** utilizando **PySpark** y **Spark SQL** bajo una arquitectura **Medallion (Bronze → Silver → Gold)** sobre el dataset de e-commerce de **Olist**.

---

## Estructura del Proyecto

* [`01_BRONZE_OLIST 2026-11-22 17_49_54 (1).ipynb`](./01_BRONZE_OLIST%202026-11-22%2017_49_54%20(1).ipynb) — Ingesta de archivos CSV crudos y persistencia en tablas de la capa **Bronze**.
* [`02_SILVER_OLIST (1).ipynb`](./02_SILVER_OLIST%20(1).ipynb) — Limpieza, estandarización, anonimización/generación de nombres, validación de calidad y guardado de tablas **Silver**.
* [`03_GOLD_OLIST (1).ipynb`](./03_GOLD_OLIST%20(1).ipynb) — Ejecución de la capa Silver (`%run ./02_SILVER_OLIST`), registro de vistas temporales y creación de la vista analítica **`gold_ventas`**.

---

## Flujo de Datos (Arquitectura Medallion)

### 1. Capa Bronze ([`01_BRONZE_OLIST 2026-11-22 17_49_54 (1).ipynb`](./01_BRONZE_OLIST%202026-11-22%2017_49_54%20(1).ipynb))
Lee los archivos CSV desde el volumen `/Volumes/workspace/olist_nuevo/olist/Archivos.csv/Olist_CSV/` con `header=True`, `inferSchema=True` y separador `,`:

* `olist_customers_dataset.csv` → `olist_nuevo.bronze_clientes`
* `olist_orders_dataset.csv` → `olist_nuevo.bronze_pedidos`
* `olist_order_items_dataset.csv` → `olist_nuevo.bronze_detalles`
* `olist_products_dataset.csv` → `olist_nuevo.bronze_productos`
* `olist_sellers_dataset.csv` → `olist_nuevo.bronze_vendedores`
* `olist_category_name_translation_dataset.csv` → `olist_nuevo.bronze_categorias`

---

### 2. Capa Silver ([`02_SILVER_OLIST (1).ipynb`](./02_SILVER_OLIST%20(1).ipynb))
Aplica reglas de limpieza, tipado y enriquecimiento antes de guardar en `workspace.olist_nuevo.silver_*`:

* **Generación determinista de nombres brasileños:** Asigna `nombre_cliente` (por `customer_unique_id`) y `nombre_vendedor` (por `seller_id`) combinando listas de nombres y apellidos mediante `xxhash64` y `pmod`.
* **Clientes (`silver_clientes`):** Elimina duplicados por `customer_id`, descarta nulos/vacíos en claves, normaliza `customer_city` a minúsculas y `customer_state` a mayúsculas con `trim`, y une `nombre_cliente`.
* **Pedidos (`silver_pedidos`):** Filtra únicamente pedidos con `order_status == "delivered"`, convierte `order_purchase_timestamp` a `timestamp` y valida que no sea nulo.
* **Detalles (`silver_detalles`):** Valida claves y rangos (`order_item_id > 0`, `price >= 0`, `freight_value >= 0`), parsea `shipping_limit_date` y conserva solo ítems pertenecientes a pedidos entregados (`left_semi` con `df_pedidos_silver`).
* **Productos (`silver_productos`):** Valida dimensiones y peso no negativos (o nulos), limpia `product_category_name` y renombra `product_name_lenght` → `longitud_nombre_producto` y `product_description_lenght` → `longitud_descripcion_producto`.
* **Vendedores (`silver_vendedores`):** Limpia `seller_id`, normaliza ciudad/estado y agrega `nombre_vendedor`.
* **Categorías (`silver_categorias`):** Deduplica por `product_category_name`, elimina nulos/vacíos y estandariza `product_category_name_english` en minúsculas.
* **Controles de calidad:** Verifica ausencia de nulos en `order_id`, comprueba que no existan duplicados en las claves primarias/compuestas y muestra estadísticas descriptivas y conteos finales.

---

### 3. Capa Gold ([`03_GOLD_OLIST (1).ipynb`](./03_GOLD_OLIST%20(1).ipynb))
* Ejecuta `%run ./02_SILVER_OLIST` y expone los DataFrames Silver como vistas temporales.
* Construye la vista temporal `gold_ventas` mediante `INNER JOIN` entre `silver_detalles`, `silver_pedidos`, `silver_clientes`, `silver_productos`, `silver_vendedores` y `silver_categorias`, filtrando registros con `product_category_name_english IS NOT NULL`.
* **Columnas expuestas:** `order_id`, `order_item_id`, datos del cliente (`customer_id`, `customer_unique_id`, `nombre_cliente`, `customer_city`, `customer_state`), pedido (`order_status`, `order_purchase_timestamp`), producto (`product_id`, `product_category_name`, `product_category_name_english`), vendedor (`seller_id`, `nombre_vendedor`, `seller_city`, `seller_state`) y métricas (`price`, `freight_value`).

---

## Requisitos y Ejecución

1. Subir los notebooks a un workspace de **Databricks** (con acceso a Unity Catalog / volúmenes configurados).
2. Asegurar que los archivos CSV de origen existan en `/Volumes/workspace/olist_nuevo/olist/Archivos.csv/Olist_CSV/`.
3. Ejecutar los notebooks en orden:
   1. [`01_BRONZE_OLIST 2026-11-22 17_49_54 (1).ipynb`](./01_BRONZE_OLIST%202026-11-22%2017_49_54%20(1).ipynb)
   2. [`02_SILVER_OLIST (1).ipynb`](./02_SILVER_OLIST%20(1).ipynb)
   3. [`03_GOLD_OLIST (1).ipynb`](./03_GOLD_OLIST%20(1).ipynb)
