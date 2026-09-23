import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/html.dart' show ArcaneDiv, ArcaneLink;

import '../utils/changelog_parser.dart';

/// A styled changelog timeline component.
class KBChangelog extends StatelessWidget {
  final List<ChangelogVersion> versions;
  final int? maxVersions;
  final String? githubUrl;

  const KBChangelog({required this.versions, this.maxVersions, this.githubUrl});

  @override
  Widget build(BuildContext context) {
    final List<ChangelogVersion> displayVersions = maxVersions != null
        ? versions.take(maxVersions!).toList()
        : versions;

    if (displayVersions.isEmpty) {
      return const ArcaneDiv(children: []);
    }

    return ArcaneDiv(
      classes: <String>['kb-changelog'],
      children: displayVersions.map(_buildVersion).toList(),
    );
  }

  Widget _buildVersion(ChangelogVersion version) {
    return ArcaneDiv(
      classes: <String>['kb-changelog-version'],
      styles: const ArcaneStyleData(
        margin: MarginPreset.bottomXl,
        padding: PaddingPreset.verticalLg,
      ),
      children: [
        const ArcaneDiv(
          classes: <String>['kb-section-divider'],
          children: <Widget>[],
        ),
        // Version header
        ArcaneDiv(
          classes: <String>['kb-changelog-header'],
          styles: const ArcaneStyleData(
            display: Display.flex,
            crossAxisAlignment: CrossAxisAlignment.center,
            gap: Gap.md,
            margin: MarginPreset.bottomMd,
            padding: PaddingPreset.bottomMd,
          ),
          children: [
            // Version badge
            ArcaneDiv(
              classes: <String>['kb-changelog-version-label'],
              styles: const ArcaneStyleData(
                display: Display.inlineFlex,
                fontSize: FontSize.sm,
                fontWeight: FontWeight.w600,
              ),
              children: [Text('v${version.version}')],
            ),
            // Date
            if (version.date != null)
              ArcaneDiv(
                styles: const ArcaneStyleData(
                  fontSize: FontSize.sm,
                  textColor: TextColor.mutedForeground,
                ),
                children: [Text(version.date!)],
              ),
            // GitHub release link
            if (githubUrl != null)
              ArcaneLink.external(
                href: '$githubUrl/releases/tag/v${version.version}',
                styles: const ArcaneStyleData(
                  display: Display.inlineFlex,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  gap: Gap.xs,
                  fontSize: FontSize.sm,
                  textColor: TextColor.mutedForeground,
                  textDecoration: TextDecoration.none,
                ),
                child: Row(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ArcaneIcon.externalLink(size: IconSize.xs),
                    const Text('Release'),
                  ],
                ),
              ),
          ],
        ),
        const ArcaneDiv(
          classes: <String>['kb-section-divider'],
          children: <Widget>[],
        ),

        // Sections
        ...version.sectionNames.map(
          (String sectionName) =>
              _buildSection(sectionName, version[sectionName]),
        ),
      ],
    );
  }

  Widget _buildSection(String name, List<String> items) {
    if (items.isEmpty) return const ArcaneDiv(children: []);

    return ArcaneDiv(
      classes: <String>['kb-changelog-section'],
      styles: const ArcaneStyleData(margin: MarginPreset.bottomMd),
      children: [
        // Section title with icon
        ArcaneDiv(
          styles: const ArcaneStyleData(
            display: Display.flex,
            crossAxisAlignment: CrossAxisAlignment.center,
            gap: Gap.sm,
            margin: MarginPreset.bottomSm,
            fontWeight: FontWeight.w600,
            fontSize: FontSize.sm,
          ),
          children: [_getSectionIcon(name), Text(name)],
        ),
        // Items
        ArcaneDiv(
          styles: const ArcaneStyleData(paddingStringCustom: '0 0 0 1.5rem'),
          children: items
              .map(
                (String item) => ArcaneDiv(
                  styles: const ArcaneStyleData(
                    display: Display.flex,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    gap: Gap.sm,
                    margin: MarginPreset.bottomXs,
                    fontSize: FontSize.sm,
                    textColor: TextColor.onSurfaceVariant,
                  ),
                  children: [
                    const ArcaneDiv(
                      styles: ArcaneStyleData(
                        textColor: TextColor.mutedForeground,
                      ),
                      children: [Text('-')],
                    ),
                    Text(item),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _getSectionIcon(String name) {
    final String lowerName = name.toLowerCase();

    if (lowerName.contains('add')) {
      return ArcaneDiv(
        styles: const ArcaneStyleData(textColorCustom: '#22c55e'),
        children: [ArcaneIcon.plus(size: IconSize.sm)],
      );
    } else if (lowerName.contains('change')) {
      return ArcaneDiv(
        styles: const ArcaneStyleData(textColorCustom: '#3b82f6'),
        children: [ArcaneIcon.pencil(size: IconSize.sm)],
      );
    } else if (lowerName.contains('deprecat')) {
      return ArcaneDiv(
        styles: const ArcaneStyleData(textColorCustom: '#eab308'),
        children: [ArcaneIcon.triangleAlert(size: IconSize.sm)],
      );
    } else if (lowerName.contains('remov')) {
      return ArcaneDiv(
        styles: const ArcaneStyleData(textColorCustom: '#ef4444'),
        children: [ArcaneIcon.trash(size: IconSize.sm)],
      );
    } else if (lowerName.contains('fix')) {
      return ArcaneDiv(
        styles: const ArcaneStyleData(textColorCustom: '#a855f7'),
        children: [ArcaneIcon.wrench(size: IconSize.sm)],
      );
    } else if (lowerName.contains('secur')) {
      return ArcaneDiv(
        styles: const ArcaneStyleData(textColorCustom: '#f97316'),
        children: [ArcaneIcon.shield(size: IconSize.sm)],
      );
    }

    return ArcaneIcon.info(size: IconSize.sm);
  }
}
