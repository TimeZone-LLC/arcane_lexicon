import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/html.dart' show ArcaneDiv, ArcaneLink;
import '../config/site_config.dart';
import '../navigation/nav_item.dart';
import '../navigation/nav_section.dart';
import '../navigation/nav_builder.dart';

/// Widget that displays related pages based on shared tags.
class KBRelatedPages extends StatelessWidget {
  final SiteConfig config;
  final NavManifest manifest;
  final String currentPath;
  final List<String> currentTags;
  final int maxItems;

  const KBRelatedPages({
    required this.config,
    required this.manifest,
    required this.currentPath,
    required this.currentTags,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (currentTags.isEmpty) return const ArcaneDiv(children: []);

    // Find all pages with at least one shared tag
    final List<_RelatedPage> relatedPages = _findRelatedPages();

    if (relatedPages.isEmpty) return const ArcaneDiv(children: []);

    return ArcaneDiv(
      classes: <String>['kb-related-pages'],
      styles: const ArcaneStyleData(
        margin: MarginPreset.topXl,
        padding: PaddingPreset.topLg,
      ),
      children: [
        const ArcaneDiv(
          styles: ArcaneStyleData(
            fontWeight: FontWeight.w600,
            fontSize: FontSize.sm,
            textColor: TextColor.mutedForeground,
            margin: MarginPreset.bottomMd,
          ),
          children: [Text('Related Pages')],
        ),
        ArcaneDiv(
          classes: <String>['kb-related-grid'],
          styles: const ArcaneStyleData(display: Display.grid, gap: Gap.md),
          children: <Widget>[
            const ArcaneDiv(
              classes: <String>['kb-section-divider'],
              children: <Widget>[],
            ),
            ...relatedPages
                .take(maxItems)
                .map((_RelatedPage page) => _buildRelatedRow(page)),
          ],
        ),
      ],
    );
  }

  List<_RelatedPage> _findRelatedPages() {
    final List<_RelatedPage> results = [];
    final Set<String> currentTagSet = currentTags.toSet();

    // Collect all pages from manifest
    void collectFromItems(List<NavItem> items) {
      for (final NavItem item in items) {
        if (item.path == currentPath) continue;
        if (item.hidden || item.draft) continue;
        if (item.tags.isEmpty) continue;

        final Set<String> itemTagSet = item.tags.toSet();
        final Set<String> sharedTags = currentTagSet.intersection(itemTagSet);

        if (sharedTags.isNotEmpty) {
          results.add(
            _RelatedPage(
              title: item.title,
              path: item.path,
              description: item.description,
              sharedTags: sharedTags.toList(),
              relevance: sharedTags.length,
            ),
          );
        }
      }
    }

    void collectFromSections(List<NavSection> sections) {
      for (final NavSection section in sections) {
        collectFromItems(section.visibleItems);
        collectFromSections(section.visibleSections);
      }
    }

    // Collect from root items and sections
    collectFromItems(manifest.visibleItems);
    collectFromSections(manifest.visibleSections);

    // Sort by relevance (most shared tags first)
    results.sort((a, b) => b.relevance.compareTo(a.relevance));

    return results;
  }

  Widget _buildRelatedRow(_RelatedPage page) {
    return ArcaneLink(
      href: config.fullPath(page.path),
      classes: <String>['kb-related-row'],
      styles: const ArcaneStyleData(
        display: Display.block,
        gap: Gap.xs,
        padding: PaddingPreset.md,
        textDecoration: TextDecoration.none,
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArcaneDiv(
            styles: const ArcaneStyleData(
              fontWeight: FontWeight.w500,
              textColor: TextColor.primary,
            ),
            children: [Text(page.title)],
          ),
          if (page.description != null)
            ArcaneDiv(
              styles: const ArcaneStyleData(
                fontSize: FontSize.sm,
                textColor: TextColor.mutedForeground,
              ),
              children: [
                Text(
                  page.description!.length > 100
                      ? '${page.description!.substring(0, 100)}...'
                      : page.description!,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RelatedPage {
  final String title;
  final String path;
  final String? description;
  final List<String> sharedTags;
  final int relevance;

  const _RelatedPage({
    required this.title,
    required this.path,
    this.description,
    required this.sharedTags,
    required this.relevance,
  });
}
