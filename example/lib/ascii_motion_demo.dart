import 'package:arcane_jaspr/arcane_jaspr.dart';
import 'package:arcane_jaspr_ascii/arcane_jaspr_ascii.dart';
import 'package:jaspr/dom.dart' as dom;
import 'package:jaspr/jaspr.dart' show client;

@client
class AsciiMotionDemo extends StatefulWidget {
  const AsciiMotionDemo({super.key});

  @override
  State<AsciiMotionDemo> createState() => _AsciiMotionDemoState();
}

class _AsciiMotionDemoState extends State<AsciiMotionDemo> {
  bool _paused = false;
  int _replay = 0;

  @override
  Widget build(BuildContext context) => ArcaneThemeProvider(
    stylesheet: const AsciiStylesheet(),
    child: dom.section(
      <Widget>[
        const dom.p(<Widget>[
          Text('Select Ascii in the stylesheet menu to view this example.'),
        ], classes: 'lexicon-ascii-theme-hint'),
        dom.div(<Widget>[
          dom.div(
            <Widget>[
              AsciiDatum(
                label: 'Motion specimen',
                value: 'Ascii',
                animated: !_paused,
              ),
              dom.div(<Widget>[
                dom.div(<Widget>[
                  AsciiReveal(
                    animated: !_paused,
                    child: const dom.h2(<Widget>[
                      Text('Space for the words.'),
                    ], classes: 'lexicon-ascii-title'),
                  ),
                  AsciiReveal(
                    animated: !_paused,
                    delay: const Duration(milliseconds: 100),
                    child: const dom.p(<Widget>[
                      Text(
                        'Open space, fine lines, and a quiet orbit. '
                        'Labels resolve once; the page stays readable.',
                      ),
                    ], classes: 'lexicon-ascii-description'),
                  ),
                  dom.div(<Widget>[
                    AsciiText(
                      'Paper / ink / motion',
                      motion: _paused
                          ? AsciiTextMotion.none
                          : AsciiTextMotion.decode,
                      duration: const Duration(milliseconds: 850),
                    ),
                  ], classes: 'lexicon-ascii-caption'),
                ], classes: 'lexicon-ascii-copy'),
                dom.div(<Widget>[
                  AsciiOrbit(animated: !_paused),
                  const dom.span(<Widget>[
                    Text('Ascii'),
                  ], classes: 'lexicon-ascii-orbit-label'),
                ], classes: 'lexicon-ascii-orbit'),
              ], classes: 'lexicon-ascii-composition'),
            ],
            key: ValueKey<int>(_replay),
            classes: 'lexicon-ascii-stage',
            attributes: <String, String>{
              'data-ascii-motion': _paused ? 'off' : 'on',
              'data-ascii-replay': '$_replay',
            },
          ),
          dom.div(<Widget>[
            Button.outline(
              label: _paused ? 'Resume motion' : 'Pause motion',
              attributes: <String, String>{
                'aria-pressed': '$_paused',
                'data-ascii-pause': 'true',
              },
              onPressed: () => setState(() => _paused = !_paused),
            ),
            Button.ghost(
              label: 'Replay entrance',
              disabled: _paused,
              attributes: const <String, String>{
                'data-ascii-replay-control': 'true',
              },
              onPressed: () => setState(() => _replay++),
            ),
            dom.span(
              <Widget>[Text(_paused ? 'Motion paused' : 'Motion enabled')],
              attributes: const <String, String>{'role': 'status'},
              classes: 'lexicon-ascii-motion-status',
            ),
          ], classes: 'lexicon-ascii-controls'),
          const dom.p(<Widget>[
            Text('Your system’s reduced-motion preference takes priority.'),
          ], classes: 'lexicon-ascii-preference'),
        ], classes: 'lexicon-ascii-preview'),
      ],
      classes: 'lexicon-ascii-demo',
      attributes: const <String, String>{'aria-label': 'Ascii motion example'},
    ),
  );
}
