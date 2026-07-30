# Ruby dependency management in one breath: Gemfile declares gems, `bundle
# install` resolves + installs them into Gemfile.lock, `bundle exec` runs a
# command against exactly the locked versions (never bare global `jekyll`).
# Absolute path to Homebrew ruby's bundler — Apple's /usr/bin/bundle is a
# fossilized 2.6 that can't load this lockfile. (Also dodges make 3.81's
# no-shell fast path, which ignores `export PATH` for one-command recipes.)
BUNDLE := /opt/homebrew/opt/ruby/bin/bundle

.DEFAULT_GOAL := serve
.PHONY: serve build deps clean

# jekyll serve = build + local HTTP + rebuild-on-save; --livereload also
# refreshes the browser. Same engine GitHub Pages runs on every push.
serve: deps
	$(BUNDLE) exec jekyll serve --livereload

# Static output lands in _site/ — never edit it, never commit it.
build: deps
	$(BUNDLE) exec jekyll build

# Re-resolve only when Gemfile changed; the lock is the reproducible truth.
Gemfile.lock: Gemfile
	$(BUNDLE) install
deps: Gemfile.lock

clean:
	rm -rf _site .jekyll-cache
