# Evidencia 7 - Prueba de Rendimiento y Latencia de KPIs Menor a 2 Segundos

## 1. Descripción

Esta evidencia contiene el script SQL y las capturas de pantalla utilizadas para evaluar el rendimiento y la latencia de las consultas de indicadores clave de rendimiento (KPIs) del DataMart Olist.

Las pruebas se realizaron sobre la base de datos `OLIST_DATAMART`, utilizando la tabla de hechos `fact_ventas` y las dimensiones relacionadas del modelo dimensional en estrella.

Se evaluó el tiempo de ejecución de las consultas SQL y el rendimiento de los objetos visuales del informe desarrollado en Power BI, con el propósito de verificar que los indicadores puedan consultarse de manera eficiente.

## 2. Objetivo

Evaluar el rendimiento y la latencia de las consultas SQL y los objetos visuales del DataMart Olist, verificando que los principales KPIs puedan ejecutarse y visualizarse en un tiempo menor a 2 segundos.

## 3. Contenido

Se incluyen los siguientes archivos:

- **PRUEBA DE RENDIMIENTO Y LATENCIA DE KPIs MENOR A 2S.sql:** Script SQL utilizado para ejecutar las consultas de los indicadores clave de rendimiento y medir su tiempo de ejecución mediante las opciones `SET STATISTICS TIME ON` y `SET STATISTICS IO ON`.
- **PRUEBA DE RENDIMIENTO Y LATENCIA DE KPIs MENOR A 2S.png:** Captura de pantalla de la ejecución de las consultas SQL y los resultados obtenidos.
- **Tiempo de renderizado de las tarjetas y gráficos.png:** Captura del Analizador de rendimiento de Power BI, donde se registran los tiempos de actualización y renderizado de los objetos visuales del informe.

## 4. Procedimiento

### 4.1. Preparación del entorno

Se seleccionó la base de datos `OLIST_DATAMART`, que contiene el modelo dimensional en estrella utilizado para el análisis de ventas.

Las tablas utilizadas fueron:

- `fact_ventas`: tabla de hechos que almacena los registros de ventas.
- `dim_vendedor`: dimensión que contiene la información de los vendedores.
- `dim_producto`: dimensión que contiene las categorías de productos.
- `dim_tiempo`: dimensión que permite analizar las ventas por año y mes.

### 4.2. Ejecución de las consultas SQL

Se ejecutaron cinco consultas correspondientes a los principales indicadores del DataMart:

1. **Ingresos Totales:** calcula la suma de los precios registrados en la tabla de hechos.
2. **Top 10 Vendedores por Ingresos:** identifica a los diez vendedores con mayores ingresos registrados.
3. **Ingresos por Categoría de Producto:** agrupa los ingresos según la categoría del producto.
4. **Evolución Mensual de Ventas:** permite analizar los ingresos mensuales agrupados por año y mes.
5. **Distribución Geográfica por Estado:** agrupa los ingresos según el estado del vendedor.

Para evaluar el rendimiento de las consultas se utilizaron las siguientes instrucciones:

```sql
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
```

Estas opciones permiten obtener información sobre el tiempo de ejecución y las operaciones de entrada y salida realizadas por SQL Server.

### 4.3. Evaluación del rendimiento en Power BI

Se utilizó el Analizador de rendimiento de Power BI para registrar los tiempos de actualización y renderizado de los objetos visuales del informe.

Se evaluaron tarjetas, gráficos y otros elementos visuales relacionados con los indicadores de ventas.

Los resultados permitieron identificar los tiempos registrados durante la actualización de los objetos visuales y comparar su comportamiento durante la ejecución del informe.

## 5. Resultados obtenidos

### 5.1. Resultados de las consultas SQL

Las consultas SQL se ejecutaron correctamente en la base de datos `OLIST_DATAMART`, obteniendo resultados para los cinco indicadores evaluados.

La captura de pantalla evidencia la ejecución de las consultas y la obtención de los resultados correspondientes a los ingresos totales, vendedores, categorías, evolución mensual y distribución geográfica.

### 5.2. Resultados del Analizador de rendimiento de Power BI

El Analizador de rendimiento permitió registrar los tiempos de actualización y renderizado de los objetos visuales del informe.

En la captura se observan tiempos de renderizado de tarjetas y gráficos que se encuentran por debajo de los 2 segundos.

Estos resultados permiten comprobar que los objetos visuales evaluados presentan tiempos de respuesta adecuados para la consulta de los indicadores.

## 6. Conclusión

La prueba de rendimiento y latencia permitió verificar el funcionamiento de las consultas SQL y evaluar el comportamiento de los objetos visuales del informe Power BI desarrollado sobre el DataMart Olist.

Las consultas ejecutadas permitieron obtener correctamente los principales indicadores de ventas, mientras que el Analizador de rendimiento proporcionó información sobre los tiempos de actualización y renderizado de los objetos visuales.

De acuerdo con los resultados registrados en las capturas de pantalla, los objetos visuales evaluados presentan tiempos de renderizado inferiores a 2 segundos, cumpliendo con el objetivo establecido para esta evidencia.

