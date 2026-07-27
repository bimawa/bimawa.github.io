# Tech Stack: bimawa.net

## Core Stack

| Layer | Technology | Version/Notes |
|---|---|---|
| SSG | Zola | 0.22.0. Rust-based. NOT Hugo. |
| Theme | Terminimal | Custom templates in `templates/` |
| Language | Rust (Zola) | All templates in HTML + Tera |
| CSS | Sass → compiled | `sass/` → `public/`. Manual CSS in `static/` |
| Search | elasticlunr.js | `public/elasticlunr.min.js`. Indexes `search_index.*.js` |
| Shell | fish | NOT bash, NOT zsh. `completions/just.fish` |
| Task runner | just | `justfile` at repo root. 1.43.1 |

## Deployment

- **Host**: GitHub Pages (`bimawa.github.io` → custom domain `bimawa.net`)
- **Trigger**: Push to `main` branch
- **Action**: `shalzz/zola-deploy-action@v0.21.0` in `.github/workflows/deploy.yml`
- **Build command**: `zola build` (outputs to `public/`, gitignored)

## Content Architecture

```
content/
├── _index.md             # Root EN (template=index.html)
├── _index.ru.md          # Root RU
├── blog/                 # Blog section
│   ├── _index.md         # Blog EN index (paginate_by=10)
│   ├── _index.ru.md      # Blog RU index
│   ├── YYYY-MM-DDTHH:MM:SSZ_slug.md        # Post EN
│   └── YYYY-MM-DDTHH:MM:SSZ_slug.ru.md     # Post RU
├── projects/             # Projects section
│   ├── _index.md         # Projects EN (template=projects.html)
│   ├── _index.ru.md      # Projects RU
│   ├── YYYY-MM-DD_name.md        # Project card EN
│   ├── YYYY-MM-DD_name.ru.md     # Project card RU
│   └── ProjectName/      # Detail section (PascalCase)
│       ├── _index.md     # Detail EN (custom template)
│       ├── _index.ru.md  # Detail RU
│       ├── YYYY-MM-DDTHH:MM:SSZ_article.md       # Article EN
│       └── YYYY-MM-DDTHH:MM:SSZ_article.ru.md    # Article RU
├── about.md / about.ru.md
├── contacts.md / contacts.ru.md
├── cv.md / cv.ru.md
├── offer.md / offer.ru.md
├── privacy.md / privacy.ru.md
├── terms.md / terms.ru.md
├── archive.md / archive.ru.md
```

## Key Conventions

- **Bilingual pairs**: Every `.md` has `.ru.md`. Both mandatory.
- **Date format in filenames**: ISO 8601 datetime `YYYY-MM-DDTHH:MM:SSZ_` for articles, date-only `YYYY-MM-DD_` for project cards.
- **Date format in front matter**: ISO 8601 datetime string for articles, quoted date `"YYYY-MM-DD"` for project cards.
- **Slug convention**: For blog posts use kebab-case; for project cards use lowercase-noconnect; for detail articles use snake_case.
- **Tags**: In `[taxonomies]` for blog posts; in `[extra]` for project cards; in main body (no section) for some detail articles.
- **Project directory name**: PascalCase (e.g. `TradeTerminal`, `WireDeskVR`).
- **Custom templates**: Each project detail section has its own template `index<Name>.html` in `templates/`.

## Infrastructure

- **Framework orchestration**: Genie in `.genie/` (AGENTS.md via CLAUDE.md reference)
- **Config**: Zola TOML in `config.toml`. No package.json. No Node.js.
- **CI/CD**: GitHub Actions. No manual build steps needed.
