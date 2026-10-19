USE OLIST_DATAMART;
GO

SELECT 
    rol.name AS rol,
    permiso.permission_name AS permiso,
    permiso.state_desc AS estado,
    permiso.class_desc AS alcance
FROM sys.database_permissions AS permiso
INNER JOIN sys.database_principals AS rol 
    ON permiso.grantee_principal_id = rol.principal_id
WHERE rol.name IN ('rol_olist_lectura', 'rol_olist_carga')
ORDER BY rol.name, permiso.permission_name;