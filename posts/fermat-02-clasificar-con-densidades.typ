#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Clasificar estimando densidades",
  date: "2026-10-05",
  series: "fermat",
  part: 2,
  summary: [El problema de clasificación, el clasificador de Bayes y cómo la estimación de densidad por núcleos lo convierte en un algoritmo concreto: el clasificador de densidad por núcleos.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)
#set math.equation(numbering: "(1)")

#callout(title: "En este post")[
  *¿Cómo se construye un clasificador a partir de estimar densidades?* El clasificador de Bayes dice que hay que asignar cada observación a la clase más probable dada su posición; la estimación de densidad por núcleos (KDE) ofrece una manera concreta de estimar esas probabilidades a partir de los datos. De la combinación sale el clasificador de densidad por núcleos, #kdc, el punto de partida de toda la tesis. Hay notación y algunas cuentas, pero nada que exceda un primer curso de estadística.
]


#plegable[Vocabulario y notación (para consultar cuando haga falta)][
A lo largo de esta monografía tomaremos como referencia enciclopédica el excelente _Elements of Statistical Learning_ @hastieElementsStatisticalLearning2009. En la medida de lo posible, basaremos nuestra notación en la suya.

Denotaremos a las variables independientes #footnote[También conocidas como predictoras, o #emph[inputs].] con $X$. Si $X$ es un vector, accederemos a sus componentes con subíndices, $X_j$. En el contexto del problema de clasificación, la variable _cualitativa_ dependiente #footnote[También conocida como variable respuesta u #emph[output].] será $G$ (de "G"rupo). Usaremos letras mayúsculas como $X, G$ para referirnos a los aspectos genéricos de una variable. Los valores _observados_ se escribirán en minúscula, de manera que el $i$-ésimo valor observado de $X$ será $x_i$ (de nuevo, $x_i$ puede ser un escalar o un vector).

Representaremos a las matrices con letras mayúsculas en negrita, #XX; p. ej., el conjunto de $N$ vectores $d$-dimensionales ${x_i, i in {1, dots, N}}$ será representado por la matriz #XX de dimensión $N times d$.

En general, los vectores _no_ estarán en negrita, excepto cuando tengan $N$ componentes; esta convención distingue el $d$-vector de #emph[inputs] para la $i$-ésima observación, $x_i$, del $N$-vector $bu(x)_j$ con todas las observaciones de la variable $X_j$. Como todos los vectores se asumen vectores columna, la $i$-ésima fila de #XX es $x_i^T$, la traspuesta de la $i$-ésima observación $x_i$. El elemento de la $i$-ésima fila y $j$-ésima columna de la matriz #XX se notará $XX_(i,j)$.


A continuación, algunos símbolos y operadores utilizados en el texto:

#set terms(separator: h(2em, weak: true), spacing: 1em)

/ $[k]$: el conjunto de los enteros positivos del $1$ hasta $k$, ${1, 2, 3, dots, k}$
/ $EE(dot)$: la función esperanza #footnote[En general no hará falta definir el espacio muestral ni la $sigma$-álgebra correspondientes; de hacer falta se indicarán con subíndices.] <fn-pr>
/ $Pr(dot)$: función de probabilidad @fn-pr
/ $ind(x)$: la función indicadora, $ind(x)=cases(1 "si" x "es verdadero", 0 "si no")$
/ $RR$: los números reales; $RR_+$ denotará los reales estrictamente positivos
/ $RR^d$: el espacio euclídeo de dimensión $d$
/ $h$: la ventana ($h in RR_+$) en un estimador de densidad por núcleos en $RR$
/ $K$: función núcleo $RR^d -> RR$; también, el número de clases del problema de clasificación (el contexto desambigua)
/ $iid$: independientes e idénticamente distribuidos #footnote[Típicamente, los elementos aleatorios de #XX son $iid$.]
/ $bu(H)$: ídem $h$, para estimadores en $RR^d$ ($bu(H) in RR^(d times d)$)
/ $K_h, KH$: el núcleo $K$ reescalado por la ventana $h$ o por la matriz $bu(H)$
/ #MM: una variedad arbitraria #footnote[Típicamente riemanniana, compacta y sin frontera; oportunamente definiremos estos calificativos.]
/ $T_p MM$: el espacio tangente a #MM en el punto $p in MM$
/ $dotp(u, v)$: producto interno entre $u, v in T_p MM$ (la métrica riemanniana de #MM en $p$)
/ $norm(dot)$: norma euclídea de un vector de $RR^d$
/ $exp_p$: el mapa exponencial $T_p MM -> MM$ alrededor de $p$
/ $overline(S)$: la _clausura_ del conjunto $S$ (la unión de $S$ y sus puntos límite); ocasionalmente, también el segmento entre dos puntos $overline(a b)$
/ $dg(p, q)$: distancia riemanniana (geodésica) entre $p, q in MM$
/ $bu(X)$: una muestra de $N$ elementos $d$-dimensionales ($XX in RR^(N times d)$)
/ $cal(D)_(f, beta)(x, y)$: distancia macroscópica de Fermat entre $x$ e $y$ inducida por la densidad $f$ con parámetro $beta >= 1$
/ $D_(Q, alpha)(x, y)$: distancia muestral de Fermat entre $x$ e $y$ a través del conjunto $Q$ con parámetro $alpha >= 1$


]

= El problema de clasificación

== Definición y vocabulario #footnote[Adaptado de @hastieElementsStatisticalLearning2009[§2.4, "Statistical Decision Theory"].]
El _aprendizaje estadístico supervisado_ busca estimar (aprender) una variable _respuesta_ a partir de cierta(s) variable(s) _predictora(s)_. Cuando la _respuesta_ es una variable _cualitativa_, el problema de asignar cada observación $X$ a una clase $G in GG={GG_1, dots, GG_K}$ se denomina _de clasificación_. En general, reemplazaremos los nombres o "etiquetas" de clases $GG_i$ por los enteros correspondientes, $G in [K]$. En esta definición del problema las clases son

- _mutuamente excluyentes_: cada observación $X_i$ está asociada a lo sumo a una clase
- _conjuntamente exhaustivas_: cada observación $X_i$ está asociada al menos a una clase.

#defn("clasificador")[
  Un _clasificador_ es una función $hat(G)(X)$ que para cada observación intenta aproximar su verdadera clase $G$ por $hat(G)$ #footnote[Pronunciado "ge sombrero".].
] <clasificador>

Para construir $hat(G)$, contaremos con una muestra o _conjunto de entrenamiento_ $XX, bu(g)$,  de pares $(x_i, g_i), i in {1, dots, N}$ conocidos. Para discernir cuán bien se "ajusta" un clasificador a los datos, la teoría requiere de una "función de pérdida" $L(G, hat(G)(X))$ #footnote[_Loss function_ en inglés. A veces también "función de riesgo" --- _risk function_.]. Será de especial interés la función de clasificación $f$ que minimiza el "error de predicción esperado" $"EPE"$ #footnote[Del inglés #emph[expected prediction error].]:

$
  hat(G) = arg min_f "EPE"(f) = arg min_f EE(L(G, f(X))),
$
donde la esperanza es respecto de la distribución conjunta $(X, G)$. Por la ley de la esperanza total, podemos condicionar a $X$ #footnote[Aquí "condicionar" implica factorizar la densidad conjunta $Pr(X, G) = Pr(G|X) Pr(X)$ donde $Pr(G|X) = hfrac(Pr(X, G), Pr(X))$, y repartir la integral bivariada de manera acorde.] y expresar el EPE como

$
  "EPE"(f) & = EE_(X,G)(L(G, f(X))) \
           & = EE_X EE_(G|X)(L(G, f(X))) \
           & = EE_X sum_(k in [K]) L(GG_k, f(X)) Pr(GG_k | X).
$
Y basta con minimizar punto a punto para obtener una expresión computable de $hat(G)$:
$
  hat(G)(x) & = arg min_f EE(L(G, f(X))) \
            & = arg min_(g in GG) sum_(k in [K]) L(GG_k, g) Pr(GG_k | X = x).
$
Con la _pérdida 0-1_ #footnote[Es decir, la función indicadora de un error de predicción, $bu(01)(hat(G), G) = ind(hat(G) != G)$.], la expresión se simplifica a
$
  hat(G)(x) & = arg min_(g in GG) sum_(k in [K]) ind(cal(G)_k != g) Pr(GG_k|X=x) \
            & = arg min_(g in GG) [1-Pr(g|X=x)] \
            & = arg max_(g in GG) Pr(g | X = x).
$<clf-bayes>

Esta razonable solución se conoce como el _clasificador de Bayes_, y sugiere que clasifiquemos a cada observación según la clase modal #footnote[Es decir, la de mayor probabilidad.] condicional a su distribución conjunta $Pr(G|X)$.
Su error esperado de predicción $"EPE"$ se conoce como la _tasa de Bayes_. Un aproximador directo de este resultado es el clasificador de "$k$ vecinos más cercanos" #footnote[Del inglés _k-nearest neighbors_.].

#defn("clasificador de k-vecinos-más-cercanos")[
  Sean $x^((1)), dots, x^((k))$ los $k$ #footnote[Que no guarda relación alguna con la cantidad $K$ del problema de clasificación.] vecinos más cercanos a $x$, y $g^((1)), dots, g^((k))$ sus respectivas clases. El clasificador de k-vecinos-más-cercanos --- que notaremos #kn --- le asignará a $x$ la clase más frecuente entre $g^((1)), dots, g^((k))$. Más formalmente:
  $
    hat(G)_(#kn)(x) & = g = arg max_(g in GG) sum_(i in [k]) ind(g^((i)) = g).
  $

] <kn-clf>

== Clasificador de Bayes empírico

La _regla de Bayes_,
$
  Pr(G|X) = (Pr(X| G) times Pr(G)) / (Pr(X)),
$
nos sugiere una reescritura de $hat(G)$ que facilita su estimación:
$
  hat(G)(x) = g & = arg max_(g in GG) Pr(g | X = x) \
                & <=> Pr(g|X=x) = max_(g in GG) Pr(g|X=x) \
                & <=> Pr(X=x|g) times Pr(g) = max_(g in GG) Pr(X=x|g) times Pr(g) \
                & <=> Pr(X=x|GG_k) times Pr(GG_k) = max_(k in [K]) Pr(X=x|GG_k) times Pr(GG_k),
$

donde el segundo $<=>$ vale siempre que $Pr(X = x) > 0$ --- y dado que _observamos_ $X=x$, el supuesto es razonable.

A las probabilidades "incondicionales" de clase $Pr(GG_k)$ se las suele llamar su "distribución a priori", y notarlas por $pi = (pi_1, dots, pi_K)^T, sum pi_k = 1$. Una aproximación razonable, si es que el conjunto de entrenamiento se obtuvo por muestreo aleatorio simple, es estimarlas a partir de las proporciones muestrales:
$
  forall k in [K], quad hat(pi)_k & = N^(-1) sum_(i in [N]) ind(g_i = GG_k) \
                                  & = \#{g_i : g_i = GG_k, i in [N]} / N .
$


Resta hallar una aproximación $hat(Pr)(X=x|GG_k)$ a las probabilidades condicionales $X|GG_k$ para cada clase.

= Estimación de densidad por núcleos

Tal vez la metodología más estudiada a tales fines es la estimación de densidad por núcleos, reseñada en @hastieElementsStatisticalLearning2009[§6.6]. En el caso unidimensional, al estimador resultante se lo conoce por el nombre de Parzen-Rosenblatt, por sus contribuciones fundacionales en el área @parzenEstimationProbabilityDensity1962 @rosenblattRemarksNonparametricEstimates1956.

== Estimación unidimensional


Para fijar ideas, asumamos que $X in RR$ y consideremos la estimación de densidad en una única clase para la que contamos con $N$ ejemplos ${x_1, dots, x_N}$. Una aproximación $hat(f)$ directa sería
$
  hat(f)(x_0) = \#{x_i in cal(N)(x_0)} / (N times h),
$ #label("eps-nn")


donde $cal(N)$ es un vecindario métrico de $x_0$ de diámetro $h$.

Esta estimación es irregular, con saltos discretos en el numerador, por lo que se prefiere el estimador "suavizado por núcleos" de Parzen-Rosenblatt. Pero primero: ¿qué es un núcleo?


#defn([función núcleo o _kernel_])[

  Se dice que $K(x) : RR -> RR$ es una _función núcleo_ si cumple que

  + toma valores reales no negativos: $K(u) >= 0$,
  + está "normalizada": $integral K(u) dif u = 1$,
  + es simétrica en torno al cero: $K(u) = K(-u)$ y
  + alcanza su máximo en el centro: $max_u K(u) = K(0)$.
] <kernel>

#obs[Todas las funciones de densidad simétricas y unimodales centradas en 0 son núcleos; en particular, la densidad "normal estándar" $ phi.alt(x) = 1/sqrt(2 pi) exp(-x^2 / 2) $ lo es.]

#obs[Si $K(u)$ es un núcleo, entonces $K_h (u) = 1/h op(K)(u / h)$ también lo es.]

#defn("estimador de densidad por núcleos")[


  Sea $bu(x) = (x_1, dots, x_N)^T$ una muestra #iid de cierta variable aleatoria escalar $X in RR$ con función de densidad $f$. Su estimador de densidad por núcleos, KDE #footnote[De _Kernel Density Estimator_, por sus siglas en inglés.] o estimador de Parzen-Rosenblatt es
  $
    hat(f)(x_0) = 1/N sum_(i=1)^N 1/ h K ((x_0 - x_i)/h) = 1/N sum_(i=1)^N K_h (x_0 - x_i),
  $

  donde $K_h$ es un núcleo según la #link(<kernel>)[definición de función núcleo]. Al parámetro $h$ se lo conoce como "ventana" de suavizado o _smoothing_.
] <parzen>

#obs[
  La densidad de la distribución uniforme centrada en 0 de diámetro 1, $U(x) = ind(-1/2 < x <= 1/2)$ es un núcleo.  Luego, $ U_h (x) = 1/h ind(-h/2 < x <= h/2) $ también es un núcleo válido, y por ende el estimador de @eps-nn resulta estrechamente emparentado al #link(<parzen>)[estimador de Parzen-Rosenblatt]:
  $
    hat(f)(x_0) & = \#{x_i in cal(N)(x_0)} / (N times h) \
                & = 1 / N sum_(i in [N]) 1/h ind(-h/2 < x_i - x_0 <= h/2) \
                & = 1 / N sum_(i in [N]) U_h (x_i - x_0),
  $
  con la diferencia de que el estimador de @eps-nn fija el _diámetro_ del vecindario a considerar, y el de #link(<kn-clf>)[k-vecinos-más-cercanos] fija la _cantidad_ de vecinos a tener en cuenta #footnote[Al primero se lo conoce como $epsilon$-_nearest neighbors_ ($epsilon$-NN) con $epsilon$ denotando el _radio_ del vecindario; el segundo es el ya descrito $k$-NN.].
]
== Clasificador de densidad por núcleos

Si $hat(f)_k, k in [K]$ son estimadores de densidad por núcleos de cada una de las $K$ densidades condicionales $X|GG_k$ según la #link(<parzen>)[definición de KDE], podemos construir el siguiente clasificador _plug-in_:

#defn(
  "clasificador de densidad por núcleos",
)[ Sean $hat(f)_1, dots, hat(f)_K$ estimadores de densidad por núcleos según la #link(<parzen>)[definición de KDE]. Sean además $hat(pi)_1, dots, hat(pi)_K$ las estimaciones de la probabilidad incondicional de pertenecer a cada grupo $GG_1, dots, GG_K$. Luego, la siguiente regla constituye un clasificador de densidad por núcleos que notaremos #kdc:
  $
    hat(G)_#kdc (x) = g & = arg max_(i in [K]) hat(Pr)(GG_i | X = x) \
                        & = arg max_(i in [K]) hat(Pr)(X=x|GG_i) times hat(Pr)(GG_i) \
                        & = arg max_(i in [K]) hat(f)_i (x) times hat(pi)_i .
  $] <kdc-duro>

== Clasificadores duros y suaves

Un clasificador que _asigna_ cada observación  a _una_ clase (la más probable) se suele llamar _clasificador duro_. Un clasificador que asigna a cada observación _una distribución de probabilidades de clase_ $hat(gamma)$ #footnote[$hat(gamma)$ aproximará $gamma = (gamma_1, dots, gamma_K)^T$ con $gamma_i = Pr(G = GG_i), quad sum_(i in [K]) gamma_i = 1$.] se suele llamar _clasificador blando_. Dado un clasificador _blando_ $hat(G)_"Blando"$, es trivial construir el clasificador duro asociado $hat(G)_"Duro"$:
$
  hat(G)_"Duro" (x_0) = arg max_(i in [K]) [hat(G)_"Blando" (x_0)]_i = arg max_(i in [K]) hat(gamma)_i .
$

#obs[
  El #link(<kdc-duro>)[clasificador de densidad por núcleos] es la versión dura de un clasificador blando donde $ hat(gamma)_i = (hat(f)_i (x) times hat(pi)_i) / (sum_(j in [K]) hat(f)_j (x) times hat(pi)_j) . $
]

#obs[
  Ciertos clasificadores solo pueden ser duros, como $hat(G)_"1-NN"$ (el #link(<kn-clf>)[clasificador de k-vecinos-más-cercanos] con $k=1$), o aquellos derivados de algoritmos que clasifican sin estimar probabilidades condicionales, como los basados en SVM #footnote[Del inglés _support vector machines_, "máquinas de vectores de soporte" @cortesSupportvectorNetworks1995.].
]

Dos clasificadores _blandos_ pueden tener la misma pérdida 0-1, pero "pintar" dos panoramas muy distintos respecto a cuán "seguros" están de cierta clasificación. Por caso, sea $epsilon > 0$ y arbitrariamente pequeño:
$
  hat(G)_"C(onfiado)" (x_0) &: hat(Pr)(GG_i | X = x_0) = cases(1 - epsilon &" si " i = 1, hfrac(epsilon, (K - 1)) &" si " i != 1) \
  hat(G)_"D(udoso)" (x_0) &: hat(Pr)(GG_i | X = x_0) = cases(1/K + epsilon &" si " i = 1, 1 / K - hfrac(epsilon, (K - 1)) &" si " i != 1).
$
$hat(G)_C$ está "casi seguro" de que la clase correcta es $GG_1$, mientras que $hat(G)_D$ otorga casi las mismas probabilidades a todas las clases. Para el entrenamiento y análisis de clasificadores blandos como el de densidad por núcleos, será relevante encontrar funciones de pérdida que recompensen la confianza de un clasificador _cuando esta esté justificada_ #footnote[Y lo penalicen cuando no --- es decir, cuando la confianza está puesta en la clase errada. Más al respecto, más adelante.].


#bibliography("/refs.bib", title: "Referencias")
