# Pipeline Medallion — Dataset Olist (Databricks / PySpark)

Pipeline de procesamiento de datos en **Databricks** utilizando **PySpark** y **Spark SQL** bajo una arquitectura **Medallion (Bronze → Silver → Gold)** sobre el dataset de e-commerce de **Olist**[cite: 1, 2, 3].

---

## Estructura del Proyecto

* `01_BRONZE_OLIST` — Ingesta de archivos CSV crudos y persistencia en tablas de la capa **Bronze**[cite: 1].
* `02_SILVER_OLIST` — Limpieza, estandarización, anonimización/generación de nombres, validación de calidad y guardado de tablas **Silver**[cite: 2].
* `03_GOLD_OLIST` (o notebook Gold correspondiente) — Ejecución de la capa Silver (`%run ./02_SILVER_OLIST`), registro de vistas temporales y creación de la vista analítica **`gold_ventas`**[cite: 3].

---

## Flujo de Datos (Arquitectura Medallion)

### 1. Capa Bronze (`01_BRONZE_OLIST`)
Lee los archivos CSV desde el volumen `/Volumes/workspace/olist_nuevo/olist/Archivos.csv/Olist_CSV/` con `header=True`, `inferSchema=True` y separador `,`[cite: 1]:

* `olist_customers_dataset.csv` → `olist_nuevo.bronze_clientes`[cite: 1]
* `olist_orders_dataset.csv` → `olist_nuevo.bronze_pedidos`[cite: 1]
* `olist_order_items_dataset.csv` → `olist_nuevo.bronze_detalles`[cite: 1]
* `olist_products_dataset.csv` → `olist_nuevo.bronze_productos`[cite: 1]
* `olist_sellers_dataset.csv` → `olist_nuevo.bronze_vendedores`[cite: 1]
* `olist_category_name_translation_dataset.csv` → `olist_nuevo.bronze_categorias`[cite: 1]

---

### 2. Capa Silver (`02_SILVER_OLIST`)
Aplica reglas de limpieza, tipado y enriquecimiento antes de guardar en `workspace.olist_nuevo.silver_*`[cite: 2]:

* **Generación determinista de nombres brasileños:** Asigna `nombre_cliente` (por `customer_unique_id`) y `nombre_vendedor` (por `seller_id`) combinando listas de nombres y apellidos mediante `xxhash64` y `pmod`[cite: 2].
* **Clientes (`silver_clientes`):** Elimina duplicados por `customer_id`, descarta nulos/vacíos en claves, normaliza `customer_city` a minúsculas y `customer_state` a mayúsculas con `trim`, y une `nombre_cliente`[cite: 2].
* **Pedidos (`silver_pedidos`):** Filtra únicamente pedidos con `order_status == "delivered"`, convierte `order_purchase_timestamp` a `timestamp` y valida que no sea nulo[cite: 2].
* **Detalles (`silver_detalles`):** Valida claves y rangos (`order_item_id > 0`, `price >= 0`, `freight_value >= 0`), parsea `shipping_limit_date` y conserva solo ítems pertenecientes a pedidos entregados (`left_semi` con `df_pedidos_silver`)[cite: 2].
* **Productos (`silver_productos`):** Valida dimensiones y peso no negativos (o nulos), limpia `product_category_name` y renombra `product_name_lenght` → `longitud_nombre_producto` y `product_description_lenght` → `longitud_descripcion_producto`[cite: 2].
* **Vendedores (`silver_vendedores`):** Limpia `seller_id`, normaliza ciudad/estado y agrega `nombre_vendedor`[cite: 2].
* **Categorías (`silver_categorias`):** Deduplica por `product_category_name`, elimina nulos/vacíos y estandariza `product_category_name_english` en minúsculas[cite: 2].
* **Controles de calidad:** Verifica ausencia de nulos en `order_id`, comprueba que no existan duplicados en las claves primarias/compuestas y muestra estadísticas descriptivas y conteos finales[cite: 2].

---

### 3. Capa Gold (Vista `gold_ventas`)
* Ejecuta `%run ./02_SILVER_OLIST` y expone los DataFrames Silver como vistas temporales[cite: 3].
* Construye la vista temporal `gold_ventas` mediante `INNER JOIN` entre `silver_detalles`, `silver_pedidos`, `silver_clientes`, `silver_productos`, `silver_vendedores` y `silver_categorias`, filtrando registros con `product_category_name_english IS NOT NULL`[cite: 3].
* **Columnas expuestas:** `order_id`, `order_item_id`, datos del cliente (`customer_id`, `customer_unique_id`, `nombre_cliente`, `customer_city`, `customer_state`), pedido (`order_status`, `order_purchase_timestamp`), producto (`product_id`, `product_category_name`, `product_category_name_english`), vendedor (`seller_id`, `nombre_vendedor`, `seller_city`, `seller_state`) y métricas (`price`, `freight_value`)[cite: 3].

---

## Requisitos y Ejecución

1. Subir los notebooks a un workspace de **Databricks** (con acceso a Unity Catalog / volúmenes configurados)[cite: 1, 2, 3].
2. Asegurar que los archivos CSV de origen existan en `/Volumes/workspace/olist_nuevo/olist/Archivos.csv/Olist_CSV/`[cite: 1].
3. Ejecutar los notebooks en orden[cite: 1, 2, 3]:
   1. `01_BRONZE_OLIST`[cite: 1]
   2. `02_SILVER_OLIST`[cite: 2]
   3. Notebook **Gold** (que invoca `%run ./02_SILVER_OLIST` y crea `gold_ventas`)[cite: 3]
