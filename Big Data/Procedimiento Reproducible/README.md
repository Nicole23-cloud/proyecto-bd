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
- Los archivos de datos originales de Olist cargados en Databricks

## Cómo reproducirlo

1. Crear la cuenta en Databricks Free Edition y configurar el entorno de trabajo.
2. Importar el notebook de la capa **Bronze** y ejecutarlo con **Run All**.
3. Importar el notebook de la capa **Silver** y ejecutarlo con **Run All**.
4. Importar el notebook de la capa **Gold** y ejecutarlo con **Run All**. Este notebook vuelve a ejecutar primero la lógica de Silver para que los datos estén actualizados.

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

## Autores

- [Nombre(s) del equipo]
- [Curso / institución]
