
USE DATAMARTT_OLIST;
GO

SET NOCOUNT ON;
GO

/* =========================================================
   1. TABLA DE AUDITORIA
   ========================================================= */

IF OBJECT_ID(N'dbo.auditoria_etl', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.auditoria_etl
    (
        id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
        fecha_inicio DATETIME2 NOT NULL,
        fecha_fin DATETIME2 NULL,
        estado NVARCHAR(30) NOT NULL,
        filas_procesadas BIGINT NOT NULL DEFAULT 0,
        mensaje NVARCHAR(MAX) NULL
    );
END;
GO

/* =========================================================
   2. TABLA DE ERRORES
   ========================================================= */

IF OBJECT_ID(N'dbo.errores_etl', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.errores_etl
    (
        id_error INT IDENTITY(1,1) PRIMARY KEY,
        id_auditoria INT NULL,
        fecha_error DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        procedimiento NVARCHAR(200) NULL,
        mensaje_error NVARCHAR(MAX) NULL,
        numero_error INT NULL,
        linea_error INT NULL
    );
END;
GO

/* =========================================================
   3. TABLA DE METRICAS
   ========================================================= */

IF OBJECT_ID(N'dbo.metricas_etl', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.metricas_etl
    (
        id_metrica INT IDENTITY(1,1) PRIMARY KEY,
        id_auditoria INT NOT NULL,
        nombre_tabla NVARCHAR(128) NOT NULL,
        metrica NVARCHAR(150) NOT NULL,
        valor DECIMAL(18,2) NULL,
        fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

/* =========================================================
   PERF COUNTER (secciones 1, 2 y 3 de tu script, tal cual)
   ========================================================= */

-- =====================================================================
-- PERF COUNTER para el ETL de Olist (SQL Server)
-- Mide por paso: duracion, filas, CPU, lecturas y escrituras
-- y toma un snapshot de contadores del servidor antes y despues.
-- Requiere permiso VIEW SERVER STATE.
-- =====================================================================

-- 1. TABLAS ----------------------------------------------------------
if object_id('dbo.etl_perf_log') is null
create table dbo.etl_perf_log (
    id                  int identity(1,1) primary key,
    corrida_id          uniqueidentifier not null,
    paso                varchar(100)     not null,
    inicio              datetime2(3)     not null,
    fin                 datetime2(3)     not null,
    duracion_ms         int              not null,
    filas               int              null,
    cpu_acum_ms         bigint           null,   -- acumulado de la sesion
    lecturas_acum       bigint           null,   -- lecturas logicas acumuladas
    escrituras_acum     bigint           null
);

if object_id('dbo.etl_perf_counters') is null
create table dbo.etl_perf_counters (
    id          int identity(1,1) primary key,
    corrida_id  uniqueidentifier not null,
    momento     varchar(10)      not null,       -- 'antes' / 'despues'
    capturado   datetime2(3)     not null default sysdatetime(),
    objeto      varchar(128)     null,
    contador    varchar(128)     null,
    instancia   varchar(128)     null,
    valor       bigint           null
);
go

-- 2. SNAPSHOT DE CONTADORES DEL SERVIDOR -----------------------------
create or alter procedure dbo.usp_perf_snapshot
    @corrida_id uniqueidentifier,
    @momento    varchar(10)          -- 'antes' o 'despues'
as
begin
    set nocount on;

    insert into dbo.etl_perf_counters (corrida_id, momento, objeto, contador, instancia, valor)
    select @corrida_id,
           @momento,
           rtrim(object_name),
           rtrim(counter_name),
           rtrim(instance_name),
           cntr_value
    from sys.dm_os_performance_counters
    where (counter_name like 'Page life expectancy%')
       or (counter_name like 'Buffer cache hit ratio%')
       or (counter_name like 'Batch Requests/sec%')
       or (counter_name like 'Transactions/sec%'  and instance_name = db_name())
       or (counter_name like 'Log Flushes/sec%'   and instance_name = db_name());

    -- fila base para poder calcular deltas por paso
    if @momento = 'antes'
        insert into dbo.etl_perf_log
            (corrida_id, paso, inicio, fin, duracion_ms, filas,
             cpu_acum_ms, lecturas_acum, escrituras_acum)
        select @corrida_id, '_inicio', sysdatetime(), sysdatetime(), 0, null,
               cpu_time, logical_reads, writes
        from sys.dm_exec_requests
        where session_id = @@spid;
end;
go

-- 3. REGISTRO DE UN PASO ---------------------------------------------
create or alter procedure dbo.usp_perf_paso
    @corrida_id uniqueidentifier,
    @paso       varchar(100),
    @inicio     datetime2(3),
    @filas      int
as
begin
    set nocount on;

    insert into dbo.etl_perf_log
        (corrida_id, paso, inicio, fin, duracion_ms, filas,
         cpu_acum_ms, lecturas_acum, escrituras_acum)
    select @corrida_id, @paso, @inicio, sysdatetime(),
           datediff(millisecond, @inicio, sysdatetime()),
           @filas,
           cpu_time, logical_reads, writes
    from sys.dm_exec_requests
    where session_id = @@spid;
end;
go

/* =========================================================
   4. PROCEDIMIENTO ETL CON AUDITORIA
   IMPORTANTE:
   El bloque ETL original se conserva sin cambiar sus
   INSERT, SELECT, JOIN, filtros ni condiciones.
   ========================================================= */

CREATE OR ALTER PROCEDURE dbo.sp_cargar_olist_etl
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @id_auditoria INT;
    DECLARE @filas_producto BIGINT;
    DECLARE @filas_cliente BIGINT;
    DECLARE @filas_vendedor BIGINT;
    DECLARE @filas_tiempo BIGINT;
    DECLARE @filas_estado BIGINT;
    DECLARE @filas_factura BIGINT;
    DECLARE @filas_totales BIGINT;

    DECLARE @producto_antes BIGINT;
    DECLARE @cliente_antes BIGINT;
    DECLARE @vendedor_antes BIGINT;
    DECLARE @tiempo_antes BIGINT;
    DECLARE @estado_antes BIGINT;
    DECLARE @factura_antes BIGINT;

    /* PERF COUNTER (paso 4): variables */
    DECLARE @corrida uniqueidentifier = newid();
    DECLARE @t       datetime2(3);
    DECLARE @n       int;

    /* Registrar el inicio fuera de la transacción de carga */

    INSERT INTO dbo.auditoria_etl
    (
        fecha_inicio,
        estado,
        filas_procesadas,
        mensaje
    )
    VALUES
    (
        SYSDATETIME(),
        N'EN PROCESO',
        0,
        N'Inicio de la carga ETL de Olist.'
    );

    SET @id_auditoria = CONVERT(INT, SCOPE_IDENTITY());

    BEGIN TRY

        BEGIN TRANSACTION;

        /* Registrar cantidades iniciales */

        SELECT @producto_antes = COUNT_BIG(*) FROM dbo.dim_producto;
        SELECT @cliente_antes = COUNT_BIG(*) FROM dbo.dim_cliente;
        SELECT @vendedor_antes = COUNT_BIG(*) FROM dbo.dim_vendedor;
        SELECT @tiempo_antes = COUNT_BIG(*) FROM dbo.dim_tiempo;
        SELECT @estado_antes = COUNT_BIG(*) FROM dbo.dim_estado_pedido;
        SELECT @factura_antes = COUNT_BIG(*) FROM dbo.fact_ventas;

        /* PERF COUNTER (paso 4) */
        exec dbo.usp_perf_snapshot @corrida, 'antes';

        /* =================================================
           5. ETL ORIGINAL: DIM_PRODUCTO
           ================================================= */

        /* PERF COUNTER (paso 4): inicia dim_producto */
        set @t = sysdatetime();

        insert into dim_producto (
            product_id,
            categoria_original,
            categoria_ingles,
            peso_g,
            largo_cm,
            alto_cm,
            ancho_cm
        )
        select distinct
            ltrim(rtrim(p.product_id)),                                   -- LIMPIEZA: espacios
            lower(ltrim(rtrim(p.product_category_name))),                 -- LIMPIEZA: espacios y minusculas
            lower(ltrim(rtrim(tr.column2))),                              -- LIMPIEZA: espacios y minusculas
            case when p.product_weight_g  > 0 then p.product_weight_g  end,  -- LIMPIEZA: 0 o negativos -> NULL
            case when p.product_length_cm > 0 then p.product_length_cm end,
            case when p.product_height_cm > 0 then p.product_height_cm end,
            case when p.product_width_cm  > 0 then p.product_width_cm  end
        from olist.dbo.olist_products_dataset p
        left join olist.dbo.product_category_name_translation tr
            on ltrim(rtrim(p.product_category_name)) = ltrim(rtrim(tr.column1))
        where exists (
            select 1
            from olist.dbo.olist_order_items_dataset i
            inner join olist.dbo.olist_orders_dataset o
                on i.order_id = o.order_id
            where i.product_id = p.product_id
              and lower(ltrim(rtrim(o.order_status))) = 'delivered'
        )
        and p.product_id is not null                                      -- LIMPIEZA
        and nullif(ltrim(rtrim(p.product_category_name)), '') is not null -- LIMPIEZA: vacios
        and nullif(ltrim(rtrim(tr.column2)), '') is not null
        and tr.column1 <> 'product_category_name'                         -- LIMPIEZA: fila de encabezado importada
        and not exists (                                                  -- LIMPIEZA: evita duplicados al re-ejecutar
            select 1 from dim_producto d
            where d.product_id = ltrim(rtrim(p.product_id))
        );

        /* PERF COUNTER (paso 4): anota dim_producto */
        set @n = @@rowcount;
        exec dbo.usp_perf_paso @corrida, 'dim_producto', @t, @n;


        /* =================================================
           6. ETL ORIGINAL: DIM_CLIENTE
           ================================================= */

        /* PERF COUNTER (paso 4): inicia dim_cliente */
        set @t = sysdatetime();

        insert into dim_cliente (
            customer_id,
            customer_unique_id,
            codigo_postal,
            ciudad,
            estado
        )
        select distinct
            ltrim(rtrim(c.customer_id)),                                  -- LIMPIEZA
            ltrim(rtrim(c.customer_unique_id)),                           -- LIMPIEZA
            c.customer_zip_code_prefix,
            lower(ltrim(rtrim(c.customer_city))),                         -- LIMPIEZA: normaliza ciudad
            upper(ltrim(rtrim(c.customer_state)))                         -- LIMPIEZA: estado en mayusculas
        from olist.dbo.olist_customers_dataset c
        inner join olist.dbo.olist_orders_dataset o
            on c.customer_id = o.customer_id
        where lower(ltrim(rtrim(o.order_status))) = 'delivered'
          and o.order_purchase_timestamp is not null
          and c.customer_id is not null                                   -- LIMPIEZA
          and c.customer_unique_id is not null
          and nullif(ltrim(rtrim(c.customer_city)), '') is not null
          and len(ltrim(rtrim(c.customer_state))) = 2                     -- LIMPIEZA: UF valida
          and exists (
              select 1
              from olist.dbo.olist_order_items_dataset i
              where i.order_id = o.order_id
          )
          and not exists (                                                -- LIMPIEZA: evita duplicados al re-ejecutar
              select 1 from dim_cliente d
              where d.customer_id = ltrim(rtrim(c.customer_id))
          );

        /* PERF COUNTER (paso 4): anota dim_cliente */
        set @n = @@rowcount;
        exec dbo.usp_perf_paso @corrida, 'dim_cliente', @t, @n;


        /* =================================================
           7. ETL ORIGINAL: DIM_VENDEDOR
           ================================================= */

        /* PERF COUNTER (paso 4): inicia dim_vendedor */
        set @t = sysdatetime();

        insert into dim_vendedor (
            seller_id,
            codigo_postal,
            ciudad,
            estado
        )
        select distinct
            ltrim(rtrim(s.seller_id)),                                    -- LIMPIEZA
            s.seller_zip_code_prefix,
            lower(ltrim(rtrim(s.seller_city))),                           -- LIMPIEZA
            upper(ltrim(rtrim(s.seller_state)))                           -- LIMPIEZA
        from olist.dbo.olist_sellers_dataset s
        where exists (
            select 1
            from olist.dbo.olist_order_items_dataset i
            inner join olist.dbo.olist_orders_dataset o
                on i.order_id = o.order_id
            where i.seller_id = s.seller_id
              and lower(ltrim(rtrim(o.order_status))) = 'delivered'
              and o.order_purchase_timestamp is not null
              and i.price is not null
              and i.price > 0                                             -- LIMPIEZA: precio valido
              and i.freight_value is not null
              and i.freight_value >= 0                                    -- LIMPIEZA: flete valido
        )
        and s.seller_id is not null                                       -- LIMPIEZA
        and nullif(ltrim(rtrim(s.seller_city)), '') is not null          -- LIMPIEZA: vacios
        and len(ltrim(rtrim(s.seller_state))) = 2                         -- LIMPIEZA: UF valida
        and not exists (                                                  -- LIMPIEZA: evita duplicados al re-ejecutar
            select 1 from dim_vendedor d
            where d.seller_id = ltrim(rtrim(s.seller_id))
        );

        /* PERF COUNTER (paso 4): anota dim_vendedor */
        set @n = @@rowcount;
        exec dbo.usp_perf_paso @corrida, 'dim_vendedor', @t, @n;


        /* =================================================
           8. ETL ORIGINAL: DIM_TIEMPO
           ================================================= */

        /* PERF COUNTER (paso 4): inicia dim_tiempo */
        set @t = sysdatetime();

        insert into dim_tiempo (
            id_tiempo,
            fecha,
            dia,
            mes,
            trimestre,
            anio
        )
        select distinct
            year(o.order_purchase_timestamp) * 10000
              + month(o.order_purchase_timestamp) * 100
              + day(o.order_purchase_timestamp),
            cast(o.order_purchase_timestamp as date),
            day(o.order_purchase_timestamp),
            month(o.order_purchase_timestamp),
            datepart(quarter, o.order_purchase_timestamp),
            year(o.order_purchase_timestamp)
        from olist.dbo.olist_orders_dataset o
        inner join olist.dbo.olist_order_items_dataset i
            on o.order_id = i.order_id
        where lower(ltrim(rtrim(o.order_status))) = 'delivered'
          and o.order_purchase_timestamp is not null
          and i.price is not null
          and i.price > 0                                                 -- LIMPIEZA
          and i.freight_value is not null
          and i.freight_value >= 0                                        -- LIMPIEZA
          and not exists (
              select 1
              from dim_tiempo t
              where t.id_tiempo =
                  year(o.order_purchase_timestamp) * 10000
                  + month(o.order_purchase_timestamp) * 100
                  + day(o.order_purchase_timestamp)
          );

        /* PERF COUNTER (paso 4): anota dim_tiempo */
        set @n = @@rowcount;
        exec dbo.usp_perf_paso @corrida, 'dim_tiempo', @t, @n;


        /* =================================================
           9. ETL ORIGINAL: DIM_ESTADO_PEDIDO
           ================================================= */

        /* PERF COUNTER (paso 4): inicia dim_estado_pedido */
        set @t = sysdatetime();

        insert into dim_estado_pedido (estado_pedido)
        select distinct lower(ltrim(rtrim(o.order_status)))               -- LIMPIEZA: normaliza
        from olist.dbo.olist_orders_dataset o
        where nullif(ltrim(rtrim(o.order_status)), '') is not null        -- LIMPIEZA: nulos y vacios
          and not exists (
              select 1
              from dim_estado_pedido e
              where e.estado_pedido = lower(ltrim(rtrim(o.order_status)))
          );

        /* PERF COUNTER (paso 4): anota dim_estado_pedido */
        set @n = @@rowcount;
        exec dbo.usp_perf_paso @corrida, 'dim_estado_pedido', @t, @n;


        /* =================================================
           10. ETL ORIGINAL: FACT_VENTAS
           ================================================= */

        /* PERF COUNTER (paso 4): inicia fact_ventas */
        set @t = sysdatetime();

        insert into fact_ventas (
            id_pedido,
            numero_item,
            id_producto,
            id_vendedor,
            id_cliente,
            id_tiempo,
            id_estado,
            precio,
            flete,
            cantidad_articulos
        )
        select
            ltrim(rtrim(o.order_id)),                                     -- LIMPIEZA
            i.order_item_id,
            p.id_producto,
            v.id_vendedor,
            c.id_cliente,
            t.id_tiempo,
            e.id_estado,
            i.price,
            i.freight_value,
            1
        from olist.dbo.olist_order_items_dataset i
        inner join olist.dbo.olist_orders_dataset o
            on i.order_id = o.order_id
        inner join dim_producto p
            on ltrim(rtrim(i.product_id)) = p.product_id
        inner join dim_vendedor v
            on ltrim(rtrim(i.seller_id)) = v.seller_id
        inner join dim_cliente c
            on ltrim(rtrim(o.customer_id)) = c.customer_id
        inner join dim_tiempo t
            on cast(o.order_purchase_timestamp as date) = t.fecha
        inner join dim_estado_pedido e
            on lower(ltrim(rtrim(o.order_status))) = e.estado_pedido
        where lower(ltrim(rtrim(o.order_status))) = 'delivered'
          and o.order_purchase_timestamp is not null
          and i.price is not null
          and i.price > 0                                                 -- LIMPIEZA
          and i.freight_value is not null
          and i.freight_value >= 0                                        -- LIMPIEZA
          and not exists (                                                -- LIMPIEZA: evita duplicados al re-ejecutar
              select 1 from fact_ventas f
              where f.id_pedido = ltrim(rtrim(o.order_id))
                and f.numero_item = i.order_item_id
          );

        /* PERF COUNTER (paso 4): anota fact_ventas */
        set @n = @@rowcount;
        exec dbo.usp_perf_paso @corrida, 'fact_ventas', @t, @n;

        /* PERF COUNTER (paso 4): snapshot despues */
        exec dbo.usp_perf_snapshot @corrida, 'despues';


        /* =================================================
           11. CALCULAR FILAS CARGADAS
           ================================================= */

        SELECT @filas_producto =
            COUNT_BIG(*) - @producto_antes
        FROM dbo.dim_producto;

        SELECT @filas_cliente =
            COUNT_BIG(*) - @cliente_antes
        FROM dbo.dim_cliente;

        SELECT @filas_vendedor =
            COUNT_BIG(*) - @vendedor_antes
        FROM dbo.dim_vendedor;

        SELECT @filas_tiempo =
            COUNT_BIG(*) - @tiempo_antes
        FROM dbo.dim_tiempo;

        SELECT @filas_estado =
            COUNT_BIG(*) - @estado_antes
        FROM dbo.dim_estado_pedido;

        SELECT @filas_factura =
            COUNT_BIG(*) - @factura_antes
        FROM dbo.fact_ventas;

        SET @filas_totales =
              @filas_producto
            + @filas_cliente
            + @filas_vendedor
            + @filas_tiempo
            + @filas_estado
            + @filas_factura;

        /* =================================================
           12. REGISTRAR METRICAS
           ================================================= */

        INSERT INTO dbo.metricas_etl
        (
            id_auditoria,
            nombre_tabla,
            metrica,
            valor,
            fecha_registro
        )
        VALUES
            (@id_auditoria, N'dim_producto',
             N'filas_insertadas', @filas_producto, SYSDATETIME()),

            (@id_auditoria, N'dim_cliente',
             N'filas_insertadas', @filas_cliente, SYSDATETIME()),

            (@id_auditoria, N'dim_vendedor',
             N'filas_insertadas', @filas_vendedor, SYSDATETIME()),

            (@id_auditoria, N'dim_tiempo',
             N'filas_insertadas', @filas_tiempo, SYSDATETIME()),

            (@id_auditoria, N'dim_estado_pedido',
             N'filas_insertadas', @filas_estado, SYSDATETIME()),

            (@id_auditoria, N'fact_ventas',
             N'filas_insertadas', @filas_factura, SYSDATETIME()),

            (@id_auditoria, N'ETL',
             N'total_filas_insertadas', @filas_totales, SYSDATETIME());

        COMMIT TRANSACTION;

        /* =================================================
           13. FINALIZAR AUDITORIA
           ================================================= */

        UPDATE dbo.auditoria_etl
        SET
            fecha_fin = SYSDATETIME(),
            estado = N'EXITOSO',
            filas_procesadas = @filas_totales,
            mensaje = N'ETL ejecutado correctamente.'
        WHERE id_auditoria = @id_auditoria;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        UPDATE dbo.auditoria_etl
        SET
            fecha_fin = SYSDATETIME(),
            estado = N'ERROR',
            filas_procesadas = 0,
            mensaje = ERROR_MESSAGE()
        WHERE id_auditoria = @id_auditoria;

        INSERT INTO dbo.errores_etl
        (
            id_auditoria,
            fecha_error,
            procedimiento,
            mensaje_error,
            numero_error,
            linea_error
        )
        VALUES
        (
            @id_auditoria,
            SYSDATETIME(),
            N'dbo.sp_cargar_olist_etl',
            ERROR_MESSAGE(),
            ERROR_NUMBER(),
            ERROR_LINE()
        );

        THROW;
    END CATCH;
END;
GO

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

/* =========================================================
   15. EJECUTAR EL ETL
   ========================================================= */

EXEC dbo.sp_cargar_olist_etl;
GO

/* =========================================================
   15B. NOMBRES FICTICIOS PARA CLIENTES Y VENDEDORES
   (script del usuario, tal cual; se ejecuta despues del ETL)
   ========================================================= */

/* =========================================================
   1. AGREGAR COLUMNAS PARA LOS NOMBRES FICTICIOS
   ========================================================= */

IF COL_LENGTH('dbo.dim_cliente', 'nombre_cliente') IS NULL
BEGIN
    ALTER TABLE dbo.dim_cliente
    ADD nombre_cliente NVARCHAR(150) NULL;
END;
GO

IF COL_LENGTH('dbo.dim_vendedor', 'nombre_vendedor') IS NULL
BEGIN
    ALTER TABLE dbo.dim_vendedor
    ADD nombre_vendedor NVARCHAR(150) NULL;
END;
GO

/* =========================================================
   2. CREAR COMBINACIONES DE NOMBRES Y APELLIDOS
   ========================================================= */

IF OBJECT_ID('tempdb..#combinaciones') IS NOT NULL
    DROP TABLE #combinaciones;

CREATE TABLE #combinaciones
(
    id_combinacion INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL
);

INSERT INTO #combinaciones (nombre, apellido)
SELECT n.nombre, a.apellido
FROM
(
    VALUES
        (N'Ana'), (N'Lúcia'), (N'Camila'), (N'Valéria'),
(N'Fernanda'), (N'Daniela'), (N'Gabriela'), (N'Paula'),
(N'Juliana'), (N'Carolina'), (N'Maria'), (N'Cláudia'),
(N'João'), (N'Lucas'), (N'Rafael'), (N'Miguel'),
(N'José'), (N'Bruno'), (N'André'), (N'Felipe'),
(N'Ricardo'), (N'Gabriel'), (N'Pedro'), (N'Adriano'),
(N'Mateus'), (N'Sofia'), (N'Isabela'), (N'Helena'),
(N'Luciana'), (N'Vinícius')
) AS n(nombre)
CROSS JOIN
(
    VALUES
        (N'Silva'), (N'Santos'), (N'Oliveira'), (N'Souza'),
(N'Pereira'), (N'Costa'), (N'Rodrigues'), (N'Almeida'),
(N'Nascimento'), (N'Lima'), (N'Araújo'), (N'Fernandes'),
(N'Carvalho'), (N'Gomes'), (N'Martins'), (N'Rocha'),
(N'Ribeiro'), (N'Alves'), (N'Monteiro'), (N'Mendes'),
(N'Barbosa'), (N'Cardoso'), (N'Correia'), (N'Dias'),
(N'Castro'), (N'Teixeira'), (N'Moreira'), (N'Nunes'),
(N'Marques'), (N'Machado')

) AS a(apellido);

 /* =========================================================
    3. GENERAR NOMBRES FICTICIOS PARA LOS CLIENTES
    ========================================================= */

;WITH lista_clientes AS
(
    SELECT
        customer_id,
        ROW_NUMBER() OVER (ORDER BY customer_id) AS numero
    FROM dbo.dim_cliente
)
UPDATE d
SET nombre_cliente =
    CONCAT(
        co.nombre,
        N' ',
        co.apellido,
        N' ',
        RIGHT(
            REPLICATE('0', 6) +
            CAST(c.numero AS VARCHAR(6)),
            6
        )
    )
FROM dbo.dim_cliente AS d
INNER JOIN lista_clientes AS c
    ON c.customer_id = d.customer_id
INNER JOIN #combinaciones AS co
    ON co.id_combinacion =
       ((c.numero - 1) % (SELECT COUNT(*) FROM #combinaciones)) + 1;
GO

/* =========================================================
   4. GENERAR NOMBRES FICTICIOS PARA LOS VENDEDORES
   ========================================================= */

;WITH lista_vendedores AS
(
    SELECT
        seller_id,
        ROW_NUMBER() OVER (ORDER BY seller_id) AS numero
    FROM dbo.dim_vendedor
)
UPDATE v
SET nombre_vendedor =
    CONCAT(
        co.nombre,
        N' ',
        co.apellido,
        N' ',
        RIGHT(
            REPLICATE('0', 6) +
            CAST(s.numero AS VARCHAR(6)),
            6
        )
    )
FROM dbo.dim_vendedor AS v
INNER JOIN lista_vendedores AS s
    ON s.seller_id = v.seller_id
INNER JOIN #combinaciones AS co
    ON co.id_combinacion =
       ((s.numero - 1) % (SELECT COUNT(*) FROM #combinaciones)) + 1;
GO

/* =========================================================
   5. ELIMINAR TABLA TEMPORAL
   ========================================================= */

DROP TABLE #combinaciones;
GO

/* =========================================================
   6. VERIFICAR RESULTADOS
   ========================================================= */

SELECT TOP (20)
    customer_id,
    nombre_cliente
FROM dbo.dim_cliente
ORDER BY customer_id;

SELECT TOP (20)
    seller_id,
    nombre_vendedor
FROM dbo.dim_vendedor
ORDER BY seller_id;
GO


/* =========================================================
   16. CONSULTAR AUDITORIA
   ========================================================= */

SELECT TOP (20)
    id_auditoria,
    fecha_inicio,
    fecha_fin,
    estado,
    filas_procesadas,
    mensaje
FROM dbo.auditoria_etl
ORDER BY id_auditoria DESC;
GO

/* =========================================================
   17. CONSULTAR ERRORES
   ========================================================= */

SELECT TOP (50)
    id_error,
    id_auditoria,
    fecha_error,
    procedimiento,
    mensaje_error,
    numero_error,
    linea_error
FROM dbo.errores_etl
ORDER BY id_error DESC;
GO

/* =========================================================
   18. CONSULTAR METRICAS
   ========================================================= */

SELECT
    id_auditoria,
    nombre_tabla,
    metrica,
    valor,
    fecha_registro
FROM dbo.metricas_etl
ORDER BY id_metrica DESC;
GO

/* =========================================================
   19. VERIFICAR CANTIDAD DE REGISTROS
   ========================================================= */

SELECT N'dim_producto' AS tabla, COUNT_BIG(*) AS registros
FROM dbo.dim_producto

UNION ALL

SELECT N'dim_cliente', COUNT_BIG(*)
FROM dbo.dim_cliente

UNION ALL

SELECT N'dim_vendedor', COUNT_BIG(*)
FROM dbo.dim_vendedor

UNION ALL

SELECT N'dim_tiempo', COUNT_BIG(*)
FROM dbo.dim_tiempo

UNION ALL

SELECT N'dim_estado_pedido', COUNT_BIG(*)
FROM dbo.dim_estado_pedido

UNION ALL

SELECT N'fact_ventas', COUNT_BIG(*)
FROM dbo.fact_ventas;
GO

/* =========================================================
   PERF COUNTER (secciones 5 y 6 de tu script, tal cual)
   ========================================================= */

-- 5. REPORTE POR PASO (ultima corrida) -------------------------------
with ult as (
    select top 1 corrida_id from dbo.etl_perf_log order by id desc
),
x as (
    select l.*,
           cpu_acum_ms     - lag(cpu_acum_ms)     over (partition by l.corrida_id order by l.id) as cpu_ms,
           lecturas_acum   - lag(lecturas_acum)   over (partition by l.corrida_id order by l.id) as lecturas_logicas,
           escrituras_acum - lag(escrituras_acum) over (partition by l.corrida_id order by l.id) as escrituras
    from dbo.etl_perf_log l
    join ult on ult.corrida_id = l.corrida_id
)
select paso,
       duracion_ms,
       filas,
       case when duracion_ms > 0 then filas * 1000 / duracion_ms end as filas_por_seg,
       cpu_ms,
       lecturas_logicas,
       escrituras
from x
where paso <> '_inicio'
order by id;

-- 6. REPORTE DE CONTADORES DEL SERVIDOR (ultima corrida) -------------
-- Los contadores "/sec" son acumulados: se calcula el delta entre
-- 'antes' y 'despues' dividido entre los segundos transcurridos.
with ult as (
    select top 1 corrida_id from dbo.etl_perf_counters order by id desc
)
select a.contador,
       a.instancia,
       a.valor as valor_antes,
       d.valor as valor_despues,
       d.valor - a.valor as delta,
       case when a.contador like '%/sec%'
            then (d.valor - a.valor) * 1.0
                 / nullif(datediff(second, a.capturado, d.capturado), 0)
       end as por_segundo
from dbo.etl_perf_counters a
join dbo.etl_perf_counters d
  on  d.corrida_id = a.corrida_id
  and d.contador   = a.contador
  and d.instancia  = a.instancia
  and d.momento    = 'despues'
join ult on ult.corrida_id = a.corrida_id
where a.momento = 'antes'
order by a.contador;
go
