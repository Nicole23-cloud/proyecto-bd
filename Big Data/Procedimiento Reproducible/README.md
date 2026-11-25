# Procedimiento Reproducible – Solución Big Data

Guía paso a paso para reproducir la solución Big Data del proyecto, implementada con la **arquitectura Medallion** (Bronze, Silver y Gold) sobre el dataset **Olist** en **Databricks Free Edition**.

## Contenido de esta carpeta

| Archivo | Descripción |
|---|---|
| `Procedimiento_Reproducible.docx` | Documento con el procedimiento completo, con capturas de cada etapa |
| `README.md` | Esta guía rápida |

## Arquitectura

La solución se ejecuta en tres capas, **siempre en este orden**:

| Capa | Qué hace | Notebook |
|---|---|---|
| **Bronze** | Ingesta y almacenamiento de los datos originales | `01_BRONZE_OLIST` |
| **Silver** | Limpieza, validación y depuración (nulos, duplicados, inconsistencias) | `02_SILVER_OLIST` |
| **Gold** | Agregación y modelado para reportes e indicadores (KPI) | `[nombre del notebook Gold]` |

Los notebooks están en la carpeta `Big Data/ARQUITCTURA MEDALLION/` de este repositorio.

## Requisitos

- Cuenta gratuita en [Databricks Free Edition](https://www.databricks.com/learn/free-edition)
- Los tres notebooks (`.ipynb`) de este repositorio
- Los seis archivos CSV originales de Olist

## Cómo reproducirlo

### 1. Preparar el entorno y los datos de origen

**Crear la cuenta**
1. Ingresar a [Databricks Free Edition](https://www.databricks.com/learn/free-edition) y hacer clic en **Sign up**.
2. Elegir **Free Edition** (no la prueba gratuita) y registrarse con un correo personal.
3. Al terminar, Databricks crea automáticamente un espacio de trabajo (workspace).

**Crear el esquema, el volumen y los directorios**

| Elemento | Nombre |
|---|---|
| Catálogo | `workspace` |
| Esquema | `olist_nuevo` |
| Volumen | `olist` |
| Directorios | `Archivos.csv` y dentro `Olist_CSV` |

1. En el menú lateral, hacer clic en **Catalog** y seleccionar el catálogo `workspace`.
2. Hacer clic en **Create schema**, escribir `olist_nuevo` y hacer clic en **Create**.
3. Dentro del esquema, hacer clic en **Create > Volume**, escribir `olist`, dejar **Managed volume** y hacer clic en **Create**.
4. Abrir el volumen y hacer clic en **Create directory**. Crear `Archivos.csv` y, dentro de él, `Olist_CSV`.

**Subir los archivos CSV**
1. Abrir el directorio `Olist_CSV`.
2. En el menú lateral, hacer clic en **New > Add or upload data > Upload files to a volume**.
3. Seleccionar los seis archivos CSV de la tabla siguiente y hacer clic en **Upload**.

| Archivo CSV | Contenido |
|---|---|
| `olist_customers_dataset.csv` | Clientes |
| `olist_orders_dataset.csv` | Pedidos |
| `olist_order_items_dataset.csv` | Detalle de pedidos |
| `olist_products_dataset.csv` | Productos |
| `olist_sellers_dataset.csv` | Vendedores |
| `olist_category_name_translation_dataset.csv` | Traducción de categorías |

Los datos deben quedar en esta ruta, que es la que lee el notebook Bronze:

```
/Volumes/workspace/olist_nuevo/olist/Archivos.csv/Olist_CSV/
```

> Si usas otros nombres, actualiza la ruta en la primera celda del notebook Bronze.

### 2. Ejecutar las tres capas

1. Importar el notebook de la capa **Bronze** y ejecutarlo con **Run All**.
2. Importar el notebook de la capa **Silver** y ejecutarlo con **Run All**.
3. Importar el notebook de la capa **Gold** y ejecutarlo con **Run All**. Este notebook vuelve a ejecutar primero la lógica de Silver para que los datos estén actualizados.

> Los pasos detallados, con capturas, están en `Procedimiento_Reproducible.docx`.

## Indicadores (KPI) generados en Gold

1. Ingresos totales
2. Top 10 vendedores con más ventas
3. Top 10 categorías de productos más vendidas
4. Evolución mensual de ventas
5. Variación porcentual frente al mes anterior
6. Distribución geográfica de ventas
7. Total de vendedores
8. Total de pedidos entregados
9. Total de artículos vendidos
10. Top 10 estados con mayores ingresos

### Valores de referencia

Si la ejecución fue correcta, estos indicadores deben coincidir:

| KPI | Valor |
|---|---|
| Ingresos totales | 13,045,531 |
| Total de vendedores | 2,912 |
| Total de pedidos entregados | 95,127 |
| Total de artículos vendidos | 108,638 |

