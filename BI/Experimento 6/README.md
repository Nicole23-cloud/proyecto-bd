# Experimento 06 - Optimización con índice en consulta analítica (BI - SQL Server)

## 1. Objetivo
Evaluar el impacto en el rendimiento de una consulta analítica agregada sobre el Data Mart de Olist (`OLIST_DATAMART`) al crear un índice no agrupado con columnas incluidas (`IX_fact_ventas_tiempo_producto_inc`) sobre la tabla de hechos `dbo.fact_ventas`, verificando las lecturas lógicas, el conteo de escaneos y la consistencia de los resultados.

## 2. Configuración
| Parámetro | Valor |
|---|---|
| Motor / Plataforma | Microsoft SQL Server (SSMS) |
| Base de datos | `OLIST_DATAMART` |
| Tabla principal | `dbo.fact_ventas` (junto con `dbo.dim_producto` y `dbo.dim_tiempo`) |
| Índice evaluado | `IX_fact_ventas_tiempo_producto_inc` en `(id_tiempo, id_producto)` con `INCLUDE` |
| Métricas activadas | `SET STATISTICS IO ON` y `SET STATISTICS TIME ON` |
| Filas devueltas | `1,264` filas (antes y después del índice) |

## 3. Procedimiento
1. **Línea base.** Se activaron `STATISTICS IO` y `STATISTICS TIME` y se ejecutó la consulta analítica agrupada por año, mes y categoría (`ISNULL(p.categoria_ingles, 'sin_categoria')`) uniendo `fact_ventas`, `dim_producto` y `dim_tiempo`.
2. **Creación del índice.** Se creó el índice no agrupado `IX_fact_ventas_tiempo_producto_inc` en `dbo.fact_ventas` sobre `(id_tiempo, id_producto)` incluyendo columnas de ventas/flete/cantidad.
3. **Medición posterior.** Se volvió a ejecutar la misma consulta y se compararon las lecturas lógicas (`logical reads`), el número de escaneos (`Scan count`), el tiempo de CPU y el número total de filas devueltas (`1,264`).

## 4. Resultados
| Métrica en `dbo.fact_ventas` | Antes del índice | Después del índice | Variación |
|---|---|---|---|
| Lecturas lógicas (`logical reads`) | `1,781` | `520` | `-1,261` (`-70.80 %`) |
| Escaneos (`Scan count`) | `13` | `1` | `-12` (`-92.31 %`) |
| Tiempo de CPU (`CPU time`) | `249 ms` | `~93–94 ms` | Reducción significativa |
| Filas devueltas | `1,264` | `1,264` | Sin cambios (consistente) |

## 5. Comparación y análisis
- **Lecturas y escaneos.** Al incorporar el índice `IX_fact_ventas_tiempo_producto_inc`, las lecturas lógicas sobre `dbo.fact_ventas` bajaron de `1,781` a `520` y el `Scan count` pasó de `13` a `1`, reduciendo la cantidad de páginas leídas y el trabajo de recorrido.
- **Consistencia de datos.** La consulta mantuvo exactamente las mismas `1,264` filas y los mismos montos agregados antes y después del cambio, confirmando que la optimización no altera el resultado analítico.
- **Tiempo de procesamiento.** El `CPU time` bajó de `249 ms` a alrededor de `93–94 ms` en las ejecuciones posteriores, reflejando menor esfuerzo de cómputo para resolver la unión y agregación.

## 6. Conclusiones
- Agregar un índice no agrupado con columnas incluidas (`INCLUDE`) alineado con las claves de unión (`id_tiempo`, `id_producto`) y las columnas agregadas mejora de forma clara las lecturas lógicas y los escaneos en `OLIST_DATAMART`.
- Es recomendable validar este tipo de índices en consultas analíticas frecuentes antes de aplicarlos de forma masiva, considerando el costo de mantenimiento en escrituras.

## 7. Evidencias
- Script SQL y capturas de `Resultados` y `Mensajes` (antes y después del índice) en esta carpeta.
