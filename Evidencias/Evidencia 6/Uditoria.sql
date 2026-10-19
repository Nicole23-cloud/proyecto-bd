USE OLIST_DATAMART;
GO

SELECT 
    id_auditoria,
    nombre_proceso,
    fecha_inicio,
    fecha_fin,
    registros_origen,
    registros_destino,
    estado,
    observaciones
FROM dbo.auditoria_etl
WHERE nombre_proceso = 'ejecucion_etl_olist'
ORDER BY id_auditoria DESC;

SELECT * FROM dbo.auditoria_etl ORDER BY id_auditoria DESC;