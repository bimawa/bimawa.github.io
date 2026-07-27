# Structure: bimawa.net Repository

## Directory Layout

```
.
├── .env                 # Genie hooks config (skip_tests, allow_main_push)
├── .gitignore           # Ignores public/, .DS_Store, node_modules/, .auto-claude/
├── AGENTS.md            # Genie Master Genie framework (420 lines, loaded by CLAUDE.md)
├── CLAUDE.md            # → @AGENTS.md alias
├── justfile              # Task runner (build, serve, post, project, etc.)
├── config.toml          # Zola site config (base_url, theme, languages)
├── content/             # All site content (see tech.md for structure)
├── templates/           # Zola Tera templates (base.html, index.html, project.html, etc.)
├── sass/                # Sass sources → compiled CSS
├── static/              # Static assets (images, fonts, JS, custom CSS)
├── public/              # Build output (gitignored)
├── themes/              # Git submodule: terminimal theme
├── completions/         # Fish shell completions for just
│   └── just.fish
├── docs_notIndex/       # Private documents (gitignored PDFs)
├── .genie/              # Genie orchestration framework
│   ├── PROJECT.md       # Project context (tech stack, conventions, gotchas)
│   ├── spells/          # Genie spell library
│   ├── agents/          # Agent definitions (code, create, QA, etc.)
│   └── ...
└── .kiro/               # Kiro project steering (this directory)
    ├── steering/        # Persistent project knowledge
    └── specs/           # Specifications
```

## Content Naming

### Blog Posts
```
content/blog/YYYY-MM-DDTHH:MM:SSZ_slug.md
content/blog/YYYY-MM-DDTHH:MM:SSZ_slug.ru.md
```
- Slug: kebab-case (e.g. `my-new-feature`)
- Date + time in filename and front matter match exactly
- Tags in `[taxonomies]` section

### Project Cards
```
content/projects/YYYY-MM-DD_shortname.md
content/projects/YYYY-MM-DD_shortname.ru.md
```
- Slug: lowercased (e.g. `tradeterminal`, `rfidreader`)
- Date only in filename, quoted date `"YYYY-MM-DD"` in front matter
- Template: `project.html`
- Tags in `[extra]` section
- All fields in `[extra]`: tags, author, link, description

### Project Detail Articles
```
content/projects/ProjectName/YYYY-MM-DDTHH:MM:SSZ_article.md
content/projects/ProjectName/YYYY-MM-DDTHH:MM:SSZ_article.ru.md
```
- Slug: snake_case (e.g. `trade_terminal`, `rfid_reader`)
- Date + time in filename and front matter match exactly
- Template: `project.html`
- Tags in `[taxonomies]` section (like blog posts)

### Project _index
```
content/projects/ProjectName/_index.md
content/projects/ProjectName/_index.ru.md
```
- Template: `index<Name>.html` (custom for each project)
- Fields: title, sort_by=date, paginate_by=10

## Template Mappings

| Content Area | Template |
|---|---|
| Home page (root `_index.md`) | `index.html` |
| Blog section | `index.html` |
| Blog post | default (Zola page template) |
| Projects section | `projects.html` |
| Project card | `project.html` |
| Project detail `_index` | `index<Name>.html` (custom) |
| Project detail article | `project.html` |
| Archive | `archive.html` |
| 404 | `404.html` |
| Tags list | `tags/list.html` |
| Tag single | `tags/single.html` |

## Conventions

- **Every content file has RU + EN pair**. Never create one without the other.
- **_index.md + _index.ru.md** required in every section directory.
- **Project cards** list at root of `content/projects/` with `link` pointing to `/projects/Name/`.
- **Custom project templates** in `templates/index<Name>.html` — one per project detail section.
