---
title: Rich Markdown Blocks
description: Live showcase of all default rich markdown components
icon: component
order: 9
tags:
  - rich-markdown
  - components
  - showcase
author: Arcane Arts
date: 2026-03-03
---

This page renders the default rich markdown component set that Arcane Lexicon registers automatically.

## Cards and Tiles

<CardGroup>
  <Card title="Installation" href="/guide/basics/installation" icon="rocket">
    Start by adding the package and running the app.
  </Card>
  <Card title="SiteConfig" href="/reference/site-config" icon="settings">
    Configure global behavior and layout flags.
  </Card>
  <Card title="GitHub" href="https://github.com/ArcaneArts/arcane_lexicon" icon="github">
    External links keep the same flat row hierarchy.
  </Card>
</CardGroup>

<Tiles>
  <Tile title="Internal Link" href="/reference/components" icon="book">
    Internal tiles render as direct navigation rows.
  </Tile>
  <Tile title="External Link" href="https://docs.page/schultek/jaspr" icon="globe">
    External tiles use the same restrained row treatment.
  </Tile>
  <Tile title="Static Tile" icon="activity">
    Tile with no `href` renders as static content.
  </Tile>
</Tiles>

## Columns, Panels, and Banner

<Columns cols={2}>
  <Column>
    <Panel title="Panel Example" icon="panel">
      Panels are useful for grouped explanatory content.
    </Panel>
  </Column>
  <Column>
    <Banner title="Read the Guide" href="/guide/basics/configuration" type="info">
      Banners can be static or clickable.
    </Banner>
  </Column>
</Columns>

## Steps and Accordions

<Steps>
  <Step title="Define content structure">Create markdown pages under your content directory.</Step>
  <Step title="Configure sections">Add `_section.json5` files for section metadata.</Step>
  <Step title="Build and verify">Run `jaspr build` and check final output.</Step>
</Steps>

<AccordionGroup>
  <Accordion title="Accordion item">Grouped collapsible content.</Accordion>
  <Accordion title="Starts open" defaultOpen={true}>`defaultOpen={true}` opens on first render.</Accordion>
</AccordionGroup>

<Expandable title="Standalone expandable" defaultOpen={false}>
  Use `Expandable` when you do not need an accordion group.
</Expandable>

## Badges, Update, and Frame

<Badge color="info">Info</Badge>
<Badge color="success">Success</Badge>
<Badge color="warning">Warning</Badge>
<Badge color="danger">Danger</Badge>

<Update label="Last updated" date="2026-03-03">
  Update blocks highlight change summaries or release notes.
</Update>

<Frame label="Preview" caption="Optional caption text.">
  Frame body supports standard markdown content.
</Frame>

## Fields and Tree

<FieldGroup>
  <ParamField query="page" type="number" required={true}>Page number for pagination.</ParamField>
  <ParamField body="filter" type="object">Optional filter payload.</ParamField>
  <ResponseField name="items" type="array" required={true}>Returned records.</ResponseField>
</FieldGroup>

<Tree>
  <Tree.Folder name="content" defaultOpen={true}>
    <Tree.File name="index.md" />
    <Tree.File name="guide/basics/installation.md" />
    <Tree.File name="reference/components.md" />
  </Tree.Folder>
</Tree>

## Color and View

<Color>
  <Color.Item label="Primary" value="#3b82f6" />
  <Color.Item label="Success" value="#22c55e" />
  <Color.Item label="Warning" value="#f59e0b" />
  <Color.Item label="Danger" value="#ef4444" />
</Color>

<View title="View Container">
  View wraps content in a labeled container for grouped output.
</View>

## Tooltip, Icon, and CodeGroup

<Tooltip tip="This uses the native title tooltip.">Hover for tooltip</Tooltip>

<Icon name="server" size="sm" />
<Icon name="palette" size="sm" />
<Icon name="lightbulb" size="sm" />

<CodeGroup title="Commands">
```bash
jaspr serve
```
```bash
jaspr build --dart-define=BASE_URL=/docs
```
</CodeGroup>

## Tabs

<Tabs defaultValue="one">
  <TabItem label="First" value="one">First tab content</TabItem>
  <TabItem label="Second" value="two">Second tab content</TabItem>
</Tabs>
