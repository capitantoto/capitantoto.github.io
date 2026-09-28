#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Distancias basadas en densidad y la distancia de Fermat",
  date: "2026-11-09",
  series: "fermat",
  part: 7,
  summary: [Por qué no alcanza con conocer la geometría, cómo se define una distancia que abarata los caminos por regiones densas, y qué garantiza la distancia de Fermat muestral.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)
#set math.equation(numbering: "(1)")

#callout(title: "En este post")[
  *¿Cómo medir distancias que respeten la densidad de los datos?* Conocer la geometría no alcanza: hay que abaratar los caminos por regiones densas y encarecer los que cruzan regiones vacías. Las _distancias basadas en densidad_ formalizan esa idea, y la distancia de Fermat es una familia de ellas para la que se conocen garantías de convergencia de la versión muestral: un camino mínimo en el grafo completo de la muestra, con aristas elevadas a una potencia $alpha$, que no requiere conocer ni la variedad ni su dimensión. Es la pieza con la que se construye la #parte("fermat-08-propuesta")[propuesta]. Nivel: técnico, con una demostración plegada que se puede saltear.
]


= Distancias basadas en densidad

Algoritmos como Isomap aprenden la _geometría_ de los datos, reemplazando la distancia euclídea ambiente por la distancia geodésica en el grafo pesado $bu(N N)_k$ #footnote[Donde el subíndice representa la cantidad de vecinos considerados --- o el diámetro $epsilon$ de la vecindad, de corresponder.], que con $N -> oo$ converge a la distancia $dg$ en $MM$. En estadística, conocer la geometría del soporte no es suficiente para tener un panorama completo. Por caso: sean $X'$ y $X^*$ dos elementos aleatorios soportados en la esfera $S^2$:
- $X'$ surgido de muestrear uniformemente "coordenadas polares" en el rectángulo $[0, pi] times [0, 2 pi]$ y proyectarlas a $S^2$, y
- $X^*$ surgido de muestrear uniformemente directamente en $S^2$.
Ambas distribuciones tienen la misma geometría, pero distintas densidades: $X'$ se concentra en los polos y es mínimamente densa en el ecuador; $X^*$ es efectivamente igual de densa en todo $S^2$.

Un ejemplo aún más concreto: sea $Omega$ la población de alumnos de nuestra facultad, y tomemos $X(omega) = (X_1(omega), X_2(omega))$ con
$
  X_1(omega) & = "edad de " omega \
  X_2(omega) & = "cantidad de cabellos de " omega.
$
Es cierto que $sop(X) subset RR^2$, pero resulta patente que la tasa de variación en ambas dimensiones _no es_ la misma: una decena de años es una diferencia de edad significativa, mientras que una decena de cabellos faltantes es invisible a cualquiera #footnote[Salvo, seguramente, a quien los haya perdido.].

Conocer la _densidad_ de los datos en la geometría es crucial para obtener una noción de distancia verdaderamente útil: de esta necesidad surge el estudio de las (métricas de) _distancia basadas en densidad_ o "DBD" #footnote[Del inglés _density-based distance metrics_.]: su premisa básica es computar la longitud de una curva $gamma$ integrando una función de costo inversamente proporcional a la densidad $f_X$ en #MM --- más "costosa" en regiones menos densas. Esta área del aprendizaje de distancias vio considerables avances durante el siglo XXI --- luego del éxito empírico de Isomap ---, y pavimentó el camino para técnicas de reducción de dimensionalidad basales en el "aprendizaje profundo" #footnote[O _deep learning_ en inglés. Llamamos genéricamente de tal modo a la plétora de arquitecturas de redes neuronales con múltiples capas que dominan hoy el procesamiento de información de alta dimensión @lecunDeepLearning2015.] como los "autocodificadores" #footnote[#emph[Autoencoders] en inglés, algoritmo que dada #XX, aprende un codificador $c(x): RR^D -> RR^d, d << D$ y un decodificador $delta(x) : RR^d -> RR^D$ tal que $delta(c(x)) approx x$. Mantenemos aquí la notación habitual de esta literatura, $D$ para la dimensión ambiente y $d$ para la del código, en lugar de $d$ y $d_MM$.
]. Yoshua Bengio --- uno de los "padres de la IA" cuyo trabajo ya mencionamos en esta monografía ---, menciona #link("https://www.reddit.com/r/MachineLearning/comments/mzjshl/d_who_first_advanced_the_manifold_hypothesis_to/", "en Reddit") cómo su grupo de investigación en la Universidad de Montreal trabajó en estas ideas: aprendizaje de variedades primero, y autocodificadores posteriormente.

#quote(attribution: "Y. Bengio")[
  El término hipótesis de la variedad es en efecto más antiguo que la revolución del aprendizaje profundo, aunque el concepto ya estaba presente en los primeros días de los autoencoders en los primeros años de los 90 (no bajo ese nombre, pero la misma idea) y los mapas autoorganizados en los 80, por no mencionar PCA aun antes (aunque eso estaba limitado a variedades lineales). Y el grupo a mi alrededor en la U. de Montreal en la década del 2000 y principios de la del 2010 trabajó bastante sobre el concepto, en el contexto de modelar distribuciones que se concentran cerca de un conjunto de menor dimensión (es decir, una variedad), por ejemplo, con _denoising auto-encoders_ (trabajo liderado por Pascal Vincent) y _contractive auto-encoders_ (liderado por Salah Rifai). También trabajamos en cómo la hipótesis de la variedad impactaba los modelos generativos y la dificultad de muestrear (y cómo muestrear) cuando hay múltiples variedades alejadas entre sí (el "problema de mezclado" en MCMC #footnote["Métodos de Montecarlo basados en cadenas de Markov", por sus siglas en inglés.]).
]
Aprender una DBD nos permite saltearnos el problema ya harto descrito de aprender la variedad desconocida #MM, e ir directamente a lo único estrictamente necesario para tener un algoritmo de clasificación funcional: una noción de distancia adecuada.

#cite(<vincentDensitySensitiveMetrics2003>, form: "prose") proveen una de las primeras heurísticas para una DBD: al igual que Isomap, toman las distancias de caminos mínimos pesados en un grafo con vértices #XX, pero
- consideran el grafo completo $bu(C)$ en lugar del de $k$-vecinos $bu(N N)_k$ y
- pesan las aristas del grafo por la distancia euclídea en el espacio ambiente entre sus extremos _elevada al cuadrado_.

Esta noción de "distancia de arista-al-cuadrado" #footnote[_Edge-squared distance_ en el original.] tiene el efecto de desalentar grandes saltos entre observaciones lejanas, que es una manera  de "asignar un costo alto a trayectos por regiones de baja densidad", por lo cual ya califica como una DBD  rudimentaria.

#figure(image("/assets/fermat/img/distancia-cuadrada.svg", height: 16em), caption: flex-caption(
  [En este grafo geométrico representando un triángulo isósceles, hay solo dos caminos entre $a$ y $c$: $zeta = a -> b -> c$, y $gamma = a -> c$],
  [Grafo geométrico de triángulo isósceles.],
)) <grafo-completo-3-vertices>

Consideremos el grafo geométrico de @grafo-completo-3-vertices. Con la norma euclídea, las longitudes definidas en la #parte("fermat-04-variedades-de-riemann")[definición de longitud de una curva] son $ L(gamma) = 3 < 4 = 2 + 2 = L(zeta), $ de modo que $d(a, c) = 3$ con geodésica $gamma$. Con la distancia de arista-al-cuadrado, $ L(zeta) = 2^2 + 2^2 = 8 < 3^2 = L(gamma), $ y por lo tanto $d(a, c) = 8$ con geodésica $zeta$. La distancia de arista-al-cuadrado cambia las geodésicas como también la escala en que se miden las distancias.


En las dos últimas décadas han surgido numerosos algoritmos para calcular DBD y hasta algunos _surveys_ comparando las bondades relativas de cada una. #cite(<caytonAlgorithmsManifoldLearning2005>, form: "prose") provee un resumen de los algoritmos de aprendizaje de variedades más relevantes hasta entonces. En sus reflexiones finales #footnote[ #cite(<caytonAlgorithmsManifoldLearning2005>, form: "prose"), §5 "¿Qué queda por hacer?", cuya lectura recomendamos.], el autor considera que es tan amplio el espectro de variedades subyacentes y de representaciones "útiles" que se pueden concebir, que (a) en el plano teórico resulta muy difícil obtener garantías de eficiencia y rendimiento #footnote[Adoptamos "rendimiento" como traducción del inglés _performance_, anglicismo de uso extendido aun en el habla hispana.], y (b) en el plano experimental, quedamos reducidos a elegir un conjunto representativo de variedades y observar si los resultados obtenidos son "intuitivamente agradables". Más aún, las evaluaciones experimentales requieren _conocer_ la variedad subyacente para luego evaluar si el algoritmo de aprendizaje preserva información útil. Determinar si un dataset del mundo real efectivamente yace sobre cierta variedad es tan difícil como aprenderla; usar datos artificiales puede no rendir resultados realistas. Veintiún años más tarde, en esta monografía nos topamos con las mismas dificultades de antaño.

A nuestro entender, #cite(<bijralSemisupervisedLearningDensity2011>, form: "prose") ofrecen una de las primeras formalizaciones de qué constituye una DBD. Para abordarla, revisaremos una definición previa. #parte("fermat-04-variedades-de-riemann")[En la cuarta parte] definimos la longitud de una curva $gamma$ parametrizada y diferenciable sobre una variedad de Riemann compacta y sin frontera $(MM, g)$.

#defn(
  "curva rectificable",
)[Una _curva rectificable_ es una curva que tiene longitud finita. Más formalmente, sea $gamma: [a,b] -> MM$ una curva parametrizada. La curva es rectificable si su longitud de arco es finita:

  $ L(gamma) = sup sum_(i=1)^n dg(gamma(t_i), gamma(t_(i-1))) < infinity, $

  donde el supremo se toma sobre todas las particiones posibles $a = t_0 < t_1 < dots < t_n = b$ del intervalo $[a,b]$.

  Equivalentemente, si $gamma$ es diferenciable por tramos, entonces es rectificable si y solo si:

  $ L(gamma) = integral_a^b norm(gamma'(t)) dif t < infinity. $
]

Las curvas rectificables son importantes porque permiten definir conceptos como la longitud de arco y la parametrización por longitud de arco, que son fundamentales en geometría diferencial y análisis. En particular, sea $gamma: [a,b] -> RR^d$ una curva rectificable parametrizada y diferenciable por tramos y $f: RR^d -> RR$ una función diferenciable. La "integral de línea" #footnote[_Line integral_ en inglés.] de $f$ sobre $gamma$ se define como:

$ integral_gamma f dif s = integral_a^b f(gamma(t)) norm(gamma'(t)) dif t, $

donde $dif s$ representa el elemento de longitud de arco.

Si $gamma$ tiene longitud finita y $f$ es continua --- como en nuestro caso de uso ---, el resultado de la integral *existe y es independiente de la parametrización*.

Sea entonces $X ~ f, thick f : MM -> RR_+$ un elemento aleatorio distribuido según $f$ sobre una variedad de Riemann compacta y sin frontera --- potencialmente desconocida --- #MM. Sea además $g(t) : RR_+ -> RR$ una función _monótona decreciente_ en su parámetro. Consideraremos el "costo" $J_f$ de un camino $gamma : [0, 1] -> MM, gamma(0)=a, gamma(1)=b$ entre $a, b$ como la integral de $g compose f$ a lo largo de $gamma$:

$
  op(J_(g compose f))(gamma) = integral_0^1 op(g) lr(( f(gamma(t)) ), size: #140%) norm(gamma'(t))_p dif t.
$

Y la distancia basada en la densidad $f$ pesada por $g$ entre dos puntos cualesquiera $a, b in MM$ como

$
  D_(g compose f) (a, b) = inf_gamma op(J_(g compose f))(gamma),
$
donde el ínfimo se toma respecto al conjunto de todos los senderos rectificables con extremos en $a, b$, y $norm(dot)_p$ es la $p$-norma o distancia de Minkowski con parámetro $p$.


#defn([norma $p$])[
  Sea $p >= 1$. Para $x, y in RR^d$, la norma $ell_p$ #footnote[También conocida como "$p$-norma" o "distancia de Minkowski".] se define como:

  $
    norm(x)_p = (sum_(i=1)^d abs(x_i)^p)^(1/p).
  $
]
#obs[Cada $p$-norma induce su propia distancia $d_p$. Algunas son muy conocidas:
  - $p=1$ da la distancia "taxi" o "de Manhattan" #footnote[Llamada así porque representa la distancia que recorrería un taxi en una grilla urbana. Una traducción localizada razonable sería "distancia de San Telmo".]:
  $ d_1(x, y) = norm(x - y)_1 = sum_(i=1)^d abs(x_i - y_i) thin , $
  - $p=2$ da la distancia euclídea que ya hemos usado, omitiendo el subíndice $2$:
  $ d_2(x, y) = norm(x - y) = sqrt(sum_(i=1)^d (x_i-y_i)^2) thin , $
  - $p -> oo$ da la distancia de Chebyshev:
  $ d_oo (x, y) = norm(x - y)_oo = max_(1 <= i <= d) abs(x_i - y_i). $
] <lp-metric>

#obs[Tomando $g(t) = 1$ y $p=2$ en $J_(g compose f)$ recuperamos la #parte("fermat-04-variedades-de-riemann")[definición de longitud de una curva]. Como $g(t) = 1$ es constante, la longitud es insensible a la densidad.]

¿Es posible estimar $D_(g compose f)$ de manera consistente? Intuitivamente, consideremos dos puntos $a, b in U subset MM, thick dim MM = d$ #footnote[Reemplazamos la notación habitual de $p, q in MM$ por $a, b in MM$ y $d_MM$ por $d$ siguiendo a #cite(<bijralSemisupervisedLearningDensity2011>, form: "prose", supplement: [§3]), para evitar confusiones.] en un vecindario $U$ de $a$ lo "suficientemente pequeño" como para que $f$ sea esencialmente uniforme en él, y en particular en el segmento $gamma_(a b) = overline(a b)$ y tomemos $g = 1 slash f^r$:

$J_(r)(gamma_(a b)) = D_r (a, b) & approx g lr((f("alrededor de " a " y " b)), size: #140%) norm(b - a)_p \
& prop g(norm(b -a)_p^(-d)) norm(b-a)_p \
& = norm(b -a)_p^(r d + 1) = norm(b-a)_p^q thin,$

donde $q = r times d+1$.

Nótese que como ya mencionamos, tomar $q=1$ (o $r = 0$) devuelve la distancia de Minkowski.

Sea $Pi = (pi_0, pi_1, dots, pi_m)$ una serie de índices identificando $m + 1$ observaciones de $XX$. Luego, el costo de un paseo de $m$ pasos por el grafo completo de #XX, $x_(pi_0)-> x_(pi_1) -> dots -> x_(pi_m)$, se puede computar con una simple suma:
$
  J_r (x_(pi_0)-> dots -> x_(pi_m)) & = sum_(j=1)^m D_r (x_(pi_(j-1)), x_(pi_(j))) \
                                    & prop sum_(j=1)^m norm(x_(pi_(j)) - x_(pi_(j-1)))_p^q.
$

Si #XX es una muestra "suficientemente densa", los saltos entre nodos de índices consecutivos serán "cortos" y podemos estimar las distancias geodésicas $D_r$ como los "caminos mínimos" en el grafo completo de $XX$ con aristas pesadas por $norm(b - a)_p^q, thick a, b in XX$.

Esta estimación es particularmente atractiva, en tanto no depende para nada de la dimensión ambiente, y solo depende de la dimensión intrínseca $d$ de #MM a través de $q=r d+1$. De hecho, los autores mencionan que "casi cualquier par de valores $(p, q)$ funciona", y en particular encuentran que en sus experimentos, $p=2, q=8$ "anda bien en general" @bijralSemisupervisedLearningDensity2011[§5.1] #footnote[Tendremos más para decir al respecto en los resultados, en particular en la #parte("fermat-11-de-donde-sale-la-ventaja")[parte 11].].


Un resultado interesante por lo exacto aparece en #cite(<chuExactComputationManifold2019>, form: "prose"). Dado un conjunto de puntos $P = {p_i : p_i in MM, i in [N]}$, considérese la "métrica de vecino más cercano"

$ r_P (q) = 4 min_(p in P) norm(q - p) thin , $

donde $P subset MM$ es un _subconjunto_ de la variedad #footnote[A nuestros fines, $P = XX$, pero no tiene por qué serlo: el argumento de Chu et al. admite cualquier conjunto _finito_ $P$, cuyos elementos pueden ser regiones no convexas de $MM$.] que da lugar a la función de costo

$ J_(r_P) (gamma) = integral_0^1 r_P (gamma(t)) norm(gamma'(t)) dif t thin , $

que a su vez define la distancia

$
  D_(r_P) (p, q) = inf_gamma J_(r_P) (gamma) thin ,
$
que los autores llaman "distancia de vecino más cercano", $d_bu(N) = D_(r_P)$.

Considérese además la distancia de arista-al-cuadrado #footnote[Cuando $P = XX$, esta es la misma que #cite(<vincentDensitySensitiveMetrics2003>, form: "prose") propusieron dieciséis años antes.]:
$
  d_bu(2)(a, b) = inf_((p_0, dots, p_m)) sum_(i=1)^m norm(p_i - p_(i-1))^2,
$
donde el ínfimo se toma sobre toda posible secuencia de puntos $p_0, dots, p_m in P, p_0 = a, p_m = b$. Resulta entonces que la distancia de vecino más cercano $d_bu(N)$ y la métrica de arista cuadrada $d_bu(2)$ son equivalentes para todo conjunto de puntos $P$ en dimensión arbitraria @chuExactComputationManifold2019[Teorema 1.1] #footnote[La prueba que ofrecen es más general: los elementos de $P$ pueden ser conjuntos compactos con costo cero al atravesarlos y el resultado se sostiene @chuExactComputationManifold2019[Figura 2].].

Probar la equivalencia para el caso trivial con $P = {a, b} subset RR^(d_MM)$ se convierte en un ejercicio de análisis muy sencillo, que cimenta la intuición y explica el factor de $4$ en $r_P$:

#plegable[La demostración para $P = {a, b}$][
#figure(
  image("/assets/fermat/img/equivalencia-d2-dN.svg"),
  caption: flex-caption(
    [Ejemplo trivial de la equivalencia $d_bu(N) equiv d_bu(2)$ para $P = {a, b}$],
    [Ejemplo de la equivalencia $d_bu(N) equiv d_bu(2)$],
  ),
) <equiv-d2-dn>

Con solo dos nodos, la geodésica de $a$ a $b$ es simplemente $a -> b$ --- cualquier otro camino repite nodos y se alarga innecesariamente ---, así que $d_bu(2)(a, b) = norm(b - a)^2$. Ahora, $d_bu(N)(a, b)$ requiere encontrar el mínimo entre todos los caminos posibles, aunque no viajen sobre las aristas del grafo. En la región azul, $r_{a,b} (q) = 4 norm(q - a)$ solo depende de la distancia a $a$, y todo camino desde $a$ hasta la mediatriz debe recorrer al menos $norm(b - a) slash 2$ de esa distancia: el más barato es el segmento recto hasta el punto medio. Análogamente en la región naranja $r_{a,b} (q) = 4 norm(q - b)$. Como todo camino de $a$ a $b$ cruza la mediatriz, el de menor costo es $overline(a b)$. Parametricémoslo:
$
  gamma & : [0, 1] -> RR^(d_MM), quad
             gamma(t) = a + (b - a) t, quad
             gamma'(t) = b - a,
$
$
  d_bu(N)(a, b) & = D_(r_{a, b}) (a, b) = inf_gamma J_(r_{a, b}) (gamma) = J_(r_{a, b}) (overline(a b)) \
  &= integral_0^1 r_{a, b} (gamma(t)) times norm(gamma'(t)) dif t \
  &= integral_0^1 4 min_(p in {a, b}) norm((a + (b -a)t) - p) norm(b-a) dif t \
  &= 4 norm(b-a) (integral_0^(1/2) norm(a + (b -a)t - a) dif t + integral_(1/2)^1 norm(a + (b -a)t - b) dif t )\
  &= 4 norm(b-a) (integral_0^(1/2) norm((b -a)t) dif t + integral_(1/2)^1 norm((a-b)(1-t)) dif t )\
  &= 4 norm(b-a)^2 (integral_0^(1/2) t dif t + integral_(1/2)^1 (1-t) dif t ) \
  &= 4 norm(b-a)^2 [( t^2 slash 2 |^(1 slash 2)_0) + (t - t^2 slash 2 |^1_(1 slash 2))] \
  &= 4 norm(b-a)^2 (1/8 + 1/8) \
  & = norm(b-a)^2 \
  & = d_bu(2)(a, b) quad square
$
]

El grueso del trabajo de Chu et al. consiste en una prueba general de esta igualdad, que se desarrolla en tres partes:
1. Para toda colección finita de puntos $P = {p_i : p_i in RR^(d_MM)}$,

  1.a. $d_bu(N) <= d_bu(2)$

  1.b. $d_bu(N) >= d_bu(2)$
2. (1) también es válido para toda colección de compactos $P$ de $RR^(d_MM)$.

Una utilidad de este resultado es que permite calcular con precisión para qué valores de $k$ estimar $d_bu(N)$ sobre el grafo pesado por aristas cuadradas $bu(N N)_k (XX)$  es un "suficientemente buen reemplazo" del cálculo equivalente --- pero mucho más costoso --- sobre el grafo completo  $bu(C)(XX)$. En su Teorema 1.3, los autores observan que con tomar $k = O(2^(d_MM) ln N)$ basta.

Lo que Chu et al. llaman $d_bu(2)$ y ya introdujimos como "distancia de arista-al-cuadrado" @chuExactComputationManifold2019 @vincentDensitySensitiveMetrics2003, es la misma distancia $D_r$ que #cite(<bijralSemisupervisedLearningDensity2011>, form: "prose") consideran con $p = 2$ (norma euclídea) y $r = 1/d$ --- de modo que $q=r d+1=2$.

= Distancia de Fermat

No conocemos pruebas de equivalencia entre la familia de distancias $D_r$ de #cite(<bijralSemisupervisedLearningDensity2011>, form: "prose") y sus respectivas aproximaciones a través de geodésicas en el grafo completo para valores arbitrarios de $p$ y $q = r d + 1$ como la que acabamos de enunciar entre $d_bu(N)$ y $d_bu(2)$, ni se desprende de la prueba mencionada que deban de existir. Sin embargo, sí existe en la literatura una familia de DBD para la cual se conocen tasas de convergencia asintótica de la aproximación muestral en el grafo completo a la distancia propiamente dicha, sobre una variedad riemanniana compacta sin frontera --- la familia de _Distancia(s) de Fermat_.

#cite(<groismanNonhomogeneousEuclideanFirstpassage2022>, form: "prose") considera la misma familia de distancias basadas en funciones monótonamente decrecientes de la densidad que @bijralSemisupervisedLearningDensity2011, $g = 1 / f^r$, salvo que sus autores fijan $p$ y las parametrizan según
$
  p = 2; quad q = alpha; quad r = beta = (alpha - 1) / d_MM.
$

Los autores no se limitan a sugerir que la distancia en el espacio ambiente se puede aproximar a través de la distancia basada en el grafo completo con aristas pesadas, sino que precisan en qué sentido la una converge a la otra, y a qué tasa.#footnote[Con respecto a fijar $p=2$, en la "Observación 2.6" los autores mencionan que es posible y hasta sería interesante reemplazar la norma euclídea o "$2$-norma" por otra distancia --- p. ej., otra $p$-norma ---, reemplazando las integrales con respecto a la longitud de arco, por integrales con respecto a la distancia involucrada. Entendemos de ello que no es una condición _necesaria_ para el desarrollo del trabajo, sino solo _conveniente_. Omitiremos el subíndice en la $2$-norma de aquí en más.]

#defn([Distancia "macroscópica" de Fermat @groismanNonhomogeneousEuclideanFirstpassage2022[Definición 2.2]])[

  Sea $f$ una función continua y positiva, $beta >=0$
  y $x, y in S subset.eq RR^d$. Definimos la _Distancia de Fermat_ $cal(D)_(f, beta)(x, y)$ como:

  $
    cal(T)_(f, beta)(gamma) = integral_gamma f^(-beta) dif s, quad cal(D)_(f, beta)(x, y) = inf_gamma cal(T)_(f, beta)(gamma) thin ,
  $

  donde el ínfimo se toma sobre el conjunto de todos los "senderos" o curvas rectificables entre $x$ e $y$ contenidos en $overline(S)$ --- la clausura de $S$ ---, y la integral se entiende con respecto a la longitud de arco $dif s$ dada por la distancia euclídea. Omitiremos la dependencia en $beta$ y $f$ cuando no sea estrictamente necesaria. #footnote[
    En palabras de los autores, el nombre deriva de que "esta definición coincide con el Principio de Fermat en óptica para determinar el sendero recorrido por un haz de luz en un medio no homogéneo cuando el índice de refracción está dado por $f^(-beta)$".
  ]
]

Este objeto "macroscópico" se puede aproximar a partir de una versión "microscópica" del mismo, que en el límite converge a $cal(D)_(f, beta)$:

#let sfd = $D_(Q, alpha)$

#defn([Distancia muestral o "microscópica" de Fermat])[

  Sea $Q$ un conjunto no vacío, _localmente finito_ #footnote[Es decir, que para todo compacto $U subset RR^d$, la cardinalidad de $Q inter U$ es finita, $abs(Q inter U) < oo$.] de $RR^d$. Para $alpha >=1$ y $x, y in RR^d$, la _Distancia Muestral de Fermat_ se define como


  $
    sfd (x, y) = inf { & sum_(j=1)^(m-1) norm(q_(j+1) - q_j)^alpha : (q_1, dots, q_m) \
                       & "es un camino de "x" a "y, m>=1},
  $

  donde los $q_j in Q thin forall j in [m]$. Nótese que #sfd satisface la desigualdad triangular, define una métrica sobre $Q$ y una pseudométrica #footnote[Una métrica tal que la distancia puede ser nula entre puntos no idénticos: $ exists a != b : d(a, b) = 0. $] sobre $RR^d$.
] <sample-fermat-distance>

Antes de presentar en qué sentido  #sfd converge a $cal(D)_(f, beta)$, una definición más:
#defn([variedad isométrica])[
  Diremos que #MM es una variedad $d_MM$-dimensional $C^1$ _isométrica_ embebida en $RR^d$ si existe un conjunto abierto y conexo $S subset RR^d$ y $phi : S -> RR^d$ una transformación isométrica #footnote[Que preserva las métricas o distancias; del griego "isos" (igual) y "metron" (medida).] tal que $phi(overline(S)) = MM$. Como se mencionó con anterioridad, se espera que $d_MM << d$, pero no es necesario.
]

#thm([Convergencia de $D_(Q, alpha)$, @groismanNonhomogeneousEuclideanFirstpassage2022[Teorema 2.7]])[

  Asuma que #MM es una variedad $C^1$ $d_MM$-dimensional isométrica embebida en $RR^d$ y $f: MM -> RR_+$ es una función de densidad de probabilidad continua. Sea $Q_n = {q_1, dots, q_n}$ un conjunto de elementos aleatorios independientes con densidad común $f$. Entonces, para $alpha > 1$ y $x,y in MM$ tenemos:

  $ lim_(n->oo) n^beta D_(Q_n,alpha)(x,y) = mu cal(D)_(f,beta)(x,y) " casi seguramente", $

  donde $mu$ es una constante que depende únicamente de $alpha$ y $d_MM$.
] <convergencia-sfd>

#obs[
  El factor de escala $beta = (alpha-1) slash d_MM$ depende de la dimensión intrínseca $d_MM$ de la variedad, y no de la dimensión $d$ del espacio ambiente.
]

La distancia muestral de Fermat $D_(Q, alpha)$ se puede aproximar a partir de una muestra "lo suficientemente grande" sin conocer ni la variedad #MM ni su dimensión intrínseca. Además, tiene garantías de convergencia a una distancia basada en densidad (DBD) --- la distancia de Fermat "macroscópica" $cal(D)_(f, beta)$ --- para todo $beta$. Hemos encontrado un candidato para la pieza faltante de nuestro clasificador en variedades desconocidas, y estamos finalmente en condiciones de proponer un algoritmo de clasificación que reúna todos los cabos del tejido teórico hasta aquí desplegado.

Trabajos contemporáneos a Groisman et al. @littleBalancingGeometryDensity2022 @mckenziePowerWeightedShortest2019 analizan lo que ellos llaman "distancias de caminos mínimos pesadas por potencias" #footnote[_Power-weighted shortest-path distances_, o PWSPD por sus siglas en inglés.], aplicándolas no a problemas de clasificación, sino de _clustering_ #footnote[Es decir, de identificación de grupos en datos no etiquetados.]. Las definiciones de ambos grupos son muy similares en espíritu, con una diferencia: la distancia microscópica que plantean Little et al. no es la suma de las aristas pesadas por $q=alpha$ como en Bijral et al. y Groisman et al., sino la raíz $alpha$-ésima de tal suma, en una especie de reversión de la distancia de Minkowski. Siendo la sustancia de estos trabajos muy similar a la de la distancia de Fermat pero aplicada a otro problema, no profundizaremos en ellos.



#bibliography("/refs.bib", title: "Referencias")
