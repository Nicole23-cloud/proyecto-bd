--# Anexo F: Manual de Despliegue y Demostración Funcional (Evidencia E-14)

--**Proyecto:** Integración de Datos Olist - Solución BI  
--**Plataformas:** SQL Server 2019/2022 Management Studio (SSMS) & Power BI Desktop  

---
-- 1. Requisitos Previos
--* Microsoft SQL Server 2019 o superior.
--* SQL Server Management Studio (SSMS).
--* Power BI Desktop.


--## 2. Guía Paso a Paso para la Ejecución

--### Paso 1: Carga de la Base Relacional (OLTP)
--1. Abrir SSMS y conectarse al servidor local.
--2. Ejecutar `Evidencias/Evidencia 01/OLIST_DATABASE.sql`.
--3. Validar calidad con `Evidencias/Evidencia 02/perfilado_calidad_oltp.sql`.

--### Paso 2: Creación del Data Mart y Seguridad
--1. Abrir y ejecutar `Evidencias/Evidencia 05/OLIST_TABLAS_DATAMART.sql` para estructurar la base `OLIST_DATAMART`, las tablas de auditoría y los roles RBAC.

--### Paso 3: Ejecución del ETL y Auditoría (Control Transaccional)
--1. Abrir y ejecutar `Evidencias/Evidencia 06/ETL_OLIST.sql`.
--2. Ejecutar los procedimientos almacenados con control de transacciones y captura de errores:```sql
   USE OLIST_DATAMART;
   GO
   EXEC dbo.sp_ejecutar_etl_olist;
   EXEC dbo.sp_registrar_metricas_etl;

--### Paso 4: Verificar la correcta auditoría
   SELECT * FROM dbo.auditoria_etl ORDER BY id_auditoria DESC;

--### Paso 5: Pruebas de Escalabilidad y Rendimiento (2x)
-- Ejecutar Evidencias/Evidencia 03/replica_escalada_2x.sql
-- Ejecutar Evidencias/Evidencia 07/consultas_kpis_rendimiento.sql para comprobar tiempos de respuesta < 2s.

--### Paso 6: Despliegue del Dashboard en Power BI
-- Abrir el archivo Evidencias/Evidencia 13/OLIST.pbix en Power BI Desktop.
-- Actualizar el origen de datos hacia la base OLIST_DATAMART en SQL Server local.