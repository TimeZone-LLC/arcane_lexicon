import 'dart:io' as io;

import 'package:arcane_jaspr/arcane_jaspr.dart' hide ReadingTimeExtension;
import 'package:jaspr_content/jaspr_content.dart';
import 'package:yaml/yaml.dart';

import '../config/site_config.dart';
import '../navigation/nav_builder.dart';
import '../layout/kb_layout.dart';
import '../scripts/kb_scripts.dart';
import '../components/rich_markdown_components.dart';
import '../extensions/reading_time_extension.dart';
import '../extensions/callout_extension.dart';
import '../extensions/media_extension.dart';
import '../utils/search_index_generator.dart';

export '../layout/kb_layout.dart' show DemoBuilder;

/// Configuration for creating a knowledge base application.
///
/// Use this class with Jaspr.initializeApp() to create a documentation site
/// from a directory of markdown files.
///
/// Example usage with 1-line theming:
/// ```dart
/// import 'package:arcane_jaspr_neon/arcane_jaspr_neon.dart';
/// import 'package:arcane_jaspr_neubrutalism/arcane_jaspr_neubrutalism.dart';
/// import 'package:arcane_jaspr_shadcn/arcane_jaspr_shadcn.dart';
/// import 'package:arcane_lexicon/arcane_lexicon.dart' hide runApp;
///
/// const ArcaneStylesheet shadcnStylesheet = ShadcnStylesheet(
///   theme: ShadcnTheme.charcoal,
/// );
/// const ArcaneStylesheet neonStylesheet = NeonStylesheet(
///   theme: NeonTheme.green,
/// );
/// const ArcaneStylesheet neubrutalismStylesheet = NeubrutalismStylesheet(
///   theme: NeubrutalismTheme.yellow,
/// );
/// const ArcaneStylesheet selectedStylesheet = shadcnStylesheet;
///
/// void main() async {
///   Jaspr.initializeApp();
///   runApp(
///     await KnowledgeBaseApp.create(
///       config: const SiteConfig(
///         name: 'My Docs',
///         contentDirectory: 'content',
///       ),
///       stylesheet: selectedStylesheet,
///     ),
///   );
/// }
/// ```
class KnowledgeBaseApp {
  /// Create a ContentApp configured for the knowledge base.
  ///
  /// This method builds the navigation manifest from the content directory
  /// and returns a ContentApp ready to be passed to Jaspr.initializeApp().
  ///
  /// The optional [demoBuilder] callback is called for each page that has a
  /// `component` field in its frontmatter. Return a Widget to render as
  /// a live demo above the page content, or null to skip.
  ///
  /// Set [generateSearchIndex] to true (default) to generate a search-index.json
  /// file in the web directory. This file can be fetched by external sites to
  /// enable search functionality.
  static Future<ContentApp> create({
    required SiteConfig config,
    required ArcaneStylesheet stylesheet,
    List<PageExtension>? extensions,
    List<CustomComponent>? components,
    List<KBStylesheetOption> stylesheetOptions = const <KBStylesheetOption>[],
    DemoBuilder? demoBuilder,
    bool generateSearchIndex = true,
  }) async {
    String? landingSourcePath = await _resolveLandingSourcePath(config);
    Set<String> ignoredSourcePaths = _ignoredSourcePaths(landingSourcePath);

    // Build navigation manifest from content directory
    final NavBuilder navBuilder = NavBuilder(
      contentDirectory: config.contentDirectory,
      baseUrl: config.baseUrl,
      ignoredSourcePaths: ignoredSourcePaths,
    );
    final NavManifest manifest = await navBuilder.build();

    // Generate search index if enabled
    if (generateSearchIndex) {
      await _writeSearchIndex(config, manifest);
    }

    // Create scripts
    KBScripts scripts = KBScripts(
      basePath: config.baseUrl,
      stylesheetOptions: stylesheetOptions,
      defaultStylesheetId: _defaultStylesheetId(stylesheet, stylesheetOptions),
    );

    // Create layout
    final KBLayout layout = KBLayout(
      config: config,
      manifest: manifest,
      stylesheet: stylesheet,
      stylesheetOptions: stylesheetOptions,
      scripts: scripts,
      demoBuilder: demoBuilder,
    );

    // Default extensions for markdown processing
    final List<PageExtension> defaultExtensions = <PageExtension>[
      const MediaExtension(),
      const CalloutExtension(),
      HeadingAnchorsExtension(),
      const TableOfContentsExtension(),
      const ReadingTimeExtension(),
    ];

    final List<CustomComponent> defaultComponents =
        KBRichMarkdownComponents.defaults();

    return _contentApp(
      config: config,
      landingSourcePath: landingSourcePath,
      layout: layout,
      extensions: <PageExtension>[...defaultExtensions, ...?extensions],
      components: <CustomComponent>[...defaultComponents, ...?components],
    );
  }

  /// Write the search index JSON file to web/search-index.json.
  ///
  /// Creates the web directory when needed so search generation is explicit and
  /// predictable for newly scaffolded projects.
  static Future<void> _writeSearchIndex(
    SiteConfig config,
    NavManifest manifest,
  ) async {
    final generator = SearchIndexGenerator(config: config, manifest: manifest);
    final json = generator.generate();

    final webDirectory = io.Directory('web');
    await webDirectory.create(recursive: true);

    final file = io.File('${webDirectory.path}/search-index.json');
    await file.writeAsString(json);
  }

  /// Create a synchronous ContentApp when the manifest is pre-built.
  ///
  /// Use this when you've already built the navigation manifest at build time.
  static ContentApp createSync({
    required SiteConfig config,
    required NavManifest manifest,
    required ArcaneStylesheet stylesheet,
    List<PageExtension>? extensions,
    List<CustomComponent>? components,
    List<KBStylesheetOption> stylesheetOptions = const <KBStylesheetOption>[],
    DemoBuilder? demoBuilder,
  }) {
    String? landingSourcePath = _resolveLandingSourcePathSync(config);

    // Create scripts
    KBScripts scripts = KBScripts(
      basePath: config.baseUrl,
      stylesheetOptions: stylesheetOptions,
      defaultStylesheetId: _defaultStylesheetId(stylesheet, stylesheetOptions),
    );

    // Create layout
    final KBLayout layout = KBLayout(
      config: config,
      manifest: manifest,
      stylesheet: stylesheet,
      stylesheetOptions: stylesheetOptions,
      scripts: scripts,
      demoBuilder: demoBuilder,
    );

    // Default extensions for markdown processing
    final List<PageExtension> defaultExtensions = <PageExtension>[
      const MediaExtension(),
      const CalloutExtension(),
      HeadingAnchorsExtension(),
      const TableOfContentsExtension(),
      const ReadingTimeExtension(),
    ];

    final List<CustomComponent> defaultComponents =
        KBRichMarkdownComponents.defaults();

    return _contentApp(
      config: config,
      landingSourcePath: landingSourcePath,
      layout: layout,
      extensions: <PageExtension>[...defaultExtensions, ...?extensions],
      components: <CustomComponent>[...defaultComponents, ...?components],
    );
  }

  static String _defaultStylesheetId(
    ArcaneStylesheet stylesheet,
    List<KBStylesheetOption> stylesheetOptions,
  ) {
    for (KBStylesheetOption option in stylesheetOptions) {
      if (identical(option.stylesheet, stylesheet)) {
        return option.id;
      }
    }
    if (stylesheetOptions.isEmpty) {
      return '';
    }
    return stylesheetOptions.first.id;
  }

  static ContentApp _contentApp({
    required SiteConfig config,
    required String? landingSourcePath,
    required KBLayout layout,
    required List<PageExtension> extensions,
    required List<CustomComponent> components,
  }) {
    Set<String> ignoredSourcePaths = _ignoredSourcePaths(landingSourcePath);
    List<RouteLoader> loaders = <RouteLoader>[];

    if (landingSourcePath != null) {
      String landingContent = io.File(
        '${config.contentDirectory}/$landingSourcePath',
      ).readAsStringSync();
      loaders.add(
        MemoryLoader(
          pages: <MemoryPage>[
            MemoryPage(
              path: 'index.md',
              content: landingContent,
              initialData: _landingInitialData(),
            ),
          ],
        ),
      );
    }

    loaders.add(
      _FilteredFilesystemLoader(
        config.contentDirectory,
        ignoredSourcePaths: ignoredSourcePaths,
      ),
    );

    return ContentApp.custom(
      loaders: loaders,
      configResolver: PageConfig.all(
        dataLoaders: <DataLoader>[
          FilesystemDataLoader('${config.contentDirectory}/_data'),
          MemoryDataLoader(<String, Object?>{
            'site': <String, Object?>{'base': _documentBase(config.baseUrl)},
          }),
        ],
        parsers: const <PageParser>[MarkdownParser()],
        layouts: <PageLayout>[layout],
        extensions: extensions,
        components: components,
      ),
    );
  }

  static String _documentBase(String baseUrl) {
    if (baseUrl.isEmpty || baseUrl == '/') {
      return '/';
    }
    return baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  }

  static Future<String?> _resolveLandingSourcePath(SiteConfig config) async {
    String? landingPath = config.landingPath;
    if (landingPath == null || landingPath.trim().isEmpty) {
      return null;
    }
    List<String> candidates = _landingCandidates(landingPath);
    for (String candidate in candidates) {
      io.File file = io.File('${config.contentDirectory}/$candidate');
      if (await file.exists()) {
        return candidate;
      }
    }
    throw Exception(
      'Landing source not found: ${config.contentDirectory}/$landingPath',
    );
  }

  static String? _resolveLandingSourcePathSync(SiteConfig config) {
    String? landingPath = config.landingPath;
    if (landingPath == null || landingPath.trim().isEmpty) {
      return null;
    }
    List<String> candidates = _landingCandidates(landingPath);
    for (String candidate in candidates) {
      io.File file = io.File('${config.contentDirectory}/$candidate');
      if (file.existsSync()) {
        return candidate;
      }
    }
    throw Exception(
      'Landing source not found: ${config.contentDirectory}/$landingPath',
    );
  }

  static List<String> _landingCandidates(String landingPath) {
    String normalized = _normalizeSourcePath(landingPath);
    if (normalized.isEmpty) {
      return const <String>[];
    }
    if (normalized.endsWith('.md')) {
      return <String>[normalized];
    }
    return <String>[
      normalized.endsWith('/')
          ? '${normalized}index.md'
          : '$normalized/index.md',
      '$normalized.md',
    ];
  }

  static Set<String> _ignoredSourcePaths(String? landingSourcePath) {
    if (landingSourcePath == null) {
      return const <String>{};
    }
    return <String>{'index.md', landingSourcePath};
  }

  static String _normalizeSourcePath(String path) {
    String normalized = path.trim().replaceAll('\\', '/');
    while (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  static Map<String, Object?> _landingInitialData() => <String, Object?>{
    'page': <String, Object?>{
      'layout': 'kb',
      'landing': true,
      'pageNav': false,
    },
  };
}

class _FilteredFilesystemLoader extends FilesystemLoader {
  final Set<String> ignoredSourcePaths;

  _FilteredFilesystemLoader(super.directory, {required this.ignoredSourcePaths})
    : super(filterExtensions: const <String>{'.md'});

  @override
  Future<List<FilePageSource>> loadPageSources() async {
    List<FilePageSource> sources = await super.loadPageSources();
    List<FilePageSource> publishedSources = <FilePageSource>[];

    for (FilePageSource source in sources) {
      if (ignoredSourcePaths.contains(source.path)) {
        continue;
      }
      String content = await source.file.readAsString();
      if (_isUnpublished(content)) {
        continue;
      }
      publishedSources.add(source);
    }

    return publishedSources;
  }

  static bool _isUnpublished(String content) {
    RegExp frontmatterPattern = RegExp(
      r'^---\s*\r?\n([\s\S]*?)\r?\n---\s*(?:\r?\n|$)',
    );
    RegExpMatch? match = frontmatterPattern.firstMatch(content);
    if (match == null) {
      return false;
    }

    Object? parsed = loadYaml(match.group(1) ?? '');
    if (parsed is! YamlMap) {
      return false;
    }
    return parsed['draft'] == true || parsed['hidden'] == true;
  }
}
