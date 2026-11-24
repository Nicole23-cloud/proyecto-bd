# 01. Experimento de escalabilidad y particionamiento - OLIST (Big Data)

## 1. Objetivo

Evaluar cómo se comporta la tabla de ventas de Olist al aumentar el volumen de datos (factores x1, x10 y x50) y comparar dos formas de almacenarla: sin partición y particionada por año y mes. Se midieron el tiempo de carga (escritura de la tabla) y el tiempo de respuesta de cuatro consultas analíticas típicas.

## 2. Configuración

| Parámetro | Valor |
|---|---|
| Plataforma | Databricks (PySpark / Spark SQL) |
| Formato de las tablas | Delta |
| Tabla base | `workspace.olist_nuevo.gold_ventas` |
| Filas de la tabla base | 108 638 |
| Factores de volumen | x1, x10 y x50 |
| Variantes por factor | Sin partición y particionada por `anio`, `mes` (sufijo `_part`) |
| Repeticiones por consulta | 3 (se reporta la mediana, en segundos) |
| Notebook | `Experi01.ipynb` |

## 3. Procedimiento

1. **Replicación.** Cada factor se genera con un `crossJoin` contra `spark.range(factor)`. Para que los pedidos no se repitan, se concatena el número de réplica al `order_id`, y se derivan las columnas `anio` y `mes` a partir de `order_purchase_timestamp`.
2. **Creación de tablas.** Para cada factor se crean dos tablas:
   - `exp_ventas_x{factor}`: sin partición.
   - `exp_ventas_x{factor}_part`: particionada por `anio` y `mes`.
3. **Tiempo de carga.** Se midió con `time.time()` alrededor de cada escritura (`saveAsTable` en modo `overwrite`).
4. **Consultas evaluadas.** Cada una se ejecutó 3 veces con `.collect()` y se tomó la mediana:
   - `ventas_por_mes`: suma de ventas agrupada por año y mes.
   - `top_categorias`: las 10 categorías con más ventas.
   - `ventas_por_estado`: pedidos distintos (`COUNT(DISTINCT order_id)`) y ventas por estado del cliente.
   - `filtro_periodo`: conteo y ventas filtrando `anio = 2018 AND mes = 1`.
5. **Almacenamiento.** Se consultó `DESCRIBE DETAIL` de cada tabla para obtener número de archivos y tamaño.


*Figura 1. Código de replicación y carga de tablas.*

## 4. Resultados

### 4.1 Tiempo de carga (segundos)

| Factor | Sin partición | Particionada |
|---|---|---|
| x1 | 12.4 | 5.2 |
| x10 | 4.4 | 5.2 |
| x50 | 8.1 | 8.0 |



*Figura 2. Tiempos de carga por factor y tipo de tabla.*

### 4.2 Tiempo de consulta (mediana, segundos)

| Consulta | x1 | x1_part | x10 | x10_part | x50 | x50_part |
|---|---|---|---|---|---|---|
| filtro_periodo | 0.57 | 0.55 | 0.57 | 0.53 | 0.61 | 0.53 |
| top_categorias | 0.59 | 0.63 | 0.59 | 0.61 | 0.65 | 0.62 |
| ventas_por_estado | 0.62 | 0.68 | 0.74 | 0.78 | 1.23 | 1.14 |
| ventas_por_mes | 0.64 | 0.67 | 0.57 | 0.62 | 0.64 | 0.62 |



*Figura 3. Mediana de tiempos de consulta por tabla.*

### 4.3 Almacenamiento (`DESCRIBE DETAIL`)

| Tabla | N.º de archivos | Tamaño (MB) | Particiones |
|---|---|---|---|
| exp_ventas_x1 | 1 | 7.9 | - |
| exp_ventas_x1_part | 23 | 9.7 | anio, mes |
| exp_ventas_x10 | 1 | 14.2 | - |
| exp_ventas_x10_part | 23 | 16.6 | anio, mes |
| exp_ventas_x50 | 1 | 42.4 | - |
| exp_ventas_x50_part | 23 | 24.6 | anio, mes |



*Figura 4. Resultado de `DESCRIBE DETAIL` para las seis tablas.*

## 5. Comparación y análisis

**Carga.** No se observa una tendencia clara entre sin partición y particionada. El valor de 12.4 s en x1 sin partición es probablemente un efecto de arranque en frío del clúster (primera escritura de la sesión) y no del método. Desde x10 los tiempos son similares: 4.4 s frente a 5.2 s, y 8.1 s frente a 8.0 s.

**Consultas.** Los tiempos se mantienen casi planos (entre 0.53 s y 0.78 s) aunque el volumen crece 50 veces. La excepción es `ventas_por_estado`, que pasa de 0.62 s a 1.23 s en x50 sin partición (1.14 s con partición). Es la consulta más costosa porque combina `COUNT(DISTINCT)` con agrupación, lo que exige más movimiento de datos entre nodos.

**Efecto de la partición.** La única consulta que se beneficia de forma consistente es `filtro_periodo`, ya que el filtro por `anio` y `mes` coincide con las columnas de partición y Spark solo lee las carpetas necesarias: en x50 baja de 0.61 s a 0.53 s. En las demás consultas la diferencia es mínima, y en algunos casos la tabla particionada es un poco más lenta (por ejemplo, `ventas_por_estado` en x10: 0.78 s frente a 0.74 s), porque debe leer 23 archivos pequeños en lugar de uno.

**Almacenamiento.** En x1 y x10 la versión particionada ocupa más espacio (9.7 MB frente a 7.9 MB, y 16.6 MB frente a 14.2 MB) por la sobrecarga de dividir en 23 archivos. En x50 ocurre lo contrario: 24.6 MB frente a 42.4 MB. Esto debe interpretarse con cautela, porque los datos replicados son repetitivos y se comprimen distinto según cómo se agrupen en archivos, por lo que no representan necesariamente un crecimiento real de datos.

## 6. Conclusiones

- Con hasta unos 5.4 millones de filas (x50), el volumen sigue siendo pequeño para Spark: los tiempos de consulta casi no crecen y el costo fijo del motor domina sobre el volumen de datos.
- Particionar por `anio` y `mes` solo conviene cuando las consultas filtran por período. Para consultas de agregación global no aporta mejora y añade archivos pequeños.
- `ventas_por_estado` es la consulta que mejor anticipa los problemas de escalabilidad, por lo que conviene vigilarla si el volumen sigue creciendo.
- Para obtener conclusiones más firmes se recomienda repetir el experimento con factores mayores (por ejemplo x100 o x500), descartar la primera ejecución como calentamiento y aumentar el número de repeticiones por consulta.

## 7. Evidencias

- Notebook: [`Experi01.ipynb`](Experi01.ipynb)

