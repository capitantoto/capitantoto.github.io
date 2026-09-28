#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "Resultados II: ¿de dónde sale la ventaja de f-KDC?",
  date: "2026-12-07",
  series: "fermat",
  part: 11,
  summary: [Un estudio de ablación y una auditoría de los hiperparámetros elegidos en `lunas_lo` muestran que, en el plano, la ventaja de #fkdc sobre #kdc no viene de la distancia de Fermat.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)

#callout(title: "Si solo leés una cosa")[
  En `lunas_lo`, #fkdc le gana a #kdc en $R^2$, pero no por la distancia de Fermat: bajo la regla de parsimonia elige $alpha = 1$ --- la distancia euclídea --- en todas las semillas, con una ventana $h$ apenas menor que la de #kdc. Las superficies de pérdida explican por qué: en datos bien muestreados, para cada $alpha$ existe una ventana $h$ que alcanza casi el mismo _score_, así que $alpha$ aporta poco que $h$ no pueda dar. Según las #parte("fermat-14-conclusiones")[conclusiones], la ventaja de #fkdc en `lunas_lo` y `espirales_lo` se explica por la interacción entre la regla de parsimonia y el espacio de hiperparámetros ampliado.
]


= Estudio de ablación: $R^2$ para #kdc / #kn con y sin distancia de Fermat

Según la #link("https://dle.rae.es/ablaci%C3%B3n")[RAE], "ablación" proviene del latín tardío "ablatio, -ōnis", y significa 'acción de quitar'. ¿Qué se pierde en términos de $R^2$ al _no_ usar la distancia de Fermat muestral #sfd en estos algoritmos? Sirvan para enfocar la atención los gráficos de dispersión del $R^2$ alcanzado en $XX_"test"$ para #kn y #kdc con y sin distancia de Fermat, en las #reps repeticiones de cada Tarea.

#let curvas = ("lunas", "circulos", "espirales")
#wide_figure(
  fig-grid(
    columns: "auto 1fr 1fr",
    // column headers
    [], [*#kdc vs. #fkdc*], [*#kn vs. #fkn*],
    // rows: one per curve
    ..curvas
      .map(c => (
        rotulo(raw(c + "_lo")),
        img(c + "_lo-kdc-fkdc-r2-scatter.svg"),
        img(c + "_lo-kn-fkn-r2-scatter.svg"),
      ))
      .sum(),
  ),
  kind: image,
  caption: flex-caption(
    [Gráficos de dispersión de $R^2$ para #kdc (izq.) y #kn (der.) con (eje $y$) y sin (eje $x$) distancia de Fermat.],
    [$R^2$ con y sin distancia de Fermat para #kdc y #kn],
  ),
) <fig-17>

Para #kn y #fkn, los resultados son casi exactamente iguales para todas las semillas en `lunas_lo` y `circulos_lo`; con ciertas semillas #fkn saca ventaja en `espirales_lo`, pero también tiene dos muy malos resultados con $R^2 approx 0$ que #kn evita.

Para #fkdc, pareciera evidenciarse alguna ventaja para varias semillas en `lunas_lo` y `espirales_lo`, menos así para `circulos_lo`.

Veamos primero qué sucede durante el entrenamiento para `circulos_lo`: ¿es que no hay ninguna ventaja en usar #sfd? Consideremos la _superficie de pérdida_ que resulta de graficar en 2D el _score_ obtenido _durante el entrenamiento_ para cada hiperparametrización considerada:

#obs(
  "unidades de la pérdida",
)[Si bien buscamos maximizar el $R^2$, el entrenamiento se realizó maximizando la log-verosimilitud --- o _score_ `neg_log_loss` #footnote[
    A posteriori de la experimentación descubrimos que entre las numerosas funciones de _score_ que tolera `scikit-learn`, se incluye #link("https://scikit-learn.org/stable/modules/model_evaluation.html#d2-score-classification")[`d2_log_loss_score`], que es esencialmente el $R^2$ de McFadden que proponemos como métrica de evaluación. Sería ideal recomputar los experimentos entrenándolos con dicha función objetivo, pero no hay razones de peso para suponer que el resultado sería distinto: al fin y al cabo, tanto la log-verosimilitud como el $R^2$ se maximizan en el mismo punto que la verosimilitud.] en `scikit-learn`  --- que toma valores en el intervalo $(-oo, 0]$. Como el _score_ es exactamente la pérdida cambiada de signo, mantenemos el nombre habitual de "superficie de pérdida" para estos gráficos, pero en ellos el óptimo es un _máximo_.]

#figure(
  image("/assets/fermat/img/circulos_lo-8527-fkdc-bandwidth-alpha-loss_contour.svg"),
  caption: flex-caption(
    [Superficie de pérdida en `circulos_lo`: para cada valor de $alpha$ considerado, una cruz roja marca el valor de $h$ que maximizó el _score_.],
    [Superficie de pérdida en `circulos_lo`],
  ),
)
Nótese que la región amarilla, que representa los máximos puntajes durante el entrenamiento, se extiende diagonalmente a través de (casi) todo el rango de $alpha$. Es decir, no hay _un_ par de hiperparámetros óptimos $(alpha^star, h^star)$, sino que fijando $alpha$, siempre pareciera existir un $tilde(h)(alpha)$ que alcanza (o aproxima) la máxima log-verosimilitud $cal(l)$ posible con #fkdc en el dataset. En este ejemplo en particular, hasta pareciera ser que una relación log-lineal captura bastante bien el fenómeno, $tilde(h) prop log(alpha)$. En particular, entonces, $cal(l)(tilde(h)(alpha), alpha) approx cal(l)(h^star, alpha^star) thin forall alpha$, y se entiende que #fkdc no mejore significativamente por sobre #kdc. Este resultado es consistente con el ya mencionado comentario de #cite(<bijralSemisupervisedLearningDensity2011>, form: "prose", supplement: [§5.1]), que encuentran que fijar $p=2$ para la norma y $q=alpha=8$ "representa una elección razonable para la mayoría de los datasets".


Ahora bien, esto es solo en _un_ dataset, con _una_ semilla específica. ¿Se replicará el fenómeno en los otros datasets?

#let semillas = (7354, 8527, 1188)

#wide_figure(
  fig-grid(
    columns: "auto 1fr 1fr 1fr",
    gap: "1px",
    // column headers (seeds)
    [], ..semillas.map(s => [*s=#s*]),
    // rows: one per curve
    ..curvas
      .map(c => (
        rotulo(raw(c + "_lo")),
        ..semillas.map(s => img(c + "_lo-" + str(s) + "-fkdc-bandwidth-alpha-loss_contour.svg")),
      ))
      .sum(),
  ),
  kind: image,
  caption: flex-caption(
    [Superficies de pérdida para tres semillas $s in #semillas$ y cada uno de los tres datasets.],
    [Superficies de pérdida para `[lunas|circulos|espirales]_lo`],
  ),
) <fig-19>

Efectivamente, el fenómeno se replica. Podemos observar también en datasets como `circulos_lo`, $s =7354$, cómo actúa la regla de parsimonia. Dentro de la "meseta color lima" que ocupa toda el área por encima de la diagonal principal del gráfico,  todas las hiperparametrizaciones alcanzan resultados similares. Sin embargo, la validación cruzada elige consistentemente para cada $h$ el menor $alpha$ posible que no "cae" hacia la región azul de menores _scores_.

Estamos ahora frente a una contradicción: en la @fig-17 vimos que, por ejemplo, para `lunas_lo`, #fkdc alcanzaba un $R^2$ consistentemente mejor que #kdc; mientras que de los paneles superiores de la @fig-19 observamos que los _scores_ que se alcanzan limitándonos a $alpha = 1$ son tan altos como los de $alpha > 1$. Es cierto que los resultados de @fig-17 son a través de _todas_ las semillas, y en el conjunto de evaluación, mientras que en la @fig-19 observamos _algunas_ semillas y sobre los datos de entrenamiento, pero la pregunta es válida: ¿de dónde proviene la ventaja de #fkdc en estos datasets?

= Hiperparámetros óptimos en `lunas_lo` para #kdc, #fkdc

Hacemos entonces una comprobación fundamental: ¿qué parametrizaciones están siendo elegidas en el esquema de validación cruzada con regla de parsimonia? Hete aquí el detalle para las #reps repeticiones de `lunas_lo`:

// Las cantidades de semillas por valor de alpha salen de data/lunas_lo-best_test_params.csv
Durante el entrenamiento, a veces el mejor se obtiene con _otros_ valores de $alpha$ --- sin aplicar la regla de parsimonia, el $alpha$ que maximiza el _score_ de entrenamiento en `lunas_lo` fue $1$ en 6 semillas, $1.25$ en 9 y $1.5$ en 10 ---, pero la mejora no es lo suficientemente grande para descartar alguna hiperparametrización con $alpha = 1$ bajo la R1SD (#parte("fermat-09-metodologia")[regla de un desvío estándar]).

#tabla_csv(
  "/assets/fermat/data/lunas_lo-best_params.csv",
  collapse: ("clf", "alpha"),
  caption: [Hiperparámetros seleccionados por CV con regla de parsimonia para #kdc y #fkdc en `lunas_lo`, por semilla.],
  short-caption: [Hiperparámetros seleccionados por R1SD de #kdc y #fkdc en `lunas_lo`],
)

Resulta ser que
- al entrenar #fkdc se está eligiendo $alpha=1$ para _todas_ las semillas, y
- el ancho de banda seleccionado es ligera pero consistentemente _menor_ que el que toma #kdc.

Veamos cómo se comparan los valores de $R^2$ que alcanza cada algoritmo en cada semilla:
#wide_figure(
  kind: image,
  fig-grid(
    img("lunas_lo-[f]kdc-score-vs-bandwidth.svg"),
    img("lunas_lo-[f]kdc-delta_r2-vs-delta_h.svg"),
  ),
  caption: flex-caption(
    [(izq.) Dispersión --- _scatter_ --- de $R^2$ en función de $h$ por clasificador y semilla en `lunas_lo`, para #fkdc, #kdc;
      (der.) dispersión de $Delta_(R^2) = R^2_#kdc - R^2_#fkdc$ en función de $Delta_h = h^(1 sigma)_#fkdc - h^(1 sigma)_#kdc$ para cada semilla.],
    [$R^2$ vs. $h$ y $Delta_(R^2)$ vs. $Delta_h$ en `lunas_lo`],
  ),
)
En el panel izquierdo se observa una clara tendencia a mejorar ligeramente el $R^2$ a medida que disminuye el ancho de la ventana $h$ (en el rango en cuestión). En el panel derecho, para confirmar que la tendencia sucede _en cada repetición del experimento_, comparamos no los valores absolutos sino las diferencias relativas en $R^2, h$ entre #fkdc y #kdc apareando los resultados _para cada semilla_, y vemos que a mayor diferencia en el $h$ de #kdc por sobre #fkdc, peor es la caída en $R^2$.

Cabe aquí una crítica al diseño experimental: si #fkdc está tomando siempre $alpha =1$, ¿por qué #kdc no puede elegir el mismo $h$ que #fkdc y así equiparar su rendimiento? ¿Se exploró una grilla de hiperparámetros a propósito desfavorable para #kdc? Pues no, todo lo contrario #footnote[La definición exacta está en `fkdc/config.py`, y es `np.logspace(-5, 6, 45)` para #fkdc y `np.logspace(-5, 6, 136)` para #kdc.]: las grillas de $h$ para #kdc y #fkdc cubren de manera "logarítmicamente equidistante" el mismo rango de $h: [10^(-5), 10^6]$ y la grilla de #kdc cuenta con $approx$ el triple de puntos de #fkdc ($136 "vs." 45$).

Como en el entrenamiento de #fkdc se gastaron 13 veces más recursos evaluando 13 valores distintos de $alpha in {1, 1.25, dots, 3.75, 4}$, consideramos oportuno permitirle a #kdc explorar más valores de $h$, y la cantidad se eligió para que la grilla de #kdc coincida con la de #fkdc, y tenga además otros dos valores intermedios entre dos valores cualesquiera de la grilla de #fkdc #footnote[
  Para hacer esto correctamente, deberíamos haber tomado $(45 - 1) times (2 + 1) + 1= 133$ elementos en la segunda grilla, pero olvidamos restar 1 a 45 --- hay 45 puntos pero 44 "espacios" entre puntos de la grilla --- y por eso obtuvimos 136 puntos, con lo cual las grillas están ligeramente "desalineadas" y una no es un subconjunto de la otra. De todas maneras, la grilla de #kdc contiene el $0.173$, mucho más cercano al $0.178$ óptimo de #fkdc, con lo cual no se termina de explicar que la elección "modal" de #kdc haya sido $0.251$.
].
En efecto, en el rango de interés, las grillas contaban con los valores redondeados a 3 decimales:
$
  #fkdc: & [0.1, 0.178, 0.316, 0.562] \
   #kdc: & [0.119, 0.143, 0.173, 0.208, 0.251, 0.303, 0.366, 0.441, 0.532],
$
con lo cual #kdc _podría_ haber encontrado el ligeramente más conveniente $h^star approx 0.173$, pero la validación cruzada se inclinó por valores concentrados en el rango $[0.25, 0.3]$. De repetir el experimento tomando una grilla más fina en este rango crucial, es posible que $Delta_h^(1 sigma) approx 0$ y por ende $Delta_(R^2)$ también, aunque por el mismo argumento, de tomar una grilla más fina para $alpha approx 1$ terminaríamos encontrando tal vez un $alpha^(1 sigma) > 1$ para #fkdc #footnote[Hete aquí la dificultad de enunciar propiedades generales a partir de experimentos particulares: siempre hay _una prueba más_ para hacer, pero lamentablemente, en algún momento había que culminar la etapa experimental.]. En cualquier caso, hemos de aceptar que la ventaja de #fkdc en `lunas_lo` y `espirales_lo` sobre #kdc _no_ se debe a la inclusión del hiperparámetro $alpha$, sino quizás a una validación cruzada aleatoriamente favorable.


#bibliography("/refs.bib", title: "Referencias")
