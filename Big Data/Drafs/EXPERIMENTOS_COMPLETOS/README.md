# Experimentos: Batch Completo vs. Batch Incremental vs. Streaming

Benchmark experimental en **Databricks** (PySpark / Delta Lake / Auto Loader) que evalúa y compara distintas estrategias de ingesta y procesamiento de datos sobre el dataset de Olist (`workspace.olist_nuevo.bronze_detalles`) a través de **7 experimentos** enfocados en **velocidad, latencia, correctitud y costo**.

---

## Contenido de la Carpeta

* [`07_EXPERIMENTOS_COMPLETOS_BATCH_VS_STREAMING`](./07_EXPERIMENTOS_COMPLETOS_BATCH_VS_STREAMING) — Notebook principal con el código completo de configuración, ejecución, métricas y gráficas de los 7 experimentos.
* **Evidencias de ejecución (capturas de resultados y gráficas):**
  * [`EXP - 01.png`](./EXP%20-%2001.png) — Resultados del Experimento 1: Eficiencia.
  * [`EXP - 02.png`](./EXP%20-%2002.png) — Resultados del Experimento 2: Latencia de extremo a extremo.
  * [`EXP - 03.png`](./EXP%20-%2003.png) — Resultados del Experimento 3: Tamaño de llegadas (punto de cruce).
  * [`EXP - 04.png`](./EXP%20-%2004.png) — Resultados del Experimento 4: Actualizaciones y borrados (`MERGE`).
  * [`EXP - 05.png`](./EXP%20-%2005.png) — Resultados del Experimento 5: Datos tardíos (*late arriving data*).
  * [`EXP - 06.png`](./EXP%20-%2006.png) — Resultados del Experimento 6: Fallos y duplicados (idempotencia).
  * [`EXP - 07.png`](./EXP%20-%2007.png) — Resultados del Experimento 7: Modelo de costo (horas de cómputo/día).

---

## Estrategias Evaluadas

* **A. Batch completo:** Con cada llegada relee todo el historial acumulado y sobrescribe (`overwrite`) la tabla destino.
* **B. Streaming (Auto Loader):** Procesamiento estructurado con `cloudFiles` y gestión de estado mediante `checkpointLocation`.
* **C. Batch incremental:** Procesa únicamente los archivos nuevos mediante `append` o `MERGE`, controlando el estado desde el código.
* **D. Batch incremental con marca de agua *(Exp. 5)*:** Filtra e ingesta únicamente registros cuyo timestamp sea mayor al máximo ya cargado (`ts > max(ts)`).

---

## Resumen de Experimentos y Resultados

| # | Experimento | Dimensión | Pregunta Clave | Evidencia |
|---|---|---|---|---|
| **1** | **Eficiencia** | Velocidad | ¿Cuánto tarda cada forma cuando llegan tandas sucesivas (~20% c/u)? | [Ver captura](./EXP%20-%2001.png) |
| **2** | **Latencia** | Latencia | ¿Cuánto tarda un dato en estar disponible desde que llega el archivo? | [Ver captura](./EXP%20-%2002.png) |
| **3** | **Tamaño de llegadas** | Velocidad | ¿A partir de qué volumen de filas conviene procesar incrementalmente? | [Ver captura](./EXP%20-%2003.png) |
| **4** | **Updates y Deletes** | Correctitud + Velocidad | ¿Qué ocurre al aplicar cambios (`U`, `D`, `I`) con `MERGE` vs. `append` ingenuo? | [Ver captura](./EXP%20-%2004.png) |
| **5** | **Datos tardíos** | Correctitud | ¿Qué estrategia pierde registros atrasados al usar marca de agua vs. checkpoint? | [Ver captura](./EXP%20-%2005.png) |
| **6** | **Fallos (Idempotencia)** | Correctitud | ¿Qué ocurre si el proceso cae tras escribir y se reintenta (`txnAppId`/`txnVersion`)? | [Ver captura](./EXP%20-%2006.png) |
| **7** | **Costo (Modelo)** | Costo | ¿Cuántas horas de cómputo diarias consume cada estrategia según la frecuencia? | [Ver captura](./EXP%20-%2007.png) |

---

## Visualización de Resultados

### Experimento 1: Eficiencia
![Experimento 1](./EXP%20-%2001.png)

### Experimento 2: Latencia de extremo a extremo
![Experimento 2](./EXP%20-%2002.png)

### Experimento 3: Tamaño de llegadas (Punto de cruce)
![Experimento 3](./EXP%20-%2003.png)

### Experimento 4: Actualizaciones y borrados (`MERGE`)
![Experimento 4](./EXP%20-%2004.png)

### Experimento 5: Datos tardíos
![Experimento 5](./EXP%20-%2005.png)

### Experimento 6: Fallos y duplicados (Idempotencia)
![Experimento 6](./EXP%20-%2006.png)

### Experimento 7: Modelo de costo
![Experimento 7](./EXP%20-%2007.png)

---

## Conclusiones Principales

* **Escalabilidad (Exp. 1 y 3):** El batch completo incrementa su tiempo linealmente con el historial acumulado, mientras que streaming y batch incremental se mantienen estables. Sin embargo, en lotes muy pequeños pesa el *overhead* inicial (checkpoints y metadatos).
* **Latencia (Exp. 2):** La latencia de extremo a extremo está determinada principalmente por el intervalo de sondeo/ejecución y no solo por el motor.
* **Integridad de datos (Exp. 4, 5 y 6):**
  * Un `append` incremental sin `MERGE` corrompe los datos ante actualizaciones o borrados.
  * El filtrado por marca de agua (`ts > max(ts)`) descarta datos tardíos, a diferencia del seguimiento por archivo o checkpoint.
  * Ante caídas a mitad de ejecución, las escrituras incrementales requieren idempotencia (`txnAppId` / `txnVersion` en Delta Lake) para evitar duplicados.
* **Compromiso Costo vs. Latencia (Exp. 7):** No existe una única estrategia óptima; el batch completo es simple e idempotente por defecto pero no escala, mientras que streaming ofrece la menor latencia a cambio de mayor complejidad operativa y consumo continuo.

---

## Requisitos y Ejecución

1. Contar con la tabla origen `workspace.olist_nuevo.bronze_detalles` en Databricks (generada en la capa Bronze).
2. Importar el notebook [`07_EXPERIMENTOS_COMPLETOS_BATCH_VS_STREAMING`](./07_EXPERIMENTOS_COMPLETOS_BATCH_VS_STREAMING) en el workspace de Databricks.
3. Ajustar los parámetros iniciales en el **Paso 1** según el entorno (`RAPIDO = False` para volumen completo o `True` para pruebas rápidas; `STREAMING_CONTINUO = False` en entornos Serverless).
4. Ejecutar todas las celdas; al finalizar, las métricas consolidan automáticamente en la tabla Delta `workspace.olist_exp.cuadro_resultados_completo`.
