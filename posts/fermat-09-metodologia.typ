#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Cómo comparamos clasificadores",
  date: "2026-11-23",
  series: "fermat",
  part: 9,
  summary: [Tareas, exactitud y $R^2$ de McFadden, algoritmos de referencia, validación cruzada, #reps repeticiones por dataset y una regla de parsimonia: el diseño experimental detrás de los resultados.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)

#callout(title: "En este post")[
  *¿Cómo se compara con justicia un clasificador nuevo?* Evaluamos principalmente por $R^2$ de McFadden, que premia la confianza bien puesta, sin perder de vista la exactitud; contra cuatro algoritmos de referencia; con #reps repeticiones por dataset y validación cruzada; y con una _regla de parsimonia_ que solo deja a #fkdc usar $alpha > 1$ cuando rinde claramente mejor que #kdc. Esa regla es clave para leer los #parte("fermat-10-resultados-en-el-plano")[resultados].
]



La unidad de evaluación de los algoritmos a considerar es una `Tarea` #footnote[Cf. el archivo `fkdc/tarea.py` en el repositorio adjunto para más detalles.], que se compone de:
- un dataset con el conjunto de $N$ observaciones en $d$ dimensiones repartidas en $K$ clases, $(XX, bu(g))$,
- un _split de evaluación_ $r in (0, 1)$, que determina la proporción de los datos a incluir en la muestra de entrenamiento $XX_"train"$ ($1 - r$) y la de evaluación $XX_"test"$ ($r$),
- una _semilla_ $s in [2^32]$ que alimenta el generador de números aleatorios y determina cómo realizar la división antedicha y
- una _métrica de evaluación_ #footnote[En muchos casos esta coincidirá con la función de pérdida $L$ a minimizar durante el entrenamiento, pero no necesariamente.] que resume la "bondad" de las predicciones sobre $XX_"test"$ del clasificador entrenado en $XX_"train"$.

= Métricas de evaluación

En tareas de clasificación, la métrica más habitual es la _exactitud_ #footnote([Más conocida por su nombre en inglés, _accuracy_.])

#defn(
  "exactitud",
)[Sean $(XX, bu(g)) in RR^(N times d) times RR^N$ una matriz de $N$ observaciones de $d$ atributos y sus clases asociadas. Sean además $hat(bu(g)) = hat(G)(XX)$ las predicciones de clase resultado de una regla de clasificación $hat(G)$. La _exactitud_ ($"exac"$) de $hat(G)$ en #XX se define como la proporción de coincidencias con las clases verdaderas $bu(g)$:
  $ op("exac")(hat(G) | XX) = N^(-1) sum_(i=1)^N ind(hat(g)_i = g_i). $
] <exactitud>

La exactitud está bien definida para cualquier clasificador que provea una regla _dura_ de clasificación. Ahora bien, cuando un clasificador provee una regla suave, la exactitud como métrica pierde información: dos clasificadores binarios que asignen respectivamente 0.51 y 1.0 de probabilidad de pertenecer a la clase correcta a todas las observaciones tendrán la misma exactitud, $100%$, aunque el segundo es a las claras mejor. A la inversa, cuando un clasificador erra al asignar la clase: ¿lo hace con absoluta confianza, asignando una alta probabilidad a la clase equivocada, o con cierta incertidumbre, repartiendo la masa de probabilidad entre varias clases que considera factibles? Una métrica natural para evaluar una regla de clasificación suave es la _verosimilitud_ de las predicciones.

#defn(
  "verosimilitud",
)[Sean $XX, bu(g)$ como en la #link(<exactitud>)[definición de exactitud]. Sea además $hat(bu(Y)) = clf(XX) in RR^(N times K)$ la matriz de probabilidades de clase resultado de una regla suave de clasificación #clf. La _verosimilitud_ ($"vero"$) de #clf en #bu("X") se define como la probabilidad conjunta que asigna #clf a las clases verdaderas #bu("g"):
  $
    op("vero")( clf | XX ) = product_(i=1)^N Pr(hat(g)_i =g_i) = product_(i=1)^N hat(bu(Y))_(i, g_i).
  $

  Por conveniencia, se suele considerar la _log-verosimilitud promedio_,
  $ op(cal(l))(clf) = N^(-1) log(op("vero")(clf)) = N^(-1)sum_(i=1)^N log(hat(bu(Y))_(i, g_i)). $
] <vero>

La verosimilitud de una muestra varía en el rango $[0, 1]$ y su log-verosimilitud, en $(-oo, 0]$. Como métrica, esta se comprende mejor al expresarla _relativa a otros clasificadores_, por ejemplo, como propone #cite(<mcfaddenConditionalLogitAnalysis1974>, form: "prose").

#defn(
  [$R^2$ de McFadden],
)[Sea $clf_0$ el clasificador "nulo", que asigna a cada observación y posible clase, la frecuencia empírica de clase encontrada en la muestra de entrenamiento $XX_("train")$. Para todo clasificador suave $clf$, definimos el $R^2$ de McFadden como
  $ op(R^2)(clf | XX) = 1 - (op(cal(l))(clf)) / (op(cal(l))(clf_0)). $
] <R2-mcf>

#obs[ $op(R^2)(clf_0) = 0$. Un clasificador perfecto --- un "oráculo" --- $clf^star$ que otorgue toda la masa de probabilidad a la clase correcta, tendrá $op("vero")(clf^star) = 1$ y log-verosimilitud igual a 0, de manera que $op(R^2)(clf^star) = 1 - 0 = 1$. Un clasificador _peor_ que $clf_0$, en tanto asigne bajas probabilidades a las clases correctas, puede tener un $R^2$ infinitamente negativo.
]

#kdc, #fkdc, #kn y #fkn son clasificadores suaves, por lo que los evaluaremos principalmente según el $R^2$ de la #link(<R2-mcf>)[definición del $R^2$ de McFadden]. Sin embargo, mantendremos un ojo en la exactitud de la #link(<exactitud>)[definición de exactitud], para asegurarnos de que su rendimiento en esta métrica estándar no sea significativamente peor que la de los algoritmos de referencia.

= Algoritmos de referencia

Pírrica victoria sería mejorar con la distancia de Fermat el rendimiento de #kdc o #kn para encontrar que aun así, tales algoritmos no son competitivos contra el estado del arte en la misma tarea. A modo de referencia incluimos también los siguientes algoritmos en la comparación:
- Naive Bayes gaussiano (#gnb),
- Regresión logística (#logr),
- _Gradient Boosting Trees_ (#gbt) #footnote[Una traducción literal sería "árboles (de decisión) por potenciación del gradiente", pero este término casi nunca se traduce en la práctica.] y
- clasificador de soporte vectorial (#svc).

Esta elección no pretende ser exhaustiva, sino que responde a un "capricho informado" del investigador. Naive Bayes (presentado en #parte("fermat-03-maldicion-y-variedades")[la tercera parte]) es una alternativa natural, ya que es la simplificación que surge de asumir independencia en las dimensiones de $X$ para KDE multivariado (#parte("fermat-03-maldicion-y-variedades")[definición de KDE multivariada]), y se puede computar para grandes conjuntos de datos en muy poco tiempo.

La regresión logística es "el" método para clasificación binaria, y su extensión a múltiples clases no es particularmente compleja. Para resultar mínimamente valioso, un nuevo algoritmo necesita ser al menos tan bueno como #logr y sus ya más de 80 años en el campo #footnote[La referencia más temprana a la regresión logística que encontramos fue #cite(<berksonApplicationLogisticFunction1944>, form: "prose"); la referencia clásica al marco formal moderno se debe a #cite(<coxRegressionAnalysisBinary1958>, form: "prose"). Un trabajo aún anterior sobre estimación de probabilidades pero usando la función _probit_ --- la distribución acumulada de la normal estándar --- en lugar de la función _logit_ o sigmoidea pertenece a #cite(<blissCALCULATIONDOSAGEMORTALITYCURVE1935>, form: "prose").].

Por último, fue nuestro deseo incorporar algunos métodos contemporáneos, más cercanos al estado del arte. A tal fin incluimos un método de _boosting_ #footnote[ El _gradient boosting_ fue introducido por #cite(<friedmanGreedyFunctionApproximation2001>, form: "prose"), y desde entonces ha dado lugar a implementaciones altamente eficientes como XGBoost @chenXGBoostScalableTree2016 y LightGBM @keLightGBMHighlyEfficient2017.] y el antedicho clasificador de soporte vectorial. El clasificador de soporte vectorial @cortesSupportvectorNetworks1995, #svc, se evaluó en dos variantes: con núcleos (_kernels_) lineales y RBF #footnote[Del inglés _radial basis functions_, "funciones de base radial".].


Por conocerlo en profundidad y en virtud de su sencillez de uso, la implementación se realizó utilizando `scikit-learn` @JMLR:v12:pedregosa11a, un poderoso y extensible paquete para tareas de aprendizaje automático en Python. Más importante aún, desarrollar nuestros nuevos clasificadores en el _framework_ de `scikit-learn`
- simplifica enormemente la comparación de resultados, en tanto podemos utilizar exactamente los mismos métodos y _pipelines_ para los clasificadores bajo estudio y los de referencia, y
- nos permite, a nosotros mismos o a otros investigadores el día de mañana, integrar estos nuevos desarrollos al vasto universo de herramientas de estimación que toda la comunidad de aprendizaje automático construye alrededor de `scikit-learn`.


= Pretratamiento de los datos <pretratamiento>

Mantuvimos al mínimo el pretratamiento de los datos de entrada. Esta decisión fue deliberada: nos interesaba evaluar si la distancia de Fermat era capaz de capturar la estructura de la variedad subyacente sin asistencia adicional en la preparación de los datos, si bien reconocemos que este supuesto no es del todo razonable en aplicaciones del mundo real, donde el preprocesamiento suele ser una etapa fundamental.

Ni siquiera la regresión logística, de la que es bien sabido que se degrada cuando las variables predictoras están en escalas muy distintas, recibió un tratamiento especial. El efecto de la escala se estudia aparte, en #parte("fermat-13-datasets-organicos")[`pinguinos`: sensibilidad a la escala de los atributos], reentrenando todos los clasificadores sobre variantes estandarizadas de los datasets que lo requieren.

= Entrenamiento de los algoritmos
La especificación completa de un clasificador incluye, además de un dataset de entrenamiento, un algoritmo y también sus hiperparámetros. Para cada algoritmo y en cada dataset se seleccionaron hiperparámetros de una extensa grilla "cuadrada" #footnote["Cuadrada" en tanto para cada hiperparámetro se elige una secuencia de posibles valores, y se buscan soluciones en el espacio producto de tales secuencias.] maximizando la log-verosimilitud (cf. #link(<vero>)[definición de verosimilitud]) para los clasificadores suaves, y la exactitud (cf. #link(<exactitud>)[definición de exactitud]) para los duros #footnote[Entre los mencionados, el único clasificador duro es #svc. Técnicamente es posible entrenar un clasificador suave a partir de uno duro con un _segundo_ estimador que toma como _input_ el resultado "crudo" del clasificador duro y da como _output_ una probabilidad calibrada (cf. #link("https://scikit-learn.org/stable/modules/calibration.html")[Calibración] en la documentación de `scikit-learn`  @buitinckAPIDesignMachine2013), pero es un proceso computacionalmente costoso.] con una búsqueda exhaustiva por validación cruzada de 5 pliegos #footnote[Conocida en inglés como #emph[grid search 5-fold cross-validation].] sobre la grilla entera.

En una ronda "exploratoria" de Tareas, se identificó en qué escala estaban aproximadamente los hiperparámetros óptimos para cada algoritmo y dataset. Para la corrida "principal" de los experimentos, se definió una única grilla por clasificador, para todos los datasets, cubriendo el rango descubierto para cada hiperparámetro y suficientes puntos como para ser significativa a lo largo. #footnote[De contar con más tiempo, hubiésemos preferido definir una grilla específica a cada dataset y estimador --- multiplicando el trabajo por 20 (datasets) ---, o usar una búsqueda bayesiana de hiperparámetros como la que ofrece #link("https://scikit-optimize.github.io/stable/auto_examples/sklearn-gridsearchcv-replacement.html")[`scikit-optimize`] --- complejizando el diseño experimental tal vez más de lo necesario.]

= Estimación de la variabilidad en el rendimiento reportado
En última instancia, cualquier métrica evaluada no es otra cosa que un _estadístico_ que representa la "calidad" del clasificador en la tarea a mano. A fin de conocer no solo su estimación puntual sino también darnos una idea de la variabilidad de su rendimiento, para cada dataset y colección de algoritmos, se entrenaron y evaluaron #reps versiones idénticas de cada tarea salvo por la semilla $s$, que luego se usaron para estimar estadísticos de locación (media, mediana) y dispersión (varianza, desvío estándar, rango intercuartil) en la exactitud (#link(<exactitud>)[definición]) y el $R^2$ (#link(<R2-mcf>)[definición]) reportados.

En los conjuntos de datos generados sintéticamente, las semillas se utilizaron para generar #reps versiones distintas y perfectamente replicables del mismo dataset, y en todas se utilizó una misma semilla maestra $s^star$ para definir el _split_ de evaluación. Para los conjuntos de datos "silvestres", las #reps semillas $s_1, dots, s_#reps$ fueron utilizadas para definir diferentes particiones de entrenamiento/evaluación sobre el único dataset disponible.


= Regla de parsimonia

La estrategia de validación cruzada intenta evitar que los algoritmos sobreajusten durante el entrenamiento, evaluando su comportamiento, en cada pliego, sobre observaciones de $XX_"train"$ no usadas para ajustarlos.
No todas las hiperparametrizaciones son equivalentes: en general, para cada hiperparámetro se puede establecer una dirección en la que el modelo se complejiza, en tanto adquiere mayor "flexibilidad" para adaptarse a los datos de entrenamiento #footnote[Por ejemplo, #kn se complejiza a medida que  _disminuye_ $k$, la cantidad de vecinos: las predicciones de $1$-NN sobre la variedad varían más seguido que las de $100$-NN.]. Resolveremos este _trade-off_ entre complejidad y poder predictivo recurriendo a un principio filosófico clásico:

#obs(link("https://es.wikipedia.org/wiki/Navaja_de_Ockham")[Navaja de Occam])[
  Atribuida a William de Ockham (c. 1287--1347), también se conoce como "Principio de Parsimonia", y se suele citar --- en palabras que su autor nunca pronunció exactamente --- como _Entia non sunt multiplicanda praeter necessitatem_, "No se deben multiplicar las entidades sin necesidad". Popularmente, se suele parafrasear como "de entre dos teorías en disputa, es preferible la explicación más simple de un fenómeno".
]
Reformulando, diremos que sujeto a la implementación de _cierto_ algoritmo, cuando dos hiperparametrizaciones $nu, mu$ tienen _casi_ las mismas consecuencias --- alcanzan pérdidas tales que $abs(L(nu) - L(mu)) < c$ con $c$ "suficientemente pequeño" --- preferiremos la más sencilla: la de menor _complejidad_ $C$, para cierta función $C$ a definir.

La validación cruzada de $k$ pliegos nos provee naturalmente de $k$ realizaciones de la métrica a optimizar para cada hiperparametrización, que podemos utilizar para estimar el desvío estándar de la misma. Sobre esta base, implementamos la siguiente regla:
#defn([regla de un desvío estándar o "R1SD"])[
  Sea $mu^star$ la hiperparametrización que minimiza la pérdida de entrenamiento y $hat(s)_(L(mu^star))$ el desvío estimado de dicha pérdida. De entre todas las hiperparametrizaciones a menos de $hat(s)_(L(mu^star))$ de $mu^star$, elíjase _la más sencilla_:
  $         & mu^(1 sigma) = arg min_(mu in Mu) C(mu) \
  "donde" & Mu = {mu : L(mu) <= L(mu^star) + hat(s)_(L(mu^star)) }. $
] <r1sd>

Para definir $C$ en modelos con más de un hiperparámetro sin entrar en consideraciones de "complejidad relativa" de cada uno, definimos un orden de complejidad creciente por clasificador como una lista de pares ordenados de hiperparámetros y la dirección de complejidad creciente. Para #fkdc, $C_#fkdc (mu)$  es creciente en $alpha$, y para cierto $alpha_0$ fijo, decreciente en $h$.

La decisión de ordenar así los parámetros, con $alpha$ primero y $C$ ascendente, hace que en el entrenamiento de #fkdc, el algoritmo "prefiera" soluciones parsimoniosas en que #fkdc se reduce a #kdc --- cuando $alpha = 1$ --- o casi. En consecuencia, al entrenar #fkdc con R1SD solo se seleccionará un $alpha^(1 sigma) > 1$ cuando el rendimiento de #fkdc sea significativamente mejor que el de #kdc.

#obs([complejidad en $h$])[
  La complejidad es _descendente_ en el tamaño de la ventana $h$: a mayor $h$, tanto más grande se vuelve el vecindario donde $K_h (d(x, x_i)) >> 0$ y $x_i$ pesa en la predicción, hasta que eventualmente es tan grande que "todo está cerca de todo" y la predicción en cualquier punto es prácticamente la misma. Análogamente, $k$-NN y su primo $epsilon$-NN tienen complejidad _descendente_ en $k, epsilon$.
]

= Medidas de locación y dispersión no paramétricas
Al no conocer _a priori_ demasiado con respecto a la teoría de la distribución de los estimadores bajo análisis (especialmente #fkdc y #fkn), decidimos comparar el rendimiento con una medida de locación robusta como la mediana (y no la media) entre las #reps repeticiones con distintas semillas de cada clasificador, y las visualizaremos con un _boxplot_ en lugar de un intervalo de confianza.



#bibliography("/refs.bib", title: "Referencias")
