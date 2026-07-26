import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:peconote_mobile/app/peco_note_app.dart';
import 'package:peconote_mobile/features/startup/application/controllers/startup_controller.dart';
import 'package:peconote_mobile/features/startup/application/providers/startup_providers.dart';

void main() {
  testWidgets('Splash screen shows the pecoNote wordmark', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupControllerProvider.overrideWith(
            (ref) => Completer<StartupDestination>().future,
          ),
        ],
        child: const PecoNoteApp(),
      ),
    );

    expect(find.text('FINANCE, SOFTLY'), findsOneWidget);
  });
}
