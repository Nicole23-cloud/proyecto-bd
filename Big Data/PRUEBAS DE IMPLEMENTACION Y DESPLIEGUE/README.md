# Suite de Pruebas y Calidad de Datos — Pipeline Olist (`04_PRUEBAS_OLIST`)

Suite automatizada de aseguramiento de calidad (QA) en **Databricks** (PySpark / Spark SQL / Unity Catalog) para validar el pipeline Medallion **Bronze → Silver → Gold** sobre el dataset de Olist.

Cada caso de prueba está vinculado a un requisito funcional (`RF`) o no funcional (`RNF`), registra su estado (`PASS`, `FAIL`, `ERROR`, `OMITIDA`) en Delta Lake (`workspace.olist_qa.resultados`) y exporta evidencias auditablemente trazables.

---

## Archivo Principal

* [`04_PRUEBAS_OLIST (1).ipynb`](./04_PRUEBAS_OLIST%20(1).ipynb) — Notebook ejecutable con el motor de pruebas `@prueba`, definición de 21 requisitos, 37 casos de prueba automatizados y generación de la matriz de trazabilidad.

---

## Cobertura de Pruebas (37 Casos Ejecutados)

| Categoría | Código | Cantidad | Alcance y Validaciones Principales |
|---|---|---|---|
| **Unitarias** | `UT-01` a `UT-07` | 7 | Funciones de limpieza en DataFrames sintéticos: deduplicación, nulos, trim/case de ciudad y UF, filtrado de pedidos `delivered`, validación de rangos de precios/dimensiones y seudonimización determinista (`xxhash64`). |
| **Integración** | `IT-01` a `IT-06` | 6 | Paridad de conteos CSV vs. Bronze, existencia de las 22 tablas del ecosistema (6 Bronze, 6 Silver, `gold_ventas`, 9 KPIs), retención Silver ≤ Bronze, recálculo de `JOIN` en `gold_ventas` y orden cronológico de ejecución mediante `DESCRIBE HISTORY`. |
| **Calidad de Datos** | `DQ-01` a `DQ-07` | 7 | Completitud de campos obligatorios, unicidad de claves primarias/compuestas, integridad referencial sin huérfanos (4 relaciones), validez de dominios (27 estados UF de Brasil, rangos de fechas 2016–2018) y retención de pedidos entregados. |
| **Seguridad** | `SEC-01` a `SEC-05`, `SEC-07` | 6 | Auditoría de permisos (`SHOW GRANTS`) en esquemas, volúmenes y tablas bajo Unity Catalog (principio de mínimo privilegio), ausencia de columnas PII (`email`, `cpf`, `phone`, `zip_code`), cobertura del 100% de seudónimos y prueba funcional de *Column Masking*. |
| **Aceptación (UAT)** | `UAT-01` a `UAT-11` | 11 | Conciliación financiera y operativa independiente desde Bronze y `gold_ventas` contra los 9 KPIs (`KPI-01` a `KPI-09`), variación porcentual mensual, cobertura geográfica de los 27 estados y validación del umbral de pérdida de ingresos por productos sin categoría (`1.33% <= 5.0%`). |

---

## Trazabilidad y Artefactos Generados

Al ejecutar el notebook, se crean y actualizan automáticamente los siguientes objetos en el esquema `workspace.olist_qa`:

* **Tablas Delta:**
  * `workspace.olist_qa.requisitos` — Catálogo de 21 requisitos funcionales (`RF-01` a `RF-13`) y no funcionales (`RNF-01` a `RNF-08`).
  * `workspace.olist_qa.resultados` — Histórico de ejecuciones identificado por `run_id`, usuario, resultado y detalle obtenido.
* **Evidencias exportadas en `/Volumes/workspace/olist_qa/evidencias/`:**
  * `matriz_trazabilidad_<RUN_ID>.csv` — Cruce completo *Requisito → Prueba → Resultado → Evidencia*.
  * `historial_tablas_<RUN_ID>.csv` — Marcas de tiempo de última escritura por capa.
  * `grants_<RUN_ID>.csv`, `grants_volume_<RUN_ID>.csv`, `grants_tablas_<RUN_ID>.csv` — Respaldo de concesiones de seguridad en Unity Catalog.

---

## Requisitos y Orden de Ejecución

1. Haber ejecutado previamente el pipeline completo en Databricks:
   1. `01_BRONZE_OLIST`
   2. `02_SILVER_OLIST`
   3. `03_GOLD_OLIST`
2. Abrir [`04_PRUEBAS_OLIST (1).ipynb`](./04_PRUEBAS_OLIST%20(1).ipynb) en Databricks y ejecutar todas las celdas (**Run all**).
3. Revisar la tabla resumen final y verificar que la consulta de pruebas con estado `FAIL` o `ERROR` devuelva 0 registros.
