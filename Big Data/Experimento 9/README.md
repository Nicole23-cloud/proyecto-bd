# Experimento 09 - Subconsulta correlacionada vs. Función de ventana en participación mensual (BI - SQL Server)

## 1. Objetivo
Evaluar el rendimiento y la consistencia de resultados al calcular el porcentaje de participación mensual de las ventas dentro de cada año en `OLIST_DATAMART` comparando una subconsulta correlacionada frente a una función de ventana (`SUM() OVER (PARTITION BY t.anio)`).

## 2. Configuración
| Parámetro | Valor |
|---|---|
| Motor / Plataforma | Microsoft SQL Server (SSMS) |
| Base de datos | `OLIST_DATAMART` |
| Tablas consultadas | `dbo.fact_ventas` y `dbo.dim_tiempo` |
| Variantes comparadas | Variante A: Subconsulta correlacionada \| Variante B: Función de ventana `OVER` |
| Métricas activadas | `SET STATISTICS IO ON` y `SET STATISTICS TIME ON` |

## 3. Procedimiento
1. Se activaron `STATISTICS IO` y `STATISTICS TIME` en SSMS.
2. Se ejecutó la **Variante A** (subconsulta correlacionada por `anio`) calculando `total_items`, `ventas_mes` y `porcentaje_anual`.
3. Se ejecutó la **Variante B** (función de ventana `SUM(SUM(f.precio)) OVER (PARTITION BY t.anio)`) para el mismo cálculo mensual y se compararon salidas y estadísticas.

## 4. Resultados
| Métrica | Variante A (Subconsulta) | Variante B (Función de ventana `OVER`) |
|---|---|---|
| `logical reads` (`fact_ventas`) | `[completar]` | `[completar]` |
| `Scan count` (`fact_ventas`) | `[completar]` | `[completar]` |
| `CPU time` (ms) | `[completar]` | `[completar]` |
| `elapsed time` (ms) | `[completar]` | `[completar]` |
| Filas devueltas | `[completar]` | `[completar]` |

## 5. Comparación y análisis
- **Consistencia:** Ambas variantes devuelven la misma cantidad de periodos mensuales, montos de venta y porcentajes anuales.
- **Plan y lecturas:** La subconsulta correlacionada evalúa el total anual por subconsulta vinculada al año externo, mientras que la función de ventana calcula el total particionado sobre el agregado de la consulta principal.

## 6. Conclusiones
- Para cálculos de participación porcentual sobre grupos o totales superiores en SQL Server, comparar `subconsulta` frente a `OVER (PARTITION BY ...)` permite verificar cuál enfoque resulta más claro y eficiente en el plan de ejecución.
- Mantener la misma lógica de negocio garantiza exactitud analítica independientemente de la forma en que se exprese el cálculo.

## 7. Evidencias
- Script SQL: `[nombre_del_script.sql]`
- Salida de `Mensajes`: `[Mensajes.txt]`
- Captura de resultados: `[captura_resultados.jpg]`
