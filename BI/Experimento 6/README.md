# Experimento 6 - BI (SQL Server)

Prueba de rendimiento en `OLIST_DATAMART` antes y después de crear el índice no agrupado `IX_fact_ventas_tiempo_producto_inc` en `dbo.fact_ventas`.

- **Lecturas lógicas (`logical reads`) en `fact_ventas`:** bajaron de `1,781` a `520`.
- **Escaneos (`Scan count`) en `fact_ventas`:** bajaron de `13` a `1`.
- **Filas devueltas:** `1,264` filas en ambos casos.
