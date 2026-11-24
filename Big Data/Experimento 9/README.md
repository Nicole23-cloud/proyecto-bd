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
| Filas devueltas | `23` filas (periodos mensuales entre 2016 y 2018) |

## 3. Procedimiento
1. Se activaron `STATISTICS IO` y `STATISTICS TIME` en SSMS.
2. Se ejecutó la **Variante A** (subconsulta correlacionada por `anio`) calculando `total_items`, `ventas_mes` y `porcentaje_anual`.
3. Se ejecutó la **Variante B** (función de ventana `SUM(SUM(f.precio)) OVER (PARTITION BY t.anio)`) para el mismo cálculo mensual y se compararon salidas y estadísticas.

## 4. Resultados
| Métrica | Variante A (Subconsulta) | Variante B (Función de ventana `OVER`) | Variación |
|---|---:|---:|---|
| `logical reads` (`fact_ventas`) | `1,040` | `520` | `-50.00 %` (se reduce a la mitad) |
| `Scan count` (`fact_ventas`) | `2` | `1` | `-1` escaneo |
| `logical reads` (`dim_tiempo`) | `10` | `5` | `-50.00 %` |
| `Scan count` (`dim_tiempo`) | `2` | `1` | `-1` escaneo |
| `CPU time` (ms) | `15 ms` | `16 ms` | Equivalente |
| `elapsed time` (ms) | `27 ms` | `14 ms` | `-48.15 %` |
| Filas devueltas | `23` | `23` | Exactamente iguales |

## 5. Comparación y análisis
- **Lecturas y escaneos:** En la Variante A (subconsulta correlacionada), SQL Server necesitó recorrer `fact_ventas` y `dim_tiempo` **dos veces** (`Scan count 2`), generando `1,040` lecturas lógicas en `fact_ventas` y `10` en `dim_tiempo`. Con la función de ventana `OVER` (Variante B), realizó **un solo recorrido** (`Scan count 1`) con `520` lecturas lógicas en `fact_ventas` y `5` en `dim_tiempo`.
- **Tiempo de respuesta y consistencia:** El tiempo transcurrido (`elapsed time`) se redujo casi a la mitad (de `27 ms` a `14 ms`), manteniendo exactamente las mismas `23` filas y los mismos valores de porcentaje anual.

## 6. Conclusiones
- El uso de funciones de ventana (`SUM() OVER (PARTITION BY ...)`) evita escanear dos veces la tabla de hechos y la dimensión de tiempo en cálculos de participación porcentual sobre un grupo superior.
- En consultas analíticas de BI sobre SQL Server, reemplazar subconsultas correlacionadas por funciones de ventana mejora tanto la legibilidad del código como el costo de entrada/salida (`logical reads`).

## 7. Evidencias
- Script SQL: [`Experimento_09.sql`](Experimento_09.sql)
- Salida de estadísticas (`STATISTICS IO` / `TIME`): [`Mensajes.txt`](Mensajes9.txt)
- Captura de ejecución y resultados: [`Captura resultado.jpg`](Captura%20resultado.jpg)
