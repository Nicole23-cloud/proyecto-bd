/* =========================================================
   14. CREAR ROLES DE SEGURIDAD
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'rol_olist_lectura') IS NULL
    EXEC(N'CREATE ROLE rol_olist_lectura');
GO

IF DATABASE_PRINCIPAL_ID(N'rol_olist_carga') IS NULL
    EXEC(N'CREATE ROLE rol_olist_carga');
GO

/* Rol de lectura */

GRANT SELECT ON dbo.dim_producto TO rol_olist_lectura;
GRANT SELECT ON dbo.dim_cliente TO rol_olist_lectura;
GRANT SELECT ON dbo.dim_vendedor TO rol_olist_lectura;
GRANT SELECT ON dbo.dim_tiempo TO rol_olist_lectura;
GRANT SELECT ON dbo.dim_estado_pedido TO rol_olist_lectura;
GRANT SELECT ON dbo.fact_ventas TO rol_olist_lectura;

GRANT SELECT ON dbo.auditoria_etl TO rol_olist_lectura;
GRANT SELECT ON dbo.metricas_etl TO rol_olist_lectura;
GRANT SELECT ON dbo.errores_etl TO rol_olist_lectura;
GO

/* Rol de carga: ejecutar el procedimiento */

GRANT EXECUTE ON dbo.sp_cargar_olist_etl TO rol_olist_carga;
GO

/* =========================================================
   14B. VACIAR LAS TABLAS ANTES DE CARGAR
   Sirve para que el ETL cargue todo desde cero en cada
   ejecucion. Primero la tabla de hechos y luego las dimensiones.
   Si NO quieres vaciar, comenta este bloque.
   ========================================================= */

DELETE FROM dbo.fact_ventas;
DELETE FROM dbo.dim_producto;
DELETE FROM dbo.dim_cliente;
DELETE FROM dbo.dim_vendedor;
DELETE FROM dbo.dim_tiempo;
DELETE FROM dbo.dim_estado_pedido;
GO
