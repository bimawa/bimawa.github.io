# Fish completions for just — bimawa.github.io
# ───────────────────────────────────────────────────────
# Self-contained: includes standard just completions
# + dynamic project/blog name completion.
#
# Install:  just setup
# ───────────────────────────────────────────────────────

# ─── Standard just completions (generated) ──────────────

# Include just's own completions for recipe names and flags
just --completions fish 2>/dev/null | source -

# ─── Dynamic helpers ─────────────────────────────────

function __just_in_project
    test -f justfile
    and string match -q '*bimawa.github.io*' < justfile 2>/dev/null
end

function __just_project_names
    if not __just_in_project; return; end
    for dir in content/projects/*/
        basename $dir
    end
end

function __just_blog_slugs
    if not __just_in_project; return; end
    if not test -d content/blog; return; end
    set -l slugs
    for f in content/blog/*.md
        set -l base (basename $f)
        set -l slug (string replace -ra '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z_|\.(ru\.)?md$' '' -- $base)
        if test -n "$slug"; and not string match -qr '^_index' -- $slug
            contains -- $slug $slugs; or set -a slugs $slug
        end
    end
    for s in $slugs; echo $s; end
end

# ─── Dynamic completions for project names ────────────

complete -c just -n '__fish_seen_subcommand_from project;     and __just_in_project' \
    -xa '(__just_project_names)' -d 'Project name'
complete -c just -n '__fish_seen_subcommand_from project-post; and __just_in_project' \
    -xa '(__just_project_names)' -d 'Project name'
complete -c just -n '__fish_seen_subcommand_from project-translate; and __just_in_project' \
    -xa '(__just_project_names)' -d 'Project name'

# ─── Dynamic completions for blog slugs ───────────────

complete -c just -n '__fish_seen_subcommand_from translate; and __just_in_project' \
    -xa '(__just_blog_slugs)' -d 'Blog post slug'
complete -c just -n '__fish_seen_subcommand_from edit; and __just_in_project' \
    -xa '(__just_blog_slugs)' -d 'Blog post slug'
