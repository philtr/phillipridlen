# Repo Guide for Agents

Quick orientation to the repo structure and where common work happens.

## Top-level
- `src/`: Nanoc site content and layouts.
  - `src/posts/`: Blog posts (notes/links). Posts now live under `YYYY/MM/`.
  - `src/layouts/`: ERB/Haml layouts.
  - `src/pages/`: Static pages and feeds.
  - `src/css/`, `src/images/`: Site assets.
- `lib/`: Nanoc helpers, preprocessors, and custom data sources.
- `config/`: Nanoc compilation rules (blog/photos).
- `bin/`: One-off scripts (e.g., migrations).
- `spec/`: Ruby specs for helper code.
- `Procfile`: App/dev commands (currently for nanoc build/watch).

## BlogAdmin app
- Standalone repo: `https://github.com/philtr/blog-admin`
- The app is optional and targets this repo's content layout under `src/posts`, `src/drafts`, and `src/photos`.
- Keep usage and setup instructions in the standalone repo rather than duplicating them here.

## Nanoc site
- Rules: `config/rules/blog.rb`, `config/rules/photos.rb`
- Preprocessors: `lib/preprocessors/blog.rb`
- Helpers: `lib/helpers.rb`
- Site config: `nanoc.yaml`

## Date + file layout conventions
- Blog posts: `src/posts/{notes,links}/YYYY/MM/slug.md` or `.../slug/index.md`
- YAML `date` is ISO8601 with time; default 9am CT if date-only.
- BlogAdmin writes YAML dates and moves posts into `YYYY/MM/` folders.

## Useful scripts
- `bin/migrate_posts_to_yaml_dates.rb`: backfills YAML dates and moves posts.
- `bin/fix_date_prefixed_slugs.rb`: cleans up date-prefixed slugs.

## Notes
- Content should avoid non-ASCII unless existing files already use it.

## Ruby-only instructions
These apply only when changing Ruby files.
- Format with Standard Ruby: `bundle exec standardrb --fix`.
- Ensure no StandardRB violations: `bundle exec standardrb`.
- Run tests: `bundle exec rspec`.
