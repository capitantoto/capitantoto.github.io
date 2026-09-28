#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Resultados IV: datasets “orgánicos” (d ≥ 4)",
  date: "2026-12-21",
  series: "fermat",
  part: 13,
  summary: [Pingüinos, iris, vino, dígitos y MNIST: qué pasa con los clasificadores basados en la distancia de Fermat fuera de las variedades sintéticas, y por qué la escala de los atributos importa más de lo que esperábamos.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)

#callout(title: "Si solo leés una cosa")[
  Los métodos basados en distancias no son invariantes a la escala de los atributos, y la distancia de Fermat tampoco. En `pinguinos`, una variable en gramos frente a tres en milímetros bastó para que #fkdc confundiera dos especies por completo; estandarizando, su $R^2$ pasa de $approx 0.42$ a $approx 0.96$. Pero estandarizar no siempre ayuda: en `digitos`, de escala homogénea, perjudica. Y en `mnist`, la concentración de las distancias convierte al clasificador de densidad en una especie de $1$-NN blando.
]


Los datasets restantes no fueron generados por nosotros a partir de una variedad conocida: `iris`, `vino` y `pinguinos` provienen de repositorios clásicos de _machine learning_, y `digitos` y `mnist` son colecciones de imágenes. Tal como se explicó en #parte("fermat-09-metodologia")[“Pretratamiento de los datos” (parte 9)], los tratamos con el mínimo preprocesamiento posible. Esa decisión, deliberada, tuvo una consecuencia que no anticipamos y que ilustramos con `pinguinos`.

= `pinguinos`: sensibilidad a la escala de los atributos <sensibilidad-escala>

#highlights_figure("pinguinos")

El dataset de pingüinos de Palmer ($K = 3$, $d = 4$) es casi linealmente separable: #logr domina con $R^2 approx 0.96$ y todos los clasificadores de referencia lo resuelven con exactitudes similares, pero toda la familia $cal(K)$ queda entre $0.40$ y $0.50$. La matriz de confusión de #fkdc muestra que no predice la clase Chinstrap en absoluto: sus 34 observaciones del conjunto de evaluación se clasifican como Adelie.

#figure(
  image("/assets/fermat/img/pinguinos-fkdc-confusion_matrix.svg", width: 70%),
  caption: flex-caption(
    [Matriz de confusión de #fkdc en `pinguinos`. La clase Chinstrap se confunde enteramente con Adelie.],
    [Matriz de confusión de #fkdc en `pinguinos`],
  ),
)

Un primer diagnóstico para entender lo que sucede consiste en observar el _pairplot_ #footnote[La grilla con los gráficos de densidad por dimensión y dispersión por cada par de dimensiones.] de la muestra (cf. @pairplot-pinguinos). Efectivamente, en las dimensiones 1, 2 y especialmente en la 3 las clases Adelie y Chinstrap están sumamente solapadas, y si uno reentrena el clasificador excluyendo alguna de ellas, la exactitud y el $R^2$ de la familia $cal(K)$ mejoran. La verdadera explicación no está en la geometría de las clases sino en sus unidades. Tres de los cuatro atributos se miden en milímetros #footnote["Largo del pico" (columna 0), "ancho del pico" (col. 1) y "largo de la aleta" (col. 2).] y toman valores entre 13 y 230; el cuarto, la masa corporal, se mide en gramos y va de 2700 a 6300. La distancia euclídea entre dos pingüinos es, a todos los efectos prácticos, su diferencia de masa, y la distancia de Fermat --- construida sobre aristas euclídeas --- hereda el problema. Adelie y Chinstrap tienen masas indistinguibles, y por eso se confunden. Los métodos que no dependen de la métrica del espacio ambiente no lo padecen: #gbt parte cada variable por separado, y #logr absorbe la escala de cada variable en su coeficiente.

#wide_figure(
  width: 110%,
  image("/assets/fermat/img/pinguinos-pairplot.svg"),
  caption: flex-caption(
    [_Pairplot_ del dataset `pinguinos`. Nótese la escala de la cuarta variable (masa corporal, en gramos) frente a las otras tres (en milímetros).],
    [_Pairplot_ de `pinguinos`],
  ),
) <pairplot-pinguinos>


// Los paneles salen de fkdc/viz.py a partir de las corridas de `pinguinos` y `pinguinos_std`;
// los valores exactos quedan en data/pinguinos-crudo-vs-std.csv.
#wide_figure(
  width: 120%,
  grid(
    columns: 2,
    gutter: 4pt,
    image("/assets/fermat/img/pinguinos-crudo-vs-std-r2.svg"), image("/assets/fermat/img/pinguinos-crudo-vs-std-accuracy.svg"),
  ),
  caption: flex-caption(
    [$R^2$ y exactitud medianos en `pinguinos` sobre los atributos crudos (punto lleno) y estandarizados en el entrenamiento (punto vacío).],
    [`pinguinos`: atributos crudos vs. estandarizados],
  ),
) <fig-pinguinos-std>

Para confirmarlo repetimos las #reps repeticiones de `pinguinos` con un único cambio: a cada clasificador se le antepuso un estandarizador #footnote[Más precisamente, se usó #link("https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.StandardScaler.html")[`sklearn.preprocessing.StandardScaler`] con parámetros por defecto, que transforma los datos sustrayendo la media y dividiendo por el desvío estándar por columna.] ajustado sobre el pliego de entrenamiento correspondiente (ficha de #ficha-de("pinguinos_std") en el Anexo de la tesis).
Con la escala corregida, la familia $cal(K)$ alcanza a los métodos lineales: #fkdc pasa de $R^2 approx 0.42$ a $approx 0.96$, a cinco milésimas de #logr, y su exactitud de $73%$ a $99%$ (@fig-pinguinos-std), mientras que #logr y #gbt --- insensibles a la escala en la práctica --- no se mueven. La lección excede a `pinguinos`: la familia $cal(K)$ no es invariante a la escala de los atributos, y en datasets con unidades heterogéneas hay que estandarizar. Las comparaciones "en crudo" de esta sección en general deben leerse con esa salvedad.

= `iris` y `vino`

#wide_figure(
  width: 120%,
  grid(
    columns: (auto, 1fr, 1fr),
    gutter: 4pt,
    align: horizon,
    [], align(center)[*$R^2$*], align(center)[*exactitud*],
    ..("iris", "vino")
      .map(d => (
        raw(d),
        image("/assets/fermat/img/" + d + "-crudo-vs-std-r2.svg"),
        image("/assets/fermat/img/" + d + "-crudo-vs-std-accuracy.svg"),
      ))
      .sum(),
  ),
  kind: image,
  caption: flex-caption(
    [$R^2$ y exactitud medianos en `iris` y `vino` sobre los atributos crudos (punto lleno) y estandarizados  (punto vacío) como en @fig-pinguinos-std.],
    [`iris` y `vino`: atributos crudos vs. estandarizados],
  ),
) <fig-iris-vino-std>

No se trata, sin embargo, de estandarizar siempre. En `iris`, con las cuatro variables en centímetros, el mismo tratamiento _empeora_ ligeramente a $cal(K)$ (#fkn pasa de $R^2 approx 0.90$ a $approx 0.84$), y en `digitos` la caída es severa, como veremos a continuación (#ficha-de("iris_std"), #ficha-de("digitos_std")). Las fichas de #ficha-de("iris") y #ficha-de("vino") --- y de sus variantes #ficha-de("iris_std") y #ficha-de("vino_std") --- están en el Anexo de la tesis: en `iris` los métodos lineales y $cal(K)$ empatan; en `vino`, cuyas 13 variables recorren cuatro órdenes de magnitud, #gbt domina con $R^2 approx 0.90$ y #logr, con $0.69$ sobre los datos crudos, muestra el mismo síntoma que la familia $cal(K)$: estandarizando, #logr sube a $0.90$ y $cal(K)$ de $R^2 approx 0.43$ a $0.84$--$0.88$, competitiva aunque todavía por debajo de #gbt.
= Alta dimensión: caracteres manuscritos (`digitos` y `mnist`)

Estas variables aleatorias se ajustan particularmente bien a la #parte("fermat-03-maldicion-y-variedades")[hipótesis de la variedad] planteada al inicio: un elemento aleatorio (el dígito) definido en una variedad que postulamos de baja dimensión, "capturado" en un soporte gráfico de alta dimensión: $d=64$ píxeles para `digitos`, $d=784$ para `mnist`.

#figure(
  image("/assets/fermat/img/digitos-mnist-ejemplos.png", width: 100%),
  caption: flex-caption(
    [Dos ejemplos por clase de `digitos` (arriba, imágenes de $8 times 8$ píxeles) y de `mnist` (abajo, $28 times 28$), semilla $s = #plotting_seed$.],
    [Ejemplos de `digitos` y `mnist`],
  ),
) <fig-ejemplos-digitos>


== `digitos`

El dataset de dígitos de scikit-learn ($N = 1797$, $K = 10$, $d = 64$, imágenes de $8 times 8$ píxeles) es el caso más favorable a $cal(K)$ en todo el experimento: #fkdc es el mejor clasificador global ($R^2 approx 0.98$), apenas por encima de #kdc ($approx 0.97$), y ambos por encima de todos los demás. Aquí la escala es homogénea --- píxeles con valores de $0$ a $16$ --- y estandarizar es contraproducente: los píxeles de los bordes, casi siempre nulos, ven su varianza inflada a $1$ y se convierten en dimensiones de ruido, con lo que #fkdc cae a $R^2 approx 0.87$ (cf. #ficha-de("digitos_std")).

#highlights_figure("digitos")

// Conteos por semilla en data/digitos-hiperparametros-K.csv (fkdc/viz.py).
Esperábamos alguna ventaja más notable de #fkdc sobre #kdc, o de #fkn sobre #kn, que no se comprobó, y los hiperparámetros elegidos repiten el patrón de `lunas_lo`. La regla de parsimonia eligió para #fkdc $alpha = 1$ en las #reps semillas, con una ventana algo menor que la de #kdc ($h approx 5.6$ contra $7.4$) que la grilla de #kdc no contenía exactamente: de allí la leve ventaja. Para #fkn, el _score_ de validación cruzada se maximizó con $alpha$ entre $1.75$ y $3.75$ en _todas_ las semillas, pero la mejora rara vez superó el desvío estándar entre pliegos y la parsimonia devolvió $alpha = 1$ en 13 de las 25.

== `mnist`

A `mnist` ($N = 60000$, $d = 784$) se lo redujo a $d = 96$ dimensiones por PCA #footnote[Número que conserva al menos el 90 % de la variación en los datos originales.] y del $N=60000$ original por cada semilla se eligió una muestra al azar _sin estratificar_ de $N=800$ para volverlo manejable #footnote[En cantidad de dimensiones, para evitar las dificultades ya expuestas; en cantidad de observaciones, para que no exploten los tiempos de cómputo de los experimentos.]. #kdc ($R^2 approx 0.77$) supera a #fkdc ($approx 0.74$) con menor dispersión; ambos superan a #gbt y quedan a la par de #logr en exactitud y $R^2$, con #svc como el más exacto. 

#highlights_figure("mnist")

// Conteos por semilla en data/mnist-hiperparametros-K.csv (fkdc/viz.py).
Aquí ni siquiera el maximizador del _score_ de validación cruzada se aparta de $alpha = 1$ para #fkdc, en ninguna semilla; para #fkn se repite lo de `digitos`, con $alpha = 1$ bajo parsimonia en 18 de las 25. Lo que sí merece atención son los anchos de banda seleccionados, entre $316$ y $562$ para #kdc y #fkdc: parecen enormes, pero hay que leerlos contra la escala de los datos, que la @tabla-escala-distancias resume para los cinco datasets orgánicos. En `mnist` la distancia mediana de una observación a su vecina más cercana es $approx 1300$, y la distancia mediana entre dos observaciones cualesquiera, $approx 2500$. Es la maldición de la dimensionalidad de la #parte("fermat-03-maldicion-y-variedades")[KDE multivariada] en acción: mientras que en `iris` o `vino` la distancia típica es entre diez y treinta veces la distancia al vecino más cercano, en `digitos` es menos de tres veces y en `mnist` menos de dos. Con las distancias así concentradas no existe una escala en la que el núcleo pese un vecindario sin pesar a casi toda la muestra --- ni siquiera con distancia geodésica ---, y la validación cruzada responde encogiendo $h$ muy por debajo de la distancia al vecino más cercano --- $5.6$ contra $18$ en `digitos`, $316$ contra $1300$ en `mnist`. Incluso ese vecino recibe un peso casi nulo y cada predicción descansa en una o dos observaciones. El clasificador de densidad degenera así en una especie de $1$-NN blando en el que el peso de cada vecino decae con la distancia en lugar de repartirse en partes iguales entre los $k$ más cercanos, lo que explicaría que #kdc supere por un buen margen a #kn no solo en $R^2$, sino también en exactitud --- especialmente en `mnist`.

El cociente de `pinguinos` en la @tabla-escala-distancias, $169$, es el reverso del mismo fenómeno: la masa en gramos estira una sola dirección y las distancias, lejos de concentrarse, quedan dominadas por ella.

// Generado por fkdc/viz.py sobre la muestra de la semilla de graficación de cada dataset.
#tabla_csv(
  "/assets/fermat/data/escala-distancias.csv",
  headers: (dataset: [dataset], d: [$d$], nn_mediana: [al vecino más cercano], pareada_mediana: [entre pares], cociente: [cociente]),
  raw-cols: ("dataset",),
  caption: [Escala de las distancias euclídeas en los datasets orgánicos (muestra con $s = #plotting_seed$): distancia mediana al vecino más cercano, distancia mediana entre pares, y su cociente.],
  short-caption: [Escala de las distancias en los datasets orgánicos],
) <tabla-escala-distancias>


#bibliography("/refs.bib", title: "Referencias")
