#!/usr/bin/env bash
set -euo pipefail

workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
target_pubspec_overrides="${workspace_root}/example/pubspec_overrides.yaml"

cat > "${target_pubspec_overrides}" <<'YAML'
dependency_overrides:
  arcane_jaspr:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git
  arcane_jaspr_shadcn:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git
      path: packages/arcane_jaspr_shadcn
  arcane_jaspr_neon:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git
      path: packages/arcane_jaspr_neon
  arcane_jaspr_neubrutalism:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git
      path: packages/arcane_jaspr_neubrutalism
  arcane_jaspr_kb:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git
      path: packages/arcane_jaspr_kb
  arcane_lexicon:
    path: ../
YAML
