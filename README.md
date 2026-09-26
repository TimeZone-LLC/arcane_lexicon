# Arcane Lexicon

Transform markdown directories into documentation websites with generated navigation, search, theming, and rich markdown components. Built on Jaspr.

**[Live Demo](https://timezone-llc.github.io/arcane_lexicon/)** | **[GitHub](https://github.com/ArcaneArts/arcane_lexicon)**

## Fastest Start

Create a starter docs site, then drop markdown files into `content/`:

```bash
dart pub global activate --source git https://github.com/ArcaneArts/arcane_lexicon.git
arcane_lexicon create my_docs
cd my_docs
dart pub get
arcane_lexicon serve
```

During local package development, use the same flow without global activation:

```bash
dart run arcane_lexicon create my_docs
cd my_docs
dart pub get
# Optional before this package is published/pushed from your working copy:
# create a pubspec_overrides.yaml pointing arcane_lexicon at this repo.
dart run arcane_lexicon serve
```

The generated project is intentionally small:

```text
my_docs/
  pubspec.yaml
  jaspr_options.yaml
  lib/
    main.server.dart
    main.client.dart
  content/
    index.md
    guide/
      _section.json5
      getting-started.md
  web/
    styles.css
```

Add pages by adding markdown files under `content/`. Folders become sidebar sections. `_section.json5` files customize folder titles, icons, order, and collapsed state.

## CLI

```bash
arcane_lexicon create my_docs
arcane_lexicon create docs --name "Acme Docs" --theme neon
arcane_lexicon serve
arcane_lexicon build --dart-define=BASE_URL=/docs
arcane_lexicon clean
arcane_lexicon doctor
```

### `create` Options

| Option | Description |
|---|---|
| `--name <site name>` | Human-readable site name. Defaults to title-cased project name. |
| `--description <text>` | Site description used in generated config/frontmatter. |
| `--output-dir <path>` | Directory to create. Defaults to `<project_name>`. |
| `--theme <theme>` | `shadcn`, `neon`, or `neubrutalism`. Defaults to `shadcn`. |
| `--force` | Allow merging starter files into an existing directory. Existing files are preserved unless `--force` is set. |

## Manual Setup

For local development, keep the site, `arcane_lexicon`, and `arcane_jaspr`
checkouts in the same parent directory. Resolve the core and renderer from that
same Arcane Jaspr checkout:

```yaml
dependencies:
  jaspr: ^0.23.1
  arcane_lexicon:
    path: ../arcane_lexicon
  arcane_jaspr_shadcn:
    path: ../arcane_jaspr/packages/arcane_jaspr_shadcn

dependency_overrides:
  arcane_jaspr:
    path: ../arcane_jaspr
```

The CLI starter uses Git dependencies. Apply these local paths to its generated
`pubspec.yaml` when working against an unreleased checkout. A dependency override
inside Lexicon does not propagate to a consuming site; declare the core override
in the site's own pubspec.

Then create a Jaspr server entrypoint:

```dart
import 'package:arcane_jaspr_shadcn/arcane_jaspr_shadcn.dart';
import 'package:arcane_lexicon/arcane_lexicon.dart' hide runApp;
import 'package:jaspr/server.dart';

Future<void> main() async {
  Jaspr.initializeApp();

  runApp(
    await KnowledgeBaseApp.create(
      config: const SiteConfig(
        name: 'My Docs',
        contentDirectory: 'content',
      ),
      stylesheet: const ShadcnStylesheet(theme: ShadcnTheme.midnight),
    ),
  );
}
```

## Content Directory Shape

```text
content/
  index.md
  guide/
    _section.json5
    index.md
    basics/
      _section.json5
      installation.md
      configuration.md
  reference/
    _section.json5
    site-config.md
    components.md
```

## Page Frontmatter

```yaml
---
layout: kb
title: Installation
description: How to install
icon: download
order: 1
tags:
  - setup
author: Arcane Arts
date: 2026-03-03
pageNav: true
component: ExampleDemo
draft: false
hidden: false
---
```

## Section Config

```json5
{
  title: 'Getting Started',
  icon: 'rocket',
  order: 1,
  collapsed: false,
  ignore: false,
}
```

## SiteConfig

```dart
SiteConfig(
  name: 'Site Name',
  contentDirectory: 'content',
  githubUrl: 'https://github.com/...',
  searchEnabled: true,
  tocEnabled: true,
  themeToggleEnabled: true,
  pageNavEnabled: true,
  navigationBarEnabled: true,
  navigationBarPosition: KBNavigationBarPosition.top,
  sidebarWidth: '280px',
  sidebarTreeIndent: '10px',
)
```

## What Ships by Default

- Generated nav from markdown folders/files.
- Sidebar + top/bottom navigation bar modes.
- Breadcrumbs and footer prev/next navigation.
- GitHub-style callout syntax with optional title.
- Media embed syntax (`@[youtube]`, `@[video]`, `@[image]`, etc.).
- Highlight.js code blocks with copy buttons.
- Reading time + metadata row.
- `web/search-index.json` is generated automatically during serve/build.

## Default Rich Markdown Components

Registered through `KBRichMarkdownComponents.defaults()`:

- `CardGroup`, `Card`
- `Columns`, `Column`
- `Tiles`, `Tile`
- `Steps`, `Step`
- `AccordionGroup`, `Accordion`, `Expandable`
- `Badge`, `Banner`, `Panel`, `Frame`, `Update`
- `Tooltip`, `Icon`, `CodeGroup`
- `FieldGroup`, `ParamField`, `ResponseField`
- `Tree`, `Tree.Folder`, `Tree.File`
- `Color`, `Color.Item`
- `View`
- `Note`, `Tip`, `Warning`, `Info`, `Check`, `Caution`, `Important`
- `Tabs`, `TabItem`

## Build

```bash
arcane_lexicon build
arcane_lexicon build --dart-define=BASE_URL=/docs
```

The legacy demo runner still serves the repository example at `http://localhost:8081`:

```bash
dart tool/arcane_lexicon_demo.dart
```

## Package docs coverage

The package examples and matching reference docs live in:

- `example/content/reference` (API + behavior reference)
- `example/content/features` (visual examples)
- `example/content/guide` (workflow-oriented setup and utility usage)

## License

GPL-3.0
