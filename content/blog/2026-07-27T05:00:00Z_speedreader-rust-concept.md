+++
title = "SpeedReaderRust: The Story of an Idea"
date = 2026-07-27T05:00:00Z
description = "How reading documentation led to creating an RSVP reader in Rust with editor integration"
[taxonomies]
tags = ["rust", "rsvp", "reading", "productivity", "tools"]
+++

## How It Started

I read a lot of technical documentation. SDDs (Specification Driven Development documents), RFCs, specs — I have to digest large volumes constantly. Regular reading hits a speed limit: you waste time on saccades (eye jumps between words) and regressions (backtracking across lines).

At some point I remembered RSVP — Rapid Serial Visual Presentation. Words appear one at a time in a fixed screen position, driven by words-per-minute. Your eyes don't move — they just stare at the center and absorb words.

<!-- more -->

## The Problem with Existing Solutions

I googled around. Web services, mobile apps, browser extensions — all of them share the same issues:

1. **No editor integration** — can't open a file from Zed and read immediately
2. **Fixed overlay position** — can't move it where you want
3. **Closed source** — can't add your own feature
4. **No center letter highlighting** — which turns out to be critical for recognition speed

I decided to write my own. In Rust, of course.

## Why Rust

Because:
- An RSVP reader needs to be **fast** — words flash at 300+ per minute, no time for GC pauses
- **Cross-platform** — Linux, macOS, Windows from a single codebase
- **No bloat** — didn't want to drag in Electron or Python

I built a minimal prototype in one evening: `winit` for the window, `ab_glyph` for font rendering, `pixels` for pixel pushing. Exactly what I needed.

## How It Works

The program reads a text file, tokenizes it into words, and displays them one by one in the center of the screen. Each word is rendered with a **highlighted center letter** (ORP — Optimal Recognition Point).

Research shows your eye doesn't focus on the first letter when scanning a word — it lands roughly one third of the way in. Highlighting that letter helps the brain recognize the whole word faster. This isn't a gimmick — it's a scientifically backed technique that genuinely improves reading speed without sacrificing comprehension.

## Editor Integration

The killer feature: hit `Space` — reading pauses, and your editor (Zed, VS Code, Vim, or anything else) opens exactly at the word you stopped on. No searching, no context loss.

I mapped `Cmd+Shift+R` in Zed — now I read any open file with a single shortcut. SDDs, logs, code snippets — anything that can be opened can be read via RSVP.

## What's Next

The project is open source on GitHub: [github.com/bimawa/SpeedReaderRust](https://github.com/bimawa/SpeedReaderRust)

Install with one command:

```sh
cargo install speed-reader
```

Right now it's a working MVP. Plans:
- PDF support
- Reading stats (average speed, words per session)
- Speed profiles for different content types
- Dark and light themes

Give it a try — and open an issue if you find a bug or have an idea.
