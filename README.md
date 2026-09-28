# capitantoto.github.io

Personal site and blog of Gonzalo Barrera Borla, written in Typst and built with its experimental HTML export. Every page is a static HTML file with no external requests.

## Layout

- `posts/<slug>.typ` — one file per post; files starting with `_` are ignored. Each defines `#let meta = (title, date, series, part, summary, status, lang)` and then `#show: post.with(..meta)`.
- `scripts/posts.py` — picks the posts to publish and writes the Atom feed (`feed.xml`).
- `pages/` — home (post index) and About.
- `lib.typ` — page template: header, series navigation, math as inline SVG, footnote tooltips, image and grid handling.
- `fermat.typ` — macros shared by the Fermat-distance series; `refs.bib` its bibliography.
- `style.css`, `assets/` — styles, images and data files.

## Publishing

A post is published when its `status` is `"published"` and its `date` (`"YYYY-MM-DD"`, Buenos Aires calendar) is today or earlier. Drafts (`"draft"`, `"stub"`) and future-dated posts are not built. The home page lists published posts newest first.

To schedule a post, give it a future date: the daily CI build releases it that morning. Until then, links to it from other posts render as plain text, and the previous part of its series announces it with its date. Preview a future state locally with `make TODAY=YYYY-MM-DD`.

GitHub disables scheduled workflows in a repository with no activity for 60 days; each scheduled run calls the workflow-enable API to keep the schedule alive. If a weekly post fails to appear, check that the `pages` workflow is still enabled (Actions tab).

## Build

Requires Typst 0.15.1.

- `make` — build the site into `out/`; open `out/index.html` directly, no server needed. `make TODAY=YYYY-MM-DD` builds the site as it will look on that date.
- `make clean` — remove `out/` and `build/`.
- A single post: `typst compile --features html --root . posts/<slug>.typ /tmp/<slug>.html`.

Locally, a post that fails to compile is skipped and logged in `build/log/`; in CI any compile error fails the build.

The template also supports a consulting mode (`make MODES="personal consulting"`), which is not published.

## Deploy

`.github/workflows/pages.yml` builds and publishes `out/` to GitHub Pages on every push to `master` and daily at 08:00 Buenos Aires time. Pages must be set to deploy from GitHub Actions (Settings → Pages → Source).
