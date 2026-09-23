---
title: Installation
description: Add Arcane Lexicon to your project
icon: download
order: 1
author: Arcane Arts
date: 2025-01-11
---

Notice the **breadcrumbs** above the title showing: Guide > Basics > Installation

## Add Dependencies

With your site beside local `arcane_lexicon` and `arcane_jaspr` checkouts:

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

Resolve the core and renderer from the same checkout. The site must declare its
own override because dependency overrides do not propagate from Lexicon.

## Install

```bash
dart pub get
```

## Next Steps

Use the **Next** button below to continue to Configuration.
