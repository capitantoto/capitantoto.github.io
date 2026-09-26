// Macros shared by the Fermat thesis series, adapted from fkdc/docs/tesis.typ for HTML export.
#import "lib.typ": fig-grid
// Data and image paths passed to these helpers must be root-absolute (e.g. "/assets/fermat/data/x.csv"); compile with --root pointing at site/.
#let ind = $op(bb(1))$
#let in-outline = state("in-outline", false)
#let iid = "i.i.d."
#let sop = $op("sop")$
#let Pr = $op("Pr")$
#let bu(x) = $bold(upright(#x))$
#let GG = $cal(G)$
#let MM = $cal(M)$
#let HH = $bu(H)$
#let XX = $bu(X)$
#let KH = $op(K_HH)$
#let dotp(x, y) = $lr(chevron.l #x, #y chevron.r)$
#let dg = $op(d_g)$
#let var = $op("Var")$
#let SS = $bu(Sigma)$
// nombres de clasificadores
#let fkdc = [$f$`-KDC`]
#let kdc = `KDC`
#let fkn = [$f$`-KN`]
#let kn = `KN`
#let gnb = `GNB` // $("GNB")$
#let logr = `LR`
#let slr = [$s$`-LR`]
#let svc = `SVC`
#let gbt = `GBT`
// clasificador genérico
#let clf = $op(hat(G))$
#let flex-caption(long, short) = (
  context if in-outline.get() {
    short
  } else {
    long
  }
)
#let hfrac(num, denom) = math.frac(num, denom, style: "horizontal")


// Theorem-like environments: ctheorems does not target HTML, so these render as classed blocks without numbering.
#let _thmlike(kind, label) = (..args) => {
  let pos = args.pos()
  let body = pos.last()
  let name = if pos.len() > 1 { pos.first() } else { none }
  html.elem("div", attrs: (class: "thm " + kind))[*#label*#if name != none [ (#name)]. #body]
}
#let defn = _thmlike("defn", "Definición")
#let thm = _thmlike("thm", "Teorema")
#let obs = _thmlike("obs", "Observación")

#let encabezados_csv = (clf: [Clf.], alpha: $alpha$, bandwidth: $h$, count: [Cant.], r2: $R^2$)

// `collapse`: columnas (por nombre) cuyo valor solo se muestra cuando cambia
// respecto de la fila anterior; entre grupos de la primera de ellas se traza una línea.
#let tabla_csv(path, caption: none, short-caption: none, headers: encabezados_csv, collapse: (), raw-cols: ()) = {
  let data = csv(path)
  let scope = (fkdc: fkdc, kn: kn, fkn: fkn, kdc: kdc, lr: logr, svc: svc, gnb: gnb, gbt: gbt, slr: slr)
  let nombres = data.at(0)
  let rows = data.slice(1)
  let render(v) = if v in scope { scope.at(v) } else { eval(v, mode: "markup", scope: scope) }
  let render_col(i, v) = if nombres.at(i) in raw-cols { raw(v) } else { render(v) }
  let colapsadas = collapse.map(c => nombres.position(h => h == c)).filter(i => i != none)

  let cells = (
    table.hline(stroke: 1pt),
    ..nombres.map(h => table.cell(align: center)[*#headers.at(h, default: eval(h, mode: "markup", scope: scope))*]),
    table.hline(stroke: 0.5pt),
  )
  let previa = none
  for row in rows {
    if previa != none and colapsadas.len() > 0 and row.at(colapsadas.first()) != previa.at(colapsadas.first()) {
      cells.push(table.hline(stroke: 0.5pt))
    }
    for (i, v) in row.enumerate() {
      // Se omite el valor si esta y todas las columnas colapsadas anteriores coinciden con la fila previa.
      let repetida = (
        previa != none and i in colapsadas and colapsadas.filter(j => j <= i).all(j => row.at(j) == previa.at(j))
      )
      cells.push(if repetida { [] } else { render_col(i, v) })
    }
    previa = row
  }
  cells.push(table.hline(stroke: 1pt))

  let t = table(
    columns: nombres.len(),
    stroke: none,
    ..cells,
  )
  if caption != none {
    figure(t, caption: flex-caption(caption, if short-caption != none { short-caption } else { caption }))
  } else {
    t
  }
}

// CSV con metadata de columnas en las primeras `skip-rows` filas (default 3):
// fila 0 con clasificador asociado, fila 1 con nombre de variable, fila 2
// vacía marcando "semilla". Se descarta toda esa cabecera y se usa `labels`
// (array de contenido, típicamente fórmulas math) como encabezado real.
// Opcionalmente `columns` proyecta solo los índices de columna deseados,
// útil para descartar columnas no relevantes para la tesis.
// `split: n` reparte las filas en `n` bloques lado a lado, cada uno con su
// encabezado (útil para tablas largas y angostas).
#let tabla_params(path, labels, columns: none, skip-rows: 3, split: 1, caption: none, short-caption: none) = {
  let data = csv(path)
  let rows = data.slice(skip-rows)
  let projected = if columns != none { rows.map(r => columns.map(i => r.at(i))) } else { rows }
  let encabezado = labels.map(l => table.cell[*#l*])
  let t = if split <= 1 {
    table(columns: labels.len(), stroke: none, table.header(..encabezado), ..projected.flatten())
  } else {
    let alto = calc.ceil(projected.len() / split)
    let bloques = range(split).map(j => projected.slice(j * alto, calc.min((j + 1) * alto, projected.len())))
    let vacia = labels.map(_ => [])
    let filas = range(alto).map(i => bloques.map(bl => if i < bl.len() { bl.at(i) } else { vacia }).flatten())
    table(
      columns: labels.len() * split,
      stroke: none,
      table.header(..range(split).map(_ => encabezado).flatten()),
      ..filas.flatten(),
    )
  }
  if caption != none {
    figure(t, caption: flex-caption(caption, if short-caption != none { short-caption } else { caption }))
  } else { t }
}

// Ficha de un dataset en el Anexo de la tesis (no publicado en el blog): texto plano.
#let ficha-link(dataset, body) = body
#let ficha-de(dataset) = ficha-link(dataset, raw(dataset))

// Wrapper de `figure` que estira el cuerpo por encima del ancho del texto.
// Por defecto 140%; útil para gráficos triples (lunas/circulos/espirales) y
// figuras-resumen panorámicas.
#let wide_figure(width: 140%, body, ..args) = figure(
  box(width: width, body),
  ..args,
)

// CSV con columnas (clf, cant, datasets). Renderiza la primera columna
// pasando por los macros estilizados de clasificador, la última envolviendo
// cada nombre de dataset en `raw` (monoespaciado).
#let tabla_clf_destacados(path, caption: none, short-caption: none) = {
  let data = csv(path)
  let clf-macros = (fkdc: fkdc, kn: kn, fkn: fkn, kdc: kdc, lr: logr, svc: svc, gnb: gnb, gbt: gbt, slr: slr)
  let headers = data.at(0)
  let rows = data.slice(1)
  let format_row(row) = (
    clf-macros.at(row.at(0).trim(), default: row.at(0)),
    row.at(1),
    row.at(2).split(", ").map(d => raw(d.trim())).join([, ]),
  )
  let cells = (
    table.hline(stroke: 1pt),
    ..headers.map(h => table.cell(align: center)[*#h*]),
    table.hline(stroke: 0.5pt),
    ..rows.map(format_row).flatten(),
    table.hline(stroke: 1pt),
  )
  let t = table(
    columns: (auto, auto, 1fr),
    stroke: none,
    align: (center, center, left),
    ..cells,
  )
  if caption != none {
    figure(t, caption: flex-caption(caption, if short-caption != none { short-caption } else { caption }))
  } else { t }
}


// ##################################
// ### Macros compartidos por los posts de resultados
// ##################################
#let sfd = $D_(Q, alpha)$
#let euc = $norm(thin dot thin)_2$
#let reps = 25
#let plotting_seed = 1075

#let img(path) = image("/assets/fermat/img/" + path, width: 100%)
// Rótulo de fila rotado 90° a la izquierda, como `rotate(-90deg)` en la tesis.
#let rotulo(body) = html.elem("div", attrs: (style: "writing-mode: vertical-rl; transform: rotate(180deg); margin: auto;"), body)

// Mapeo de nombres CSV a macros de clasificadores
#let clf_macros = (fkdc: fkdc, kdc: kdc, fkn: fkn, kn: kn, gnb: gnb, lr: logr, slr: slr, svc: svc, gbt: gbt)

// Versión HTML de la tabla resumen y del cuadro de síntesis por dataset: la tesis
// resuelve el cuadro con `layout`/`measure`/`scale`, que no existen en HTML, y
// `table.cell(fill:)` y `text(fill:)` se descartan al exportar. Aquí la tabla se
// arma como HTML con el mejor resaltado en verde y los atenuados translúcidos.
#let highlights_table(highlights) = {
  let csv_string = highlights.at("summary")
  let best_clf = highlights.at("best", default: none)
  let bad_clfs = highlights.at("bad", default: ())
  let lines = csv_string.split("\n").filter(l => l.len() > 0)
  let headers = lines.at(0).split(",")
  let rows = lines.slice(1)

  let cell_style(i) = if i == 0 { "text-align: right; border-right: 0.5pt solid currentColor; padding: 0.15em 0.5em;" } else { "text-align: left; padding: 0.15em 0.5em;" }

  let head = html.elem("thead", html.elem("tr", headers.enumerate().map(((i, h)) => {
    let label = if h == "clf" { [clf] } else if h == "r2" { [$R^2$] } else if h == "accuracy" { [exac] } else { [#h] }
    html.elem("th", attrs: (style: "text-align: center; border-bottom: 1pt solid currentColor; padding: 0.15em 0.5em;"), label)
  }).join()))
  let body = html.elem("tbody", rows.map(row_str => {
    let fields = row_str.split(",")
    let clf_key = fields.at(0)
    let clf_label = clf_macros.at(clf_key, default: raw(clf_key))
    let row_class = if clf_key == best_clf { "best" } else if clf_key in bad_clfs { "bad" } else { "" }
    html.elem("tr", attrs: (class: row_class), fields.enumerate().map(((i, field)) => {
      let content = if i == 0 { clf_label } else if field == "" { [--] } else { field }
      html.elem("td", attrs: (style: cell_style(i) + if field == "" { "text-align: center;" } else { "" }), content)
    }).join())
  }).join())
  html.elem("table", attrs: (class: "highlights", style: "margin: 0.5em auto; border-collapse: collapse; font-size: 0.85em;"), head + body)
}

// Cuadro de dos columnas: a la izquierda el scatterplot sobre la tabla resumen,
// a la derecha los dos boxplots (verticales) uno debajo del otro.
#let highlights_figure(dataset, width: 100%) = {
  let highlights = json("/assets/fermat/data/" + dataset + "-r2-highlights.json")
  let izquierda = img(dataset + "-scatter.svg") + highlights_table(highlights)
  let derecha = ("r2", "accuracy").map(m => img(dataset + "-" + m + "-boxplot.svg")).join()
  figure(
    kind: image,
    fig-grid(columns: "1fr 1fr", gap: "1em", izquierda, derecha),
    caption: flex-caption[_Scatterplot_, tabla resumen y _boxplots_ de $R^2$ y _accuracy_ en el dataset #raw(dataset)][Resumen de resultados para #raw(dataset)],
  )
}


// ##################################
// ### Recursos editoriales del blog (no están en la tesis)
// ##################################
// Recuadro destacado: `kind` es "lead" (pregunta y respuesta corta al inicio de cada post),
// "math" (aviso de nivel matemático) o "recap" (resumen o puente entre posts).
#let callout(kind: "lead", title: none, body) = html.elem("aside", attrs: (class: "callout " + kind), {
  if title != none { html.elem("p", attrs: (class: "callout-title"), strong(title)) }
  body
})
// Bloque plegable para material que se puede saltear (notación, cuentas, demostraciones).
#let plegable(title, body) = html.elem("details", attrs: (class: "fold"), html.elem("summary", title) + body)
// Enlace a otra parte de la serie por slug.
#let parte(slug, body) = link(slug + ".html", body)
