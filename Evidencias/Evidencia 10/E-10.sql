--E-10

USE OLIST_DATAMART;
GO

EXEC dbo.sp_ejecutar_etl_olist;
EXEC dbo.sp_registrar_metricas_etl;


SELECT * FROM dbo.auditoria_etl ORDER BY id_auditoria DESC;

SELECT * FROM dbo.metricas_etl WHERE id_auditoria = (SELECT MAX(id_auditoria) FROM dbo.auditoria_etl);