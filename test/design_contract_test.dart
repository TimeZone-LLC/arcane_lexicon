import 'dart:convert';
import 'dart:io';

import 'package:arcane_jaspr_shadcn/arcane_jaspr_shadcn.dart';
import 'package:arcane_lexicon/arcane_lexicon.dart';
import 'package:arcane_lexicon/src/icons/kb_icon.dart';
import 'package:jaspr/server.dart' show Jaspr, ResponseLike, renderComponent;
import 'package:test/test.dart';

void main() {
  setUpAll(Jaspr.initializeApp);

  group('knowledge base design contract', () {
    test('generated component CSS stays flat and effect-free', () {
      final String css = KBStyles.generate();

      expect(
        css,
        isNot(
          contains(
            RegExp(r'(?:repeating-)?(?:linear|radial|conic)-gradient\('),
          ),
        ),
      );
      expect(
        css,
        isNot(
          contains(
            RegExp(r'border-radius\s*:\s*(?:999\d*px|50%|var\([^)]*full)'),
          ),
        ),
      );
      expect(css, isNot(contains('.kb-callout::before')));
      expect(css, isNot(contains('.markdown-alert-title::before')));
    });

    test('rounded surfaces never receive a one-sided border', () {
      final String css = KBStyles.generate();
      final RegExp rulePattern = RegExp(r'([^{}]+)\{([^{}]*)\}');
      final RegExp surfacePattern = RegExp(
        r'\.kb-(?:card|tile|callout|banner|panel|frame|update|tag|resource|field|view|landing)|\.markdown-alert',
      );
      final RegExp oneSidedBorderPattern = RegExp(
        r'border-(?:left|right|top|bottom)(?:\s*:|-color\s*:|-width\s*:)',
      );

      for (final RegExpMatch match in rulePattern.allMatches(css)) {
        final String selector = match.group(1) ?? '';
        final String declarations = match.group(2) ?? '';
        if (!surfacePattern.hasMatch(selector) ||
            !declarations.contains('border-radius:')) {
          continue;
        }
        expect(
          declarations,
          isNot(contains(oneSidedBorderPattern)),
          reason: 'Rounded surface has a one-sided border: $selector',
        );
      }
    });

    test('content surfaces never add decorative shadows', () {
      final String css = KBStyles.generate();
      final RegExp rulePattern = RegExp(r'([^{}]+)\{([^{}]*)\}');
      final RegExp surfacePattern = RegExp(
        r'\.kb-(?:card|tile|callout|banner|panel|frame|update|tag|resource|field|view|landing)|\.markdown-alert',
      );

      for (final RegExpMatch match in rulePattern.allMatches(css)) {
        final String selector = match.group(1) ?? '';
        if (!surfacePattern.hasMatch(selector)) {
          continue;
        }
        final String declarations = match.group(2) ?? '';
        for (final RegExpMatch shadow in RegExp(
          r'box-shadow\s*:\s*([^;]+)',
        ).allMatches(declarations)) {
          expect(
            shadow.group(1)?.trim(),
            matches(RegExp(r'^none(?:\s*!important)?$')),
            reason: 'Content surface has a decorative shadow: $selector',
          );
        }
      }
    });

    test('nested rich surfaces collapse to one visible frame', () {
      final String css = KBStyles.generate();
      final RegExpMatch? nestedRule = RegExp(
        r':is\(\s*\.kb-card,.*?\)\s*:is\(.*?\)\s*\{([^}]*)\}',
        dotAll: true,
      ).firstMatch(css);

      expect(nestedRule, isNotNull);
      final String declarations = nestedRule?.group(1) ?? '';
      for (final String declaration in <String>[
        'border: 0 !important',
        'border-radius: 0 !important',
        'background: transparent !important',
        'background-image: none !important',
        'box-shadow: none !important',
        'backdrop-filter: none !important',
      ]) {
        expect(declarations, contains(declaration));
      }
    });

    test('search focus uses an outline without a shadow ring', () {
      final String css = KBStyles.generate();
      final RegExpMatch? focusRule = RegExp(
        r'\.kb-search-input:focus\s*\{([^}]*)\}',
      ).firstMatch(css);

      expect(focusRule, isNotNull);
      final String declarations = focusRule?.group(1) ?? '';
      expect(declarations, contains('outline-color: var(--ring)'));
      expect(declarations, isNot(contains('box-shadow')));
    });

    test('implicit rich components do not invent icons', () async {
      final ResponseLike cardResponse = await _renderThemed(
        const KBCardComponent().apply('Card', <String, String>{
          'title': 'Guide',
          'href': '/guide',
        }, const Text('Read the guide')),
        standalone: true,
      );
      final ResponseLike tileResponse = await _renderThemed(
        const KBTileComponent().apply('Tile', <String, String>{
          'title': 'Status',
        }, const Text('Ready')),
        standalone: true,
      );
      final ResponseLike viewResponse = await _renderThemed(
        const KBViewComponent().apply('View', <String, String>{
          'title': 'Output',
        }, const Text('Ready')),
        standalone: true,
      );
      final ResponseLike panelResponse = await _renderThemed(
        const KBPanelComponent().apply('Panel', <String, String>{
          'title': 'Status',
        }, const Text('Ready')),
        standalone: true,
      );
      final ResponseLike iconResponse = await _renderThemed(
        const KBIconComponent().apply('Icon', const <String, String>{}, null),
        standalone: true,
      );
      final String cardHtml = utf8.decode(cardResponse.body);
      final String tileHtml = utf8.decode(tileResponse.body);
      final String viewHtml = utf8.decode(viewResponse.body);
      final String panelHtml = utf8.decode(panelResponse.body);
      final String iconHtml = utf8.decode(iconResponse.body);

      expect(cardHtml, contains('kb-card-content-no-icon'));
      expect(cardHtml, isNot(contains('kb-card-icon')));
      expect(tileHtml, contains('kb-tile-content-no-icon'));
      expect(tileHtml, isNot(contains('kb-tile-icon')));
      expect(viewHtml, contains('kb-view-title'));
      expect(viewHtml, isNot(contains('kb-view-icon')));
      expect(panelHtml, contains('kb-panel-title'));
      expect(panelHtml, isNot(contains('kb-panel-icon')));
      expect(iconHtml, isNot(contains('kb-inline-icon')));
    });

    test('rich components render only explicitly requested icons', () async {
      final ResponseLike cardResponse = await _renderThemed(
        const KBCardComponent().apply('Card', <String, String>{
          'title': 'Guide',
          'href': '/guide',
          'icon': 'book',
        }, const Text('Read the guide')),
        standalone: true,
      );
      final ResponseLike tileResponse = await _renderThemed(
        const KBTileComponent().apply('Tile', <String, String>{
          'title': 'Status',
          'icon': 'activity',
        }, const Text('Ready')),
        standalone: true,
      );
      final ResponseLike viewResponse = await _renderThemed(
        const KBViewComponent().apply('View', <String, String>{
          'title': 'Output',
          'icon': 'terminal',
        }, const Text('Ready')),
        standalone: true,
      );
      final String cardHtml = utf8.decode(cardResponse.body);
      final String tileHtml = utf8.decode(tileResponse.body);
      final String viewHtml = utf8.decode(viewResponse.body);

      expect(cardHtml, contains('kb-card-icon'));
      expect(cardHtml, isNot(contains('kb-card-content-no-icon')));
      expect(tileHtml, contains('kb-tile-icon'));
      expect(tileHtml, isNot(contains('kb-tile-content-no-icon')));
      expect(viewHtml, contains('kb-view-icon'));
    });

    test('rich components use typed styles and fixed column classes', () async {
      final ResponseLike columnsResponse = await _renderThemed(
        const KBColumnsComponent().apply('Columns', <String, String>{
          'cols': '4',
        }, const Text('Columns')),
        standalone: true,
      );
      final ResponseLike colorResponse = await _renderThemed(
        const KBColorItemComponent().apply('Color.Item', <String, String>{
          'label': 'Brand',
          'value': '#123456',
        }, null),
        standalone: true,
      );
      final String columnsHtml = utf8.decode(columnsResponse.body);
      final String colorHtml = utf8.decode(colorResponse.body);
      final String componentsSource = File(
        'lib/src/components/rich_markdown_components.dart',
      ).readAsStringSync();
      final String css = KBStyles.generate();

      expect(columnsHtml, contains('kb-columns-4'));
      expect(colorHtml, contains('background: #123456'));
      expect(componentsSource, isNot(contains('ArcaneStyleData(raw:')));
      expect(css, contains('.kb-columns-1'));
      expect(css, contains('.kb-columns-3'));
      expect(css, contains('.kb-columns-4'));
      expect(css, isNot(contains('--kb-columns')));
    });

    test('routes include only published Markdown files', () async {
      final Directory contentDirectory = await Directory.systemTemp.createTemp(
        'arcane-lexicon-routes-',
      );
      addTearDown(() => contentDirectory.delete(recursive: true));
      await File(
        '${contentDirectory.path}/published.md',
      ).writeAsString('---\ntitle: Published\n---\n# Published\n');
      await File(
        '${contentDirectory.path}/draft.md',
      ).writeAsString('---\ntitle: Draft\ndraft: true\n---\n# Draft\n');
      await File(
        '${contentDirectory.path}/hidden.md',
      ).writeAsString('---\ntitle: Hidden\nhidden: true\n---\n# Hidden\n');

      await File(
        '${contentDirectory.path}/.DS_Store',
      ).writeAsBytes(<int>[0xff, 0xfe, 0x00]);
      await File(
        '${contentDirectory.path}/diagram.png',
      ).writeAsBytes(<int>[0x89, 0x50, 0x4e, 0x47]);
      await File(
        '${contentDirectory.path}/notes.txt',
      ).writeAsString('These notes are not a documentation page.');

      final ContentApp app = await KnowledgeBaseApp.create(
        config: SiteConfig(
          name: 'Route filtering test',
          contentDirectory: contentDirectory.path,
        ),
        stylesheet: const _TestStylesheet(),
        generateSearchIndex: false,
      );
      final FilesystemLoader loader = app.loaders.single as FilesystemLoader;
      await loader.loadRoutes(app.configResolver, false);
      final Set<String> routes = loader.sources
          .map((FilePageSource source) => source.url)
          .toSet();

      expect(routes, <String>{'/published'});
    });

    test('manifest consumers expose published content only', () async {
      const NavItem current = NavItem(
        title: 'Current',
        path: '/current',
        order: 1,
        tags: <String>['shared'],
      );
      const NavItem draft = NavItem(
        title: 'Draft',
        path: '/draft',
        order: 2,
        draft: true,
        tags: <String>['shared'],
      );
      const NavItem hidden = NavItem(
        title: 'Hidden',
        path: '/hidden',
        order: 3,
        hidden: true,
        tags: <String>['shared'],
      );
      const NavItem published = NavItem(
        title: 'Published',
        path: '/published',
        order: 4,
        tags: <String>['shared'],
      );
      const NavManifest manifest = NavManifest(
        items: <NavItem>[current, draft, hidden, published],
        sections: <NavSection>[
          NavSection(
            title: 'Draft section',
            path: '/draft-section',
            items: <NavItem>[draft],
          ),
        ],
      );

      expect(manifest.visibleItems, <NavItem>[current, published]);
      expect(manifest.visibleSections, isEmpty);
      expect(manifest.totalPages, 2);
      expect(jsonEncode(manifest.toJson()), isNot(contains('/draft')));
      expect(jsonEncode(manifest.toJson()), isNot(contains('/hidden')));

      final ResponseLike pageNavResponse = await _renderThemed(
        const KBPageNav(
          config: SiteConfig(name: 'Published-only test'),
          manifest: manifest,
          currentPath: '/current',
        ),
        standalone: true,
      );
      final ResponseLike relatedResponse = await _renderThemed(
        const KBRelatedPages(
          config: SiteConfig(name: 'Published-only test'),
          manifest: manifest,
          currentPath: '/current',
          currentTags: <String>['shared'],
        ),
        standalone: true,
      );
      final String html = <ResponseLike>[
        pageNavResponse,
        relatedResponse,
      ].map((ResponseLike response) => utf8.decode(response.body)).join();

      expect(html, contains('href="/published"'));
      expect(utf8.decode(pageNavResponse.body), contains('Published'));
      expect(utf8.decode(relatedResponse.body), contains('Published'));
      expect(html, isNot(contains('href="/draft"')));
      expect(html, isNot(contains('href="/hidden"')));
    });

    test('tree folder summaries render at most one icon', () async {
      final ResponseLike response = await _renderThemed(
        const KBTreeFolderComponent().apply('Tree.Folder', <String, String>{
          'name': 'content',
        }, null),
        standalone: true,
      );
      final String html = utf8.decode(response.body);
      final RegExpMatch? summary = RegExp(
        r'<summary[^>]*kb-tree-folder-summary[^>]*>(.*?)</summary>',
        dotAll: true,
      ).firstMatch(html);

      expect(summary, isNotNull);
      expect(
        RegExp(r'<(?:i|svg|img)\b').allMatches(summary?.group(1) ?? '').length,
        lessThanOrEqualTo(1),
      );
    });

    test('navigation icons use one canonical KBIcon renderer path', () async {
      final String sidebarSource = File(
        'lib/src/layout/kb_sidebar.dart',
      ).readAsStringSync();
      final String renderersSource = File(
        'lib/src/layout/kb_renderers.dart',
      ).readAsStringSync();

      expect(
        sidebarSource,
        contains(
          'Widget _buildIcon(String iconName) =>\n'
          "      KBIcon.build(iconName, classes: 'sidebar-icon');",
        ),
      );
      expect(
        renderersSource,
        contains(
          'Widget icon(KnowledgeBaseRenderData data, String iconName) =>\n'
          '      KBIcon.build(',
        ),
      );

      final ResponseLike response = await _renderThemed(
        KBIcon.build('rocket', classes: 'sidebar-icon'),
        standalone: true,
      );
      final String html = utf8.decode(response.body);
      expect(RegExp(r'<(?:i|svg|img)\b').allMatches(html).length, 1);
    });

    test('retired component aliases are absent from the public API', () {
      final RegExp pathPattern = const KBPathComponent().pattern as RegExp;
      final RegExp fieldGroupPattern =
          const KBFieldGroupComponent().pattern as RegExp;
      final RegExp treeFilePattern =
          const KBTreeFileComponent().pattern as RegExp;
      final RegExp colorItemPattern =
          const KBColorItemComponent().pattern as RegExp;
      expect(pathPattern.matchAsPrefix('FilePath'), isNotNull);
      expect(pathPattern.matchAsPrefix('PathChip'), isNull);
      expect(fieldGroupPattern.matchAsPrefix('FieldGroup'), isNotNull);
      expect(fieldGroupPattern.matchAsPrefix('Fields'), isNull);
      expect(treeFilePattern.matchAsPrefix('Tree.File'), isNotNull);
      expect(treeFilePattern.matchAsPrefix('TreeItem'), isNull);
      expect(colorItemPattern.matchAsPrefix('Color.Item'), isNotNull);
      expect(colorItemPattern.matchAsPrefix('ColorItem'), isNull);

      final String publicLibrary = File(
        'lib/arcane_lexicon.dart',
      ).readAsStringSync();
      final String components = Directory('lib/src/components')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
          .map((File file) => file.readAsStringSync())
          .join('\n');
      expect(publicLibrary, isNot(contains('kb_tag_chips.dart')));
      expect(components, isNot(contains('KBTagChip')));
      expect(components, isNot(contains('PathChip')));

      final String icons = File(
        'lib/src/icons/kb_icon.dart',
      ).readAsStringSync();
      expect(icons, isNot(contains("'sparkles'")));

      final String navSection = File(
        'lib/src/navigation/nav_section.dart',
      ).readAsStringSync();
      expect(navSection, isNot(contains('NavSection.fromYaml')));

      final String iconDocs = File(
        'example/content/reference/icons.md',
      ).readAsStringSync();
      expect(iconDocs, isNot(contains('`sparkles`')));
    });

    test('component markup omits backplates and trailing indicators', () {
      final String richComponents = File(
        'lib/src/components/rich_markdown_components.dart',
      ).readAsStringSync();
      final String pageNavigation = File(
        'lib/src/layout/kb_page_nav.dart',
      ).readAsStringSync();
      final String relatedPages = File(
        'lib/src/layout/kb_related_pages.dart',
      ).readAsStringSync();

      for (final String retiredClass in <String>[
        'kb-card-top',
        'kb-card-leading',
        'kb-card-indicator',
        'kb-tile-top',
        'kb-tile-indicator',
        'kb-resource-top',
        'kb-resource-indicator',
        'kb-banner-indicator',
      ]) {
        expect(richComponents, isNot(contains(retiredClass)));
      }
      expect(pageNavigation, isNot(contains('kb-subpage-card')));
      expect(relatedPages, isNot(contains('kb-related-card')));
    });

    test('section components use neutral divider elements', () async {
      const NavManifest manifest = NavManifest(
        items: <NavItem>[
          NavItem(title: 'Current', path: '/current', order: 1),
          NavItem(title: 'Next', path: '/next', order: 2),
        ],
        sections: <NavSection>[],
      );
      final List<ResponseLike> responses = <ResponseLike>[
        await _renderThemed(
          const KBPageNav(
            config: SiteConfig(name: 'Divider test'),
            manifest: manifest,
            currentPath: '/current',
          ),
          standalone: true,
        ),
        await _renderThemed(
          const KBChangelog(
            versions: <ChangelogVersion>[
              ChangelogVersion(
                version: '1.0.0',
                sections: <String, List<String>>{
                  'Changed': <String>['Flattened the docs layout'],
                },
              ),
            ],
          ),
          standalone: true,
        ),
        await _renderThemed(
          const KBRating(pagePath: '/current'),
          standalone: true,
        ),
      ];
      final String html = responses
          .map((ResponseLike response) => utf8.decode(response.body))
          .join('\n');

      expect(
        RegExp('kb-section-divider').allMatches(html).length,
        greaterThanOrEqualTo(4),
      );
      expect(html, isNot(contains('border-top:')));

      final String layoutSources = <String>[
        'lib/src/layout/kb_page_nav.dart',
        'lib/src/layout/kb_related_pages.dart',
        'lib/src/layout/kb_changelog.dart',
        'lib/src/layout/kb_rating.dart',
      ].map((String path) => File(path).readAsStringSync()).join('\n');
      expect(
        layoutSources,
        isNot(contains(RegExp(r'border(?:Top|Right|Bottom|Left)\s*:'))),
      );
      expect(
        layoutSources,
        isNot(
          contains(RegExp(r'''['"]border-(?:top|right|bottom|left)['"]\s*:''')),
        ),
      );
    });

    test('interactive hidden states remain semantic and effect-free', () async {
      final ResponseLike searchResponse = await _renderThemed(
        const DefaultKnowledgeBaseRenderers().searchBox(),
        standalone: true,
      );
      final String searchHtml = utf8.decode(searchResponse.body);
      final String scripts = const KBScripts().generate();
      final String renderers = File(
        'lib/src/layout/kb_renderers.dart',
      ).readAsStringSync();
      final String css = KBStyles.generate();

      expect(searchHtml, contains('role="combobox"'));
      expect(searchHtml, contains('aria-label="Search documentation"'));
      expect(searchHtml, contains('aria-expanded="false"'));
      expect(searchHtml, contains('role="listbox"'));
      expect(searchHtml, contains('hidden'));
      expect(scripts, contains("input.setAttribute('aria-expanded', 'true')"));
      expect(scripts, contains("input.setAttribute('aria-controls'"));
      expect(scripts, contains("sidebar.setAttribute('inert', '')"));
      expect(scripts, contains("toggle.setAttribute('aria-controls'"));
      expect(scripts, contains("e.key !== 'Escape'"));
      expect(
        scripts,
        contains("copyBtn.setAttribute('aria-label', 'Copy code')"),
      );
      expect(scripts, contains("document.querySelectorAll('.kb-rating')"));
      expect(scripts, isNot(contains('searchResults.innerHTML')));
      expect(
        renderers,
        contains('kb-sidebar-search-mobile-only'),
        reason: 'Mobile users need a reachable search control in the drawer.',
      );
      final RegExpMatch? searchResultsOverride = RegExp(
        r'#arcane-root \.kb-style-slot \.search-results\s*\{([^}]*)\}',
      ).firstMatch(css);
      expect(searchResultsOverride, isNotNull);
      final String searchResultsDeclarations =
          searchResultsOverride?.group(1) ?? '';
      expect(
        searchResultsDeclarations,
        contains('box-shadow: none !important'),
        reason: 'The KB override must outrank renderer overlay shadows.',
      );
      expect(
        searchResultsDeclarations,
        contains('backdrop-filter: none !important'),
      );
      for (final RegExpMatch match in RegExp(
        r'box-shadow\s*:\s*([^;]+)',
      ).allMatches(css)) {
        expect(
          match.group(1)?.trim(),
          matches(RegExp(r'^none(?:\s*!important)?$')),
        );
      }
    });

    test('Lexicon never generates or loads remote font CSS', () {
      final List<String> sources = <String>[
        File('lib/src/layout/kb_layout.dart').readAsStringSync(),
        File('lib/src/cli/arcane_lexicon_cli.dart').readAsStringSync(),
        File('example/web/styles.css').readAsStringSync(),
      ];

      for (final String source in sources) {
        expect(
          source,
          isNot(
            contains(
              RegExp(r'''https?://[^\s"']*font''', caseSensitive: false),
            ),
          ),
        );
        expect(
          source,
          isNot(
            contains(
              RegExp(
                r'''(?:@import\s+(?:url\()?|@font-face[\s\S]*?url\()\s*["']?https?://''',
                caseSensitive: false,
              ),
            ),
          ),
        );
      }

      const String canonicalCss =
          "@font-face { font-family: 'lucide'; src: url('/assets/fonts/lucide/lucide.woff2') format('woff2'); }";
      final String rewritten = KBLayout.rewriteAssetUrlsForBasePath(
        canonicalCss,
        '/docs',
      );
      expect(rewritten, isNot(contains('https://')));
      expect(rewritten, contains('/docs/assets/fonts/lucide/lucide.woff2'));
      expect(
        RegExp(r'url\(').allMatches(rewritten).length,
        1,
        reason: 'A canonical local font must remain a single source.',
      );

      const String stylesheetCss =
          "@font-face { font-family: 'lucide'; src: url('/assets/fonts/lucide/lucide.woff2') format('woff2'), url('/fonts/lucide/lucide.woff') format('woff'), url('../assets/fonts/lucide/lucide.ttf') format('truetype'); }";
      final String canonicalStylesheetCss =
          KBLayout.rewriteAssetUrlsForBasePath(stylesheetCss, '/docs');
      expect(
        canonicalStylesheetCss,
        contains('/docs/assets/fonts/lucide/lucide.woff2'),
      );
      expect(
        RegExp(r'url\(').allMatches(canonicalStylesheetCss).length,
        1,
        reason: 'The generated font face must reference one bundled asset.',
      );
      expect(canonicalStylesheetCss, isNot(contains("lucide.woff'")));
      expect(canonicalStylesheetCss, isNot(contains('lucide.ttf')));

      const String remoteCss =
          "@font-face { font-family: 'lucide'; src: url('https://cdn.example/lucide.woff2') format('woff2'); }";
      expect(
        KBLayout.rewriteAssetUrlsForBasePath(remoteCss, '/docs'),
        remoteCss,
        reason: 'Asset rewriting must not repair unsupported remote sources.',
      );
    });

    test('configured subpath becomes document-base page data', () async {
      final Directory contentDirectory = await Directory.systemTemp.createTemp(
        'arcane-lexicon-base-',
      );
      addTearDown(() => contentDirectory.delete(recursive: true));
      await File(
        '${contentDirectory.path}/index.md',
      ).writeAsString('---\ntitle: Home\nlayout: kb\n---\n# Home\n');

      final ContentApp app = await KnowledgeBaseApp.create(
        config: SiteConfig(
          name: 'Subpath test',
          baseUrl: '/arcane_lexicon',
          contentDirectory: contentDirectory.path,
        ),
        stylesheet: const _TestStylesheet(),
        generateSearchIndex: false,
      );
      final FilesystemLoader loader = app.loaders.single as FilesystemLoader;
      await loader.loadRoutes(app.configResolver, false);
      final FilePageSource source = loader.sources.single;
      final Page page = await source.buildPage();
      page.parseFrontmatter();
      await page.loadData();

      expect(page.data.site['base'], '/arcane_lexicon/');
    });
  });
}

class _TestStylesheet extends ArcaneStylesheet {
  const _TestStylesheet();

  @override
  String get id => 'test';

  @override
  String get name => 'Test';

  @override
  ComponentRenderers get renderers => throw UnsupportedError('Not rendered');

  @override
  ThemeSeed get lightSeed => throw UnsupportedError('Not rendered');
}

Future<ResponseLike> _renderThemed(Widget child, {bool standalone = false}) {
  return renderComponent(
    ArcaneThemeProvider(stylesheet: const ShadcnStylesheet(), child: child),
    standalone: standalone,
  );
}
