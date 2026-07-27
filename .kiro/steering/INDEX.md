# bimawa.net — Project Steering

## Navigation

| File | What it covers |
|---|---|
| `product.md` | Purpose, audience, content types |
| `tech.md` | Tech stack, deployment, architecture |
| `structure.md` | Directory layout, naming, template mapping |
| `blog-posts.md` | **Blog post creation workflow, conventions, gotchas** |

## Specs

| File | What it covers |
|---|---|
| `.kiro/specs/audit-2026-07.md` | Full audit findings (blockers → minor) |

## Core Rules

1. **Bilingual pairs** — every `.md` has `.ru.md`. Always.
2. **Russian-first** — write in RU, translate to EN.
3. **Zola, not Hugo** — Rust-based SSG. No Node/NPM.
4. **fish shell** — completions, workflow scripts.
5. **just task runner** — use `just` for content creation.
6. **GitHub Pages deploy** — push to main → auto-deploy.
