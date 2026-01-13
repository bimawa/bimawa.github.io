# Project Context

## Tech Stack
- **Static Site Generator**: Zola (Rust-based, NOT Hugo)
- **Theme**: Terminimal
- **Deployment**: GitHub Pages via GitHub Actions

## Environment
- **Shell**: fish (NOT zsh)
- **OS**: macOS

## Git Hooks Configuration
- Custom wrapper in `.git/hooks/pre-push`
- Auto-exports: `GENIE_SKIP_TESTS=1`, `GENIE_ALLOW_MAIN_PUSH=1`
- No pnpm/npm tests (this is not a Node.js project)

## Content Rules
- **Tags**: Must be in English (Zola taxonomy requirement)
- **Blog posts**: Located in `content/blog/`
- **Multilingual**: English + Russian (ru)

## Known Issues
- Don't commit `.genie/state/` files (ephemeral token usage data)
- CSS paths in JS should be relative, not absolute (for path validator)
