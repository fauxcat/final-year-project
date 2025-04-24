// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_year_project/screens/progress_screen.dart';

void main() {
  testWidgets('Start date selection updates state',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressScreen()));

    // Verify initial state
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);

    // Simulate tapping the start date button
    await tester.tap(find.text('Start Date'));
    await tester.pumpAndSettle();

    // Simulate selecting a date
    await tester.tap(find.text('OK')); // Assuming a date picker is shown
    await tester.pumpAndSettle();

    // Verify state is updated
    expect(find.textContaining('MMM dd, yyyy'), findsOneWidget);
  });
}
