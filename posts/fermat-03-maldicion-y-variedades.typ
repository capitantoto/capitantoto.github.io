#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "La maldición de la dimensionalidad y la hipótesis de la variedad",
  date: "2026-10-12",
  series: "fermat",
  part: 3,
  summary: [Por qué estimar densidades se vuelve imposible en alta dimensión, y por qué aun así el aprendizaje automático funciona: los datos parecen vivir en variedades de mucha menor dimensión que el espacio donde se registran.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)
#set math.equation(numbering: "(1)")

#callout(title: "En este post")[
  *¿Por qué clasificar en alta dimensión es tan difícil, y por qué aun así funciona?* En 20 dimensiones, una "cajita" con la mitad del ancho de otra contiene menos de una millonésima de su volumen: el espacio está vacío, y los estimadores de densidad se quedan sin datos. La salida que explora la tesis es la _hipótesis de la variedad_: los datos reales se concentrarían en una variedad de mucha menor dimensión que el espacio en que se registran. La cuenta que justifica la "cajita" está plegada; se puede saltear.
]


En la #parte("fermat-02-clasificar-con-densidades")[segunda parte] estimamos densidades de una variable $X in RR$. ¿Qué pasa cuando $X$ tiene muchas componentes?

= Naive Bayes
Una manera "ingenua" de adaptar el procedimiento de estimación de densidad ya mencionado a $X$ multivariadas consiste en sostener el falso-pero-útil supuesto de que sus componentes $X_1, dots, X_d$ son independientes entre sí. De este modo, la estimación de densidad conjunta se reduce a la estimación de $d$ densidades marginales univariadas. Dada cierta clase $j$ #footnote[Donde el entero $j in [K]$ es la etiqueta de la clase $GG_j$.], podemos escribir la densidad condicional $X|j$ como
$
  f_j (X) = product_(k = 1)^d f_(j k) (X_k),
$ <naive-bayes>

donde $f_(j k)$ es la densidad de $X_k$ condicional a la clase $GG_j$. Este procedimiento se conoce como "Naive Bayes" @hastieElementsStatisticalLearning2009[§6.6.3], y a pesar de su aparente ingenuidad es competitivo contra algoritmos mucho más sofisticados en un amplio rango de tareas. En términos de cómputo, permite resolver la estimación con $K times d$ KDE univariados. Además, permite que en $X$ se combinen variables cuantitativas y cualitativas: basta con reemplazar la estimación de densidad para las componentes $X_k$ cualitativas por su correspondiente histograma.

= KDE multivariado
Consideremos un dataset compuesto por observaciones muestreadas de dos círculos concéntricos con algo de ruido:
#figure(
  caption: flex-caption(
    "Dos círculos concéntricos y sus KDE marginales por clase: a pesar de que la frontera entre ambos grupos de puntos es muy clara, es casi imposible distinguirlas a partir de sus densidades marginales.",
    "Dos círculos concéntricos",
  ),
  image("/assets/fermat/img/dos-circulos-jointplot.svg", width: 75%),
)


En casos así, el procedimiento de Naive Bayes falla por completo, y será necesario adaptar el procedimiento de KDE unidimensional a $d >= 2$ sin basarnos en el supuesto de independencia de las $X_1, dots, X_d$. A lo largo de las cuatro décadas posteriores a las publicaciones de Parzen y Rosenblatt, el estudio de los estimadores de densidad por núcleos avanzó considerablemente, de manera que ya para mediados de los \'90 existían minuciosos libros de referencia como "Kernel Smoothing" @wandKernelSmoothing1995, que seguiremos en la presente sección.

#defn([KDE multivariada, @wandKernelSmoothing1995[§4]])[
  En su forma más general, el estimador de densidad por núcleos #box[$d$-variado] es

  $
    hat(f) (x; HH) = N^(-1) sum_(i=1)^N KH (x - x_i),
  $

  donde
  - $HH in RR^(d times d)$ es una matriz simétrica definida positiva análoga a la ventana $h in RR$ para $d=1$,
  - $KH(t) = abs(det HH)^(-1/2) K(HH^(-1/2) t)$ y
  - $K$ es una función núcleo $d$-variada tal que $integral_(RR^d) K(x) dif x = 1$.
] <kde-mv>

Típicamente, $K$ es la densidad normal multivariada estándar
$
  phi.alt : RR^d -> RR, quad phi.alt(x) = (2 pi)^(-d/2) exp(- norm(x)^2 / 2).
$

= La elección de $HH$
Sean las siguientes clases de matrices de $RR^(d times d)$:
- $cal(F)$, de matrices simétricas definidas positivas,
- $cal(D)$, de matrices diagonales definidas positivas ($cal(D) subset.eq cal(F)$) y
- $cal(S)$, de múltiplos escalares de la identidad: $cal(S) = {h^2 bu(I):h >0} subset.eq cal(D)$.

Aun tomando una única $HH$ para _toda_ la muestra, la elección de $HH$ en $d$ dimensiones requiere ajustar
- $binom(d + 1, 2) = (d^2 + d) slash 2$ parámetros si $HH in cal(F)$,
- $d$ parámetros si $HH in cal(D)$ y
- un único parámetro $h$ si $HH = h^2 bu(I)$.

La evaluación de la conveniencia relativa de cada parametrización se vuelve muy compleja, muy rápido. #cite(<wandComparisonSmoothingParameterizations1993>, form: "prose") proveen un análisis detallado para el caso $d = 2$, y concluyen que aunque cada caso amerita su propio estudio, $HH in cal(D)$ suele ser un compromiso "adecuado" entre la complejidad de tomar $HH in cal(F)$ y la rigidez de $HH in cal(S)$. Sin embargo, este no es un gran consuelo para valores de $d$ verdaderamente altos, en cuyo caso existe aún un problema más fundamental.

= La maldición de la dimensionalidad

Uno estaría perdonado por suponer que el problema de estimar densidades en alta dimensión se resuelve con una buena elección de $HH$, y una muestra "lo suficientemente grande". Considérese, sin embargo, el siguiente ejercicio ilustrativo de cuánto es "suficientemente grande":

#quote(attribution: [adaptado de @wandKernelSmoothing1995[§4.9, ej. 4.1]])[
  Sean $X_i tilde.op^("iid")"Uniforme"([-1, 1]^d), thick i in [N]$, y consideremos la estimación de la densidad en el origen, $hat(f)(bu(0))$. Suponga que el núcleo $K_(HH)$ es un "núcleo producto" basado en la distribución univariada $"Uniforme"(-1, 1)$, y $HH = h^2 bu(I)$. Derive una expresión para la proporción esperada de puntos incluidos dentro del soporte del núcleo $KH$ para $(h, d)$ arbitrarios.
]

#plegable[La cuenta: qué proporción de la muestra cae dentro del núcleo][
El "núcleo producto" $d$-variado basado en cierta ley univariada no es más que el producto de $d$ densidades univariadas como aquella. Para la  $"Uniforme"(-1, 1)$ el núcleo evaluado en el origen $x_0 = 0$ es:
$
  K(x - x_0) & = K(x) = product_(i = 1)^d 1/2 ind(-1 <= x_i <= 1) \
             & = 2^(-d) ind(inter.big_(i=1)^d thick abs(x_i) <= 1).
$
De la #link(<kde-mv>)[definición de KDE multivariada] y el hecho de que $det HH = h^(2d); thick HH^(-1/2) = h^(-1) bu(I)$, se sigue que
$
  KH(x) & = abs(h^(2d))^(-1/2) K(h^(-1)bu(I) x) = h^(-d) K(x/h) \
        & = (2h)^(-d) ind(inter.big_(i=1)^d thick abs(x_i / h) <= 1) = (2h)^(-d) ind(inter_(i=1)^d thick abs(x_i) <= h) \
        & = (2h)^(-d) ind(x in [-h, h]^d).
$
De modo que $sop KH = [-h, h]^d$. Como la distribución de las $X_i$ es _uniforme_ en su dominio, su densidad es constante y la proporción esperada de puntos es una simple proporción:
$
  Pr(X in [-h, h]^d) & = "Vol"(sop K_HH) / "Vol"([-1,1]^d) \
                     & = (h - (-h))^d/(1-(-1))^d = h^d quad square
$
]

#let h = 0.5
#let d = 20

Para $h =#h, d=#d, thick Pr(X in [-#h,#h]^#d) = #h^(#d) approx #calc.round(calc.pow(h, d), digits: 8)$, ¡menos de uno en un millón! Dicho de otra forma: en 20 dimensiones, una "cajita" con la mitad del ancho de otra contiene menos de una millonésima de su volumen. Aun para $h approx 1$, en verdaderamente altas dimensiones el fenómeno es dramático. Represente $X$ un segundo de audio, muestreado respetando el estándar _mínimo_ para llamadas telefónicas  #footnote[De Wikipedia: la tasa #link("https://en.wikipedia.org/wiki/Digital_Signal_0")[DS0], o _Digital Signal 0_, fue introducida para transportar una sola llamada de voz "digitizada". La típica llamada de audio se digitiza a $8 "kHz"$, o a razón de 8.000 veces por segundo.], tal que $d=8000$. En tal espacio ambiente, aun con $h=0.999$, $Pr(dot) approx #calc.round(calc.pow(0.999, 8000), digits: 6)$, o 1:3.000.

#figure(
  caption: flex-caption(
    [Proporción de $X_i tilde.op^("iid")"Uniforme"([-1, 1]^d)$ dentro de un $d$-cubo de lado $h$ para valores seleccionados de $h$.],
    [Proporción de $X$ dentro de un $d$-cubo de lado $h$],
  ),
  image("/assets/fermat/img/curse-dim.svg"),
)
= La hipótesis de la variedad (_manifold hypothesis_)

Ahora, si el espacio está _tan_, pero _tan_ vacío en alta dimensión, ¿cómo es que el aprendizaje supervisado _sirve de algo_? La reciente explosión en capacidades y herramientas de procesamiento (¡y generación!) de formatos de altísima dimensión #footnote[Audio, video, texto y datos genómicos, por citar solo algunos.] pareciera ser prueba fehaciente de que la tan mentada _maldición de la dimensionalidad_ no es más que una fábula para asustar estudiantes de estadística.

Pues bien, el ejemplo de un segundo de audio antedicho _es_ sesgado: no es cierto que si $X$ representa un segundo de voz humana digitizada, su ley sea uniforme en 8000 dimensiones #footnote[El audio se digitiza usando 8 bits para cada muestra, así que más precisamente, si $B = [2^8] = {1, dots, 256}$, $sop X = B^8000$ y $abs(B^8000) = 2^64000$, o $64 "kbps"$, kilobits por segundo.]. Un segundo de audio generado siguiendo cualquier distribución en la que muestras consecutivas no tengan ninguna correlación da por resultado #link("https://es.wikipedia.org/wiki/Ruido_blanco")[_ruido blanco_]. La voz humana tiene _estructura_, y por ende correlación instante a instante. Cada voz tiene un _timbre_ característico, y las posibles palabras a enunciar están ceñidas por la _estructura fonológica_ de la lengua locutada.

Sin precisar detalles, podríamos postular que las realizaciones de la variable de interés $X$ (el habla), que registramos en un soporte $cal(S) subset.eq RR^d$ de alta dimensión, en realidad se concentran en cierta _variedad_ #footnote[Término que ya precisaremos. Por ahora, #MM es el _subespacio de realizaciones posibles_ de $X$.] $MM subset.eq cal(S)$ de potencialmente mucha menor dimensión $dim MM = d_MM << d$, con una noción de distancia más "útil" que la de $cal(S)$. A tal postulado se lo conoce como "la hipótesis de la variedad", o _manifold hypothesis_. <hipotesis-variedad>
#footnote[
  Para el lector curioso: @rifaiManifoldTangentClassifier2011 ofrece un desglose de la hipótesis de la variedad en tres aspectos complementarios, de los cuales el aquí presentado sería el segundo, la "hipótesis de la variedad no supervisada". El tercero, "la hipótesis de la variedad para clasificación", dice que "puntos de distintas clases se concentrarán sobre variedades disjuntas separadas por regiones de muy baja densidad", y lo asumimos implícitamente a la hora de construir un clasificador.
]


La hipótesis de la variedad no es exactamente una hipótesis contrastable en el sentido tradicional del método científico; de hecho, ni siquiera resulta obvio que de existir, sean susceptibles de definición las variedades en las que existen los elementos del mundo real: un dígito manuscrito, el canto de un pájaro, o una flor. Y de existir, es de esperar que sean altamente no lineales. Más bien, corresponde entender esta hipótesis como un modelo mental, que nos permite aventurar ciertas líneas prácticas de trabajo en alta dimensión.
#footnote[
  El uso de la palabra "variedad" para denotar semi-formalmente un espacio no euclídeo con una noción de "distancia" va más allá de la literatura matemática. Para el lector ávido, mencionamos dos _papers_ interesantes sobre modelos "varietales" de fenómenos como la empatía y la conciencia.

  Uno es @galleseRootsEmpathyShared2003, _Las Raíces de la Empatía: La Hipótesis de la Variedad Compartida y las Bases Neuronales de la Intersubjetividad_: la hipótesis sostiene que existe un espacio intersubjetivo que compartimos con los demás. No somos mentes aisladas intentando descifrar a otras mentes aisladas; más bien, habitamos un espacio común de acción y emoción. Este "nosotros" (_we-centric space_) es la condición de posibilidad para la empatía. Reconocemos al otro no como un objeto, sino como otro "yo", porque cohabitamos la misma variedad corporal y neuronal.

  El otro es  @bengioConsciousnessPrior2019, _El Prior de la Conciencia_, en el que se postula que ante un espacio infinito de estímulos, la conciencia tiene una función evolutiva y computacional específica: actuar como un cuello de botella de información para facilitar el razonamiento y la generalización. La conciencia produce una representación rala y de baja dimensionalidad compuesta por los factores salientes de entre los estímulos recibidos y sus interconexiones --- es decir, una cierta variedad de baja dimensión intrínseca.
]

#figure(caption: flex-caption(
  [Ejemplos de variedades en el mundo físico: una bandera flameando al viento, el pétalo de una flor. Ambas tienen dimensión $d_MM = 2$ y están embebidas en $RR^3$. Ninguna es lineal.],
  "Ejemplos de variedades en el mundo físico",
))[
  #fig-grid(
    image("/assets/fermat/img/bandera-argentina.png", alt: "Bandera argentina flameando al viento"),
    image("/assets/fermat/img/hormiga-petalo.jpg", alt: "Hormiga sobre el pétalo de una flor"),
  )
]

Antes de poder profundizar en esta línea, debemos plantearnos algunas preguntas básicas:
#html.elem("p", attrs: (style: "text-align: center"))[
  ¿Qué es _exactamente_ una variedad? \ \
  ¿Se pueden construir KDE con soporte en variedades? \ \
  ¿Y si la variedad es _desconocida_?
]

#callout(kind: "recap", title: "Cómo sigue")[
  Las próximas partes responden estas preguntas en orden: #parte("fermat-04-variedades-de-riemann")[qué es una variedad de Riemann] (la más abstracta de la serie), #parte("fermat-05-densidades-en-variedades")[cómo estimar densidades y clasificar sobre ella], y qué hacer cuando es desconocida: #parte("fermat-06-aprendizaje-de-distancias")[aprender la distancia] y, en particular, la #parte("fermat-07-distancia-de-fermat")[distancia de Fermat]. Quien prefiera saltear la matemática puede seguir directamente por la #parte("fermat-08-propuesta")[propuesta].
]


#bibliography("/refs.bib", title: "Referencias")
