#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Variedades de Riemann, lo justo y necesario",
  date: "2026-10-19",
  series: "fermat",
  part: 4,
  summary: [Topología, cartas, métricas, geodésicas, mapa exponencial y radio de inyectividad: las definiciones mínimas para hablar de densidades sobre una variedad.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)
#set math.equation(numbering: "(1)")

#callout(kind: "math", title: "Nivel matemático")[
  *¿Qué es, exactamente, una variedad?* Este es el post más abstracto de la serie: definiciones de topología y geometría riemanniana, casi sin aplicaciones. Si no te interesa la maquinaria, alcanza con llevarse tres ideas: una variedad de Riemann es un espacio que localmente se parece a $RR^d$ y en el que se pueden medir longitudes; una _geodésica_ es el camino más corto sobre ella; y el _radio de inyectividad_ dice hasta qué distancia vale la aproximación local por un espacio euclídeo. Con eso se puede seguir en la #parte("fermat-05-densidades-en-variedades")[quinta parte], o saltar directo a la #parte("fermat-07-distancia-de-fermat")[distancia de Fermat].
]


Adelantando la respuesta a la segunda pregunta, resulta ser que si el soporte de $X$ es una "variedad de Riemann" y se cumplen ciertas condiciones razonables, sí es posible estimar su densidad por núcleos  @pelletierKernelDensityEstimation2005.

A continuación, haremos un recorrido sumario e idiosincrático por ciertos conceptos básicos de topología y variedades que consideramos necesarios para motivar la definición de variedades riemannianas, que de paso precisarán la respuesta a la primera pregunta en el contexto que nos interesa. Seguiremos la exposición de la monografía _Estimación no paramétrica de la densidad en variedades Riemannianas_ @munozEstimacionNoParametrica2011, que a su vez sigue, entre otros, el clásico _Introduction to Riemannian Manifolds_ @leeIntroductionRiemannianManifolds2018.

= Variedades diferenciables


#defn([espacio topológico @leeIntroductionRiemannianManifolds2018])[

  Formalmente, se llama *espacio topológico* al par ordenado $(X, T)$ formado por un conjunto $X$ y una _topología_ $T$ sobre $X$, es decir una colección de subconjuntos de $X$ que cumple las siguientes tres propiedades:
  + El conjunto vacío y $X$ están en $T$: $ emptyset in T,quad X in T, $
  + La intersección de cualquier subcolección _finita_ de $T$ está en $T$:
  $ U in T, V in T => U inter V in T, $
  + La unión de _cualquier_ subcolección de conjuntos de $T$ está en $T$:
  $
    forall S subset T, thick union.big_(O in S) O in T.
  $
]
A los conjuntos pertenecientes a la topología $T$ se les llama "conjuntos abiertos" o simplemente "abiertos" de $(X, T)$; a sus complementos en $X$, "conjuntos cerrados".

#defn([entorno @leeIntroductionRiemannianManifolds2018])[
  Si $(X,T)$ es un espacio topológico y $p$ es un punto perteneciente a $X$, un _entorno_ #footnote[También se los conoce como "vecindarios" o _neighborhoods_ en inglés.] del punto $p$ es un conjunto $V$ en el que está contenido un conjunto abierto $U$ que incluye al propio $p: p in U subset.eq V$.
]

#defn([espacio de Hausdorff @leeIntroductionRiemannianManifolds2018])[

  Sea $(X, T)$ un espacio topológico. Se dice que dos puntos $p, q in X$ cumplen la propiedad de Hausdorff si existen dos entornos $U_p$ de $p$ y $U_q$ de $q$ tales que $U_p inter U_q = emptyset$ (es decir, son disjuntos).

  Se dice que un espacio topológico es un espacio de Hausdorff #footnote[Que "verifica la propiedad de Hausdorff", "es separado" o "es $bu(T_2)$".] si todo par de puntos distintos del espacio verifica la propiedad de Hausdorff.
]
En términos coloquiales, un espacio de Hausdorff es aquel donde todos sus puntos están "bien separados".

#defn(
  [variedad topológica @munozEstimacionNoParametrica2011[Def. 3.1.1], @leeIntroductionRiemannianManifolds2018[Apéndice A]],
)[
  Una variedad topológica de dimensión $d in NN$ es un espacio topológico $(MM, T)$ de Hausdorff, de base numerable, que es #strong[localmente homeomorfo a $RR^d$]. Es decir, para cada $p in MM$ existe un abierto $U in T$ y un abierto $A subset.eq RR^d$, tal que $p in U$ #footnote[De modo que $U$ es un entorno de $p$.] y existe un homeomorfismo $phi : U -> A$.
]

#obs(
  "Sobre variedades con y sin frontera",
)[ Toda $d$-variedad #footnote[Es decir, variedad de dimensión $d$.] tiene puntos interiores, pero algunas además tienen una _frontera_; esta frontera es a su vez una variedad _sin_ frontera de dimensión $d - 1$. Por caso: un disco en el plano euclídeo $RR^2$ es una $2$-variedad _con_ frontera, cuya frontera es una variedad de dimensión $2 - 1 = 1$ sin frontera: el círculo. De aquí en más, cuando hablemos de variedades topológicas, nos referiremos a variedades _sin frontera_.]


En una variedad topológica, cobra sentido el concepto de cercanía pero no necesariamente de _distancia_, y es posible definir funciones continuas y límites.

Un _homeomorfismo_ #footnote[Del griego _homo-_, "igual", y _-morfo_, "forma": de igual forma.] es una función $phi$ entre dos espacios topológicos que es biyectiva y tal que tanto ella como su inversa son continuas. El par ordenado $(U, phi)$ es una _carta #footnote[_Chart_ en inglés.] alrededor de $p$_.

A un conjunto numerable de tales cartas que cubran completamente la variedad se lo denomina "atlas". Simbólicamente, #box[$cal(A) = {(U_alpha, phi_alpha) : alpha in cal(I)}$] es un atlas si y solo si $MM = union_alpha U_alpha$. Al conjunto de entornos ${U_alpha : (U_alpha, phi_alpha) in cal(A)}$ que componen un atlas se lo denomina "cobertura" de #MM.

Cuando un homeomorfismo --- y su inversa --- es $r$ veces diferenciable, se le llama _$C^r$-difeomorfismo_, o simplemente difeomorfismo #footnote[Luego, un homeomorfismo es un $C^0$-difeomorfismo.]. En particular, un $C^oo$-difeomorfismo es un difeomorfismo _suave_.

#defn([cartas suavemente compatibles])[
  Sean $(MM, T)$ una variedad topológica de dimensión $d$ y sean $(U, phi), (V, psi)$ dos cartas. Diremos que son _suavemente compatibles_ #footnote[_Smoothly compatible_ según @leeIntroductionRiemannianManifolds2018[ § "Smooth Manifolds and Smooth Maps"]. @munozEstimacionNoParametrica2011 lo denomina _compatible_ a secas.] si $U inter V = emptyset$ o bien si la función cambio de coordenadas restringida a $U inter V$ es un difeomorfismo.]

La compatibilidad requiere que la transición entre cartas no sea solo continua, sino también _suave_. El motivo de esta condición es asegurar que el concepto de _suavidad_ esté bien definido en toda la variedad $MM$, independientemente de qué carta se use: si una función es diferenciable vista a través de una carta, también lo será al analizarla desde cualquier carta compatible.

#defn([estructura diferenciable @munozEstimacionNoParametrica2011[Def. 3.1.3]])[
  Un atlas $cal(A) = {(U_alpha, phi_alpha) : alpha in cal(I)}$ es diferenciable si sus cartas son compatibles entre sí. Si un atlas diferenciable $cal(D)$ es _maximal_ lo llamaremos una _estructura diferenciable de la variedad $MM$ _. Con maximal queremos decir lo siguiente: si $(U, phi)$ es una carta de $MM$ que es compatible con todas las cartas de $cal(D)$, entonces $(U, phi) in cal(D)$ #footnote[Es decir, no existe otro atlas diferenciable que contenga propiamente a $cal(D)$, lo cual desambigua la referencia.].
]
#defn([variedad diferenciable @munozEstimacionNoParametrica2011[Def. 3.1.4]])[
  Una variedad diferenciable de dimensión $d$ es una terna $(MM, tau, cal(D))$ donde $(MM, tau)$ es una variedad topológica de dimensión $d$ y $cal(D)$ una estructura diferenciable.
]

Una variedad diferenciable es aquella en la que la operación de diferenciación tiene sentido no solo punto a punto, sino globalmente. De no poder diferenciar, tampoco podremos tomar integrales, y definir funciones de densidad --- ni hablar de estimarlas --- resulta imposible.

Sobre una variedad diferenciable, cobra sentido plantear el concepto de _métrica_. En particular, toda variedad diferenciable admite una "métrica de Riemann" @docarmoRiemannianGeometry1992[§1, Proposición 2.10].

#defn(["métrica riemanniana" @docarmoRiemannianGeometry1992[§1, Def. 2.1]])[
  Sea $T_p MM$ el _espacio tangente_ a un punto $p in MM$. Una métrica riemanniana --- o estructura riemanniana --- en una variedad diferenciable $MM$ es una correspondencia que asocia a cada punto $p in MM$ un producto interno $dotp(dot, dot)$ #footnote[Es decir, una forma bilineal simétrica definida positiva.] en el espacio tangente $T_p MM$ que "varía diferenciablemente" #footnote[Para el lector riguroso, el texto original define precisamente el sentido de esta expresión.] en el entorno de $p$.

  A dicho producto interno se lo denomina $g_p$ e induce naturalmente una norma: $norm(v)_p= sqrt(op(g_p)(v, v)) = sqrt(dotp(v, v))$. Decimos entonces que $g_p$ es una métrica riemanniana y el par $(MM, g)$ es una variedad de Riemann.
] <metrica-riemanniana>

#figure(image("/assets/fermat/img/Tangent_plane_to_sphere_with_vectors.svg", height: 12em), caption: flex-caption(
  [Espacio tangente  $T_p MM$ a una esfera $MM = S^2$ por $p$. Nótese que el espacio tangente varía con $p$, pero siempre mantiene la misma dimensión ($d=2$) que $MM$. Imagen: Mathwriter2718, #link("https://commons.wikimedia.org/wiki/File:Tangent_plane_to_sphere_with_vectors.svg")[Wikimedia Commons], CC0.],
  [Espacio tangente en $S^2$],
))

#obs(
  [según @docarmoRiemannianGeometry1992[§1.2 Prop. 2.10]],
)[
  *Toda variedad diferenciable admite una métrica riemanniana*, que se puede construir componiendo las métricas riemannianas locales a cada carta de su estructura diferenciable según la "partición de la unidad"
  #footnote[
    La definición formal de "partición de la unidad" se da sin prueba de existencia en @docarmoRiemannianGeometry1992[§0.5, p. 30]. A cada entorno $U_alpha$ de la cobertura de #MM se le asigna una función $f_alpha$ de manera que $sum_alpha f_alpha (p) = 1 forall p in MM$. Intuitivamente, da una base funcional de #MM, que al ser evaluadas en cualquier punto ponderan con pesos que suman 1 las métricas locales a cada carta para obtener un resultado global coherente.
  ]
  ${f_alpha : alpha in cal(I)}$ subordinada a su cobertura.

  Es claro que podemos definir una métrica riemanniana $dotp(dot, dot)^alpha$ en cada entorno $U_alpha$ de la cobertura: la métrica inducida por el sistema de coordenadas locales. Definiendo entonces
  $
    dotp(u, v)_p = sum_alpha f_alpha (p) dotp(u, v)_p^alpha quad forall p in MM, thick u,v in T_p MM,
  $
  es posible verificar que esta construcción define una métrica riemanniana en todo #MM.
]

#obs[ Cuando $MM=RR^d$, el espacio tangente es constante e idéntico a la propia variedad: $forall p in RR^d, thick T_p RR^d = RR^d$. La matriz identidad $bu(I)_d$, cuyas columnas forman la base canónica de $T_p RR^d = RR^d$, es definida positiva y da lugar al producto interno "clásico" $dotp(u, v) = u^T bu(I)_d v = sum_(i=1)^d u_i v_i$. $dotp(u, v)$ es una métrica riemanniana que induce la norma euclídea $norm(v) = sqrt(v^T v)$ y la distancia $d(x, y) = norm(x-y)$.]

= Geodésicas y mapa exponencial
Con las definiciones previas podemos definir algunos conceptos fundamentales como longitud, distancia y geodésica en variedades de Riemann.

#defn("longitud de una curva")[
  Sea $gamma : [a, b] -> MM$ una _curva diferenciable_ en #MM, y $gamma'$ su derivada. La _longitud_ de $gamma$ está dada por
  $
    L(gamma) = integral_a^b norm(gamma'(t)) dif t = integral_a^b sqrt(op(g_(gamma(t)))(gamma'(t), gamma'(t))) dif t.
  $] <longitud>

#defn("distancia en variedades de Riemann")[
  Sea $(MM, g)$ una variedad de Riemann, y $p, q in MM$ dos puntos. Definimos la distancia entre ellos inducida por la métrica $g$ como
  $
    dg(p, q) = inf_(gamma) thick {L(gamma) : thick thick gamma: [0, 1] -> MM, thick gamma(0)=p,thick gamma(1)=q}.
  $
]
Una _geodésica_ es una generalización de la línea recta de la geometría euclídea. Considérese la siguiente analogía #footnote[Este párrafo y el que sigue están adaptados de "El Flujo Geodésico" @docarmoRiemannianGeometry1992[§3.2].]: en la física clásica, un objeto que no está sujeto a ninguna fuerza (no recibe _aceleración_ alguna) estará o quieto (con velocidad nula) o en movimiento _rectilíneo_ uniforme ("MRU"). En variedades diferenciables, las geodésicas son exactamente eso: curvas sin aceleración, $gamma''(t) = 0 forall t$. Las geodésicas son localmente minimizantes de longitud: la curva $gamma$ que realiza la distancia $dg(p, q)$ es necesariamente una geodésica.

Sea $p in MM$ y $v in T_p MM$ un vector tangente en $p$, que interpretamos como una _velocidad inicial_: su dirección $v slash norm(v)$ indica hacia dónde ir, y su magnitud $norm(v)$, cuán rápido. Por existencia y unicidad de soluciones de ecuaciones diferenciales, existe una única geodésica $gamma$ con $gamma(0) = p$ y $gamma'(0) = v$. Como $gamma''(t) = 0 forall t$, la rapidez a lo largo de $gamma$ es constante: $norm(gamma'(t)) = norm(v) forall t$, de modo que $L(gamma) = integral_0^1 norm(gamma'(t)) dif t = norm(v)$. Tras una unidad de tiempo, la geodésica alcanza el punto $gamma(1) in MM$, habiendo recorrido una longitud $norm(v)$.

Esta relación, entre vectores de $T_p MM$ y geodésicas de $MM$ con origen en $p$, nos permite relacionar una "bola" en $T_p MM$ con su análogo en $MM$.

#defn("mapa exponencial")[
  Sean $p in MM, v in T_p MM$. Se conoce como _mapa exponencial_ a la función
  $ exp_p : T_p MM -> MM, quad exp_p (v) = gamma_(p,v)(1), $
  donde $gamma_(p,v)(t)$ es la única geodésica que en el instante $t=0$ pasa por $p$ con velocidad $v$.
]

#defn("bola normal")[
  Sea $B_epsilon (x) subset RR^d$ la bola cerrada de radio $epsilon$ centrada en $x$:
  $ B_epsilon (x) = {y in RR^d : dg(x, y) = norm(x - y) <= epsilon}. $
  Si $exp_p$ es un difeomorfismo  en un vecindario (entorno) $V$ del origen en $T_p MM$, su imagen $U = exp_p (V)$ es un "vecindario normal" de $p$.
  Si $B_epsilon (0)$ es tal que $overline(B_epsilon (0)) subset V$, llamamos a $exp_p B_epsilon (0) = B_epsilon (p)$ la _bola normal_ --- o "bola geodésica" --- con centro $p$ y radio $epsilon$.
]
La frontera de $B_epsilon (p)$ es una "subvariedad" de #MM ortogonal a las geodésicas que irradian desde $p$. Una concepción intuitiva de qué es una bola normal es "un entorno de $p$ en el que las geodésicas que pasan por $p$ son minimizadoras de distancias". El siguiente concepto es útil para entender "cuán lejos vale" la aproximación local a un espacio euclídeo en la variedad.

#defn(
  [radio de inyectividad #footnote[
      Basado en @munozEstimacionNoParametrica2011[Def. 3.3.16]. Una definición a mi entender más esclarecedora se encuentra en @docarmoRiemannianGeometry1992[§13.2, _The cut locus_], que introducimos aquí informalmente. Se le dice "punto de corte" de una geodésica al punto en que esta deja de ser minimizadora de distancia. El _cut locus_ o _ligne de partage_ $C_m (p)$ --- algo así como "línea de corte" --- de un punto $p$ es la variedad que resulta de la unión de los puntos de corte de todas las geodésicas que irradian de $p$. El ínfimo de la distancia entre $p$ y su _cut locus_ es el radio de inyectividad de #MM en $p$, de modo que podemos escribir $ "iny" MM = inf_(p in MM) d(p, C_m (p)), $
      donde la distancia de un punto a una variedad es el ínfimo de la distancia a todos los puntos de la variedad.]],
)[
  Sea $(MM, g)$ una $d$-variedad riemanniana. Llamamos "radio de inyectividad en $p$" a
  $
    "iny"_p MM = sup{s in RR_+ : B_s (p) " es una bola normal"}.
  $
  El ínfimo de los radios de inyectividad "puntuales" es el radio de inyectividad de la variedad #MM:
  $
    "iny"MM = inf_(p in MM) "iny"_p MM.
  $
]

#obs[Si $MM = RR^d$ con la métrica canónica entonces $"iny" MM = oo$. Si $MM = RR^d - {p}$, con la métrica usual, entonces existe un punto arbitrariamente cerca de $p$ en el que la geodésica que irradia en dirección a $p$ se corta inmediatamente e $"iny" MM = 0$. Si $MM = S^1$ con radio unitario y la métrica inducida de $RR^2$, el radio de inyectividad es $pi$, puesto que si tomamos "el polo norte" $p_N$ como origen de un espacio tangente $T_p_N S^1$, todas las geodésicas que salen de él llegan al polo sur $p_S$ "al mismo tiempo" $pi$, y perdemos la inyectividad.]

#figure(caption: flex-caption(
  [Espacio tangente y mapa exponencial para $p_N in S^1$. Nótese que $"iny" S^1 = pi$. Prolongando una geodésica  $gamma(t)$ más allá de $t = pi$, ya no se obtiene un camino mínimo, pues hubiese sido más corto llegar por $-gamma(s), thick s = t mod pi$.],
  [Espacio tangente y mapa exponencial para $p_N in S^1$],
))[#image("/assets/fermat/img/mapa-exponencial-s1.svg")]


Agregamos una última definición para restringir la clase de variedades de Riemann que nos interesará:

#defn(
  "punto límite",
)[Un punto $x$ es límite del conjunto $S$ si toda vecindad abierta de $x$ contiene puntos de $S$ distintos de $x$.]


#defn("variedad compacta")[
  Decimos que una variedad es _acotada_ cuando $sup_((p, q) in MM^2) dg(p, q) = overline(d) < oo$ --- es decir, no posee elementos distanciados infinitamente entre sí.
  Una variedad que incluya todos sus "puntos límite" es una variedad _cerrada_. Una variedad cerrada y acotada se denomina _compacta_.
]

#obs[
  Un círculo en el plano, $S^1 = {(x, y) in RR^2 : x^2 + y^2 = 1}$, es una variedad compacta: es acotada --- ninguna distancia es mayor a medio gran círculo, $pi$ --- y cerrada. $RR^2$ es una variedad cerrada pero no acotada. El "disco sin borde" ${(x, y) in RR^2 : x^2 + y^2 < 1}$ es acotado pero no cerrado --- pues no incluye su frontera $S^1$. El "cilindro infinito" ${(x, y, z) in RR^3 : x^2 + y^2 < 1}$ no es ni acotado ni cerrado.
]

Ahora sí, hemos arribado a un objeto lo suficientemente "bien portado" para soportar funciones diferenciables, una noción de distancia y todo aquello que precisamos para definir elementos aleatorios: la _variedad de Riemann compacta sin frontera_. Cuando hablemos de una variedad de Riemann sin calificarla, nos referiremos a esta.



#bibliography("/refs.bib", title: "Referencias")
