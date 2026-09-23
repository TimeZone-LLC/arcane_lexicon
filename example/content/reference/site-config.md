---
title: SiteConfig Reference
description: Complete reference for all SiteConfig options
icon: settings
order: 1
tags:
  - configuration
  - reference
author: Arcane Arts
date: 2026-03-03
---

`SiteConfig` controls global behavior for your Arcane Lexicon site.

## Basic Example

```dart
SiteConfig(
  name: 'My Docs',
  description: 'Documentation for My Project',
  contentDirectory: 'content',
  githubUrl: 'https://github.com/myorg/myproject',
)
```

## Full Example

```dart
SiteConfig(
  name: 'My Docs',
  description: 'Documentation for My Project',
  logo: '/assets/logo.svg',
  githubUrl: 'https://github.com/myorg/myproject',
  baseUrl: '/docs',
  contentDirectory: 'content',
  landingPath: 'Landing',
  homeRoute: '/',
  searchEnabled: true,
  tocEnabled: true,
  themeToggleEnabled: true,
  defaultTheme: KBThemeMode.dark,
  primaryColor: '#3b82f6',
  footerText: 'Built with Arcane Lexicon',
  copyright: '2026 My Company',
  headerLinks: [
    NavLink(label: 'Docs', href: '/'),
    NavLink(label: 'GitHub', href: 'https://github.com/myorg/myproject', external: true),
  ],
  socialLinks: [
    SocialLink.github('https://github.com/myorg/myproject'),
    SocialLink.discord('https://discord.gg/example'),
  ],
  sidebarFooter: 'v1.2.0',
  sidebarFooterUrl: 'https://github.com/myorg/myproject/releases',
  editBranch: 'main',
  showEditLink: true,
  ratingEnabled: false,
  ratingPromptText: 'Was this page helpful?',
  ratingThankYouText: 'Thanks for your feedback!',
  pageNavEnabled: true,
  sidebarWidth: '280px',
  sidebarTreeIndent: '10px',
  navigationBarEnabled: true,
  navigationBarPosition: KBNavigationBarPosition.top,
)
```

## All Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | `String` | required | Site name |
| `description` | `String?` | `null` | Meta/site description |
| `logo` | `String?` | `null` | Optional logo path or URL |
| `githubUrl` | `String?` | `null` | Repository URL for GitHub link/edit links |
| `baseUrl` | `String` | `String.fromEnvironment('BASE_URL')` | Subpath prefix (for hosted subdirectories) |
| `contentDirectory` | `String` | `'content'` | Markdown content directory |
| `landingPath` | `String?` | `null` | Optional Markdown file or folder used as the styled home page |
| `homeRoute` | `String` | `'/'` | Home route |
| `searchEnabled` | `bool` | `true` | Enable search input/logic |
| `tocEnabled` | `bool` | `true` | Enable right-side TOC |
| `themeToggleEnabled` | `bool` | `true` | Show theme toggle button |
| `defaultTheme` | `KBThemeMode` | `KBThemeMode.dark` | Initial theme |
| `primaryColor` | `String?` | `null` | Optional theme accent override |
| `footerText` | `String?` | `null` | Footer text |
| `copyright` | `String?` | `null` | Copyright text |
| `headerLinks` | `List<NavLink>` | `[]` | Top navigation links |
| `socialLinks` | `List<SocialLink>` | `[]` | Social links data |
| `sidebarFooter` | `String?` | `null` | Sidebar bottom text |
| `sidebarFooterUrl` | `String?` | `null` | Sidebar bottom link |
| `editBranch` | `String` | `'main'` | Git branch used by edit links |
| `showEditLink` | `bool` | `true` | Show/hide "Edit this page" links |
| `ratingEnabled` | `bool` | `false` | Enable rating widget |
| `ratingPromptText` | `String` | `'Was this page helpful?'` | Rating prompt text |
| `ratingThankYouText` | `String` | `'Thanks for your feedback!'` | Rating thank-you text |
| `pageNavEnabled` | `bool` | `true` | Enable footer prev/next navigation globally |
| `sidebarWidth` | `String` | `'280px'` | Sidebar width |
| `sidebarTreeIndent` | `String` | `'10px'` | Sidebar tree/link indent |
| `navigationBarEnabled` | `bool` | `true` | Enable top/bottom navigation bar |
| `navigationBarPosition` | `KBNavigationBarPosition` | `KBNavigationBarPosition.top` | Navigation bar position |

## Default Layout Consumption Notes

`SiteConfig` exposes some fields that are currently not consumed by the default `KBLayout` rendering path:

- `homeRoute`
- `primaryColor`
- `footerText`
- `copyright`
- `socialLinks`
- `sidebarFooter`
- `sidebarFooterUrl`

You can still use these fields in custom layouts/components.

## Enums

```dart
enum KBThemeMode { dark, light, system }
enum KBNavigationBarPosition { top, bottom }
```

## NavLink

```dart
NavLink(
  label: 'GitHub',
  href: 'https://github.com/ArcaneArts/arcane_lexicon',
  external: true,
)
```

## SocialLink

```dart
SocialLink(name: 'Discord', url: 'https://discord.gg/example', icon: 'message-circle')
SocialLink.github('https://github.com/ArcaneArts/arcane_lexicon')
SocialLink.twitter('https://x.com/arcanearts')
SocialLink.discord('https://discord.gg/example')
SocialLink.youtube('https://youtube.com/@arcanearts')
```

## BASE_URL and Subpath Hosting

`baseUrl` defaults to `BASE_URL` from build defines:

```bash
jaspr build --dart-define=BASE_URL=/docs
```

This keeps one config working for both local root hosting and deployed subpath hosting.

## Helper Methods

### `fullPath(String path)`

Adds `baseUrl` prefix when needed.

```dart
config.fullPath('/guide') // '/docs/guide' when baseUrl is '/docs'
```

### `assetPrefix`

Computed getter for static asset prefix.

### `editUrl(String pagePath)`

Builds GitHub edit URL when `githubUrl` is set and `showEditLink` is `true`.

```dart
config.editUrl('/guide/basics/installation')
// https://github.com/.../edit/main/content/guide/basics/installation.md
```
