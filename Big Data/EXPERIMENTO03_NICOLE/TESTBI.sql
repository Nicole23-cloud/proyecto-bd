USE DATAMART_OLIST;
GO

SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @total BIGINT;
DECLARE @inicio DATETIME2(7);
DECLARE @fin DATETIME2(7);
DECLARE @tiempo_ms DECIMAL(18,3);

DECLARE @resultados TABLE
(
    ejecucion INT,
    consultas INT,
    registros BIGINT,
    tiempo_total_ms DECIMAL(18,3),
    promedio_ms DECIMAL(18,3)
);

WHILE @i <= 5
BEGIN
    SET @inicio = SYSDATETIME();

    DECLARE @j INT = 1;

    WHILE @j <= 100
    BEGIN
        SELECT @total = COUNT_BIG(*)
        FROM dbo.fact_ventas;

        SET @j = @j + 1;
    END;

    SET @fin = SYSDATETIME();

    SET @tiempo_ms =
        DATEDIFF_BIG(MICROSECOND, @inicio, @fin) / 1000.0;

    INSERT INTO @resultados
    VALUES
    (
        @i,
        100,
        @total,
        @tiempo_ms,
        @tiempo_ms / 100.0
    );

    SET @i = @i + 1;
END;

SELECT *
FROM @resultados
ORDER BY ejecucion;

SELECT
    AVG(promedio_ms) AS promedio_general_ms,
    MIN(promedio_ms) AS minimo_ms,
    MAX(promedio_ms) AS maximo_ms
FROM @resultados;