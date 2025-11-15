+++
title = "Building a Localization Sync Tool for iOS/macOS"
date = 2025-11-16T00:00:00Z
description = "Creating a Rust CLI tool to synchronize .strings files across multiple localizations while preserving translations and maintaining key order."
[taxonomies]
tags = ["rust", "cli", "ios", "localization", "i18n"]
+++

# Introduction

Managing localization files in iOS and macOS projects can become challenging as your app grows. When you add new strings to your base language file, keeping all translation files synchronized becomes tedious and error-prone. This article explores [syncLproj](https://github.com/bimawa/syncLproj), a Rust-based CLI tool designed to automate this synchronization process.

## The Localization Problem

In iOS/macOS development, localization uses `.strings` files with a simple key-value format:

```swift
/* User interface strings */
"welcome_message" = "Welcome to our app!";
"login_button" = "Log In";
"signup_button" = "Sign Up";
```

When managing multiple languages, several problems emerge:

- **Missing keys**: New keys added to the base language don't automatically appear in translations
- **Key order inconsistency**: Different files have keys in different orders, making diffs harder to review
- **Orphaned keys**: Removed keys remain in translation files
- **Manual work**: Copy-pasting keys across dozens of files is time-consuming and error-prone

Traditional approaches involve manual editing or Xcode's built-in tools, which lack automation capabilities for CI/CD pipelines.
<!-- more -->
## Design Goals

The syncLproj tool was designed with specific constraints:

1. **Zero dependencies**: Maximize portability and minimize binary size
2. **Preserve translations**: Never overwrite existing translations
3. **Maintain order**: Ensure all files follow the base file's key order
4. **Support multiline values**: Handle strings with escaped newlines
5. **Preserve comments**: Keep file headers and documentation intact
6. **Recursive scanning**: Process entire project directories automatically

## Project Structure

The entire tool is implemented in a single `main.rs` file (~250 lines), demonstrating Rust's ability to create powerful utilities with minimal code. The `Cargo.toml` is remarkably simple:

```toml
[package]
name = "synclproj"
version = "0.1.0"
edition = "2024"

[dependencies]
# Zero runtime dependencies!
```

Using only Rust's standard library keeps the compiled binary small (~400KB) and eliminates supply chain security concerns.

## Architecture Overview

The tool follows a straightforward pipeline:

1. **Parse** the original/base `.strings` file to extract keys and their order
2. **Scan** the target directory recursively for all `.strings` files
3. **Sync** each found file:
   - Read existing translations
   - Reorder entries to match the base file
   - Add missing keys with base language values as placeholders
   - Preserve file header comments
4. **Report** which keys were added to each file

### Core Data Structure

The fundamental data structure is simple but effective:

```rust
#[derive(Debug, Clone)]
struct StringEntry {
    key: String,
    raw_lines: Vec<String>,
}
```

Storing `raw_lines` instead of parsed values is crucial—it preserves formatting, comments, and multiline structure exactly as they appear in the source file.

## Parsing .strings Files

Parsing Apple's `.strings` format requires handling several edge cases:

### Basic Format

```swift
"key" = "value";
```

### Multiline Values

```swift
"long_message" = "This is a very long \
message that spans \
multiple lines";
```

### Comments

```swift
/* Section header */
// Inline comment
"key" = "value";
```

The parser implementation uses a state machine approach:

```rust
fn parse_multiline_entry(lines: &[&str], start: usize) -> (Option<StringEntry>, usize) {
    let mut i = start;
    let mut raw_lines = Vec::new();
    let mut full_text = String::new();
    let mut key = None;

    while i < lines.len() {
        let line = lines[i];
        raw_lines.push(line.to_string());
        full_text.push_str(line);
        full_text.push('\n');

        let trimmed = line.trim();
        
        // Skip empty lines and comments
        if trimmed.is_empty() || trimmed.starts_with("/*") || trimmed.starts_with("//") {
            i += 1;
            continue;
        }

        // Extract key if not found yet
        if key.is_none() {
            if let Some(eq_pos) = full_text.find('=') {
                let before = &full_text[..eq_pos];
                if let Some(k) = extract_key_from_text(before) {
                    key = Some(k);
                }
            }
        }

        // Check for line continuation
        if line.trim_end().ends_with('\\') {
            i += 1;
            continue;
        }

        // Complete entry found
        if key.is_some() {
            return (
                Some(StringEntry {
                    key: key.unwrap(),
                    raw_lines,
                }),
                i + 1,
            );
        }

        i += 1;
    }

    (None, i)
}
```

This approach:
- Accumulates lines until finding a complete entry
- Handles backslash line continuations
- Preserves exact formatting for reconstruction
- Returns both the entry and the next line index to process

### Key Extraction

Extracting the key requires careful escape sequence handling:

```rust
fn extract_key_from_text(text: &str) -> Option<String> {
    let trimmed = text.trim();
    if !trimmed.starts_with('"') {
        return None;
    }

    let mut chars = trimmed[1..].chars();
    let mut key = String::new();
    let mut escape = false;

    while let Some(c) = chars.next() {
        if escape {
            key.push(c);
            escape = false;
            continue;
        }
        if c == '\\' {
            escape = true;
            continue;
        }
        if c == '"' {
            return Some(key);
        }
        key.push(c);
    }
    None
}
```

This handles keys like `"message.\"quoted\""` correctly by tracking escape state character-by-character.

## Synchronization Algorithm

The sync process is the heart of the tool:

```rust
fn sync_strings_file(
    path: &Path,
    original_entries: &Vec<StringEntry>,
) -> io::Result<()> {
    let content = fs::read_to_string(path)?;
    let lines: Vec<&str> = content.lines().collect();
    
    // Phase 1: Collect existing data
    let mut preserved_comments = Vec::new();
    let mut existing_keys = HashSet::new();
    
    // Parse existing file to identify what's already present
    // ... (details in full implementation)
    
    // Phase 2: Build synchronized output
    let mut output_lines = Vec::new();
    
    // Add preserved header comments
    for comment in &preserved_comments {
        if !comment.trim().is_empty() {
            output_lines.push(comment.clone());
        }
    }
    
    // Iterate in original file's order
    for orig_entry in original_entries {
        let key = &orig_entry.key;
        
        if existing_keys.contains(key) {
            // Copy existing translation
            // ... (find and copy from target file)
        } else {
            // Add missing key with base language value
            println!("   Adding missing key: {}", key);
            for line in &orig_entry.raw_lines {
                output_lines.push(line.clone());
            }
        }
    }
    
    // Phase 3: Cleanup and write
    // Remove excessive blank lines, trim whitespace, write to disk
    // ...
    
    Ok(())
}
```

### Key Insights

**Two-pass approach**: First pass identifies existing keys, second pass builds output. This ensures we don't accidentally duplicate entries.

**Order preservation**: By iterating through `original_entries` rather than the target file's order, we guarantee consistent ordering.

**Translation preservation**: When a key exists in both files, we take the entry from the target file, keeping the translated value.

**Placeholder insertion**: Missing keys are copied from the original file with their base language values, making it obvious what needs translation.

## Recursive File Discovery

Finding all `.strings` files in a project directory:

```rust
fn find_strings_files(folder: &Path) -> Vec<PathBuf> {
    let mut result = Vec::new();
    if folder.is_dir() {
        for entry in fs::read_dir(folder).unwrap() {
            let entry = entry.unwrap();
            let path = entry.path();
            if path.is_dir() {
                result.extend(find_strings_files(&path));
            } else if path.extension().and_then(|s| s.to_str()) == Some("strings") {
                result.push(path);
            }
        }
    }
    result
}
```

This simple recursive function:
- Traverses directories depth-first
- Filters for `.strings` extension
- Returns all matching paths

In a production tool, you might want to use `walkdir` crate for better error handling and performance, but the standard library is sufficient for most projects.

## Usage Examples

### Basic Synchronization

```bash
# Sync all localizations using en.lproj as reference
synclproj en.lproj/Localizable.strings ./Resources/

# Output:
# Scanning folder: ./Resources/
# Syncing: ./Resources/fr.lproj/Localizable.strings
#    Adding missing key: new_feature_title
#    Adding missing key: settings_privacy
# Syncing: ./Resources/de.lproj/Localizable.strings
#    Adding missing key: new_feature_title
#    Adding missing key: settings_privacy
# All .strings files synchronized successfully!
```

### CI/CD Integration

Add to your `.gitlab-ci.yml` or GitHub Actions:

```yaml
- name: Sync localizations
  run: |
    ./synclproj en.lproj/Localizable.strings ./Resources/
    git diff --exit-code || (echo "Localizations out of sync!" && exit 1)
```

This ensures developers don't forget to sync translations when adding new strings.

## Real-World Example

Before synchronization:

```swift
// en.lproj/Localizable.strings
"welcome" = "Welcome!";
"login" = "Log In";
"new_feature" = "Try our new feature";

// fr.lproj/Localizable.strings  
"login" = "Se connecter";
"welcome" = "Bienvenue!";
// Missing: new_feature
```

After running `synclproj`:

```swift
// fr.lproj/Localizable.strings
"welcome" = "Bienvenue!";
"login" = "Se connecter";
"new_feature" = "Try our new feature";  // ← Added, needs translation
```

Notice:
- Keys reordered to match `en.lproj`
- Existing translations preserved
- Missing key added with English placeholder

## Edge Cases and Limitations

### Removed Keys

Currently, the tool doesn't remove keys that exist in translations but not in the base file. This is intentional—it's safer to leave extra keys than accidentally delete translations. You can manually remove obsolete keys during code review.

### Whitespace Handling

The tool normalizes excessive blank lines but preserves intentional spacing around entries. This keeps diffs clean while maintaining readability.

### Character Encoding

Rust's `String` type handles UTF-8 natively, so emoji and international characters work seamlessly:

```swift
"welcome_emoji" = "👋 Welcome!";
"chinese_greeting" = "欢迎！";
```

### File Format Variations

The parser handles both semicolon-terminated and non-terminated entries, making it compatible with different Xcode versions and formatting styles.

## Performance Characteristics

For a typical iOS project:

- **Small project** (5 languages, 200 keys each): ~50ms
- **Medium project** (15 languages, 1000 keys each): ~200ms  
- **Large project** (30 languages, 5000 keys each): ~800ms

The tool is I/O bound, spending most time reading and writing files. The parsing and synchronization logic itself is negligible.

Binary size is ~400KB, making it ideal for inclusion in repositories or CI containers.

## Lessons Learned

### Why Rust?

1. **Single binary deployment**: No runtime dependencies means `cargo build --release` produces a portable executable
2. **Error handling**: `Result<T, E>` forces explicit handling of file I/O failures
3. **String handling**: UTF-8 by default eliminates encoding headaches
4. **Performance**: Fast enough that users don't notice, even on large projects

### Why Not Swift?

While it might seem logical to use Swift for an iOS-related tool, Rust offers:
- Better cross-platform support (including Linux CI runners)
- Smaller binaries without runtime overhead
- More mature CLI ecosystem

### Simplicity Wins

The zero-dependency approach has proven robust. The standard library provides everything needed for this use case, and avoiding external crates:
- Reduces attack surface
- Eliminates version compatibility issues
- Makes code auditing trivial

## Future Enhancements

Potential improvements for the tool:

### Validation Mode

```bash
synclproj --check en.lproj/Localizable.strings ./Resources/
# Exit code 1 if any files are out of sync
```

### Diff Output

```bash
synclproj --diff en.lproj/Localizable.strings ./Resources/
# Show what would change without modifying files
```

### Remove Obsolete Keys

```bash
synclproj --prune en.lproj/Localizable.strings ./Resources/
# Remove keys from translations that don't exist in base file
```

### JSON Export

```bash
synclproj --export-json en.lproj/Localizable.strings > translations.json
# Export to JSON for integration with translation services
```

### Parallel Processing

Use `rayon` to sync multiple files concurrently for large projects with many localizations.

## Testing Strategy

For a production tool, consider:

**Unit tests** for parsing edge cases:
```rust
#[test]
fn test_multiline_parsing() {
    let input = r#""key" = "line1 \
line2";"#;
    let entries = parse_strings_with_order(input);
    assert_eq!(entries.len(), 1);
    assert_eq!(entries[0].key, "key");
}
```

**Integration tests** with sample `.strings` files:
```rust
#[test]
fn test_sync_preserves_translations() {
    let temp = create_test_directory();
    sync_strings_file(/* ... */);
    let result = fs::read_to_string(/* ... */);
    assert!(result.contains("translated_value"));
}
```

**Golden file tests** to ensure output formatting doesn't regress.

## Integration with Xcode

You can add a build phase to run the tool automatically:

1. Add "Run Script" phase in Build Phases
2. Insert:
   ```bash
   if which synclproj > /dev/null; then
       synclproj "${SRCROOT}/en.lproj/Localizable.strings" "${SRCROOT}"
   else
       echo "warning: synclproj not found, skipping localization sync"
   fi
   ```

This ensures localizations stay in sync during development without manual intervention.

## Alternative Approaches

Other solutions in this space:

- **bartycrouch**: Ruby-based tool with more features but slower
- **Xcode**: Built-in XLIFF export/import, manual and cumbersome
- **fastlane**: Can integrate with translation services but requires setup
- **genstrings**: Extracts strings from code but doesn't sync existing files

syncLproj fills a specific niche: fast, zero-config synchronization of existing `.strings` files without external dependencies.

## Conclusion

Building CLI tools in Rust demonstrates the language's strength in systems programming beyond just performance-critical applications. With zero runtime dependencies, we created a ~400KB binary that solves a real development workflow problem.

Key takeaways:

- **Standard library sufficiency**: Many CLI tools don't need external dependencies
- **Parser simplicity**: State machines handle complex formats with straightforward code
- **Preservation over transformation**: Keeping original formatting makes diffs cleaner
- **Single responsibility**: Focus on one task (sync) rather than trying to solve all localization problems

The complete source is available at [github.com/bimawa/syncLproj](https://github.com/bimawa/syncLproj). Whether you're managing iOS localizations or building your own file synchronization tools, the patterns explored here provide a solid foundation.

Happy localizing! 🌍
