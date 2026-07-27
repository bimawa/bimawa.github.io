# Blog Posts: bimawa.net

## Workflow (Russian-first)

```
1. just post <slug> "Заголовок"       # → content/blog/…slug.ru.md
2. ✏️  Write content in Russian
3. just translate <slug>              # → .md with [EN] markers
4. ✏️  Translate body to English
5. just build                         # Verify build
6. just deploy "docs: add <slug>"    # Commit & push
```

## File Naming

### Blog Posts (only type produced manually)

Format: `YYYY-MM-DDTHH:MM:SSZ_slug.md` + `.ru.md`

```
blog/2026-01-08T12:00:00Z_forge-ai-project-management.md
blog/2026-01-08T12:00:00Z_forge-ai-project-management.ru.md
```

Rules:
- **Always paired**: every post has `.md` AND `.ru.md`
- **Date in filename** = UTC ISO 8601: `date -u +%Y-%m-%dT%H:%M:%SZ`
- **Slug**: kebab-case, URL-friendly (e.g. `my-new-feature`)
- **_index.md / _index.ru.md**: always exist in `content/blog/`
- **DO NOT** create blog posts with date-only filename (no time) — must match ISO 8601 with time

### Project News (created via justfile)

Format: `content/projects/Name/YYYY-MM-DDTHH:MM:SSZ_slug.ru.md`

```
project-post TradeTerminal v2-release "Выпущена версия 2.0"
→ projects/TradeTerminal/2026-07-10T09:06:16Z_v2-release.ru.md
→ project-translate TradeTerminal v2-release
→ projects/TradeTerminal/2026-07-10T09:06:16Z_v2-release.md
```

## Front Matter Template

### Blog Post (correct structure)
```toml
+++
title = "Заголовок поста"
date = 2026-01-08T12:00:00Z
description = "Краткое описание для превью"
[taxonomies]
tags = ["ai", "productivity", "tools"]
+++
```

### Rules
- **title**: Required. RU version = Russian, EN version = English.
- **date**: ISO 8601 datetime. MUST match filename timestamp exactly.
- **description**: Required, non-empty. Short preview text (1-2 sentences).
- **tags**: In `[taxonomies]` section. Array of strings. English only (Zola taxonomy requirement).
- **template**: DO NOT set. Zola uses default page template.
- **NO extra fields**: No `author`, `sort_by`, `paginate_by` in blog posts (section-only fields).

### Project Detail Article (correct structure)
```toml
+++
title = "Заголовок статьи"
description = "Краткое описание"
date = 2026-01-31T00:00:00Z
template = "project.html"
[taxonomies]
tags = ["rust", "cli", "trading"]
+++
```

### Rules
- `template = "project.html"` required
- Tags in `[taxonomies]` section (like blog posts, NOT inline in body)

## Naming Gotchas (from Audit)

### Slug skew: listing ≠ detail
```
WRONG:  projects/2026-02-20_tradeterminal.md  →  projects/TradeTerminal/trade_terminal
                                              ↑ listing snake          ↑ detail snake
Both use different slugs for the same project. Zola deduplicates by section.
→ Just ensure listing `link` in [extra] correctly points to /projects/Name/
```

### Date mismatch: filename ≠ front matter
```
WRONG:  filename: 2025-11-15_wireDeskVR.md  →  front matter: date = 2023-05-15
```
→ **Always match filename date to front matter date**

### Tags placement
```
WRONG:  tags in main body (no [taxonomies])
RIGHT:  [taxonomies]\ntags = [...]
```

### Directory name casing
```
Project dirs: PascalCase (TradeTerminal, SyncLProj)
NOT:         lowercase (netmonrs — inconsistent, should be NetMonRS)
```

## Translation Workflow

### `just translate <slug>` does:
1. Finds `content/blog/*_<slug>.ru.md`
2. Copies to `.md` (EN version)
3. Marks title with `[EN]` suffix
4. Marks description with `[EN: translate]`
5. Body content remains as-is (needs manual translation)

### Translation checklist:
- [ ] Translate **title** (remove [EN] suffix)
- [ ] Translate **description** (replace [EN: translate])
- [ ] Translate **body** content
- [ ] Keep **tags** in English (don't translate)
- [ ] Keep **date** unchanged
- [ ] Verify build: `just build`

## Verification

Before deploy:
```
just build       # Should complete without errors
just check       # Verify all internal links
just list-posts  # Confirm new post appears (both languages)
```

## Common Mistakes to Avoid

1. **Missing RU/EN pair**: Always create both. Never commit a post in one language only.
2. **Date mismatch**: Filename date must match front matter date.
3. **Wrong tags section**: Use `[taxonomies]`, not inline tags or `[extra]`.
4. **Extra section fields**: `sort_by`, `paginate_by` belong in `_index.md`, not individual posts.
5. **Missing description**: Required field. 1-2 sentences for preview cards.
6. **Double slashes**: When editing base.html language switcher, avoid chained `replace` producing `//`.
7. **Typo in tags**: Verify tag spelling — tags are taxonomy keys, "Nerworking" vs "Networking" matters.
