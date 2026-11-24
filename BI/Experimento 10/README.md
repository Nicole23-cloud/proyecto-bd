# Experimento 10 - Consulta histórica completa vs. filtro anual en ventas y fletes (BI - SQL Server)

## 1. Objetivo
Evaluar el comportamiento y el rendimiento de una consulta analítica mensual de ventas y fletes en `OLIST_DATAMART` al ejecutarla sobre todo el periodo histórico frente a filtrarla por un año específico (`WHERE t.anio = 2018`).

## 2. Configuración
| Parámetro | Valor |
|---|---|
| Motor / Plataforma | Microsoft SQL Server (SSMS) |
| Base de datos | `OLIST_DATAMART` |
| Tablas consultadas | `dbo.fact_ventas` y `dbo.dim_tiempo` |
| Variantes comparadas | Variante A: Sin filtro de año (historial completo) \| Variante B: Filtro `WHERE t.anio = 2018` |
| Métricas activadas | `SET STATISTICS IO ON` y `SET STATISTICS TIME ON` |

## 3. Procedimiento
1. Se activaron `STATISTICS IO` y `STATISTICS TIME` en SSMS.
2. Se ejecutó la **Variante A** agrupando por `t.anio` y `t.mes` sobre todo el historial disponible (`23` filas).
3. Se ejecutó la **Variante B** aplicando el filtro `WHERE t.anio = 2018` (`8` filas) y se compararon filas devueltas, lecturas y tiempos.

## 4. Resultados
| Métrica | Variante A (Sin filtro de año) | Variante B (`WHERE t.anio = 2018`) |
|---|---:|---:|
| `logical reads` (`fact_ventas`) | `520` | `520` |
| `Scan count` (`fact_ventas`) | `1` | `1` |
| `logical reads` (`dim_tiempo`) | `5` | `5` |
| `Scan count` (`dim_tiempo`) | `1` | `1` |
| `CPU time` (ms) | `15 ms` | `16 ms` |
| `elapsed time` (ms) | `15 ms` | `14 ms` |
| Filas devueltas | `23` | `8` |

## 5. Comparación y análisis
- **Alcance temporal:** La Variante A devuelve `23` periodos mensuales de todo el historial en `OLIST_DATAMART`, mientras que la Variante B acota la salida a los `8` meses correspondientes a `2018`.
- **Lecturas y tiempos:** Ambas ejecuciones mantienen `520` lecturas lógicas (`Scan count 1`) en `fact_ventas` y `5` lecturas lógicas (`Scan count 1`) en `dim_tiempo`, con tiempos transcurridos muy cercanos (`15 ms` y `14 ms`), mostrando estabilidad y consistencia en el motor.

## 6. Conclusiones
- Filtrar por un año específico (`WHERE t.anio = 2018`) permite acotar la salida analítica a los meses requeridos manteniendo tiempos de respuesta de ~14–15 ms en SQL Server.
- Revisar `STATISTICS IO` y `STATISTICS TIME` confirma la consistencia de las lecturas y tiempos entre ambas consultas.

## 7. Evidencias
- Script SQL: [`SQLQuery10.sql`](SQLQuery10.sql)
- Salida de estadísticas (`STATISTICS IO` / `TIME`): [`Mensajes10`](Mensajes10)
- Captura de ejecución y resultados: [`capturaExperimento 10.jpg`](capturaExperimento%2010.jpg)
