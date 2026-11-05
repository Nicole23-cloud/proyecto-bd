# Evidencia 12: Seguridad, auditoría y organización del repositorio

## 1. Objetivo

Implementar y verificar mecanismos de seguridad mediante roles y permisos RBAC, validar los registros de auditoría del proceso ETL y organizar las evidencias del proyecto de Business Intelligence y DataMart en un repositorio GitHub.

## 2. Descripción

En esta evidencia se desarrollaron actividades relacionadas con la administración de permisos, la verificación de registros de auditoría y la organización de los archivos del proyecto Olist.

Se realizaron consultas SQL en la base de datos `OLIST_DATAMART` para comprobar los permisos asignados a los roles y verificar el registro de auditoría correspondiente a la ejecución del proceso de registro de métricas ETL.

Asimismo, se organizó el repositorio GitHub para facilitar la identificación y consulta de las evidencias desarrolladas durante el proyecto.

## 3. Actividades realizadas

### 3.1. Verificación de roles y permisos RBAC

Se ejecutó una consulta SQL para verificar los roles, permisos, estados y alcances configurados en la base de datos.

Se revisaron los siguientes roles:

- `rol_olist_carga`
- `rol_olist_lectura`

La consulta permitió visualizar los permisos asignados, incluyendo operaciones como SELECT, INSERT, UPDATE y DELETE, así como sus respectivos estados GRANT o DENY.

**Archivos:**
- `Consulta de verificación de roles y permisos RBAC.sql`
- `Consulta de verificación de roles y permisos RBAC.png`

### 3.2. Consulta del registro corregido de auditoría

Se ejecutó una consulta SQL para verificar el registro de auditoría correspondiente al proceso de registro de métricas ETL.

Se verificaron los siguientes campos:

- Identificador de auditoría.
- Nombre del proceso.
- Fecha de inicio y finalización.
- Cantidad de registros de origen.
- Cantidad de registros de destino.
- Estado del proceso.
- Observaciones.

En el registro consultado se observó que el proceso `registro_metricas_etl` finalizó correctamente, con 108 905 registros de origen y 219 610 registros de destino.

**Archivos:**
- `Consulta del registro corregido de auditoría.sql`
- `Consulta del registro corregido de auditoría.png`

### 3.3. Organización del repositorio de evidencias

Se organizó el repositorio GitHub del proyecto `proyecto-bd`, agrupando las evidencias en carpetas independientes para facilitar su identificación, revisión y mantenimiento.

La estructura permite acceder a los scripts SQL y capturas de pantalla correspondientes a las actividades desarrolladas.

**Archivo:**
- `Organización del repositorio de evidencias.png`

## 4. Resultados obtenidos

- Se verificaron los roles y permisos configurados mediante RBAC.
- Se comprobaron los estados GRANT y DENY de los permisos consultados.
- Se verificó el registro de auditoría del proceso de registro de métricas ETL.
- Se identificó un proceso de auditoría con estado correcto.
- Se organizó el repositorio GitHub para facilitar la revisión de las evidencias.

## 5. Conclusión

La Evidencia 12 permitió verificar los mecanismos de seguridad y control implementados en el DataMart de Olist mediante la revisión de roles, permisos y registros de auditoría.

Además, la organización del repositorio GitHub contribuye a mantener una estructura ordenada y facilita la trazabilidad de las actividades desarrolladas durante el proyecto de Business Intelligence.

