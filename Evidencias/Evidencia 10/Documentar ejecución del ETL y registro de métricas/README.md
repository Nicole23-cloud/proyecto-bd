# Evidencia 10 - Ejecución del ETL y Registro de Métricas

## 1. Descripción

Esta evidencia contiene el script SQL y las capturas de pantalla utilizadas para ejecutar el proceso ETL del DataMart Olist y registrar las métricas correspondientes a su ejecución.

El proceso se realiza sobre la base de datos `OLIST_DATAMART`, utilizando los procedimientos almacenados `sp_ejecutar_etl_olist` y `sp_registrar_metricas_etl`.

Asimismo, se utilizan las tablas de auditoría y métricas para almacenar información sobre los registros procesados, el estado de ejecución y los resultados obtenidos durante el proceso de carga de datos.

## 2. Objetivo

Ejecutar el proceso ETL del DataMart Olist y registrar las métricas correspondientes, permitiendo verificar el correcto procesamiento y carga de los datos, así como mantener un historial de auditoría de las ejecuciones realizadas.

## 3. Contenido

Se incluyen los siguientes archivos:

- **E-10.sql:** Script SQL utilizado para ejecutar el proceso ETL, registrar las métricas y consultar los resultados de auditoría.
- **E-10.png:** Captura de pantalla de la ejecución del script SQL y los resultados obtenidos en las tablas `auditoria_etl` y `metricas_etl`.

## 4. Procedimiento

### 4.1. Selección de la base de datos

Se seleccionó la base de datos `OLIST_DATAMART`, donde se encuentra implementado el modelo dimensional y los procedimientos almacenados necesarios para ejecutar el proceso ETL.

### 4.2. Ejecución del proceso ETL

Se ejecutó el procedimiento almacenado:

```sql
EXEC dbo.sp_ejecutar_etl_olist;
```

Este procedimiento realiza el proceso de extracción, transformación y carga de los datos hacia el DataMart Olist.

### 4.3. Registro de métricas

Después de completar la ejecución del ETL, se ejecutó el procedimiento:

```sql
EXEC dbo.sp_registrar_metricas_etl;
```

Este procedimiento registra las métricas relacionadas con el proceso ejecutado, incluyendo la cantidad de registros procesados en las tablas del DataMart.

### 4.4. Verificación de auditoría

Se consultó la tabla `auditoria_etl` para verificar el historial de ejecuciones del proceso ETL.

```sql
SELECT *
FROM dbo.auditoria_etl
ORDER BY id_auditoria DESC;
```

Esta consulta permite visualizar las ejecuciones más recientes, sus fechas de inicio y finalización, la cantidad de registros de origen y destino, el estado del proceso y las observaciones registradas.

### 4.5. Verificación de métricas

Finalmente, se consultó la tabla `metricas_etl` para visualizar las métricas correspondientes a la última auditoría registrada.

```sql
SELECT *
FROM dbo.metricas_etl
WHERE id_auditoria = (
    SELECT MAX(id_auditoria)
    FROM dbo.auditoria_etl
);
```

Esta consulta permite verificar las métricas asociadas a la ejecución más reciente del ETL.

## 5. Resultados obtenidos

### 5.1. Resultado de la ejecución ETL

La ejecución del procedimiento almacenado `sp_ejecutar_etl_olist` se completó correctamente, registrándose el estado `correcto` en la tabla de auditoría.

En la captura de pantalla se observa el historial de ejecuciones, incluyendo los registros de origen y destino, las fechas de ejecución y las observaciones correspondientes.

### 5.2. Resultado del registro de métricas

Se ejecutó correctamente el procedimiento `sp_registrar_metricas_etl`, generando registros en la tabla `metricas_etl`.

Las métricas permiten verificar la cantidad de registros almacenados en las tablas dimensionales y en la tabla de hechos `fact_ventas`, así como los valores relacionados con los ingresos, fletes y artículos procesados.

## 6. Conclusión

La ejecución del proceso ETL y el registro de métricas permitieron verificar el correcto funcionamiento de los procedimientos almacenados implementados en el DataMart Olist.

La tabla `auditoria_etl` proporciona un historial de las ejecuciones realizadas, mientras que la tabla `metricas_etl` permite consultar información cuantitativa sobre los registros procesados.

De esta manera, se fortalece el control, la trazabilidad y la supervisión del proceso ETL, facilitando la verificación de los resultados y el seguimiento de futuras ejecuciones del DataMart.
