---
title: Running
description: Start the development server
icon: play
order: 3
author: Arcane Arts
date: 2025-01-11
---

## Development

```bash
cd your-project
dart run arcane_lexicon serve
```

Visit http://localhost:8081. The generated starter includes `jaspr_cli`.

From the Lexicon repository, run `dart tool/arcane_lexicon_demo.dart` to
serve the bundled example.

## Production Build

```bash
dart run arcane_lexicon build
```

## With Base URL

For subdirectory hosting (e.g., GitHub Pages):

```bash
dart run arcane_lexicon build --dart-define=BASE_URL=/my-docs
```

---

This is the last page in the Basics section. The **Previous** button takes you back to Configuration.
