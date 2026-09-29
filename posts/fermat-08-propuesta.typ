#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "La propuesta: clasificadores con distancia de Fermat",
  date: "2026-11-16",
  series: "fermat",
  part: 8,
  summary: [Qué implementamos --- #kdc, #fkdc y #fkn --- y las tres decisiones de diseño que hicieron falta: distancia de Fermat _out-of-sample_, una sola ventana global y la omisión de la densidad de volumen.],
  status: "draft",
  lang: "es",
)
#show: post.with(..meta)

#callout(title: "En este post")[
  *¿Qué construimos, exactamente?* Tres clasificadores: #kdc (densidad por núcleos con distancia euclídea), #fkdc (el mismo, con distancia de Fermat) y #fkn ($k$ vecinos más cercanos con distancia de Fermat), en una librería de código abierto. Para que funcionaran hicieron falta tres decisiones de diseño: calcular la distancia de Fermat a observaciones nuevas, elegir una única ventana $h$ y un único $alpha$ globales, y omitir la densidad de volumen.
]


En función de lo expuesto hasta ahora, creemos que es posible mejorar un algoritmo de clasificación reemplazando la distancia euclídea por una aprendida de los datos, y en particular que la distancia muestral de Fermat #sfd es una buena candidata de reemplazo. Deseamos también comprender si el efecto de la #sfd aprendida es independiente del algoritmo de clasificación que la incorpore. Para saldar ambas cuestiones, nos propusimos:

1. Implementar un clasificador basado en estimación de densidad por núcleos según la #parte("fermat-05-densidades-en-variedades")[definición de KDE en variedades de Riemann] @loubesKernelbasedClassifierRiemannian2008, al que llamaremos "KDC" #footnote[_Kernel Density Classifier_, por sus siglas en inglés.].
2. Implementar un clasificador de densidad por núcleos basado en la distancia de Fermat, "$f$-KDC", a fin de comparar el rendimiento de KDC con distancia euclídea y con distancia de Fermat.
3. Implementar un clasificador de $k$ vecinos más cercanos según la #parte("fermat-02-clasificar-con-densidades")[definición del clasificador de $k$ vecinos más cercanos], pero con distancia muestral de Fermat en lugar de euclídea.
4. Comparar sistemáticamente la capacidad de clasificación de cada algoritmo propuesto --- y algunos más de referencia --- en datasets de diversas características.
5. Analizar los resultados e identificar en qué condiciones es que la distancia de Fermat aporta mejoras significativas sobre la tradicional distancia euclídea.

El método de aprendizaje de la distancia muestral de Fermat y los tres algoritmos novedosos componen un repositorio de código abierto que acompaña esta tesis y está a disposición de cualquier investigador que desee corroborar los resultados en GitHub #footnote[#link("https://github.com/capitantoto/fermat").]. En los tres se requirieron desarrollos nuevos al menos parcialmente:
- KDC en variedades según la #parte("fermat-05-densidades-en-variedades")[regla de clasificación por KDE en variedades] está definido en #cite(<loubesKernelbasedClassifierRiemannian2008>, form: "prose") pero no conocemos implementaciones previas,
- la estimación de densidad por núcleos multivariada de la #parte("fermat-03-maldicion-y-variedades")[definición de KDE multivariada] cuenta con múltiples implementaciones en código pero no conocemos algoritmos de clasificación "llave en mano" que se basen en ella, y
- $k$-NN como en la #parte("fermat-02-clasificar-con-densidades")[definición del clasificador de $k$ vecinos más cercanos] es un algoritmo de clasificación harto común que soporta distancias no euclídeas, pero requirió implementar la distancia de Fermat específicamente.

A continuación, mencionamos algunos aspectos salientes sobre los desarrollos de código necesarios así como la metodología de evaluación diseñada, antes de pasar a los resultados.

= Estimación de distancia de Fermat _out-of-sample_

Un proyecto de código preexistente a esta monografía ya implementa el cálculo de la distancia de Fermat microscópica o muestral para un conjunto de observaciones dado: #link("https://pypi.org/project/fermat/")[fermat], de Facundo Sapienza. Este paquete fue desarrollado para soportar los experimentos de #cite(<sapienzaWeightedGeodesicDistance2018>, form: "prose") que exploran los efectos de esta noción de distancia en tareas de _clustering_. Al ser una tarea no supervisada #footnote[Una tarea supervisada de aprendizaje es aquella en que se entrena el algoritmo con un conjunto de observaciones para el que _ya se sabe_ el valor correcto de respuesta. Una tarea "no supervisada" no cuenta con una "respuesta correcta" de antemano. _Clustering_ --- identificar grupos en la muestra --- es una tarea no supervisada; _clasificación_ --- asignar elementos a clases conocidas de antemano --- es una tarea supervisada.], se utilizan todas las observaciones disponibles y solo se requiere calcular la distancia entre dos elementos cualesquiera de la muestra #XX, pero nunca contra otros $p : p in MM, p in.not XX$.

Entrenar un algoritmo _supervisado_ de clasificación requiere apartar una fracción de las observaciones disponibles #footnote[De no hacerlo y evaluar al clasificador sobre los mismos datos de entrenamiento, se corre el riesgo de sobreajustar el clasificador a los datos. De entrenar $k$-NN con toda la muestra, se puede tomar $k =1$ incondicionalmente. Durante el entrenamiento se acertará la clase correcta siempre, ya que cada observación es su propia vecina con distancia cero, pero el clasificador resultante generalizará muy mal a nuevas observaciones.] y conformar un conjunto de _test_ en el que evaluar la pérdida objetivo $L$. ¿Cómo calculamos entonces la distancia muestral de Fermat de una _nueva_ observación $x_0$ a los elementos de cada grupo $GG_i, i in [K]$, si no incluimos su nodo en el grafo completo de cada clase durante el entrenamiento?

Sencillamente, para cada una de las $GG_i in GG$ clases, definimos el conjunto $ Q_i= {x_0} union {x_j : x_j in XX, g_j = i}, $ resultante de unir la nueva observación $x_0$ al conjunto de entrenamiento correspondiente a la clase $GG_i$, y recomputamos $D_(Q_i, alpha) (x_0, y) forall y in Q_i$. Aunque sencillo de describir, resultaría absurdamente costoso computacionalmente recomputar la matriz completa de distancias $D_(Q_i, alpha)$ para cada una de las $K$ clases por _cada_ nueva observación. En su lugar, implementamos un sencillo algoritmo "incremental", que permite recomputar únicamente las geodésicas que cambian al agregar la nueva observación $x_0$ al grafo completo de la clase en cuestión. #footnote[Para más detalles al respecto, léase el método `SampleFermatDistance._distancia` en el módulo `fkdc/fermat.py`.]

= Elección del ancho de banda para clasificación

Al estimar densidades con distancia de Fermat en una variedad, la elección del ancho de banda se simplifica considerablemente: en lugar de una matriz completa $HH$ como en el KDE multivariado euclídeo, basta con dos escalares --- $h$ y $alpha$. Idealmente, convendría elegir un par $(h_i^star, alpha_i^star)$ óptimo para cada clase $GG_i$, ya que las densidades individuales pueden diferir sustancialmente.

Sin embargo, #cite(<hallBandwidthChoiceNonparametric2005>, form: "prose") muestran que el $h$ óptimo para la estimación de densidad no es necesariamente el óptimo para clasificación: la tarea de clasificar no requiere estimar bien la densidad en todo el soporte, sino distinguir bien _en las fronteras_ entre clases. Teniendo esto en cuenta y para simplificar la configuración, parametrizamos #fkdc con un único $h$ y $alpha$ globales #footnote[Y #kdc con un único $h$, elegido sobre una grilla mucho más fina que la de #fkdc.]. La búsqueda de simplicidad en la configuración no es un deseo, es una necesidad: la elección de hiperparámetros óptimos por validación cruzada en una grilla requiere entrenar el mismo clasificador en una cantidad de configuraciones que crece exponencialmente con la cantidad de hiperparámetros, lo cual prohíbe configuraciones mucho más complejas que unos pocos parámetros.

= Omisión de la densidad de volumen <omision-theta>

El estimador de la #parte("fermat-05-densidades-en-variedades")[definición de KDE en variedades de Riemann] incluye un factor $1 slash theta_(X_i) (p)$ que #kdc y #fkdc omiten: es decir, tomamos $theta equiv 1$. Sin conocer #MM no hay forma de evaluar $theta$, como se discutió en la #parte("fermat-05-densidades-en-variedades")[definición de función de densidad de volumen] y sus observaciones. Lo único que sabemos de $theta$ es lo que allí se dijo: vale exactamente $1$ en variedades planas, vale $1$ en el propio punto $p$ y tiende a $1$ a medida que $q$ se acerca a $p$. Como el núcleo solo pesa observaciones a distancia comparable a $h$, y la construcción de #cite(<pelletierKernelDensityEstimation2005>, form: "prose") exige $h < "iny" MM$, el factor omitido es cercano a $1$ justamente en la región que importa, y tanto más cuanto menor sea $h$ respecto de la curvatura de #MM. Para clasificación, conjeturamos #footnote[Siguiendo un argumento _alla_ #cite(<hallBandwidthChoiceNonparametric2005>, form: "prose").] que el efecto podría ser todavía menor, porque el mismo factor afecta a todas las clases alrededor de $p$ y en buena medida se cancela en el cociente de la regla de Bayes. Es un supuesto que no verificamos, que falla en variedades muy curvas respecto de $h$, y que retomamos como debilidad en #parte("fermat-14-conclusiones")[Trabajo futuro]. Por ahora diremos que no es necesariamente un callejón sin salida: en variedades conocidas podemos calcularlo explícitamente @henryKernelDensityEstimation2009, y en variedades desconocidas podríamos estimar su efecto. #cite(<besseManifoldsAllWhose1978>, form: "prose", supplement: [§6.3]) expresa $theta$ mediante campos de Jacobi a lo largo de las geodésicas que irradian de $p$ --- es decir, en función de cómo se separan o se juntan las geodésicas vecinas; esa información local es del mismo tipo que la que captura el análisis de componentes principales alrededor de cada observación de #cite(<vincentManifoldParzenWindows2002>, form:"prose"): cómo cambia el espacio tangente estimado de una observación a sus vecinas.


#bibliography("/refs.bib", title: "Referencias")
