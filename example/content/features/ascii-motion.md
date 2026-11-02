---
title: Ascii Motion
description: A live example of the Ascii orbit, entrance, datum, and text components
order: 9
component: AsciiMotion
tags:
  - ascii
  - motion
  - theming
---

Choose **Ascii** from the stylesheet menu to see the live example. Pause the
motion or replay the entrance with the controls above. The theme toggle switches
between paper and ink.

## A quiet background

`AsciiOrbit` draws fine circular lines and moves its children along them. Its
labels stay upright as they travel. Use it for a short introduction or a visual
pause between sections; omit the children for the default character marks.

```dart
AsciiOrbit(
  children: const <Widget>[Text('Ascii')],
)
```

## Content entering the page

`AsciiReveal` brings a heading or a short block into place with a small vertical
movement. A brief delay can separate a heading from its supporting text.

```dart
AsciiReveal(
  delay: const Duration(milliseconds: 100),
  child: Text('The supporting text follows the heading.'),
)
```

## Labels and rules

Use `AsciiText` for short labels and `AsciiDatum` to connect a label to a value.
Body text and headings use the proportional theme font; the small labels use
monospaced type.

```dart
const AsciiText('Paper / ink / motion')

const AsciiDatum(
  label: 'Theme',
  value: 'Ascii',
)
```

## Motion preferences

The components respect `prefers-reduced-motion`. The full text and line work
remain visible without animation. Pass `animated: false` to `AsciiOrbit`,
`AsciiReveal`, or `AsciiDatum` to disable their motion explicitly. For text,
use `AsciiTextMotion.none`.

See [the stylesheet setup](/reference/theming#asciistylesheet) to use Ascii in
your own documentation site.
