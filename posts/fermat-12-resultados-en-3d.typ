#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Resultados III: hélices, hueveras y otras variedades en 3D",
  date: "2026-12-14",
  series: "fermat",
  part: 12,
  summary: [Donde la distancia de Fermat sí aporta algo propio --- variedades curvas y muy próximas entre sí --- y qué pasa cuando se agregan 12 dimensiones de ruido.],
  status: "draft",
  lang: "es",
)
#show: post.with(..meta)

#callout(title: "Si solo leés una cosa")[
  Acá aparece el aporte propio de la distancia de Fermat. En `helices_0` y `hueveras_0` aparecen hiperparametrizaciones con $alpha > 1$ que mejoran el $R^2$ --- en `hueveras_0`, incluso con la misma cantidad de vecinos $k$ que #kn: una mejora neta atribuible a la distancia de Fermat. Además, en `helices_0` #fkn se mantiene cerca de su óptimo para cualquier $k$, porque sus vecindarios crecen a lo largo de la hélice sin saltar a la otra. En `pionono`, en cambio, no hay diferencia significativa, y en `eslabones` la tarea es tan sencilla que toda la familia alcanza $R^2 approx 1$. Y con 12 dimensiones de ruido agregadas, toda la familia de métodos basados en densidad se desploma, con o sin Fermat.
]



Consideraremos a continuación datasets de variedades con dimensión intrínseca  $1$ (`eslabones, helices`) y $2$ (`pionono, hueveras`) embebidas en 3D.

= Eslabones

#highlights_figure("eslabones_0", width: 95%)

Toda la familia de estimadores de densidad por núcleos alcanza un $R^2 approx 1$, y aun Naive Bayes tiene un rendimiento aceptable: con este nivel de ruido blanco en el muestreo, el "margen de separación" entre ambos anillos es tan amplio que la tarea resulta trivial.

Un punto en contra de #fkdc aquí es que el _boxplot_ de $R^2$ --- no así el de exactitud --- revela un fuerte _outlier_ para la semilla $2411$:

#tabla_csv(
  "/assets/fermat/data/eslabones_0-params-2411.csv",
  caption: [Parametrización de #fkdc para `eslabones_0`, $s=2411$.],
  short-caption: [Parámetros de #fkdc en `eslabones_0`, $s=2411$],
)

La semilla resultó adversa para ambos, pero particularmente para #fkdc. #gbt queda técnicamente a más de $1 sigma$ del $R^2$ medio de #fkn, pero en la práctica, ofrece un $R^2$  excelente _sin ningún outlier_.

= Hélices

#highlights_figure("helices_0")

Este dataset consiste en dos hélices del mismo diámetro y "enroscadas" en la misma dirección, una de ellas empezando a "media altura" entre dos brazos consecutivos de la otra. El dataset es particularmente desafiante para Naive Bayes y regresión logística, que no logran diferenciarse en nada de un clasificador trivial que prediga siempre la misma clase.
#obs[El rendimiento de #logr es malo únicamente porque se aplicó ciegamente a los datos. La primera tarea cuando se busca inferir la geometría de unos datos es graficarlos, y al observar la hélice uno puede parametrizarla de manera natural como $f(x, y, z) = ("ángulo, velocidad radial, velocidad vertical") ,$ entrenar sobre esta _representación_ y obtener un $R^2 approx 1$.
  Todo algoritmo funciona OK sobre una representación adecuada --- la ventaja de algunos es que son _plug and play_: no hace falta dedicarle demasiada atención a la elección de covariables. Que a #gnb le resulte complejo es esperable, ya que las distribuciones marginales son prácticamente idénticas.
]
#figure(
  image("/assets/fermat/img/helices-pairplot.svg"),
  caption: flex-caption(
    [_Pairplot_ del dataset `helices_0`. Las densidades marginales son prácticamente idénticas para ambas clases, el talón de Aquiles de #gnb.],
    [_Pairplot_ de `helices_0`.],
  ),
)
La clasificación dura con estimación de densidad por núcleos --- con distancia de Fermat o sin ella --- resulta ser ligeramente superior a todas las alternativas en términos de exactitud y muy superior en $R^2$. Encima de ello, #fkdc mejora en $R^2$ a #kdc por casi 5 puntos porcentuales y consistentemente en (casi) todas las semillas. ¿Con qué parámetros?
#figure(
  image("/assets/fermat/img/helices_0-kdc-fkdc-r2-scatter.svg"),
  caption: flex-caption(
    [$R^2$ apareado por semilla en `helices_0`: cada punto compara una corrida de #fkdc con la de #kdc para la misma semilla. #fkdc supera a #kdc en casi todas las semillas, con una ventaja media de 5pp.],
    [$R^2$ de #fkdc vs. #kdc por semilla en `helices_0`.],
  ),
)

La semilla con mayor $Delta_(R^2)$ favorable a #fkdc corresponde a una hiperparametrización no reducible a #kdc $(alpha = 1.25, h = 0.006)$ y le otorga 23.7pp de $R^2$ _en términos absolutos_ #footnote[En criollo, "un montón".] más que #kdc con $h = 0.208$ --- una ventana $approx 35$ veces más ancha.

Salta a la vista también que tales parametrizaciones "divergentes" tienen muy variado rendimiento por fuera del conjunto de entrenamiento #footnote[O _out-of-sample_, en inglés.], pues para $s = 8096$ #fkdc eligió la misma ventana contra $h_#kdc = 0.143 approx 25 h_#fkdc$ y se dio la segunda diferencia más amplia _en contra_ de #fkdc ($Delta_(R^2) = -0.098$).

#tabla_params(
  "/assets/fermat/data/helices_0-parametros_comparados-kdc.csv",
  ($s$, $Delta_(R^2)$, $alpha_#fkdc$, $h_#fkdc$, $R^2_#fkdc$, $h_#kdc$, $R^2_#kdc$),
  columns: (0, 1, 2, 3, 4, 5, 6),
  caption: [Parámetros comparados de #fkdc vs. #kdc en `helices_0`, ordenados por $Delta_(R^2)$.],
  short-caption: [Parámetros de #fkdc vs. #kdc en `helices_0`],
)


Se podría argumentar en contra de #fkdc que $alpha = 1.25 approx 1$, pero al revisar el comportamiento de la regla de parsimonia,  encontramos por ejemplo que para $s = 1188, thin Delta_(R^2) = 0.227$  la parametrización maximizadora de $R^2$ en entrenamiento fue con $(h = 10^(-3), alpha=3)$ y todas las hiperparametrizaciones a menos de $1 sigma$ de esta tenían $alpha >= 2.5$, lejos de 1.

Más aún, en unos cuantos casos --- $s in {1182, 6610, 2411}$ --- en que $alpha_#fkdc = alpha_#kdc = 1$, #fkdc todavía rinde un poco mejor que #kdc al elegir anchos de banda mucho más pequeños. Ya hemos visto que aun ligeras diferencias en $h$ pueden redundar en un $R^2$ favorable a #fkdc por el "detalle fino" de la búsqueda de hiperparámetros. Sin embargo vemos casos como el de

$ s = 1182, quad Delta_(R^2)=0.111, quad alpha_#fkdc = alpha_#kdc = 1, quad h_#kdc / h_#fkdc approx 14.3, $

que cuesta explicar únicamente en base al mismo fenómeno.


#wide_figure(
  kind: image,
  fig-grid(
    gap: ".5em",
    img("helices_0-1188-fkdc-bandwidth-alpha-loss_contour.svg"),
    img("r1sd+alpha.svg"),
  ),
  caption: flex-caption(
    [Superficie de pérdida de #fkdc en `helices_0`.
      (izq., $s=1188$) Nótese la pequeña "isla" alrededor de $h approx 10^(-3), alpha = 3$. (der., $s=1182$) #kdc encuentra (1) al entrenar, #fkdc se sale de $alpha=1$ y encuentra (2). La regla de parsimonia encuentra (3), de vuelta con $alpha = 1$.],
    [Superficies de pérdida para #fkdc en `helices_0`],
  ),
) <alpha-ne-1>

Nuestra hipótesis es que el dominio ampliado de hiperparámetros de #fkdc junto con la regla de parsimonia trabajan en tándem:

Durante el entrenamiento, #kdc encuentra la solución $h_#kdc=0.143$ (cf. posición $(1)$ de @alpha-ne-1, der.) con $alpha = 1$, sobre el borde inferior de la superficie. Presumiblemente, la varianza del rendimiento en testeo para dicha solución fue tal que ningún punto en el entorno de $h_#fkdc=0.01$ (cf. pos. $(3)$) estaba a menos de $1 sigma$ del _score_ en $(1)$. Cuando entrenamos #fkdc y ampliamos el dominio de la parametrización a toda la superficie computada, el entrenamiento por CV maximiza el _score_ en $(alpha=3.5, h = 0.001)$ --- posición $(2)$. Con esta hiperparametrización, la varianza en los resultados de cada pliego de CV es mayor, por lo que la cota inferior de la R1SD será más laxa. En ese rango ampliado de hiperparametrizaciones "suficientemente buenas" se encuentra $(alpha=1, h=0.01)$, la solución de $(3)$ que en entrenamiento #kdc vio y no eligió.

= Efecto de #sfd en las vecindades óptimas de #kn

En el estimador de densidad en variedades de  #cite(<loubesKernelbasedClassifierRiemannian2008>, form: "prose"), al núcleo $K$ se lo evalúa sobre
$frac(d(x_0, X_i), h, style: "horizontal")$, y nuestra implementación de #fkdc estima la distancia con $hat(d) = D_(Q_i, alpha)(XX)$. Si resultase que la distancia de Fermat es proporcional a la euclídea --- $D_(Q_i, alpha) prop norm(dot)$ --- podríamos escribir

$
  (op(D_(Q_i, alpha))(x_0, X_i))/ h approx (c norm(x_0 - X_i))/ h = norm(x_0 - X_i) / h',
$
con $h' = h slash c$ y observaríamos que los parámetros $(alpha, h)$ se solapan en sus funciones. Localmente, cuando el espacio está "densamente" muestreado, los saltos de una observación a otra en su vecindario serán "pequeños", y el efecto "inflacionario" de $alpha$ menos importante.

Para $k = 1$, #fkn y #kn coinciden exactamente: todo camino que sale de $x_0$ en el grafo muestral comienza con una arista de longitud al menos $r_1 (x_0)$, la distancia a su vecino euclídeo más cercano, de modo que $D_(Q, alpha)(x_0, X_i) >= r_1 (x_0)^alpha$ para todo $i$, con igualdad para ese vecino. El vecino más cercano según la distancia de Fermat es también el euclídeo, cualquiera sea $alpha$, y por ello ambas curvas de la @fig-fkn-kn-k parten del mismo punto. A partir de $k = 2$ divergen por una razón "geométrica": en `helices_0`, el vecindario euclídeo de un punto pronto incorpora la otra hélice, que pasa "ahí nomás", y el mejor _score_ de #kn se desploma para $k gt.tilde 5$. Los vecindarios de Fermat, en cambio, crecen a lo largo de la hebra, y #fkn se mantiene a nada de su óptimo para _cualquier_ $k$:

#figure(
  image("/assets/fermat/img/helices_0-fkn_kn-mean_test_score.svg"),
  caption: flex-caption(
    [Máximo _score_ medio en validación cruzada por cantidad de vecinos $k$ en `helices_0`. Para cada $k$, se muestra el mejor desempeño hallado entre todas las parametrizaciones de cada clasificador; #fkn y su "dominio ampliado" vía $alpha$ igualan o superan a #kn para todo $k$.],
    [$cal(l)$ en entrenamiento para #fkn y #kn en `helices_0`],
  ),
) <fig-fkn-kn-k>

Llegamos a la misma conclusión que antes por otra dirección: en los vecindarios más pequeños #footnote[Vía $k$ en $k$-vecinos-más-cercanos, $h$ en KDE.], la distancia de Fermat no se distingue de la euclídea. Su aporte no está allí, sino en que permite agrandar el vecindario sin cruzar a la otra variedad, y por ende vuelve al clasificador robusto a la elección de $k$ (#fkn) o $h$ (#fkdc).

= Pionono

#highlights_figure("pionono_0")

Este dataset "clásico" para evaluar algoritmos de _clustering_ no lineales es analizado en #cite(<sapienzaWeightedGeodesicDistance2018>, form: "prose"), así que decidimos incluirlo en la serie experimental. El trabajo citado también es una aplicación empírica de la distancia muestral de Fermat, pero tiene otro objetivo ---  _clustering_ basado en el algoritmo $k$-medoides --- y provee un gráfico de exactitud comparada contra Isomap. Los autores encuentran que "$[dots]$ existe un amplio rango de $alpha$ #footnote[En el trabajo, "nuestro" $alpha$ se denomina $d$.] para los que la $alpha$-distancia se porta significativamente mejor que Isomap. $[dots]$ para la exactitud esta región está limitada a $1.7 <= alpha <= 2.2$".

Nuestro objetivo (clasificación, no _clustering_) como también los algoritmos empleados (#kdc y #kn en lugar de $k$-medoides) son distintos, y en este _setting_ no encontramos diferencia significativa entre #kdc y #fkdc --- o entre $alpha = 1$ y $alpha > 1$ ---, que a su vez rinden tan bien como el estado del arte en exactitud (#svc) y $R^2$ (#gbt). Esta paridad es consistente con la observación de que, en las #reps repeticiones analizadas, #fkdc seleccionó $alpha = 1$ bajo la regla de parsimonia en _todos_ los casos, colapsando efectivamente a una variante de #kdc con ancho de banda ligeramente menor.

= Hueveras ($d=3, d_MM=2, K=2$)
#highlights_figure("hueveras_0")

Este dataset sintético consiste en dos clases con idénticas distribuciones pero signo opuesto en la dirección de la coordenada vertical $ z = plus.minus(sin(x) times sin(y)) $ y se puede concebir bien como los dos cartones de un maple de huevos intentando ocupar el mismo espacio. La exactitud de la familia $cal(K)$ es competitiva contra la de #svc, que es ligeramente mejor. En términos de $R^2$, la familia $cal(K)$ es la única en alcanzar valores no nulos aunque todavía bastante bajos ($0.25$--$0.30$).


Analizando los hiperparámetros de #fkdc v. #kdc por semilla, se repite la observación de `helices_0`: el par $(alpha^star, h^star)$ que maximiza $R^2$ durante el entrenamiento de #fkdc tiene $alpha^star > 1$, pero existe otra $(alpha^(1 sigma), h^(1 sigma))$ que cumple la R1SD con $alpha^(1 sigma) = 1$ y $h^(1 sigma)$ distinta a la elegida por #kdc.  Las tres semillas en las que #fkdc saca más ventaja sobre #kdc tienen por óptimo $h_#fkdc = 0.562$ y en esos mismos _splits_ $h_#kdc = 0.774$, aunque $0.532$ y $0.641$ también estaban en la grilla de #kdc.

#tabla_params(
  "/assets/fermat/data/hueveras_0-parametros_comparados-kdc-top3.csv",
  ($s$, $Delta_(R^2)$, $alpha_#fkdc$, $h_#fkdc$, $R^2_#fkdc$, $h_#kdc$, $R^2_#kdc$),
  skip-rows: 1,
  caption: [Parámetros comparados de #fkdc vs. #kdc en `hueveras_0` para las tres semillas con mayor $Delta_(R^2)$.],
  short-caption: [Parámetros de #fkdc vs. #kdc en `hueveras_0` (top 3)],
)


En #fkn, la distancia de Fermat parece ofrecer una diferencia significativa en $R^2$ sobre #kn, con varias repeticiones del experimento donde aun con regla de parsimonia, #fkn y #kn eligen _la misma cantidad_ de vecinos pero $alpha_#fkn > 1$:

#tabla_params(
  "/assets/fermat/data/hueveras_0-parametros_comparados-kn-mismo_k.csv",
  ($Delta_(R^2)$, $k$, $alpha_#fkn$),
  skip-rows: 1,
  split: 3,
  caption: [Parámetros comparados de #fkn vs. #kn en `hueveras_0`, restringido a las repeticiones donde $k_#fkn = k_#kn$. Cuando $alpha_#fkn > 1$, $Delta_(R^2) > 0$ en casi todos los casos, indicando una ganancia neta de usar #sfd.],
  short-caption: [$Delta_(R^2)$ en `hueveras_0` con $k_#fkn = k_#kn$],
)


= Efecto de aumentar la dimensión ambiente

Sobre los datasets de `lunas`, `circulos` y `espirales` analizamos los efectos de incrementar la cantidad de _ruido_ en el registro de las observaciones, sin modificar la dimensión del espacio ambiente. Para los datasets recién presentados (`pionono`, `helices`, `hueveras`, `eslabones`) intentamos algo distinto: ¿qué pasa si los datos son los mismos, pero agregamos _dimensiones enteras_ de ruido independientes de las clases observadas? Para ello, se "extendieron" las observaciones ya analizadas con 12 dimensiones #footnote[De allí los sufijos `_0` y `_12`, que denotan la cantidad de dimensiones de ruido agregadas.], todas independientes entre sí, y distribución normal con media y varianza en la escala de las primeras 3 dimensiones agrupadas #footnote[Es decir, para cada dataset se concatenaron los valores de las 3 dimensiones de $N$ observaciones en una única muestra de longitud $3N$, de la cual se calculó la media y el desvío estándar.].

El efecto sobre el $R^2$ es dramático para todos los clasificadores, pero la familia $cal(K)$ lo sufre en particular: en `helices_12` y `hueveras_12` ningún clasificador se distingue del azar, pero en `pionono_12` y `eslabones_12` el $R^2$ de $cal(K)$ se desploma a $approx 0.1$ y $approx 0.25$, mientras que #gbt, #gnb y #logr conservan prácticamente intacto el $R^2$ alcanzado en la versión sin ruido.

#wide_figure(
  kind: image,
  fig-grid(
    ..("pionono", "eslabones", "helices", "hueveras").map(f => img(f + "-caida_r2-15d.svg")),
  ),
  caption: flex-caption(
    [Caída de $R^2$ mediano al agregar 12 dimensiones de ruido a los datasets 3D: punto lleno en 3D, punto vacío en 15D.],
    [Caída de $R^2$: 3D vs. 15D],
  ),
)

El fenómeno de las dimensiones de ruido sin correlación es particularmente pernicioso para los algoritmos basados en densidad por núcleos, aun con distancias basadas en densidad. Como la distancia de Fermat está computada como una geodésica en un grafo completo, y los pesos de cada arista están basados en distancia euclídea, las dimensiones de ruido puro "alejan" puntos cercanos entre sí en las dimensiones que importan. La ventaja de #gbt en _algunos_ de estos datasets del régimen de alto ruido es que al proceder con preguntas binarias sobre _un predictor a la vez_, puede identificar más fácilmente que cualquier pregunta sobre las columnas de ruido puro nunca sirve para partir la muestra en dos grupos con densidades bien distintas, y por eso las ignora. Algo análogo sucede con #gnb --- que no encuentra diferencia alguna en las dimensiones de ruido --- y #logr, que ajusta un coeficiente por dimensión. Las fichas de #ficha-de("pionono_12"), #ficha-de("eslabones_12"), #ficha-de("helices_12") y #ficha-de("hueveras_12") están en el Anexo de la tesis.



#bibliography("/refs.bib", title: "Referencias")
