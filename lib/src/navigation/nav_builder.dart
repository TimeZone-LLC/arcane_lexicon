import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:json5/json5.dart';
import 'nav_item.dart';
import 'nav_section.dart';

/// Builds navigation structure from a directory of markdown files.
class NavBuilder {
  final String contentDirectory;
  final String baseUrl;
  final Set<String> ignoredSourcePaths;

  NavBuilder({
    required this.contentDirectory,
    this.baseUrl = '',
    this.ignoredSourcePaths = const <String>{},
  });

  /// Build the complete navigation tree from the content directory.
  Future<NavManifest> build() async {
    final contentDir = Directory(contentDirectory);
    if (!await contentDir.exists()) {
      throw Exception('Content directory not found: $contentDirectory');
    }

    final rootItems = <NavItem>[];
    final rootSections = <NavSection>[];

    await _scanDirectory(contentDir, '', '', rootItems, rootSections);

    return NavManifest(items: rootItems, sections: rootSections);
  }

  Future<void> _scanDirectory(
    Directory dir,
    String pathPrefix,
    String sourcePrefix,
    List<NavItem> items,
    List<NavSection> sections,
  ) async {
    final entities = await dir.list().toList();

    // Sort entities for consistent ordering
    entities.sort((a, b) => a.path.compareTo(b.path));

    // Process files first
    for (final entity in entities) {
      if (entity is File) {
        final filename = entity.path.split('/').last;

        // Skip non-markdown files and special files
        if (!filename.endsWith('.md')) continue;
        if (filename.startsWith('_')) continue;
        String sourcePath = sourcePrefix.isEmpty
            ? filename
            : '$sourcePrefix/$filename';
        if (ignoredSourcePaths.contains(sourcePath)) continue;

        // Build the path
        String pagePath;
        if (filename == 'index.md') {
          pagePath = pathPrefix.isEmpty ? '/' : pathPrefix;
        } else {
          final slug = filename.replaceAll('.md', '');
          pagePath = pathPrefix.isEmpty ? '/$slug' : '$pathPrefix/$slug';
        }

        // Parse frontmatter and extract content
        final content = await entity.readAsString();
        final frontmatter = _parseFrontmatter(content);
        final excerpt = _extractExcerpt(content);

        // Get file last modified time
        final FileStat stat = await entity.stat();
        final String lastModified = stat.modified.toIso8601String();

        final item = NavItem.fromFrontmatter(
          path: pagePath,
          frontmatter: frontmatter,
          fallbackTitle: NavItem.filenameToTitle(filename),
          excerpt: excerpt,
          lastModified: lastModified,
        );

        items.add(item);
      }
    }

    // Process subdirectories
    for (final entity in entities) {
      if (entity is Directory) {
        final folderName = entity.path.split('/').last;

        // Skip hidden directories
        if (folderName.startsWith('.')) continue;

        // Check for section config in this subdirectory first to see if ignored
        final Map<String, dynamic>? subSectionConfig = await _loadSectionConfig(
          entity.path,
        );

        // Skip ignored folders
        if (subSectionConfig?['ignore'] == true) continue;

        final sectionPath = pathPrefix.isEmpty
            ? '/$folderName'
            : '$pathPrefix/$folderName';
        String sectionSourcePrefix = sourcePrefix.isEmpty
            ? folderName
            : '$sourcePrefix/$folderName';
        final sectionItems = <NavItem>[];
        final nestedSections = <NavSection>[];

        await _scanDirectory(
          entity,
          sectionPath,
          sectionSourcePrefix,
          sectionItems,
          nestedSections,
        );

        // Only add section if it has content
        if (sectionItems.isNotEmpty || nestedSections.isNotEmpty) {
          final section = subSectionConfig != null
              ? NavSection.fromConfig(
                  path: sectionPath,
                  config: subSectionConfig,
                  fallbackTitle: NavItem.filenameToTitle(folderName),
                  items: sectionItems,
                  sections: nestedSections,
                )
              : NavSection.fromFolderName(
                  path: sectionPath,
                  folderName: folderName,
                  items: sectionItems,
                  sections: nestedSections,
                );

          sections.add(section);
        }
      }
    }
  }

  /// Load section configuration from _section.json5 or _section.yaml.
  /// Prefers JSON5 over YAML if both exist.
  Future<Map<String, dynamic>?> _loadSectionConfig(String dirPath) async {
    // Try JSON5 first (preferred - supports comments)
    final json5File = File('$dirPath/_section.json5');
    if (await json5File.exists()) {
      final content = await json5File.readAsString();
      try {
        final dynamic parsed = JSON5.parse(content);
        if (parsed is Map) {
          return Map<String, dynamic>.from(parsed);
        }
      } catch (e) {
        // Fall through to try YAML
      }
    }

    // Fall back to YAML
    final yamlFile = File('$dirPath/_section.yaml');
    if (await yamlFile.exists()) {
      final content = await yamlFile.readAsString();
      try {
        final dynamic parsed = loadYaml(content);
        if (parsed is YamlMap) {
          return Map<String, dynamic>.from(parsed);
        }
      } catch (e) {
        // Return null if parsing fails
      }
    }

    return null;
  }

  /// Extract a content excerpt for search indexing.
  String _extractExcerpt(String content, {int maxLength = 500}) {
    String text = content;

    // Remove frontmatter
    if (text.startsWith('---')) {
      final int endIndex = text.indexOf('---', 3);
      if (endIndex > 0) {
        text = text.substring(endIndex + 3);
      }
    }

    // Remove markdown formatting
    text = text
        // Remove code blocks
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        // Remove inline code
        .replaceAll(RegExp(r'`[^`]+`'), ' ')
        // Remove images
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), ' ')
        // Remove links (keep text)
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (Match match) => match.group(1)!,
        )
        // Remove headers markers
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        // Remove bold/italic markers
        .replaceAllMapped(
          RegExp(r'[*_]{1,2}([^*_]+)[*_]{1,2}'),
          (Match match) => match.group(1)!,
        )
        // Remove HTML tags
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        // Remove blockquotes
        .replaceAll(RegExp(r'^>\s*', multiLine: true), '')
        // Normalize whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Truncate to max length
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
      // Try to break at a word boundary
      final int lastSpace = text.lastIndexOf(' ');
      if (lastSpace > maxLength - 50) {
        text = text.substring(0, lastSpace);
      }
    }

    return text;
  }

  /// Parse YAML frontmatter from markdown content.
  Map<String, dynamic> _parseFrontmatter(String content) {
    final frontmatterRegex = RegExp(
      r'^---\s*\n([\s\S]*?)\n---',
      multiLine: true,
    );
    final match = frontmatterRegex.firstMatch(content);

    if (match == null) return {};

    try {
      final yamlContent = match.group(1);
      if (yamlContent == null || yamlContent.trim().isEmpty) return {};

      final yaml = loadYaml(yamlContent);
      if (yaml is YamlMap) {
        return Map<String, dynamic>.from(yaml);
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}

/// The complete navigation manifest.
class NavManifest {
  /// Root-level navigation items.
  final List<NavItem> items;

  /// Root-level navigation sections.
  final List<NavSection> sections;

  const NavManifest({required this.items, required this.sections});

  /// Get all items sorted by order.
  List<NavItem> get sortedItems {
    final sorted = List<NavItem>.from(items);
    sorted.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return sorted;
  }

  /// Get all sections sorted by order.
  List<NavSection> get sortedSections {
    final sorted = List<NavSection>.from(sections);
    sorted.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return sorted;
  }

  /// Get visible root items (excludes hidden and draft items).
  List<NavItem> get visibleItems =>
      sortedItems.where((item) => !item.hidden && !item.draft).toList();

  /// Get root sections that contain at least one published page.
  List<NavSection> get visibleSections => sortedSections
      .where((NavSection section) => section.hasVisibleContent)
      .toList();

  /// Convert to JSON for client-side use.
  Map<String, dynamic> toJson() {
    return {
      'items': visibleItems.map(_itemToJson).toList(),
      'sections': visibleSections.map(_sectionToJson).toList(),
    };
  }

  Map<String, dynamic> _itemToJson(NavItem item) {
    return {
      'title': item.title,
      'path': item.path,
      'icon': item.icon,
      'order': item.order,
      'hidden': item.hidden,
      'draft': item.draft,
      'description': item.description,
      'tags': item.tags,
      'excerpt': item.excerpt,
      'author': item.author,
      'date': item.date,
      'lastModified': item.lastModified,
    };
  }

  Map<String, dynamic> _sectionToJson(NavSection section) {
    return {
      'title': section.title,
      'path': section.path,
      'icon': section.icon,
      'order': section.order,
      'collapsed': section.collapsed,
      'items': section.visibleItems.map(_itemToJson).toList(),
      'sections': section.visibleSections.map(_sectionToJson).toList(),
    };
  }

  /// Create from JSON.
  factory NavManifest.fromJson(Map<String, dynamic> json) {
    return NavManifest(
      items: (json['items'] as List<dynamic>)
          .map((e) => _itemFromJson(e as Map<String, dynamic>))
          .toList(),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => _sectionFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static NavItem _itemFromJson(Map<String, dynamic> json) {
    return NavItem(
      title: json['title'] as String,
      path: json['path'] as String,
      icon: json['icon'] as String?,
      order: json['order'] as int? ?? 999,
      hidden: json['hidden'] as bool? ?? false,
      draft: json['draft'] as bool? ?? false,
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      excerpt: json['excerpt'] as String?,
      author: json['author'] as String?,
      date: json['date'] as String?,
      lastModified: json['lastModified'] as String?,
    );
  }

  static NavSection _sectionFromJson(Map<String, dynamic> json) {
    return NavSection(
      title: json['title'] as String,
      path: json['path'] as String,
      icon: json['icon'] as String?,
      order: json['order'] as int? ?? 999,
      collapsed: json['collapsed'] as bool? ?? true,
      items: (json['items'] as List<dynamic>)
          .map((e) => _itemFromJson(e as Map<String, dynamic>))
          .toList(),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => _sectionFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get total page count.
  int get totalPages {
    int count = visibleItems.length;
    for (final NavSection section in visibleSections) {
      count += _countSectionPages(section);
    }
    return count;
  }

  int _countSectionPages(NavSection section) {
    int count = section.visibleItems.length;
    for (final NavSection nested in section.visibleSections) {
      count += _countSectionPages(nested);
    }
    return count;
  }
}
