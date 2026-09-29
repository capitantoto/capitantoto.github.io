#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Estimar densidades (y clasificar) sobre una variedad",
  date: "2026-10-26",
  series: "fermat",
  part: 5,
  summary: [De von Mises y Fisher al estimador de Pelletier: cómo se estima una densidad por núcleos en una variedad de Riemann, qué papel juega la densidad de volumen y cómo se construye con él un clasificador consistente.],
  status: "draft",
  lang: "es",
)
#show: post.with(..meta)
#set math.equation(numbering: "(1)")

#callout(title: "En este post")[
  *¿Se puede estimar una densidad, y clasificar, sobre una variedad?* Sí. Después de un repaso histórico por la estadística direccional --- von Mises en el círculo, Fisher en la esfera ---, presentamos el estimador de densidad por núcleos de Pelletier para variedades de Riemann compactas sin frontera, que converge, y el clasificador que Loubes y Pelletier construyen con él, fuertemente consistente para dos clases. El precio es un factor, la _densidad de volumen_, que solo se sabe calcular en casos particulares como la esfera. La primera sección es historia; el resto es matemático.
]


= Probabilidad en variedades
Hemos definido una clase bastante general de variedades --- las variedades de Riemann --- capaces de soportar funciones de densidad y sus estimaciones @pelletierKernelDensityEstimation2005. Estos desarrollos relativamente modernos no constituyen el origen de la probabilidad en variedades. Mucho antes de su sistematización, ciertos casos particulares fueron ya bien estudiados y allanaron el camino para el interés en variedades más generales.

Probablemente la referencia más antigua a un elemento aleatorio en una variedad distinta a $RR^d$ se deba a Richard von Mises, en _Sobre la naturaleza entera del peso atómico y cuestiones relacionadas_ @vonmisesUberGanzzahligkeitAtomgewicht1918 #footnote["Über die 'Ganzzahligkeit' der Atomgewichte und verwandte Fragen", en el alemán original.]. En él, von Mises se plantea si los pesos atómicos --- que empíricamente se observan siempre muy cercanos a la unidad para los elementos más livianos --- son enteros con un cierto error de medición, y argumenta que para tal tratamiento, el "error gaussiano" clásico es inadecuado:

#quote(attribution: [traducido de @vonmisesUberGanzzahligkeitAtomgewicht1918])[
  [$dots$] Pues no es evidente desde el principio que, por ejemplo, para un peso atómico de $35,46$ (Cl), el error sea de $+0,46$ y no de $-0,54$: es muy posible que se logre una mejor concordancia con ciertos supuestos con la segunda determinación. A continuación, se desarrollan los elementos --- esencialmente muy simples --- de una "teoría del error cíclico", que se complementa con la teoría gaussiana o "lineal" y permite un tratamiento completamente inequívoco del problema de la "enteridad" y cuestiones similares.
]

#figure(
  image("/assets/fermat/img/von-mises-s1.png", height: 12em),
  caption: flex-caption(
    [Pretendido "error" --- diferencia módulo 1 --- de los pesos atómicos medidos para ciertos elementos sobre $S^1$. Nótese cómo la mayoría de las mediciones se agrupan en torno al $0.0$. Fuente: @vonmisesUberGanzzahligkeitAtomgewicht1918],
    [Pesos atómicos "módulo 1" sobre $S^1$],
  ),
)
Motivado también por un problema del mundo físico, Ronald Fisher escribe "Dispersiones en la esfera" @fisherDispersionSphere1957, donde desarrolla una teoría apropiada para mediciones de posición en una esfera #footnote[Y como era de esperar del padre del test de hipótesis, también su correspondiente test de significancia, análogo al "t de Student".] y la ilustra a partir de mediciones de la dirección de la "magnetización termorremanente" de flujos de lava  en Islandia.
#footnote[
  Los datos que Fisher usa en la Sección 4 son mediciones de magnetismo remanente en muestras de roca de flujos de lava islandeses, recolectadas por J. Hospers en Pembroke College, Cambridge. Cuando la lava se enfría y solidifica, los minerales ferromagnéticos (como la magnetita) se alinean con el campo magnético terrestre del momento y quedan "congelados" en esa orientación. Esto se llama magnetización termorremanente. Siglos o milenios después, se puede tomar una muestra de esa roca y medir en qué dirección apunta su magnetización residual, hecho que Fisher utiliza para "testear" si entre "su presente" y el período Cuaternario el campo magnético terrestre se invirtió --- cosa que efectivamente sucedió.
]


Dos décadas más tarde, los casos particulares de von Mises ($S^1$) y Fisher ($S^2$) fueron integrados al caso más general $S^n$ en lo que se conocería como "estadística direccional" #footnote[La $n$-esfera $S^n$ de radio $1$ con centro en $0$ contiene exactamente a todos los vectores unitarios --- es decir, todas las _direcciones_ posibles de un vector --- en su espacio ambiente $RR^(n+1)$.]. En 1975 se habla ya de _teoría de la distribución_ para la distribución von Mises--Fisher @mardiaDistributionTheoryMisesFisher1975, la "más importante en el análisis de datos direccionales". A fines de los \'80 Jupp y Mardia plantean "una visión unificada de la teoría de la estadística direccional" @juppUnifiedViewTheory1989, adaptando conceptos clave del "caso euclídeo" como las familias exponenciales y el teorema central del límite, entre otros.

Aunque el caso particular de la $n$-esfera sí fue bien desarrollado a lo largo del siglo XX, no se alcanzó un tratamiento más general de la estadística en variedades riemannianas conocidas pero arbitrarias.

= KDE en variedades de Riemann

Ya en el siglo XXI, Bruno Pelletier propone una adaptación directa del estimador de densidad por núcleos multivariado (ver #parte("fermat-03-maldicion-y-variedades")[tercera parte]) en variedades de Riemann compactas sin frontera @pelletierKernelDensityEstimation2005. Lo presentamos primero y ampliamos los detalles a continuación.


#defn([KDE en variedades de Riemann @pelletierKernelDensityEstimation2005[Ecuación 1]])[
  Sean
  - $(MM, g)$ una variedad de Riemann compacta y sin frontera de dimensión intrínseca $d$, y $dg$ la distancia de Riemann #footnote[Mantenemos la notación del original: $d$ es un entero y #dg un operador, lo que debería evitar la confusión; asimismo, el teorema que sigue escribe $n$ por $N$ para el tamaño muestral.],
  - $K$ un _núcleo isotrópico_ en #MM soportado en la bola unitaria en $RR^d$ y
  - dados $p, q in MM$, $theta_p (q)$ la _función de densidad de volumen en_ #MM.
  Sea #XX una muestra de $N$ observaciones de una variable aleatoria $X$ con densidad $f$ soportada en #MM.
  Luego, el estimador de densidad por núcleos para $X$ es la #box[$hat(f) :MM ->RR$] que a cada $p in MM$ le asocia el valor
  $
    hat(f) (p) & = N^(-1) sum_(i=1)^N K_h (p,X_i) \
               & = N^(-1) sum_(i=1)^N 1/h^d 1/(theta_X_i (p))K((dg(p, X_i))/h),
  $
] <kde-variedad>
con la restricción de que la ventana $h <= h_0 < "iny" MM$, el radio de inyectividad de #MM #footnote[
  Esta restricción no es catastrófica. Para toda variedad compacta, el radio de inyectividad será estrictamente positivo @munozEstimacionNoParametrica2011[Prop. 3.3.18]. Como además $h$ es en realidad una sucesión ${h_n}_(n=1)^N$ decreciente como función del tamaño muestral, siempre existirá un cierto tamaño muestral a partir del cual $h_n < "iny" MM$.
].
El autor prueba la convergencia en $L^2(MM)$:

#thm([convergencia de $hat(f)$ en $L^2$ @pelletierKernelDensityEstimation2005[§3 Teorema 5]])[
  Sea $f$ una densidad de probabilidad dos veces diferenciable en #MM con segunda derivada covariante acotada. Sea $hat(f)_n$ el estimador de densidad definido en la #link(<kde-variedad>)[definición de KDE en variedades de Riemann] con ventana $h_n <= h_0 < "iny" MM$. Luego, existe una constante $C_f$ tal que
  $
    EE norm(hat(f)_n - f)_(L^2(MM))^2 <= C_f (1/ (n h^d)+ h^4).
  $
  En consecuencia, para $h tilde n^(-1/(d+4))$, tenemos $ EE norm(hat(f)_n - f)_(L^2(MM))^2 = O(n^(-4/(d+4))). $
]
Nótese que esta formulación sugiere en qué orden comenzar la búsqueda de un $h$ "óptimo". Guillermo Henry y Daniela Rodríguez prueban la consistencia fuerte de $hat(f)$ @henryKernelDensityEstimation2009[Teorema 3.2]: bajo los mismos supuestos de @pelletierKernelDensityEstimation2005, obtienen que
$
  sup_(p in MM) abs(hat(f)_n(p) - f(p)) attach(->, t: "c.s.") 0.
$

#defn("núcleo isotrópico")[ Sea $K: RR_+ -> RR$ un mapa no negativo tal que:
  #table(
    align: (left, right),
    stroke: none,
    columns: 2,
    $integral_(RR^d) K(norm(x)) dif lambda(x) = 1$, [$K$ es función de densidad en $RR^d$],
    $integral_(RR^d) x K(norm(x)) dif lambda(x) = 0$, [Si $Y~K, thick EE Y = 0$],
    $integral_(RR^d) norm(x)^2 K(norm(x)) dif lambda(x) < oo$, [Si $Y~K, thick var Y < oo$],
    $sop K = [0, 1]$, "",
    $sup_x K(x) = K(0)$, [$K$ se maximiza en el origen],
  )

  Decimos entonces que el mapa $RR^d in.rev x |-> K(norm(x)) in RR$ es un _núcleo isotrópico_ en $RR^d$ soportado en la bola unitaria.
]

#obs[Todo núcleo isotrópico es también un núcleo válido según la definición de KDE multivariada de la #parte("fermat-03-maldicion-y-variedades")[tercera parte]. A nuestros fines, continuaremos utilizando el núcleo normal.]
#defn(
  [función de densidad de volumen @besseManifoldsAllWhose1978[§6.2]],
)[
  Sean $p, q in MM$; le llamaremos _función de densidad de volumen_ en #MM a
  $
    theta_p : q |-> mu_(exp_p^* g) / mu_(g_p) (exp_p^(-1)(q)),
  $
  es decir, el cociente entre la medida canónica de la métrica riemanniana $exp_p^* g$ sobre $T_p MM$ (la métrica _pullback_ que resulta de transferir $g$ de $MM$ a $T_p MM$ a través del mapa exponencial $exp_p$) y la medida de Lebesgue de la estructura euclídea que $g_p$ define en $T_p MM$.
] <vol-dens>

#obs[

  $theta_p (q)$ está bien definida "cerca" de $p$: vale $theta_p (p) = 1$ y $theta_p (q) -> 1$ cuando $q -> p$. Ciertamente está definida para todo $q$ dentro del radio de inyectividad de $p$, $dg(p, q) < "iny"_p MM$ #footnote[Besse la define en todo $T_p MM$ como función del vector $v$, vía _campos de Jacobi_ @besseManifoldsAllWhose1978[§6.3] @pelletierKernelDensityEstimation2005[§2]; como función de $q$, solo está bien definida donde $exp_p$ es inyectiva. Su tratamiento global escapa al tema de esta monografía.].
]


El mapa exponencial alrededor de $p, thick exp_p : T_p MM -> MM$ es un difeomorfismo en cierta bola normal alrededor de $p$, así que admite una inversa continua y biyectiva al menos en tal bola $B_p$; lo notaremos $ exp_p^(-1) : B_p -> T_p MM $.
Así, $exp_p^(-1) (q)$ es la representación de $q$ en las coordenadas localmente euclídeas del espacio tangente a $p$ (o sencillamente "locales a $p$"). De esta cantidad $x = exp_p^(-1) (q)$, queremos conocer el cociente entre dos medidas:
- la medida canónica de la métrica _pullback_ de $g$: la métrica inducida en $T_p MM$ por la métrica riemanniana $g$ en #MM, y
- la medida de Lebesgue en la estructura euclídea de $T_p MM$.

En otras palabras, $theta_p (q)$ representa cuánto se infla/encoge el espacio en la variedad #MM alrededor de $p$, relativo al volumen "natural" del espacio tangente. En general, su cómputo resulta sumamente complejo, salvo en casos particulares como las variedades "planas" o de curvatura constante.

= Densidad de volumen en la esfera

#obs(
  [@besseManifoldsAllWhose1978[§6.2]],
)[En una variedad plana, $theta_p (q)$ es idénticamente igual a 1 para todo $p, q in MM$.]

Una variedad plana tiene _curvatura_ #footnote[La _curvatura_ de un espacio es una de las propiedades fundamentales que estudia la geometría riemanniana; en este contexto, basta con la comprensión intuitiva de que una variedad no plana tiene _cierta_ curvatura.] nula en todo punto. De entre las variedades curvas, las $n$-esferas son de las más sencillas, y tienen curvatura _positiva y constante_. Esta estructura vuelve posible el cómputo de $theta_p (q)$ en $S^n$.

En _Kernel Density Estimation on Riemannian Manifolds: Asymptotic Results_ @henryKernelDensityEstimation2009, Guillermo Henry y Daniela Rodríguez estudian algunas propiedades asintóticas del #link(<kde-variedad>)[estimador de KDE en variedades de Riemann], y las ejemplifican con datos de sitios volcánicos en la superficie terrestre. Para ello, desarrollan $theta_p (q)$ en $S^2$ y llegan a que #footnote[Recordemos que la antípoda de $p$, $-p$, cae justo fuera de $"iny"_p S^2$.]

$
  theta_p (q) = cases(
    R abs(sin(dg(p, q) slash R)) / dg(p, q) & "si" q != p\, -p,
    1 & "si" q = p
  ).
$


#figure(caption: flex-caption(
  [Densidad estimada de sitios volcánicos en la superficie terrestre ($approx S^2$) para distintos valores de $h$. Fuente: @henryKernelDensityEstimation2009],
  [Densidad estimada en $S^2$ para distintos valores de $h$],
))[#image("/assets/fermat/img/henry-rodriguez-bolas.png", height: 22em)]

Para variedades de curvatura variable, el cálculo es mucho más complejo. En un trabajo reciente, por ejemplo, se reseña:

#quote(
  attribution: [@berenfeldDensityEstimationUnknown2021[§1.2, "Resultados Principales"]],
)[
  Un problema restante a esta altura es el de entender cómo la _regularidad_ #footnote[En este contexto, se entiende que una variedad es más regular mientras menos varíe su densidad de volumen punto a punto.] de #MM afecta las tasas de convergencia de funciones suaves. $[dots]$ en dimensión $1$ al menos, la regularidad de la variedad #MM no afecta la tasa para estimar $f$ aun cuando #MM es desconocida. Sin embargo, la función de densidad de volumen $theta_p (q)$ _no_ es constante tan pronto como $d >= 2$ y obtener un panorama global en mayores dimensiones es todavía un problema abierto y presumiblemente muy desafiante.
]

= Clasificación en variedades

Un desarrollo directo del #link(<kde-variedad>)[estimador de KDE en variedades de Riemann] consta en _A kernel based classifier on a Riemannian manifold_ @loubesKernelbasedClassifierRiemannian2008,
donde los autores construyen un clasificador para un objetivo de dos clases $GG in {0, 1}$ con #emph[inputs] $X$ soportadas sobre una variedad de Riemann. A tal fin, minimizan la pérdida 0-1 y siguen la regla de Bayes, de manera que su clasificador _duro_ resulta:

$
  hat(G)(X) = cases(1 "si" hat(Pr)(G=1|X) > hat(Pr)(G=0|X), 0 "si no"),
$
que está de acuerdo con el estimador del clasificador de Bayes basado en densidad por núcleos para $K$ clases propuesto en la #parte("fermat-02-clasificar-con-densidades")[segunda parte] cuando $K=2$. En el caso más general con $K > 2$ clases,
$
  hat(Pr)(G=k|X) &= (hat(f)_k (x) times hat(pi)_k) / underbrace((sum_(j in [K]) hat(f)_j (x) times hat(pi)_j), =c) = c^(-1) times hat(f)_k (x) times hat(pi)_k,
$
de modo que la tarea es equivalente a maximizar $hat(f)_k (x) times hat(pi)_k$ sobre $k in [K]$. Si $N_k$ es la cantidad de observaciones en la clase $k$ y  $sum_k N_k = N$, podemos reescribir el estimador de densidad de la clase $k$ como:
$
  hat(f)_k (x) & = N_k^(-1) sum_(i=1)^N_k K_h (x,X_i) \
               & = (sum_(i=1)^N ind(G_i = k) K_h (x,X_i)) / (sum_(i=1)^N ind(G_i = k)),
$
como además $hat(pi)_k = N_k slash N =N^(-1) sum_(i=1)^N ind(G_i = k)$, resulta que
$
  hat(f)_k (x) times hat(pi)_k& = (sum_(i=1)^N ind(G_i = k) K_h (x,X_i)) / (sum_(i=1)^N ind(G_i = k)) times (sum_(i=1)^N ind(G_i = k)) / N \
  & = N^(-1) sum_(i=1)^N ind(G_i = k) K_h (x,X_i).
$
Y suprimiendo la constante $N$ concluimos que la regla de clasificación resulta equivalente a:
$
  hat(G)(p) = arg max_(k in [K]) sum_(i=1)^N ind(G_i = k) K_h (p,X_i),
$ <clf-kde-variedad>
para todo $p in MM$ con $K_h_n$ un núcleo isotrópico con sucesión de ventanas $h_n$ @loubesKernelbasedClassifierRiemannian2008[Ecuación 3.1].
Los autores toman de @devroyeProbabilisticTheoryPattern1996 la siguiente definición de _consistencia_:

#defn([consistencia de un clasificador @devroyeProbabilisticTheoryPattern1996[§6.1]])[
  Sea ${hat(G)_n : n in NN}$ una secuencia de clasificadores #footnote[A veces también llamada una _regla_ de clasificación.] de modo que el $n$-ésimo clasificador está construido con las primeras $n$ observaciones de la muestra $XX, bu(g)$. Sea $L_n = Pr(hat(G)_n (X) != G | XX, bu(g))$ la probabilidad de error de $hat(G)_n$ condicional a la muestra, y $L^*$ la que alcanza el clasificador de Bayes (ver #parte("fermat-02-clasificar-con-densidades")[segunda parte]).

  Diremos que la regla ${hat(G)_n}$ es (débilmente) consistente --- o asintóticamente eficiente en el sentido del riesgo de Bayes --- para cierta distribución $(X, G)$ si cuando $n-> oo$
  $
    EE L_n = Pr(hat(G)_n (X) != G) -> L^*
  $
  y fuertemente consistente si
  $
    lim_(n -> oo) L_n = L^* "con probabilidad 1".
  $
]

En el trabajo, se prueba que el clasificador de @clf-kde-variedad es fuertemente consistente para $K=2$.


#bibliography("/refs.bib", title: "Referencias")
