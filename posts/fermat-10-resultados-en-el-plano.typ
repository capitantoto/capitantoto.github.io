#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Resultados I: el marcador global y las curvas en el plano",
  date: "2026-11-30",
  series: "fermat",
  part: 10,
  summary: [Quién ganó en los 20 datasets, y cómo se comportan #fkdc y #fkn en lunas, círculos, espirales y anteojos, con poco y con mucho ruido.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)

#callout(title: "Si solo leés una cosa")[
  Ningún clasificador domina. Por $R^2$ mediano, la distancia de Fermat alcanza el máximo en 12 de los 20 datasets (7 con #fkdc, 5 con #fkn); por exactitud la ventaja se diluye y #svc lidera. En las curvas del plano con poco ruido, #fkdc tiene el mejor $R^2$ con una exactitud comparable a la del mejor; con mucho ruido el terreno se nivela y las ventajas disminuyen. Lo que no captan los números: las fronteras de #fkdc siguen la forma de las variedades.
]


= In toto
En total, ejecutamos unas 4800 tareas: 4000 producto de #reps repeticiones por dataset y clasificador sobre 20 datasets y 8 clasificadores diferentes, más 800 sobre variantes estandarizadas de cuatro de esos datasets (#parte("fermat-13-datasets-organicos")[`pinguinos`: sensibilidad a la escala de los atributos]). De los clasificadores ya se habló; los datasets --- cuyos nombres se estilan en fuente `monoespacio` --- se presentarán cuando nos aboquemos al análisis de cada uno.

Designaremos por $cal(K) = {#fkdc, #kdc, #fkn, #kn}$ a la familia de estimadores basados en densidad por núcleos, sobre la que se concentra el análisis comparativo de los resultados. Entre los clasificadores blandos, la distancia de Fermat alcanzó el máximo $R^2$ mediano en 12 de los 20 datasets: 7 con #fkdc y 5 con #fkn, dos de estos empatados con #kn. En todo este recuento, un empate en la mediana --- a cuatro decimales, como en las tablas resumen --- se cuenta para cada clasificador que lo alcanza, así que los totales pueden superar los 20 datasets.

#gbt alcanzó el máximo en 5 datasets, entre ellos varios con mucho ruido (`_hi` y `_12`). #kdc lo hizo en 2, consolidando la técnica de la #parte("fermat-05-densidades-en-variedades")[definición de KDE en variedades de Riemann] como competitiva de por sí. Por último, #kn y #logr fueron los mejores en mediana en 2 y 1 datasets respectivamente, y solo #gnb no consiguió ningún podio --- aunque resultó competitivo en casi todo el tablero.
La amplia distribución de algoritmos óptimos según las condiciones del dataset pone de relieve la existencia de ventajas relativas en todos ellos.

#tabla_clf_destacados(
  "/assets/fermat/data/mejor-clf-por-dataset-segun-r2-mediano.csv",
  caption: [_Clasificadores con mayor $R^2$ mediano por dataset_, sobre los atributos crudos (cf. #parte("fermat-13-datasets-organicos")[`pinguinos`: sensibilidad a la escala de los atributos]). #fkdc alcanza el máximo en 7 de los 20 datasets, #fkn y #gbt en 5, #kdc y #kn en 2 y #logr en 1; los empates se cuentan para cada clasificador que los alcanza.],
  short-caption: [Mejor clasificador por dataset según $R^2$ mediano.],
)

El mismo análisis con métrica de exactitud es menos favorable a la familia $cal(K)$, que de ser óptima en 14 de 20 datasets por $R^2$ pasa a serlo en 9 de 20 por exactitud, casi siempre empatados entre sí. #svc, entrenado en consecuencia, obtiene la mayor exactitud mediana en 7 de los 20 datasets, con rendimiento sólido en todo tipo de datasets. #gbt vuelve a brillar en aquellos con mucho ruido y siguen figurando como competitivos numerosos estimadores: hasta #fkdc retiene su título en 1 dataset, `espirales_lo`.

#tabla_clf_destacados(
  "/assets/fermat/data/mejor-clf-por-dataset-segun-accuracy-mediano.csv",
  caption: [_Clasificadores con mayor exactitud mediana por dataset._ #svc lidera con 7 máximos, seguido por #gbt con 6 y por #fkn y #kn con 5 cada uno, casi siempre empatados; los métodos basados en densidad ceden terreno respecto del ranking por $R^2$.],
  short-caption: [Mejor clasificador por dataset según exactitud mediana.],
)

No es nuestra intención abrumar al lector, así que a continuación haremos un paneo arbitrario por algunos de los resultados que nos resultaron más llamativos o se acercan lo suficiente a algún resultado de la literatura previa como para merecer un comentario aparte #footnote[Si usted, querido lector, es un alma crítica e inquieta y decide clonar el repositorio, cambiar las semillas y reproducir los experimentos --- ¡o aun incorporar nuevos datasets y algoritmos! --- por favor, no deje de hacer un _pull request_ al repositorio original.].
= Lunas, círculos y espirales ($d=2, d_MM=1, K=2$)

Para comenzar, consideramos el caso no trivial más sencillo con $d > d_MM$: $d=2, d_MM=1, K=2$, y exploramos tres curvas muestreadas con un poco de "ruido blanco" añadido: dos "lunas" --- semicírculos no superpuestos con sus centros en un extremo del semicírculo opuesto ---, dos círculos concéntricos y dos espirales con el mismo origen y sentido de rotación pero desfasadas medio giro #footnote[No entraremos en demasiado detalle sobre cómo se generó o de dónde se tomó cada dataset para mantener el foco en los resultados experimentales. Las rutinas para generar cada conjunto de datos se pueden leer en `fkdc/datasets.py`.].


#defn(
  "ruido blanco",
)[Sea $W = (W_1, dots, W_d) in RR^d$ una variable aleatoria tal que $"E"(W_i)=0, "Var"(W_i)=SS thick forall i in [d]$. Llamaremos "ruido blanco con escala $SS$" a $N$ realizaciones #iid de $W, thin bu(W) in RR^(N times d)$.] <ruido-blanco>


#let plotting_seed = 1075
#wide_figure(
  kind: image,
  fig-grid(
    columns: "repeat(3, 1fr)",
    img("lunas_lo-scatter.svg"), img("circulos_lo-scatter.svg"), img("espirales_lo-scatter.svg"),
  ),
  caption: flex-caption["Lunas", "Círculos" y "Espirales", con $d = 2, d_MM = 1$ y $s=#plotting_seed$ en régimen de "bajo ruido"][ "Lunas", "Círculos" y "Espirales" con bajo ruido],
) <fig-2>

#obs[Dado que la dimensión de la variedad subyacente ($d_MM=1$) es menor que la del espacio ambiente ($d=2$), sin ruido las observaciones caerían exactamente sobre la curva y la tarea de clasificación resultaría casi trivialmente sencilla. Para acercarnos a un escenario más realista que simule la incertidumbre inherente en cualquier toma de muestras, las observaciones se generan dentro de un _tubo_ de radio $tau$ alrededor de #MM, es decir, en el conjunto $B(MM, tau) = {x in RR^d : min_(y in MM) norm(x - y)_2 <= tau}$, tal como #cite(<mckenziePowerWeightedShortest2019>, form: "prose") mencionan como posible extensión a su trabajo.]



En una primera variación con "bajo ruido" (y sufijada "`_lo`") #footnote[En inglés, _low_ y _high_ --- baja y alta --- son casi homófonos de _lo_ y _hi_.], a las observaciones #XX sobre la variedad #MM se les añadió ruido blanco con un parámetro de escala $sigma$ según la distribución normal bivariada, $epsilon ~ cal(N)_2(0, sigma^2 bu(I))$. $sigma$ se ajustó a cada dataset para resultar "poco" relativo a la escala de los datos #footnote[La distribución normal multivariada no determina un radio finito para el tubo $B(MM, tau)$. En la práctica, con muestras relativamente pequeñas como las nuestras --- 400 observaciones por clase --- el tubo de radio $tau = 6 sigma$ deja afuera alguna observación con probabilidad del orden de $10^(-5)$.].
$ sigma_"lunas" = 0.25 quad sigma_"circulos" = 0.08 quad sigma_"espirales" = 0.1. $

En los tres datasets, el resultado es muy similar: #fkdc es el estimador que mejor $R^2$ reporta, y en todos tiene una exactitud comparable a la del mejor para el dataset. En ninguno de los tres datasets #fkdc tiene una exactitud muy distinta a la de #kdc, pero saca ventaja en $R^2$ para `lunas_lo` y `espirales_lo`.

Entre el resto de los algoritmos, los no paramétricos son competitivos: #kn, #fkn y #gbt, mientras que #gnb y #logr rinden mal pues las _fronteras de decisión_ que pueden representar no cortan bien a los datos.



#obs("riesgos computacionales")[
  Una dificultad de entrenar un clasificador _original_ es que hay que definir las rutinas numéricas "a mano", usando librerías estándares como `numpy` y `scipy` para operaciones elementales y nada más. Además, depurar #footnote[_Debug_ en inglés.] errores en rutinas numéricas es particularmente difícil, puesto que las operaciones no producen errores obvios, sino que retornan valores irrisorios #footnote[Hubo montones de estos, cuya resolución progresiva dio lugar al módulo `fkdc/fermat.py` y las clases `SampleFermatDistance, FermatKNeighborsClassifier, FermatKDE` y `KDClassifier` --- que acepta tanto la métrica euclídea como de Fermat --- en la pequeña librería que acompaña esta tesis. Creemos que no los hay, pero todo error de cálculo que pueda persistir en el producto final depende exclusivamente de mí.].

  A ello se le suma que el cómputo de la distancia muestral de Fermat #sfd es realmente caro. Aun siguiendo "buenas prácticas computacionales" #footnote[Como sumar logaritmos en lugar de multiplicar valores "crudos" siempre que sea posible.], implementaciones ingenuas pueden resultar impracticables hasta en datasets de baja cardinalidad y pocas dimensiones.

  Por otra parte, el #parte("fermat-07-distancia-de-fermat")[teorema de convergencia de $D_(Q, alpha)$] nos garantiza que cuando $N->oo, quad sfd -> cal(D)_(f, beta)$, pero esa es una afirmación asintótica y aquí estamos tomando $k=5$ pliegos de entre $N = 800$ observaciones, con $N_"train" = N_"eval" = N slash 2$ observaciones para un tamaño muestral efectivo de $(k-1)/k N/2 = 320$. ¿Es 320 un tamaño muestral "lo suficientemente grande" para que sea válida?

  Por todo ello, que la bondad de los clasificadores _no empeore_ con el uso de #sfd en lugar de #euc es de por sí un hito importante.
]

== `lunas_lo`

A continuación presentaremos el resumen de los resultados obtenidos para este dataset. Como tal gráfica de síntesis se repetirá por dataset, amerita una breve descripción. Consta de dos columnas: en la izquierda, un gráfico de dispersión 2D o 3D de algunas dimensiones del dataset y una tabla con la exactitud y el $R^2$ mediano por algoritmo. Para ayudar a la comprensión de un vistazo, los algoritmos se ordenan por $R^2$ descendente, el mejor se resalta en verde, y atenuados en gris figuran aquellos cuya mediana de $R^2$ esté por debajo del primer cuartil del mejor --- salvo #svc, que no reporta $R^2$ #footnote[Una regla similar a la R1SD hubiese sido más consistente, pero al presentar los datos con boxplots esta demarcación nos resultó más natural.].

En la columna derecha, los boxplots de ambas métricas para todos los clasificadores; los atenuados en la tabla se dibujan translúcidos, y el eje vertical se recorta por debajo del peor valor de #fkdc. Las líneas punteadas horizontales marcan la mediana del mejor algoritmo en cada métrica. Las fichas de todos los datasets, incluidas las que no se reproducen en esta serie, están reunidas en el Anexo de la tesis.

#highlights_figure("lunas_lo")

#fkdc tiene el mejor rendimiento, pero no por mucho, y aun #logr rinde decentemente en `lunas_lo`:

#figure(
  image("/assets/fermat/img/lunas_lo-lr-decision_boundary.svg", height: 17em),
  caption: flex-caption(
    [Frontera de decisión para #logr en `lunas_lo`, $s = #plotting_seed$],
    [Frontera de #logr en `lunas_lo`],
  ),
)
Nótese que la frontera _lineal_ entre clases (al centro de la banda gris) aprendida por #logr separa "bastante bien" la muestra: pasa por el punto medio del segmento que une el "centro" de cada luna, y de todas las direcciones con tal origen, elige la que mejor separa las clases. _Grosso modo_, en el tercio de la muestra más cercano a la frontera, alcanza una exactitud de $approx 50%$, pero en los tercios al interior de cada una acierta virtualmente el 100%, para un promedio global de $1/3 dot 50% + 2/3 dot 100% approx 86.7%$, muy cercano a la exactitud observada.

== `circulos_lo` y `espirales_lo`

#highlights_figure("circulos_lo")
#highlights_figure("espirales_lo")

Una inspección ocular a las fronteras de decisión revela las limitaciones de distintos algoritmos, siendo `espirales_lo` un caso vistoso y pedagógico: fijamos una semilla, y dibujamos las fronteras de decisión por clasificador.

#logr solo puede dibujar fronteras "lineales", y como ninguna frontera lineal que corte la muestra logra dividirla en dos regiones con densidades de clase realmente diferentes, el algoritmo no es mejor que "lanzar una moneda". #gnb falla de manera análoga, aunque su problema es otro --- no lidia bien con distribuciones con densidades marginales muy similares.

Entre #kn y #fkn casi no observamos diferencias, asunto que ahondaremos en las partes #parte("fermat-11-de-donde-sale-la-ventaja")[11] y #parte("fermat-12-resultados-en-3d")[12]. Por lo pronto, sí se nota que se adaptan bastante bien a los datos, con algunas regiones de incertidumbre que resultan onerosas en términos de $R^2$: a primera vista los mapas de decisión recién expuestos se ven muy similares, pero las pequeñas diferencias de probabilidades resultaron en una diferencia de $0.19$ en $R^2$ _en contra_ del #fkn para esta semilla #footnote[La diferencia en la _mediana_ de $R^2$ para ambos es mucho menor, $approx 0.03$, lo cual resalta la sensibilidad de los resultados a la semilla aleatorizante y la importancia de realizar muchas repeticiones de cada experimento para evitar resultados espurios.]. También resulta llamativa la "creatividad" de #gbt para aproximar las verdaderas fronteras --- espirales curvas --- con una serie de _splits_ binarios, que le permiten dibujar una especie de "espiral rectangular".

#let clfs = ("kdc", "fkdc", "svc", "kn", "fkn", "gbt", "lr", "gnb")
#wide_figure(
  kind: image,
  fig-grid(columns: "repeat(4, 1fr)", ..clfs.map(clf => img(
      "espirales_lo-" + clf + "-decision_boundary.svg",
    ))),
  caption: flex-caption(
    [Fronteras de decisión de los ocho algoritmos evaluados sobre `espirales_lo` con semilla $s=#plotting_seed$. Nótese la incapacidad de #logr y #gnb para separar las clases, la aproximación rectangular de #gbt, y la nitidez de las fronteras de #fkdc y #svc.],
    [Fronteras de decisión en `espirales_lo`],
  ),
) <fig-fronteras-espirales>

#kdc ofrece una frontera aún más regular que #kn, sin perder en $R^2$ y hasta mejorando la exactitud. Y por encima de este ya destacable rendimiento, el uso de la distancia de Fermat _incrementa_ la confianza en estas regiones --- nótese cómo se afinan las áreas grises de incertidumbre y aumenta la superficie de rojo/azul sólido, mejorando otro poco el $R^2$.


#wide_figure(
  kind: image,
  fig-grid(
    img("espirales_lo-fkdc-decision_boundary.svg"),
    img("espirales_lo-svc-decision_boundary.svg"),
  ),
  caption: flex-caption(
    [Fronteras de decisión de #fkdc (izq.) y #svc (der.) en `espirales_lo`, $s = #plotting_seed$],
    [Fronteras de #fkdc y #svc en `espirales_lo`],
  ),
)

Las fronteras de #svc no tienen gradiente de color sino solo una línea #footnote[Como aprendimos: la frontera de una variedad riemanniana de dimensión intrínseca $d_MM$ es una variedad sin frontera de dimensión intrínseca $d_MM - 1$; la frontera de estas regiones es una curva parametrizable en $RR^1$ embebida en $RR^2$.], puesto que al ser un clasificador duro determina una frontera abrupta donde cambia la clase predicha. Es sorprendente la flexibilidad del algoritmo, que consigue dibujar una única frontera sumamente no lineal que separa los datos con altísima exactitud. La ventaja que #fkdc pareciera tener sobre #svc es que la frontera que dibuja pasa "más lejos" de las observaciones de clase, mientras que la de #svc parece estar muy pegada a los brazos de la espiral, particularmente en el giro más interno.

== Efectos de aumentar el ruido

Consideremos ahora los mismos datasets que hasta ahora, pero muestreando las observaciones sobre la variedad con "más ruido"; es decir, aumentando el valor de $sigma$ en el ruido blanco (#link(<ruido-blanco>)[definición de ruido blanco]) que le agregamos a los $X in MM$ según

$ sigma_"lunas" = 0.5 quad sigma_"circulos" = 0.2 quad sigma_"espirales" = 0.2. $

#wide_figure(
  kind: image,
  fig-grid(
    columns: "repeat(3, 1fr)",
    gap: "1px",
    img("lunas_hi-scatter.svg"), img("circulos_hi-scatter.svg"), img("espirales_hi-scatter.svg"),
  ),
  caption: flex-caption["Lunas", "Círculos" y "Espirales" con "alto ruido"][ "Lunas", "Círculos" y "Espirales", alto ruido ],
) <fig-22>

En general, #fkdc y #fkn siguen siendo competitivos, pero el "terreno de juego" se ha nivelado considerablemente, y las ventajas antes vistas disminuyen.

- En `lunas_hi` observamos que #gbt alcanza un $R^2$ marginalmente mejor que #fkdc, y todos los métodos basados en densidad por núcleos (la familia $cal(K)$) alcanzan una exactitud ligeramente mejor que la de #gbt.
- En `circulos_hi` #gbt es superior en $R^2$ y exactitud, aunque aún su propio rendimiento no es muy alentador con $R^2_#gbt approx 0.09$.

- En `espirales_hi` todos los métodos de $cal(K)$ alcanzan un $R^2$ muy similar, #gbt queda largamente atrás y #gnb y #logr no se distinguen del $0$. #svc obtiene la mejor exactitud,  por encima de #fkdc. Las ventajas de #fkdc por sobre #kdc son (casi) nulas en los tres casos.

#highlights_figure("lunas_hi")

#highlights_figure("circulos_hi")
#highlights_figure("espirales_hi")



El aumento en la cantidad de ruido hace la tarea más difícil para _todos_ los estimadores, pero los métodos basados en densidad por núcleos parecen sufrirlo particularmente, aunque solo sea porque "caen desde más alto", a un nivel de rendimiento similar al de otros métodos.

#wide_figure(
  kind: image,
  fig-grid(
    columns: "repeat(3, 1fr)",
    img("lunas-caida_r2.svg"), img("circulos-caida_r2.svg"), img("espirales-caida_r2.svg"),
  ),
  caption: flex-caption(
    [$R^2$ mediano por clasificador y dataset con bajo y alto ruido en el muestreo; se excluyen aquellos con $R^2 approx 0$ en ambas variantes.],
    [Caída de $R^2$ mediano al aumentar el ruido],
  ),
)

#{
  let hi_clfs = (("fkdc", fkdc), ("gbt", gbt), ("svc", svc))
  let hi_datasets = ("lunas_hi", "circulos_hi", "espirales_hi")
  wide_figure(
    fig-grid(
      columns: "auto 1fr 1fr 1fr",
      [], ..hi_datasets.map(d => [*#raw(d)*]),
      ..hi_clfs
        .map(((key, label)) => (
          rotulo(label),
          ..hi_datasets.map(d => img(d + "-" + key + "-decision_boundary.svg")),
        ))
        .sum(),
    ),
    kind: image,
    caption: flex-caption(
      [Fronteras de decisión para #fkdc, #gbt, #svc en regímenes de alto ruido, $s = #plotting_seed$.],
      [Fronteras de decisión en alto ruido],
    ),
  )
}

Al ojo humano, las regiones de confianza que "dibuja" #fkdc se alinean "en espíritu" con la forma de las variedades que buscamos descubrir: la "región de indiferencia" gris en `lunas_hi` es una especie de curva casi cúbica que efectivamente separa las lunas; el "huevo frito" de `circulos_hi` otorga máxima confianza a la clase interna en el centro de la imagen y se va deformando progresivamente a medida que nos alejamos; en `espirales_hi` logra dibujar una espiral, aunque con algunas islas inconexas y cortocircuitos entre los brazos. Esta deseable propiedad  --- la "intuitividad" en las regiones que traza #fkdc --- no se repite ni para #gbt (que tuvo el mejor $R^2$) ni #svc (el de mayor exactitud), pero como no es fácilmente reducible a una métrica en $RR$, se desdibuja en las comparaciones puramente numéricas.

== `anteojos` ($K = 3$, $d = 2$)

#highlights_figure("anteojos")

Cerramos el plano con `anteojos` #footnote[Inspirado en la tesis de maestría de #cite(<battocchioTestHipotesisSobre2024>, form:"prose", supplement: [§3.1.3]), "Test de hipótesis sobre homología
persistente utilizando la distancia de Fermat", que forma parte del mismo programa de investigación que esta.], un dataset sintético de tres clases con forma de anteojos que incluimos por ser el único multiclase en dos dimensiones: todos los estimadores salvo #logr alcanzan una exactitud de aproximadamente $97%$, y #fkdc saca una ventaja pequeña pero consistente en $R^2$ aun sobre #kdc.



#bibliography("/refs.bib", title: "Referencias")
