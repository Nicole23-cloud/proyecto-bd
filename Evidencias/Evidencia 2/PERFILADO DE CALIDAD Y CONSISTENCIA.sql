USE OLIST_DATABASE;
GO

--PERFILADO DE CALIDAD Y CONSISTENCIA (OLTP)


-- 1. CONTEO Y REVISIÓN DE REGISTROS TOTALES EN EL ORIGEN
SELECT 'olist_customers_dataset' AS Tabla, COUNT_BIG(*) AS Total_Registros FROM dbo.olist_customers_dataset
UNION ALL
SELECT 'olist_products_dataset', COUNT_BIG(*) FROM dbo.olist_products_dataset
UNION ALL
SELECT 'olist_sellers_dataset', COUNT_BIG(*) FROM dbo.olist_sellers_dataset
UNION ALL
SELECT 'olist_orders_dataset', COUNT_BIG(*) FROM dbo.olist_orders_dataset
UNION ALL
SELECT 'olist_order_items_dataset', COUNT_BIG(*) FROM dbo.olist_order_items_dataset;

-- 2. DETECTAR VALORES NULOS EN CAMPOS CLAVE
SELECT 
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS clientes_nulos,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS ciudades_nulas,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS estados_nulos
FROM dbo.olist_customers_dataset;

SELECT 
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS productos_nulos,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS categorias_nulas
FROM dbo.olist_products_dataset;

-- 3. PRUEBA T-01: VALIDACIÓN DE MEDIDAS CUANTITATIVAS EN PEDIDOS ENTREGADOS (RNF-01)
-- Debe devolver 0 en precios_negativos y fletes_negativos
SELECT 
    COUNT_BIG(*) AS total_items_entregados,
    SUM(CASE WHEN i.price < 0 THEN 1 ELSE 0 END) AS precios_negativos,
    SUM(CASE WHEN i.freight_value < 0 THEN 1 ELSE 0 END) AS fletes_negativos,
    SUM(CASE WHEN i.price IS NULL THEN 1 ELSE 0 END) AS precios_nulos,
    SUM(CASE WHEN i.freight_value IS NULL THEN 1 ELSE 0 END) AS fletes_nulos
FROM dbo.olist_order_items_dataset i
INNER JOIN dbo.olist_orders_dataset o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered';