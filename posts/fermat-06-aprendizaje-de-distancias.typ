#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Cuando la variedad es desconocida: aprender la distancia",
  date: "2026-11-02",
  series: "fermat",
  part: 6,
  summary: [PCA, las ventanas de Parzen en variedades, las cartas de Brand e Isomap: cómo distintos métodos intentan recuperar la geometría de los datos a partir de la muestra.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)
#set math.equation(numbering: "(1)")

#callout(title: "En este post")[
  *¿Y si la variedad es desconocida?* Casi siempre lo es. Este post recorre cómo distintos métodos intentan recuperar la geometría a partir de la muestra: el análisis de componentes principales, las ventanas de Parzen en variedades, las cartas de Brand e Isomap. Cada uno resuelve algo y deja abierta alguna dificultad, lo que motiva el paso siguiente: en lugar de aprender la variedad, aprender directamente una _distancia_.
]



La hipótesis de la variedad nos ofrece un marco teórico en el que abordar la clasificación en alta dimensión, y encontramos en la literatura que la estimación de densidad por núcleos en variedades de Riemann compactas sin frontera está estudiada y tiene buenas garantías de convergencia. Por alentador que resulte, ya notamos una primera dificultad --- el cómputo de $theta_p (q)$ --- y nos resta una segunda: _la variedad que soporta las $X$ no suele ser conocida_. Salvo que los datasets estén generados sintéticamente o el objeto de estudio cuente con un dominio bien entendido y ya formalizado, tendremos problemas tanto para definir adecuadamente la dimensión intrínseca $d_MM$ como la distancia $d_g$ en #MM.

#figure(caption: flex-caption(
  [Datos espaciales en variedades bien definidas. (izq.) Los datos geoespaciales están sobre la corteza terrestre, que es aproximadamente la $2$-esfera $S^2 subset RR^3$ que representa la frontera de nuestra "canica azul", una $3$-bola. (der.) La clasificación clásica de Hubble distingue literalmente _variedades_ "elípticas", "espirales" e "irregulares" de galaxias de acuerdo con cómo se orientan sus estrellas. #footnote[La categorización completa es más compleja, con _outliers_ cuando #link("https://astronomy.stackexchange.com/questions/32947/what-decides-the-shape-of-a-galaxy")[distintas galaxias interactúan entre sí], como las #link("https://es.wikipedia.org/wiki/Galaxias_Antennae")[Antennae]. La #link("https://en.wikipedia.org/wiki/Spacetime_topology")[topología del espacio-tiempo] es un tópico de estudio clave en la relatividad general.]],
  "Datos espaciales con dimensiones bien definidas.",
))[
  #fig-grid(
    image("/assets/fermat/img/blue-marble.jpg", alt: "La Tierra vista desde el espacio"),
    image("/assets/fermat/img/tipos-de-galaxia-secuencia-hubble.png", alt: "Secuencia de Hubble de tipos de galaxia"),
  )
]

#let reddot = math.class("normal", circle(radius: 2.5pt, fill: red.lighten(60%), stroke: 1pt + red))
#let greendot = math.class("normal", circle(radius: 2.5pt, fill: green.lighten(60%), stroke: 1pt + green))
#let yellowdot = math.class("normal", circle(radius: 2.5pt, fill: yellow.lighten(60%), stroke: 1pt + yellow))

Considere, por caso, el diagrama de @variedad-u, la curva $cal(U) subset RR^2$.

#figure(
  caption: flex-caption[La curva $cal(U)$ de dimensión $d_(cal(U)) = 1$ embebida en $RR^2$. En el espacio ambiente, $d(greendot, reddot thin |RR^2) < d(greendot, yellowdot thin | RR^2)$. Trasladándose _sobre_ $cal(U)$, #box[$thin d(greendot, reddot thin |cal(U)) > d(greendot, yellowdot thin | cal(U)) approx 1/2 d(greendot, reddot thin |cal(U))$].][Variedad $cal(U)$ embebida en $RR^2$],
)[#image("/assets/fermat/img/variedad-u.svg", height: 18em)] <variedad-u>

A los fines de estimar la densidad de $X$ soportada en cierta variedad #MM, hace falta una noción de _distancia_ apropiada en #MM, pues como ya dijimos, raramente bastará con la propia del espacio ambiente.


En el ejemplo de @variedad-u, con tan solo $N=3$ observaciones es imposible distinguir $cal(U)$, pero con una muestra #XX "suficientemente grande", es de esperar que los propios datos revelen la forma de la variedad. Sobre esta idea se edifica la teoría de "aprendizaje de distancias".


La distancia entre dos puntos es una _representación_ útil de cuán similares son: a menor distancia, mayor similitud. Por ello, la estimación de variedades es fundamental al _aprendizaje de representaciones_. En una extensa reseña de dicho campo, @bengioRepresentationLearningReview2013 así lo explican:


#quote(attribution: [ @bengioRepresentationLearningReview2013[§8]])[
  $[dots]$ La principal tarea del aprendizaje no supervisado se considera entonces como el modelado de la estructura de la variedad que sustenta los datos. La representación asociada que se aprende puede asociarse con un sistema de coordenadas intrínseco en la variedad embebida.
]



= El ejemplo canónico: análisis de componentes principales (PCA)

El término "hipótesis de la variedad" es moderno, pero el concepto está presente hace más de un siglo en la teoría estadística #footnote[Estas referencias vienen del mismo Bengio #link("https://www.reddit.com/r/MachineLearning/comments/mzjshl/comment/gwq8szw/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button")[comentando en Reddit sobre el origen del término].].

El algoritmo arquetípico de modelado de variedades es, como era de esperar, también el algoritmo arquetípico de aprendizaje de representaciones de baja dimensión: el Análisis de Componentes Principales, PCA @pearsonLIIILinesPlanes1901, que dada $XX in RR^(N times d)$, devuelve en orden decreciente las "direcciones de mayor variabilidad" en los datos, $bu(U)_d = (u_1, u_2, dots, u_d) in RR^(d times d)$. Proyectar $XX$ sobre las primeras $m <= d$ direcciones, $ hat(XX) = XX bu(U)_m in RR^(N times m), thick hat(X)_i = (hat(X)_(i 1), dots, hat(X)_(i m))^T, $
nos devuelve la "mejor" #footnote[Cuya definición precisa obviamos.] representación lineal de dimensión $m$.
#figure(
  image("/assets/fermat/img/pca.png"),
  caption: flex-caption(
    [$XX in RR^2$ y sus componentes principales. Fuente: _"On lines and planes of closest fit to systems of points in space."_ @pearsonLIIILinesPlanes1901],
    [$XX in RR^2$ y sus componentes principales.],
  ),
)

Ya se dijo que las variedades que soportan variables aleatorias "silvestres" #footnote[Es decir, medidas "en el campo", por contraposición a aquellas definidas y generadas digitalmente según leyes conocidas.] seguramente sean fuertemente no lineales. Sin embargo, todavía hay lugar para PCA en esta aventura: cuando el dataset tiene dimensión verdaderamente muy alta, un proceso razonable consistirá en primero disminuir la dimensión a un subespacio lineal en que las distancias relativas sean casi idénticas a las del espacio original usando PCA, y recién en este subespacio aplicar técnicas más complejas de aprendizaje de distancias.

= Aprendizaje del espacio tangente

Aprovechando que al menos las observaciones de entrenamiento son puntos conocidos de la variedad  #footnote["Módulo" el error de medición, claro está.], y que en la variedad el espacio es _localmente euclídeo_, #cite(<vincentManifoldParzenWindows2002>, form: "prose") parten del estimador de densidad por núcleos multivariado (ver #parte("fermat-03-maldicion-y-variedades")[tercera parte]) pero en lugar de utilizar un núcleo $KH$ fijo en cada observación $x_i$, se proponen hacer análisis de componentes principales en un vecindario de cada observación $x_i$. En lugar de fijar un vecindario "duro" (de $k$ observaciones o radio $epsilon$), definen un "vecindario suave" según $cal(K)$, una medida de cercanía en el espacio ambiente tal como la densidad normal multivariada $phi.alt$ #footnote[En los experimentos del trabajo, no obstante, usan el vecindario duro de los $k$ vecinos más cercanos.]:
$
  hat(SS)_cal(K)_i = hat(SS)_cal(K)(x_i) = (sum_(j in [N] - i) cal(K)(x_i, x_j) (x_j - x_i) (x_j - x_i)^T )/(sum_(j in [N] - i) cal(K)(x_i, x_j)).
$
La estimación de densidad asociada resulta:
$
  hat(f) (x) & = N^(-1) sum_(i=1)^N K_( hat(SS)_cal(K)_i) (x, x_i) \
             & = N^(-1) sum_(i=1)^N abs(det hat(SS)_cal(K)_i)^(-1/2) K( hat(SS)_(cal(K)_i)^(-1/2) (x - x_i)).
$
Ahora bien, computar una $hat(SS)_cal(K)_i$  para cada una de las $N$ observaciones, más su inversa y la "raíz cuadrada" de esta última es muy costoso, por lo que los autores agregan un refinamiento: si la variedad en cuestión es de dimensión $d_MM$, es de esperar que las direcciones principales a partir de la $(d_MM+1)$-ésima sean "negligibles" #footnote[La sugerente metáfora que usan en el trabajo es que en lugar de ubicar una "bola" de densidad alrededor de cada observación $x_i$, quieren ubicar un "panqueque" tangente a la variedad.]. En lugar de computar las componentes principales de $hat(SS)_cal(K)_i$,
+ fijan de antemano la dimensión $d_MM$ esperada para la variedad,
+ se quedan con las $d_MM$ direcciones principales #footnote[En la práctica, las obtienen usando SVD --- descomposición en valores singulares @hastieElementsStatisticalLearning2009[§3, Eq. 45, p. 64].],
+ "ponen en cero" el resto y
+ "completan" la aproximación con un poco de "ruido" $sigma^2 bu(I)$.


La aproximación resultante #box[$hat(SS)_i = bu(V)_(d_MM) bu(Lambda)_(d_MM) bu(V)_(d_MM)^T + sigma^2 bu(I)$] --- con $bu(V)_(d_MM), bu(Lambda)_(d_MM)$ los primeros $d_MM$ autovectores y autovalores de $hat(SS)_cal(K)_i$ --- es mucho menos costosa de invertir, y tiene una interpretación geométrica bastante intuitiva en cada punto.
Usando el mismo clasificador basado en la regla de Bayes que ya mencionamos en la #parte("fermat-02-clasificar-con-densidades")[segunda parte], obtienen así resultados superadores a los del KDE multivariado con $HH = h^2 bu(I)$. El método es intuitivo e ingenioso, pero todavía consta de dos dificultades:
- no es obvio cuál debería ser la dimensión intrínseca $d_MM$ del paso (1) cuando la variedad es desconocida, y
- el subespacio generado por los primeros $d_MM$ autovectores de la matriz de covarianza local a $x_i$ aproxima el espacio tangente $T_(x_i)MM$, pero no dicen nada de cómo es $T_p MM$ en otros puntos. #footnote[El grupo de Bengio, Vincent y Rifai continuó con estos estimadores, con énfasis en aprender una geometría _global_ de la variedad, pero a partir de aquí su camino se desvía del de esta monografía: #cite(<bengioNonLocalManifoldParzen2005>, form: "prose") agregan restricciones globales a los núcleos punto a punto y los computan con redes neuronales, y #cite(<rifaiManifoldTangentClassifier2011>, form: "prose") aprenden explícitamente un atlas para clasificar con TangentProp @simardTangentPropFormalism1991.]

En un trabajo contemporáneo a @vincentManifoldParzenWindows2002, "Charting a Manifold" @brandChartingManifold2002, el autor aborda dificultades análogas en el contexto de la reducción de dimensionalidad, en tres etapas:
+ estimar la dimensión intrínseca de la variedad $d_MM$; luego
+ definir un conjunto de cartas centradas en cada observación $x_i in MM$ que minimicen una _divergencia_ global, y finalmente
+ "coser" las cartas a través de una _conexión_ global sobre la variedad.


El procedimiento para estimar $d_MM$ es tanto ingenioso como costoso de computar. Sean $XX = (x_1^T, dots, x_N^T)$ $N$ observaciones $d$-dimensionales muestreadas de una distribución en $(MM, g)$ con $d_MM < d$ con algo de ruido _isotrópico_ #footnote[Del griego _iso-_, "igual", y _-tropos_, "dirección": "igual en todas las direcciones".] $d$-dimensional. Dada una bola $B_r (q)$ centrada en un punto cualquiera $q in #MM$, consideremos la tasa $t(r)$ a la que incorpora observaciones vecinas a medida que crece $r$. Cuando $r$ está en la escala del ruido isotrópico, la bola incorpora puntos rápidamente, pues los hay en todas las direcciones. A medida que $r$ alcanza la escala en la que la variedad es localmente análoga a $RR^(d_MM)$, la incorporación de nuevos puntos disminuye, pues solo habrá nuevas observaciones en las $d_MM$ direcciones tangentes a $q$. Si $r$ sigue creciendo, la bola $B_r (q)$ eventualmente alcanzará la escala de la _curvatura_ de la variedad, momento en el que comenzará a acelerarse nuevamente la incorporación de puntos. El $r$ que minimiza $t(r)$ identifica la escala localmente lineal, y la tasa de crecimiento en esa escala, la dimensión intrínseca: allí la cantidad de puntos en la bola crece como $r^(d_MM)$. #footnote[Más precisamente, el autor sigue $c(r) = (dif log r) / (dif log n(r))$, con $n(r)$ la cantidad de puntos en la bola, que vale aproximadamente $1/d$ en la escala del ruido, es menor a $1/d_MM$ en la escala de la curvatura, y alcanza su máximo $1/d_MM$ en la escala localmente lineal. El máximo de $c(r)$ da así tanto la escala como la dimensión. Además, evalúa las bondades y dificultades de estimar $d_MM$ tanto punto a punto como globalmente en toda la variedad.]


#figure(
  image("/assets/fermat/img/scale-behavior-1d-curve-w-noise.png"),
  caption: flex-caption(
    [
      Una bola de radio creciente centrada en un punto de una $1$-variedad muestreada con ruido en $RR^2$ _minimiza_ la tasa a la que incorpora observaciones cuando $r$ está en la escala "localmente lineal" de la variedad.
      Fuente: @brandChartingManifold2002[Fig. 1]
    ],
    [
      Comportamiento de escala de una $1$-variedad en $RR^2$
    ],
  ),
)

Estimada $d_MM$, los pasos siguientes no son menos complejos. Por un lado, se plantea un sistema de ecuaciones para obtener _simultáneamente_ todos los entornos coordenados centrados en cada observación minimizando una medida de _divergencia_ entre $SS_j$ vecinos
#footnote[
  A tal fin, modela la muestra como una "mezcla de $N$ gaussianas"  --- _gaussian mixture modelling_ o "GMM" por sus siglas en inglés ---, con $mu_i = x_i forall i in [N]$, y resuelve simultáneamente $SS_i forall i in [N]$ maximizando la verosimilitud de la mezcla --- que "aplasta" cada componente sobre los datos --- penalizada por una _a priori_ que castiga la divergencia entre gaussianas vecinas. Intuitivamente, la divergencia representa el "costo" o "error" que resulta de querer representar un punto $a$ del vecindario $U$ de $x_i$ en las coordenadas correspondientes a un vecindario $V$ de $x_j$: es la divergencia de Kullback-Leibler entre $cal(N)(x_i, SS_i)$ y $cal(N)(x_j, SS_j)$, que el autor llama _entropía cruzada_. Nótese que solo exige que los subespacios principales de vecinos sean _casi el mismo_, no que sus ejes estén alineados, lo que vuelve convexo el problema.]. Finalmente, han de encontrar una _conexión_ entre los entornos coordenados de cada observación, de manera que se puedan definir coordenadas para _cualquier_ punto de la variedad y con ellas formar un atlas diferenciable.

Una _conexión_ @docarmoRiemannianGeometry1992 es otro término de significado muy preciso en geometría riemanniana que aquí usamos coloquialmente. Es un _objeto geométrico_ que _conecta_ espacios tangentes cercanos, describiendo precisamente cómo estos varían a medida que uno se desplaza sobre la variedad. La "conexión" de Brand es más modesta: un conjunto de transformaciones afines que llevan las coordenadas locales de cada carta a un único sistema de coordenadas global en $RR^(d_MM)$, resuelto en forma cerrada por mínimos cuadrados. El resultado es una representación de baja dimensión con mapas de ida y vuelta, del mismo tipo que las de Isomap o LLE #footnote[_Locally linear embeddings_ en inglés. Sobre Isomap ampliaremos en la siguiente sección.], pero no una métrica $g$ ni una densidad de volumen $theta_p$. Si se dispusiera de un atlas diferenciable con su conexión en sentido estricto, sería posible en principio computar $g_p$ y $theta_p (q)$; pero a esta altura, hemos reemplazado el de por sí difícil problema original --- encontrar una buena representación de baja dimensión #MM --- por uno tal vez aún más difícil: encontrar la dimensión intrínseca, un atlas diferenciable y su conexión global para una variedad desconocida. El proceso es sumamente interesante, pero complejiza en lugar de simplificar nuestro desafío inicial.

= Isomap

En rigor, no es necesario conocer #MM para estimar densidades en ella; bastaría con conocer una aproximación a la distancia geodésica en #MM que sirva de sustituto a la distancia euclídea en el espacio ambiente. Probablemente el algoritmo más conocido a tal fin sea Isomap --- por "mapeo isométrico de _features_".

Desarrollado a fines del siglo XX por Joshua Tenenbaum et al.  @tenenbaumMappingManifoldPerceptual1997 @tenenbaumGlobalGeometricFramework2000, el algoritmo consta de tres pasos:

#defn("algoritmo Isomap")[
  Sean $XX = (x_1, dots, x_N), x_i in RR^d$ $N$ observaciones $d$-dimensionales.
  El mapeo isométrico de _features_ es el resultado de:
  + Construir el grafo pesado de vecinos más cercanos $bu(N N) = (XX, E, W)$, donde cada observación $x_i$ es un vértice y la arista #footnote[_Edge_ en inglés.] $e_i = a ~ b$ que une $a$ con $b$ está presente con peso $w_i = norm(a - b)$ si y solo si
    - ($epsilon$-Isomap): la distancia euclídea entre $a$ y $b$ en el espacio ambiente es menor o igual a $epsilon$, $norm(a - b) <= epsilon$, o
    - ($k$-Isomap): $b$ es uno de los $k$ vecinos más cercanos de $a$ #footnote[O viceversa: el grafo se toma no dirigido, así que basta con que uno de los dos sea vecino más cercano del otro.].
  + Computar la distancia geodésica en el grafo $bu(N N)$ --- el "costo" de los caminos mínimos --- entre todo par de observaciones, $d_bu(N N)(a, b) forall a in XX, b in XX$ #footnote[A tal fin, se puede utilizar según convenga el algoritmo de Floyd-Warshall @floydAlgorithm97Shortest1962 o el de Dijkstra @dijkstraNoteTwoProblems1959.].
  + Construir la representación $d_MM$-dimensional utilizando MDS #footnote[_Multidimensional scaling_, o "escalamiento multidimensional", un algoritmo de reducción de dimensionalidad @kruskalMultidimensionalScalingOptimizing1964.] en el espacio euclídeo $RR^(d_MM)$ que minimice una métrica de discrepancia denominada "estrés", entre las distancias $d_bu(N N)$ de (2) y la norma euclídea en la representación. Para elegir el valor óptimo de $d_MM$, búsquese el "codo" en el gráfico de estrés en función de la dimensión de MDS #footnote[Valor que debería coincidir con la dimensión intrínseca de los datos.].
]
#figure(
  image("/assets/fermat/img/isomap-2.png", height: 16em),
  caption: flex-caption(
    [Isomap aplicado a 1.000 dígitos "2" manuscritos del dataset _MNIST_ con $d_MM=2$. Nótese que las dos direcciones se corresponden fuertemente con características de los dígitos: el rulo inferior en el eje $X$, y el arco superior en el eje $Y$. Fuente: @tenenbaumGlobalGeometricFramework2000.],
    [Isomap ($d_MM=2$) aplicado a 1.000 dígitos "2" manuscritos],
  ),
)

La pieza clave del algoritmo es la estimación de la distancia geodésica en #MM a través de su aproximación por la distancia en el grafo de vecinos más cercanos. Si la muestra disponible es "suficientemente grande" y el espacio está "densamente muestreado", es razonable esperar que en el entorno de una observación $x_0$ las distancias euclídeas aproximen bien las distancias geodésicas, y por ende un "paseo" por el grafo $bu(N N)$ debería describir una curva prácticamente contenida en #MM. Isomap fue --- y aún es --- un algoritmo sumamente efectivo que avivó el interés por el aprendizaje de distancias, pero cuenta con un talón de Aquiles: la elección del parámetro de cercanía, $epsilon$ o $k$:
- valores demasiado pequeños pueden "partir" $bu(N N)$ en más de una componente conexa, otorgando "distancia infinita" a puntos en componentes disjuntas, mientras que
- valores demasiado grandes pueden "cortocircuitar" la representación --- en particular en variedades con muchos pliegues ---, uniendo secciones de la variedad subyacente a través del espacio ambiente.


#bibliography("/refs.bib", title: "Referencias")
