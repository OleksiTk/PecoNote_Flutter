import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peconote_mobile/shared/widgets/gradient_background.dart';

void main() {
  testWidgets('gradient background fills the whole page', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GradientBackground(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(height: 100),
          ),
        ),
      ),
    );

    final scaffoldSize = tester.getSize(find.byType(Scaffold));
    final backgroundStack = tester.widgetList<Stack>(find.byType(Stack)).first;
    final stackSize = tester.getSize(find.byWidget(backgroundStack));

    expect(backgroundStack.fit, StackFit.expand);
    expect(stackSize, scaffoldSize);
  });
}
