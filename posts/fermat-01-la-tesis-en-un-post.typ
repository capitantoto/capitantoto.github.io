#import "../lib.typ": *
#import "../fermat.typ": *

#let meta = (
  title: "La tesis en un post: distancia de Fermat para clasificar",
  date: none,
  series: "fermat",
  part: 1,
  summary: [De dónde salió, qué se preguntó y qué encontró mi tesis de maestría sobre distancia de Fermat en clasificadores de densidad por núcleos, y un mapa para leer el resto de la serie en el orden y la profundidad que cada uno prefiera.],
  status: "published",
  lang: "es",
)
#show: post.with(..meta)

_Esta serie adapta mi tesis de maestría en Estadística Matemática (UBA), "Distancia de Fermat en Clasificadores de Densidad por Núcleos", dirigida por Pablo Groisman. Este primer post es la tesis entera en pocas líneas: de dónde salió, qué se preguntó, qué encontró y un mapa para leer el resto. Se puede leer solo; los demás profundizan cada pieza._

#callout(title: "Si solo leés una cosa")[
  - *La pregunta.* En alta dimensión la distancia euclídea deja de distinguir lo cercano de lo lejano. Si los datos viven en una variedad de baja dimensión, ¿se puede aprender de la muestra una distancia mejor --- la _distancia de Fermat_ --- y clasificar mejor con ella?
  - *Lo que construí.* Dos clasificadores, #fkdc (densidad por núcleos) y #fkn ($k$ vecinos más cercanos), que reemplazan la distancia euclídea por la de Fermat, y los comparé con sus pares euclídeos y cuatro algoritmos de referencia en 20 datasets, con #reps repeticiones cada uno.
  - *Lo que encontré.* Ningún algoritmo es universalmente óptimo. Por $R^2$ mediano, #fkdc ganó en 7 datasets y #fkn en 5; por exactitud la ventaja se diluye y #svc resulta casi imbatible. La distancia de Fermat ayuda en variedades muy curvas o ralamente muestreadas, con atributos en una escala común y pocas dimensiones de ruido puro. En vecindarios pequeños no se distingue de la euclídea.
]

= Introducción

Hace un lustro, cuando ya salíamos a hacer las compras sin barbijos pero la educación seguía siendo fundamentalmente a distancia en los últimos estertores de la pandemia del covid, me anoté a una optativa del departamento de matemática para completar el programa de la maestría en estadística. Al igual que los otros 120 alumnos inscriptos, le vi nombre de materia práctica, pero resultó ser un paseo para nada aleatorio sobre tópicos de probabilidad, con tangenciales menciones a aplicaciones de aprendizaje automático. Tan "áspera" resultó para los que no veníamos de la licenciatura en matemática, que solo una décima parte de los inscriptos la cursamos hasta el final, y versiones más recientes del mismo curso llevan el siguiente descargo justo por encima del programa:

#quote(attribution: [del sitio de #link("https://sites.google.com/view/pml2024")[probabilidad y machine learning (2024)]])[
  _Esta es una materia de matemática_, más precisamente de probabilidad. Vamos a probar teoremas y todo eso (pero no sólo eso!). Los problemas que trataremos están motivados por cuestiones relativas al aprendizaje automático (ML), pero vamos a hacer matemática. $[dots]$ Ya enterados, si siguen con ganas, son todes bienvenides!
]

Quienes nos quedamos hasta el final tuvimos la oportunidad de estudiar con riguroso fundamento matemático fenómenos "folclóricos" del análisis estadístico como la "maldición de la dimensionalidad", aprender marcos teóricos sólidos para áreas de frontera del aprendizaje automático como las redes neuronales @lecunDeepLearning2015 y el aprendizaje de variedades @bengioRepresentationLearningReview2013, y "mojar los pies" en el análisis de elementos aleatorios definidos en espacios de probabilidad no reducibles a $RR^d$ como grafos, procesos puntuales y paseos al azar.

Encantado con el programa, le pregunté al docente a cargo si no tenía algún tema de investigación asequible a una tesis de maestría, y me contestó que sí. De las conversaciones posteriores surgió la idea de aplicar la "distancia de Fermat" @groismanNonhomogeneousEuclideanFirstpassage2022 al problema de clasificación en altas dimensiones. Las páginas que siguen están escritas en el mismo espíritu curioso e indagador de aquella materia que lo disparó. En los preliminares --- de la #parte("fermat-02-clasificar-con-densidades")[segunda] a la #parte("fermat-07-distancia-de-fermat")[séptima parte] --- comenzamos por definir las dificultades de la clasificación en alta dimensión, pero en lugar de ir "hacia adelante" a posibles soluciones, primero hacemos un recorrido preliminar en la dirección opuesta: hacia explicaciones posibles de lo desafiante del problema de clasificación en alta dimensión, y hacia el desarrollo histórico de los métodos estadísticos --- estimación de densidad por núcleos --- y la teoría matemática --- densidad en variedades riemannianas compactas sin frontera --- que subyacen a los algoritmos de clasificación novedosos basados en distancia de Fermat que proponemos en la #parte("fermat-08-propuesta")[octava parte]. En la #parte("fermat-09-metodologia")[novena] definimos también los experimentos y el proceso de evaluación de las bondades relativas de tales clasificadores, mientras que de la #parte("fermat-10-resultados-en-el-plano")[décima] a la #parte("fermat-13-datasets-organicos")[decimotercera] analizamos los resultados obtenidos. En la #parte("fermat-14-conclusiones")[última] recapitulamos lo obtenido: como es de esperar, el método propuesto ofrece ventajas marginales sobre métodos equivalentes entrenados con distancia euclídea, pero solo en escenarios particulares, que intentamos caracterizar a partir de lo observado. Finalmente, proponemos algunas líneas de trabajo futuro _a priori_ prometedoras.

En una época absolutamente obsesionada por la inteligencia artificial y los agentes, donde la red neuronal profunda parece ser la reina del aprendizaje automático, perseguir un resultado de mejora marginal en escenarios específicos para un método clásico puede parecer irrelevante. Este texto no fue escrito para "empujar la frontera", sino para disfrutar del humano placer de aprender en profundidad un tema, y compartir con los demás lo aprendido. Espero que leer estas páginas les genere una fracción del placer que a mí me da presentárselas.


= La tesis en un párrafo

Este es el resumen de la tesis, tal como fue presentado:

#quote[En altas dimensiones, la distancia natural del espacio en que se registran las observaciones de un elemento aleatorio --- típicamente la distancia euclídea en $RR^d$ --- no distingue adecuadamente entre elementos en la vecindad local de una observación y otros más alejados, lo cual dificulta enormemente cualquier tarea de clasificación basada en distancias. Según la "hipótesis de la variedad", los elementos aleatorios bajo estudio podrían posarse sobre una variedad de dimensión intrínseca potencialmente mucho menor que la ambiente --- la del soporte de registro ---, y en tal contexto sería posible aprender una distancia de los datos que conserve utilidad en alta dimensión. Habiendo analizado la genealogía y los fundamentos teóricos del aprendizaje de distancias, proponemos un clasificador basado en densidad por núcleos para elementos aleatorios definidos en variedades riemannianas compactas, sin frontera y _a priori_ desconocidas, utilizando la distancia de Fermat aprendida de los datos disponibles, y aplicamos la misma distancia al clasificador de $k$ vecinos más cercanos. El estudio sistemático de estas construcciones revela que los clasificadores basados en densidad son competitivos frente a métodos del estado del arte, sin que ninguno domine con claridad. En datasets de alta curvatura y poca separación entre clases, clasificadores entrenados con distancia de Fermat aportan mejoras en términos de $R^2$ sobre sus pares con distancia euclídea, sin perder en exactitud. En escenarios bien muestreados, donde la ventana del clasificador es pequeña y define un vecindario dentro del radio de inyectividad de la variedad, la distancia de Fermat no se diferencia de la euclídea y el beneficio es casi nulo. Por último, la distancia de Fermat es tan sensible a la escala de los atributos como la euclídea: en datasets con unidades heterogéneas, estandarizar es indispensable para que los clasificadores basados en distancias sean competitivos.]

Dos figuras condensan el aporte. La primera muestra lo que la distancia de Fermat permite hacer: en dos hélices entrelazadas, el vecindario euclídeo de un punto pronto incorpora la otra hélice, mientras que el vecindario de Fermat crece a lo largo de la hebra, de modo que #fkn se mantiene cerca de su óptimo para _cualquier_ cantidad de vecinos $k$.

#figure(
  image("/assets/fermat/img/helices_0-fkn_kn-mean_test_score.svg"),
  caption: [Máximo _score_ medio en validación cruzada por cantidad de vecinos $k$ en `helices_0`. Para cada $k$, se muestra el mejor desempeño hallado entre todas las parametrizaciones de cada clasificador; #fkn y su "dominio ampliado" vía $alpha$ igualan o superan a #kn para todo $k$. Detalles en la #parte("fermat-12-resultados-en-3d")[parte 12].],
)

La segunda muestra su límite más prosaico: la distancia de Fermat se construye sobre aristas euclídeas, así que hereda la sensibilidad a la escala de los atributos. En `pinguinos`, una variable en gramos frente a tres en milímetros hunde a toda la familia de métodos basados en distancias, y estandarizar la devuelve al nivel del mejor.

#figure(
  kind: image,
  fig-grid(img("pinguinos-crudo-vs-std-r2.svg"), img("pinguinos-crudo-vs-std-accuracy.svg")),
  caption: [$R^2$ y exactitud medianos en `pinguinos` sobre los atributos crudos (punto lleno) y estandarizados en el entrenamiento (punto vacío). Detalles en la #parte("fermat-13-datasets-organicos")[parte 13].],
)

= Cómo leer la serie

Cada parte responde una pregunta y se puede leer sola. Las partes 4 a 7 son las más matemáticas: quien solo quiera la intuición puede leer la 2 y la 3 y saltar a la #parte("fermat-08-propuesta")[propuesta]; quien solo quiera los resultados puede ir directo a la #parte("fermat-10-resultados-en-el-plano")[parte 10].

#let mapa = (
  ("fermat-02-clasificar-con-densidades", [Clasificar estimando densidades], [¿Cómo se construye un clasificador a partir de estimar densidades?], [general]),
  ("fermat-03-maldicion-y-variedades", [La maldición de la dimensionalidad y la hipótesis de la variedad], [¿Por qué falla en alta dimensión, y por qué aun así funciona?], [general]),
  ("fermat-04-variedades-de-riemann", [Variedades de Riemann, lo justo y necesario], [¿Qué es, exactamente, una variedad?], [matemático]),
  ("fermat-05-densidades-en-variedades", [Estimar densidades (y clasificar) sobre una variedad], [¿Se puede estimar una densidad sobre una variedad?], [matemático]),
  ("fermat-06-aprendizaje-de-distancias", [Cuando la variedad es desconocida: aprender la distancia], [¿Y si no conocemos la variedad?], [técnico]),
  ("fermat-07-distancia-de-fermat", [Distancias basadas en densidad y la distancia de Fermat], [¿Qué distancia respeta la densidad de los datos?], [matemático]),
  ("fermat-08-propuesta", [La propuesta: clasificadores con distancia de Fermat], [¿Qué construimos, exactamente?], [técnico]),
  ("fermat-09-metodologia", [Cómo comparamos clasificadores], [¿Cómo se compara con justicia un clasificador nuevo?], [técnico]),
  ("fermat-10-resultados-en-el-plano", [Resultados I: el marcador global y las curvas en el plano], [¿Quién gana, y dónde?], [resultados]),
  ("fermat-11-de-donde-sale-la-ventaja", [Resultados II: ¿de dónde sale la ventaja de #fkdc?], [¿Es la distancia de Fermat o es otra cosa?], [resultados]),
  ("fermat-12-resultados-en-3d", [Resultados III: hélices, hueveras y otras variedades en 3D], [¿Cuándo aporta algo propio la distancia de Fermat?], [resultados]),
  ("fermat-13-datasets-organicos", [Resultados IV: datasets "orgánicos"], [¿Qué pasa con datos reales?], [resultados]),
  ("fermat-14-conclusiones", [Conclusiones y próximos pasos], [¿Cuándo conviene, y qué queda por hacer?], [general]),
)
#html.elem("table", attrs: (class: "series-map"), {
  html.elem("thead", html.elem("tr", ([Parte], [Post], [Pregunta], [Nivel]).map(h => html.elem("th", h)).join()))
  html.elem("tbody", mapa.enumerate().map(((i, (slug, titulo, pregunta, nivel))) => html.elem("tr", (
    html.elem("td", str(i + 2)),
    html.elem("td", parte(slug, titulo)),
    html.elem("td", pregunta),
    html.elem("td", nivel),
  ).join())).join())
})

El código que acompaña la tesis está en #link("https://github.com/capitantoto/fermat")[github.com/capitantoto/fermat].

#bibliography("/refs.bib", title: "Referencias")
