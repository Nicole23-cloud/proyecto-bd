
USE DATAMART_OLIST;
GO

/* =========================================================
   EVIDENCIA CAF-01: VALIDACION DE LOS 10 KPI DE OLIST
   ========================================================= */


/* KPI 1. INGRESOS TOTALES (R$) */
SELECT
    SUM(precio) AS ingresos_totales
FROM dbo.fact_ventas;
GO


/* KPI 2. ARTICULOS VENDIDOS */
SELECT
    COUNT(*) AS articulos_vendidos
FROM dbo.fact_ventas;
GO


/* KPI 3. PEDIDOS ENTREGADOS */
SELECT
    COUNT(DISTINCT f.id_pedido) AS pedidos_entregados
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_estado_pedido AS e
    ON f.id_estado = e.id_estado
WHERE LOWER(LTRIM(RTRIM(e.estado_pedido))) = 'delivered';
GO


/* KPI 4. TOTAL DE VENDEDORES */
SELECT
    COUNT(*) AS total_vendedores
FROM dbo.dim_vendedor;
GO


/* KPI 5. INGRESOS POR CATEGORIA DE PRODUCTO */
SELECT
    p.categoria_ingles AS categoria,
    SUM(f.precio) AS ingresos_totales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_producto AS p
    ON f.id_producto = p.id_producto
GROUP BY p.categoria_ingles
ORDER BY ingresos_totales DESC;
GO


/* KPI 6. INGRESOS TOTALES POR UBICACION
   Se utiliza el estado del vendedor. */
SELECT
    v.estado AS estado_vendedor,
    SUM(f.precio) AS ingresos_totales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_vendedor AS v
    ON f.id_vendedor = v.id_vendedor
GROUP BY v.estado
ORDER BY ingresos_totales DESC;
GO


/* KPI 7. EVOLUCION MENSUAL DE VENTAS
   Ingresos agrupados por mes. */
SELECT
    YEAR(t.fecha) AS anio,
    MONTH(t.fecha) AS numero_mes,
    SUM(f.precio) AS ingresos_mensuales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_tiempo AS t
    ON f.id_tiempo = t.id_tiempo
GROUP BY
    YEAR(t.fecha),
    MONTH(t.fecha)
ORDER BY
    anio,
    numero_mes;
GO


/* KPI 8. TOP 10 VENDEDORES POR NUMERO DE VENTAS
   Se cuentan pedidos distintos por vendedor. */
SELECT TOP (10)
    v.id_vendedor,
    v.seller_id,
    COUNT(DISTINCT f.id_pedido) AS numero_ventas,
    SUM(f.precio) AS ingresos_totales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_vendedor AS v
    ON f.id_vendedor = v.id_vendedor
GROUP BY
    v.id_vendedor,
    v.seller_id
ORDER BY
    numero_ventas DESC,
    v.id_vendedor;
GO


/* KPI 9. PORCENTAJE DE INGRESOS POR ESTADO */
WITH ingresos_estado AS
(
    SELECT
        v.estado,
        SUM(f.precio) AS ingresos_estado
    FROM dbo.fact_ventas AS f
    INNER JOIN dbo.dim_vendedor AS v
        ON f.id_vendedor = v.id_vendedor
    GROUP BY v.estado
)
SELECT
    estado,
    ingresos_estado,
    CAST(
        100.0 * ingresos_estado
        / NULLIF(SUM(ingresos_estado) OVER (), 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_ventas
FROM ingresos_estado
ORDER BY ingresos_estado DESC;
GO



USE DATAMART_OLIST;
GO

/* =========================================================
   EVIDENCIA CAF-01: VALIDACION DE LOS 10 KPI DE OLIST
   ========================================================= */


/* KPI 1. INGRESOS TOTALES (R$) */
SELECT
    SUM(precio) AS ingresos_totales
FROM dbo.fact_ventas;
GO


/* KPI 2. ARTICULOS VENDIDOS */
SELECT
    COUNT(*) AS articulos_vendidos
FROM dbo.fact_ventas;
GO


/* KPI 3. PEDIDOS ENTREGADOS */
SELECT
    COUNT(DISTINCT f.id_pedido) AS pedidos_entregados
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_estado_pedido AS e
    ON f.id_estado = e.id_estado
WHERE LOWER(LTRIM(RTRIM(e.estado_pedido))) = 'delivered';
GO


/* KPI 4. TOTAL DE VENDEDORES */
SELECT
    COUNT(*) AS total_vendedores
FROM dbo.dim_vendedor;
GO


/* KPI 5. INGRESOS POR CATEGORIA DE PRODUCTO */
SELECT
    p.categoria_ingles AS categoria,
    SUM(f.precio) AS ingresos_totales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_producto AS p
    ON f.id_producto = p.id_producto
GROUP BY p.categoria_ingles
ORDER BY ingresos_totales DESC;
GO


/* KPI 6. INGRESOS TOTALES POR UBICACION
   Se utiliza el estado del vendedor. */
SELECT
    v.estado AS estado_vendedor,
    SUM(f.precio) AS ingresos_totales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_vendedor AS v
    ON f.id_vendedor = v.id_vendedor
GROUP BY v.estado
ORDER BY ingresos_totales DESC;
GO


/* KPI 7. EVOLUCION MENSUAL DE VENTAS
   Ingresos agrupados por mes. */
SELECT
    YEAR(t.fecha) AS anio,
    MONTH(t.fecha) AS numero_mes,
    SUM(f.precio) AS ingresos_mensuales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_tiempo AS t
    ON f.id_tiempo = t.id_tiempo
GROUP BY
    YEAR(t.fecha),
    MONTH(t.fecha)
ORDER BY
    anio,
    numero_mes;
GO


/* KPI 8. TOP 10 VENDEDORES POR NUMERO DE VENTAS
   Se cuentan pedidos distintos por vendedor. */
SELECT TOP (10)
    v.id_vendedor,
    v.seller_id,
    COUNT(DISTINCT f.id_pedido) AS numero_ventas,
    SUM(f.precio) AS ingresos_totales
FROM dbo.fact_ventas AS f
INNER JOIN dbo.dim_vendedor AS v
    ON f.id_vendedor = v.id_vendedor
GROUP BY
    v.id_vendedor,
    v.seller_id
ORDER BY
    numero_ventas DESC,
    v.id_vendedor;
GO


/* KPI 9. PORCENTAJE DE INGRESOS POR ESTADO */
WITH ingresos_estado AS
(
    SELECT
        v.estado,
        SUM(f.precio) AS ingresos_estado
    FROM dbo.fact_ventas AS f
    INNER JOIN dbo.dim_vendedor AS v
        ON f.id_vendedor = v.id_vendedor
    GROUP BY v.estado
)
SELECT
    estado,
    ingresos_estado,
    CAST(
        100.0 * ingresos_estado
        / NULLIF(SUM(ingresos_estado) OVER (), 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_ventas
FROM ingresos_estado
ORDER BY ingresos_estado DESC;
GO


/* KPI 10. VARIACION PORCENTUAL DE INGRESOS
   Respecto al mes inmediatamente anterior. */
WITH ingresos_mensuales AS
(
    SELECT
        YEAR(t.fecha) AS anio,
        MONTH(t.fecha) AS numero_mes,
        SUM(f.precio) AS ingresos
    FROM dbo.fact_ventas AS f
    INNER JOIN dbo.dim_tiempo AS t
        ON f.id_tiempo = t.id_tiempo
    GROUP BY
        YEAR(t.fecha),
        MONTH(t.fecha)
),
comparacion AS
(
    SELECT
        anio,
        numero_mes,
        ingresos,
        LAG(ingresos) OVER (
            ORDER BY anio, numero_mes
        ) AS ingresos_mes_anterior
    FROM ingresos_mensuales
)
SELECT
    anio,
    numero_mes,
    ingresos,
    ingresos_mes_anterior,
    CAST(
        100.0 * (ingresos - ingresos_mes_anterior)
        / NULLIF(ingresos_mes_anterior, 0)
        AS DECIMAL(10,2)
    ) AS variacion_porcentual
FROM comparacion
ORDER BY anio, numero_mes;
GO



WITH ingresos_mensuales AS
(
    SELECT
        YEAR(t.fecha) AS anio,
        MONTH(t.fecha) AS numero_mes,
        SUM(f.precio) AS ingresos_mes
    FROM dbo.fact_ventas AS f
    INNER JOIN dbo.dim_tiempo AS t
        ON f.id_tiempo = t.id_tiempo
    GROUP BY
        YEAR(t.fecha),
        MONTH(t.fecha)
),
comparacion AS
(
    SELECT
        anio,
        numero_mes,
        ingresos_mes,
        LAG(ingresos_mes) OVER (
            ORDER BY anio, numero_mes
        ) AS ingresos_mes_anterior
    FROM ingresos_mensuales
)
SELECT
    anio,
    numero_mes,
    CASE
        WHEN ingresos_mes_anterior IS NULL
             OR ingresos_mes_anterior = 0
        THEN 'N/A'
        ELSE CAST(
            CAST(ingresos_mes AS DECIMAL(18,2))
            AS VARCHAR(30)
        )
    END AS ingresos_mes,
    CASE
        WHEN ingresos_mes_anterior IS NULL
             OR ingresos_mes_anterior = 0
        THEN 'N/A'
        ELSE CONCAT(
            CAST(
                CAST(
                    ((ingresos_mes - ingresos_mes_anterior) * 100.0)
                    / ingresos_mes_anterior
                    AS DECIMAL(10,2)
                ) AS VARCHAR(30)
            ),
            '%'
        )
    END AS variacion_porcentual
FROM comparacion
ORDER BY anio, numero_mes;
GO
---------------------------------------------------------
USE DATAMART_OLIST;
GO

/* 1. VERIFICAR CLAVES DIMENSIONALES VALIDAS */
SELECT
    'id_producto' AS clave,
    COUNT(*) AS registros_sin_dimension
FROM dbo.fact_ventas f
LEFT JOIN dbo.dim_producto d ON f.id_producto = d.id_producto
WHERE d.id_producto IS NULL

UNION ALL

SELECT 'id_vendedor', COUNT(*)
FROM dbo.fact_ventas f
LEFT JOIN dbo.dim_vendedor d ON f.id_vendedor = d.id_vendedor
WHERE d.id_vendedor IS NULL

UNION ALL

SELECT 'id_cliente', COUNT(*)
FROM dbo.fact_ventas f
LEFT JOIN dbo.dim_cliente d ON f.id_cliente = d.id_cliente
WHERE d.id_cliente IS NULL

UNION ALL

SELECT 'id_tiempo', COUNT(*)
FROM dbo.fact_ventas f
LEFT JOIN dbo.dim_tiempo d ON f.id_tiempo = d.id_tiempo
WHERE d.id_tiempo IS NULL

UNION ALL

SELECT 'id_estado', COUNT(*)
FROM dbo.fact_ventas f
LEFT JOIN dbo.dim_estado_pedido d ON f.id_estado = d.id_estado
WHERE d.id_estado IS NULL;
GO

USE DATAMART_OLIST;
GO


/* =====================================================
   2. VALIDAR DUPLICADOS EN LA TABLA DE HECHOS
   Se considera la combinación pedido + número de artículo.
   El resultado esperado es 0 filas.
   ===================================================== */

SELECT
    id_pedido,
    numero_item,
    COUNT(*) AS cantidad
FROM dbo.fact_ventas
GROUP BY
    id_pedido,
    numero_item
HAVING COUNT(*) > 1;
GO


/* 3. VERIFICAR VALORES ECONOMICOS INVALIDOS */
SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN precio IS NULL THEN 1 ELSE 0 END) AS precios_nulos,
    SUM(CASE WHEN precio < 0 THEN 1 ELSE 0 END) AS precios_negativos,
    SUM(CASE WHEN flete IS NULL THEN 1 ELSE 0 END) AS fletes_nulos,
    SUM(CASE WHEN flete < 0 THEN 1 ELSE 0 END) AS fletes_negativos
FROM dbo.fact_ventas;
GO
-------------------------------------------------------------------------


SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

/* KPI 1. INGRESOS TOTALES */
SELECT SUM(precio) AS ingresos_totales
FROM dbo.fact_ventas;
GO

/* KPI 2. ARTICULOS VENDIDOS */
SELECT SUM(cantidad_articulos) AS articulos_vendidos
FROM dbo.fact_ventas;
GO

/* KPI 3. PEDIDOS ENTREGADOS */
SELECT COUNT(DISTINCT id_pedido) AS pedidos_entregados
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_estado_pedido e
    ON f.id_estado = e.id_estado
WHERE LOWER(e.estado_pedido) = 'delivered';
GO

/* KPI 4. TOTAL DE VENDEDORES */
SELECT COUNT(*) AS total_vendedores
FROM dbo.dim_vendedor;
GO

/* KPI 5. INGRESOS POR CATEGORIA */
SELECT
    p.categoria_ingles,
    SUM(f.precio) AS ingresos
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_producto p
    ON f.id_producto = p.id_producto
GROUP BY p.categoria_ingles
ORDER BY ingresos DESC;
GO

/* KPI 6. INGRESOS POR ESTADO DEL VENDEDOR */
SELECT
    v.estado,
    SUM(f.precio) AS ingresos
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_vendedor v
    ON f.id_vendedor = v.id_vendedor
GROUP BY v.estado
ORDER BY ingresos DESC;
GO

/* KPI 7. EVOLUCION MENSUAL DE INGRESOS */
SELECT
    t.año,
    t.mes,
    SUM(f.precio) AS ingresos
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_tiempo t
    ON f.id_tiempo = t.id_tiempo
GROUP BY t.año, t.mes
ORDER BY t.año, t.mes;
GO

/* KPI 8. TOP 10 VENDEDORES POR NUMERO DE PEDIDOS */
SELECT TOP 10
    v.id_vendedor,
    COUNT(DISTINCT f.id_pedido) AS total_pedidos
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_vendedor v
    ON f.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor
ORDER BY total_pedidos DESC;
GO

/* KPI 9. PORCENTAJE DE INGRESOS POR ESTADO */
SELECT
    v.estado,
    SUM(f.precio) AS ingresos_estado,
    CAST(
        100.0 * SUM(f.precio) /
        NULLIF((SELECT SUM(precio)
                FROM dbo.fact_ventas), 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_ingresos
FROM dbo.fact_ventas f
INNER JOIN dbo.dim_vendedor v
    ON f.id_vendedor = v.id_vendedor
GROUP BY v.estado
ORDER BY ingresos_estado DESC;
GO

/* KPI 10. VARIACION MENSUAL DE INGRESOS */
WITH ingresos_mensuales AS (
    SELECT
        t.año,
        t.mes,
        SUM(f.precio) AS ingresos
    FROM dbo.fact_ventas f
    INNER JOIN dbo.dim_tiempo t
        ON f.id_tiempo = t.id_tiempo
    GROUP BY t.año, t.mes
),
variacion AS (
    SELECT
        año,
        mes,
        ingresos,
        LAG(ingresos) OVER (
            ORDER BY año, mes
        ) AS ingresos_mes_anterior
    FROM ingresos_mensuales
)
SELECT
    año,
    mes,
    ingresos,
    ingresos_mes_anterior,
    CASE
        WHEN ingresos_mes_anterior IS NULL
          OR ingresos_mes_anterior = 0
        THEN NULL
        ELSE CAST(
            100.0 * (ingresos - ingresos_mes_anterior)
            / ingresos_mes_anterior
            AS DECIMAL(10,2)
        )
    END AS variacion_porcentual
FROM variacion
ORDER BY año, mes;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
---------------------------------------------------------



-- =====================================================
-- VERIFICACION DE PERMISOS EN OLIST_DATABASE
-- Y DATAMART_OLIST
-- =====================================================

USE OLIST_DATABASE;
GO

PRINT 'PERMISOS EN OLIST_DATABASE';

SELECT
    DB_NAME() AS base_datos,
    USER_NAME(p.grantee_principal_id) AS usuario_o_rol,
    p.permission_name AS permiso,
    p.state_desc AS estado_permiso,
    OBJECT_SCHEMA_NAME(p.major_id) AS esquema,
    OBJECT_NAME(p.major_id) AS objeto
FROM sys.database_permissions AS p
WHERE p.grantee_principal_id > 0
ORDER BY usuario_o_rol, permiso;
GO

-- =====================================================
-- VERIFICACION DE PERMISOS EN DATAMART_OLIST
-- =====================================================

USE DATAMART_OLIST;
GO

PRINT 'PERMISOS EN DATAMART_OLIST';

SELECT
    DB_NAME() AS base_datos,
    USER_NAME(p.grantee_principal_id) AS usuario_o_rol,
    p.permission_name AS permiso,
    p.state_desc AS estado_permiso,
    OBJECT_SCHEMA_NAME(p.major_id) AS esquema,
    OBJECT_NAME(p.major_id) AS objeto
FROM sys.database_permissions AS p
WHERE p.grantee_principal_id > 0
ORDER BY usuario_o_rol, permiso;
GO

-----------------------------------------------------
SELECT @@VERSION AS version_sql_server;

---------------------------------------------------------
USE [DATAMARTT_OLIST];
GO

-- 1. KPI de referencia de la escala 1x
SELECT
    COUNT_BIG(*) AS filas_fact_ventas,
    COUNT(DISTINCT id_pedido) AS total_pedidos,
    SUM(precio) AS ingresos_totales,
    SUM(flete) AS flete_total,
    SUM(precio + flete) AS ingresos_mas_flete,
    COUNT(DISTINCT id_vendedor) AS vendedores,
    COUNT(DISTINCT id_cliente) AS clientes,
    CAST(
        100.0 * SUM(flete) / NULLIF(SUM(precio), 0)
        AS decimal(10,2)
    ) AS porcentaje_flete_sobre_precio
FROM dbo.fact_ventas;
GO
-------------------------------------------------------------------------


USE [DATAMARTT_OLIST];
GO

-- RNF-06: completitud y consistencia de fact_ventas
WITH perfil AS (
    SELECT
        f.id_pedido,
        f.numero_item,
        f.id_producto,
        f.id_vendedor,
        f.id_cliente,
        f.id_tiempo,
        f.id_estado,
        f.precio,
        f.flete,
        f.cantidad_articulos,
        CASE
            WHEN f.id_pedido IS NOT NULL
             AND f.numero_item IS NOT NULL
             AND f.id_producto IS NOT NULL
             AND f.id_vendedor IS NOT NULL
             AND f.id_cliente IS NOT NULL
             AND f.id_tiempo IS NOT NULL
             AND f.id_estado IS NOT NULL
             AND f.precio IS NOT NULL
             AND f.flete IS NOT NULL
             AND f.cantidad_articulos IS NOT NULL
             AND f.precio >= 0
             AND f.flete >= 0
             AND f.cantidad_articulos > 0
             AND p.id_producto IS NOT NULL
             AND v.id_vendedor IS NOT NULL
             AND c.id_cliente IS NOT NULL
             AND t.id_tiempo IS NOT NULL
             AND e.id_estado IS NOT NULL
            THEN 1
            ELSE 0
        END AS fila_valida
    FROM dbo.fact_ventas AS f
    LEFT JOIN dbo.dim_producto AS p
        ON f.id_producto = p.id_producto
    LEFT JOIN dbo.dim_vendedor AS v
        ON f.id_vendedor = v.id_vendedor
    LEFT JOIN dbo.dim_cliente AS c
        ON f.id_cliente = c.id_cliente
    LEFT JOIN dbo.dim_tiempo AS t
        ON f.id_tiempo = t.id_tiempo
    LEFT JOIN dbo.dim_estado_pedido AS e
        ON f.id_estado = e.id_estado
),
resultado AS (
    SELECT
        COUNT_BIG(*) AS total_filas,
        SUM(CAST(fila_valida AS bigint)) AS filas_validas
    FROM perfil
)
SELECT
    total_filas,
    filas_validas,
    total_filas - filas_validas AS filas_con_incidencias,
    CAST(
        100.0 * filas_validas / NULLIF(total_filas, 0)
        AS decimal(6,2)
    ) AS completitud_consistencia_pct,
    CASE
        WHEN 100.0 * filas_validas / NULLIF(total_filas, 0) >= 98
            THEN 'CUMPLE RNF-06'
        ELSE 'NO CUMPLE RNF-06'
    END AS resultado
FROM resultado;
GO
