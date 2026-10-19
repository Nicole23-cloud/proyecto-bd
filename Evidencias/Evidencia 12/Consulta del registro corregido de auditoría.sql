USE OLIST_DATAMART;
GO

SELECT id_auditoria, nombre_proceso, fecha_inicio, fecha_fin, 
       registros_origen, registros_destino, estado, observaciones
FROM dbo.auditoria_etl
WHERE id_auditoria = 4;