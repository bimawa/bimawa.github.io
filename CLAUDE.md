# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Development server with live reload
zola serve

# Build for production
zola build

# Check for errors without building
zola check
```

## Architecture

This is a **Zola static site** (https://www.getzola.org/) using the **terminimal** theme with custom overrides.

### Multilingual Support

The site supports English (default) and Russian:
- English pages: `content/page.md`
- Russian pages: `content/page.ru.md`
- URLs: English at `/page/`, Russian at `/ru/page/`

Menu items are defined separately in `config.toml`:
- `[extra].menu_items` for English
- `[extra].menu_items_ru` for Russian

Translation strings are in `[translations]` and `[languages.ru.translations]`.

### Template Hierarchy

All custom templates extend `templates/base.html`, which:
- Imports theme macros from `terminimal/templates/macros/`
- Uses custom `templates/macros/menu.html` for language-aware navigation
- Includes language switcher (EN | RU) in the header

Key templates:
- `base.html` - Main layout with language switcher
- `index.html` - Blog homepage
- `projects.html` - Projects listing page
- `project.html` - Individual project page
- `index{ProjectName}.html` - Project-specific section templates (e.g., `indexWireDeskVR.html`)

### Content Structure

```
content/
├── _index.md              # Blog home (paginated)
├── blog/                  # Blog posts
├── projects/              # Projects section
│   ├── _index.md          # Projects listing
│   └── {ProjectName}/     # Each project has its own section
│       ├── _index.md      # Project section config
│       └── *.md           # Project articles
└── *.md                   # Static pages (about, cv, contacts, privacy, terms)
```

### Adding New Content

**New blog post:**
```markdown
+++
title = "Post Title"
date = 2025-01-01T00:00:00Z
description = "Brief description"
[taxonomies]
tags = ["tag1", "tag2"]
+++
```

**New project article:**
```markdown
+++
title = "Project Name"
description = "Project description"
date = 2025-01-01T00:00:00Z
author = "Author Name"
tags = ["tag1", "tag2"]
template = "project.html"
+++
```

For Russian translations, create a `.ru.md` file with the same name. Tags must remain in English (same across languages).

### Static Assets

- `static/` - CSS, JS, images
- `static/projects.css` - Project page styles
- `static/menu-projects.css` - Project menu styles
