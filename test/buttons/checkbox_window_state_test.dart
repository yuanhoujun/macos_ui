import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final windowState in <bool?>[null, true, false]) {
      for (final value in <bool?>[true, null, false]) {
        for (final enabled in [true, false]) {
          testWidgets(
            'checkbox $brightness window=$windowState value=$value enabled=$enabled',
            (tester) async {
              await tester.pumpWidget(
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: MacosTheme(
                    data: MacosThemeData(
                      brightness: brightness,
                      isMainWindow: windowState,
                    ),
                    child: Center(
                      child: MacosCheckbox(
                        value: value,
                        onChanged: enabled ? (_) {} : null,
                      ),
                    ),
                  ),
                ),
              );

              final icon = tester.widget<Icon>(find.byType(Icon));
              expect(
                icon.icon,
                value == false
                    ? null
                    : value == null
                    ? CupertinoIcons.minus
                    : CupertinoIcons.checkmark,
              );
              final active = windowState ?? true;
              expect(
                icon.color,
                !enabled
                    ? const MacosColor.fromRGBO(172, 172, 172, 1)
                    : brightness == Brightness.light && !active
                    ? MacosColors.black
                    : MacosColors.white,
              );

              // The white inset belongs only to unchecked/inactive/disabled
              // light controls, never over the active accent fill and glyph.
              final whiteInsets = tester
                  .widgetList<DecoratedBox>(
                    find.descendant(
                      of: find.byType(MacosCheckbox),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .where((box) {
                    final decoration = box.decoration;
                    return decoration is BoxDecoration &&
                        (decoration.boxShadow ?? []).any(
                          (shadow) =>
                              shadow.color == CupertinoColors.white ||
                              shadow.color ==
                                  const MacosColor.fromRGBO(255, 255, 255, 0.8),
                        );
                  });
              final needsInset =
                  brightness == Brightness.light &&
                  !(value != false && active && enabled);
              expect(whiteInsets.length, needsInset ? 1 : 0);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
