USE OLIST_DATAMART;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Variante A: Agregación mensual y de fletes sin filtro de año (todo el historial)
SELECT 
    t.anio,
    t.mes,
    COUNT_BIG(*) AS total_items,
    SUM(f.precio) AS total_ventas,
    SUM(f.flete) AS total_fletes
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;
GO

-- 2. Variante B: Misma agregación filtrando un año específico (WHERE t.anio = 2018)
SELECT 
    t.anio,
    t.mes,
    COUNT_BIG(*) AS total_items,
    SUM(f.precio) AS total_ventas,
    SUM(f.flete) AS total_fletes
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
WHERE t.anio = 2018
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO