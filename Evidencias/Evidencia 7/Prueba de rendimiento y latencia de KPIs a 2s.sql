USE OLIST_DATAMART;
GO

-- PRUEBA DE RENDIMIENTO Y LATENCIA DE KPIS (< 2s)

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- KPI 1: Ingresos Totales
SELECT SUM(precio) AS Ingresos_Totales 
FROM dbo.fact_ventas;

-- KPI 2: Top 10 Vendedores por Ingresos
SELECT TOP 10 v.nombre_vendedor, SUM(f.precio) AS Total_Vendido
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_vendedor v ON f.id_vendedor = v.id_vendedor
GROUP BY v.nombre_vendedor
ORDER BY Total_Vendido DESC;

-- KPI 3: Ingresos por Categoría de Producto
SELECT p.categoria_ingles, SUM(f.precio) AS Total_Categoria
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_producto p ON f.id_producto = p.id_producto
GROUP BY p.categoria_ingles
ORDER BY Total_Categoria DESC;

-- KPI 4: Evolución Mensual de Ventas
SELECT t.anio, t.mes, SUM(f.precio) AS Ingresos_Mensuales
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;

-- KPI 5: Distribución Geográfica por Estado
SELECT v.estado, SUM(f.precio) AS Ingresos_Estado
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_vendedor v ON f.id_vendedor = v.id_vendedor
GROUP BY v.estado
ORDER BY Ingresos_Estado DESC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO