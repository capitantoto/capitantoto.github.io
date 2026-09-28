// Site template for Typst's HTML export. Posts rely on the `post` signature below (see the post contract in the README of this folder, if any, or the comment on `post`).
// Build inputs (all optional, so a post also compiles on its own with `typst compile --features html --root . posts/<slug>.typ`):
//   mode  = "personal" (default) | "consulting"
//   consulting-tab = "true" shows the Consulting tab in personal mode (off by default: the consulting mode is not published yet)
//   posts = comma-separated published slugs, newest first (the Makefile writes their metadata to build/meta/<slug>.json); enables the index and series navigation
//   all   = comma-separated slugs of every post with metadata, including scheduled ones; used for series totals and the "next part" notice
//   slug  = slug of the post being compiled
#let mode = sys.inputs.at("mode", default: "personal")
#let consulting = mode == "consulting"
#let consulting-tab = consulting or sys.inputs.at("consulting-tab", default: "false") == "true"
#let current-slug = sys.inputs.at("slug", default: none)
#let listed-slugs = sys.inputs.at("posts", default: "").split(",").filter(s => s != "")
#let all-slugs = sys.inputs.at("all", default: "").split(",").filter(s => s != "")

#let person = (
  name: "Gonzalo Barrera Borla",
  email: "gonzalobb@gmail.com",
  linkedin: "https://www.linkedin.com/in/gonzabb/",
  github: "https://github.com/capitantoto",
)
#let company = (
  name: "Borlandux LLC",
  email: "borlandux@outlook.com",
)

// Display names for `meta.series`; unknown series fall back to the raw key.
#let series-names = (
  fermat: (es: "Distancia de Fermat", en: "Fermat distance"),
  apuestas: (es: "Apuestas hípicas", en: "Horse-race betting"),
)

#let _i18n = (
  es: (
    months: ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"),
    date: (d, m, y) => str(d) + " de " + m + " de " + str(y),
    part: (n, total) => "Parte " + str(n) + " de " + str(total),
    prev: "Anterior",
    next: "Siguiente",
    upcoming: "Próxima parte",
    soon: "Próximamente",
    draft: "borrador",
    stub: "esbozo",
    undated: "sin fecha",
  ),
  en: (
    months: ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"),
    date: (d, m, y) => str(d) + " " + m + " " + str(y),
    part: (n, total) => "Part " + str(n) + " of " + str(total),
    prev: "Previous",
    next: "Next",
    upcoming: "Next part",
    soon: "Coming soon",
    draft: "draft",
    stub: "stub",
    undated: "undated",
  ),
)
#let _t(lang) = _i18n.at(lang, default: _i18n.en)

#let series-name(key, lang) = {
  let names = series-names.at(key, default: none)
  if names == none { key } else { names.at(lang, default: names.values().first()) }
}

#let format-date(date, lang) = {
  let (y, m, d) = date.split("-").map(int)
  let t = _t(lang)
  html.elem("time", attrs: (datetime: date), (t.date)(d, t.months.at(m - 1), y))
}

#let status-badge(status, lang) = if status in ("draft", "stub") {
  html.span(class: "badge badge-" + status, _t(lang).at(status))
}

// Plain-text rendering of short content (for <meta name="description">).
#let _plain(it) = {
  if it == none { "" } else if type(it) == str { it } else if it.has("text") { it.text } else if it.has("children") {
    it.children.map(_plain).join()
  } else if it.has("body") { _plain(it.body) } else if it.func() == [ ].func() { " " } else { "" }
}

// Metadata from the JSON files the Makefile writes (title, date, series, part, status, lang; no summary): published posts, and every post.
#let catalog() = listed-slugs.map(s => json("/build/meta/" + s + ".json") + (slug: s))
#let catalog-all() = all-slugs.map(s => json("/build/meta/" + s + ".json") + (slug: s))

// Equations become inline SVG frames (math nested inside a frame is left to the paged layout). A numbered block equation is re-rendered unnumbered and its number is set as HTML text, flush right.
#let _eq(it) = context if target() != "html" { it } else if not it.block {
  html.span(class: "eq", box(html.frame(it)))
} else if it.numbering == none {
  html.div(class: "eq-block", html.frame(it))
} else {
  html.div(class: "eq-block numbered", {
    html.frame(math.equation(block: true, numbering: none, it.body))
    html.span(class: "eq-num", context counter(math.equation).display(it.numbering))
  })
}

// CSS-grid column template from Typst `columns` (int, array of fr/auto/length) or a raw CSS string.
#let _grid-template(columns) = {
  if type(columns) == str { columns } else if type(columns) == int { "repeat(" + str(columns) + ", minmax(0, 1fr))" } else if type(columns) == array {
    columns.map(c => if c == auto { "auto" } else if type(c) == fraction { "minmax(0, " + repr(c) + ")" } else if type(c) == length { str(c.pt()) + "pt" } else { "minmax(0, 1fr)" }).join(" ")
  } else { "minmax(0, 1fr)" }
}

// Side-by-side figures: `#fig-grid(columns: 2, image(..), image(..))`. Columns as in `grid` (or a CSS template string); collapses to one column on narrow screens.
// Grids without `auto` columns (plain image rows) stack into one column on narrow screens; grids with label columns keep their shape.
#let fig-grid(columns: 2, gap: none, ..cells) = {
  let tpl = _grid-template(columns)
  let gap = if type(gap) == length { str(gap.pt()) + "pt" } else { gap }
  html.div(
    class: "fig-grid" + if not tpl.contains("auto") { " stack" },
    style: "grid-template-columns: " + tpl + if gap != none { "; gap: " + gap },
    cells.pos().map(c => html.div(class: "cell", c)).join(),
  )
}

// Typst's HTML export drops `grid`, `align`, `rotate` and `columns` together with their content; these rules keep the content.
#let _grid(it) = fig-grid(
  columns: it.columns,
  ..it.children.filter(c => c.func() not in (grid.hline, grid.vline)).map(c => if c.func() == grid.cell { c.body } else { c }),
)
#let _align(it) = {
  let a = it.alignment
  let h = if a.axis() == "horizontal" { a } else if a.axis() == none { a.x } else { none }
  if h in (center, right, end) { html.div(class: "align-" + repr(h), it.body) } else { it.body }
}

// Footnote tooltips: hovering, focusing or tapping a footnote marker shows the note (copied from Typst's end-of-post list) in one shared tooltip clamped to the viewport. On touch, the first tap opens the tooltip and a second tap follows the link.
#let _fn-script = "(function(){
var tip=null,cur=null,coarse=matchMedia('(hover: none)').matches;
function note(a){var id=decodeURIComponent((a.getAttribute('href')||'').slice(1));return id?document.getElementById(id):null;}
function hide(){if(tip)tip.hidden=true;if(cur)cur.removeAttribute('aria-describedby');cur=null;}
function show(a){var li=note(a);if(!li)return;
 if(!tip){tip=document.createElement('div');tip.className='fn-tip';tip.id='fn-tip';tip.setAttribute('role','tooltip');document.body.appendChild(tip);}
 tip.innerHTML='';var c=li.cloneNode(true);c.querySelectorAll('[role=doc-backlink]').forEach(function(b){b.remove();});
 while(c.firstChild)tip.appendChild(c.firstChild);tip.hidden=false;cur=a;a.setAttribute('aria-describedby','fn-tip');
 var r=a.getBoundingClientRect(),m=12,w=tip.offsetWidth,h=tip.offsetHeight;
 var x=Math.max(m,Math.min(r.left+r.width/2-w/2,innerWidth-m-w)),y=r.bottom+8;
 if(y+h>innerHeight-m&&r.top-8-h>m)y=r.top-8-h;
 tip.style.left=x+'px';tip.style.top=y+'px';}
document.querySelectorAll('sup[role=doc-noteref] a').forEach(function(a){
 if(!coarse){a.addEventListener('mouseenter',function(){show(a);});a.addEventListener('mouseleave',hide);
 a.addEventListener('focus',function(){show(a);});a.addEventListener('blur',hide);}
 a.addEventListener('click',function(e){if(coarse&&cur!==a){e.preventDefault();show(a);}});});
document.addEventListener('click',function(e){if(cur&&!e.target.closest('sup[role=doc-noteref]'))hide();});
document.addEventListener('keydown',function(e){if(e.key==='Escape')hide();});
addEventListener('scroll',hide,{passive:true});addEventListener('resize',hide);
})();"

// Page shell shared by posts and pages. `depth` is the number of directories between the page and its mode's root (posts: 1).
#let _shell(title: none, description: none, current: none, depth: 0, lang: "en", after-main: none, body) = {
  let up = "../" * depth
  let site-root = if consulting { up + "../" } else { up }
  let other-root = if consulting { site-root } else { up + "consulting/" }
  let site-title = if consulting { "Borlandux" } else { person.name }
  set document(
    title: if title == none { site-title } else { title + " — " + site-title },
    description: description,
  )
  set text(lang: lang)
  set quote(block: true)
  show math.equation: _eq
  show grid: _grid
  show align: _align
  show rotate: it => it.body
  show columns: it => it.body
  // A link to a post that isn't released yet (scheduled or draft) renders as plain text until the post is published.
  show link: it => {
    if type(it.dest) != str or it.dest.contains(":") { return it }
    let file = it.dest.split("#").first().split("/").last()
    if not file.ends-with(".html") { return it }
    let slug = file.slice(0, file.len() - 5)
    if slug in all-slugs and slug not in listed-slugs { html.span(class: "unreleased", title: _t(lang).soon, it.body) } else { it }
  }
  // Link image files instead of inlining them as data URIs; root-absolute "/assets/..." becomes relative to the page.
  show image: it => if type(it.source) == str and it.source.starts-with("/assets/") {
    html.elem("img", attrs: (src: up + it.source.slice(1), alt: if it.alt == none { "" } else { it.alt }, loading: "lazy"))
  } else { it }

  html.elem("link", attrs: (rel: "stylesheet", href: site-root + "style.css"))
  html.elem("link", attrs: (rel: "alternate", type: "application/atom+xml", title: site-title, href: site-root + "feed.xml"))
  html.header(class: "site-header" + if consulting { " consulting" }, {
    html.a(class: "site-name", href: up + "index.html", if consulting {
      html.span(class: "wordmark", "Borlandux")
      html.span(class: "byline", person.name)
    } else { person.name })
    let item(key, label, href) = html.a(
      href: href,
      ..if current == key { (class: "active", aria-current: "page") },
      label,
    )
    html.nav(aria-label: "Site", {
      item("blog", "Blog", up + "index.html")
      item("about", if consulting { "Consulting" } else { "About" }, up + "about.html")
      if consulting { item(none, "Personal", other-root + "index.html") } else if consulting-tab {
        item(none, "Consulting", other-root + "about.html")
      }
    })
  })
  html.main(body)
  after-main
  html.elem("script", _fn-script)
  html.footer(class: "site-footer", {
    let sep = html.span(class: "sep", "·")
    if consulting {
      [#company.name #sep #link("mailto:" + company.email, company.email) #sep #link(person.linkedin)[LinkedIn]]
    } else {
      [#person.name #sep #link("mailto:" + person.email, person.email) #sep #link(person.github)[GitHub] #sep #link(person.linkedin)[LinkedIn]]
    }
  })
}

// Plain page (home, about). `depth` as in `_shell`.
#let page(title: none, current: none, depth: 0, description: none, lang: "en", body) = _shell(
  title: title,
  description: description,
  current: current,
  depth: depth,
  lang: lang,
  html.article(class: "page", {
    if title != none { html.h1(title) }
    body
  }),
)

#let _series-nav(series, part, lang) = {
  let in-series(entries) = entries.filter(e => e.series == series and e.part != none).sorted(key: e => e.part)
  let released = in-series(catalog())
  // The total counts scheduled parts too, so part 2 of 14 reads as such the week it comes out.
  let planned = in-series(catalog-all()).filter(e => e.status == "published" and e.date != none)
  if released.len() == 0 { return (none, none) }
  let t = _t(lang)
  let pos = released.position(e => e.part == part)
  let head = html.p(class: "series", {
    html.span(class: "series-name", series-name(series, lang))
    [ · ]
    (t.part)(part, calc.max(planned.len(), released.len()))
  })
  let foot = if pos == none { none } else {
    let prev = if pos > 0 { released.at(pos - 1) }
    let next = if pos + 1 < released.len() { released.at(pos + 1) }
    let upcoming = if next == none { planned.find(e => e.part > part) }
    html.nav(class: "series-nav", aria-label: series-name(series, lang), {
      if prev != none {
        html.a(class: "prev", href: prev.slug + ".html", {
          html.span(class: "dir", "← " + t.prev)
          html.span(class: "t", prev.title)
        })
      }
      if next != none {
        html.a(class: "next", href: next.slug + ".html", {
          html.span(class: "dir", t.next + " →")
          html.span(class: "t", next.title)
        })
      } else if upcoming != none {
        html.div(class: "next upcoming", {
          html.span(class: "dir", t.upcoming + " · " )
          format-date(upcoming.date, lang)
          html.span(class: "t", upcoming.title)
        })
      }
    })
  }
  (head, foot)
}

// Post template. Every post file does:
//   #import "../lib.typ": *
//   #let meta = (title: str, date: "YYYY-MM-DD" | none, series: str | none, part: int | none, summary: content | none, status: "published" | "draft" | "stub", lang: "es" | "en")
//   #show: post.with(..meta)
#let post(
  title: none,
  date: none,
  series: none,
  part: none,
  summary: none,
  status: "draft",
  lang: "es",
  body,
) = {
  let (series-head, series-foot) = if series != none and part != none { _series-nav(series, part, lang) } else { (none, none) }
  _shell(
    title: title,
    description: if summary != none { _plain(summary).trim() },
    current: "blog",
    depth: 1,
    lang: lang,
    after-main: series-foot,
    html.article(class: "post", {
      html.header(class: "post-header", {
        series-head
        html.h1(title)
        let bits = (
          if date != none { format-date(date, lang) },
          status-badge(status, lang),
        ).filter(b => b != none)
        if bits.len() > 0 { html.p(class: "post-meta", bits.join([ ])) }
      })
      body
    }),
  )
}

// Home page post list, newest first (the Makefile passes published slugs in that order); series posts carry their series and part.
// Summaries come from importing each post's `meta`, so only slugs that built are listed.
#let post-index() = {
  let entry(m) = {
    let lang = m.at("lang", default: "es")
    html.li(class: "entry", {
      let series = m.at("series", default: none)
      if series != none and m.at("part", default: none) != none {
        html.p(class: "series-label", series-name(series, lang) + " · " + str(m.part))
      }
      html.p(class: "entry-title", html.a(href: "posts/" + m.slug + ".html", m.title))
      if m.at("date", default: none) != none { html.p(class: "entry-date", format-date(m.date, lang)) }
      if m.at("summary", default: none) != none { html.p(class: "entry-summary", m.summary) }
    })
  }
  html.ul(class: "post-list", listed-slugs.map(s => {
    import "/posts/" + s + ".typ": meta
    entry(meta + (slug: s))
  }).join())
}

// Optional helper for posts: the shared bibliography.
#let references(title: auto, ..args) = bibliography("/refs.bib", title: title, ..args)
