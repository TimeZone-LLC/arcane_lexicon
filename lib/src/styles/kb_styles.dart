/// Default CSS styles for knowledge base components.
///
/// These styles provide STRUCTURAL defaults only (layout, positioning).
/// Visual styling (colors, fonts, effects) comes from the stylesheet's
/// componentCss (arcaneSidebarTreeStyles for ShadCN, arcaneSidebarNeonStyles for Neon).
class KBStyles {
  const KBStyles._();

  /// Generate the complete default CSS for knowledge base components.
  static String generate() =>
      '''
$_chromeStyles
$_sidebarSections
$_sidebarDetailsMarkers
$_sidebarChevron
$_sidebarTree
$_sidebarTreeConnectors
$_sidebarLinks
$_tocSpacingStyles
$_proseLinkIndicatorStyles
$_mediaStyles
$_calloutStyles
$_markdownAlerts
$_pageNavStyles
$_cardStyles
$_columnsStyles
$_tileStyles
$_stepStyles
$_accordionStyles
$_badgeStyles
$_bannerStyles
$_panelStyles
$_frameStyles
$_updateStyles
$_tooltipStyles
$_inlineIconStyles
$_tagStyles
$_ratingStyles
$_docUtilityStyles
$_codeGroupStyles
$_fieldStyles
$_treeStyles
$_colorStyles
$_viewStyles
$_landingStyles
$_contentThemeBridge
$_lightThemeReadability
$_nestedSurfaceStyles
''';

  static const String _chromeStyles = '''
.kb-page-shell {
  min-height: 100vh;
}

.kb-style-slot[hidden] {
  display: none !important;
}

.kb-style-slot {
  min-height: 100vh;
}

.kb-section-divider {
  width: 100%;
  height: 1px;
  margin: 0;
  border: 0;
  background: var(--border);
}

.kb-scaffold {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--background);
  color: var(--foreground);
}

.kb-layout-body {
  display: flex;
  flex: 1;
  min-height: 0;
  align-items: flex-start;
}

.kb-main-area {
  min-width: 0;
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
}

.kb-content-area {
  width: 100%;
  display: flex;
  gap: 2rem;
  padding: 2rem;
  max-width: var(--container-2xl, 1440px);
  margin-left: auto;
  margin-right: auto;
  flex: 1 1 auto;
  min-width: 0;
}

.kb-article-panel {
  flex: 1 1 auto;
  min-width: 0;
}

.kb-page-title {
  margin: 0 0 1.5rem;
  color: var(--foreground);
  font-size: 1.875rem;
  font-weight: 700;
  line-height: 1.15;
}

.kb-page-description {
  margin: 0 0 2rem;
  color: var(--muted-foreground);
  font-size: 1.125rem;
  line-height: 1.6;
}

.kb-breadcrumbs {
  margin-bottom: 1rem;
}

.kb-page-metadata {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
}

.kb-page-metadata-item {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  color: var(--muted-foreground);
  font-size: 0.875rem;
}

.kb-tags-footer {
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border);
}

.kb-tags-footer-label {
  margin-bottom: 0.5rem;
  color: var(--muted-foreground);
  font-size: 0.875rem;
  font-weight: 600;
}

.kb-toc-panel {
  width: 220px;
  flex: 0 0 220px;
  position: sticky;
  top: 80px;
  align-self: flex-start;
  max-height: calc(100vh - 100px);
  overflow-y: auto;
}

.kb-topbar {
  position: sticky;
  top: 0;
  z-index: 50;
  width: 100%;
  border-bottom: 1px solid var(--border);
  background: var(--background);
  box-shadow: none;
  backdrop-filter: none;
  -webkit-backdrop-filter: none;
}

.kb-topbar.kb-topbar-bottom {
  top: auto;
  bottom: 0;
  border-top: 1px solid var(--border);
  border-bottom: none;
}

.kb-topbar[data-kb-autohide="true"] {
  transition: transform 0.25s ease;
  will-change: transform;
}

.kb-topbar[data-kb-autohide="true"].kb-topbar--hidden {
  transform: translateY(-100%);
}

.kb-topbar-inner {
  width: 100%;
  max-width: none;
  margin: 0;
  min-height: 3.5rem;
  padding: 0 1rem;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.75rem;
}

.kb-topbar-left {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
  flex: 1 1 auto;
  justify-content: flex-start;
}

.kb-topbar-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-left: auto;
  justify-content: flex-end;
  flex: 0 0 auto;
}

.kb-topbar-brand {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: var(--foreground);
  font-weight: 600;
  font-size: 0.9375rem;
  line-height: 1;
  white-space: nowrap;
}

.kb-topbar-brand:hover {
  opacity: 0.88;
}

.kb-topbar-logo {
  width: 1.125rem;
  height: 1.125rem;
  object-fit: contain;
  border-radius: var(--radius-sm, 0.25rem);
}

.kb-topbar-nav {
  display: flex;
  align-items: center;
  gap: 0.125rem;
  margin-left: 0.375rem;
}

.kb-topbar-link {
  height: 2rem;
  padding: 0 0.625rem;
  border-radius: var(--radius-sm, 0.25rem);
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  text-decoration: none;
  color: var(--muted-foreground);
  font-size: 0.875rem;
  line-height: 1;
  transition: background 0.15s ease, color 0.15s ease;
}

.kb-topbar-link:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.kb-topbar-link.active {
  background: var(--muted);
  color: var(--foreground);
}

.kb-topbar-github,
.kb-theme-toggle,
.kb-stylesheet-select,
.kb-palette-select {
  width: 2.25rem;
  height: 2.25rem;
  border-radius: var(--radius-md, 0.375rem);
  border: 1px solid var(--border);
  background: var(--background);
  color: var(--muted-foreground);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  cursor: pointer;
  transition: background 0.15s ease, color 0.15s ease, border-color 0.15s ease;
}

.kb-stylesheet-select,
.kb-palette-select {
  width: auto;
  min-width: 7rem;
  padding: 0 2rem 0 0.75rem;
  font: inherit;
  font-size: 0.8125rem;
  font-weight: 500;
}

.kb-palette-select {
  min-width: 6rem;
}

.kb-style-switcher {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  flex-wrap: wrap;
}

.kb-topbar-github:hover,
.kb-theme-toggle:hover,
.kb-stylesheet-select:hover,
.kb-palette-select:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.theme-icon-dark {
  display: none;
}

.dark .theme-icon-light,
html.dark .theme-icon-light {
  display: none;
}

.dark .theme-icon-dark,
html.dark .theme-icon-dark {
  display: block;
}

.kb-search {
  position: relative;
  width: min(25rem, 42vw);
}

.kb-search-input-wrap {
  position: relative;
}

.kb-search-input {
  width: 100%;
  height: 2.25rem;
  border-radius: var(--radius-md, 0.375rem);
  border: 1px solid var(--border);
  background: var(--background);
  color: var(--foreground);
  padding: 0 0.75rem 0 2rem;
  font-size: 0.875rem;
  outline: 2px solid transparent;
  outline-offset: 1px;
  transition: border-color 0.15s ease, outline-color 0.15s ease;
}

.kb-search-input::placeholder {
  color: var(--muted-foreground);
}

.kb-search-input:focus {
  border-color: var(--ring);
  outline-color: var(--ring);
}

.kb-search-icon {
  position: absolute;
  left: 0.625rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--muted-foreground);
  pointer-events: none;
  display: flex;
  align-items: center;
}

.search-results {
  display: none;
  position: absolute;
  top: calc(100% + 0.25rem);
  left: 0;
  right: 0;
  background: var(--popover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md, 0.375rem);
  max-height: 22rem;
  overflow-y: auto;
  z-index: 70;
}

.search-results[hidden] {
  display: none !important;
}

.kb-search-result {
  display: block;
  padding: 0.625rem 0.75rem;
  border-bottom: 1px solid var(--border);
  color: inherit;
  text-decoration: none;
  transition: background 0.15s ease;
}

.kb-search-result:last-child {
  border-bottom: 0;
}

.kb-search-result-title {
  color: var(--foreground);
  font-weight: 500;
}

.kb-search-result-category {
  color: var(--muted-foreground);
  font-size: 0.75rem;
}

.kb-search-empty {
  padding: 0.75rem;
  color: var(--muted-foreground);
  text-align: center;
}

.search-results a:hover,
.kb-search-result.is-selected {
  background: var(--accent) !important;
}

.kb-hamburger {
  display: none !important;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: var(--radius-md, 0.375rem);
  border: 1px solid var(--border);
  background: var(--background);
  color: var(--muted-foreground);
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.15s ease, color 0.15s ease;
}

.kb-hamburger:hover {
  background: var(--accent);
  color: var(--accent-foreground);
}

.kb-hamburger:focus-visible,
.kb-theme-toggle:focus-visible,
.kb-topbar-github:focus-visible,
.kb-stylesheet-select:focus-visible,
.kb-palette-select:focus-visible,
.kb-search-result:focus-visible,
.sidebar-summary:focus-visible,
.sidebar-link:focus-visible,
.kb-rating-btn:focus-visible,
.copy-code-btn:focus-visible {
  outline: 2px solid var(--ring);
  outline-offset: 2px;
}

.kb-sidebar {
  --kb-sidebar-stick-top: calc(3.5rem + var(--kb-sidebar-rail-top, 0px));
  position: sticky;
  top: var(--kb-sidebar-stick-top);
  z-index: 30;
  flex-shrink: 0;
  width: min(100%, var(--kb-sidebar-width, 17.5rem));
  height: max-content;
  max-height: none;
  min-height: 0;
  align-self: start;
  display: block;
  overflow: visible;
}

.kb-sidebar-panel {
  width: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.sidebar-header {
  position: static;
  z-index: 2;
  padding: 0.875rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  background: var(--card);
}

#arcane-root .kb-style-slot .sidebar-header {
  margin: 0;
  border: 0;
  border-radius: 0;
  background: transparent;
  box-shadow: none;
}

#arcane-root .kb-style-slot .search-results {
  border-radius: var(--radius-md, 0.375rem);
  background-image: none !important;
  box-shadow: none !important;
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
}

.sidebar-brand-title {
  color: var(--foreground);
  font-size: 0.925rem;
  font-weight: 600;
  line-height: 1.25;
}

.sidebar-brand-subtitle {
  color: var(--muted-foreground);
  font-size: 0.78rem;
  margin-top: 0.25rem;
}

.sidebar-controls {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.sidebar-nav {
  padding: 0.75rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-search {
  width: 100%;
  min-width: 0;
}

.kb-sidebar-search-mobile-only .kb-search {
  display: none;
}

.kb-sidebar-header-mobile-only {
  display: none;
}

.kb-sidebar-divider-mobile-only {
  display: none;
}

@media (max-width: 1280px) {
  .kb-search {
    width: min(20rem, 35vw);
  }
}

@media (max-width: 1024px) {
  .kb-topbar-nav {
    display: none;
  }

  .kb-search {
    width: min(18rem, 52vw);
  }
}

@media (max-width: 900px) {
  .kb-hamburger {
    display: inline-flex !important;
  }

  .kb-topbar .kb-search {
    display: none;
  }

  .kb-sidebar-search-mobile-only .kb-search {
    display: block;
  }

  .kb-sidebar-header-mobile-only {
    display: flex;
  }

  .kb-sidebar-divider-mobile-only {
    display: block;
  }

  .kb-sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    height: 100vh;
    height: 100dvh;
    width: min(22rem, 92vw);
    max-width: 92vw;
    transform: translateX(-100%);
    transition: transform 0.2s ease;
    background: var(--card);
    overflow-y: auto;
  }

  .kb-sidebar.open {
    transform: translateX(0);
  }
}
''';

  /// Sidebar section and summary STRUCTURAL styles only
  static const String _sidebarSections = '''
/* ============================================
   SIDEBAR SECTIONS & SUMMARIES - Structure Only
   Visual styling provided by stylesheet componentCss
   ============================================ */
.sidebar-section {
  margin-bottom: 0.5rem;
}

.sidebar-section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.5rem;
}

.sidebar-details {
  width: 100%;
}

.sidebar-summary {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  padding: 0.625rem 0.75rem;
  cursor: pointer;
  list-style: none !important;
}
''';

  /// Aggressively hide browser default disclosure markers
  static const String _sidebarDetailsMarkers = '''
/* ============================================
   HIDE DEFAULT DISCLOSURE MARKERS
   ============================================ */
.sidebar-summary::-webkit-details-marker,
.sidebar-summary::marker,
.sidebar-details > summary::-webkit-details-marker,
.sidebar-details > summary::marker {
  display: none !important;
  content: '' !important;
  list-style: none !important;
}

details.sidebar-details {
  list-style: none !important;
}

details.sidebar-details > summary {
  list-style: none !important;
}

details > summary {
  list-style: none !important;
}

details > summary::marker,
details > summary::-webkit-details-marker {
  display: none !important;
}
''';

  /// Chevron indicator STRUCTURAL styling
  static const String _sidebarChevron = '''
/* ============================================
   CHEVRON INDICATOR - Structure Only
   ============================================ */
.sidebar-chevron {
  margin-left: auto;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.2s ease, opacity 0.2s ease;
  transform: rotate(-90deg);
}

/* Hide CSS-based chevron from arcaneSidebarTreeStyles - we use an actual icon */
.sidebar-chevron::before {
  display: none !important;
}

.sidebar-details[open] > .sidebar-summary .sidebar-chevron {
  transform: rotate(0deg);
}
''';

  /// Sidebar tree STRUCTURAL layout
  static const String _sidebarTree = '''
/* ============================================
   SIDEBAR TREE STRUCTURE - Layout Only
   ============================================ */
.sidebar-tree {
  padding-left: 1rem;
  display: flex;
  flex-direction: column;
  position: relative;
  margin-left: 0.5rem;
}

.sidebar-tree .sidebar-tree {
  margin-left: 0;
  padding-left: 0.75rem;
}

.sidebar-tree .sidebar-section {
  margin-bottom: 0;
  margin-top: 3px;
}

.sidebar-tree .sidebar-section:first-child {
  margin-top: 0;
}

/* Extend tree-item vertical lines to bridge the 3px gap before sections */
.sidebar-tree > .sidebar-tree-item:not(:last-child)::after {
  bottom: -3px;
}

.sidebar-tree .sidebar-details {
  margin-left: 0;
}

.sidebar-tree .sidebar-summary {
  padding: 0.375rem 0.5rem;
}
''';

  /// Tree connector lines STRUCTURAL positioning
  /// Note: .sidebar-tree-item connectors are handled by the stylesheet's
  /// arcaneSidebarTreeStyles. This only handles .sidebar-section (folders).
  static const String _sidebarTreeConnectors = '''
/* ============================================
   TREE CONNECTOR LINES (folders only) - Structure
   Colors provided by stylesheet componentCss
   ============================================ */
.sidebar-tree > .sidebar-section {
  position: relative;
}

/* Vertical line from this section to next */
.sidebar-tree > .sidebar-section::after {
  content: '';
  position: absolute;
  left: -0.75rem;
  top: 0;
  bottom: 0;
  width: 1px;
  pointer-events: none;
}

/* Last section: vertical line only goes to summary level (L-shape) */
.sidebar-tree > .sidebar-section:last-child::after {
  bottom: auto;
  height: 0.875rem;
}

/* Horizontal connector line at summary level */
.sidebar-tree > .sidebar-section::before {
  content: '';
  position: absolute;
  left: -0.75rem;
  top: 0.875rem;
  width: 0.5rem;
  height: 1px;
  pointer-events: none;
}

/* Single section: no vertical line needed */
.sidebar-tree > .sidebar-section:first-child:last-child::after {
  display: none;
}

/* Extend lines to bridge margin gaps */
.sidebar-tree > .sidebar-section:not(:last-child)::after {
  bottom: -3px;
}
''';

  /// Sidebar link STRUCTURAL styling
  static const String _sidebarLinks = '''
/* ============================================
   SIDEBAR LINKS - Structure Only
   Visual styling provided by stylesheet componentCss
   ============================================ */
.sidebar-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.375rem 0.5rem;
  text-decoration: none;
}

.sidebar-icon,
.sidebar-chevron-icon {
  display: inline-block;
  width: 1rem;
  height: 1rem;
  flex: 0 0 1rem;
  color: currentColor;
}

.sidebar-icon-svg {
  width: 1rem;
  height: 1rem;
  flex: 0 0 1rem;
}
''';

  static const String _tocSpacingStyles = '''
.toc-content a {
  margin-left: 0.125rem;
  padding: 0.5rem 0.75rem 0.5rem 0.625rem !important;
  font-size: 0.8125rem;
  line-height: 1.3;
}

.toc-content ul ul a {
  padding: 0.5rem 0.75rem 0.5rem 0.625rem !important;
  font-size: 0.8125rem;
  line-height: 1.3;
}

''';

  static const String _proseLinkIndicatorStyles = '''
.prose p a[href]:not([href^="#"])::after,
.prose li a[href]:not([href^="#"])::after,
.prose blockquote a[href]:not([href^="#"])::after,
.prose td a[href]:not([href^="#"])::after,
.prose th a[href]:not([href^="#"])::after {
  display: inline-block;
  margin-left: 0.18em;
  font-size: 0.62em;
  line-height: 1;
  vertical-align: super;
  opacity: 0.8;
}

.prose p a[href^="http://"]::after,
.prose p a[href^="https://"]::after,
.prose p a[href^="//"]::after,
.prose p a[href^="mailto:"]::after,
.prose li a[href^="http://"]::after,
.prose li a[href^="https://"]::after,
.prose li a[href^="//"]::after,
.prose li a[href^="mailto:"]::after,
.prose blockquote a[href^="http://"]::after,
.prose blockquote a[href^="https://"]::after,
.prose blockquote a[href^="//"]::after,
.prose blockquote a[href^="mailto:"]::after,
.prose td a[href^="http://"]::after,
.prose td a[href^="https://"]::after,
.prose td a[href^="//"]::after,
.prose td a[href^="mailto:"]::after,
.prose th a[href^="http://"]::after,
.prose th a[href^="https://"]::after,
.prose th a[href^="//"]::after,
.prose th a[href^="mailto:"]::after {
  content: '↗';
}

.prose p a[href^="/"]::after,
.prose p a[href^="./"]::after,
.prose p a[href^="../"]::after,
.prose li a[href^="/"]::after,
.prose li a[href^="./"]::after,
.prose li a[href^="../"]::after,
.prose blockquote a[href^="/"]::after,
.prose blockquote a[href^="./"]::after,
.prose blockquote a[href^="../"]::after,
.prose td a[href^="/"]::after,
.prose td a[href^="./"]::after,
.prose td a[href^="../"]::after,
.prose th a[href^="/"]::after,
.prose th a[href^="./"]::after,
.prose th a[href^="../"]::after {
  content: '↪';
}
''';

  /// Media embed styles (video, images, iframes)
  static const String _mediaStyles = '''
/* ============================================
   MEDIA EMBEDS - Responsive containers
   ============================================ */

/* Base media container */
.kb-media {
  margin: 1.5rem 0;
  width: 100%;
}

/* Video containers (YouTube, Vimeo, Loom, local) */
.kb-media-video {
  position: relative;
  padding-bottom: 56.25%; /* 16:9 aspect ratio */
  height: 0;
  overflow: hidden;
  border-radius: var(--radius-md, 0.5rem);
  background: var(--muted, #1a1a1a);
}

.kb-media-video iframe,
.kb-media-video video {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: none;
  border-radius: var(--radius-md, 0.5rem);
}

/* Local video figure */
figure.kb-media-video {
  padding-bottom: 0;
  height: auto;
}

figure.kb-media-video video {
  position: relative;
  max-width: 100%;
  height: auto;
}

/* Image containers */
.kb-media-image,
.kb-media-gif,
.kb-media-apng {
  text-align: center;
}

.kb-media-image img,
.kb-media-gif img,
.kb-media-apng img {
  max-width: 100%;
  height: auto;
  border-radius: var(--radius-md, 0.5rem);
  background: var(--muted, #1a1a1a);
}

/* Caption styling */
.kb-media-caption {
  margin-top: 0.75rem;
  font-size: 0.875rem;
  color: var(--muted-foreground, #888);
  text-align: center;
  font-style: italic;
}

/* Twitter/X embed */
.kb-media-twitter {
  display: flex;
  justify-content: center;
}

.kb-media-twitter blockquote {
  margin: 0 !important;
}

/* Generic iframe container */
.kb-media-iframe {
  border-radius: var(--radius-md, 0.5rem);
  overflow: hidden;
  background: var(--muted, #1a1a1a);
}

.kb-media-iframe iframe {
  display: block;
  border: none;
}

/* GIF/APNG indicator badge */
.kb-media-gif::before,
.kb-media-apng::before {
  content: attr(data-type);
  position: absolute;
  top: 0.5rem;
  left: 0.5rem;
  padding: 0.125rem 0.5rem;
  font-size: 0.625rem;
  font-weight: 600;
  text-transform: uppercase;
  background: rgba(0, 0, 0, 0.6);
  color: white;
  border-radius: var(--radius-sm, 0.25rem);
  pointer-events: none;
}

.kb-media-gif,
.kb-media-apng {
  position: relative;
  display: inline-block;
}

/* Dark mode adjustments */
.dark .kb-media-video {
  background: #111111;
}

.dark .kb-media-image img,
.dark .kb-media-gif img,
.dark .kb-media-apng img {
  background: #111111;
}
''';

  static const String _calloutStyles = '''
.kb-callout {
  --kb-callout-accent: var(--info, #3b82f6);
  margin: 1.25rem 0;
  padding: 0.9rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.kb-callout-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 700;
  font-size: 0.875rem;
  line-height: 1.25;
  margin: 0;
  color: var(--foreground);
  letter-spacing: 0.01em;
}

.kb-callout-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.25rem;
  height: 1.25rem;
  color: var(--kb-callout-accent);
  flex-shrink: 0;
}

.kb-callout-icon svg,
.kb-callout-icon-svg {
  width: 16px;
  height: 16px;
}

.kb-callout-icon i {
  width: 16px !important;
  height: 16px !important;
  font-size: 16px !important;
}

.kb-callout-content {
  font-size: 0.875rem;
  line-height: 1.625;
  color: var(--muted-foreground);
  margin: 0;
  padding-top: 0.65rem;
}

.kb-callout-content > :first-child {
  margin-top: 0;
}

.kb-callout-content > :last-child {
  margin-bottom: 0;
}

.kb-callout-content br {
  display: block;
  content: '';
  margin-top: 0.5rem;
}

.kb-callout-note {
  --kb-callout-accent: var(--info, #3b82f6);
}

.kb-callout-tip {
  --kb-callout-accent: var(--success, #22c55e);
}

.kb-callout-important {
  --kb-callout-accent: var(--primary, #8b5cf6);
}

.kb-callout-warning {
  --kb-callout-accent: var(--warning, #f59e0b);
}

.kb-callout-caution {
  --kb-callout-accent: var(--destructive, #ef4444);
}

.markdown-alert {
  --kb-alert-accent: var(--info, #3b82f6);
  margin: 1rem 0;
  padding: 0.7rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  color: var(--foreground);
}

.markdown-alert-title {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  margin: 0 0 0.45rem;
  padding: 0;
  color: var(--kb-alert-accent);
  font-size: 0.875rem;
  font-weight: 700;
  line-height: 1.25;
  text-transform: uppercase;
}

.markdown-alert p {
  margin: 0;
  color: var(--muted-foreground);
  font-size: 0.875rem;
  line-height: 1.55;
}

.markdown-alert p + p {
  margin-top: 0.5rem;
}

.markdown-alert-note {
  --kb-alert-accent: var(--info, #3b82f6);
}

.markdown-alert-tip {
  --kb-alert-accent: var(--success, #22c55e);
}

.markdown-alert-important {
  --kb-alert-accent: var(--primary, #8b5cf6);
}

.markdown-alert-warning {
  --kb-alert-accent: var(--warning, #f59e0b);
}

.markdown-alert-caution {
  --kb-alert-accent: var(--destructive, #ef4444);
}

''';

  static const String _markdownAlerts = '''
.markdown-alert > :last-child {
  margin-bottom: 0;
}
''';

  static const String _pageNavStyles = '''
.kb-page-nav {
  margin-top: 1.25rem;
}

.kb-page-nav-link {
  color: inherit;
  transition: color 0.15s ease;
}

.kb-page-nav-link:hover {
  color: var(--primary);
}

.kb-related-row,
.kb-subpage-row {
  border-bottom: 1px solid var(--border);
  color: inherit;
  transition: color 0.15s ease;
}

.kb-related-row:hover,
.kb-subpage-row:hover {
  color: var(--primary);
}

.kb-page-nav-link .arcane-icon {
  color: var(--muted-foreground);
}

@media (max-width: 900px) {
  .kb-page-nav {
    display: grid !important;
    grid-template-columns: 1fr;
  }
}
''';

  static const String _cardStyles = '''
.kb-card-group {
  display: flex;
  flex-direction: column;
  margin: 1.5rem 0;
  border-top: 1px solid var(--border);
}

.kb-card {
  display: block;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border);
  text-decoration: none;
  color: inherit;
  transition: color 0.16s ease;
}

.kb-card:hover {
  color: var(--primary);
}

.kb-card-content {
  display: grid;
  grid-template-columns: 1.5rem minmax(0, 1fr);
  align-items: start;
  gap: 0.75rem;
}

.kb-card-content-no-icon {
  grid-template-columns: minmax(0, 1fr);
}

.kb-card-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--muted-foreground);
}

.kb-card-title {
  font-size: 0.98rem;
  line-height: 1.3;
  font-weight: 600;
  color: var(--foreground);
}

.kb-card:hover .kb-card-title {
  color: var(--primary);
}

.kb-card-body {
  font-size: 0.9rem;
  line-height: 1.5;
  color: var(--muted-foreground);
}

.kb-card-body p {
  margin: 0;
}

.kb-card-body p + p {
  margin-top: 0.5rem;
}

''';

  static const String _columnsStyles = '''
.kb-columns {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.9rem;
  margin: 1.5rem 0;
}

.kb-columns-1 {
  grid-template-columns: minmax(0, 1fr);
}

.kb-columns-3 {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.kb-columns-4 {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.kb-column {
  min-width: 0;
}

.kb-column > :first-child {
  margin-top: 0;
}

.kb-column > :last-child {
  margin-bottom: 0;
}

@media (max-width: 900px) {
  .kb-columns {
    grid-template-columns: 1fr;
  }
}
''';

  static const String _tileStyles = '''
.kb-tiles {
  display: flex;
  flex-direction: column;
  margin: 1.25rem 0 1.5rem;
  border-top: 1px solid var(--border);
}

.kb-tile {
  border-bottom: 1px solid var(--border);
  color: inherit;
}

.kb-tile-content {
  display: grid;
  grid-template-columns: 1.5rem minmax(0, 1fr);
  align-items: start;
  gap: 0.75rem;
  padding: 0.9rem 0;
}

.kb-tile-content-no-icon {
  grid-template-columns: minmax(0, 1fr);
}

.kb-tile-link {
  text-decoration: none;
  display: block;
  transition: color 0.16s ease;
}

.kb-tile-link:hover {
  color: var(--primary);
}

.kb-tile-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--muted-foreground);
}

.kb-tile-title {
  font-size: 0.94rem;
  line-height: 1.3;
  font-weight: 600;
  color: var(--foreground);
  margin-bottom: 0.35rem;
}

.kb-tile-link:hover .kb-tile-title {
  color: var(--primary);
}

.kb-tile-body {
  font-size: 0.86rem;
  line-height: 1.5;
  color: var(--muted-foreground);
}

.kb-tile-body p {
  margin: 0;
}

.kb-tile-body p + p {
  margin-top: 0.45rem;
}

''';

  static const String _stepStyles = '''
.kb-steps {
  position: relative;
  margin: 1.5rem 0;
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
  counter-reset: kb-step-counter;
}

.kb-step {
  position: relative;
  display: grid;
  grid-template-columns: 2.4rem minmax(0, 1fr);
  gap: 0.75rem;
}

.kb-step:not(:last-child)::after {
  content: '';
  position: absolute;
  left: 1.05rem;
  top: 2.35rem;
  bottom: -0.9rem;
  width: 1px;
  background: color-mix(in srgb, var(--border) 65%, var(--primary) 35%);
  pointer-events: none;
}

.kb-step-marker {
  width: 2.1rem;
  height: 2.1rem;
  color: var(--foreground);
  font-size: 0.9rem;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-top: 0.15rem;
  font-size: 0;
}

.kb-step-marker::before {
  counter-increment: kb-step-counter;
  content: counter(kb-step-counter);
  font-size: 0.9rem;
  line-height: 1;
}

.kb-step-main {
  position: relative;
  padding: 0.35rem 0 0.85rem;
}

.kb-step-title {
  font-size: 0.96rem;
  line-height: 1.3;
  font-weight: 600;
  color: var(--foreground);
  margin-bottom: 0.45rem;
}

.kb-step-body {
  color: var(--muted-foreground);
  font-size: 0.9rem;
  line-height: 1.55;
}

.kb-step-body p {
  margin: 0;
}

.kb-step-body p + p {
  margin-top: 0.5rem;
}

@media (max-width: 700px) {
  .kb-step {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }

  .kb-step-marker {
    width: 1.95rem;
    height: 1.95rem;
  }

  .kb-step:not(:last-child)::after {
    display: none;
  }
}
''';

  static const String _accordionStyles = '''
.kb-accordion-group {
  display: flex;
  flex-direction: column;
  margin: 1.5rem 0;
  border-top: 1px solid var(--border);
}

.kb-accordion {
  border-bottom: 1px solid var(--border);
}

.kb-accordion-summary {
  list-style: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  padding: 0.85rem 0;
}

.kb-accordion-summary::-webkit-details-marker {
  display: none;
}

.kb-accordion-title {
  font-size: 0.95rem;
  line-height: 1.35;
  font-weight: 600;
  color: var(--foreground);
}

.kb-accordion-chevron {
  color: var(--muted-foreground);
  transition: transform 0.16s ease;
}

.kb-accordion[open] .kb-accordion-chevron {
  transform: rotate(180deg);
}

.kb-accordion-content {
  padding: 0 0 1rem;
  color: var(--muted-foreground);
  font-size: 0.9rem;
  line-height: 1.55;
}
''';

  static const String _badgeStyles = '''
.kb-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--foreground);
  font-size: 0.72rem;
  line-height: 1;
  font-weight: 600;
  letter-spacing: 0.02em;
  text-transform: uppercase;
  padding: 0.1rem 0;
}

.kb-badge-info {
  color: #3b82f6;
}

.kb-badge-success {
  color: #22c55e;
}

.kb-badge-warning {
  color: #f59e0b;
}

.kb-badge-danger {
  color: #ef4444;
}
''';

  static const String _bannerStyles = '''
.kb-banner {
  margin: 1.25rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  color: inherit;
  text-decoration: none;
  display: block;
}

.kb-banner-inner {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 0.5rem 0.75rem;
  padding: 0.8rem 0;
}

.kb-banner-leading {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
}

.kb-banner-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--foreground);
}

.kb-banner-title {
  font-size: 0.91rem;
  line-height: 1.25;
  font-weight: 700;
  color: var(--foreground);
}

.kb-banner-body {
  grid-column: 1 / 2;
  font-size: 0.88rem;
  color: var(--muted-foreground);
}

.kb-banner-body p {
  margin: 0;
}

a.kb-banner:hover {
  color: var(--primary);
}
''';

  static const String _panelStyles = '''
.kb-panel {
  margin: 1.5rem 0;
  padding: 0.95rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.kb-panel-title {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1.2;
  color: var(--foreground);
  margin-bottom: 0.6rem;
}

.kb-panel-icon {
  display: inline-flex;
  align-items: center;
  color: var(--muted-foreground);
}

.kb-panel-content {
  font-size: 0.9rem;
  line-height: 1.55;
  color: var(--muted-foreground);
}
''';

  static const String _frameStyles = '''
.kb-frame {
  margin: 1.5rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.kb-frame-label {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--muted-foreground);
  font-size: 0.72rem;
  letter-spacing: 0.03em;
  text-transform: uppercase;
  font-weight: 700;
  padding: 0.5rem 0 0;
}

.kb-frame-body {
  padding: 0.9rem 0;
}

.kb-frame-caption {
  border-top: 1px solid var(--border);
  color: var(--muted-foreground);
  font-size: 0.82rem;
  line-height: 1.45;
  padding: 0.55rem 0 0.65rem;
}
''';

  static const String _updateStyles = '''
.kb-update {
  margin: 1.5rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  padding: 0.85rem 0;
}

.kb-update-head {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.kb-update-icon {
  color: var(--muted-foreground);
  display: inline-flex;
}

.kb-update-label {
  color: var(--foreground);
  font-size: 0.88rem;
  font-weight: 700;
  line-height: 1.2;
}

.kb-update-date {
  margin-left: auto;
  color: var(--muted-foreground);
  font-size: 0.78rem;
}

.kb-update-body {
  color: var(--muted-foreground);
  font-size: 0.88rem;
  line-height: 1.55;
}
''';

  static const String _tooltipStyles = '''
.kb-tooltip {
  display: inline-flex;
  align-items: center;
  line-height: 1;
}

.kb-tooltip-ready {
  border-bottom: 1px dashed color-mix(in srgb, var(--muted-foreground) 60%, transparent);
  cursor: help;
}
''';

  static const String _inlineIconStyles = '''
.kb-inline-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  vertical-align: middle;
}
''';

  static const String _tagStyles = '''
.kb-tag-list {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.35rem;
}

.kb-tag-list-md {
  gap: 0.45rem;
}

.kb-tag {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.3rem;
  max-width: 100%;
  padding: 0;
  color: var(--muted-foreground);
  font-weight: 500;
  line-height: 1.2;
  white-space: nowrap;
}

.kb-tag-xs {
  font-size: 0.72rem;
}

.kb-tag-sm {
  font-size: 0.8rem;
}

.kb-tag-md {
  font-size: 0.86rem;
  color: var(--muted-foreground);
}

.kb-tag svg,
.kb-tag i {
  flex-shrink: 0;
  opacity: 0.7;
}

.kb-tags-footer .kb-tag-list {
  row-gap: 0.55rem;
}
''';

  static const String _ratingStyles = '''
.kb-rating {
  margin-top: 2rem;
}

.kb-rating-content {
  padding: 1rem;
}

.kb-rating-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-md, 0.375rem);
  background: var(--background);
  color: var(--muted-foreground);
  font: inherit;
  font-size: 0.875rem;
  cursor: pointer;
  transition: border-color 0.15s ease, color 0.15s ease;
}

.kb-rating-btn:hover,
.kb-rating-btn:focus-visible {
  border-color: var(--primary);
  color: var(--foreground);
}

.kb-rating-count {
  margin-left: 0.25rem;
  color: var(--muted-foreground);
  font-size: 0.75rem;
}

.kb-rating-thanks[hidden] {
  display: none;
}
''';

  static const String _docUtilityStyles = '''
.kb-kbd {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 1.45rem;
  min-height: 1.35rem;
  padding: 0.12rem 0.36rem;
  border: 1px solid var(--border);
  background: var(--muted);
  color: var(--foreground);
  font-family: var(--font-mono, monospace);
  font-size: 0.78em;
  font-weight: 600;
  line-height: 1;
  vertical-align: 0.08em;
}

.kb-path {
  display: inline-flex;
  align-items: center;
  gap: 0.32rem;
  max-width: 100%;
  border: 1px solid var(--border);
  background: var(--muted);
  color: var(--foreground);
  font-family: var(--font-mono, monospace);
  font-size: 0.86em;
  line-height: 1.15;
  padding: 0.18rem 0.4rem;
  vertical-align: 0.03em;
  overflow-wrap: anywhere;
}

.kb-path-icon {
  display: inline-flex;
  align-items: center;
  color: var(--muted-foreground);
  flex-shrink: 0;
}

.kb-endpoint {
  display: flex;
  align-items: stretch;
  width: 100%;
  margin: 1rem 0;
  border: 1px solid var(--border);
  background: var(--card);
  overflow: hidden;
}

.kb-endpoint-method {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 4.5rem;
  padding: 0.55rem 0.7rem;
  border-right: 1px solid var(--border);
  color: var(--foreground);
  font-family: var(--font-mono, monospace);
  font-size: 0.76rem;
  font-weight: 800;
}

.kb-endpoint-path {
  min-width: 0;
  flex: 1;
  padding: 0.55rem 0.75rem;
  color: var(--foreground);
  font-family: var(--font-mono, monospace);
  font-size: 0.86rem;
  overflow-wrap: anywhere;
}

.kb-endpoint-get .kb-endpoint-method {
  color: #22c55e;
}

.kb-endpoint-post .kb-endpoint-method {
  color: #3b82f6;
}

.kb-endpoint-put .kb-endpoint-method,
.kb-endpoint-patch .kb-endpoint-method {
  color: #f59e0b;
}

.kb-endpoint-delete .kb-endpoint-method {
  color: #ef4444;
}

.kb-resource-grid {
  display: flex;
  flex-direction: column;
  margin: 1.25rem 0;
  border-top: 1px solid var(--border);
}

.kb-resource {
  display: block;
  border-bottom: 1px solid var(--border);
  color: inherit;
  text-decoration: none;
}

.kb-resource-link {
  transition: color 0.15s ease;
}

.kb-resource-link:hover {
  color: var(--primary);
}

.kb-resource-content {
  display: grid;
  grid-template-columns: 1.25rem minmax(0, 1fr);
  align-items: start;
  gap: 0.75rem;
  padding: 0.82rem 0;
}

.kb-resource-icon {
  display: inline-flex;
  align-items: center;
  color: var(--muted-foreground);
  flex-shrink: 0;
}

.kb-resource-label {
  color: var(--muted-foreground);
  font-size: 0.68rem;
  font-weight: 700;
  line-height: 1;
  margin-bottom: 0.25rem;
  text-transform: uppercase;
}

.kb-resource-title {
  color: var(--foreground);
  font-size: 0.92rem;
  font-weight: 700;
  line-height: 1.25;
}

.kb-resource-link:hover .kb-resource-title {
  color: var(--primary);
}

.kb-resource-body {
  margin-top: 0.35rem;
  color: var(--muted-foreground);
  font-size: 0.86rem;
  line-height: 1.5;
}

.kb-resource-body p {
  margin: 0;
}

@media (max-width: 640px) {
  .kb-endpoint {
    flex-direction: column;
  }

  .kb-endpoint-method {
    justify-content: flex-start;
    border-right: 0;
    border-bottom: 1px solid var(--border);
  }
}
''';

  static const String _codeGroupStyles = '''
.kb-code-group {
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  margin: 1.5rem 0;
}

.kb-code-group-title {
  border-bottom: 1px solid var(--border);
  font-size: 0.78rem;
  line-height: 1;
  letter-spacing: 0.03em;
  text-transform: uppercase;
  color: var(--muted-foreground);
  font-weight: 700;
  padding: 0.5rem 0;
}

.kb-code-group-body {
  padding: 0;
}

.kb-code-group-body pre {
  border-radius: 0 !important;
  margin: 0;
}

.kb-code-group-body pre + pre {
  border-top: 1px solid var(--border);
}
''';

  static const String _fieldStyles = '''
.kb-field-group {
  margin: 1.5rem 0;
  display: flex;
  flex-direction: column;
  border-top: 1px solid var(--border);
}

.kb-field {
  border-bottom: 1px solid var(--border);
  padding: 0.75rem 0;
}

.kb-field-head {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.35rem 0.45rem;
}

.kb-field-name {
  font-size: 0.89rem;
  font-weight: 700;
  color: var(--foreground);
}

.kb-field-type {
  color: var(--muted-foreground);
  font-size: 0.74rem;
  line-height: 1;
  padding: 0.25rem 0.45rem;
}

.kb-field-badge {
  font-size: 0.72rem;
  line-height: 1;
  padding: 0.22rem 0.42rem;
  text-transform: uppercase;
  letter-spacing: 0.02em;
  font-weight: 700;
}

.kb-field-location {
  color: color-mix(in srgb, var(--primary) 70%, var(--foreground));
}

.kb-field-required {
  color: #ef4444;
}

.kb-field-body {
  margin-top: 0.5rem;
  color: var(--muted-foreground);
  font-size: 0.87rem;
  line-height: 1.55;
}
''';

  static const String _treeStyles = '''
.kb-tree {
  margin: 1.5rem 0;
  padding-left: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  border-top: 1px solid var(--border);
}

.kb-tree-item {
  list-style: none;
}

.kb-tree-folder-details {
  border-bottom: 1px solid var(--border);
}

.kb-tree-folder-summary {
  list-style: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.55rem 0.7rem;
}

.kb-tree-folder-summary::-webkit-details-marker {
  display: none;
}

.kb-tree-folder-label {
  font-size: 0.87rem;
  line-height: 1.25;
  color: var(--foreground);
  font-weight: 600;
}

.kb-tree-folder-chevron {
  margin-left: auto;
  color: var(--muted-foreground);
  transition: transform 0.16s ease;
}

.kb-tree-folder-details[open] .kb-tree-folder-chevron {
  transform: rotate(180deg);
}

.kb-tree-branch {
  list-style: none;
  margin: 0;
  padding: 0 0.6rem 0.6rem 0.95rem;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.kb-tree-file-row {
  display: flex;
  align-items: center;
  gap: 0.38rem;
  padding: 0.42rem 0.55rem;
}

.kb-tree-file-label {
  font-size: 0.84rem;
  color: var(--muted-foreground);
}

.kb-tree-file-extra {
  margin-left: 1.65rem;
  margin-top: 0.35rem;
  font-size: 0.84rem;
  color: var(--muted-foreground);
}
''';

  static const String _colorStyles = '''
.kb-color-grid {
  margin: 1.5rem 0;
  display: flex;
  flex-direction: column;
  border-top: 1px solid var(--border);
}

.kb-color-item {
  display: grid;
  grid-template-columns: 4rem minmax(0, 1fr);
  border-bottom: 1px solid var(--border);
}

.kb-color-swatch {
  min-height: 3.1rem;
}

.kb-color-meta {
  padding: 0.6rem 0.7rem;
}

.kb-color-label {
  color: var(--foreground);
  font-size: 0.84rem;
  font-weight: 700;
  line-height: 1.2;
}

.kb-color-value {
  margin-top: 0.24rem;
  color: var(--muted-foreground);
  font-size: 0.78rem;
  line-height: 1.2;
  font-family: var(--font-mono, monospace);
}

.kb-color-extra {
  margin-top: 0.45rem;
  color: var(--muted-foreground);
  font-size: 0.82rem;
}
''';

  static const String _viewStyles = '''
.kb-view {
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  margin: 1.5rem 0;
}

.kb-view-title {
  border-bottom: 1px solid var(--border);
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  width: 100%;
  color: var(--foreground);
  font-size: 0.86rem;
  line-height: 1.2;
  font-weight: 700;
  padding: 0.6rem 0;
}

.kb-view-icon {
  color: var(--muted-foreground);
  display: inline-flex;
}

.kb-view-body {
  padding: 0.8rem 0;
}
''';

  static const String _landingStyles = '''
.kb-landing-content-area {
  max-width: none !important;
  width: 100%;
  padding: 2rem;
}

.kb-landing-page {
  width: 100%;
  max-width: 80rem !important;
  padding: 0 !important;
}

.kb-landing-page .kb-landing-prose,
.kb-landing-page .prose {
  max-width: none;
}

.kb-landing-prose > * + * {
  margin-top: 1.25rem;
}

.kb-landing-prose h1,
.kb-landing-prose h2,
.kb-landing-prose h3,
.kb-landing-prose p,
.kb-landing-prose ul,
.kb-landing-prose li {
  margin: 0;
}

.kb-landing-hero {
  position: relative;
  display: grid;
  grid-template-columns: minmax(0, 1.1fr) minmax(18rem, 0.9fr);
  gap: 1.5rem;
  min-height: 28rem;
  padding: 3rem;
}

.kb-landing-hero-copy {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 1.2rem;
  max-width: 44rem;
}

.kb-landing-kicker {
  width: max-content;
  max-width: 100%;
  color: var(--foreground);
  font-size: 0.8rem;
  font-weight: 800;
  line-height: 1;
  text-transform: uppercase;
  letter-spacing: 0;
}

.kb-landing-hero h1 {
  max-width: 12ch;
  color: var(--foreground);
  font-size: 4rem;
  font-weight: 900;
  line-height: 0.95;
  letter-spacing: 0;
}

.kb-landing-hero p {
  max-width: 38rem;
  color: var(--muted-foreground);
  font-size: 1.125rem;
  line-height: 1.65;
}

.kb-landing-actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.75rem;
  margin-top: 0.35rem;
}

.kb-landing-actions a {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 2.75rem;
  padding: 0 1rem;
  border: 1px solid var(--border);
  font-size: 0.95rem;
  font-weight: 800;
  line-height: 1;
  text-decoration: none;
}

.kb-landing-actions a::after,
.kb-landing-card a::after {
  content: none !important;
}

.kb-landing-primary {
  background: var(--primary);
  color: var(--primary-foreground) !important;
}

.kb-landing-secondary {
  background: var(--card);
  color: var(--foreground) !important;
}

.kb-landing-spotlight {
  position: relative;
  z-index: 1;
  align-self: stretch;
  display: grid;
  grid-template-rows: auto 1fr;
  gap: 1rem;
  min-width: 0;
}

.kb-landing-terminal {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.kb-landing-terminal-bar {
  display: flex;
  gap: 0.4rem;
  padding: 0.75rem;
  border-bottom: 1px solid var(--border);
}

.kb-landing-terminal-dot {
  display: none;
}

.kb-landing-terminal-body {
  display: grid;
  gap: 0.95rem;
  padding: clamp(1rem, 1.8vw, 1.25rem);
}

.kb-landing-terminal-row {
  display: grid;
  gap: 0.45rem;
  padding: 0.95rem 0;
  border-bottom: 1px solid var(--border);
}

.kb-landing-terminal-label {
  color: var(--muted-foreground);
  font-size: 0.72rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0;
}

.kb-landing-terminal-value {
  color: var(--foreground);
  font-family: var(--font-mono);
  font-size: 0.9rem;
  line-height: 1.35;
}

.kb-landing-grid {
  display: flex;
  flex-direction: column;
  margin-top: 1.25rem;
  margin-bottom: 1.5rem;
  border-top: 1px solid var(--border);
}

.kb-landing-card {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.25rem 0;
  border-bottom: 1px solid var(--border);
  color: var(--foreground);
}

.kb-landing-card h2 {
  color: var(--foreground);
  font-size: 1.25rem;
  font-weight: 850;
  line-height: 1.1;
  border: 0;
  padding: 0;
}

.kb-landing-card p {
  color: var(--muted-foreground);
  line-height: 1.55;
}

.kb-landing-card a {
  width: max-content;
  max-width: 100%;
  margin-top: auto;
  color: var(--primary);
  font-weight: 800;
  text-decoration: none;
}

.kb-landing-band {
  display: grid;
  grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.1fr);
  gap: clamp(1.45rem, 2.4vw, 2.15rem);
  align-items: stretch;
  margin-top: 1.25rem;
  padding: 1.5rem 0;
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.kb-landing-band h2 {
  color: var(--foreground);
  font-size: 2rem;
  font-weight: 900;
  line-height: 1;
  border: 0;
  padding: 0;
}

.kb-landing-list {
  display: grid;
  border-top: 1px solid var(--border);
}

.kb-landing-list-item {
  display: grid;
  grid-template-columns: 2.5rem minmax(0, 1fr);
  gap: 0.8rem;
  align-items: start;
  padding: 0.85rem 0;
  border-bottom: 1px solid var(--border);
}

.kb-landing-list-index {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.1rem;
  height: 2.1rem;
  color: var(--primary);
  font-weight: 900;
}

.kb-landing-list-title {
  color: var(--foreground);
  font-weight: 850;
  line-height: 1.2;
}

.kb-landing-list-copy {
  margin-top: 0.25rem;
  color: var(--muted-foreground);
  line-height: 1.5;
}



@media (max-width: 1100px) {
  .kb-landing-hero,
  .kb-landing-band {
    grid-template-columns: 1fr;
  }

  .kb-landing-hero {
    min-height: auto;
  }
}

@media (max-width: 700px) {
  .kb-landing-content-area {
    padding: 1rem;
  }

  .kb-landing-hero,
  .kb-landing-band,
  .kb-landing-card {
    padding: 1rem 0;
  }

  .kb-landing-hero h1 {
    font-size: 2.75rem;
  }

  .kb-landing-hero p {
    font-size: 1rem;
  }
}
''';

  static const String _contentThemeBridge = '''
#arcane-root {
  --text: var(--foreground);
  --content-headings: var(--foreground);
  --content-lead: var(--muted-foreground);
  --content-links: var(--primary);
  --content-bold: var(--foreground);
  --content-counters: color-mix(in srgb, var(--muted-foreground) 82%, var(--foreground));
  --content-bullets: color-mix(in srgb, var(--muted-foreground) 76%, transparent);
  --content-hr: var(--border);
  --content-quotes: var(--foreground);
  --content-quote-borders: var(--border);
  --content-captions: var(--muted-foreground);
  --content-kbd: var(--foreground);
  --content-kbd-shadows: color-mix(in srgb, var(--foreground) 36%, transparent);
  --content-code: var(--foreground);
  --content-pre-code: var(--foreground);
  --content-pre-bg: color-mix(in srgb, var(--card) 88%, var(--background));
  --content-th-borders: var(--border);
  --content-td-borders: var(--border);
}

#arcane-root .content :is(h1, h2, h3, h4, h5, h6)[anchor] > span {
  min-width: 0;
  overflow-wrap: anywhere;
}

#arcane-root .content :is(h1, h2, h3, h4, h5, h6)[anchor] > a {
  flex-shrink: 0;
}
''';

  static const String _lightThemeReadability = '''
html.light .prose p,
html.light .prose li,
html.light .prose blockquote,
#arcane-root.light .prose p,
#arcane-root.light .prose li,
#arcane-root.light .prose blockquote {
  color: var(--foreground);
}

html.light .prose li::marker,
#arcane-root.light .prose li::marker {
  color: color-mix(in srgb, var(--foreground) 70%, transparent);
}

html.light .sidebar-brand-title,
html.light .sidebar-section-header,
html.light .sidebar-summary,
html.light .sidebar-link,
html.light .sidebar-chevron,
#arcane-root.light .sidebar-brand-title,
#arcane-root.light .sidebar-section-header,
#arcane-root.light .sidebar-summary,
#arcane-root.light .sidebar-link,
#arcane-root.light .sidebar-chevron {
  color: var(--foreground);
}

html.light .toc-title,
html.light .toc-content a,
#arcane-root.light .toc-title,
#arcane-root.light .toc-content a {
  color: var(--foreground);
}

html.light .kb-topbar-brand,
html.light .kb-topbar-link,
#arcane-root.light .kb-topbar-brand,
#arcane-root.light .kb-topbar-link {
  color: var(--foreground);
}

html.light .kb-topbar-link.active,
#arcane-root.light .kb-topbar-link.active {
  color: var(--foreground);
}

html.light .kb-callout-content,
html.light .markdown-alert p,
#arcane-root.light .kb-callout-content,
#arcane-root.light .markdown-alert p {
  color: var(--foreground);
}

html.light .prose th,
html.light .prose td,
#arcane-root.light .prose th,
#arcane-root.light .prose td {
  color: var(--foreground);
}
''';

  static const String _nestedSurfaceStyles = '''
:is(
  .kb-card,
  .kb-tile,
  .kb-callout,
  .markdown-alert,
  .kb-banner,
  .kb-panel,
  .kb-frame,
  .kb-update,
  .kb-resource,
  .kb-field,
  .kb-view,
  .kb-landing-card,
  .kb-code-group,
  .kb-endpoint,
  .kb-accordion
) :is(
  .kb-card-group,
  .kb-card,
  .kb-tiles,
  .kb-tile,
  .kb-callout,
  .markdown-alert,
  .kb-banner,
  .kb-panel,
  .kb-frame,
  .kb-update,
  .kb-resource-grid,
  .kb-resource,
  .kb-code-group,
  .kb-field-group,
  .kb-field,
  .kb-tree,
  .kb-color-grid,
  .kb-view,
  .kb-landing-card,
  .kb-endpoint,
  .kb-accordion-group,
  .kb-accordion
) {
  border: 0 !important;
  border-radius: 0 !important;
  background: transparent !important;
  background-image: none !important;
  box-shadow: none !important;
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
  filter: none !important;
}

@media (prefers-reduced-motion: reduce) {
  .kb-style-slot,
  .kb-style-slot *,
  .kb-style-slot *::before,
  .kb-style-slot *::after {
    scroll-behavior: auto !important;
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
''';
}
