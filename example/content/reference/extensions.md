---
title: Extensions
description: Built-in page extensions and custom extension hooks
icon: code
order: 8
tags:
  - reference
  - markdown
  - extensions
---

Arcane Lexicon registers a default extension pipeline for every page.

## Default Extension Order

`KnowledgeBaseApp.create()` currently applies extensions in this order:

1. `MediaExtension`
2. `CalloutExtension`
3. `HeadingAnchorsExtension`
4. `TableOfContentsExtension`
5. `ReadingTimeExtension`

Custom extensions passed in `extensions:` are appended after these defaults.

## MediaExtension

Transforms custom media syntax:

```markdown
@[youtube](dQw4w9WgXcQ)
@[video autoplay loop muted](demo.mp4)
@[image caption="Screenshot"](image.png)
@[gif](loader.gif)
@[apng](animation.png)
@[twitter](1215212801876090880)
@[iframe title="Embed" height="500"](https://example.com/embed)
```

Supported media types:
- `youtube`
- `video`
- `image` / `img`
- `gif`
- `apng`
- `twitter` / `x`
- `iframe`

## CalloutExtension

Transforms GitHub-style callouts into GitHub alert markup and preserves rich callout tags as Arcane component callouts.

```markdown
> [!NOTE]
> Informational message.

> [!WARNING] Java 21 Required
> Use Java 21 or newer.
```

Supported types:
- `NOTE`
- `TIP`
- `IMPORTANT`
- `WARNING`
- `CAUTION`

Optional title is supported on the marker line.

## HeadingAnchorsExtension

Adds heading anchors so sections are deep-linkable.

## TableOfContentsExtension

Generates TOC data consumed by the right-side TOC panel when `SiteConfig.tocEnabled` is `true`.

## ReadingTimeExtension

Adds:
- `readingTime`
- `wordCount`

Default reading speed is `200` WPM. Link labels and emphasized text contribute their full word counts; formatting markers and link URLs do not.

```dart
KnowledgeBaseApp.create(
  config: config,
  stylesheet: stylesheet,
  extensions: const <PageExtension>[
    ReadingTimeExtension(wordsPerMinute: 250),
  ],
)
```

## Default Custom Components

In addition to extensions, Arcane Lexicon registers default custom markdown components.

See [Components](/reference/components) for complete syntax and live examples.

Registered by default:
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
- Callout tags: `Note`, `Tip`, `Warning`, `Info`, `Check`, `Caution`, `Important`
- `Tabs` and `TabItem`

## Adding Custom Extensions

```dart
class MyExtension implements PageExtension {
  const MyExtension();

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    String content = page.content;
    String updated = content.replaceAll('foo', 'bar');

    if (updated != content) {
      page.apply(content: updated);
    }

    return nodes;
  }
}
```

```dart
KnowledgeBaseApp.create(
  config: config,
  stylesheet: stylesheet,
  extensions: const <PageExtension>[
    MyExtension(),
  ],
)
```

## Syntax Highlighting Notes

Arcane Lexicon includes Highlight.js setup in `KBLayout` scripts.

Common classes are normalized for:
- `dart`
- `javascript` / `js`
- `yaml`
- `bash` / `shell`
- `json`
- `html`
- `css`
