"""Post selection and Atom feed for the Makefile, from the metadata in build/meta/<slug>.json.

    python3 scripts/posts.py due  <today> <slug>...            published posts dated on or before <today>, newest first
    python3 scripts/posts.py feed <today> <out.xml> <slug>...   Atom feed of those posts
"""

import json
import sys
from pathlib import Path
from xml.sax.saxutils import escape

SITE_URL = "https://capitantoto.github.io/"
AUTHOR = "Gonzalo Barrera Borla"
UTC_OFFSET = "-03:00"  # dates are Buenos Aires calendar days


def load(slugs):
    return [dict(json.loads(Path(f"build/meta/{slug}.json").read_text()), slug=slug) for slug in slugs]


def due(today, slugs):
    posts = [post for post in load(slugs) if post.get("status") == "published" and post.get("date") and post["date"] <= today]
    return sorted(posts, key=lambda post: (post["date"], post.get("part") or 0), reverse=True)


def timestamp(date):
    return f"{date}T00:00:00{UTC_OFFSET}"


def feed(posts):
    updated = timestamp(posts[0]["date"]) if posts else timestamp("1970-01-01")
    entries = "".join(
        f"""  <entry>
    <title>{escape(post["title"])}</title>
    <link href="{SITE_URL}posts/{post["slug"]}.html"/>
    <id>{SITE_URL}posts/{post["slug"]}.html</id>
    <published>{timestamp(post["date"])}</published>
    <updated>{timestamp(post["date"])}</updated>
  </entry>
"""
        for post in posts
    )
    return f"""<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>{escape(AUTHOR)}</title>
  <link href="{SITE_URL}"/>
  <link rel="self" href="{SITE_URL}feed.xml"/>
  <id>{SITE_URL}</id>
  <updated>{updated}</updated>
  <author><name>{escape(AUTHOR)}</name></author>
{entries}</feed>
"""


if __name__ == "__main__":
    command, today, *rest = sys.argv[1:]
    if command == "due":
        print(" ".join(post["slug"] for post in due(today, rest)))
    elif command == "feed":
        out_path, *slugs = rest
        Path(out_path).write_text(feed(due(today, slugs)))
    else:
        sys.exit(f"unknown command: {command}")
