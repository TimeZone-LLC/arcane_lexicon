---
title: Theming
description: Stylesheet configuration and theme customization
icon: sliders
order: 6
tags:
  - configuration
  - theming
  - styling
author: Arcane Arts
date: 2025-01-11
---

Arcane Lexicon uses the arcane_jaspr stylesheet system for theming. Swap themes with a single line of code.

## Basic Usage

```dart
import 'package:arcane_jaspr_shadcn/arcane_jaspr_shadcn.dart';
import 'package:arcane_lexicon/arcane_lexicon.dart' hide runApp;
import 'package:jaspr/server.dart';

Future<void> main() async {
  Jaspr.initializeApp();

  runApp(
    await KnowledgeBaseApp.create(
      config: const SiteConfig(name: 'My Docs'),
      stylesheet: const ShadcnStylesheet(theme: ShadcnTheme.midnight),
    ),
  );
}
```

## Available Stylesheets

### ShadcnStylesheet

The shadcn/ui-based theme uses:
- Rounded corners and minimal shadows
- Border-focused design
- Inter font family
- Multiple color themes

```dart
stylesheet: const ShadcnStylesheet(theme: ShadcnTheme.midnight)
```

### NeonStylesheet

QualityNode's restrained game-server theme:
- Green accents on grayscale surfaces
- Flat panels with neutral dividers
- Local or system fonts only
- No gradients, glow effects, or frosted glass

```dart
stylesheet: const NeonStylesheet(theme: NeonTheme.green)
```

### NeubrutalismStylesheet

Comic-book inspired NeuBrutalism aesthetic with bold flat colors:
- Thick black borders (2-4px solid)
- Hard-offset drop shadows (no blur)
- Press-down interaction on `:active` (translate + shadow shrink)
- Pop-art saturated palettes paired with pure black/white
- Archivo Black headings, Space Grotesk body, JetBrains Mono code

```dart
stylesheet: const NeubrutalismStylesheet(theme: NeubrutalismTheme.yellow)
```

## ShadcnTheme Options

### Neutral Themes

These themes use auto-tinted surfaces derived from the primary color:

| Theme | Description |
|-------|-------------|
| `midnight` | OLED black/pure white - maximum contrast |
| `charcoal` | Softer dark with off-black - easier on eyes |
| `cream` | Warm cream/ivory tones |
| `slate` | Cool slate/gray - professional |

### Pastel Themes

Colored surfaces with matching accents:

| Theme | Description |
|-------|-------------|
| `rose` | Soft rose/pink pastel |
| `lavender` | Soft lavender/purple |
| `mint` | Soft mint/green |
| `sky` | Soft sky/blue |
| `peach` | Soft peach/orange |
| `teal` | Soft teal/cyan |

### Examples

```dart
// OLED-optimized (pure black dark mode)
ShadcnStylesheet(theme: ShadcnTheme.midnight)

// Warm and inviting
ShadcnStylesheet(theme: ShadcnTheme.cream)

// Cool and professional
ShadcnStylesheet(theme: ShadcnTheme.slate)

// Colorful pastel
ShadcnStylesheet(theme: ShadcnTheme.lavender)
```

## NeonTheme Options

Neon has one intentionally constrained brand palette:

| Theme | Color | Description |
|-------|-------|-------------|
| `green` | `#059669` | QualityNode emerald (default and only option) |

### Examples

```dart
// QualityNode emerald with grayscale surfaces
NeonStylesheet(theme: NeonTheme.green)
```

## NeubrutalismTheme Options

Bold pop-art accent colors paired with thick black borders and hard shadows:

| Theme | Color | Description |
|-------|-------|-------------|
| `yellow` | `#FFD23F` | High-vis yellow (default) |
| `pink` | `#FF6B9D` | Hot bubblegum pink |
| `mint` | `#95E1D3` | Cool mint green |
| `orange` | `#FF8C42` | Warm pop-art orange |
| `sky` | `#6FB3FF` | Cool electric blue |
| `lavender` | `#B983FF` | Saturated purple |
| `lime` | `#C1FF72` | Acid lime green |
| `red` | `#FF4747` | Pure stop-sign red |

### Examples

```dart
// Default high-vis yellow
NeubrutalismStylesheet(theme: NeubrutalismTheme.yellow)

// Bubblegum pop
NeubrutalismStylesheet(theme: NeubrutalismTheme.pink)

// Acid lime
NeubrutalismStylesheet(theme: NeubrutalismTheme.lime)
```

## Theme Toggle

Users can toggle between light and dark modes using the theme toggle button in the sidebar. The preference is saved to localStorage.

### Configuration

```dart
SiteConfig(
  name: 'My Docs',
  themeToggleEnabled: true,        // Show toggle (default: true)
  defaultTheme: KBThemeMode.dark,  // Initial theme
)
```

### KBThemeMode Options

| Mode | Description |
|------|-------------|
| `dark` | Start in dark mode |
| `light` | Start in light mode |
| `system` | Follow system preference |

## Font Customization

Arcane Lexicon does not load remote font stylesheets. Define `@font-face`
rules in your site's `web/styles.css`, serve the files from `web/assets/fonts/`,
and override `--font-sans`, `--font-heading`, and `--font-mono` there. Theme font
names are fallbacks only; a production site must provide its chosen local assets.

## Custom CSS

Add custom styles via a `/styles.css` file in your web directory:

```css
/* Custom overrides */
.prose h1 {
  color: var(--primary);
}

.kb-sidebar {
  background: var(--surface);
}
```

## CSS Variables

The stylesheets expose CSS variables for customization:

### Colors

```css
--primary          /* Primary accent color */
--primary-foreground
--background       /* Page background */
--foreground       /* Text color */
--muted            /* Muted backgrounds */
--muted-foreground /* Muted text */
--border           /* Border color */
--ring             /* Focus ring color */
```

### Typography

```css
--font-sans        /* Body font */
--font-mono        /* Code font */
--font-heading     /* Heading font (Neon only) */
```

### Spacing and Radius

```css
--radius-sm
--radius-md
--radius-lg
--radius-xl
```

## Dark Mode Classes

The themes add a `.dark` class to the root element in dark mode:

```css
/* Light mode styles */
.my-component {
  background: white;
}

/* Dark mode styles */
.dark .my-component {
  background: black;
}
```

## Theme Persistence

Theme preference is stored in localStorage under the key `arcane-theme-mode`. The stored value is either `'dark'` or `'light'`.

## Syntax Highlighting

Code blocks use Highlight.js for syntax highlighting. All stylesheets include theme-appropriate colors:

- **ShadcnStylesheet**: GitHub-style highlighting (light in light mode, dark in dark mode)
- **NeonStylesheet**: Neon terminal-style highlighting with primary color accents
- **NeubrutalismStylesheet**: Flat high-contrast palette with hard borders and accent-tinted code backgrounds
