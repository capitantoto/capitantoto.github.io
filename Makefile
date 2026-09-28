# Builds the blog with Typst's experimental HTML export, one page per compile:
#   out/                personal mode
#   out/consulting/     consulting mode (same posts, consulting About and contact), only with `make MODES="personal consulting"`
# Every posts/<slug>.typ is a post (files starting with `_` are ignored). A post is published once its status is "published" and its date is on or before TODAY (Buenos Aires calendar); the daily CI build releases scheduled posts on their date.
# A post that fails to evaluate or compile is skipped with a warning, so `make` succeeds while posts are in progress.
# Stages: (1) build/meta/<slug>.json per post via `typst eval`, (2) pages of due posts, (3) index, about and feed.xml, listing only posts whose pages built.

TYPST  ?= typst
FLAGS   = --features html --root . --diagnostic-format short $(TAB)
COMMON := lib.typ fermat.typ refs.bib
MODES  ?= personal
TAB    := $(if $(filter consulting,$(MODES)),--input consulting-tab=true)
comma  := ,
empty  :=
space  := $(empty) $(empty)
dir_personal   := out
dir_consulting := out/consulting

TODAY ?= $(shell TZ=America/Argentina/Buenos_Aires date +%F)
HAVE  := $(basename $(notdir $(filter-out posts/_%,$(wildcard posts/*.typ))))

.PHONY: all meta posts pages assets clean
all:
	@$(MAKE) --no-print-directory meta
	@$(MAKE) --no-print-directory posts
	@$(MAKE) --no-print-directory pages assets
	@echo "built: $(foreach m,$(MODES),$(dir_$(m))/index.html)"

# Stage 1: per-post metadata (summary omitted: it is content, the index imports it directly).
meta: $(HAVE:%=build/meta/%.json)
build/meta/%.json: posts/%.typ $(COMMON)
	@mkdir -p $(@D) build/log
	@if $(TYPST) eval $(FLAGS) --target html --format json \
	    'import "/posts/$*.typ": meta; meta.pairs().filter(p => p.first() != "summary").to-dict()' \
	    > $@.tmp 2> build/log/$*.meta.log; then mv $@.tmp $@; \
	else rm -f $@.tmp $@; echo "skip (meta failed): $* — see build/log/$*.meta.log"; fi

# Stages 2 and 3 run in sub-makes, after stage 1 has decided which slugs are listed.
# ALL: posts with metadata (series totals and upcoming parts); DUE: published and dated today or earlier, newest first.
ALL  := $(foreach s,$(HAVE),$(if $(wildcard build/meta/$(s).json),$(s)))
DUE  := $(shell python3 scripts/posts.py due $(TODAY) $(ALL))
BUILT := $(foreach s,$(DUE),$(if $(filter $(words $(MODES)),$(words $(foreach m,$(MODES),$(wildcard $(dir_$(m))/posts/$(s).html)))),$(s)))

# Rebuilds dependents only when the listed set changes.
build/list-%: FORCE
	@mkdir -p $(@D)
	@echo '$($*)' | cmp -s - $@ || echo '$($*)' > $@
FORCE:
.PRECIOUS: build/list-%

# compile(mode, listed slugs, source, output, log name)
define compile
	@mkdir -p $(dir $4) build/log
	@if $(TYPST) compile $(FLAGS) --input mode=$1 --input posts=$(subst $(space),$(comma),$(strip $2)) --input all=$(subst $(space),$(comma),$(strip $(ALL))) $5 $3 $4 2> build/log/$6.log; \
	then :; else rm -f $4; echo "skip (compile failed): $4 — see build/log/$6.log"; fi
endef

POST_DEPS = $(COMMON) $(ALL:%=build/meta/%.json) build/list-ALL build/list-DUE
posts: $(foreach m,$(MODES),$(DUE:%=$(dir_$(m))/posts/%.html))
out/posts/%.html: posts/%.typ $(POST_DEPS)
	$(call compile,personal,$(DUE),$<,$@,--input slug=$*,$*.personal)
out/consulting/posts/%.html: posts/%.typ $(POST_DEPS)
	$(call compile,consulting,$(DUE),$<,$@,--input slug=$*,$*.consulting)

PAGES := index about
PAGE_DEPS = $(COMMON) $(BUILT:%=posts/%.typ) build/list-BUILT
pages: $(foreach m,$(MODES),$(PAGES:%=$(dir_$(m))/%.html)) out/style.css out/feed.xml
out/consulting/%.html: pages/%.typ $(PAGE_DEPS)
	$(call compile,consulting,$(BUILT),$<,$@,,page-$*.consulting)
out/%.html: pages/%.typ $(PAGE_DEPS)
	$(call compile,personal,$(BUILT),$<,$@,,page-$*.personal)

out/feed.xml: scripts/posts.py build/list-BUILT $(BUILT:%=build/meta/%.json)
	@mkdir -p $(@D)
	python3 scripts/posts.py feed $(TODAY) $@ $(BUILT)

out/style.css: style.css
	@mkdir -p $(@D)
	cp $< $@

# Post links to files under assets/ are relative (../assets/...), so each mode gets its own copy. static/ (404 page, redirects from old URLs) is copied to the site root.
assets:
	@$(foreach m,$(MODES),mkdir -p $(dir_$(m))/assets && rsync -a --delete assets/ $(dir_$(m))/assets/;)
	@rsync -a static/ out/

clean:
	rm -rf out build
