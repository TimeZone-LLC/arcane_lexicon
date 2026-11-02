import 'package:jaspr_content/jaspr_content.dart';

/// A PageExtension that calculates reading time for pages.
///
/// Adds a 'readingTime' field to page data with the estimated reading time in minutes.
/// The calculation is based on an average reading speed of 200 words per minute.
class ReadingTimeExtension implements PageExtension {
  /// Average words per minute for reading time calculation.
  final int wordsPerMinute;

  const ReadingTimeExtension({this.wordsPerMinute = 200});

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    final String content = page.content;

    // Remove frontmatter
    String text = content;
    if (text.startsWith('---')) {
      final int endIndex = text.indexOf('---', 3);
      if (endIndex > 0) {
        text = text.substring(endIndex + 3);
      }
    }

    // Remove markdown formatting for more accurate word count
    text = text
        // Remove code blocks
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        // Remove inline code
        .replaceAll(RegExp(r'`[^`]+`'), '')
        // Remove images
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '')
        // Remove links (keep text)
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (Match match) => match.group(1)!,
        )
        // Remove headers markers
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        // Remove bold/italic markers
        .replaceAllMapped(
          RegExp(r'[*_]{1,2}([^*_]+)[*_]{1,2}'),
          (Match match) => match.group(1)!,
        )
        // Remove HTML tags
        .replaceAll(RegExp(r'<[^>]+>'), '');

    // Count words
    final List<String> words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final int wordCount = words.length;

    // Calculate reading time (minimum 1 minute)
    final int readingTime = (wordCount / wordsPerMinute).ceil();
    final int finalTime = readingTime < 1 ? 1 : readingTime;

    // Add to page data
    page.apply(
      data: {
        'page': {'readingTime': finalTime, 'wordCount': wordCount},
      },
    );

    return nodes;
  }
}
