USE OLIST_DATAMART;
GO

--GENERACIÓN DE DATASET SINTÉTICO ESCALADO (2X)

-- 1. tabla espejo para pruebas de carga a 2x
IF OBJECT_ID('dbo.fact_ventas_2x', 'U') IS NOT NULL
    DROP TABLE dbo.fact_ventas_2x;
GO

CREATE TABLE dbo.fact_ventas_2x (
    id_venta_sintetica INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido VARCHAR(50) NOT NULL,
    numero_item INT NOT NULL,
    id_producto INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_cliente INT NOT NULL,
    id_tiempo INT NOT NULL,
    id_estado INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    flete DECIMAL(10,2) NOT NULL,
    cantidad_articulos INT NOT NULL
);
GO

-- 2. Insertar Volumen Original
INSERT INTO dbo.fact_ventas_2x (id_pedido, numero_item, id_producto, id_vendedor, id_cliente, id_tiempo, id_estado, precio, flete, cantidad_articulos)
SELECT id_pedido, numero_item, id_producto, id_vendedor, id_cliente, id_tiempo, id_estado, precio, flete, cantidad_articulos
FROM dbo.fact_ventas;

-- 3. Duplicar Registros con IDs Sintéticos para alcanzar el Nivel 2x
INSERT INTO dbo.fact_ventas_2x (id_pedido, numero_item, id_producto, id_vendedor, id_cliente, id_tiempo, id_estado, precio, flete, cantidad_articulos)
SELECT 
    CONCAT(id_pedido, '_SINT2X') AS id_pedido,
    numero_item,
    id_producto,
    id_vendedor,
    id_cliente,
    id_tiempo,
    id_estado,
    precio,
    flete,
    cantidad_articulos
FROM dbo.fact_ventas;
GO

-- 4. Verificación del Conteo de Escalado
SELECT 'fact_ventas (1x)' AS Escenario, COUNT_BIG(*) AS Total_Registros FROM dbo.fact_ventas
UNION ALL
SELECT 'fact_ventas_2x (2x)', COUNT_BIG(*) FROM dbo.fact_ventas_2x;
GO