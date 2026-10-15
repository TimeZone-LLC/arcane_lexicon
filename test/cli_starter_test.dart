import 'dart:io';

import 'package:arcane_lexicon/src/cli/arcane_lexicon_cli.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late Directory output;

  setUp(() async {
    output = await Directory.systemTemp.createTemp('lexicon-starter-');
  });

  tearDown(() async {
    await output.delete(recursive: true);
  });

  test(
    'Ascii starter resolves its renderer and shared renderer source',
    () async {
      final int result = await const ArcaneLexiconCli().run(<String>[
        'create',
        'sample_docs',
        '--theme',
        'ascii',
        '--output-dir',
        output.path,
      ]);
      expect(result, 0);

      final YamlMap manifest =
          loadYaml(await File('${output.path}/pubspec.yaml').readAsString())
              as YamlMap;
      final YamlMap dependencies = manifest['dependencies'] as YamlMap;
      final YamlMap theme = dependencies['arcane_jaspr_ascii'] as YamlMap;
      expect((theme['git'] as YamlMap)['path'], 'packages/arcane_jaspr_ascii');
      final YamlMap overrides = manifest['dependency_overrides'] as YamlMap;
      final YamlMap core = overrides['arcane_jaspr'] as YamlMap;
      final YamlMap shadcn = overrides['arcane_jaspr_shadcn'] as YamlMap;
      expect((core['git'] as YamlMap)['url'], (theme['git'] as YamlMap)['url']);
      expect(
        (shadcn['git'] as YamlMap)['path'],
        'packages/arcane_jaspr_shadcn',
      );
      final String server = await File(
        '${output.path}/lib/main.server.dart',
      ).readAsString();
      expect(
        server,
        contains(
          "import 'package:arcane_jaspr_ascii/arcane_jaspr_ascii.dart';",
        ),
      );
      expect(server, contains('stylesheet: const AsciiStylesheet()'));
    },
  );

  test('default starter remains Shadcn', () async {
    final int result = await const ArcaneLexiconCli().run(<String>[
      'create',
      'sample_docs',
      '--output-dir',
      output.path,
    ]);
    expect(result, 0);
    final String server = await File(
      '${output.path}/lib/main.server.dart',
    ).readAsString();
    expect(
      server,
      contains(
        'stylesheet: const ShadcnStylesheet(theme: ShadcnTheme.midnight)',
      ),
    );
  });
}
