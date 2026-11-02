import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/web.dart' as dom;
import 'package:arcane_lexicon/src/components/kb_tags.dart';
import 'package:arcane_lexicon/src/config/site_config.dart';
import 'package:arcane_lexicon/src/icons/kb_icon.dart';
import 'package:arcane_lexicon/src/layout/kb_page_nav.dart';
import 'package:arcane_lexicon/src/layout/kb_rating.dart';
import 'package:arcane_lexicon/src/navigation/nav_builder.dart';
import 'package:arcane_lexicon/src/navigation/nav_item.dart';
import 'package:arcane_lexicon/src/navigation/nav_section.dart';
import 'package:jaspr_content/jaspr_content.dart';

class KnowledgeBaseRenderData {
  final SiteConfig config;
  final NavManifest manifest;
  final List<KBStylesheetOption> stylesheetOptions;
  final String activeStylesheetId;
  final String activePaletteId;
  final String currentPath;
  final String? title;
  final String? description;
  final TableOfContents? toc;
  final List<String> tags;
  final int? readingTime;
  final String? author;
  final String? date;
  final String? lastModified;
  final bool landing;
  final bool showNavigationBar;
  final bool useTopPosition;
  final bool showSidebarControls;
  final String sidebarTopOffset;
  final bool showPageNav;
  final Widget? demoWidget;
  final Widget content;

  const KnowledgeBaseRenderData({
    required this.config,
    required this.manifest,
    required this.stylesheetOptions,
    required this.activeStylesheetId,
    required this.activePaletteId,
    required this.currentPath,
    required this.title,
    required this.description,
    required this.toc,
    required this.tags,
    required this.readingTime,
    required this.author,
    required this.date,
    required this.lastModified,
    required this.landing,
    required this.showNavigationBar,
    required this.useTopPosition,
    required this.showSidebarControls,
    required this.sidebarTopOffset,
    required this.showPageNav,
    required this.demoWidget,
    required this.content,
  });
}

abstract class KnowledgeBaseRenderers {
  const KnowledgeBaseRenderers();

  String get id;

  String get prefix;

  Widget shell(KnowledgeBaseRenderData data);

  Widget topBar(
    KnowledgeBaseRenderData data, {
    required bool bottom,
    required bool showBranding,
    bool autoHide = false,
  });

  Widget sidebar(
    KnowledgeBaseRenderData data, {
    required bool showBranding,
    required bool showSearch,
    required bool showThemeToggle,
  });

  Widget mainArea(KnowledgeBaseRenderData data, Widget contentArea);

  Widget contentArea(
    KnowledgeBaseRenderData data, {
    required Widget mainContent,
    required Widget? toc,
  });

  Widget articlePanel(KnowledgeBaseRenderData data);

  Widget breadcrumbs(KnowledgeBaseRenderData data);

  Widget metadata(KnowledgeBaseRenderData data);

  Widget tableOfContents(KnowledgeBaseRenderData data);

  Widget demo(KnowledgeBaseRenderData data, Widget demoWidget);

  Widget missingDemo(KnowledgeBaseRenderData data, String componentType);
}

class DefaultKnowledgeBaseRenderers extends KnowledgeBaseRenderers {
  @override
  final String id;

  @override
  final String prefix;

  const DefaultKnowledgeBaseRenderers({
    this.id = 'default',
    this.prefix = 'default',
  });

  String get slotClass => '$prefix-kb-slot';

  String get shellClass => 'kb-page-shell $prefix-kb-page-shell';

  String get scaffoldClass => 'kb-scaffold $prefix-kb-scaffold';

  String get topBarClass => 'kb-topbar $prefix-kb-topbar';

  String get sidebarClass => 'kb-sidebar $prefix-kb-sidebar';

  String get contentAreaClass => 'kb-content-area $prefix-kb-content-area';

  String get articlePanelClass => 'kb-article-panel $prefix-kb-article-panel';

  @override
  Widget shell(KnowledgeBaseRenderData data) {
    bool topbarShowsBranding = showTopBarBranding(data);
    bool sidebarShowsBranding = !topbarShowsBranding;
    return dom.div(classes: shellClass, <Widget>[
      dom.div(classes: scaffoldClass, <Widget>[
        if (data.showNavigationBar && data.useTopPosition)
          topBar(data, bottom: false, showBranding: topbarShowsBranding),
        dom.div(classes: 'kb-layout-body $prefix-kb-layout-body', <Widget>[
          sidebar(
            data,
            showBranding: sidebarShowsBranding,
            showSearch: data.config.searchEnabled,
            showThemeToggle:
                data.showSidebarControls && data.config.themeToggleEnabled,
          ),
          mainArea(
            data,
            contentArea(
              data,
              mainContent: articlePanel(data),
              toc: data.config.tocEnabled && hasTableOfContents(data)
                  ? tableOfContents(data)
                  : null,
            ),
          ),
        ]),
        if (data.showNavigationBar && !data.useTopPosition)
          topBar(data, bottom: true, showBranding: false),
      ]),
    ]);
  }

  bool showTopBarBranding(KnowledgeBaseRenderData data) =>
      data.showNavigationBar && data.useTopPosition;

  @override
  Widget topBar(
    KnowledgeBaseRenderData data, {
    required bool bottom,
    required bool showBranding,
    bool autoHide = false,
  }) {
    String positionClass = bottom ? ' kb-topbar-bottom' : '';
    bool showStylesheetSwitcher =
        data.config.stylesheetSwitcherEnabled &&
        data.stylesheetOptions.length > 1;
    bool showPaletteSwitcher =
        data.config.paletteSwitcherEnabled && activePalettes(data).length > 1;
    return dom.div(
      classes: '$topBarClass$positionClass',
      attributes: autoHide
          ? const <String, String>{'data-kb-autohide': 'true'}
          : null,
      <Widget>[
        dom.div(classes: 'kb-topbar-inner $prefix-kb-topbar-inner', <Widget>[
          dom.div(classes: 'kb-topbar-left $prefix-kb-topbar-left', <Widget>[
            dom.button(
              classes: 'kb-hamburger $prefix-kb-hamburger',
              attributes: const <String, String>{
                'type': 'button',
                'aria-label': 'Toggle sidebar',
                'aria-expanded': 'false',
                'data-kb-sidebar-toggle': 'true',
              },
              <Widget>[ArcaneIcon.panelLeft(size: IconSize.sm)],
            ),
            if (showBranding) brandLink(data, topBar: true),
          ]),
          dom.div(classes: 'kb-topbar-right $prefix-kb-topbar-right', <Widget>[
            if (data.config.searchEnabled) searchBox(),
            if (showStylesheetSwitcher || showPaletteSwitcher)
              dom.div(
                classes: 'kb-style-switcher $prefix-kb-style-switcher',
                <Widget>[
                  if (showStylesheetSwitcher) stylesheetSelect(data),
                  if (showPaletteSwitcher) paletteSelect(data),
                ],
              ),
            if (data.config.themeToggleEnabled) themeToggle(),
            if (data.config.githubUrl != null)
              githubLink(data.config.githubUrl!),
          ]),
        ]),
      ],
    );
  }

  Widget brandLink(KnowledgeBaseRenderData data, {required bool topBar}) {
    String rootClass = topBar
        ? 'kb-topbar-brand $prefix-kb-topbar-brand'
        : 'sidebar-brand-link $prefix-kb-sidebar-brand-link';
    return dom.a(href: data.config.fullPath('/'), classes: rootClass, <Widget>[
      if (data.config.logo != null)
        dom.img(
          classes: topBar
              ? 'kb-topbar-logo $prefix-kb-topbar-logo'
              : 'sidebar-brand-logo $prefix-kb-sidebar-brand-logo',
          src: resolveLogoPath(data.config, data.config.logo!),
          alt: '',
        )
      else
        dom.span(
          classes: topBar
              ? 'kb-topbar-brand-icon $prefix-kb-topbar-brand-icon'
              : 'sidebar-brand-icon $prefix-kb-sidebar-brand-icon',
          <Widget>[
            topBar
                ? Widget.text(brandInitial(data.config.name))
                : ArcaneIcon.book(size: IconSize.sm),
          ],
        ),
      dom.span(
        classes: topBar
            ? 'kb-topbar-brand-label $prefix-kb-topbar-brand-label'
            : 'sidebar-brand-title $prefix-kb-sidebar-brand-title',
        <Widget>[Widget.text(data.config.name)],
      ),
    ]);
  }

  String brandInitial(String name) {
    List<String> tokens = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
    String source = tokens.isEmpty ? name : tokens.last;
    if (source.isEmpty) {
      return 'A';
    }
    return source.substring(0, 1).toUpperCase();
  }

  Widget githubLink(String githubUrl) => dom.a(
    href: githubUrl,
    classes: 'kb-topbar-github $prefix-kb-topbar-github',
    attributes: const <String, String>{
      'target': '_blank',
      'rel': 'noopener noreferrer',
      'aria-label': 'GitHub',
    },
    <Widget>[ArcaneIcon.github(size: IconSize.sm)],
  );

  Widget searchBox() => dom.div(
    classes: 'kb-search $prefix-kb-search',
    attributes: const <String, String>{'data-kb-search': 'true'},
    <Widget>[
      dom.div(
        classes: 'kb-search-input-wrap $prefix-kb-search-input-wrap',
        <Widget>[
          Widget.element(
            tag: 'input',
            classes: 'kb-search-input $prefix-kb-search-input',
            attributes: const <String, String>{
              'type': 'text',
              'placeholder': 'Search docs...',
              'autocomplete': 'off',
              'aria-label': 'Search documentation',
              'aria-autocomplete': 'list',
              'aria-expanded': 'false',
              'role': 'combobox',
              'data-kb-search-input': 'true',
            },
          ),
          dom.div(classes: 'kb-search-icon $prefix-kb-search-icon', <Widget>[
            ArcaneIcon.search(size: IconSize.sm),
          ]),
        ],
      ),
      dom.div(
        classes: 'search-results $prefix-kb-search-results',
        attributes: const <String, String>{
          'data-kb-search-results': 'true',
          'role': 'listbox',
          'aria-label': 'Search results',
          'hidden': '',
        },
        <Widget>[],
      ),
    ],
  );

  Widget stylesheetSelect(KnowledgeBaseRenderData data) => Widget.element(
    tag: 'select',
    classes: 'kb-stylesheet-select $prefix-kb-stylesheet-select',
    attributes: const <String, String>{
      'aria-label': 'Select stylesheet',
      'data-kb-stylesheet-select': 'true',
    },
    children: <Widget>[
      for (KBStylesheetOption option in data.stylesheetOptions)
        Widget.element(
          tag: 'option',
          attributes: <String, String>{
            'value': option.id,
            if (option.id == data.activeStylesheetId) 'selected': 'selected',
          },
          children: <Widget>[Widget.text(option.label)],
        ),
    ],
  );

  Widget paletteSelect(KnowledgeBaseRenderData data) {
    List<KBPaletteOption> palettes = activePalettes(data);
    return Widget.element(
      tag: 'select',
      classes: 'kb-palette-select $prefix-kb-palette-select',
      attributes: const <String, String>{
        'aria-label': 'Select palette',
        'data-kb-palette-select': 'true',
      },
      children: <Widget>[
        for (KBPaletteOption palette in palettes)
          Widget.element(
            tag: 'option',
            attributes: <String, String>{
              'value': palette.id,
              if (palette.id == data.activePaletteId) 'selected': 'selected',
            },
            children: <Widget>[Widget.text(palette.label)],
          ),
      ],
    );
  }

  Widget themeToggle() => dom.button(
    classes: 'kb-theme-toggle $prefix-kb-theme-toggle',
    attributes: const <String, String>{
      'type': 'button',
      'aria-label': 'Toggle theme',
      'data-kb-theme-toggle': 'true',
    },
    <Widget>[
      dom.span(
        classes: 'theme-icon-light $prefix-kb-theme-icon-light',
        <Widget>[ArcaneIcon.sun(size: IconSize.sm)],
      ),
      dom.span(classes: 'theme-icon-dark $prefix-kb-theme-icon-dark', <Widget>[
        ArcaneIcon.moon(size: IconSize.sm),
      ]),
    ],
  );

  @override
  Widget sidebar(
    KnowledgeBaseRenderData data, {
    required bool showBranding,
    required bool showSearch,
    required bool showThemeToggle,
  }) {
    bool showStylesheetSwitcher =
        data.showSidebarControls &&
        data.config.stylesheetSwitcherEnabled &&
        data.stylesheetOptions.length > 1;
    bool showPaletteSwitcher =
        data.showSidebarControls &&
        data.config.paletteSwitcherEnabled &&
        activePalettes(data).length > 1;
    bool showHeader =
        showBranding ||
        showSearch ||
        showThemeToggle ||
        showStylesheetSwitcher ||
        showPaletteSwitcher;
    bool mobileSearchOnly = showSearch && !data.showSidebarControls;
    bool mobileHeaderOnly =
        mobileSearchOnly &&
        !showBranding &&
        !showThemeToggle &&
        !showStylesheetSwitcher &&
        !showPaletteSwitcher;
    return dom.aside(
      classes:
          '$sidebarClass${mobileSearchOnly ? ' kb-sidebar-search-mobile-only' : ''}',
      styles: dom.Styles(
        raw: <String, String>{
          '--kb-sidebar-width': data.config.sidebarWidth,
          '--kb-sidebar-rail-top': data.sidebarTopOffset,
        },
      ),
      <Widget>[
        dom.div(classes: 'kb-sidebar-panel $prefix-kb-sidebar-panel', <Widget>[
          if (showHeader)
            sidebarHeader(
              data,
              showBranding: showBranding,
              showSearch: showSearch,
              showThemeToggle: showThemeToggle,
              showStylesheetSwitcher: showStylesheetSwitcher,
              showPaletteSwitcher: showPaletteSwitcher,
              mobileOnly: mobileHeaderOnly,
            ),
          if (showHeader)
            dom.div(
              classes:
                  'kb-section-divider${mobileHeaderOnly ? ' kb-sidebar-divider-mobile-only' : ''}',
              <Widget>[],
            ),
          if (!data.showSidebarControls &&
              ((data.config.stylesheetSwitcherEnabled &&
                      data.stylesheetOptions.length > 1) ||
                  (data.config.paletteSwitcherEnabled &&
                      activePalettes(data).length > 1)))
            dom.div(classes: 'kb-mobile-style-controls', <Widget>[
              dom.div(classes: 'kb-style-switcher', <Widget>[
                if (data.config.stylesheetSwitcherEnabled &&
                    data.stylesheetOptions.length > 1)
                  stylesheetSelect(data),
                if (data.config.paletteSwitcherEnabled &&
                    activePalettes(data).length > 1)
                  paletteSelect(data),
              ]),
            ]),
          dom.nav(classes: 'sidebar-nav $prefix-kb-sidebar-nav', <Widget>[
            if (data.manifest.visibleItems.isNotEmpty)
              fixedSection(
                data,
                'Pages',
                KBIcon.build('file-text', classes: 'sidebar-icon'),
                <Widget>[
                  for (NavItem item in data.manifest.visibleItems)
                    navItem(data, item),
                ],
              ),
            for (NavSection section in data.manifest.visibleSections)
              collapsibleSection(data, section, depth: 0),
          ]),
        ]),
      ],
    );
  }

  Widget sidebarHeader(
    KnowledgeBaseRenderData data, {
    required bool showBranding,
    required bool showSearch,
    required bool showThemeToggle,
    required bool showStylesheetSwitcher,
    required bool showPaletteSwitcher,
    bool mobileOnly = false,
  }) {
    bool hasControls =
        showSearch ||
        showThemeToggle ||
        showStylesheetSwitcher ||
        showPaletteSwitcher;
    return dom.div(
      classes:
          'sidebar-header $prefix-kb-sidebar-header${mobileOnly ? ' kb-sidebar-header-mobile-only' : ''}',
      <Widget>[
        if (showBranding)
          dom.div(classes: 'sidebar-brand $prefix-kb-sidebar-brand', <Widget>[
            brandLink(data, topBar: false),
            if (data.config.description != null)
              dom.div(
                classes:
                    'sidebar-brand-subtitle $prefix-kb-sidebar-brand-subtitle',
                <Widget>[Widget.text(data.config.description!)],
              ),
          ]),
        if (hasControls)
          dom.div(
            classes: 'sidebar-controls $prefix-kb-sidebar-controls',
            <Widget>[
              if (showSearch) searchBox(),
              if (showStylesheetSwitcher || showPaletteSwitcher)
                dom.div(
                  classes: 'kb-style-switcher $prefix-kb-style-switcher',
                  <Widget>[
                    if (showStylesheetSwitcher) stylesheetSelect(data),
                    if (showPaletteSwitcher) paletteSelect(data),
                  ],
                ),
              if (showThemeToggle) themeToggle(),
            ],
          ),
      ],
    );
  }

  Widget fixedSection(
    KnowledgeBaseRenderData data,
    String title,
    Widget icon,
    List<Widget> items,
  ) => dom.div(classes: 'sidebar-section $prefix-kb-sidebar-section', <Widget>[
    dom.div(
      classes: 'sidebar-section-header $prefix-kb-sidebar-section-header',
      <Widget>[
        icon,
        dom.span(<Widget>[Widget.text(title)]),
      ],
    ),
    dom.div(classes: 'sidebar-tree $prefix-kb-sidebar-tree', <Widget>[
      for (Widget item in items) item,
    ]),
  ]);

  Widget collapsibleSection(
    KnowledgeBaseRenderData data,
    NavSection section, {
    required int depth,
  }) {
    bool shouldExpand =
        section.shouldExpandFor(data.currentPath) || !section.collapsed;
    return dom.div(
      classes: 'sidebar-section $prefix-kb-sidebar-section',
      <Widget>[
        Widget.element(
          tag: 'details',
          classes: 'sidebar-details $prefix-kb-sidebar-details',
          attributes: shouldExpand ? <String, String>{'open': ''} : {},
          children: <Widget>[
            Widget.element(
              tag: 'summary',
              classes: 'sidebar-summary $prefix-kb-sidebar-summary',
              styles: treeRowStyles(data, depth, isFolder: true),
              children: <Widget>[
                dom.span(<Widget>[Widget.text(section.title)]),
                dom.span(
                  classes: 'sidebar-chevron $prefix-kb-sidebar-chevron',
                  <Widget>[
                    KBIcon.build(
                      'chevron-down',
                      classes: 'sidebar-chevron-icon',
                    ),
                  ],
                ),
              ],
            ),
            dom.div(classes: 'sidebar-tree $prefix-kb-sidebar-tree', <Widget>[
              for (NavItem item in section.visibleItems)
                navItem(data, item, depth: depth + 1),
              for (NavSection nested in section.visibleSections)
                collapsibleSection(data, nested, depth: depth + 1),
            ]),
          ],
        ),
      ],
    );
  }

  Widget navItem(KnowledgeBaseRenderData data, NavItem item, {int depth = 0}) {
    String fullHref = data.config.fullPath(item.path);
    bool active = isSidebarActive(data, item.path);
    return dom.div(
      classes: 'sidebar-tree-item $prefix-kb-sidebar-tree-item',
      <Widget>[
        dom.a(
          href: fullHref,
          classes:
              'sidebar-link $prefix-kb-sidebar-link${active ? ' active' : ''}',
          styles: treeRowStyles(data, depth, isFolder: false),
          <Widget>[
            if (item.icon != null) icon(data, item.icon!),
            dom.span(classes: 'sidebar-link-label', <Widget>[
              Widget.text(item.title),
            ]),
          ],
        ),
      ],
    );
  }

  dom.Styles treeRowStyles(
    KnowledgeBaseRenderData data,
    int depth, {
    required bool isFolder,
  }) {
    Map<String, String> rawStyles = <String, String>{
      'padding-left': data.config.sidebarTreeIndent,
      '--kb-tree-depth': depth.toString(),
    };
    if (isFolder && depth > 0) {
      rawStyles['margin-left'] = '0.75rem';
    }
    return dom.Styles(raw: rawStyles);
  }

  /// Build one navigation icon from a Lucide icon name.
  Widget icon(KnowledgeBaseRenderData data, String iconName) =>
      KBIcon.build(iconName, classes: 'sidebar-icon $prefix-kb-sidebar-icon');

  @override
  Widget mainArea(KnowledgeBaseRenderData data, Widget contentArea) =>
      dom.main_(classes: 'kb-main-area $prefix-kb-main-area', <Widget>[
        contentArea,
      ]);

  @override
  Widget contentArea(
    KnowledgeBaseRenderData data, {
    required Widget mainContent,
    required Widget? toc,
  }) {
    String landingClass = data.landing ? ' kb-landing-content-area' : '';
    return dom.div(classes: '$contentAreaClass$landingClass', <Widget>[
      mainContent,
      ?toc,
    ]);
  }

  @override
  Widget articlePanel(KnowledgeBaseRenderData data) {
    bool hasMetadata =
        data.tags.isNotEmpty ||
        data.readingTime != null ||
        data.author != null ||
        data.date != null ||
        data.lastModified != null;
    String landingClass = data.landing ? ' kb-landing-page' : '';
    return Widget.element(
      tag: 'article',
      classes: '$articlePanelClass$landingClass',
      children: <Widget>[
        if (!data.landing) breadcrumbs(data),
        if (!data.landing && data.title != null) title(data),
        if (!data.landing && data.description != null) description(data),
        if (!data.landing && hasMetadata) metadata(data),
        if (data.demoWidget != null) demo(data, data.demoWidget!),
        dom.div(
          classes: data.landing ? 'prose kb-landing-prose' : 'prose',
          <Widget>[data.content],
        ),
        if (!data.landing && data.tags.isNotEmpty) tagsFooter(data),
        if (!data.landing && data.config.ratingEnabled) rating(data),
        if (!data.landing && data.showPageNav)
          KBPageNav(
            config: data.config,
            manifest: data.manifest,
            currentPath: data.currentPath,
          ),
      ],
    );
  }

  Widget title(KnowledgeBaseRenderData data) => dom.div(
    classes: 'kb-page-title $prefix-kb-page-title',
    <Widget>[Widget.text(data.title!)],
  );

  Widget description(KnowledgeBaseRenderData data) => dom.div(
    classes: 'kb-page-description $prefix-kb-page-description',
    <Widget>[Widget.text(data.description!)],
  );

  @override
  Widget metadata(KnowledgeBaseRenderData data) =>
      dom.div(classes: 'kb-page-metadata $prefix-kb-page-metadata', <Widget>[
        if (data.readingTime != null)
          metadataItem(
            ArcaneIcon.clock(size: IconSize.sm),
            '${data.readingTime} min read',
          ),
        if (data.author != null)
          metadataItem(ArcaneIcon.user(size: IconSize.sm), data.author!),
        if (data.date != null)
          metadataItem(ArcaneIcon.calendar(size: IconSize.sm), data.date!),
        if (data.lastModified != null)
          metadataItem(
            ArcaneIcon.edit(size: IconSize.sm),
            'Updated ${formatLastModified(data.lastModified!)}',
          ),
        if (data.tags.isNotEmpty)
          KBTagList(tags: data.tags, size: KBTagSize.xs),
      ]);

  Widget metadataItem(Widget icon, String text) => dom.div(
    classes: 'kb-page-metadata-item $prefix-kb-page-metadata-item',
    <Widget>[icon, Widget.text(text)],
  );

  Widget tagsFooter(KnowledgeBaseRenderData data) =>
      dom.div(classes: 'kb-tags-footer $prefix-kb-tags-footer', <Widget>[
        dom.div(
          classes: 'kb-tags-footer-label $prefix-kb-tags-footer-label',
          <Widget>[const Text('Tags')],
        ),
        KBTagList(tags: data.tags, size: KBTagSize.md),
      ]);

  Widget rating(KnowledgeBaseRenderData data) => KBRating(
    pagePath: data.currentPath,
    config: RatingConfig(
      enabled: true,
      promptText: data.config.ratingPromptText,
      thankYouText: data.config.ratingThankYouText,
    ),
  );

  @override
  Widget breadcrumbs(KnowledgeBaseRenderData data) {
    List<String> segments = data.currentPath
        .split('/')
        .where((String segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty) {
      return const dom.div(<Widget>[]);
    }

    List<BreadcrumbItem> items = <BreadcrumbItem>[
      BreadcrumbItem(label: 'Home', href: data.config.fullPath('/')),
    ];
    String currentHref = '';
    for (int i = 0; i < segments.length; i++) {
      currentHref += '/${segments[i]}';
      bool isLast = i == segments.length - 1;
      items.add(
        BreadcrumbItem(
          label: formatSegment(segments[i]),
          href: isLast ? null : data.config.fullPath(currentHref),
        ),
      );
    }

    return dom.div(classes: 'kb-breadcrumbs $prefix-kb-breadcrumbs', <Widget>[
      ArcaneBreadcrumbs(
        items: items,
        separator: BreadcrumbSeparator.chevron,
        size: BreadcrumbSize.sm,
      ),
    ]);
  }

  @override
  Widget tableOfContents(KnowledgeBaseRenderData data) => dom.aside(
    classes: 'kb-toc-panel $prefix-kb-toc-panel',
    <Widget>[ArcaneToc.custom(content: data.toc!.build())],
  );

  bool hasTableOfContents(KnowledgeBaseRenderData data) {
    TableOfContents? toc = data.toc;
    if (toc == null) {
      return false;
    }
    return toc.entries.isNotEmpty;
  }

  @override
  Widget demo(KnowledgeBaseRenderData data, Widget demoWidget) => dom.div(
    classes: 'kb-demo-shell $prefix-kb-demo-shell',
    <Widget>[demoWidget],
  );

  @override
  Widget missingDemo(KnowledgeBaseRenderData data, String componentType) =>
      dom.div(
        classes: 'kb-missing-demo $prefix-kb-missing-demo',
        attributes: const <String, String>{'role': 'status'},
        <Widget>[
          dom.div(
            classes: 'kb-missing-demo-icon $prefix-kb-missing-demo-icon',
            <Widget>[const Text('!')],
          ),
          dom.div(
            classes: 'kb-missing-demo-copy $prefix-kb-missing-demo-copy',
            <Widget>[
              dom.div(
                classes: 'kb-missing-demo-title $prefix-kb-missing-demo-title',
                <Widget>[const Text('No Demo Found')],
              ),
              dom.div(
                classes: 'kb-missing-demo-body $prefix-kb-missing-demo-body',
                <Widget>[
                  Text('No live preview is registered for "$componentType".'),
                ],
              ),
            ],
          ),
        ],
      );

  List<KBPaletteOption> activePalettes(KnowledgeBaseRenderData data) {
    for (KBStylesheetOption option in data.stylesheetOptions) {
      if (option.id == data.activeStylesheetId) {
        return option.palettes;
      }
    }
    return const <KBPaletteOption>[];
  }

  bool isSidebarActive(KnowledgeBaseRenderData data, String path) =>
      data.currentPath == path || data.currentPath == '$path/';

  String resolveLogoPath(SiteConfig config, String value) {
    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('//')) {
      return value;
    }
    if (value.startsWith('/')) {
      return config.fullPath(value);
    }
    if (config.assetPrefix.isEmpty) {
      return value;
    }
    return '${config.assetPrefix}/$value';
  }

  String formatSegment(String segment) => segment
      .split('-')
      .map(
        (String word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
      )
      .join(' ');

  String formatLastModified(String isoDate) {
    try {
      DateTime dt = DateTime.parse(isoDate);
      List<String> months = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
