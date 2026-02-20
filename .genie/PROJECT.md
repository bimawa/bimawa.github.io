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

### Project Pages Structure
Projects have two locations with language-specific files:

1. **Short description** in `content/projects/`:
   - `YYYY-MM-DD_projectname.md` (English)
   - `YYYY-MM-DD_projectname.ru.md` (Russian)
   - Both files required for multilingual support

2. **Full article** in `content/projects/ProjectName/`:
   - `YYYY-MM-DDTHH:MM:SSZ_project_name.md` (English)
   - `YYYY-MM-DDTHH:MM:SSZ_project_name.ru.md` (Russian)
   - `_index.ru.md` for Russian index

**Important**: Always create BOTH language versions when adding new projects!

## Known Issues
- Don't commit `.genie/state/` files (ephemeral token usage data)
- CSS paths in JS should be relative, not absolute (for path validator)

## Git Hooks Setup
- **Pre-commit**: REMOVED (was trying to find `.genie/scripts/` locally, not needed for blog)
- **Pre-push**: Custom wrapper in `.git/hooks/pre-push` that calls `.git/hooks/pre-push.original`
  - Wrapper exports: `GENIE_SKIP_TESTS=1`, `GENIE_ALLOW_MAIN_PUSH=1`
  - Original hook is symlink to global Genie: `/opt/homebrew/lib/node_modules/automagik-genie/.genie/scripts/hooks/pre-push.cjs`

## Important: Don't Add `.genie` to .gitignore
- Never add `.genie` or `.genie/` to `.gitignore` - it will hide all Genie configuration
- Only ignore: `.genie/.tasks/` and `.genie/state/` (ephemeral data)
