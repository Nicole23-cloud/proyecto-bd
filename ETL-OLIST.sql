----etl

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
    p.product_id,
    p.product_category_name,
    tr.column2,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
from olist.dbo.olist_products_dataset p
left join olist.dbo.product_category_name_translation tr
    on p.product_category_name = tr.column1
where exists (
    select 1
    from olist.dbo.olist_order_items_dataset i
    inner join olist.dbo.olist_orders_dataset o
        on i.order_id = o.order_id
    where i.product_id = p.product_id
      and o.order_status = 'delivered'
)
and p.product_category_name is not null
and tr.column2 is not null;
------------------------------------------------------------------

insert into dim_cliente (
    customer_id,
    customer_unique_id,
    codigo_postal,
    ciudad,
    estado
)
select distinct
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state
from olist.dbo.olist_customers_dataset c
inner join olist.dbo.olist_orders_dataset o
    on c.customer_id = o.customer_id
where o.order_status = 'delivered'
  and o.order_purchase_timestamp is not null
  and exists (
      select 1
      from olist.dbo.olist_order_items_dataset i
      where i.order_id = o.order_id
  );
  ---------------------------------------------------------------------
  insert into dim_vendedor (
    seller_id,
    codigo_postal,
    ciudad,
    estado
)
select distinct
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
from olist.dbo.olist_sellers_dataset s
where exists (
    select 1
    from olist.dbo.olist_order_items_dataset i
    inner join olist.dbo.olist_orders_dataset o
        on i.order_id = o.order_id
    where i.seller_id = s.seller_id
      and o.order_status = 'delivered'
      and o.order_purchase_timestamp is not null
      and i.price is not null
      and i.freight_value is not null
)
and s.seller_city is not null
and s.seller_state is not null;
-----------------------------------------------------------

insert into dim_tiempo (
    id_tiempo,
    fecha,
    dia,
    mes,
    trimestre,
    año
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
where o.order_status = 'delivered'
  and o.order_purchase_timestamp is not null
  and i.price is not null
  and i.freight_value is not null
  and not exists (
      select 1
      from dim_tiempo t
      where t.id_tiempo =
          year(o.order_purchase_timestamp) * 10000
          + month(o.order_purchase_timestamp) * 100
          + day(o.order_purchase_timestamp)
  );
  -----------------------------------------------------------
  insert into dim_estado_pedido (estado_pedido)
select distinct o.order_status
from olist.dbo.olist_orders_dataset o
where o.order_status is not null
  and not exists (
      select 1
      from dim_estado_pedido e
      where e.estado_pedido = o.order_status
  );

  -------------------------------------------------------------
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
from olist.dbo.olist_order_items_dataset i
inner join olist.dbo.olist_orders_dataset o
    on i.order_id = o.order_id
inner join dim_producto p
    on i.product_id = p.product_id
inner join dim_vendedor v
    on i.seller_id = v.seller_id
inner join dim_cliente c
    on o.customer_id = c.customer_id
inner join dim_tiempo t
    on cast(o.order_purchase_timestamp as date) = t.fecha
inner join dim_estado_pedido e
    on o.order_status = e.estado_pedido
where o.order_status = 'delivered'
  and o.order_purchase_timestamp is not null
  and i.price is not null
  and i.freight_value is not null;
--------------------------------------------------------

-- crear tabla de auditoria del etl

create table dbo.auditoria_etl (
    id_auditoria int identity(1,1) primary key,
    nombre_proceso varchar(100) not null,
    fecha_inicio datetime2 not null default sysdatetime(),
    fecha_fin datetime2 null,
    registros_origen bigint null,
    registros_destino bigint null,
    estado varchar(20) not null default 'iniciado',
    observaciones varchar(1000) null
);
---------------------------------------------------------------------

  
create table dbo.errores_etl (
    id_error int identity(1,1) primary key,
    id_auditoria int null,
    fecha_error datetime2 not null default sysdatetime(),
    nombre_proceso varchar(100) not null,
    tabla_afectada varchar(100) null,
    descripcion_error varchar(2000) not null,

    constraint fk_errores_auditoria
        foreign key (id_auditoria)
        references dbo.auditoria_etl(id_auditoria)
);

-----------------------------------------------------------------------


create table dbo.metricas_etl (
    id_metrica int identity(1,1) primary key,
    id_auditoria int not null,
    nombre_tabla varchar(100) not null,
    metrica varchar(100) not null,
    valor bigint not null,
    fecha_registro datetime2 not null default sysdatetime(),

    constraint fk_metricas_auditoria
        foreign key (id_auditoria)
        references dbo.auditoria_etl(id_auditoria)
);
---------------------------------------------------------------
GO
create or alter procedure dbo.sp_registrar_metricas_etl
as
begin
    set nocount on;

    declare @id_auditoria int;
    declare @total bigint;

    begin try

        -- registrar inicio del proceso
        insert into dbo.auditoria_etl (
            nombre_proceso,
            estado,
            observaciones
        )
        values (
            'registro_metricas_etl',
            'iniciado',
            'inicio del registro de metricas'
        );

        set @id_auditoria = scope_identity();

        -- registrar cantidad de clientes
        select @total = count_big(*) from dbo.dim_cliente;

        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_cliente', 'total_registros', @total);

        -- registrar cantidad de estados
        select @total = count_big(*) from dbo.dim_estado_pedido;

        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_estado_pedido', 'total_registros', @total);

        -- registrar cantidad de productos
        select @total = count_big(*) from dbo.dim_producto;

        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_producto', 'total_registros', @total);

        -- registrar cantidad de fechas
        select @total = count_big(*) from dbo.dim_tiempo;

        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_tiempo', 'total_registros', @total);

        -- registrar cantidad de vendedores
        select @total = count_big(*) from dbo.dim_vendedor;

        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_vendedor', 'total_registros', @total);

        -- registrar cantidad de ventas
        select @total = count_big(*) from dbo.fact_ventas;

        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'fact_ventas', 'total_registros', @total);

        -- finalizar auditoria correctamente
        update dbo.auditoria_etl
        set
            fecha_fin = sysdatetime(),
            estado = 'correcto',
            observaciones = 'metricas registradas correctamente'
        where id_auditoria = @id_auditoria;

    end try
    begin catch

        if @id_auditoria is not null
        begin
            update dbo.auditoria_etl
            set
                fecha_fin = sysdatetime(),
                estado = 'error',
                observaciones = error_message()
            where id_auditoria = @id_auditoria;

            insert into dbo.errores_etl (
                id_auditoria,
                nombre_proceso,
                tabla_afectada,
                descripcion_error
            )
            values (
                @id_auditoria,
                'registro_metricas_etl',
                null,
                error_message()
            );
        end;

        throw;
    end catch;
end;
-------------------------------------------------------------------
EXEC dbo.sp_registrar_metricas_etl;

select*from dbo.auditoria_etl
select *
from dbo.auditoria_etl
order by id_auditoria desc;
exec sp_helptext 'dbo.sp_registrar_metricas_etl';

GO
alter procedure dbo.sp_registrar_metricas_etl
as
begin
    set nocount on;

    declare @id_auditoria int;
    declare @total decimal(19,2);
    declare @registros_origen bigint;
    declare @registros_destino bigint;

    begin try

        -- contar detalles de pedidos entregados en el origen
        select @registros_origen = count_big(*)
        from olist.dbo.olist_order_items_dataset i
        inner join olist.dbo.olist_orders_dataset o
            on i.order_id = o.order_id
        where o.order_status = 'delivered';

        -- contar registros cargados en el destino
        select @registros_destino = count_big(*)
        from dbo.fact_ventas;

        -- iniciar auditoria con cantidades
        insert into dbo.auditoria_etl (
            nombre_proceso,
            registros_origen,
            registros_destino,
            estado,
            observaciones
        )
        values (
            'registro_metricas_etl',
            @registros_origen,
            @registros_destino,
            'iniciado',
            'inicio del registro de metricas'
        );

        set @id_auditoria = scope_identity();

        -- registrar cantidad de registros por tabla

        select @total = count_big(*) from dbo.dim_cliente;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_cliente', 'total_registros', @total);

        select @total = count_big(*) from dbo.dim_estado_pedido;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_estado_pedido', 'total_registros', @total);

        select @total = count_big(*) from dbo.dim_producto;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_producto', 'total_registros', @total);

        select @total = count_big(*) from dbo.dim_tiempo;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_tiempo', 'total_registros', @total);

        select @total = count_big(*) from dbo.dim_vendedor;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'dim_vendedor', 'total_registros', @total);

        select @total = count_big(*) from dbo.fact_ventas;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'fact_ventas', 'total_registros', @total);

        -- registrar importes y cantidades

        select @total = sum(precio) from dbo.fact_ventas;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'fact_ventas', 'suma_precios', @total);

        select @total = sum(flete) from dbo.fact_ventas;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'fact_ventas', 'suma_fletes', @total);

        select @total = sum(cantidad_articulos)
        from dbo.fact_ventas;
        insert into dbo.metricas_etl
            (id_auditoria, nombre_tabla, metrica, valor)
        values
            (@id_auditoria, 'fact_ventas', 'total_articulos', @total);

        -- finalizar auditoria

        update dbo.auditoria_etl
        set fecha_fin = sysdatetime(),
            estado = 'correcto',
            observaciones =
                'metricas registradas correctamente'
        where id_auditoria = @id_auditoria;

    end try
    begin catch

        if @id_auditoria is not null
        begin
            update dbo.auditoria_etl
            set fecha_fin = sysdatetime(),
                estado = 'error',
                observaciones = error_message()
            where id_auditoria = @id_auditoria;

            insert into dbo.errores_etl (
                id_auditoria,
                nombre_proceso,
                tabla_afectada,
                descripcion_error
            )
            values (
                @id_auditoria,
                'registro_metricas_etl',
                null,
                error_message()
            );
        end;

        throw;
    end catch;
end;
exec dbo.sp_registrar_metricas_etl;

select *
from dbo.auditoria_etl
order by id_auditoria desc;