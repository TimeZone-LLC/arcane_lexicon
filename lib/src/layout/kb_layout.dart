import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/html.dart' show ArcaneDiv;
import 'package:arcane_jaspr/web.dart' show RawText, div, link, meta, script;
import 'package:jaspr_content/jaspr_content.dart';

import '../config/site_config.dart';
import '../navigation/nav_builder.dart';
import '../navigation/nav_item.dart';
import '../navigation/nav_section.dart';
import '../scripts/kb_scripts.dart';
import '../styles/kb_styles.dart';
import 'kb_renderers.dart';

/// Callback type for building demo components.
///
/// The callback receives the component type from frontmatter and returns
/// a Widget to render as the live demo, or null if no demo is available.
typedef DemoBuilder = Widget? Function(String componentType);

/// The main layout wrapper for knowledge base pages.
/// Matches the arcane_jaspr_neon pattern with single-line theming.
class KBLayout extends PageLayoutBase {
  final SiteConfig config;
  final NavManifest manifest;
  final ArcaneStylesheet stylesheet;
  final List<KBStylesheetOption> stylesheetOptions;
  final KBScripts scripts;
  final DemoBuilder? demoBuilder;

  KBLayout({
    required this.config,
    required this.manifest,
    required this.stylesheet,
    this.stylesheetOptions = const <KBStylesheetOption>[],
    KBScripts? scripts,
    this.demoBuilder,
  }) : scripts =
           scripts ??
           KBScripts(
             basePath: config.baseUrl,
             stylesheetOptions: stylesheetOptions,
             paletteSwitcherEnabled: config.paletteSwitcherEnabled,
           );

  @override
  Pattern get name => 'kb';

  @override
  Iterable<Widget> buildHead(Page page) sync* {
    yield* super.buildHead(page);

    final Map<String, dynamic> pageData = page.data.page;
    final String assetPrefix = config.assetPrefix;
    List<KBStylesheetOption> effectiveStylesheetOptions =
        _effectiveStylesheetOptions();
    String activeStylesheetId = _activeStylesheetId(effectiveStylesheetOptions);
    String activePaletteId = _activePaletteId(
      effectiveStylesheetOptions,
      activeStylesheetId,
    );

    // Title
    final String title = pageData['title'] as String? ?? config.name;
    yield Widget.element(
      tag: 'title',
      children: [Widget.text('$title - ${config.name}')],
    );

    // Description
    final String? description =
        pageData['description'] as String? ?? config.description;
    if (description != null) {
      yield meta(name: 'description', content: description);
    }

    // Viewport and theme color
    yield const meta(
      name: 'viewport',
      content: 'width=device-width, initial-scale=1',
    );
    yield const meta(name: 'theme-color', content: '#09090b');

    // Favicons
    yield link(
      rel: 'icon',
      type: 'image/x-icon',
      href: '$assetPrefix/assets/favicon.ico',
    );
    yield link(
      rel: 'icon',
      type: 'image/png',
      href: '$assetPrefix/assets/icon-32.png',
      attributes: const {'sizes': '32x32'},
    );
    yield link(
      rel: 'icon',
      type: 'image/png',
      href: '$assetPrefix/assets/icon-16.png',
      attributes: const {'sizes': '16x16'},
    );

    if (stylesheetOptions.isEmpty) {
      String rewrittenBaseCss = _rewriteAssetUrls(
        stylesheet.baseCss,
        assetPrefix,
      );
      yield Widget.element(
        tag: 'style',
        attributes: const {'id': 'arcane-theme-vars'},
        children: [RawText(rewrittenBaseCss)],
      );
    } else {
      for (KBStylesheetOption option in effectiveStylesheetOptions) {
        for (_PaletteEntry palette in _palettesFor(option)) {
          bool isActive =
              option.id == activeStylesheetId && palette.id == activePaletteId;
          String rewrittenBaseCss = _rewriteAssetUrls(
            palette.stylesheet.baseCss,
            assetPrefix,
          );
          yield Widget.element(
            tag: 'style',
            attributes: <String, String>{
              'id': 'arcane-theme-vars-${option.id}-${palette.id}',
              'data-kb-stylesheet-id': option.id,
              'data-kb-palette-id': palette.id,
              'media': isActive ? 'all' : 'not all',
            },
            children: [RawText(rewrittenBaseCss)],
          );
        }
      }
    }

    // Inject default KB component styles (base structural styles)
    // Injected BEFORE componentCss so stylesheet overrides can take precedence
    yield Widget.element(
      tag: 'style',
      attributes: const {'id': 'arcane-kb-styles'},
      children: [RawText(KBStyles.generate())],
    );

    if (stylesheetOptions.isEmpty) {
      String rewrittenWidgetCss = _rewriteAssetUrls(
        stylesheet.componentCss,
        assetPrefix,
      );
      yield Widget.element(
        tag: 'style',
        attributes: const {'id': 'arcane-component-styles'},
        children: [RawText(rewrittenWidgetCss)],
      );
    } else {
      for (KBStylesheetOption option in effectiveStylesheetOptions) {
        for (_PaletteEntry palette in _palettesFor(option)) {
          bool isActive =
              option.id == activeStylesheetId && palette.id == activePaletteId;
          String rewrittenWidgetCss = _rewriteAssetUrls(
            palette.stylesheet.componentCss,
            assetPrefix,
          );
          yield Widget.element(
            tag: 'style',
            attributes: <String, String>{
              'id': 'arcane-component-styles-${option.id}-${palette.id}',
              'data-kb-stylesheet-id': option.id,
              'data-kb-palette-id': palette.id,
              'media': isActive ? 'all' : 'not all',
            },
            children: [RawText(rewrittenWidgetCss)],
          );
        }
      }
    }

    // Load custom styles.css after theme variables
    yield link(rel: 'stylesheet', href: '$assetPrefix/styles.css');

    // Highlight.js for syntax highlighting
    yield const script(
      attributes: {
        'src':
            'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js',
      },
    );
    yield const script(
      attributes: {
        'src':
            'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/dart.min.js',
      },
    );

    // Theme initialization script
    yield script(content: scripts.generateThemeInit());
  }

  @override
  Widget buildBody(Page page, Widget child) {
    final Map<String, dynamic> pageData = page.data.page;

    // Extract tags from frontmatter
    List<String> tags = <String>[];
    final dynamic rawTags = pageData['tags'];
    if (rawTags is List) {
      tags = rawTags.map((dynamic t) => t.toString()).toList();
    } else if (rawTags is String) {
      tags = rawTags.split(',').map((String t) => t.trim()).toList();
    }

    // Extract reading time
    final int? readingTime = pageData['readingTime'] as int?;

    // Extract author
    final String? author = pageData['author'] as String?;

    // Extract date
    final String? date = pageData['date'] as String?;

    // Extract component type for demo injection
    final String? componentType = pageData['component'] as String?;
    bool isLanding =
        _landingValue(pageData['landing']) ||
        _pathsMatch(page.url, config.homeRoute);
    bool? pageNavOverride;
    dynamic rawPageNav = pageData['pageNav'];
    if (rawPageNav is bool) {
      pageNavOverride = rawPageNav;
    } else if (rawPageNav is String) {
      String normalizedPageNav = rawPageNav.trim().toLowerCase();
      if (normalizedPageNav == 'true') {
        pageNavOverride = true;
      } else if (normalizedPageNav == 'false') {
        pageNavOverride = false;
      }
    }

    // Find the NavItem for this page to get lastModified
    final NavItem? navItem = _findNavItem(page.url);
    final String? lastModified = navItem?.lastModified;

    return ThemedKBPage(
      config: config,
      manifest: manifest,
      stylesheet: stylesheet,
      stylesheetOptions: stylesheetOptions,
      scripts: scripts,
      currentPath: page.url,
      title: pageData['title'] as String?,
      description: pageData['description'] as String?,
      toc: page.data['toc'] as TableOfContents?,
      tags: tags,
      readingTime: readingTime,
      author: author,
      date: date,
      lastModified: lastModified,
      componentType: componentType,
      landing: isLanding,
      pageNavOverride: pageNavOverride,
      demoBuilder: demoBuilder,
      content: child,
    );
  }

  String _rewriteAssetUrls(String css, String assetPrefix) {
    return KBLayout.rewriteAssetUrlsForBasePath(css, assetPrefix);
  }

  List<KBStylesheetOption> _effectiveStylesheetOptions() {
    if (stylesheetOptions.isNotEmpty) {
      return stylesheetOptions;
    }
    return <KBStylesheetOption>[
      KBStylesheetOption(
        id: 'default',
        label: 'Default',
        stylesheet: stylesheet,
      ),
    ];
  }

  String _activeStylesheetId(List<KBStylesheetOption> options) {
    for (KBStylesheetOption option in options) {
      if (identical(option.stylesheet, stylesheet)) {
        return option.id;
      }
      for (KBPaletteOption palette in option.palettes) {
        if (identical(palette.stylesheet, stylesheet)) {
          return option.id;
        }
      }
    }
    return options.first.id;
  }

  String _activePaletteId(
    List<KBStylesheetOption> options,
    String activeStylesheetId,
  ) {
    for (KBStylesheetOption option in options) {
      if (option.id != activeStylesheetId) {
        continue;
      }
      List<_PaletteEntry> palettes = _palettesFor(option);
      for (_PaletteEntry palette in palettes) {
        if (identical(palette.stylesheet, stylesheet)) {
          return palette.id;
        }
      }
      return palettes.first.id;
    }
    return _PaletteEntry.defaultId;
  }

  List<_PaletteEntry> _palettesFor(KBStylesheetOption option) {
    if (option.palettes.isEmpty) {
      return <_PaletteEntry>[
        _PaletteEntry(
          id: _PaletteEntry.defaultId,
          label: option.label,
          stylesheet: option.stylesheet,
        ),
      ];
    }
    List<_PaletteEntry> result = <_PaletteEntry>[];
    for (KBPaletteOption palette in option.palettes) {
      result.add(
        _PaletteEntry(
          id: palette.id,
          label: palette.label,
          stylesheet: palette.stylesheet,
        ),
      );
    }
    return result;
  }

  static String rewriteAssetUrlsForBasePath(String css, String assetPrefix) {
    final String normalizedPrefix =
        assetPrefix.endsWith('/') && assetPrefix.isNotEmpty
        ? assetPrefix.substring(0, assetPrefix.length - 1)
        : assetPrefix;
    final String lucideFontUrl =
        '$normalizedPrefix/assets/fonts/lucide/lucide.woff2';
    String rewritten = css.replaceAllMapped(
      RegExp(r'''src\s*:\s*[^;}]*fonts/lucide/[^;}]*;''', caseSensitive: false),
      (Match match) {
        final String source = match.group(0) ?? '';
        if (RegExp(r'https?://', caseSensitive: false).hasMatch(source)) {
          return source;
        }
        return "src: url('$lucideFontUrl') format('woff2');";
      },
    );
    if (normalizedPrefix.isNotEmpty) {
      rewritten = rewritten.replaceAll(
        "url('/assets/",
        "url('$normalizedPrefix/assets/",
      );
      rewritten = rewritten.replaceAll(
        'url("/assets/',
        'url("$normalizedPrefix/assets/',
      );
      rewritten = rewritten.replaceAll(
        'url(/assets/',
        'url($normalizedPrefix/assets/',
      );
    }
    return rewritten;
  }

  /// Find a NavItem by its path in the manifest.
  NavItem? _findNavItem(String path) {
    // Check root items
    for (final NavItem item in manifest.items) {
      if (_pathsMatch(item.path, path)) return item;
    }
    // Check sections recursively
    return _findNavItemInSections(manifest.sections, path);
  }

  NavItem? _findNavItemInSections(List<NavSection> sections, String path) {
    for (final NavSection section in sections) {
      for (final NavItem item in section.items) {
        if (_pathsMatch(item.path, path)) return item;
      }
      final NavItem? found = _findNavItemInSections(section.sections, path);
      if (found != null) return found;
    }
    return null;
  }

  bool _pathsMatch(String a, String b) {
    // Normalize paths for comparison
    final String normalA = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final String normalB = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    return normalA == normalB;
  }

  bool _landingValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      String normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 'yes' ||
          normalized == 'landing';
    }
    return false;
  }
}

/// Documentation page wrapper with light/dark mode toggle.
class ThemedKBPage extends StatefulWidget {
  final SiteConfig config;
  final NavManifest manifest;
  final ArcaneStylesheet stylesheet;
  final List<KBStylesheetOption> stylesheetOptions;
  final KBScripts scripts;
  final String currentPath;
  final String? title;
  final String? description;
  final TableOfContents? toc;
  final List<String> tags;
  final int? readingTime;
  final String? author;
  final String? date;
  final String? lastModified;
  final String? componentType;
  final bool landing;
  final bool? pageNavOverride;
  final DemoBuilder? demoBuilder;
  final Widget content;

  const ThemedKBPage({
    required this.config,
    required this.manifest,
    required this.stylesheet,
    this.stylesheetOptions = const <KBStylesheetOption>[],
    required this.scripts,
    required this.currentPath,
    this.title,
    this.description,
    this.toc,
    this.tags = const <String>[],
    this.readingTime,
    this.author,
    this.date,
    this.lastModified,
    this.componentType,
    this.landing = false,
    this.pageNavOverride,
    this.demoBuilder,
    required this.content,
  });

  @override
  State<ThemedKBPage> createState() => _ThemedKBPageState();
}

class _ThemedKBPageState extends State<ThemedKBPage> {
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _isDark = widget.config.defaultTheme != KBThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    String activeStylesheetId = widget.stylesheetOptions.isEmpty
        ? ''
        : _activeStylesheetId();
    String activePaletteId = widget.stylesheetOptions.isEmpty
        ? ''
        : _activePaletteId(activeStylesheetId);
    String themeClass = _isDark ? 'dark' : '';
    String? stylesheetClass = widget.stylesheetOptions.isEmpty
        ? widget.stylesheet.bodyClass
        : _activePaletteBodyClass(activeStylesheetId, activePaletteId);
    String? stylesheetOptionClass = widget.stylesheetOptions.isEmpty
        ? null
        : 'kb-style-$activeStylesheetId';
    String themeIdentityClass = widget.stylesheetOptions.isEmpty
        ? 'arcane-theme-${widget.stylesheet.id}'
        : 'arcane-theme-$activeStylesheetId';
    String? paletteOptionClass = widget.stylesheetOptions.isEmpty
        ? null
        : 'kb-palette-$activePaletteId';
    String rootClasses = [
      themeClass,
      themeIdentityClass,
      stylesheetOptionClass,
      paletteOptionClass,
      stylesheetClass,
    ].where((String? c) => c != null && c.isNotEmpty).join(' ');

    return ArcaneThemeProvider(
      stylesheet: widget.stylesheet,
      brightness: _isDark ? Brightness.dark : Brightness.light,
      child: ArcaneDiv(
        id: 'arcane-root',
        classes: <String>[rootClasses],
        styles: const ArcaneStyleData(
          minHeight: '100vh',
          background: Background.background,
          textColor: TextColor.primary,
          fontFamily: FontFamily.sans,
        ),
        attributes: <String, String>{
          'data-arcane-theme': activeStylesheetId.isEmpty
              ? widget.stylesheet.id
              : activeStylesheetId,
          if (activePaletteId.isNotEmpty)
            'data-arcane-palette': activePaletteId,
        },
        children: [..._buildStyleSlots(activeStylesheetId), ..._buildScripts()],
      ),
    );
  }

  Iterable<Widget> _buildStyleSlots(String activeStylesheetId) sync* {
    List<KBStylesheetOption> options = _effectiveStylesheetOptions();
    for (KBStylesheetOption option in options) {
      // A single-stylesheet app has no switcher and an empty activeStylesheetId,
      // so its one synthesized slot must always be active (otherwise the whole
      // page renders hidden).
      bool active = options.length == 1 || option.id == activeStylesheetId;
      // Theme-specific docs renderers come from arcane_jaspr_kb; options
      // without one use the default docs chrome.
      KnowledgeBaseRenderers renderers =
          option.knowledgeBaseRenderers ??
          const DefaultKnowledgeBaseRenderers();
      ArcaneStylesheet slotStylesheet = option.stylesheet;
      String slotClass = renderers is DefaultKnowledgeBaseRenderers
          ? renderers.slotClass
          : '${option.id}-kb-slot';
      yield ArcaneThemeProvider(
        stylesheet: slotStylesheet,
        brightness: _isDark ? Brightness.dark : Brightness.light,
        child: div(
          classes:
              'kb-style-slot $slotClass ${active ? 'kb-style-slot-active' : ''}',
          attributes: <String, String>{
            'data-kb-style-slot': option.id,
            'aria-hidden': active ? 'false' : 'true',
            if (!active) 'hidden': '',
            if (!active) 'inert': '',
          },
          [_buildPageLayoutFor(renderers)],
        ),
      );
    }
  }

  Widget _buildPageLayoutFor(KnowledgeBaseRenderers renderers) {
    bool showNavigationBar = widget.config.navigationBarEnabled;
    bool useTopPosition =
        widget.config.navigationBarPosition == KBNavigationBarPosition.top;
    bool showSidebarControls = !showNavigationBar;
    String sidebarTopOffset = showNavigationBar && useTopPosition
        ? '56px'
        : '0px';
    String activeStylesheetId = widget.stylesheetOptions.isEmpty
        ? ''
        : _activeStylesheetId();
    String activePaletteId = widget.stylesheetOptions.isEmpty
        ? ''
        : _activePaletteId(activeStylesheetId);

    return renderers.shell(
      KnowledgeBaseRenderData(
        config: widget.config,
        manifest: widget.manifest,
        stylesheetOptions: widget.stylesheetOptions,
        activeStylesheetId: activeStylesheetId,
        activePaletteId: activePaletteId,
        currentPath: widget.currentPath,
        title: widget.title,
        description: widget.description,
        toc: widget.toc,
        tags: widget.tags,
        readingTime: widget.readingTime,
        author: widget.author,
        date: widget.date,
        lastModified: widget.lastModified,
        landing: widget.landing,
        showNavigationBar: showNavigationBar,
        useTopPosition: useTopPosition,
        showSidebarControls: showSidebarControls,
        sidebarTopOffset: sidebarTopOffset,
        showPageNav: _showPageNav(),
        demoWidget: _buildDemoWidget(),
        content: widget.content,
      ),
    );
  }

  List<KBStylesheetOption> _effectiveStylesheetOptions() {
    if (widget.stylesheetOptions.isNotEmpty) {
      return widget.stylesheetOptions;
    }
    return <KBStylesheetOption>[
      KBStylesheetOption(
        id: 'default',
        label: 'Default',
        stylesheet: widget.stylesheet,
      ),
    ];
  }

  Widget? _buildDemoWidget() {
    if (widget.componentType != null && widget.demoBuilder != null) {
      return widget.demoBuilder!(widget.componentType!);
    }
    return null;
  }

  bool _showPageNav() {
    bool? pageOverride = widget.pageNavOverride;
    if (pageOverride != null) {
      return pageOverride;
    }
    return widget.config.pageNavEnabled;
  }

  String _activeStylesheetId() {
    for (KBStylesheetOption option in widget.stylesheetOptions) {
      if (identical(option.stylesheet, widget.stylesheet)) {
        return option.id;
      }
      for (KBPaletteOption palette in option.palettes) {
        if (identical(palette.stylesheet, widget.stylesheet)) {
          return option.id;
        }
      }
    }
    return widget.stylesheetOptions.first.id;
  }

  String _activePaletteId(String activeStylesheetId) {
    for (KBStylesheetOption option in widget.stylesheetOptions) {
      if (option.id != activeStylesheetId) {
        continue;
      }
      if (option.palettes.isEmpty) {
        return _PaletteEntry.defaultId;
      }
      for (KBPaletteOption palette in option.palettes) {
        if (identical(palette.stylesheet, widget.stylesheet)) {
          return palette.id;
        }
      }
      return option.palettes.first.id;
    }
    return _PaletteEntry.defaultId;
  }

  String? _activePaletteBodyClass(
    String activeStylesheetId,
    String activePaletteId,
  ) {
    for (KBStylesheetOption option in widget.stylesheetOptions) {
      if (option.id != activeStylesheetId) {
        continue;
      }
      if (option.palettes.isEmpty) {
        return option.stylesheet.bodyClass;
      }
      for (KBPaletteOption palette in option.palettes) {
        if (palette.id == activePaletteId) {
          return palette.bodyClass ?? palette.stylesheet.bodyClass;
        }
      }
      return option.stylesheet.bodyClass;
    }
    return widget.stylesheet.bodyClass;
  }

  /// JavaScript for static site functionality
  Iterable<Widget> _buildScripts() sync* {
    yield script(content: widget.scripts.generate());
    // Component interactivity scripts from arcane_jaspr
    yield const ArcaneScriptsComponent();
  }
}

class _PaletteEntry {
  static const String defaultId = 'default';

  final String id;
  final String label;
  final ArcaneStylesheet stylesheet;

  const _PaletteEntry({
    required this.id,
    required this.label,
    required this.stylesheet,
  });
}
