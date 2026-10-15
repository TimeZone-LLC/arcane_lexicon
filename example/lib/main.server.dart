library;

import 'dart:io';

import 'package:arcane_jaspr_ascii/arcane_jaspr_ascii.dart';
import 'package:arcane_jaspr_kb/arcane_jaspr_kb.dart';
import 'package:arcane_jaspr_neon/arcane_jaspr_neon.dart';
import 'package:arcane_jaspr_neubrutalism/arcane_jaspr_neubrutalism.dart';
import 'package:arcane_jaspr_shadcn/arcane_jaspr_shadcn.dart';
import 'package:arcane_lexicon/arcane_lexicon.dart' hide runApp;
import 'package:jaspr/server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'main.server.options.dart';

const ArcaneStylesheet shadcnStylesheet = ShadcnStylesheet(
  theme: ShadcnTheme.midnight,
);
const ArcaneStylesheet shadcnCharcoal = ShadcnStylesheet(
  theme: ShadcnTheme.charcoal,
);
const ArcaneStylesheet shadcnCream = ShadcnStylesheet(theme: ShadcnTheme.cream);
const ArcaneStylesheet shadcnSlate = ShadcnStylesheet(theme: ShadcnTheme.slate);
const ArcaneStylesheet shadcnRose = ShadcnStylesheet(theme: ShadcnTheme.rose);
const ArcaneStylesheet shadcnLavender = ShadcnStylesheet(
  theme: ShadcnTheme.lavender,
);
const ArcaneStylesheet shadcnMint = ShadcnStylesheet(theme: ShadcnTheme.mint);
const ArcaneStylesheet shadcnSky = ShadcnStylesheet(theme: ShadcnTheme.sky);
const ArcaneStylesheet shadcnPeach = ShadcnStylesheet(theme: ShadcnTheme.peach);
const ArcaneStylesheet shadcnTeal = ShadcnStylesheet(theme: ShadcnTheme.teal);

const ArcaneStylesheet neonStylesheet = NeonStylesheet(theme: NeonTheme.green);

const ArcaneStylesheet neubrutalismStylesheet = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.yellow,
);
const ArcaneStylesheet neubrutalismPink = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.pink,
);
const ArcaneStylesheet neubrutalismMint = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.mint,
);
const ArcaneStylesheet neubrutalismOrange = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.orange,
);
const ArcaneStylesheet neubrutalismSky = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.sky,
);
const ArcaneStylesheet neubrutalismLavender = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.lavender,
);
const ArcaneStylesheet neubrutalismLime = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.lime,
);
const ArcaneStylesheet neubrutalismRed = NeubrutalismStylesheet(
  theme: NeubrutalismTheme.red,
);

const ArcaneStylesheet selectedStylesheet = neonStylesheet;
const List<KBStylesheetOption> stylesheetOptions = <KBStylesheetOption>[
  KBStylesheetOption(
    id: 'ascii',
    label: 'Ascii',
    stylesheet: AsciiStylesheet(),
  ),
  KBStylesheetOption(
    id: 'shadcn',
    label: 'Shadcn',
    stylesheet: shadcnStylesheet,
    knowledgeBaseRenderers: ShadcnKnowledgeBaseRenderers(),
    palettes: <KBPaletteOption>[
      KBPaletteOption(
        id: 'midnight',
        label: 'Midnight',
        stylesheet: shadcnStylesheet,
        swatch: '#020617',
      ),
      KBPaletteOption(
        id: 'charcoal',
        label: 'Charcoal',
        stylesheet: shadcnCharcoal,
        swatch: '#1f2937',
      ),
      KBPaletteOption(
        id: 'cream',
        label: 'Cream',
        stylesheet: shadcnCream,
        swatch: '#fafaf9',
      ),
      KBPaletteOption(
        id: 'slate',
        label: 'Slate',
        stylesheet: shadcnSlate,
        swatch: '#64748b',
      ),
      KBPaletteOption(
        id: 'rose',
        label: 'Rose',
        stylesheet: shadcnRose,
        swatch: '#f43f5e',
      ),
      KBPaletteOption(
        id: 'lavender',
        label: 'Lavender',
        stylesheet: shadcnLavender,
        swatch: '#a78bfa',
      ),
      KBPaletteOption(
        id: 'mint',
        label: 'Mint',
        stylesheet: shadcnMint,
        swatch: '#34d399',
      ),
      KBPaletteOption(
        id: 'sky',
        label: 'Sky',
        stylesheet: shadcnSky,
        swatch: '#38bdf8',
      ),
      KBPaletteOption(
        id: 'peach',
        label: 'Peach',
        stylesheet: shadcnPeach,
        swatch: '#fb923c',
      ),
      KBPaletteOption(
        id: 'teal',
        label: 'Teal',
        stylesheet: shadcnTeal,
        swatch: '#14b8a6',
      ),
    ],
  ),
  KBStylesheetOption(
    id: 'neon',
    label: 'Neon',
    stylesheet: neonStylesheet,
    knowledgeBaseRenderers: NeonKnowledgeBaseRenderers(),
    palettes: <KBPaletteOption>[
      KBPaletteOption(
        id: 'green',
        label: 'Green',
        stylesheet: neonStylesheet,
        bodyClass: 'neon-green',
        swatch: '#059669',
      ),
    ],
  ),
  KBStylesheetOption(
    id: 'neubrutalism',
    label: 'NeuBrutalism',
    stylesheet: neubrutalismStylesheet,
    knowledgeBaseRenderers: NeubrutalismKnowledgeBaseRenderers(),
    palettes: <KBPaletteOption>[
      KBPaletteOption(
        id: 'yellow',
        label: 'Yellow',
        stylesheet: neubrutalismStylesheet,
        bodyClass: 'neubrutalism-yellow',
        swatch: '#ffd700',
      ),
      KBPaletteOption(
        id: 'pink',
        label: 'Pink',
        stylesheet: neubrutalismPink,
        bodyClass: 'neubrutalism-pink',
        swatch: '#ff80c0',
      ),
      KBPaletteOption(
        id: 'mint',
        label: 'Mint',
        stylesheet: neubrutalismMint,
        bodyClass: 'neubrutalism-mint',
        swatch: '#7be8b6',
      ),
      KBPaletteOption(
        id: 'orange',
        label: 'Orange',
        stylesheet: neubrutalismOrange,
        bodyClass: 'neubrutalism-orange',
        swatch: '#ff8c42',
      ),
      KBPaletteOption(
        id: 'sky',
        label: 'Sky',
        stylesheet: neubrutalismSky,
        bodyClass: 'neubrutalism-sky',
        swatch: '#7cd0ff',
      ),
      KBPaletteOption(
        id: 'lavender',
        label: 'Lavender',
        stylesheet: neubrutalismLavender,
        bodyClass: 'neubrutalism-lavender',
        swatch: '#c8a2ff',
      ),
      KBPaletteOption(
        id: 'lime',
        label: 'Lime',
        stylesheet: neubrutalismLime,
        bodyClass: 'neubrutalism-lime',
        swatch: '#c8ff42',
      ),
      KBPaletteOption(
        id: 'red',
        label: 'Red',
        stylesheet: neubrutalismRed,
        bodyClass: 'neubrutalism-red',
        swatch: '#ff5c5c',
      ),
    ],
  ),
];

Future<void> main() async {
  Jaspr.initializeApp(options: defaultServerOptions);

  Component app = await KnowledgeBaseApp.create(
    config: const SiteConfig(
      name: 'Example Docs',
      description: 'Arcane Lexicon demo site',
      contentDirectory: 'content',
      githubUrl: 'https://github.com/ArcaneArts/arcane_lexicon',
      themeToggleEnabled: true,
      stylesheetSwitcherEnabled: true,
      paletteSwitcherEnabled: true,
      showEditLink: true,
      editBranch: 'main',
      navigationBarEnabled: true,
      navigationBarPosition: KBNavigationBarPosition.top,
      headerLinks: <NavLink>[
        NavLink(label: 'Docs', href: '/'),
        NavLink(
          label: 'GitHub',
          href: 'https://github.com/ArcaneArts/arcane_lexicon',
          external: true,
        ),
      ],
      footerText: 'Built with Arcane Lexicon',
      sidebarFooter: 'v1.0.0',
      sidebarFooterUrl: 'https://github.com/ArcaneArts/arcane_lexicon/releases',
    ),
    stylesheet: selectedStylesheet,
    stylesheetOptions: stylesheetOptions,
  );

  if (const bool.fromEnvironment('jaspr.flags.release')) {
    await _serveRelease(app);
    return;
  }

  runApp(app);
}

Future<void> _serveRelease(Component app) async {
  Handler jasprHandler = serveApp((Request request, RenderFunction render) {
    return render(app);
  });
  Handler handler = _releaseHandler(app, jasprHandler);
  int port = int.parse(Platform.environment['PORT'] ?? '8080');
  HttpServer server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    port,
    shared: true,
  );

  stdout.writeln('[INFO] Running server in release mode');
  stdout.writeln('Serving at http://${server.address.host}:${server.port}');

  if (const bool.fromEnvironment('jaspr.flags.generate')) {
    await ServerApp.requestRouteGeneration('/');
  }
}

Handler _releaseHandler(Component app, Handler jasprHandler) {
  return (Request request) {
    if (_shouldRenderRoute(request)) {
      return _renderRoute(app, request);
    }
    return jasprHandler(request);
  };
}

bool _shouldRenderRoute(Request request) {
  String path = request.url.path;
  if (path.isEmpty || path.endsWith('/')) {
    return true;
  }

  String segment = request.url.pathSegments.isEmpty
      ? ''
      : request.url.pathSegments.last;
  return !segment.contains('.');
}

Future<Response> _renderRoute(Component app, Request request) async {
  ResponseLike rendered = await renderComponent(app, request: request);
  Map<String, String> headers = <String, String>{};
  for (MapEntry<String, List<String>> entry in rendered.headers.entries) {
    headers[entry.key] = entry.value.join(',');
  }
  return Response(rendered.statusCode, body: rendered.body, headers: headers);
}
