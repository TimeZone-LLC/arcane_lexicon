import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_lexicon/src/layout/kb_renderers.dart';

/// Base URL from environment, set via `--dart-define=BASE_URL=/path`.
const String _envBaseUrl = String.fromEnvironment('BASE_URL');

/// Configuration for the knowledge base site.
class SiteConfig {
  /// The name of the site displayed in the header.
  final String name;

  /// A brief description of the site for meta tags.
  final String? description;

  /// Path to a logo image (optional).
  final String? logo;

  /// GitHub repository URL (optional, adds link in header).
  final String? githubUrl;

  /// Base URL for subdirectory hosting (e.g., '/docs').
  final String baseUrl;

  /// The content directory containing markdown files.
  final String contentDirectory;

  final String? landingPath;

  /// The route for the home page.
  final String homeRoute;

  /// Whether search functionality is enabled.
  final bool searchEnabled;

  /// Whether table of contents is enabled on pages.
  final bool tocEnabled;

  /// Whether to show the theme toggle button.
  final bool themeToggleEnabled;

  final bool stylesheetSwitcherEnabled;

  final bool paletteSwitcherEnabled;

  /// Default theme mode.
  final KBThemeMode defaultTheme;

  /// Primary accent color for the theme.
  final String? primaryColor;

  /// Custom footer text (optional).
  final String? footerText;

  /// Copyright text for the footer.
  final String? copyright;

  /// Navigation links for the header.
  final List<NavLink> headerLinks;

  /// Social links for the footer/header.
  final List<SocialLink> socialLinks;

  /// Optional sidebar footer text (always visible at bottom of sidebar).
  final String? sidebarFooter;

  /// Optional sidebar footer link URL.
  final String? sidebarFooterUrl;

  /// Git branch for edit links (default: 'main').
  final String editBranch;

  /// Whether to show "Edit this page" links.
  final bool showEditLink;

  /// Whether to show the page rating widget (thumbs up/down).
  final bool ratingEnabled;

  /// Custom prompt text for the rating widget.
  final String ratingPromptText;

  /// Custom thank you text shown after rating.
  final String ratingThankYouText;

  final bool pageNavEnabled;

  /// Width of the sidebar (CSS value, e.g., '280px', '300px', '20rem').
  final String sidebarWidth;

  /// Left indent for sidebar tree items (CSS value, e.g., '10px', '0.625rem').
  /// Controls spacing between tree connector lines and icons.
  final String sidebarTreeIndent;

  final bool navigationBarEnabled;

  final KBNavigationBarPosition navigationBarPosition;

  const SiteConfig({
    required this.name,
    this.description,
    this.logo,
    this.githubUrl,
    this.baseUrl = _envBaseUrl,
    this.contentDirectory = 'content',
    this.landingPath,
    this.homeRoute = '/',
    this.searchEnabled = true,
    this.tocEnabled = true,
    this.themeToggleEnabled = true,
    this.stylesheetSwitcherEnabled = false,
    this.paletteSwitcherEnabled = false,
    this.defaultTheme = KBThemeMode.dark,
    this.primaryColor,
    this.footerText,
    this.copyright,
    this.headerLinks = const [],
    this.socialLinks = const [],
    this.sidebarFooter,
    this.sidebarFooterUrl,
    this.editBranch = 'main',
    this.showEditLink = true,
    this.ratingEnabled = false,
    this.ratingPromptText = 'Was this page helpful?',
    this.ratingThankYouText = 'Thanks for your feedback!',
    this.pageNavEnabled = true,
    this.sidebarWidth = '280px',
    this.sidebarTreeIndent = '10px',
    this.navigationBarEnabled = true,
    this.navigationBarPosition = KBNavigationBarPosition.top,
  });

  /// Get the full URL for a path, including the base URL.
  String fullPath(String path) {
    if (baseUrl.isEmpty) return path;
    if (path == '/') return baseUrl;
    return '$baseUrl$path';
  }

  /// Get the asset prefix for static assets.
  String get assetPrefix => baseUrl.isEmpty ? '' : baseUrl;

  String? get landingEditPath {
    String? rawPath = landingPath;
    if (rawPath == null) {
      return null;
    }
    String normalized = rawPath.trim().replaceAll('\\', '/');
    while (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized.endsWith('.md')) {
      return normalized;
    }
    if (normalized.endsWith('/')) {
      return '${normalized}index.md';
    }
    return '$normalized/index.md';
  }

  /// Generate the GitHub edit URL for a given page path.
  String? editUrl(String pagePath) {
    if (githubUrl == null || !showEditLink) return null;

    // Convert URL path to file path
    String filePath = pagePath;
    String? landingPath = landingEditPath;
    if (landingPath != null && _isHomePath(pagePath)) {
      filePath = landingPath;
    } else if (filePath == '/' || filePath.isEmpty) {
      filePath = 'index.md';
    } else {
      // Remove leading slash
      filePath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
      // Check if it's a section index or regular page
      if (!filePath.endsWith('.md')) {
        filePath = '$filePath.md';
      }
    }

    // Build full path to content file
    final String contentPath = '$contentDirectory/$filePath';

    // Generate GitHub edit URL
    final String repoUrl = githubUrl!.endsWith('/')
        ? githubUrl!.substring(0, githubUrl!.length - 1)
        : githubUrl!;
    return '$repoUrl/edit/$editBranch/$contentPath';
  }

  bool _isHomePath(String path) {
    String normalizedPath = path.trim().isEmpty ? '/' : path.trim();
    String normalizedHome = homeRoute.trim().isEmpty ? '/' : homeRoute.trim();
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }
    if (!normalizedHome.startsWith('/')) {
      normalizedHome = '/$normalizedHome';
    }
    return normalizedPath == normalizedHome || normalizedPath == '/';
  }
}

class KBStylesheetOption {
  final String id;
  final String label;
  final ArcaneStylesheet stylesheet;
  final List<KBPaletteOption> palettes;
  final KnowledgeBaseRenderers? knowledgeBaseRenderers;

  const KBStylesheetOption({
    required this.id,
    required this.label,
    required this.stylesheet,
    this.palettes = const <KBPaletteOption>[],
    this.knowledgeBaseRenderers,
  });
}

class KBPaletteOption {
  final String id;
  final String label;
  final ArcaneStylesheet stylesheet;
  final String? bodyClass;
  final String? swatch;

  const KBPaletteOption({
    required this.id,
    required this.label,
    required this.stylesheet,
    this.bodyClass,
    this.swatch,
  });
}

/// Theme mode options for the knowledge base.
enum KBThemeMode { dark, light, system }

enum KBNavigationBarPosition { top, bottom }

/// A navigation link for the header.
class NavLink {
  final String label;
  final String href;
  final bool external;

  const NavLink({
    required this.label,
    required this.href,
    this.external = false,
  });
}

/// A social media link.
class SocialLink {
  final String name;
  final String url;
  final String icon;

  const SocialLink({required this.name, required this.url, required this.icon});

  /// Common social link presets.
  static SocialLink github(String url) =>
      SocialLink(name: 'GitHub', url: url, icon: 'github');

  static SocialLink twitter(String url) =>
      SocialLink(name: 'Twitter', url: url, icon: 'twitter');

  static SocialLink discord(String url) =>
      SocialLink(name: 'Discord', url: url, icon: 'message-circle');

  static SocialLink youtube(String url) =>
      SocialLink(name: 'YouTube', url: url, icon: 'youtube');
}
