USE OLIST_DATAMART;
GO

-- Verifica que no existan valores NULL en campos clave
SELECT 
    'dim_cliente' AS tabla_evaluada,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN nombre_cliente IS NULL THEN 1 ELSE 0 END) AS nulos_nombre,
    SUM(CASE WHEN ciudad IS NULL THEN 1 ELSE 0 END) AS nulos_ciudad,
    SUM(CASE WHEN estado IS NULL THEN 1 ELSE 0 END) AS nulos_estado,
    CAST((1.0 - (SUM(CASE WHEN nombre_cliente IS NULL OR ciudad IS NULL OR estado IS NULL THEN 1 ELSE 0 END) * 1.0 / COUNT(*))) * 100 AS DECIMAL(5,2)) AS porcentaje_completitud
FROM dbo.dim_cliente

UNION ALL

SELECT 
    'dim_vendedor' AS tabla_evaluada,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN nombre_vendedor IS NULL THEN 1 ELSE 0 END) AS nulos_nombre,
    SUM(CASE WHEN ciudad IS NULL THEN 1 ELSE 0 END) AS nulos_ciudad,
    SUM(CASE WHEN estado IS NULL THEN 1 ELSE 0 END) AS nulos_estado,
    CAST((1.0 - (SUM(CASE WHEN nombre_vendedor IS NULL OR ciudad IS NULL OR estado IS NULL THEN 1 ELSE 0 END) * 1.0 / COUNT(*))) * 100 AS DECIMAL(5,2)) AS porcentaje_completitud
FROM dbo.dim_vendedor

UNION ALL

SELECT 
    'fact_ventas' AS tabla_evaluada,
    COUNT(*) AS total_registros,
    SUM(CASE WHEN precio IS NULL THEN 1 ELSE 0 END) AS nulos_precio,
    SUM(CASE WHEN flete IS NULL THEN 1 ELSE 0 END) AS nulos_flete,
    0 AS nulos_tercero,
    CAST((1.0 - (SUM(CASE WHEN precio IS NULL OR flete IS NULL THEN 1 ELSE 0 END) * 1.0 / COUNT(*))) * 100 AS DECIMAL(5,2)) AS porcentaje_completitud
FROM dbo.fact_ventas;