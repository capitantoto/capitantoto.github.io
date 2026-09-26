#import "../lib.typ": *

#let meta = (
  title: "Clasificadores sin entrenamiento contra la distancia de Fermat",
  date: none,
  series: none,
  part: none,
  summary: [Borrador de un experimento: sumar al banco de pruebas de la tesis un LLM que clasifica filas serializadas y clasificadores sobre _embeddings_ congelados, y ver dónde quedan frente a #smallcaps[f-KDC] y compañía.],
  status: "stub",
  lang: "es",
)
#show: post.with(..meta)

_Borrador: este post es un esqueleto; el cuerpo es texto de relleno._

= La idea

La tesis compara clasificadores de densidad por núcleos, con y sin distancia de Fermat (KDC, f-KDC), contra un puñado de referencias clásicas (KN, GNB, LR, SVC, GBT), todos entrenados sobre cada dataset. Hoy existe otra familia que no entra en esa comparación: modelos preentrenados que clasifican "de fábrica". ¿Qué pasa si a un LLM le pasamos cada fila como texto y le pedimos la clase? ¿Y si en lugar de entrenar sobre las coordenadas crudas entrenamos un clasificador simple sobre _embeddings_ congelados de esas filas o, para `digitos` y `mnist`, de las imágenes? La pregunta no es si ganan, sino dónde: en los datasets sintéticos de baja dimensión (lunas, círculos, espirales, hélices) no hay conocimiento previo que aprovechar, y en los orgánicos (`iris`, `vino`, `pinguinos`) el modelo quizás ya "sabe" la respuesta.

= Plan

- *Clasificadores nuevos.*
  - LLM _zero-shot_: prompt con la descripción de los atributos y la fila serializada; la probabilidad de cada clase sale de los _logprobs_ de las etiquetas, para poder calcular $R^2$ y no solo exactitud.
  - KN y LR sobre _embeddings_ de texto congelados de las filas serializadas, con las mismas grillas de hiperparámetros que usa la tesis para KN y LR.
  - KN y LR sobre _embeddings_ de imagen para `digitos` y `mnist` (renderizando cada vector como imagen de 8×8 o 28×28).
- *Datasets.* Los mismos del banco de pruebas: sintéticos (`lunas`, `circulos`, `espirales`, `anteojos`, `eslabones`, `helices`, `hueveras`, `pionono`) y orgánicos (`iris`, `vino`, `pinguinos`, `digitos`, `mnist`, más las variantes estandarizadas).
- *Serialización.* Probar al menos dos formatos: `atributo: valor` con nombres reales cuando existen, y coordenadas anónimas (`x1`, `x2`, …) para medir cuánto aporta el nombre de las columnas. Fijar la precisión numérica.
- *Integración con el arnés.* Envolver cada clasificador como estimador de `scikit-learn` para que entre en `Tarea` junto a los demás: mismos _splits_ (50 % de evaluación), mismas 25 semillas derivadas de la semilla principal, validación cruzada de 5 pliegues donde haya hiperparámetros.
- *Métricas.* Exactitud y $R^2$ de McFadden sobre el conjunto de evaluación, reportadas con la misma mediana y dispersión por semilla que en la tesis, para que las tablas sean directamente comparables.
- *Costo.* Tokens y dólares por dataset, latencia por fila y costo de calcular los _embeddings_; comparado con el tiempo de ajuste de f-KDC.

= Resultados

#lorem(80)

#lorem(60)

= Discusión

#lorem(70)
