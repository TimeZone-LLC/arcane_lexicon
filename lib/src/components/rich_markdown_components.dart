import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr/html.dart' show ArcaneDiv, ArcaneLink;
import 'package:arcane_lexicon/src/icons/kb_icon.dart';
import 'package:jaspr_content/components/tabs.dart';
import 'package:jaspr_content/jaspr_content.dart';

class KBRichMarkdownComponents {
  const KBRichMarkdownComponents._();

  static List<CustomComponent> defaults() {
    return <CustomComponent>[
      const KBCardGroupComponent(),
      const KBCardComponent(),
      const KBColumnsComponent(),
      const KBColumnComponent(),
      const KBTilesComponent(),
      const KBTileComponent(),
      const KBStepsComponent(),
      const KBStepComponent(),
      const KBAccordionGroupComponent(),
      const KBAccordionComponent(),
      const KBExpandableComponent(),
      const KBBadgeComponent(),
      const KBBannerComponent(),
      const KBPanelComponent(),
      const KBFrameComponent(),
      const KBUpdateComponent(),
      const KBTooltipComponent(),
      const KBIconComponent(),
      const KBKbdComponent(),
      const KBPathComponent(),
      const KBEndpointComponent(),
      const KBResourceGridComponent(),
      const KBResourceComponent(),
      const KBCodeGroupComponent(),
      const KBFieldGroupComponent(),
      const KBParamFieldComponent(),
      const KBResponseFieldComponent(),
      const KBTreeComponent(),
      const KBTreeFolderComponent(),
      const KBTreeFileComponent(),
      const KBColorComponent(),
      const KBColorItemComponent(),
      const KBViewComponent(),
      const KBCalloutTagComponent(),
      const Tabs(),
    ];
  }
}

class KBCardGroupComponent extends CustomComponentBase {
  const KBCardGroupComponent();

  @override
  Pattern get pattern => RegExp(r'^CardGroup$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-card-group'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBCardComponent extends CustomComponentBase {
  const KBCardComponent();

  @override
  Pattern get pattern => RegExp(r'^Card$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Card';
    String href = attributes['href']?.trim() ?? '#';
    String? iconName = attributes['icon']?.trim();
    bool hasIcon = iconName != null && iconName.isNotEmpty;
    bool external = _KBRichParsers.isExternalLink(href);
    String classes = external
        ? 'kb-card kb-card-external'
        : 'kb-card kb-card-internal';

    Widget cardContent = ArcaneDiv(
      classes: <String>[
        'kb-card-content',
        if (!hasIcon) 'kb-card-content-no-icon',
      ],
      children: <Widget>[
        if (hasIcon)
          ArcaneDiv(
            classes: <String>['kb-card-icon'],
            children: <Widget>[KBIcon.build(iconName, size: IconSize.md)],
          ),
        ArcaneDiv(
          classes: <String>['kb-card-copy'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-card-title'],
              children: <Widget>[Text(title)],
            ),
            ArcaneDiv(
              classes: <String>['kb-card-body'],
              children: <Widget>[
                child ?? const ArcaneDiv(children: <Widget>[]),
              ],
            ),
          ],
        ),
      ],
    );

    if (external) {
      return ArcaneLink.external(
        href: href,
        classes: <String>[classes],
        child: cardContent,
      );
    }

    return ArcaneLink(
      href: href,
      classes: <String>[classes],
      child: cardContent,
    );
  }
}

class KBColumnsComponent extends CustomComponentBase {
  const KBColumnsComponent();

  @override
  Pattern get pattern => RegExp(r'^Columns$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    int cols = _KBRichParsers.toBoundedInt(attributes['cols'], 2, 1, 4);
    return ArcaneDiv(
      classes: <String>['kb-columns kb-columns-$cols'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBColumnComponent extends CustomComponentBase {
  const KBColumnComponent();

  @override
  Pattern get pattern => RegExp(r'^Column$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-column'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBTilesComponent extends CustomComponentBase {
  const KBTilesComponent();

  @override
  Pattern get pattern => RegExp(r'^Tiles$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-tiles'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBTileComponent extends CustomComponentBase {
  const KBTileComponent();

  @override
  Pattern get pattern => RegExp(r'^Tile$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Tile';
    String href = attributes['href']?.trim() ?? '';
    String? iconName = attributes['icon']?.trim();
    bool hasIcon = iconName != null && iconName.isNotEmpty;
    bool hasHref = href.isNotEmpty;
    bool external = _KBRichParsers.isExternalLink(href);
    String classes = hasHref
        ? (external
              ? 'kb-tile kb-tile-link kb-tile-external'
              : 'kb-tile kb-tile-link kb-tile-internal')
        : 'kb-tile kb-tile-static';

    Widget tileContent = ArcaneDiv(
      classes: <String>[
        'kb-tile-content',
        if (!hasIcon) 'kb-tile-content-no-icon',
      ],
      children: <Widget>[
        if (hasIcon)
          ArcaneDiv(
            classes: <String>['kb-tile-icon'],
            children: <Widget>[KBIcon.build(iconName, size: IconSize.md)],
          ),
        ArcaneDiv(
          classes: <String>['kb-tile-copy'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-tile-title'],
              children: <Widget>[Text(title)],
            ),
            ArcaneDiv(
              classes: <String>['kb-tile-body'],
              children: <Widget>[
                child ?? const ArcaneDiv(children: <Widget>[]),
              ],
            ),
          ],
        ),
      ],
    );

    if (!hasHref) {
      return ArcaneDiv(
        classes: <String>[classes],
        children: <Widget>[tileContent],
      );
    }

    if (external) {
      return ArcaneLink.external(
        href: href,
        classes: <String>[classes],
        child: tileContent,
      );
    }

    return ArcaneLink(
      href: href,
      classes: <String>[classes],
      child: tileContent,
    );
  }
}

class KBAccordionGroupComponent extends CustomComponentBase {
  const KBAccordionGroupComponent();

  @override
  Pattern get pattern => RegExp(r'^AccordionGroup$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-accordion-group'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBStepsComponent extends CustomComponentBase {
  const KBStepsComponent();

  @override
  Pattern get pattern => RegExp(r'^Steps$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-steps'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBStepComponent extends CustomComponentBase {
  const KBStepComponent();

  @override
  Pattern get pattern => RegExp(r'^Step$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Step';
    return ArcaneDiv(
      classes: <String>['kb-step'],
      children: <Widget>[
        const ArcaneDiv(
          classes: <String>['kb-step-marker'],
          children: <Widget>[],
        ),
        ArcaneDiv(
          classes: <String>['kb-step-main'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-step-title'],
              children: <Widget>[Text(title)],
            ),
            ArcaneDiv(
              classes: <String>['kb-step-body'],
              children: <Widget>[
                child ?? const ArcaneDiv(children: <Widget>[]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class KBAccordionComponent extends CustomComponentBase {
  const KBAccordionComponent();

  @override
  Pattern get pattern => RegExp(r'^Accordion$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Section';
    bool defaultOpen =
        _KBRichParsers.toBool(
          _KBRichParsers.attribute(attributes, 'defaultOpen'),
        ) ||
        _KBRichParsers.toBool(_KBRichParsers.attribute(attributes, 'open'));
    return Widget.element(
      tag: 'details',
      classes: 'kb-accordion',
      attributes: defaultOpen
          ? <String, String>{'open': ''}
          : const <String, String>{},
      children: <Widget>[
        Widget.element(
          tag: 'summary',
          classes: 'kb-accordion-summary',
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-accordion-title'],
              children: <Widget>[Text(title)],
            ),
            ArcaneDiv(
              classes: <String>['kb-accordion-chevron'],
              children: <Widget>[
                KBIcon.build('chevron-down', size: IconSize.sm),
              ],
            ),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-accordion-content'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }
}

class KBExpandableComponent extends CustomComponentBase {
  const KBExpandableComponent();

  @override
  Pattern get pattern => RegExp(r'^Expandable$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Details';
    bool defaultOpen = _KBRichParsers.toBool(
      _KBRichParsers.attribute(attributes, 'defaultOpen'),
    );
    return Widget.element(
      tag: 'details',
      classes: 'kb-expandable',
      attributes: defaultOpen
          ? <String, String>{'open': ''}
          : const <String, String>{},
      children: <Widget>[
        Widget.element(
          tag: 'summary',
          classes: 'kb-expandable-summary',
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-expandable-title'],
              children: <Widget>[Text(title)],
            ),
            ArcaneDiv(
              classes: <String>['kb-expandable-chevron'],
              children: <Widget>[
                KBIcon.build('chevron-down', size: IconSize.sm),
              ],
            ),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-expandable-content'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }
}

class KBBadgeComponent extends CustomComponentBase {
  const KBBadgeComponent();

  @override
  Pattern get pattern => RegExp(r'^Badge$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String color = attributes['color']?.trim().toLowerCase() ?? 'default';
    String classes = 'kb-badge kb-badge-$color';
    return ArcaneDiv(
      classes: <String>[classes],
      children: <Widget>[child ?? const Text('Badge')],
    );
  }
}

class KBBannerComponent extends CustomComponentBase {
  const KBBannerComponent();

  @override
  Pattern get pattern => RegExp(r'^Banner$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Notice';
    String tone = attributes['type']?.trim().toLowerCase() ?? 'info';
    String iconName = attributes['icon']?.trim() ?? _defaultIconForTone(tone);
    String href = attributes['href']?.trim() ?? '';
    bool external = _KBRichParsers.isExternalLink(href);

    Widget inner = ArcaneDiv(
      classes: <String>['kb-banner-inner'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-banner-leading'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-banner-icon'],
              children: <Widget>[KBIcon.build(iconName, size: IconSize.sm)],
            ),
            ArcaneDiv(
              classes: <String>['kb-banner-title'],
              children: <Widget>[Text(title)],
            ),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-banner-body'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );

    String classes = 'kb-banner kb-banner-$tone';

    if (href.isEmpty) {
      return ArcaneDiv(classes: <String>[classes], children: <Widget>[inner]);
    }

    if (external) {
      return ArcaneLink.external(
        href: href,
        classes: <String>[classes],
        child: inner,
      );
    }

    return ArcaneLink(href: href, classes: <String>[classes], child: inner);
  }

  String _defaultIconForTone(String tone) {
    return switch (tone) {
      'success' => 'check-circle',
      'warning' => 'triangle-alert',
      'danger' => 'octagon-alert',
      _ => 'info',
    };
  }
}

class KBPanelComponent extends CustomComponentBase {
  const KBPanelComponent();

  @override
  Pattern get pattern => RegExp(r'^Panel$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? '';
    String? iconName = attributes['icon']?.trim();
    if (iconName?.isEmpty ?? false) {
      iconName = null;
    }
    return ArcaneDiv(
      classes: <String>['kb-panel'],
      children: <Widget>[
        if (title.isNotEmpty)
          ArcaneDiv(
            classes: <String>['kb-panel-title'],
            children: <Widget>[
              if (iconName != null)
                ArcaneDiv(
                  classes: <String>['kb-panel-icon'],
                  children: <Widget>[KBIcon.build(iconName, size: IconSize.sm)],
                ),
              Text(title),
            ],
          ),
        ArcaneDiv(
          classes: <String>['kb-panel-content'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }
}

class KBFrameComponent extends CustomComponentBase {
  const KBFrameComponent();

  @override
  Pattern get pattern => RegExp(r'^Frame$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String caption = attributes['caption']?.trim() ?? '';
    String label = attributes['label']?.trim() ?? '';
    return ArcaneDiv(
      classes: <String>['kb-frame'],
      children: <Widget>[
        if (label.isNotEmpty)
          ArcaneDiv(
            classes: <String>['kb-frame-label'],
            children: <Widget>[Text(label)],
          ),
        ArcaneDiv(
          classes: <String>['kb-frame-body'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
        if (caption.isNotEmpty)
          ArcaneDiv(
            classes: <String>['kb-frame-caption'],
            children: <Widget>[Text(caption)],
          ),
      ],
    );
  }
}

class KBUpdateComponent extends CustomComponentBase {
  const KBUpdateComponent();

  @override
  Pattern get pattern => RegExp(r'^Update$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String label = attributes['label']?.trim() ?? 'Updated';
    String date = attributes['date']?.trim() ?? '';
    return ArcaneDiv(
      classes: <String>['kb-update'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-update-head'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-update-icon'],
              children: <Widget>[KBIcon.build('clock', size: IconSize.sm)],
            ),
            ArcaneDiv(
              classes: <String>['kb-update-label'],
              children: <Widget>[Text(label)],
            ),
            if (date.isNotEmpty)
              ArcaneDiv(
                classes: <String>['kb-update-date'],
                children: <Widget>[Text(date)],
              ),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-update-body'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }
}

class KBTooltipComponent extends CustomComponentBase {
  const KBTooltipComponent();

  @override
  Pattern get pattern => RegExp(r'^Tooltip$', caseSensitive: false);

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String tip = attributes['tip']?.trim() ?? attributes['text']?.trim() ?? '';
    String classes = tip.isEmpty ? 'kb-tooltip' : 'kb-tooltip kb-tooltip-ready';
    Map<String, String> attrs = tip.isEmpty
        ? const <String, String>{}
        : <String, String>{'title': tip, 'data-tip': tip};
    return Widget.element(
      tag: 'span',
      classes: classes,
      attributes: attrs,
      children: <Widget>[child ?? const Text('Info')],
    );
  }
}

class KBIconComponent extends CustomComponentBase {
  const KBIconComponent();

  @override
  Pattern get pattern => RegExp(r'^Icon$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String? iconName = attributes['name']?.trim() ?? attributes['icon']?.trim();
    if (iconName == null || iconName.isEmpty) {
      return const ArcaneDiv(children: <Widget>[]);
    }
    IconSize size = _KBRichParsers.toIconSize(attributes['size']);
    return ArcaneDiv(
      classes: <String>['kb-inline-icon'],
      children: <Widget>[KBIcon.build(iconName, size: size)],
    );
  }
}

class KBKbdComponent extends CustomComponentBase {
  const KBKbdComponent();

  @override
  Pattern get pattern => RegExp(r'^(Kbd|Key)$', caseSensitive: false);

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String label =
        attributes['key']?.trim() ??
        attributes['label']?.trim() ??
        _KBRichParsers.componentText(child).trim();
    return Widget.element(
      tag: 'kbd',
      classes: 'kb-kbd',
      children: <Widget>[Text(label.isEmpty ? 'key' : label)],
    );
  }
}

class KBPathComponent extends CustomComponentBase {
  const KBPathComponent();

  @override
  Pattern get pattern => RegExp(r'^FilePath$', caseSensitive: false);

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String value =
        attributes['value']?.trim() ??
        attributes['path']?.trim() ??
        _KBRichParsers.componentText(child).trim();
    String iconName = attributes['icon']?.trim() ?? 'file-text';
    return Widget.element(
      tag: 'code',
      classes: 'kb-path',
      children: <Widget>[
        Widget.element(
          tag: 'span',
          classes: 'kb-path-icon',
          children: <Widget>[KBIcon.build(iconName, size: IconSize.xs)],
        ),
        Text(value.isEmpty ? './path' : value),
      ],
    );
  }
}

class KBEndpointComponent extends CustomComponentBase {
  const KBEndpointComponent();

  @override
  Pattern get pattern => RegExp(r'^Endpoint$', caseSensitive: false);

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String method = (attributes['method']?.trim() ?? 'GET').toUpperCase();
    String path =
        attributes['path']?.trim() ??
        attributes['url']?.trim() ??
        _KBRichParsers.componentText(child).trim();
    return ArcaneDiv(
      classes: <String>['kb-endpoint kb-endpoint-${method.toLowerCase()}'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-endpoint-method'],
          children: <Widget>[Text(method)],
        ),
        ArcaneDiv(
          classes: <String>['kb-endpoint-path'],
          children: <Widget>[Text(path.isEmpty ? '/' : path)],
        ),
      ],
    );
  }
}

class KBResourceGridComponent extends CustomComponentBase {
  const KBResourceGridComponent();

  @override
  Pattern get pattern => RegExp(r'^ResourceGrid$', caseSensitive: false);

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-resource-grid'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBResourceComponent extends CustomComponentBase {
  const KBResourceComponent();

  @override
  Pattern get pattern => RegExp(r'^Resource$', caseSensitive: false);

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? 'Resource';
    String href = attributes['href']?.trim() ?? '';
    String iconName = attributes['icon']?.trim() ?? 'book-open';
    String label = attributes['label']?.trim() ?? '';
    bool external = _KBRichParsers.isExternalLink(href);
    Widget content = ArcaneDiv(
      classes: <String>['kb-resource-content'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-resource-icon'],
          children: <Widget>[KBIcon.build(iconName, size: IconSize.sm)],
        ),
        ArcaneDiv(
          classes: <String>['kb-resource-copy'],
          children: <Widget>[
            if (label.isNotEmpty)
              ArcaneDiv(
                classes: <String>['kb-resource-label'],
                children: <Widget>[Text(label)],
              ),
            ArcaneDiv(
              classes: <String>['kb-resource-title'],
              children: <Widget>[Text(title)],
            ),
            ArcaneDiv(
              classes: <String>['kb-resource-body'],
              children: <Widget>[
                child ?? const ArcaneDiv(children: <Widget>[]),
              ],
            ),
          ],
        ),
      ],
    );
    String classes = href.isEmpty
        ? 'kb-resource kb-resource-static'
        : 'kb-resource kb-resource-link';

    if (href.isEmpty) {
      return ArcaneDiv(classes: <String>[classes], children: <Widget>[content]);
    }
    if (external) {
      return ArcaneLink.external(
        href: href,
        classes: <String>[classes],
        child: content,
      );
    }
    return ArcaneLink(href: href, classes: <String>[classes], child: content);
  }
}

class KBCodeGroupComponent extends CustomComponentBase {
  const KBCodeGroupComponent();

  @override
  Pattern get pattern => RegExp(r'^CodeGroup$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title = attributes['title']?.trim() ?? '';
    String rawChildText = _KBRichParsers.componentText(child);
    List<_KBFencedCodeBlock> codeBlocks = _KBRichParsers.parseFencedCodeBlocks(
      rawChildText,
    );
    List<Widget> bodyChildren = codeBlocks.isNotEmpty
        ? codeBlocks.map(_buildCodeBlock).toList()
        : <Widget>[child ?? const ArcaneDiv(children: <Widget>[])];

    return ArcaneDiv(
      classes: <String>['kb-code-group'],
      children: <Widget>[
        if (title.isNotEmpty)
          ArcaneDiv(
            classes: <String>['kb-code-group-title'],
            children: <Widget>[Text(title)],
          ),
        ArcaneDiv(
          classes: <String>['kb-code-group-body'],
          children: bodyChildren,
        ),
      ],
    );
  }

  Widget _buildCodeBlock(_KBFencedCodeBlock block) {
    String normalizedLanguage = _KBRichParsers.normalizeCodeLanguage(
      block.language,
    );
    String codeClass = normalizedLanguage.isEmpty
        ? ''
        : 'language-$normalizedLanguage';
    return Widget.element(
      tag: 'pre',
      children: <Widget>[
        Widget.element(
          tag: 'code',
          classes: codeClass.isEmpty ? null : codeClass,
          children: <Widget>[Widget.text(block.code)],
        ),
      ],
    );
  }
}

class KBFieldGroupComponent extends CustomComponentBase {
  const KBFieldGroupComponent();

  @override
  Pattern get pattern => RegExp(r'^FieldGroup$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-field-group'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBParamFieldComponent extends CustomComponentBase {
  const KBParamFieldComponent();

  @override
  Pattern get pattern => RegExp(r'^ParamField$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String location = _resolveParamLocation(attributes);
    String paramName = _resolveParamName(attributes, location);
    String type = attributes['type']?.trim() ?? 'string';
    bool required = _KBRichParsers.toBool(attributes['required']);
    return ArcaneDiv(
      classes: <String>['kb-field kb-param-field'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-field-head'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-field-name'],
              children: <Widget>[Text(paramName)],
            ),
            ArcaneDiv(
              classes: <String>['kb-field-badge kb-field-location'],
              children: <Widget>[Text(location)],
            ),
            ArcaneDiv(
              classes: <String>['kb-field-type'],
              children: <Widget>[Text(type)],
            ),
            if (required)
              const ArcaneDiv(
                classes: <String>['kb-field-badge kb-field-required'],
                children: <Widget>[Text('required')],
              ),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-field-body'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }

  String _resolveParamLocation(Map<String, String> attributes) {
    if (attributes.containsKey('path')) {
      return 'path';
    }
    if (attributes.containsKey('body')) {
      return 'body';
    }
    if (attributes.containsKey('header')) {
      return 'header';
    }
    if (attributes.containsKey('query')) {
      return 'query';
    }
    return attributes['in']?.trim() ?? 'query';
  }

  String _resolveParamName(Map<String, String> attributes, String location) {
    String name = attributes[location]?.trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }
    String fallback = attributes['name']?.trim() ?? '';
    return fallback.isEmpty ? 'field' : fallback;
  }
}

class KBResponseFieldComponent extends CustomComponentBase {
  const KBResponseFieldComponent();

  @override
  Pattern get pattern => RegExp(r'^ResponseField$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String fieldName = attributes['name']?.trim() ?? 'field';
    String type = attributes['type']?.trim() ?? 'string';
    bool required = _KBRichParsers.toBool(attributes['required']);
    return ArcaneDiv(
      classes: <String>['kb-field kb-response-field'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-field-head'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-field-name'],
              children: <Widget>[Text(fieldName)],
            ),
            ArcaneDiv(
              classes: <String>['kb-field-type'],
              children: <Widget>[Text(type)],
            ),
            if (required)
              const ArcaneDiv(
                classes: <String>['kb-field-badge kb-field-required'],
                children: <Widget>[Text('required')],
              ),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-field-body'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }
}

class KBTreeComponent extends CustomComponentBase {
  const KBTreeComponent();

  @override
  Pattern get pattern => RegExp(r'^Tree$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return Widget.element(
      tag: 'ul',
      classes: 'kb-tree',
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBTreeFolderComponent extends CustomComponentBase {
  const KBTreeFolderComponent();

  @override
  Pattern get pattern => RegExp(r'^Tree\.Folder$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String label = attributes['name']?.trim() ?? 'folder';
    bool defaultOpen = _KBRichParsers.toBool(
      _KBRichParsers.attribute(attributes, 'defaultOpen'),
    );
    return Widget.element(
      tag: 'li',
      classes: 'kb-tree-item kb-tree-folder',
      children: <Widget>[
        Widget.element(
          tag: 'details',
          classes: 'kb-tree-folder-details',
          attributes: defaultOpen
              ? <String, String>{'open': ''}
              : const <String, String>{},
          children: <Widget>[
            Widget.element(
              tag: 'summary',
              classes: 'kb-tree-folder-summary',
              children: <Widget>[
                ArcaneDiv(
                  classes: <String>['kb-tree-folder-label'],
                  children: <Widget>[Text(label)],
                ),
                ArcaneDiv(
                  classes: <String>['kb-tree-folder-chevron'],
                  children: <Widget>[
                    KBIcon.build('chevron-down', size: IconSize.sm),
                  ],
                ),
              ],
            ),
            Widget.element(
              tag: 'ul',
              classes: 'kb-tree-branch',
              children: <Widget>[
                child ?? const ArcaneDiv(children: <Widget>[]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class KBTreeFileComponent extends CustomComponentBase {
  const KBTreeFileComponent();

  @override
  Pattern get pattern => RegExp(r'^Tree\.File$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String label =
        attributes['name']?.trim() ?? attributes['label']?.trim() ?? 'file';
    return Widget.element(
      tag: 'li',
      classes: 'kb-tree-item kb-tree-file',
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-tree-file-row'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-tree-file-icon'],
              children: <Widget>[KBIcon.build('file-text', size: IconSize.sm)],
            ),
            ArcaneDiv(
              classes: <String>['kb-tree-file-label'],
              children: <Widget>[Text(label)],
            ),
          ],
        ),
        if (child != null)
          ArcaneDiv(
            classes: <String>['kb-tree-file-extra'],
            children: <Widget>[child],
          ),
      ],
    );
  }
}

class KBColorComponent extends CustomComponentBase {
  const KBColorComponent();

  @override
  Pattern get pattern => RegExp(r'^Color$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    return ArcaneDiv(
      classes: <String>['kb-color-grid'],
      children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
    );
  }
}

class KBColorItemComponent extends CustomComponentBase {
  const KBColorItemComponent();

  @override
  Pattern get pattern => RegExp(r'^Color\.Item$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String value =
        attributes['value']?.trim() ?? attributes['hex']?.trim() ?? '#6b7280';
    String label =
        attributes['label']?.trim() ?? attributes['name']?.trim() ?? value;
    return ArcaneDiv(
      classes: <String>['kb-color-item'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-color-swatch'],
          styles: ArcaneStyleData(backgroundCustom: value),
          children: <Widget>[],
        ),
        ArcaneDiv(
          classes: <String>['kb-color-meta'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-color-label'],
              children: <Widget>[Text(label)],
            ),
            ArcaneDiv(
              classes: <String>['kb-color-value'],
              children: <Widget>[Text(value)],
            ),
            if (child != null)
              ArcaneDiv(
                classes: <String>['kb-color-extra'],
                children: <Widget>[child],
              ),
          ],
        ),
      ],
    );
  }
}

class KBViewComponent extends CustomComponentBase {
  const KBViewComponent();

  @override
  Pattern get pattern => RegExp(r'^View$');

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String title =
        attributes['title']?.trim() ?? attributes['name']?.trim() ?? 'View';
    String? iconName = attributes['icon']?.trim();
    bool hasIcon = iconName != null && iconName.isNotEmpty;
    return ArcaneDiv(
      classes: <String>['kb-view'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-view-title'],
          children: <Widget>[
            if (hasIcon)
              ArcaneDiv(
                classes: <String>['kb-view-icon'],
                children: <Widget>[KBIcon.build(iconName, size: IconSize.sm)],
              ),
            Text(title),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-view-body'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }
}

class KBCalloutTagComponent extends CustomComponentBase {
  const KBCalloutTagComponent();

  @override
  Pattern get pattern => RegExp(
    r'^(Note|Tip|Warning|Info|Check|Caution|Important)$',
    caseSensitive: false,
  );

  @override
  Widget apply(String name, Map<String, String> attributes, Widget? child) {
    String normalized = name.toLowerCase();
    String calloutType = switch (normalized) {
      'info' => 'note',
      'check' => 'tip',
      _ => normalized,
    };
    String title = attributes['title']?.trim() ?? _toTitle(name);
    title = _sanitizeTitle(title, calloutType);
    return ArcaneDiv(
      classes: <String>['kb-callout kb-callout-$calloutType'],
      children: <Widget>[
        ArcaneDiv(
          classes: <String>['kb-callout-title'],
          children: <Widget>[
            ArcaneDiv(
              classes: <String>['kb-callout-icon'],
              children: <Widget>[_buildIcon(calloutType)],
            ),
            Text(title),
          ],
        ),
        ArcaneDiv(
          classes: <String>['kb-callout-content'],
          children: <Widget>[child ?? const ArcaneDiv(children: <Widget>[])],
        ),
      ],
    );
  }

  String _toTitle(String value) {
    if (value.isEmpty) {
      return 'Note';
    }
    return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
  }

  String _sanitizeTitle(String title, String calloutType) {
    RegExp markerPrefixPattern = RegExp(
      r'^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*',
      caseSensitive: false,
    );
    String cleaned = title.replaceFirst(markerPrefixPattern, '').trim();
    if (cleaned.isEmpty) {
      return _toTitle(calloutType);
    }
    return cleaned;
  }

  Widget _buildIcon(String calloutType) {
    return switch (calloutType) {
      'tip' => KBIcon.build('tip', size: IconSize.sm),
      'important' => KBIcon.build('important', size: IconSize.sm),
      'warning' => KBIcon.build('warning', size: IconSize.sm),
      'caution' => KBIcon.build('caution', size: IconSize.sm),
      _ => KBIcon.build('note', size: IconSize.sm),
    };
  }
}

class _KBRichParsers {
  const _KBRichParsers._();

  static String? attribute(Map<String, String> attributes, String key) {
    String? direct = attributes[key];
    if (direct != null) {
      return direct;
    }
    String lowered = key.toLowerCase();
    for (MapEntry<String, String> entry in attributes.entries) {
      if (entry.key.toLowerCase() == lowered) {
        return entry.value;
      }
    }
    return null;
  }

  static String componentText(Widget? component) {
    if (component == null) {
      return '';
    }
    if (component is Text) {
      return component.data;
    }
    dynamic dynamicWidget = component;
    try {
      dynamic textValue = dynamicWidget.text;
      if (textValue is String) {
        return textValue;
      }
    } catch (_) {}
    try {
      dynamic childrenValue = dynamicWidget.children;
      if (childrenValue is List) {
        StringBuffer buffer = StringBuffer();
        for (dynamic child in childrenValue) {
          if (child is Widget) {
            buffer.write(componentText(child));
          } else if (child is String) {
            buffer.write(child);
          }
        }
        return buffer.toString();
      }
    } catch (_) {}
    return '';
  }

  static List<_KBFencedCodeBlock> parseFencedCodeBlocks(String rawContent) {
    List<_KBFencedCodeBlock> blocks = <_KBFencedCodeBlock>[];
    RegExp fencePattern = RegExp(
      r'```([^\r\n`]*)\r?\n([\s\S]*?)```',
      multiLine: true,
    );
    for (Match match in fencePattern.allMatches(rawContent)) {
      String language = (match.group(1) ?? '').trim();
      String code = match.group(2) ?? '';
      while (code.endsWith('\n') || code.endsWith('\r')) {
        code = code.substring(0, code.length - 1);
      }
      blocks.add(_KBFencedCodeBlock(language: language, code: code));
    }
    return blocks;
  }

  static String normalizeCodeLanguage(String language) {
    String value = language.trim().toLowerCase();
    if (value.isEmpty) {
      return '';
    }
    if (value == 'js') {
      return 'javascript';
    }
    if (value == 'shell' || value == 'sh') {
      return 'bash';
    }
    return value;
  }

  static bool toBool(String? rawValue) {
    if (rawValue == null) {
      return false;
    }
    String value = rawValue
        .replaceAll(RegExp(r'[{}]'), '')
        .trim()
        .toLowerCase();
    return value == 'true' || value == '1' || value == 'yes' || value.isEmpty;
  }

  static int toBoundedInt(String? rawValue, int fallback, int min, int max) {
    String raw = rawValue ?? '';
    String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    int parsed = int.tryParse(digits) ?? fallback;
    if (parsed < min) {
      return min;
    }
    if (parsed > max) {
      return max;
    }
    return parsed;
  }

  static bool isExternalLink(String href) {
    return href.startsWith('http://') ||
        href.startsWith('https://') ||
        href.startsWith('mailto:') ||
        href.startsWith('//');
  }

  static IconSize toIconSize(String? rawValue) {
    String value = rawValue?.trim().toLowerCase() ?? 'md';
    return switch (value) {
      'xs' => IconSize.xs,
      'sm' => IconSize.sm,
      'lg' => IconSize.lg,
      'xl' => IconSize.xl,
      'xl2' => IconSize.xl2,
      _ => IconSize.md,
    };
  }
}

class _KBFencedCodeBlock {
  final String language;
  final String code;

  const _KBFencedCodeBlock({required this.language, required this.code});
}
