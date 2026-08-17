# bimawa.github.io — Zola Static Site Manager
# ────────────────────────────────────────────────────────
# Commands for building, content creation, and managing
# the bilingual (RU/EN) blog + projects site.
#
# Workflow:
#   just post <slug> "Заголовок"    → write RU post
#   just translate <slug>           → create EN version
#   just build                      → build & check
#
# `just` alone shows this help.
# ────────────────────────────────────────────────────────

# ─── Help (default target) ──────────────────────────────

# Show this help (default, since this is the first recipe)
help:
    @echo "╔══════════════════════════════════════════════════╗"
    @echo "║  bimawa.github.io  —  Zola Site Manager          ║"
    @echo "╚══════════════════════════════════════════════════╝"
    @echo ""
    @echo "── Site ──"
    @echo "  just build           Build the site"
    @echo "  just serve           Serve with live reload"
    @echo "  just check           Check internal links"
    @echo "  just deploy          Commit + push to main"
    @echo "  just deploy \"msg\"   Commit with custom message"
    @echo ""
    @echo "── Blog ──"
    @echo "  just post <slug> \"Title (RU)\"     New RU blog post"
    @echo "  just translate <slug>              EN version from RU"
    @echo "  just edit <slug>                   Open post for editing"
    @echo "  just list-posts                    List all posts"
    @echo ""
    @echo "── Projects ──"
    @echo "  just project <Name> \"Title\"       New project (both langs)"
    @echo "  just project-post <Project> <Slug> \"Title\"   Add news"
    @echo "  just project-translate <Project> <Slug>        Translate"
    @echo "  just list-projects                List all projects"
    @echo ""
    @echo "── Info ──"
    @echo "  just --list           Show all raw targets"
    @echo "  just --summary        Short summary"

# ─── Site ──────────────────────────────────────────────

# Build the site (production output to public/)
build:
    zola build

# Serve locally with live reload and open browser
serve:
    zola serve --open

# Check all internal links
check:
    zola check

# Commit and push to deploy via GitHub Actions
# Usage: just deploy
#        just deploy "feat: add new project"
deploy msg="docs: update site content":
    git add -A
    git commit -m "{{msg}}"
    git push origin main

# ─── Blog ──────────────────────────────────────────────

# Create a new blog post (Russian version first)
# Usage: just post <slug> "Заголовок поста"
#   slug  — URL-friendly name, e.g. "my-new-feature"
#   title — post title in Russian
[no-exit-message]
post slug title:
    #!/usr/bin/env bash
    set -euo pipefail
    slug='{{slug}}'
    title='{{title}}'
    date=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    file="content/blog/${date}_${slug}.ru.md"
    mkdir -p content/blog
    if [[ -f "$file" ]]; then
        echo "Error: ${file} already exists" >&2
        exit 1
    fi
    {
        echo '+++'
        echo "title = \"${title}\""
        echo "date = ${date}"
        echo 'description = ""'
        echo '[taxonomies]'
        echo 'tags = []'
        echo '+++'
    } > "$file"
    echo "Created: ${file}"
    echo ""
    echo "Next steps:"
    echo "  just translate ${slug}     Create English version"
    echo "  just edit ${slug}          Open for editing"

# Create English version from Russian blog post
# Usage: just translate <slug>
translate slug:
    #!/usr/bin/env bash
    set -euo pipefail
    slug='{{slug}}'
    shopt -s nullglob
    matches=(content/blog/*_"${slug}".ru.md)
    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "Error: No RU post found for slug '${slug}'" >&2
        echo "  Looked in: content/blog/*_${slug}.ru.md" >&2
        exit 1
    fi
    ru_file="${matches[0]}"
    en_file="${ru_file%.ru.md}.md"
    if [[ -f "$en_file" ]]; then
        echo "Error: EN version already exists: ${en_file}" >&2
        exit 1
    fi
    cp "$ru_file" "$en_file"
    sed -i '' 's/^title = "\(.*\)"/title = "\1 [EN]"/' "$en_file"
    sed -i '' 's/^description = "\(.*\)"/description = "\1 [EN: translate]"/' "$en_file"
    echo "Created: ${en_file}"
    echo "Translate the content in: ${en_file}"

# Open blog post(s) for editing
# Usage: just edit <slug>
edit slug:
    #!/usr/bin/env bash
    set -euo pipefail
    slug='{{slug}}'
    shopt -s nullglob
    matches=(content/blog/*_"${slug}".md content/blog/*_"${slug}".ru.md)
    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "Error: No post found for slug '${slug}'" >&2
        exit 1
    fi
    echo "Opening:" "${matches[@]}"
    exec "${EDITOR:-vim}" "${matches[@]}"

# ─── Projects ──────────────────────────────────────────

# Create a new project (short desc + detail section + first article)
# Usage: just project <Name> "Project Title"
#   Name  — PascalCase folder name, e.g. "MyProject"
#   title — display name in both languages
project name title:
    #!/usr/bin/env bash
    set -euo pipefail
    name='{{name}}'
    title='{{title}}'
    today=$(date -u +%Y-%m-%d)
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    if [[ -f "content/projects/${today}_${name_lower}.md" ]]; then
        echo "Error: Project short desc already exists" >&2
        exit 1
    fi
    if [[ -d "content/projects/${name}" ]]; then
        echo "Error: Project directory '${name}' already exists" >&2
        exit 1
    fi
    # 1. Short description pages (RU + EN)
    for sfx in ru.md md; do
        f="content/projects/${today}_${name_lower}.${sfx}"
        {
            echo '+++'
            echo "title = \"${title}\""
            echo "date = \"${today}\""
            echo 'template = "project.html"'
            echo '[extra]'
            echo 'tags = []'
            echo 'author = "Bimawa"'
            echo "link = \"/projects/${name}/\""
            echo 'description = ""'
            echo '+++'
        } > "$f"
    done
    # 2. Detail section with _index (RU + EN)
    mkdir -p "content/projects/${name}"
    for sfx in ru.md md; do
        f="content/projects/${name}/_index.${sfx}"
        {
            echo '+++'
            echo "title = \"${title}\""
            echo 'sort_by = "date"'
            echo 'paginate_by = 10'
            echo "template = \"index${name}.html\""
            echo '+++'
        } > "$f"
    done
    # 3. Section template (custom per project, like other projects)
    mkdir -p templates
    tpl="templates/index${name}.html"
    if [[ ! -f "$tpl" ]]; then
        sed "s/__PROJECT__/${name}/g" templates/project-section-template.html > "$tpl"
    fi
    # 4. First article (RU + EN)
    {
        echo '+++'
        echo "title = \"Добро пожаловать в ${title}\""
        echo 'description = ""'
        echo "date = ${now}"
        echo 'template = "project.html"'
        echo '+++'
        echo ''
        echo "## ${title}"
    } > "content/projects/${name}/${now}_welcome.ru.md"
    {
        echo '+++'
        echo "title = \"Welcome to ${title}\""
        echo 'description = ""'
        echo "date = ${now}"
        echo 'template = "project.html"'
        echo '+++'
        echo ''
        echo "## ${title}"
    } > "content/projects/${name}/${now}_welcome.md"
    echo "Project '${title}' created"
    echo "  Short desc: content/projects/${today}_${name_lower}.{md,ru.md}"
    echo "  Detail:     content/projects/${name}/"
    echo "  First post: ${now}_welcome.{md,ru.md}"
    echo ""
    echo "Next:"
    echo "  just project-post ${name} <slug> \"News title (RU)\""

# Add a news/article to an existing project (Russian version)
# Usage: just project-post <Name> <slug> "Заголовок"
project-post project slug title:
    #!/usr/bin/env bash
    set -euo pipefail
    project='{{project}}'
    slug='{{slug}}'
    title='{{title}}'
    dir="content/projects/${project}"
    if [[ ! -d "$dir" ]]; then
        echo "Error: Project '${project}' not found" >&2
        echo "  Create it:  just project ${project} \"Title\"" >&2
        exit 1
    fi
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    file="${dir}/${now}_${slug}.ru.md"
    {
        echo '+++'
        echo "title = \"${title}\""
        echo 'description = ""'
        echo "date = ${now}"
        echo 'template = "project.html"'
        echo '+++'
        echo ''
    } > "$file"
    echo "Created: ${file}"
    echo ""
    echo "Next:  just project-translate ${project} ${slug}"

# Create English version from Russian project article
# Usage: just project-translate <Name> <slug>
project-translate project slug:
    #!/usr/bin/env bash
    set -euo pipefail
    project='{{project}}'
    slug='{{slug}}'
    dir="content/projects/${project}"
    if [[ ! -d "$dir" ]]; then
        echo "Error: Project '${project}' not found" >&2
        exit 1
    fi
    shopt -s nullglob
    matches=("${dir}"/*_"${slug}".ru.md)
    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "Error: No RU article '${slug}' found in project '${project}'" >&2
        exit 1
    fi
    ru_file="${matches[0]}"
    en_file="${ru_file%.ru.md}.md"
    if [[ -f "$en_file" ]]; then
        echo "Error: EN version already exists: ${en_file}" >&2
        exit 1
    fi
    cp "$ru_file" "$en_file"
    sed -i '' 's/^title = "\(.*\)"/title = "\1 [EN]"/' "$en_file"
    sed -i '' 's/^description = "\(.*\)"/description = "\1 [EN: translate]"/' "$en_file"
    echo "Created: ${en_file}"
    echo "Translate the content in: ${en_file}"

# ─── Navigation ────────────────────────────────────────

# List all blog posts
list-posts:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    echo "=== Blog Posts ==="
    for f in content/blog/*.md; do
        base=$(basename "$f")
        [[ "$base" = _index.md || "$base" = _index.ru.md ]] && continue
        t=$(grep '^title = ' "$f" | head -1 | sed 's/^title = "\(.*\)"/\1/')
        echo "  ${base}  →  ${t}"
    done

# List all projects and their article counts
list-projects:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    echo "=== Projects ==="
    for d in content/projects/*/; do
        name=$(basename "$d")
        t=$(grep '^title = ' "${d}_index.md" 2>/dev/null | head -1 | sed 's/^title = "\(.*\)"/\1/')
        echo "  ${name}  →  ${t}"
        articles=("${d}"*.md)
        count=0
        for a in "${articles[@]}"; do
            abase=$(basename "$a")
            [[ "$abase" = _index.md || "$abase" = _index.ru.md ]] && continue
            count=$((count + 1))
        done
        echo "         ${count} article(s)"
    done

# ─── Completions & Setup ────────────────────────────────

# Install fish completions (project names + blog slugs)
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    dest="${HOME}/.config/fish/completions/just.fish"
    mkdir -p "$(dirname "$dest")"
    # Merge standard just completions with our custom ones
    {
        just --completions fish 2>/dev/null || echo "# (no standard just completions)"
        echo ""
        echo "# ── bimawa.github.io custom completions ──"
        cat completions/just.fish
    } > "$dest"
    echo "Installed completions: ${dest}"
    echo ""
    echo "Reload your shell to activate:"
    echo "  exec fish"

# Show completion installation instructions
completions:
    @echo "Install fish completions for dynamic project/blog name completion:"
    @echo ""
    @echo "  just setup"
    @echo ""
    @echo "This installs to ~/.config/fish/completions/just.fish"
    @echo "and adds tab-completion for:"
    @echo "  - just project <Tab>"
    @echo "  - just project-post <Tab>"
    @echo "  - just project-translate <Tab>"
    @echo "  - just translate <Tab>"
    @echo "  - just edit <Tab>"
    @echo ""
    @echo "Then reload:  exec fish"
    @echo ""
    @echo "For other shells (bash/zsh):"
    @echo "  just --completions zsh   # generate zsh completions"
    @echo "  just --completions bash  # generate bash completions"
