import 'dart:io';

import 'package:arcane_lexicon/src/extensions/reading_time_extension.dart';
import 'package:arcane_lexicon/src/navigation/nav_builder.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

void main() {
  const String markdown = '''
---
title: Ignored metadata
---
# Heading

[linked text](https://example.com) **strong words** *italic words*
__bold underline__ _slanted text_.

![ignored image](image.png)
`ignored code`
''';

  test('search excerpts preserve link labels and emphasized text', () async {
    final Directory contentDirectory = await Directory.systemTemp.createTemp(
      'lexicon-markdown-text-',
    );
    addTearDown(() => contentDirectory.delete(recursive: true));
    await File('${contentDirectory.path}/index.md').writeAsString(markdown);

    final NavManifest manifest = await NavBuilder(
      contentDirectory: contentDirectory.path,
    ).build();

    expect(
      manifest.items.single.excerpt,
      'Heading linked text strong words italic words bold underline slanted text.',
    );
  });

  test('reading time counts every word in links and emphasis', () async {
    final Page page = Page(
      path: 'index.md',
      url: '/',
      content: markdown,
      config: const PageConfig(),
      loader: MemoryLoader(pages: const <MemoryPage>[]),
    );
    const List<Node> nodes = <Node>[];

    final List<Node> result = await const ReadingTimeExtension(
      wordsPerMinute: 5,
    ).apply(page, nodes);

    expect(page.data.page['wordCount'], 11);
    expect(page.data.page['readingTime'], 3);
    expect(result, same(nodes));
    expect(page.content, markdown);
  });
}
