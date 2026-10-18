--E-02

USE OLIST_DATABASE;
GO

SELECT 
    COUNT_BIG(*) AS total_registros_origen,
    SUM(CASE WHEN i.price < 0 THEN 1 ELSE 0 END) AS precios_negativos,
    SUM(CASE WHEN i.freight_value < 0 THEN 1 ELSE 0 END) AS fletes_negativos
FROM dbo.olist_order_items_dataset i
INNER JOIN dbo.olist_orders_dataset o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered';