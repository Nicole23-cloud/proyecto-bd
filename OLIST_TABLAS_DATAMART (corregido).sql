USE master;
GO

IF DB_ID('OLIST_DATAMART') IS NULL
BEGIN
    CREATE DATABASE OLIST_DATAMART;
    PRINT 'Base de datos OLIST_DATAMART creada.';
END
ELSE
BEGIN
    PRINT 'La base de datos OLIST_DATAMART ya existe.';
END;
GO

USE OLIST_DATAMART;
GO

--------------------------------------------------------------
-- 1. TABLAS DEL DATA MART (ESQUEMA EN ESTRELLA)
--------------------------------------------------------------

-- Dimensión Producto
CREATE TABLE dbo.dim_producto (
    id_producto INT PRIMARY KEY IDENTITY(1,1),
    product_id NVARCHAR(50) NOT NULL,
    categoria_original NVARCHAR(50) NULL,
    categoria_ingles NVARCHAR(50) NULL,
    peso_g INT NULL,
    largo_cm TINYINT NULL,
    alto_cm TINYINT NULL,
    ancho_cm TINYINT NULL
);
GO

-- Dimensión Cliente
CREATE TABLE dbo.dim_cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    customer_id NVARCHAR(50) NOT NULL,
    customer_unique_id NVARCHAR(50) NOT NULL,
    nombre_cliente NVARCHAR(150) NULL,
    codigo_postal INT NOT NULL,
    ciudad NVARCHAR(50) NOT NULL,
    estado NVARCHAR(50) NOT NULL
);
GO

-- Dimensión Vendedor
CREATE TABLE dbo.dim_vendedor (
    id_vendedor INT PRIMARY KEY IDENTITY(1,1),
    seller_id NVARCHAR(50) NOT NULL,
    nombre_vendedor NVARCHAR(150) NULL,
    codigo_postal INT NOT NULL,
    ciudad NVARCHAR(50) NOT NULL,
    estado NVARCHAR(50) NOT NULL
);
GO

-- Dimensión Tiempo
CREATE TABLE dbo.dim_tiempo (
    id_tiempo INT PRIMARY KEY, -- Formato YYYYMMDD (ej. 20261018)
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL
);
GO

-- Dimensión Estado del Pedido
CREATE TABLE dbo.dim_estado_pedido (
    id_estado INT PRIMARY KEY IDENTITY(1,1),
    estado_pedido NVARCHAR(50) NOT NULL
);
GO

-- Tabla de Hechos Ventas
CREATE TABLE dbo.fact_ventas (
    id_hecho INT PRIMARY KEY IDENTITY(1,1),
    id_pedido NVARCHAR(50) NOT NULL,
    numero_item TINYINT NOT NULL,
    id_producto INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_cliente INT NOT NULL,
    id_tiempo INT NOT NULL,
    id_estado INT NOT NULL,
    precio FLOAT NOT NULL,
    flete FLOAT NOT NULL,
    cantidad_articulos INT NOT NULL,

    CONSTRAINT fk_ventas_producto FOREIGN KEY (id_producto) REFERENCES dbo.dim_producto(id_producto),
    CONSTRAINT fk_ventas_vendedor FOREIGN KEY (id_vendedor) REFERENCES dbo.dim_vendedor(id_vendedor),
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente) REFERENCES dbo.dim_cliente(id_cliente),
    CONSTRAINT fk_ventas_tiempo FOREIGN KEY (id_tiempo) REFERENCES dbo.dim_tiempo(id_tiempo),
    CONSTRAINT fk_ventas_estado FOREIGN KEY (id_estado) REFERENCES dbo.dim_estado_pedido(id_estado)
);
GO

--------------------------------------------------------------
-- 2. TABLAS DE AUDITORÍA, ERRORES Y MÉTRICAS
--------------------------------------------------------------

IF OBJECT_ID('dbo.metricas_etl', 'U') IS NOT NULL DROP TABLE dbo.metricas_etl;
IF OBJECT_ID('dbo.errores_etl', 'U') IS NOT NULL DROP TABLE dbo.errores_etl;
IF OBJECT_ID('dbo.auditoria_etl', 'U') IS NOT NULL DROP TABLE dbo.auditoria_etl;

CREATE TABLE dbo.auditoria_etl (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre_proceso VARCHAR(100) NOT NULL,
    fecha_inicio DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    fecha_fin DATETIME2 NULL,
    registros_origen BIGINT NULL,
    registros_destino BIGINT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'iniciado',
    observaciones VARCHAR(1000) NULL
);
GO

CREATE TABLE dbo.errores_etl (
    id_error INT IDENTITY(1,1) PRIMARY KEY,
    id_auditoria INT NULL,
    fecha_error DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    nombre_proceso VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NULL,
    descripcion_error VARCHAR(2000) NOT NULL,

    CONSTRAINT fk_errores_auditoria
        FOREIGN KEY (id_auditoria)
        REFERENCES dbo.auditoria_etl(id_auditoria)
);
GO

CREATE TABLE dbo.metricas_etl (
    id_metrica INT IDENTITY(1,1) PRIMARY KEY,
    id_auditoria INT NOT NULL,
    nombre_tabla VARCHAR(100) NOT NULL,
    metrica VARCHAR(100) NOT NULL,
    valor BIGINT NOT NULL,
    fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT fk_metricas_auditoria
        FOREIGN KEY (id_auditoria)
        REFERENCES dbo.auditoria_etl(id_auditoria)
);
GO