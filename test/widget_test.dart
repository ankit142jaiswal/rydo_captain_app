// Basic Flutter widget smoke test for the RYDO captain app.

import 'package:flutter_test/flutter_test.dart';

import 'package:rydo_captain/main.dart';

void main() {
  testWidgets('RydoCaptainApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RydoCaptainApp());

    // The splash screen shows the app name.
    expect(find.text('RYDO Captain'), findsOneWidget);
  });
}
