---
title: Search
description: Runtime search behavior and generated search-index.json
icon: search
order: 5
tags:
  - features
  - search
  - reference
---

Arcane Lexicon has two related search outputs:

1. Runtime UI search (client-side, instant).
2. Optional generated `web/search-index.json` for external consumers.

## Runtime UI Search

The built-in UI search is initialized from rendered sidebar links (`.sidebar-link`).

Current behavior:
- Case-insensitive substring matching.
- Minimum query length: `2`.
- Maximum shown results: `10`.
- Categories inferred from URL path segments.
- Keyboard shortcuts:
  - `Cmd/Ctrl + K` focuses search.
  - `Escape` closes results.
  - `ArrowUp` / `ArrowDown` navigates result list.
  - `Enter` opens selected (or first) result.

## Configuration

```dart
SiteConfig(
  name: 'My Docs',
  searchEnabled: true,
)
```

When `searchEnabled` is `false`, search input is not rendered.

## Generated `search-index.json`

`KnowledgeBaseApp.create()` can generate a search index file at build time.

```dart
await KnowledgeBaseApp.create(
  config: config,
  stylesheet: stylesheet,
  generateSearchIndex: true, // default
)
```

Generated file:
- `web/search-index.json`

Entry payload includes:
- `title`
- `path`
- `category`
- `description` (when available)
- `keywords` (tags/path-derived)
- `excerpt` (truncated Markdown text; link labels and emphasized words are preserved without their formatting)
- `icon`

This file is useful for external search integrations or custom client search implementations.

## Notes

- Runtime UI search currently uses sidebar-derived entries, not the generated JSON file.
- Hidden/draft pages are excluded from manifest-driven search index generation.

