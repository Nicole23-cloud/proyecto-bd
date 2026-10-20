USE OLIST_DATAMART;
GO

--------------------------------------------------------------
-- 1. PROCEDIMIENTO PRINCIPAL DE CARGA DE DATOS (ETL)
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_ejecutar_etl_olist
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @id_auditoria INT;
    DECLARE @registros_origen BIGINT;
    DECLARE @registros_destino BIGINT;

    BEGIN TRY
        -- Conteo de registros en la base de datos origen
        SELECT @registros_origen = COUNT_BIG(*)
        FROM OLIST_DATABASE.dbo.olist_order_items_dataset i
        INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o
            ON i.order_id = o.order_id
        WHERE o.order_status = 'delivered';

        -- Registrar inicio en la tabla de auditoría
        INSERT INTO dbo.auditoria_etl (nombre_proceso, registros_origen, estado, observaciones)
        VALUES ('ejecucion_etl_olist', @registros_origen, 'iniciado', 'Inicio de carga ETL');
        
        SET @id_auditoria = SCOPE_IDENTITY();

        BEGIN TRANSACTION;

        -- A. Cargar Dimensión Producto
        INSERT INTO dbo.dim_producto (
            product_id,
            categoria_original,
            categoria_ingles,
            peso_g,
            largo_cm,
            alto_cm,
            ancho_cm
        )
        SELECT DISTINCT
            p.product_id,
            p.product_category_name,
            tr.product_category_name_english,
            p.product_weight_g,
            p.product_length_cm,
            p.product_height_cm,
            p.product_width_cm
        FROM OLIST_DATABASE.dbo.olist_products_dataset p
        LEFT JOIN OLIST_DATABASE.dbo.olist_category_name_translation_dataset tr
            ON p.product_category_name = tr.product_category_name
        WHERE EXISTS (
            SELECT 1
            FROM OLIST_DATABASE.dbo.olist_order_items_dataset i
            INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o
                ON i.order_id = o.order_id
            WHERE i.product_id = p.product_id
              AND o.order_status = 'delivered'
        )
        AND NOT EXISTS (
            SELECT 1 FROM dbo.dim_producto dp WHERE dp.product_id = p.product_id
        );

        -- B. Cargar Dimensión Cliente
        INSERT INTO dbo.dim_cliente (
            customer_id,
            customer_unique_id,
            codigo_postal,
            ciudad,
            estado
        )
        SELECT DISTINCT
            c.customer_id,
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state
        FROM OLIST_DATABASE.dbo.olist_customers_dataset c
        INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o
            ON c.customer_id = o.customer_id
        WHERE o.order_status = 'delivered'
          AND o.order_purchase_timestamp IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM dbo.dim_cliente dc WHERE dc.customer_id = c.customer_id
          );

        -- C. Cargar Dimensión Vendedor
        INSERT INTO dbo.dim_vendedor (
            seller_id,
            codigo_postal,
            ciudad,
            estado
        )
        SELECT DISTINCT
            s.seller_id,
            s.seller_zip_code_prefix,
            s.seller_city,
            s.seller_state
        FROM OLIST_DATABASE.dbo.olist_sellers_dataset s
        WHERE EXISTS (
            SELECT 1
            FROM OLIST_DATABASE.dbo.olist_order_items_dataset i
            INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o
                ON i.order_id = o.order_id
            WHERE i.seller_id = s.seller_id
              AND o.order_status = 'delivered'
              AND o.order_purchase_timestamp IS NOT NULL
        )
        AND NOT EXISTS (
            SELECT 1 FROM dbo.dim_vendedor dv WHERE dv.seller_id = s.seller_id
        );

        -- D. Generar automáticamente Nombres Sintéticos para Clientes y Vendedores
        IF EXISTS (SELECT 1 FROM dbo.dim_cliente WHERE nombre_cliente IS NULL) 
           OR EXISTS (SELECT 1 FROM dbo.dim_vendedor WHERE nombre_vendedor IS NULL)
        BEGIN
            IF OBJECT_ID('tempdb..#combinaciones') IS NOT NULL DROP TABLE #combinaciones;

            SELECT
                ROW_NUMBER() OVER (ORDER BY NEWID()) AS numero,
                n.nombre,
                a.apellido AS apellido1,
                b.apellido AS apellido2
            INTO #combinaciones
            FROM (VALUES
                ('Ana'), ('Maria'), ('Joao'), ('Lucas'), ('Julia'),
                ('Pedro'), ('Beatriz'), ('Gabriel'), ('Laura'), ('Rafael'),
                ('Mariana'), ('Bruno'), ('Camila'), ('Felipe'), ('Larissa'),
                ('Matheus'), ('Isabela'), ('Thiago'), ('Amanda'), ('Gustavo'),
                ('Leticia'), ('Daniel'), ('Fernanda'), ('Rodrigo'), ('Carolina'),
                ('Eduardo'), ('Bianca'), ('Leonardo'), ('Patricia'), ('Vinicius'),
                ('Marcos'), ('Renata'), ('Andre'), ('Claudia'), ('Diego'),
                ('Sofia'), ('Henrique'), ('Natalia'), ('Caio'), ('Luiza'),
                ('Ricardo'), ('Vanessa'), ('Alexandre'), ('Tatiane'), ('Fabio'),
                ('Priscila'), ('Roberto'), ('Aline'), ('Samuel'), ('Isadora')
            ) n(nombre)
            CROSS JOIN (VALUES
                ('Silva'), ('Santos'), ('Oliveira'), ('Souza'), ('Pereira'),
                ('Costa'), ('Rodrigues'), ('Almeida'), ('Nascimento'), ('Lima'),
                ('Araujo'), ('Fernandes'), ('Carvalho'), ('Gomes'), ('Martins'),
                ('Rocha'), ('Ribeiro'), ('Alves'), ('Monteiro'), ('Mendes'),
                ('Barbosa'), ('Cardoso'), ('Correia'), ('Dias'), ('Castro'),
                ('Teixeira'), ('Moreira'), ('Nunes'), ('Marques'), ('Machado'),
                ('Freitas'), ('Batista'), ('Moura'), ('Campos'), ('Ramos'),
                ('Cavalcanti'), ('Azevedo'), ('Pinto'), ('Lopes'), ('Miranda'),
                ('Barros'), ('Melo'), ('Farias'), ('Reis'), ('Duarte'),
                ('Tavares'), ('Cunha'), ('Peixoto'), ('Rezende'), ('Borges')
            ) a(apellido)
            CROSS JOIN (VALUES
                ('Silva'), ('Santos'), ('Oliveira'), ('Souza'), ('Pereira'),
                ('Costa'), ('Rodrigues'), ('Almeida'), ('Nascimento'), ('Lima'),
                ('Araujo'), ('Fernandes'), ('Carvalho'), ('Gomes'), ('Martins'),
                ('Rocha'), ('Ribeiro'), ('Alves'), ('Monteiro'), ('Mendes'),
                ('Barbosa'), ('Cardoso'), ('Correia'), ('Dias'), ('Castro'),
                ('Teixeira'), ('Moreira'), ('Nunes'), ('Marques'), ('Machado'),
                ('Freitas'), ('Batista'), ('Moura'), ('Campos'), ('Ramos'),
                ('Cavalcanti'), ('Azevedo'), ('Pinto'), ('Lopes'), ('Miranda'),
                ('Barros'), ('Melo'), ('Farias'), ('Reis'), ('Duarte'),
                ('Tavares'), ('Cunha'), ('Peixoto'), ('Rezende'), ('Borges')
            ) b(apellido);

            -- Actualizar dimensión Clientes
            WITH lista_clientes AS (
                SELECT customer_id, ROW_NUMBER() OVER (ORDER BY NEWID()) AS numero
                FROM dbo.dim_cliente WHERE nombre_cliente IS NULL
            )
            UPDATE d
            SET nombre_cliente = c.nombre + ' ' + c.apellido1 + ' ' + c.apellido2
            FROM dbo.dim_cliente d
            JOIN lista_clientes l ON d.customer_id = l.customer_id
            JOIN #combinaciones c ON c.numero = l.numero;

            -- Actualizar dimensión Vendedores
            WITH lista_vendedores AS (
                SELECT seller_id, ROW_NUMBER() OVER (ORDER BY NEWID()) AS numero
                FROM dbo.dim_vendedor WHERE nombre_vendedor IS NULL
            )
            UPDATE d
            SET nombre_vendedor = c.nombre + ' ' + c.apellido1 + ' ' + c.apellido2
            FROM dbo.dim_vendedor d
            JOIN lista_vendedores l ON d.seller_id = l.seller_id
            JOIN #combinaciones c ON c.numero = l.numero;

            DROP TABLE #combinaciones;
        END

        -- E. Cargar Dimensión Tiempo
        INSERT INTO dbo.dim_tiempo (
            id_tiempo,
            fecha,
            dia,
            mes,
            trimestre,
            anio
        )
        SELECT DISTINCT
            YEAR(o.order_purchase_timestamp) * 10000
              + MONTH(o.order_purchase_timestamp) * 100
              + DAY(o.order_purchase_timestamp),
            CAST(o.order_purchase_timestamp AS DATE),
            DAY(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            DATEPART(QUARTER, o.order_purchase_timestamp),
            YEAR(o.order_purchase_timestamp)
        FROM OLIST_DATABASE.dbo.olist_orders_dataset o
        INNER JOIN OLIST_DATABASE.dbo.olist_order_items_dataset i
            ON o.order_id = i.order_id
        WHERE o.order_status = 'delivered'
          AND o.order_purchase_timestamp IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.dim_tiempo t
              WHERE t.id_tiempo = YEAR(o.order_purchase_timestamp) * 10000
                                 + MONTH(o.order_purchase_timestamp) * 100
                                 + DAY(o.order_purchase_timestamp)
          );

        -- F. Cargar Dimensión Estado de Pedido
        INSERT INTO dbo.dim_estado_pedido (estado_pedido)
        SELECT DISTINCT o.order_status
        FROM OLIST_DATABASE.dbo.olist_orders_dataset o
        WHERE o.order_status IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM dbo.dim_estado_pedido e WHERE e.estado_pedido = o.order_status
          );

        -- G. Cargar Tabla de Hechos Ventas
        INSERT INTO dbo.fact_ventas (
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
        SELECT
            o.order_id,
            i.order_item_id,
            p.id_producto,
            v.id_vendedor,
            c.id_cliente,
            t.id_tiempo,
            e.id_estado,
            i.price,
            i.freight_value,
            1
        FROM OLIST_DATABASE.dbo.olist_order_items_dataset i
        INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o
            ON i.order_id = o.order_id
        INNER JOIN dbo.dim_producto p
            ON i.product_id = p.product_id
        INNER JOIN dbo.dim_vendedor v
            ON i.seller_id = v.seller_id
        INNER JOIN dbo.dim_cliente c
            ON o.customer_id = c.customer_id
        INNER JOIN dbo.dim_tiempo t
            ON CAST(o.order_purchase_timestamp AS DATE) = t.fecha
        INNER JOIN dbo.dim_estado_pedido e
            ON o.order_status = e.estado_pedido
        WHERE o.order_status = 'delivered'
          AND o.order_purchase_timestamp IS NOT NULL
          AND i.price IS NOT NULL
          AND i.freight_value IS NOT NULL;

        COMMIT TRANSACTION;

        -- Conteo final de registros cargados en la tabla de hechos
        SELECT @registros_destino = COUNT_BIG(*) FROM dbo.fact_ventas;

        -- Actualizar el estado del log de auditoría
        UPDATE dbo.auditoria_etl
        SET fecha_fin = SYSDATETIME(),
            registros_destino = @registros_destino,
            estado = 'correcto',
            observaciones = 'Proceso de ETL completado satisfactoriamente'
        WHERE id_auditoria = @id_auditoria;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        IF @id_auditoria IS NOT NULL
        BEGIN
            UPDATE dbo.auditoria_etl
            SET fecha_fin = SYSDATETIME(),
                estado = 'error',
                observaciones = ERROR_MESSAGE()
            WHERE id_auditoria = @id_auditoria;

            INSERT INTO dbo.errores_etl (id_auditoria, nombre_proceso, descripcion_error)
            VALUES (@id_auditoria, 'ejecucion_etl_olist', ERROR_MESSAGE());
        END;

        THROW;
    END CATCH;
END;
GO

--------------------------------------------------------------
-- 2. PROCEDIMIENTO DE REGISTRO DE MÉTRICAS Y CONTROL
--------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_registrar_metricas_etl
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_auditoria INT;
    DECLARE @total DECIMAL(19,2);
    DECLARE @registros_origen BIGINT;
    DECLARE @registros_destino BIGINT;

    BEGIN TRY
        SELECT @registros_origen = COUNT_BIG(*)
        FROM OLIST_DATABASE.dbo.olist_order_items_dataset i
        INNER JOIN OLIST_DATABASE.dbo.olist_orders_dataset o
            ON i.order_id = o.order_id
        WHERE o.order_status = 'delivered';

        SELECT @registros_destino = COUNT_BIG(*) FROM dbo.fact_ventas;

        INSERT INTO dbo.auditoria_etl (
            nombre_proceso,
            registros_origen,
            registros_destino,
            estado,
            observaciones
        )
        VALUES (
            'registro_metricas_etl',
            @registros_origen,
            @registros_destino,
            'iniciado',
            'Inicio del registro de métricas'
        );

        SET @id_auditoria = SCOPE_IDENTITY();

        -- Métricas de conteo por tabla
        SELECT @total = COUNT_BIG(*) FROM dbo.dim_cliente;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'dim_cliente', 'total_registros', @total);

        SELECT @total = COUNT_BIG(*) FROM dbo.dim_estado_pedido;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'dim_estado_pedido', 'total_registros', @total);

        SELECT @total = COUNT_BIG(*) FROM dbo.dim_producto;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'dim_producto', 'total_registros', @total);

        SELECT @total = COUNT_BIG(*) FROM dbo.dim_tiempo;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'dim_tiempo', 'total_registros', @total);

        SELECT @total = COUNT_BIG(*) FROM dbo.dim_vendedor;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'dim_vendedor', 'total_registros', @total);

        SELECT @total = COUNT_BIG(*) FROM dbo.fact_ventas;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'fact_ventas', 'total_registros', @total);

        -- Métricas monetarias y consolidadas
        SELECT @total = ISNULL(SUM(precio), 0) FROM dbo.fact_ventas;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'fact_ventas', 'suma_precios', @total);

        SELECT @total = ISNULL(SUM(flete), 0) FROM dbo.fact_ventas;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'fact_ventas', 'suma_fletes', @total);

        SELECT @total = ISNULL(SUM(cantidad_articulos), 0) FROM dbo.fact_ventas;
        INSERT INTO dbo.metricas_etl (id_auditoria, nombre_tabla, metrica, valor) VALUES (@id_auditoria, 'fact_ventas', 'total_articulos', @total);

        UPDATE dbo.auditoria_etl
        SET fecha_fin = SYSDATETIME(),
            estado = 'correcto',
            observaciones = 'Métricas registradas correctamente'
        WHERE id_auditoria = @id_auditoria;

    END TRY
    BEGIN CATCH
        IF @id_auditoria IS NOT NULL
        BEGIN
            UPDATE dbo.auditoria_etl
            SET fecha_fin = SYSDATETIME(),
                estado = 'error',
                observaciones = ERROR_MESSAGE()
            WHERE id_auditoria = @id_auditoria;

            INSERT INTO dbo.errores_etl (id_auditoria, nombre_proceso, descripcion_error)
            VALUES (@id_auditoria, 'registro_metricas_etl', ERROR_MESSAGE());
        END;

        THROW;
    END CATCH;
END;
GO

--------------------------------------------------------------
-- 3. EJECUCIÓN COMPLETA DEL ETL Y AUDITORÍA
--------------------------------------------------------------

-- 1. Ejecución del proceso principal de carga
EXEC dbo.sp_ejecutar_etl_olist;

-- 2. Ejecución de registro de métricas de control
EXEC dbo.sp_registrar_metricas_etl;

-- 3. Consultas de Verificación
SELECT * FROM dbo.auditoria_etl ORDER BY id_auditoria DESC;
SELECT * FROM dbo.errores_etl ORDER BY id_error DESC;
SELECT * FROM dbo.metricas_etl ORDER BY id_metrica DESC;