/*================ 1. Tablas de medición (BENCH_OLIST) ================*/
USE master;
GO
IF DB_ID('BENCH_OLIST') IS NULL CREATE DATABASE BENCH_OLIST;
GO
USE BENCH_OLIST;
GO
DROP TABLE IF EXISTS dbo.muestreo_contadores, dbo.lat_ejecuciones, dbo.corridas;
CREATE TABLE dbo.muestreo_contadores (
    run_id VARCHAR(10), escenario VARCHAR(10), escala VARCHAR(5), muestra_n INT,
    fecha DATETIME2(3), contador VARCHAR(128), instancia VARCHAR(128), valor BIGINT);
CREATE TABLE dbo.lat_ejecuciones (
    run_id VARCHAR(10), escala VARCHAR(5), intervalo INT, ms DECIMAL(12,3));
CREATE TABLE dbo.corridas (
    run_id VARCHAR(10), escenario VARCHAR(10), escala VARCHAR(5), tipo VARCHAR(10),
    inicio DATETIME2(3), fin DATETIME2(3));
GO

/*================ 2. CORRIDAS: 12 runs x 10 intervalos x 12 s (~24 min) ================*/
USE EXP_OLIST;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.fact_ventas_1x') IS NULL OR OBJECT_ID('dbo.fact_ventas_2x') IS NULL
   OR OBJECT_ID('dbo.dim_cliente') IS NULL
BEGIN
    RAISERROR('Falta el setup: no existen fact_ventas_1x, fact_ventas_2x o dim_cliente en EXP_OLIST.', 16, 1);
    RETURN;
END

DROP TABLE IF EXISTS #cnt;
CREATE TABLE #cnt (
    run_id VARCHAR(10), escenario VARCHAR(10), escala VARCHAR(5), muestra_n INT,
    fecha DATETIME2(3), contador VARCHAR(128), instancia VARCHAR(128), valor BIGINT);

DECLARE @plan TABLE (ord INT IDENTITY(1,1), run_id VARCHAR(10), escala VARCHAR(5), tipo VARCHAR(10));
INSERT @plan (run_id, escala, tipo) VALUES
 ('RUN-01','1x','warmup'),('RUN-02','2x','warmup'),
 ('RUN-03','1x','valida'),('RUN-04','2x','valida'),
 ('RUN-05','1x','valida'),('RUN-06','2x','valida'),
 ('RUN-07','1x','valida'),('RUN-08','2x','valida'),
 ('RUN-09','1x','valida'),('RUN-10','2x','valida'),
 ('RUN-11','1x','valida'),('RUN-12','2x','valida');

DECLARE @o INT = 1, @maxo INT = (SELECT MAX(ord) FROM @plan),
        @run VARCHAR(10), @escala VARCHAR(5), @tipo VARCHAR(10),
        @k INT, @t0 DATETIME2(7), @fin12 DATETIME2(7), @ini DATETIME2(3),
        @s DECIMAL(38,2), @ms DECIMAL(12,3), @buf VARCHAR(MAX), @msg NVARCHAR(100);

WHILE @o <= @maxo
BEGIN
    SELECT @run = run_id, @escala = escala, @tipo = tipo FROM @plan WHERE ord = @o;
    SET @msg = @run + ' ' + @escala + ' ' + @tipo + ' iniciada ' + CONVERT(VARCHAR(19), SYSDATETIME(), 120);
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    SET @ini = SYSDATETIME();
    SET @buf = '';
    SET @k = 0;

    WHILE @k <= 10
    BEGIN
        IF @k > 0
        BEGIN   -- 12 s de carga; latencias en memoria (sin escribir en ninguna BD)
            SET @fin12 = DATEADD(SECOND, 12, SYSUTCDATETIME());
            WHILE SYSUTCDATETIME() < @fin12
            BEGIN
                SET @t0 = SYSUTCDATETIME();
                IF @escala = '1x'
                    SELECT @s = SUM(t.total) FROM (
                        SELECT c.estado, SUM(f.precio) AS total
                        FROM dbo.fact_ventas_1x f JOIN dbo.dim_cliente c ON f.id_cliente = c.id_cliente
                        GROUP BY c.estado) t;
                ELSE
                    SELECT @s = SUM(t.total) FROM (
                        SELECT c.estado, SUM(f.precio) AS total
                        FROM dbo.fact_ventas_2x f JOIN dbo.dim_cliente c ON f.id_cliente = c.id_cliente
                        GROUP BY c.estado) t;
                SET @ms  = CAST(DATEDIFF_BIG(MICROSECOND, @t0, SYSUTCDATETIME()) / 1000.0 AS DECIMAL(12,3));
                SET @buf = @buf + CAST(@k AS VARCHAR(3)) + '|' + CAST(@ms AS VARCHAR(20)) + ';';
            END
        END

        -- Muestra de contadores (cumulativos) + CPU acumulada
        INSERT #cnt (run_id, escenario, escala, muestra_n, fecha, contador, instancia, valor)
        SELECT @run, 'EXP-01', @escala, @k, SYSDATETIME(),
               RTRIM(counter_name), RTRIM(instance_name), cntr_value
        FROM sys.dm_os_performance_counters
        WHERE (RTRIM(object_name) LIKE '%:Buffer Manager'
               AND RTRIM(counter_name) IN ('Page life expectancy','Buffer cache hit ratio','Buffer cache hit ratio base'))
           OR (RTRIM(object_name) LIKE '%:Memory Manager'
               AND RTRIM(counter_name) = 'Total Server Memory (KB)')
           OR (RTRIM(object_name) LIKE '%:Databases'
               AND RTRIM(counter_name) = 'Transactions/sec' AND RTRIM(instance_name) = 'EXP_OLIST');

        INSERT #cnt (run_id, escenario, escala, muestra_n, fecha, contador, instancia, valor)
        VALUES (@run, 'EXP-01', @escala, @k, SYSDATETIME(), 'CPU ms', '',
                CAST(@@CPU_BUSY AS BIGINT) * @@TIMETICKS / 1000);

        SET @k += 1;
    END

    -- Guardar la corrida completa (fuera de la ventana de medición)
    INSERT BENCH_OLIST.dbo.lat_ejecuciones (run_id, escala, intervalo, ms)
    SELECT @run, @escala,
           CAST(LEFT(value, CHARINDEX('|', value) - 1) AS INT),
           CAST(SUBSTRING(value, CHARINDEX('|', value) + 1, 20) AS DECIMAL(12,3))
    FROM STRING_SPLIT(@buf, ';') WHERE value LIKE '%|%';

    INSERT BENCH_OLIST.dbo.muestreo_contadores
           (run_id, escenario, escala, muestra_n, fecha, contador, instancia, valor)
    SELECT run_id, escenario, escala, muestra_n, fecha, contador, instancia, valor FROM #cnt;
    DELETE #cnt;

    INSERT BENCH_OLIST.dbo.corridas (run_id, escenario, escala, tipo, inicio, fin)
    VALUES (@run, 'EXP-01', @escala, @tipo, @ini, SYSDATETIME());

    SET @o += 1;
END
RAISERROR('TERMINADO', 0, 1) WITH NOWAIT;
GO

/*================ 3. RESULTADOS (capturar = evidencia E-03 y E-07) ================*/
USE BENCH_OLIST;
GO
-- E-03: versión y conteos
SELECT @@VERSION AS version_servidor;
SELECT
 (SELECT COUNT(*) FROM EXP_OLIST.dbo.fact_ventas_1x) AS filas_1x,
 (SELECT COUNT(*) FROM EXP_OLIST.dbo.fact_ventas_2x) AS filas_2x,
 (SELECT COUNT(*) FROM (SELECT DISTINCT id_pedido, numero_item FROM EXP_OLIST.dbo.fact_ventas_2x) x) AS unicas_2x,
 (SELECT COUNT(*) FROM EXP_OLIST.dbo.dim_cliente)  AS dim_cliente,
 (SELECT COUNT(*) FROM EXP_OLIST.dbo.dim_vendedor) AS dim_vendedor;

-- Resultados por corrida
DROP TABLE IF EXISTS #res;
WITH l AS (
  SELECT DISTINCT run_id,
    COUNT(*) OVER (PARTITION BY run_id) AS n_ejec,
    PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY ms) OVER (PARTITION BY run_id) AS p50_ms,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY ms) OVER (PARTITION BY run_id) AS p95_ms,
    STDEV(ms) OVER (PARTITION BY run_id) AS de_ms
  FROM dbo.lat_ejecuciones),
d AS (
  SELECT run_id, MIN(fecha) AS t0, MAX(fecha) AS t1
  FROM dbo.muestreo_contadores GROUP BY run_id),
cn AS (
  SELECT run_id,
    MAX(CASE WHEN contador='Transactions/sec' THEN valor END)
      - MIN(CASE WHEN contador='Transactions/sec' THEN valor END) AS d_tx,
    MAX(CASE WHEN contador='CPU ms' THEN valor END)
      - MIN(CASE WHEN contador='CPU ms' THEN valor END) AS d_cpu_ms,
    MIN(CASE WHEN contador='Page life expectancy' THEN valor END) AS ple_min,
    MAX(CASE WHEN contador='Total Server Memory (KB)' THEN valor END) / 1024 AS ram_mb
  FROM dbo.muestreo_contadores GROUP BY run_id),
h AS (
  SELECT a.run_id, MIN(100.0 * a.valor / NULLIF(b.valor, 0)) AS cache_hit_min_pct
  FROM dbo.muestreo_contadores a
  JOIN dbo.muestreo_contadores b
    ON b.run_id = a.run_id AND b.muestra_n = a.muestra_n
   AND b.contador = 'Buffer cache hit ratio base'
  WHERE a.contador = 'Buffer cache hit ratio'
  GROUP BY a.run_id)
SELECT c0.run_id, c0.escala, c0.tipo, l.n_ejec,
  CAST(x.s AS DECIMAL(9,2))                         AS dur_s,
  CAST(l.n_ejec / x.s AS DECIMAL(9,2))              AS consultas_s,
  CAST(l.p50_ms AS DECIMAL(9,3))                    AS p50_ms,
  CAST(l.p95_ms AS DECIMAL(9,3))                    AS p95_ms,
  CAST(l.de_ms  AS DECIMAL(9,3))                    AS de_ms,
  CAST(cn.d_tx / x.s AS DECIMAL(9,2))               AS tps,
  CAST(cn.d_cpu_ms / (x.s * 1000.0) AS DECIMAL(9,3)) AS cpu_nucleos,
  cn.ple_min, cn.ram_mb,
  CAST(h.cache_hit_min_pct AS DECIMAL(6,2))         AS cache_hit_min_pct
INTO #res
FROM dbo.corridas c0
JOIN l  ON l.run_id  = c0.run_id
JOIN d  ON d.run_id  = c0.run_id
JOIN cn ON cn.run_id = c0.run_id
LEFT JOIN h ON h.run_id = c0.run_id
CROSS APPLY (SELECT DATEDIFF_BIG(MILLISECOND, d.t0, d.t1) / 1000.0 AS s) x;

SELECT * FROM #res ORDER BY run_id;

-- Resumen entre corridas VÁLIDAS por escala (excluye calentamientos)
SELECT DISTINCT r.escala, m.metrica,
  COUNT(*) OVER (PARTITION BY r.escala, m.metrica) AS n,
  PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY m.v) OVER (PARTITION BY r.escala, m.metrica) AS mediana,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY m.v) OVER (PARTITION BY r.escala, m.metrica) AS q1,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY m.v) OVER (PARTITION BY r.escala, m.metrica) AS q3,
  AVG(m.v)   OVER (PARTITION BY r.escala, m.metrica) AS media,
  STDEV(m.v) OVER (PARTITION BY r.escala, m.metrica) AS de,
  MIN(m.v)   OVER (PARTITION BY r.escala, m.metrica) AS minimo,
  MAX(m.v)   OVER (PARTITION BY r.escala, m.metrica) AS maximo
FROM #res r
CROSS APPLY (VALUES
  ('latencia_p50_ms',     CAST(r.p50_ms      AS FLOAT)),
  ('latencia_p95_ms',     CAST(r.p95_ms      AS FLOAT)),
  ('consultas_por_s',     CAST(r.consultas_s AS FLOAT)),
  ('transacciones_por_s', CAST(r.tps         AS FLOAT)),
  ('cpu_nucleos',         CAST(r.cpu_nucleos AS FLOAT)),
  ('ple_min_s',           CAST(r.ple_min     AS FLOAT))
) m(metrica, v)
WHERE r.tipo = 'valida'
ORDER BY r.escala, m.metrica;

-- Atípicos (criterio 1,5 x IQR, definido antes de ver los datos)
WITH q AS (
  SELECT DISTINCT escala,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY p50_ms)      OVER (PARTITION BY escala) AS a1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY p50_ms)      OVER (PARTITION BY escala) AS a3,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY consultas_s) OVER (PARTITION BY escala) AS b1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY consultas_s) OVER (PARTITION BY escala) AS b3
  FROM #res WHERE tipo = 'valida')
SELECT r.run_id, r.escala, r.p50_ms, r.consultas_s,
  CASE WHEN r.p50_ms < q.a1 - 1.5*(q.a3 - q.a1) OR r.p50_ms > q.a3 + 1.5*(q.a3 - q.a1)
       THEN 'ATIPICO' ELSE 'ok' END AS latencia_1_5IQR,
  CASE WHEN r.consultas_s < q.b1 - 1.5*(q.b3 - q.b1) OR r.consultas_s > q.b3 + 1.5*(q.b3 - q.b1)
       THEN 'ATIPICO' ELSE 'ok' END AS throughput_1_5IQR
FROM #res r JOIN q ON q.escala = r.escala
WHERE r.tipo = 'valida'
ORDER BY r.run_id;

-- Registro de ejecuciones
SELECT run_id, escenario, escala, tipo, inicio, fin FROM dbo.corridas ORDER BY run_id;
GO