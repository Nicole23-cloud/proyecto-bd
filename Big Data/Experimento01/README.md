##Experimento de escalabilidad y particionamiento – Olist
Proyecto de Big Data y Business Intelligence · Databricks (PySpark / Spark SQL)
1. Objetivo
Evaluar cómo se comporta la tabla de ventas de Olist al aumentar el volumen de datos (factores x1, x10 y x50) y comparar dos formas de almacenarla: sin partición y particionada por año y mes. Se midieron dos cosas: el tiempo de carga (escritura de la tabla) y el tiempo de respuesta de cuatro consultas analíticas típicas.
2. Datos y metodología
   Tabla base. workspace.olist_nuevo.gold_ventas, con 108 638 filas.
   Replicación. Cada factor se genera con un crossJoin contra spark.range(factor). Para que los pedidos no se repitan, se concatena el número de réplica al order_id, y se derivan las columnas anio y mes a partir de order_purchase_timestamp.
   Tablas generadas. Para cada factor se crean dos tablas Delta:
• exp_ventas_x{factor}: sin partición.
• exp_ventas_x{factor}_part: particionada por anio y mes.
Tiempo de carga. Se midió con time.time() alrededor de cada escritura (saveAsTable en modo overwrite).
Consultas evaluadas. Cada una se ejecutó 3 veces con .collect() y se tomó la mediana en segundos:
• ventas_por_mes: suma de ventas agrupada por año y mes.
• top_categorias: las 10 categorías con más ventas.
• ventas_por_estado: pedidos distintos (COUNT(DISTINCT order_id)) y ventas por estado del cliente.
• filtro_periodo: conteo y ventas filtrando anio = 2018 AND mes = 1.
3. Resultados

