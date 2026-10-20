USE OLIST_DATAMART;
GO


-- 1. CONTEO GENERAL DE REGISTROS POR TABLA

SELECT 'dim_producto' AS Tabla, COUNT(*) AS Total_Registros FROM dbo.dim_producto
UNION ALL
SELECT 'dim_cliente', COUNT(*) FROM dbo.dim_cliente
UNION ALL
SELECT 'dim_vendedor', COUNT(*) FROM dbo.dim_vendedor
UNION ALL
SELECT 'dim_tiempo', COUNT(*) FROM dbo.dim_tiempo
UNION ALL
SELECT 'dim_estado_pedido', COUNT(*) FROM dbo.dim_estado_pedido
UNION ALL
SELECT 'fact_ventas', COUNT(*) FROM dbo.fact_ventas;


-- 2. VISTA PREVIA DE LAS DIMENSIONES

-- Validar productos y categorías traducidas
SELECT TOP 5 id_producto, product_id, categoria_original, categoria_ingles 
FROM dbo.dim_producto;

-- Validar que los clientes tengan su nombre sintético generado
SELECT TOP 5 id_cliente, customer_id, nombre_cliente, ciudad, estado 
FROM dbo.dim_cliente;

-- Validar que los vendedores tengan su nombre sintético generado
SELECT TOP 5 id_vendedor, seller_id, nombre_vendedor, ciudad, estado 
FROM dbo.dim_vendedor;

-- Validar dimensión tiempo y clave sustituta (YYYYMMDD)
SELECT TOP 5 id_tiempo, fecha, dia, mes, trimestre, anio 
FROM dbo.dim_tiempo 
ORDER BY fecha ASC;


-- 3. INTEGRIDAD REFERENCIAL (VERIFICAR REGISTROS HUÉRFANOS)

-- Esta consulta debe devolver 0 en todos los campos
SELECT 
    COUNT(CASE WHEN p.id_producto IS NULL THEN 1 END) AS productos_sin_dimension,
    COUNT(CASE WHEN c.id_cliente IS NULL THEN 1 END) AS clientes_sin_dimension,
    COUNT(CASE WHEN v.id_vendedor IS NULL THEN 1 END) AS vendedores_sin_dimension,
    COUNT(CASE WHEN t.id_tiempo IS NULL THEN 1 END) AS tiempos_sin_dimension,
    COUNT(CASE WHEN e.id_estado IS NULL THEN 1 END) AS estados_sin_dimension
FROM dbo.fact_ventas f
LEFT JOIN dbo.dim_producto p ON f.id_producto = p.id_producto
LEFT JOIN dbo.dim_cliente c ON f.id_cliente = c.id_cliente
LEFT JOIN dbo.dim_vendedor v ON f.id_vendedor = v.id_vendedor
LEFT JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
LEFT JOIN dbo.dim_estado_pedido e ON f.id_estado = e.id_estado;


-- 4. COMPARACIÓN DE TOTALES (ORIGEN VS DESTINO)

-- Comprobar que no hay discrepancias de ventas entre ambas bases
SELECT 
    'ORIGEN (OLIST_DATABASE)' AS Capa,
    COUNT(*) AS Total_Items,
    ROUND(SUM(i.price), 2) AS Venta_Total,
    ROUND(SUM(i.freight_value), 2) AS Flete_Total
FROM OLIST_DATABASE.dbo.olist_order_items_dataset i
INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'

UNION ALL

SELECT 
    'DESTINO (OLIST_DATAMART)' AS Capa,
    COUNT(*) AS Total_Items,
    ROUND(SUM(precio), 2) AS Venta_Total,
    ROUND(SUM(flete), 2) AS Flete_Total
FROM dbo.fact_ventas;


-- 5. CONSULTA MULTIDIMENSIONAL DE PRUEBA (ESQUEMA EN ESTRELLA)
--------------------------------------------------------------
-- Reporte de las 10 mayores ventas uniendo todas las dimensiones
SELECT TOP 10
    f.id_pedido,
    t.fecha,
    c.nombre_cliente,
    c.ciudad AS ciudad_cliente,
    v.nombre_vendedor,
    v.ciudad AS ciudad_vendedor,
    p.categoria_ingles,
    f.precio,
    f.flete,
    (f.precio + f.flete) AS total_operacion
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_cliente c ON f.id_cliente = c.id_cliente
INNER JOIN dbo.dim_vendedor v ON f.id_vendedor = v.id_vendedor
INNER JOIN dbo.dim_producto p ON f.id_producto = p.id_producto
INNER JOIN dbo.dim_tiempo t ON f.id_tiempo = t.id_tiempo
INNER JOIN dbo.dim_estado_pedido e ON f.id_estado = e.id_estado
ORDER BY f.precio DESC;

USE OLIST_DATAMART;
GO

--------------------------------------------------------------
-- 1. DIMENSIÓN PRODUCTO COMPLETA
--------------------------------------------------------------
SELECT * 
FROM dbo.dim_producto;

--------------------------------------------------------------
-- 2. DIMENSIÓN CLIENTE COMPLETA
--------------------------------------------------------------
SELECT * 
FROM dbo.dim_cliente;

--------------------------------------------------------------
-- 3. DIMENSIÓN VENDEDOR COMPLETA
--------------------------------------------------------------
SELECT * 
FROM dbo.dim_vendedor;

--------------------------------------------------------------
-- 4. DIMENSIÓN TIEMPO COMPLETA
--------------------------------------------------------------
SELECT * 
FROM dbo.dim_tiempo;

--------------------------------------------------------------
-- 5. DIMENSIÓN ESTADO DE PEDIDO COMPLETA
--------------------------------------------------------------
SELECT * 
FROM dbo.dim_estado_pedido;

--------------------------------------------------------------
-- 6. TABLA DE HECHOS VENTAS COMPLETA
--------------------------------------------------------------
SELECT * 
FROM dbo.fact_ventas;