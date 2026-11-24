USE OLIST_DATAMART;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Variante A: Cálculo de participación mensual usando Subconsulta + JOIN
SELECT 
    t.anio,
    t.mes,
    COUNT_BIG(*) AS total_items,
    SUM(f.precio) AS ventas_mes,
    CAST(SUM(f.precio) * 100.0 / (
        SELECT SUM(f2.precio)
        FROM dbo.fact_ventas f2
        INNER JOIN dbo.dim_tiempo t2 ON f2.id_tiempo = t2.id_tiempo
        WHERE t2.anio = t.anio
    ) AS DECIMAL(10, 2)) AS porcentaje_anual
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;
GO

-- 2. Variante B: Mismo cálculo usando Función de Ventana (SUM() OVER)
SELECT 
    t.anio,
    t.mes,
    COUNT_BIG(*) AS total_items,
    SUM(f.precio) AS ventas_mes,
    CAST(SUM(f.precio) * 100.0 / SUM(SUM(f.precio)) OVER (PARTITION BY t.anio) AS DECIMAL(10, 2)) AS porcentaje_anual
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO