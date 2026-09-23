# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [x.x.x]

### Changed

- Markdown text extraction reads Arcane Jaspr's Flutter-style `Text.data` property.
- The themed page state reads `widget`, and navigation layouts use numeric
  `spacing` while retaining their stretched columns.
- Setup examples resolve Arcane Jaspr and their renderer from the same local
  checkout and explain the consuming site's required core override.

### Fixed

- Long linked headings wrap on narrow screens while their anchor links remain visible.
- Component snippets use the current button, rating, and related-page APIs.
- Build commands use Jaspr's `--dart-define` option.
- Route loading filters to Markdown before decoding files, so binary images and
  macOS metadata in the content directory do not break static builds.
- Render contracts mount an Arcane theme provider and require published navigation
  labels to render.
- The example font stacks include system fallbacks, and starter CSS defines font
  tokens without circular references through Arcane aliases.
- The example dependency helper includes its knowledge-base and NeuBrutalism
  packages when selecting remote dependencies.

## [2.0.0] - 2026-08-31

### Added

- Design-contract tests prevent decorative gradients, colored glows, pill
  labels, rounded one-sided borders, remote font loading, and retired nested
  surface markup from returning to the default knowledge-base layer.
- A Playwright policy checks every generated example route at 375, 768, and
  1440 pixels, including sidebar, search, theme, and disclosure states. Its
  mutation tests cover each forbidden visual treatment before deployment.
- A writing-policy test rejects AI citation tokens, AI-referrer query
  parameters, and high-confidence stock assistant phrases in published copy.
- **Markdown Alert Styles**
  - Added CSS styles for `markdown-alert` classes (jaspr_content's built-in GitHub-style callouts)
  - Supports all 5 alert types: note (blue), tip (green), important (purple), warning (amber), caution (red)
  - Dark mode support with appropriate color adjustments
  - These styles complement the existing `kb-callout` styles for CalloutExtension
- **Search Index Export**
  - `SearchIndexGenerator` - Generates a `search-index.json` file from the navigation manifest
  - Automatically writes `web/search-index.json` during build (enabled by default)
  - JSON includes: title, path, category, description, keywords, excerpt, and icon for each page
  - Enables external sites to fetch and search documentation content
  - Can be disabled via `generateSearchIndex: false` in `KnowledgeBaseApp.create()`

### Changed

- Disclosure summaries now render one semantic icon at most, search focus uses
  an outline instead of a shadow ring, and nested rich surfaces collapse to
  the outer frame.
- Card, Tile, and View rich-markdown components now render icon markup only
  when the author supplies an `icon` attribute.
- Neon theme documentation now defines the green-and-grayscale, flat-surface
  contract and explicitly excludes gradients, glows, and frosted glass.
- Rich-markdown columns now use fixed one-to-four-column classes, and color
  swatches use the dedicated flat-background field instead of raw style maps.
- Draft and hidden content is now excluded from static routes, serialized
  manifests, page navigation, related pages, subpages, sidebars, and search.
- Panels and inline icon components no longer invent a decorative icon when no
  icon is requested.
- Knowledge-base cards, tiles, resources, related pages, subpages, previous and
  next navigation, callouts, panels, fields, trees, and landing content now use
  flat rows, neutral dividers, and open sections.
- Card, tile, resource, banner, and changelog markup no longer renders icon
  backplates, redundant trailing indicators, or framed badge treatments.
- Generated projects and the example site now use local or system font stacks;
  Lexicon no longer injects stylesheet-provided remote font URLs.
- Page navigation, related-page lists, changelog entries, and rating prompts now
  use neutral divider elements instead of public one-sided border style fields.
- Search results are built with text-safe DOM nodes and expose combobox/listbox
  state; code-copy and rating feedback now announce their state to assistive
  technology.
- README and example prose now use direct technical descriptions in place of
  promotional filler.

### Fixed

- Static builds now emit the configured subpath as the document base, load the
  compiled client from that base, and ship the canonical Lucide WOFF2 asset at
  the generated font URL.
- Search remains reachable from the mobile sidebar when the top navigation is
  enabled, and closed drawers are inert, escape-dismissible, and synchronized
  with their toggle's expanded state.
- Removed overlay and drawer shadows from the default knowledge-base chrome so
  hidden search and mobile states follow the flat-surface contract.
- The example binds `jaspr_content` typography tokens to the bundled Arcane
  font families instead of inheriting its Open Sans and JetBrains Mono stacks.

### Removed

- Removed raw SVG markup and local or remote SVG URL support from navigation
  icons. Page and section navigation icons now accept one built-in Lucide icon
  name and render exclusively through `KBIcon`.
- Removed the remote Lucide font fallback, the public `KBTagChip` API, and the
  `PathChip` rich-markdown alias.
- Removed Lucide fallback-path expansion from asset URL rewriting. Lexicon now
  prefixes only the canonical `/assets/fonts/lucide/lucide.woff2` URL supplied
  by the active stylesheet and does not repair unsupported sources.
- Removed the public `sparkles` icon name and its documentation.
- Removed `NavSection.fromYaml` and the retired `Fields`, `TreeItem`, and
  `ColorItem` rich-markdown aliases without compatibility shims.
- Decorative component gradients, frosted surfaces, colored glow shadows, pill
  tag and badge shapes, and nested framed-card styling from `KBStyles`.

## [1.4.0] - 2026-08-18

### Fixed

- Example docs site failed to compile (and broke the GitHub Pages deploy):
  `main.server.dart` still constructed `ShadcnKnowledgeBaseRenderers`,
  `NeonKnowledgeBaseRenderers`, and `NeubrutalismKnowledgeBaseRenderers`,
  which moved to the `arcane_jaspr_kb` package. The example now depends on
  and imports `arcane_jaspr_kb`.
- Rounded callouts, active navigation, and top-bar groups no longer use
  one-sided borders, clipped hotspots, or asymmetric inset highlights. Status
  is expressed with complete perimeter borders, fills, icon tiles, and
  symmetric rings.
- Single-stylesheet knowledge bases (those passing only `stylesheet:` to `KnowledgeBaseApp.create`, with no `stylesheetOptions`) rendered a completely blank page. The style-slot system synthesizes one slot with id `default`, but the active-slot id resolved to `''` on both the server (`KBLayout`) and the client runtime (`_fallbackStylesheetId`), so no slot ever matched and every slot stayed `display:none`/`hidden`. A single synthesized slot is now always active server-side, and the client fallback id is `default`, so single-theme docs render correctly. Multi-stylesheet sites are unaffected.
- `DefaultKnowledgeBaseRenderers.showTopBarBranding` returned a hardcoded `false`, so KBs using the default renderers (e.g. single-stylesheet apps) left the top bar's left side empty (only a desktop-hidden hamburger) and pushed the brand into the sidebar. It now returns `data.showNavigationBar && data.useTopPosition` (matching the shadcn/neon/neubrutalism renderers), so the brand renders top-left in the standard position when the nav bar is top-positioned.

### Added

- Opt-in `autoHide` on the documentation top bar (`KBTopBar` and `KnowledgeBaseRenderers.topBar`), default `false`. When enabled, the top bar hides on scroll-down and reappears on scroll-up (via a `data-kb-autohide` marker, scoped CSS, and a throttled scroll-direction handler). The default (always-visible sticky bar) is unchanged.

### Changed

- **ArcaneJaspr typed `classes` compatibility.** Updated for `arcane_jaspr`'s wrapper widgets (`ArcaneDiv`/`ArcaneSpan`/`ArcaneParagraph`/`ArcaneHeading`/`ArcaneLink`/…) now taking `classes: List<String>?` instead of `String?`. Every internal `classes:` argument across the layout (`kb_page_nav`, `kb_changelog`, `kb_related_pages`, `kb_rating`, `kb_layout`) and rich-markdown components now passes a single-element list, so the rendered `class="..."` output is byte-identical. Requires the corresponding `arcane_jaspr` release; bump the `arcane_jaspr` constraint once it is published.
- `NeonKnowledgeBaseRenderers` simplified to use the standard `DefaultKnowledgeBaseRenderers` docs chrome (top bar / sidebar / content), matching `ShadcnKnowledgeBaseRenderers`. Removed the bespoke `shell`/`neonMobileDock`/rail/stage/command-drawer overrides (the `neon-kb-nav-rail`, `neon-kb-stage`, `neon-kb-mobile-dock`, etc. layout) whose styling had been retired, so the Neon docs no longer render an unstyled, collapsed chrome. The Neon theme now styles the standard `kb-*` chrome.

### Removed

- Theme-specific `KnowledgeBaseRenderers` (`ShadcnKnowledgeBaseRenderers`, `NeonKnowledgeBaseRenderers`, `NeubrutalismKnowledgeBaseRenderers`, `Win95KnowledgeBaseRenderers`) moved out of lexicon into their respective `arcane_jaspr` theme packages, which now depend on `arcane_lexicon` and extend the exported `DefaultKnowledgeBaseRenderers`. Consumers pass them explicitly via `KBStylesheetOption.knowledgeBaseRenderers`. The internal `_defaultRenderersFor` id-switch (which auto-resolved `shadcn`/`neon`/`neubrutalism`) is gone; a stylesheet option without an explicit renderer now falls back to `DefaultKnowledgeBaseRenderers`.

## [1.3.0] - 2026-03-13

### Changed

- **ArcaneJaspr 3.1 Surface Compatibility**
  - Updated `arcane_lexicon` to work with the Flutter-first `arcane_jaspr` primary import
  - Layout and rich markdown files now import low-level Jaspr and HTML surfaces explicitly instead of assuming raw `Component`, DOM helpers, and HTML wrappers come from `package:arcane_jaspr/arcane_jaspr.dart`
  - Adjusted the public export surface to avoid the `State` export collision introduced by the new Flutter-shaped base types

### Fixed

- **Docs Pipeline Compatibility**
  - Restored analyzer compatibility after the ArcaneJaspr surface split so the docs package no longer fails on missing `Component`, `ArcaneDiv`, `ArcaneLink`, or raw DOM helpers

## [1.0.0] - 2025-01-11

### Added

- **Core Features**
  - Auto-generated navigation from directory structure
  - YAML frontmatter support (title, description, order, icon, hidden, tags, author, date, draft)
  - Section configuration via `_section.json5` or `_section.yaml`
  - Dark/light theme with toggle
  - 1-line theme configuration using arcane_jaspr stylesheets

- **Navigation**
  - Sidebar with collapsible sections and tree view
  - Breadcrumb navigation
  - Previous/next page links
  - Table of contents auto-generation
  - Full-text search with keyboard shortcut (Cmd/Ctrl+K)

- **Content**
  - Markdown rendering with syntax highlighting
  - Code block copy buttons
  - Callout/admonition blocks (NOTE, TIP, WARNING, IMPORTANT, CAUTION)
  - Reading time calculation
  - Tags with visual badges
  - Related pages based on shared tags
  - Draft mode with banner

- **Components**
  - `KnowledgeBaseApp` - Main app factory
  - `SiteConfig` - Site configuration
  - `KBLayout` - Page layout
  - `KBSidebar` - Navigation sidebar
  - `KBPageNav` - Previous/next navigation
  - `KBSubpages` - Child pages grid
  - `KBRelatedPages` - Tag-based related content
  - `KBChangelog` - Changelog display component

- **Utilities**
  - `NavBuilder` - Navigation manifest generator
  - `SitemapGenerator` - Sitemap XML generation
  - `ChangelogParser` - Keep a Changelog format parser
  - `CalloutExtension` - GitHub-style admonition blocks
  - `ReadingTimeExtension` - Reading time calculator

- **Styling**
  - ShadCN-based theming via arcane_jaspr
  - Responsive design with mobile sidebar
  - Nested folder tree visualization
  - Back-to-top button
  - Edit on GitHub links

## [1.0.1] - 2025-01-13

### Added

- **Page Metadata**
  - Automatic file last modified date tracking (`lastModified` field)
  - "Updated Jan 15, 2025" display in page metadata section
  - Author and date fields now properly passed through NavItem for all pages

- **Page Rating System**
  - New `KBRating` component with thumbs up/down buttons
  - `RatingConfig` class for customization
  - Client-side JavaScript with localStorage tracking to prevent duplicate votes
  - Custom `kb-rating` event dispatched for Firebase/backend integration
  - New SiteConfig options: `ratingEnabled`, `ratingPromptText`, `ratingThankYouText`

- **Documentation**
  - New Rating System reference page with Firebase integration guide
  - Updated Frontmatter reference with `lastModified` auto-generated field
  - Updated SiteConfig reference with page rating options

- **Development**
  - IntelliJ run configurations for Serve (port 8085), Build, and Kill

- **CI/CD**
  - GitHub Action to automatically update frontmatter `date` and `author` fields on push to master
  - Runs on markdown file changes in `example/content/`
  - Prevents infinite loops with commit message detection

- **Media Embeds**
  - New `MediaExtension` for rich media content in markdown
  - YouTube video embeds: `@[youtube](VIDEO_ID)` with autoplay, loop, muted, start/end options
  - Local video support: `@[video](path.mp4)` with poster, caption, autoplay, loop, muted
  - Enhanced images: `@[image caption="..."](path.png)` with captions, alt text, dimensions
  - GIF support: `@[gif](animation.gif)`
  - Animated PNG support: `@[apng](animation.png)`
  - Twitter/X embeds: `@[twitter](TWEET_ID)` with theme options
  - Generic iframe embeds: `@[iframe](url)`
  - Responsive 16:9 aspect ratio containers for video embeds
  - CSS styles for all media types with dark mode support

### Removed

- Theme toggle ripple/reveal animation (now instant toggle)

## [x.x.x]

Reserved for future changes.
