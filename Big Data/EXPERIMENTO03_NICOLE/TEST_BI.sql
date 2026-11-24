USE DATAMART_OLIST;
GO

SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @registros BIGINT;
DECLARE @inicio DATETIME2(7);
DECLARE @fin DATETIME2(7);

DECLARE @resultados TABLE
(
    ejecucion INT,
    registros BIGINT,
    tiempo_ms DECIMAL(18,3)
);

WHILE @i <= 10
BEGIN
    SET @inicio = SYSDATETIME();

    SELECT @registros = COUNT_BIG(*)
    FROM dbo.fact_ventas;

    SET @fin = SYSDATETIME();

    INSERT INTO @resultados
    VALUES
    (
        @i,
        @registros,
        DATEDIFF_BIG(MICROSECOND, @inicio, @fin) / 1000.0
    );

    SET @i = @i + 1;
END;

SELECT *
FROM @resultados
ORDER BY ejecucion;

SELECT
    AVG(tiempo_ms) AS promedio_ms,
    MIN(tiempo_ms) AS minimo_ms,
    MAX(tiempo_ms) AS maximo_ms,
    COUNT(*) AS total_ejecuciones
FROM @resultados;