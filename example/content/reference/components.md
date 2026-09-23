---
title: Components
description: Complete component catalog for Arcane Lexicon
icon: layers
order: 7
tags:
  - reference
  - components
  - markdown
  - layout
---

Arcane Lexicon ships two component layers:

1. Rich markdown components available directly in `.md` files.
2. Dart layout components you can use when composing custom layouts.

## Rich Markdown Components

The following components are registered by default through `KBRichMarkdownComponents.defaults()`.

### Link Rows

#### CardGroup + Card

```markdown
<CardGroup>
  <Card title="Quick Start" href="/guide/basics/installation" icon="rocket">
    Install and launch your docs app.
  </Card>
  <Card title="GitHub" href="https://github.com/ArcaneArts/arcane_lexicon" icon="github">
    External links use the same quiet row treatment.
  </Card>
</CardGroup>
```

<CardGroup>
  <Card title="Quick Start" href="/guide/basics/installation" icon="rocket">
    Install and launch your docs app.
  </Card>
  <Card title="SiteConfig" href="/reference/site-config" icon="settings">
    Configure global behavior and layout toggles.
  </Card>
  <Card title="GitHub" href="https://github.com/ArcaneArts/arcane_lexicon" icon="github">
    External links use the same quiet row treatment.
  </Card>
</CardGroup>

#### Tiles + Tile

```markdown
<Tiles>
  <Tile title="Docs" href="/" icon="book">Internal navigation tile.</Tile>
  <Tile title="Discord" href="https://discord.gg/arcane" icon="message-circle">External support link.</Tile>
  <Tile title="Status" icon="activity">Tile without href acts as static content.</Tile>
</Tiles>
```

<Tiles>
  <Tile title="Docs" href="/" icon="book">Internal navigation tile.</Tile>
  <Tile title="Discord" href="https://discord.gg/arcane" icon="message-circle">External support link.</Tile>
  <Tile title="Status" icon="activity">Tile without href acts as static content.</Tile>
</Tiles>

### Layout Blocks

#### Columns + Column

```markdown
<Columns cols={2}>
  <Column>Left column content.</Column>
  <Column>Right column content.</Column>
</Columns>
```

<Columns cols={2}>
  <Column>
    <Panel title="Left" icon="columns">Column layout is responsive and stacks on mobile.</Panel>
  </Column>
  <Column>
    <Panel title="Right" icon="columns">Use this for side-by-side comparisons.</Panel>
  </Column>
</Columns>

#### Steps + Step

```markdown
<Steps>
  <Step title="Install dependency">Add `arcane_lexicon` to `pubspec.yaml`.</Step>
  <Step title="Run dev server">Execute `jaspr serve`.</Step>
</Steps>
```

<Steps>
  <Step title="Install dependency">Add `arcane_lexicon` to `pubspec.yaml`.</Step>
  <Step title="Run dev server">Execute `jaspr serve`.</Step>
  <Step title="Verify output">Confirm navigation, callouts, and cards render.</Step>
</Steps>

#### AccordionGroup + Accordion

```markdown
<AccordionGroup>
  <Accordion title="Can this contain markdown?">Yes.</Accordion>
  <Accordion title="Can it start open?" defaultOpen={true}>Yes.</Accordion>
</AccordionGroup>
```

<AccordionGroup>
  <Accordion title="Can this contain markdown?">Yes. Tables, code fences, and links are supported.</Accordion>
  <Accordion title="Can it start open?" defaultOpen={true}>Set `defaultOpen={true}`.</Accordion>
</AccordionGroup>

#### Expandable

```markdown
<Expandable title="More details" defaultOpen={false}>
  Hidden content until expanded.
</Expandable>
```

<Expandable title="More details" defaultOpen={false}>
  Use this when you only need one collapsible block and do not need an accordion group.
</Expandable>

### Status and Content Wrappers

#### Badge

```markdown
<Badge color="info">Beta</Badge>
<Badge color="success">Stable</Badge>
<Badge color="warning">Preview</Badge>
<Badge color="danger">Breaking</Badge>
```

<Badge color="info">Beta</Badge>
<Badge color="success">Stable</Badge>
<Badge color="warning">Preview</Badge>
<Badge color="danger">Breaking</Badge>

#### Banner

```markdown
<Banner title="Deployment" href="/guide/basics/running" type="info">
  Review runtime and build commands.
</Banner>
```

<Banner title="Deployment" href="/guide/basics/running" type="info">
  Review runtime and build commands.
</Banner>

#### Panel

```markdown
<Panel title="Implementation Notes" icon="panel">
  Group related text with a titled wrapper.
</Panel>
```

<Panel title="Implementation Notes" icon="panel">
  Group related text with a titled wrapper.
</Panel>

#### Frame

```markdown
<Frame label="Preview" caption="Optional caption text.">
  Content goes here.
</Frame>
```

<Frame label="Preview" caption="Optional caption text.">
  Frame content supports standard markdown.
</Frame>

#### Update

```markdown
<Update label="Last updated" date="2026-03-03">
  Changelog summary.
</Update>
```

<Update label="Last updated" date="2026-03-03">
  This component is useful for release notes or page maintenance history.
</Update>

### API and Data Display

#### FieldGroup + ParamField + ResponseField

```markdown
<FieldGroup>
  <ParamField query="page" type="number" required={true}>Page number.</ParamField>
  <ResponseField name="items" type="array">Returned items.</ResponseField>
</FieldGroup>
```

<FieldGroup>
  <ParamField query="page" type="number" required={true}>Page number.</ParamField>
  <ParamField body="filter" type="object">Optional filter object.</ParamField>
  <ResponseField name="items" type="array" required={true}>Returned items.</ResponseField>
</FieldGroup>

#### Tree + Tree.Folder + Tree.File

```markdown
<Tree>
  <Tree.Folder name="content" defaultOpen={true}>
    <Tree.File name="index.md" />
    <Tree.File name="guide/installation.md" />
  </Tree.Folder>
</Tree>
```

<Tree>
  <Tree.Folder name="content" defaultOpen={true}>
    <Tree.File name="index.md" />
    <Tree.File name="guide/installation.md" />
  </Tree.Folder>
</Tree>

#### Color + Color.Item

```markdown
<Color>
  <Color.Item label="Primary" value="#3b82f6" />
  <Color.Item label="Success" value="#22c55e" />
</Color>
```

<Color>
  <Color.Item label="Primary" value="#3b82f6" />
  <Color.Item label="Success" value="#22c55e" />
  <Color.Item label="Warning" value="#f59e0b" />
</Color>

#### View

```markdown
<View title="Configuration Snapshot">
  Any markdown content can be wrapped.
</View>
```

<View title="Configuration Snapshot">
  Use this as a labeled container for grouped output.
</View>

### Inline and Utility Components

#### Tooltip

```markdown
<Tooltip tip="Native tooltip text">Hover me</Tooltip>
```

<Tooltip tip="Native tooltip text">Hover me</Tooltip>

#### Icon

```markdown
<Icon name="server" size="sm" />
```

<Icon name="server" size="sm" />
<Icon name="palette" size="sm" />
<Icon name="lightbulb" size="sm" />

#### Kbd

```markdown
Press <Kbd>⌘</Kbd> + <Kbd>K</Kbd> to focus search.
```

Press <Kbd>⌘</Kbd> + <Kbd>K</Kbd> to focus search.

#### FilePath

```markdown
Edit <FilePath>content/reference/components.md</FilePath> before rebuilding.
```

Edit <FilePath>content/reference/components.md</FilePath> before rebuilding.

#### Endpoint

```markdown
<Endpoint method="GET" path="/api/docs/search-index.json" />
<Endpoint method="POST" path="/api/feedback/rating" />
```

<Endpoint method="GET" path="/api/docs/search-index.json" />
<Endpoint method="POST" path="/api/feedback/rating" />

#### ResourceGrid + Resource

```markdown
<ResourceGrid>
  <Resource title="Authoring Guide" href="/guide/basics/configuration" icon="book-open" label="Guide">
    Frontmatter, section config, and site config basics.
  </Resource>
  <Resource title="Sitemap Utility" href="/guide/advanced/sitemap" icon="globe" label="SEO">
    Build sitemap XML for production docs deployments.
  </Resource>
</ResourceGrid>
```

<ResourceGrid>
  <Resource title="Authoring Guide" href="/guide/basics/configuration" icon="book-open" label="Guide">
    Frontmatter, section config, and site config basics.
  </Resource>
  <Resource title="Sitemap Utility" href="/guide/advanced/sitemap" icon="globe" label="SEO">
    Build sitemap XML for production docs deployments.
  </Resource>
</ResourceGrid>

#### CodeGroup

````markdown
<CodeGroup title="CLI">
```bash
jaspr serve
```
```bash
jaspr build --dart-define=BASE_URL=/docs
```
</CodeGroup>
````

<CodeGroup title="CLI">
```bash
jaspr serve
```
```bash
jaspr build --dart-define=BASE_URL=/docs
```
</CodeGroup>

### Callout Tag Components

Callout tag components are available in addition to GitHub callout markdown syntax.

Supported tags:
- `Note`
- `Tip`
- `Warning`
- `Info`
- `Check`
- `Caution`
- `Important`

```markdown
<Warning title="Java 21 Required">
  Use Java 21 or newer.
</Warning>
```

<Note title="Callout Tag">
  Tag-based callouts are rendered with Arcane Lucide icons.
</Note>

<Tip title="Pro Tip">
  Use `title` to override the default heading text.
</Tip>

<Info title="Info Alias">
  `Info` renders as the note style variant.
</Info>

<Check title="Check Alias">
  `Check` renders as the tip style variant.
</Check>

<Warning title="Warning">
  Warning callout tags are available directly in markdown.
</Warning>

<Caution title="Caution">
  Caution callouts use the danger-style icon treatment.
</Caution>

<Important title="Important">
  Important callouts use the circle-alert icon treatment.
</Important>

### Tabs

`Tabs` is provided via `jaspr_content/components/tabs.dart` and is included in defaults.

```markdown
<Tabs defaultValue="one">
  <TabItem label="First" value="one">First tab content</TabItem>
  <TabItem label="Second" value="two">Second tab content</TabItem>
</Tabs>
```

<Tabs defaultValue="one">
  <TabItem label="First" value="one">First tab content</TabItem>
  <TabItem label="Second" value="two">Second tab content</TabItem>
</Tabs>

## Dart Layout Components

These components are available for custom layout composition in Dart.

### KBLayout

Main page layout used when frontmatter sets `layout: kb`.

```dart
KBLayout(
  config: config,
  manifest: manifest,
  stylesheet: stylesheet,
)
```

### KBPageNav

Sequential previous/next navigation based on sorted visible pages.

- Global toggle: `SiteConfig.pageNavEnabled`
- Per-page override: frontmatter `pageNav: true|false`

```dart
KBPageNav(
  config: config,
  manifest: manifest,
  currentPath: '/guide/basics/installation',
)
```

### KBSidebar + KBTopBar

Navigation chrome components used by the default layout.

- `navigationBarEnabled`
- `navigationBarPosition` (`top` or `bottom`)

```dart
KBSidebar(
  config: config,
  manifest: manifest,
  currentPath: '/reference/components',
  showSearch: true,
  showThemeToggle: true,
)
```

```dart
KBTopBar(
  config: config,
  currentPath: '/reference/components',
)
```

### KBRating

Thumbs up/down rating block controlled by:

- `SiteConfig.ratingEnabled`
- `SiteConfig.ratingPromptText`
- `SiteConfig.ratingThankYouText`

```dart
KBRating(
  pagePath: '/reference/components',
  config: RatingConfig(
    promptText: config.ratingPromptText,
    thankYouText: config.ratingThankYouText,
  ),
)
```

### KBChangelog

Renderable timeline view for parsed changelog entries.

```dart
const ChangelogParser parser = ChangelogParser();
final List<ChangelogVersion> versions = parser.parse(changelogMarkdown);

KBChangelog(
  versions: versions,
  maxVersions: 5,
  githubUrl: config.githubUrl,
)
```

### KBSubpages and KBRelatedPages

Both are exported and available for custom layouts.

- `KBSubpages` shows children for the current section.
- `KBRelatedPages` computes similarity from shared tags.

These are not auto-injected by the default layout; use them explicitly in custom layout composition if needed.

```dart
KBSubpages(
  config: config,
  manifest: manifest,
  currentPath: '/guide',
)
```

```dart
KBRelatedPages(
  config: config,
  manifest: manifest,
  currentPath: '/guide/basics/configuration',
  currentTags: const <String>['configuration'],
)
```

### DemoBuilder

Use `KnowledgeBaseApp.create(..., demoBuilder: ...)` and page frontmatter `component: ...` to render live Dart components above markdown content.

```dart
KnowledgeBaseApp.create(
  config: config,
  stylesheet: stylesheet,
  demoBuilder: (String componentType) {
    if (componentType == 'ButtonDemo') {
      return Button(
        label: 'Demo',
        onPressed: () {},
      );
    }
    return null;
  },
)
```
