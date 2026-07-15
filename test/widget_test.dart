import 'package:flutter_test/flutter_test.dart';

import 'package:peconote_mobile/main.dart';

void main() {
  testWidgets('Splash screen shows the pecoNote wordmark', (tester) async {
    await tester.pumpWidget(const PecoNoteApp());

    expect(find.text('FINANCE, SOFTLY'), findsOneWidget);

    // Let the splash screen's auto-navigation timer fire so it doesn't leak
    // past the end of the test.
    await tester.pump(const Duration(milliseconds: 2300));
  });
}
