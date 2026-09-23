import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/html.dart' show ArcaneDiv, ArcaneLink;
import 'package:arcane_lexicon/src/config/site_config.dart';
import 'package:arcane_lexicon/src/icons/kb_icon.dart';
import 'package:arcane_lexicon/src/navigation/nav_builder.dart';
import 'package:arcane_lexicon/src/navigation/nav_item.dart';
import 'package:arcane_lexicon/src/navigation/nav_section.dart';

/// Navigation item with title and path for prev/next links.
class PageNavLink {
  final String title;
  final String path;

  const PageNavLink({required this.title, required this.path});
}

/// Page navigation component showing previous and next articles.
class KBPageNav extends StatelessWidget {
  final SiteConfig config;
  final NavManifest manifest;
  final String currentPath;

  const KBPageNav({
    required this.config,
    required this.manifest,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // Get flat list of all pages
    final List<PageNavLink> allPages = _flattenPages();
    if (allPages.isEmpty) return const ArcaneDiv(children: []);

    // Find current page index
    final int currentIndex = allPages.indexWhere(
      (PageNavLink p) =>
          p.path == currentPath ||
          p.path == '$currentPath/' ||
          '${p.path}/' == currentPath,
    );

    if (currentIndex == -1) return const ArcaneDiv(children: []);

    // Get prev/next
    final PageNavLink? prevPage = currentIndex > 0
        ? allPages[currentIndex - 1]
        : null;
    final PageNavLink? nextPage = currentIndex < allPages.length - 1
        ? allPages[currentIndex + 1]
        : null;

    if (prevPage == null && nextPage == null) {
      return const ArcaneDiv(children: []);
    }

    return ArcaneDiv(
      classes: <String>['kb-page-nav-section'],
      styles: const ArcaneStyleData(
        margin: MarginPreset.topXl,
        padding: PaddingPreset.topLg,
      ),
      children: [
        const ArcaneDiv(
          classes: <String>['kb-section-divider'],
          children: <Widget>[],
        ),
        ArcaneDiv(
          classes: <String>['kb-page-nav'],
          styles: const ArcaneStyleData(
            display: Display.flex,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            gap: Gap.lg,
          ),
          children: <Widget>[
            // Previous link
            if (prevPage != null)
              ArcaneLink(
                href: config.fullPath(prevPage.path),
                classes: <String>['kb-page-nav-link kb-page-nav-prev'],
                styles: const ArcaneStyleData(
                  display: Display.flex,
                  flexDirection: FlexDirection.column,
                  gap: Gap.xs,
                  padding: PaddingPreset.md,
                  flex: FlexPreset.expand,
                  textDecoration: TextDecoration.none,
                ),
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        KBIcon.build('arrow-left', size: IconSize.sm),
                        const ArcaneDiv(
                          styles: ArcaneStyleData(
                            fontSize: FontSize.sm,
                            textColor: TextColor.mutedForeground,
                          ),
                          children: [Text('Previous')],
                        ),
                      ],
                    ),
                    ArcaneDiv(
                      styles: const ArcaneStyleData(
                        fontWeight: FontWeight.w500,
                        textColor: TextColor.primary,
                      ),
                      children: [Text(prevPage.title)],
                    ),
                  ],
                ),
              )
            else
              const ArcaneDiv(
                classes: <String>['kb-page-nav-spacer'],
                styles: ArcaneStyleData(flex: FlexPreset.expand),
                children: [],
              ),

            // Next link
            if (nextPage != null)
              ArcaneLink(
                href: config.fullPath(nextPage.path),
                classes: <String>['kb-page-nav-link kb-page-nav-next'],
                styles: const ArcaneStyleData(
                  display: Display.flex,
                  flexDirection: FlexDirection.column,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  gap: Gap.xs,
                  padding: PaddingPreset.md,
                  flex: FlexPreset.expand,
                  textAlign: TextAlign.right,
                  textDecoration: TextDecoration.none,
                ),
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ArcaneDiv(
                          styles: ArcaneStyleData(
                            fontSize: FontSize.sm,
                            textColor: TextColor.mutedForeground,
                          ),
                          children: [Text('Next')],
                        ),
                        KBIcon.build('arrow-right', size: IconSize.sm),
                      ],
                    ),
                    ArcaneDiv(
                      styles: const ArcaneStyleData(
                        fontWeight: FontWeight.w500,
                        textColor: TextColor.primary,
                      ),
                      children: [Text(nextPage.title)],
                    ),
                  ],
                ),
              )
            else
              const ArcaneDiv(
                classes: <String>['kb-page-nav-spacer'],
                styles: ArcaneStyleData(flex: FlexPreset.expand),
                children: [],
              ),
          ],
        ),
      ],
    );
  }

  /// Flatten the navigation manifest into an ordered list of pages.
  List<PageNavLink> _flattenPages() {
    final List<PageNavLink> pages = [];

    // Add root items
    for (final NavItem item in manifest.visibleItems) {
      pages.add(PageNavLink(title: item.title, path: item.path));
    }

    // Add sections recursively
    for (final NavSection section in manifest.visibleSections) {
      _flattenSection(section, pages);
    }

    return pages;
  }

  void _flattenSection(NavSection section, List<PageNavLink> pages) {
    // Add items in this section
    for (final NavItem item in section.visibleItems) {
      pages.add(PageNavLink(title: item.title, path: item.path));
    }

    // Add nested sections
    for (final NavSection nested in section.visibleSections) {
      _flattenSection(nested, pages);
    }
  }
}

/// Subpages component that shows child pages of the current page.
class KBSubpages extends StatelessWidget {
  final SiteConfig config;
  final NavManifest manifest;
  final String currentPath;

  const KBSubpages({
    required this.config,
    required this.manifest,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // Find section matching current path
    final NavSection? currentSection = _findSection(manifest.sections);
    if (currentSection == null) return const ArcaneDiv(children: []);

    final List<NavItem> subpages = currentSection.visibleItems;
    final List<NavSection> subsections = currentSection.visibleSections;

    if (subpages.isEmpty && subsections.isEmpty) {
      return const ArcaneDiv(children: []);
    }

    return ArcaneDiv(
      classes: <String>['kb-subpages'],
      styles: const ArcaneStyleData(margin: MarginPreset.bottomXl),
      children: [
        const ArcaneDiv(
          classes: <String>['kb-subpages-title'],
          styles: ArcaneStyleData(
            fontWeight: FontWeight.w600,
            fontSize: FontSize.sm,
            textColor: TextColor.mutedForeground,
            margin: MarginPreset.bottomMd,
          ),
          children: [Text('In this section')],
        ),
        ArcaneDiv(
          classes: <String>['kb-subpages-grid'],
          styles: const ArcaneStyleData(display: Display.grid, gap: Gap.md),
          children: [
            const ArcaneDiv(
              classes: <String>['kb-section-divider'],
              children: <Widget>[],
            ),
            // Child pages
            ...subpages.map(
              (NavItem item) => ArcaneLink(
                href: config.fullPath(item.path),
                classes: <String>['kb-subpage-row'],
                styles: const ArcaneStyleData(
                  display: Display.flex,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  gap: Gap.md,
                  padding: PaddingPreset.md,
                  textDecoration: TextDecoration.none,
                ),
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (item.icon != null)
                      ArcaneDiv(
                        styles: const ArcaneStyleData(
                          textColor: TextColor.primary,
                        ),
                        children: [KBIcon.build(item.icon!, size: IconSize.md)],
                      ),
                    ArcaneDiv(
                      styles: const ArcaneStyleData(flex: FlexPreset.expand),
                      children: [
                        ArcaneDiv(
                          styles: const ArcaneStyleData(
                            fontWeight: FontWeight.w500,
                            textColor: TextColor.primary,
                          ),
                          children: [Text(item.title)],
                        ),
                        if (item.description != null)
                          ArcaneDiv(
                            styles: const ArcaneStyleData(
                              fontSize: FontSize.sm,
                              textColor: TextColor.mutedForeground,
                            ),
                            children: [Text(item.description!)],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Child sections
            ...subsections.map(
              (NavSection section) => ArcaneLink(
                href: config.fullPath(section.path),
                classes: <String>['kb-subpage-row kb-subpage-section'],
                styles: const ArcaneStyleData(
                  display: Display.flex,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  gap: Gap.md,
                  padding: PaddingPreset.md,
                  textDecoration: TextDecoration.none,
                ),
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (section.icon != null)
                      ArcaneDiv(
                        styles: const ArcaneStyleData(
                          textColor: TextColor.primary,
                        ),
                        children: [
                          KBIcon.build(section.icon!, size: IconSize.md),
                        ],
                      ),
                    ArcaneDiv(
                      styles: const ArcaneStyleData(flex: FlexPreset.expand),
                      children: [
                        ArcaneDiv(
                          styles: const ArcaneStyleData(
                            fontWeight: FontWeight.w500,
                            textColor: TextColor.primary,
                          ),
                          children: [Text(section.title)],
                        ),
                        ArcaneDiv(
                          styles: const ArcaneStyleData(
                            fontSize: FontSize.sm,
                            textColor: TextColor.mutedForeground,
                          ),
                          children: [
                            Text('${section.visibleItems.length} pages'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  NavSection? _findSection(List<NavSection> sections) {
    for (final NavSection section in sections) {
      if (section.path == currentPath ||
          section.path == '$currentPath/' ||
          '${section.path}/' == currentPath) {
        return section;
      }
      final NavSection? found = _findSection(section.sections);
      if (found != null) return found;
    }
    return null;
  }
}
