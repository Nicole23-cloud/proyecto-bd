# 05. Seguridad - OLIST

## 1. Descripción

Esta carpeta contiene los scripts SQL utilizados para implementar y gestionar los mecanismos de seguridad del DataMart OLIST, garantizando el acceso controlado a la información y la protección de los datos almacenados.

Se consideran aspectos relacionados con la gestión de usuarios, roles, permisos y auditoría de las operaciones realizadas en la base de datos.

## 2. Objetivo

Implementar mecanismos de seguridad que permitan controlar el acceso al DataMart OLIST, proteger la información y garantizar que los usuarios puedan realizar únicamente las operaciones autorizadas.

## 3. Archivos contenidos

| Archivo | Descripción |
|---|---|
| `seguridad_roles_olist.sql` | Contiene los scripts SQL para la creación y configuración de roles, asignación de permisos y control de acceso al DataMart. |

## 4. Mecanismos de seguridad

### 4.1. Control de acceso basado en roles (RBAC)

Permite organizar los permisos según las funciones y responsabilidades de los usuarios.

### 4.2. Gestión de permisos

Se establecen permisos para controlar las operaciones que pueden realizar los usuarios sobre las tablas y objetos de la base de datos.

### 4.3. Auditoría

Permite registrar y verificar determinadas operaciones realizadas sobre la información, facilitando el seguimiento y control de los cambios.

## 5. Procedimiento de ejecución

1. Crear o seleccionar la base de datos `DATAMART_OLIST`.
2. Ejecutar el script `seguridad_roles_olist.sql`.
3. Verificar la creación de los roles y la asignación de permisos.
4. Ejecutar las consultas de comprobación de seguridad.
5. Registrar los resultados y guardar las evidencias correspondientes.

## 6. Resultados esperados

- Roles de seguridad correctamente configurados.
- Permisos asignados según las responsabilidades de cada usuario.
- Acceso controlado a los objetos de la base de datos.
- Operaciones de auditoría verificables.
- Protección de la información del DataMart.

