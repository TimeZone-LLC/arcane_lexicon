---
title: Code Blocks
description: Syntax highlighting for multiple languages
icon: code
order: 3
tags:
  - code
  - syntax-highlighting
  - markdown
author: Arcane Arts
date: 2025-01-11
---

Code blocks are automatically syntax highlighted using Highlight.js. Hover over any code block to see the **copy button** in the top-right corner.

> [!TIP]
> Click the copy icon to copy code to your clipboard. The icon changes to a checkmark for 2 seconds to confirm.

## Dart

```dart
import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/html.dart' show ArcaneDiv;

class Example extends StatelessWidget {
  final String title;

  const Example({required this.title});

  @override
  Widget build(BuildContext context) => ArcaneDiv(
    classes: const <String>['example'],
    children: [Text(title)],
  );
}
```

## JavaScript

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
  return { greeting: `Hello, ${name}!` };
}
```

## YAML

```yaml
dependencies:
  arcane_lexicon:
    git:
      url: https://github.com/ArcaneArts/arcane_lexicon
```

## Bash

```bash
cd example && jaspr serve
```

## JSON

```json
{
  "name": "arcane_lexicon",
  "version": "1.0.0",
  "dependencies": {}
}
```

## Supported Languages

- Dart
- JavaScript / TypeScript
- YAML
- JSON
- Bash / Shell
- HTML
- CSS
- Markdown
