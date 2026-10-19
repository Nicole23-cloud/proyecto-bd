USE OLIST_DATAMART;
GO

-- EVIDENCIA DE DUPLICADOS

SELECT 
    id_pedido, 
    numero_item, 
    COUNT(*) AS numero_duplicados
FROM dbo.fact_ventas
GROUP BY id_pedido, numero_item
HAVING COUNT(*) > 1;