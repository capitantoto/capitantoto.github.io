# capitantoto.github.io

Personal site and blog of Gonzalo Barrera Borla, written in Typst and built with its experimental HTML export. Every page is a static HTML file with no external requests.

## Layout

- `posts/<slug>.typ` — one file per post. Each defines `#let meta = (title, date, series, part, summary, status, lang)` and then `#show: post.with(..meta)`.
- `posts.typ` — the ordered list of published slugs. A post not listed there is not built.
- `pages/` — home (post index) and About.
- `lib.typ` — page template: header, series navigation, math as inline SVG, footnote tooltips, image and grid handling.
- `fermat.typ` — macros shared by the Fermat-distance series; `refs.bib` its bibliography.
- `style.css`, `assets/` — styles, images and data files.

## Build

Requires Typst 0.15.1.

- `make` — build the site into `out/`; open `out/index.html` directly, no server needed.
- `make clean` — remove `out/` and `build/`.
- A single post: `typst compile --features html --root . posts/<slug>.typ /tmp/<slug>.html`.

Locally, a post that fails to compile is skipped and logged in `build/log/`; in CI any compile error fails the build.

The template also supports a consulting mode (`make MODES="personal consulting"`), which is not published.

## Deploy

`.github/workflows/pages.yml` builds and publishes `out/` to GitHub Pages on every push to `master`. Pages must be set to deploy from GitHub Actions (Settings → Pages → Source).
