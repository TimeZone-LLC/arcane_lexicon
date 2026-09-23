// ignore_for_file: avoid_print

import 'dart:io';

class ArcaneLexiconCli {
  const ArcaneLexiconCli();

  Future<int> run(List<String> args) async {
    if (args.isEmpty || _isHelp(args.first)) {
      _printUsage();
      return 0;
    }

    String command = args.first;
    List<String> rest = args.sublist(1);

    switch (command) {
      case 'create':
      case 'init':
        return _create(rest);
      case 'serve':
        return _runJaspr(<String>['serve', ..._withServeDefaults(rest)]);
      case 'build':
        return _runJaspr(<String>['build', ...rest]);
      case 'clean':
        return _runJaspr(<String>['clean', ...rest]);
      case 'doctor':
        return _doctor();
      default:
        stderr.writeln('Unknown command: $command');
        stderr.writeln('');
        _printUsage();
        return 64;
    }
  }

  void _printUsage() {
    print('''
Arcane Lexicon

Create and run markdown-powered documentation sites.

Usage:
  dart run arcane_lexicon create <project_name> [options]
  dart run arcane_lexicon serve [jaspr serve args]
  dart run arcane_lexicon build [jaspr build args]
  dart run arcane_lexicon clean [jaspr clean args]
  dart run arcane_lexicon doctor

Create options:
  --name <site name>       Human-readable site name. Defaults to title-cased project name.
  --description <text>     Site description.
  --output-dir <path>      Directory to create. Defaults to <project_name>.
  --theme <theme>          shadcn, neon, or neubrutalism. Defaults to shadcn.
  --force                  Allow writing into an existing directory.

Examples:
  dart run arcane_lexicon create my_docs
  dart run arcane_lexicon create docs --name "Acme Docs" --theme neon
  dart run arcane_lexicon serve
  dart run arcane_lexicon build --dart-define=BASE_URL=/docs
''');
  }

  Future<int> _create(List<String> args) async {
    _CreateOptions options;
    try {
      options = _CreateOptions.parse(args);
    } on _UsageException catch (error) {
      stderr.writeln(error.message);
      stderr.writeln('');
      stderr.writeln(
        'Run `dart run arcane_lexicon create --help` for create options.',
      );
      return 64;
    }

    if (options.help) {
      _printUsage();
      return 0;
    }

    Directory output = Directory(options.outputDirectory);
    if (output.existsSync() && !options.force && !_isDirectoryEmpty(output)) {
      stderr.writeln(
        'Refusing to write into a non-empty directory: ${output.path}',
      );
      stderr.writeln('Pass --force to allow merging starter files into it.');
      return 73;
    }

    _StarterWriter writer = _StarterWriter(options);
    await writer.write();

    print('Created Arcane Lexicon docs site at ${output.path}');
    print('');
    print('Next steps:');
    print('  cd ${output.path}');
    print('  dart pub get');
    print('  dart run arcane_lexicon serve');
    print('');
    print('Drop markdown files into content/ to add pages.');
    return 0;
  }

  Future<int> _runJaspr(List<String> args) async {
    int doctorExitCode = await _doctor(requireProject: true, quiet: true);
    if (doctorExitCode != 0) {
      return doctorExitCode;
    }

    Process process = await Process.start(Platform.resolvedExecutable, <String>[
      'run',
      'jaspr_cli:jaspr',
      ...args,
    ], mode: ProcessStartMode.inheritStdio);
    return process.exitCode;
  }

  Future<int> _doctor({bool requireProject = false, bool quiet = false}) async {
    List<String> errors = <String>[];
    if (!File('pubspec.yaml').existsSync()) {
      errors.add('Missing pubspec.yaml in ${Directory.current.path}');
    }
    if (!Directory('content').existsSync()) {
      errors.add(
        'Missing content/ directory. Create it or run `dart run arcane_lexicon create <name>`.',
      );
    }
    if (!File('lib/main.server.dart').existsSync()) {
      errors.add(
        'Missing lib/main.server.dart. Run `dart run arcane_lexicon create <name>` for a starter.',
      );
    }
    if (!Directory('web').existsSync() && !quiet) {
      print('web/ is missing; it will be created when the site writes assets.');
    }

    if (errors.isNotEmpty) {
      if (!quiet) {
        stderr.writeln('Arcane Lexicon project check failed:');
        for (String error in errors) {
          stderr.writeln('  - $error');
        }
      } else if (requireProject) {
        stderr.writeln('This does not look like an Arcane Lexicon project.');
        stderr.writeln('Run `dart run arcane_lexicon doctor` for details.');
      }
      return 78;
    }

    if (!quiet) {
      print('Arcane Lexicon project check passed.');
    }
    return 0;
  }

  List<String> _withServeDefaults(List<String> args) {
    List<String> next = <String>[...args];
    if (!_hasOption(next, '--port')) {
      next.addAll(<String>['--port', '8081']);
    }
    return next;
  }

  bool _hasOption(List<String> args, String option) {
    for (String arg in args) {
      if (arg == option || arg.startsWith('$option=')) {
        return true;
      }
    }
    return false;
  }

  bool _isDirectoryEmpty(Directory directory) {
    if (!directory.existsSync()) {
      return true;
    }
    return directory.listSync().isEmpty;
  }

  bool _isHelp(String value) =>
      value == '-h' || value == '--help' || value == 'help';
}

class _CreateOptions {
  final String projectName;
  final String siteName;
  final String description;
  final String outputDirectory;
  final _StarterTheme theme;
  final bool force;
  final bool help;

  const _CreateOptions({
    required this.projectName,
    required this.siteName,
    required this.description,
    required this.outputDirectory,
    required this.theme,
    required this.force,
    required this.help,
  });

  static _CreateOptions parse(List<String> args) {
    if (args.any((String arg) => arg == '-h' || arg == '--help')) {
      return const _CreateOptions(
        projectName: 'docs',
        siteName: 'Docs',
        description: 'Documentation powered by Arcane Lexicon.',
        outputDirectory: 'docs',
        theme: _StarterTheme.shadcn,
        force: false,
        help: true,
      );
    }

    String? projectName;
    String? siteName;
    String? description;
    String? outputDirectory;
    _StarterTheme theme = _StarterTheme.shadcn;
    bool force = false;

    for (int i = 0; i < args.length; i++) {
      String arg = args[i];
      if (arg == '--force') {
        force = true;
      } else if (arg == '--name') {
        siteName = _readValue(args, ++i, '--name');
      } else if (arg.startsWith('--name=')) {
        siteName = arg.substring('--name='.length);
      } else if (arg == '--description') {
        description = _readValue(args, ++i, '--description');
      } else if (arg.startsWith('--description=')) {
        description = arg.substring('--description='.length);
      } else if (arg == '--output-dir') {
        outputDirectory = _readValue(args, ++i, '--output-dir');
      } else if (arg.startsWith('--output-dir=')) {
        outputDirectory = arg.substring('--output-dir='.length);
      } else if (arg == '--theme') {
        theme = _StarterTheme.parse(_readValue(args, ++i, '--theme'));
      } else if (arg.startsWith('--theme=')) {
        theme = _StarterTheme.parse(arg.substring('--theme='.length));
      } else if (arg.startsWith('-')) {
        throw _UsageException('Unknown create option: $arg');
      } else if (projectName == null) {
        projectName = arg;
      } else {
        throw _UsageException('Unexpected argument: $arg');
      }
    }

    projectName ??= 'docs';
    if (!_isValidPackageName(projectName)) {
      throw const _UsageException(
        'Project name must be lower snake_case, for example `my_docs`.',
      );
    }

    return _CreateOptions(
      projectName: projectName,
      siteName: siteName?.trim().isNotEmpty == true
          ? siteName!.trim()
          : _titleCase(projectName),
      description: description?.trim().isNotEmpty == true
          ? description!.trim()
          : 'Documentation powered by Arcane Lexicon.',
      outputDirectory: outputDirectory?.trim().isNotEmpty == true
          ? outputDirectory!.trim()
          : projectName,
      theme: theme,
      force: force,
      help: false,
    );
  }

  static String _readValue(List<String> args, int index, String option) {
    if (index >= args.length || args[index].startsWith('-')) {
      throw _UsageException('Missing value for $option.');
    }
    return args[index];
  }

  static bool _isValidPackageName(String value) =>
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value) && !value.endsWith('_');

  static String _titleCase(String value) => value
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _UsageException implements Exception {
  final String message;

  const _UsageException(this.message);
}

enum _StarterTheme {
  shadcn,
  neon,
  neubrutalism;

  static _StarterTheme parse(String value) {
    switch (value.toLowerCase()) {
      case 'shadcn':
      case 'shadcn.midnight':
        return _StarterTheme.shadcn;
      case 'neon':
      case 'neon.green':
        return _StarterTheme.neon;
      case 'neubrutalism':
      case 'neubrutalism.yellow':
        return _StarterTheme.neubrutalism;
      default:
        throw _UsageException(
          'Unknown theme `$value`. Use shadcn, neon, or neubrutalism.',
        );
    }
  }

  String get packageName {
    switch (this) {
      case _StarterTheme.shadcn:
        return 'arcane_jaspr_shadcn';
      case _StarterTheme.neon:
        return 'arcane_jaspr_neon';
      case _StarterTheme.neubrutalism:
        return 'arcane_jaspr_neubrutalism';
    }
  }

  String get importPath => 'package:$packageName/$packageName.dart';

  String get stylesheetExpression {
    switch (this) {
      case _StarterTheme.shadcn:
        return 'ShadcnStylesheet(theme: ShadcnTheme.midnight)';
      case _StarterTheme.neon:
        return 'NeonStylesheet(theme: NeonTheme.green)';
      case _StarterTheme.neubrutalism:
        return 'NeubrutalismStylesheet(theme: NeubrutalismTheme.yellow)';
    }
  }

  String get gitPath {
    switch (this) {
      case _StarterTheme.shadcn:
        return 'packages/arcane_jaspr_shadcn';
      case _StarterTheme.neon:
        return 'packages/arcane_jaspr_neon';
      case _StarterTheme.neubrutalism:
        return 'packages/arcane_jaspr_neubrutalism';
    }
  }
}

class _StarterWriter {
  final _CreateOptions options;

  const _StarterWriter(this.options);

  Future<void> write() async {
    Directory root = Directory(options.outputDirectory);
    await root.create(recursive: true);
    await Directory('${root.path}/lib').create(recursive: true);
    await Directory('${root.path}/content/guide').create(recursive: true);
    await Directory('${root.path}/web').create(recursive: true);

    await _writeFile('${root.path}/pubspec.yaml', _pubspec());
    await _writeFile('${root.path}/jaspr_options.yaml', _jasprOptions());
    await _writeFile('${root.path}/lib/main.server.dart', _mainServer());
    await _writeFile('${root.path}/lib/main.client.dart', _mainClient());
    await _writeFile('${root.path}/content/index.md', _indexPage());
    await _writeFile(
      '${root.path}/content/guide/_section.json5',
      _guideSection(),
    );
    await _writeFile(
      '${root.path}/content/guide/getting-started.md',
      _gettingStartedPage(),
    );
    await _writeFile('${root.path}/web/styles.css', _styles());
  }

  Future<void> _writeFile(String path, String content) async {
    File file = File(path);
    if (file.existsSync() && !options.force) {
      return;
    }
    await file.writeAsString(content);
  }

  String _pubspec() {
    String themePackage = options.theme.packageName;
    String themePath = options.theme.gitPath;
    return '''name: ${options.projectName}
description: ${_yamlSingleQuote(options.description)}
version: 0.1.0
publish_to: 'none'

environment:
  sdk: ^3.10.0

dependencies:
  jaspr: ^0.23.1
  jaspr_content: ^0.5.2
  arcane_lexicon:
    git:
      url: https://github.com/ArcaneArts/arcane_lexicon.git
  $themePackage:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git
      path: $themePath

dev_dependencies:
  build_runner: ^2.15.0
  build_web_compilers: ^4.8.0
  jaspr_builder: ^0.23.1
  jaspr_cli: ^0.23.1
  lints: ^6.1.0

jaspr:
  mode: static
  port: 8081

dependency_overrides:
  arcane_jaspr:
    git:
      url: https://github.com/ArcaneArts/arcane_jaspr.git

scripts:
  serve: dart run arcane_lexicon serve
  build: dart run arcane_lexicon build
  clean: dart run arcane_lexicon clean
''';
  }

  String _jasprOptions() => '''targets:
  \$default:
    auto_apply_builders: false
    builders:
      jaspr_builder|jaspr_web_builder:
        enabled: true
      jaspr_builder|jaspr_server_builder:
        enabled: true
      jaspr_builder|jaspr_styles_builder:
        enabled: false
      jaspr_builder|jaspr_router_builder:
        enabled: false
''';

  String _mainServer() {
    String siteNameLiteral = _dartString(options.siteName);
    String descriptionLiteral = _dartString(options.description);
    return '''import '${options.theme.importPath}';
import 'package:arcane_lexicon/arcane_lexicon.dart' hide runApp;
import 'package:jaspr/server.dart';

Future<void> main() async {
  Jaspr.initializeApp();

  runApp(
    await KnowledgeBaseApp.create(
      config: const SiteConfig(
        name: $siteNameLiteral,
        description: $descriptionLiteral,
        contentDirectory: 'content',
      ),
      stylesheet: const ${options.theme.stylesheetExpression},
    ),
  );
}
''';
  }

  String _mainClient() => '''import 'package:jaspr/client.dart';

void main() {
  Jaspr.initializeApp();
  runApp(const ClientApp());
}
''';

  String _indexPage() =>
      '''---
title: ${_yamlSingleQuote(options.siteName)}
description: ${_yamlSingleQuote(options.description)}
order: 0
---

# ${options.siteName}

Welcome to your Arcane Lexicon documentation site.

Add markdown files under `content/` and they become pages automatically.

## Start here

- Edit this page at `content/index.md`.
- Add pages under `content/guide/`.
- Customize sections with `_section.json5` files.
''';

  String _guideSection() => '''{
  title: 'Guide',
  icon: 'book-open',
  order: 1,
  collapsed: false,
}
''';

  String _gettingStartedPage() => '''---
title: Getting Started
description: Your first Arcane Lexicon page
icon: rocket
order: 1
tags:
  - setup
---

# Getting Started

This page lives at `content/guide/getting-started.md`.

## Add pages

Create more markdown files in this folder. Arcane Lexicon will add them to the sidebar automatically.

## Add folders

Create a folder with its own `_section.json5` file to make a nested section.
''';

  String _styles() => ''':root {
  --font-sans: ui-sans-serif, system-ui, sans-serif;
  --font-heading: var(--font-sans);
  --font-mono: ui-monospace, 'SFMono-Regular', 'Cascadia Code', monospace;
}

*, *::before, *::after {
  box-sizing: border-box;
}

html {
  min-height: 100%;
  font-family: var(--font-sans);
  scroll-behavior: smooth;
  background: var(--background);
  color: var(--foreground);
}

body {
  min-height: 100vh;
  margin: 0;
  background: var(--background);
  color: var(--foreground);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

img, svg, video, canvas {
  max-width: 100%;
}

button, input, select, textarea {
  font: inherit;
}
''';

  String _yamlSingleQuote(String value) => "'${value.replaceAll("'", "''")}'";

  String _dartString(String value) =>
      "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$').replaceAll('\n', r'\n').replaceAll('\r', r'\r')}'";
}
