

USE DATAMARTT_OLIST;
GO

SET NOCOUNT ON;
GO

/* =========================================================
   1. DIMENSION DE PRODUCTOS
   ========================================================= */

CREATE TABLE dbo.dim_producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    product_id NVARCHAR(50) NOT NULL UNIQUE,
    categoria_original NVARCHAR(100),
    categoria_ingles NVARCHAR(100),
    peso_g INT,
    largo_cm INT,
    alto_cm INT,
    ancho_cm INT
);
GO


/* =========================================================
   2. DIMENSION DE CLIENTES
   ========================================================= */

CREATE TABLE dbo.dim_cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL UNIQUE,
    customer_unique_id NVARCHAR(50),
    nombre_cliente NVARCHAR(200),
    codigo_postal INT,
    ciudad NVARCHAR(100),
    estado CHAR(2)
);
GO


/* =========================================================
   3. DIMENSION DE VENDEDORES
   ========================================================= */

CREATE TABLE dbo.dim_vendedor (
    id_vendedor INT IDENTITY(1,1) PRIMARY KEY,
    seller_id NVARCHAR(50) NOT NULL UNIQUE,
    nombre_vendedor NVARCHAR(200),
    codigo_postal INT,
    ciudad NVARCHAR(100),
    estado CHAR(2)
);
GO


/* =========================================================
   4. DIMENSION DE TIEMPO
   ========================================================= */

CREATE TABLE dbo.dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    dia INT,
    mes INT,
    trimestre INT,
    anio INT
);
GO


/* =========================================================
   5. DIMENSION DE ESTADOS DE PEDIDO
   ========================================================= */

CREATE TABLE dbo.dim_estado_pedido (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    estado_pedido NVARCHAR(30) NOT NULL UNIQUE
);
GO


/* =========================================================
   6. TABLA DE HECHOS DE VENTAS
   ========================================================= */

CREATE TABLE dbo.fact_ventas (
    id_hecho INT IDENTITY(1,1) PRIMARY KEY,

    id_pedido NVARCHAR(50) NOT NULL,
    numero_item INT NOT NULL,

    id_producto INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_cliente INT NOT NULL,
    id_tiempo INT NOT NULL,
    id_estado INT NOT NULL,

    precio DECIMAL(12,2) NOT NULL,
    flete DECIMAL(12,2) NOT NULL,
    cantidad_articulos INT NOT NULL,

    CONSTRAINT uq_fact_ventas_pedido_item
        UNIQUE (id_pedido, numero_item),

    CONSTRAINT fk_fact_producto
        FOREIGN KEY (id_producto)
        REFERENCES dbo.dim_producto(id_producto),

    CONSTRAINT fk_fact_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES dbo.dim_vendedor(id_vendedor),

    CONSTRAINT fk_fact_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dbo.dim_cliente(id_cliente),

    CONSTRAINT fk_fact_tiempo
        FOREIGN KEY (id_tiempo)
        REFERENCES dbo.dim_tiempo(id_tiempo),

    CONSTRAINT fk_fact_estado
        FOREIGN KEY (id_estado)
        REFERENCES dbo.dim_estado_pedido(id_estado),

    CONSTRAINT ck_fact_precio
        CHECK (precio >= 0),

    CONSTRAINT ck_fact_flete
        CHECK (flete >= 0),

    CONSTRAINT ck_fact_cantidad
        CHECK (cantidad_articulos > 0)
);
GO

