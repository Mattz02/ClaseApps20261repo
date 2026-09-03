// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:calculator/main.dart';

void main() {
  testWidgets('calculates an expression', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('8'));
    await tester.tap(find.text('×'));
    await tester.tap(find.text('7'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('56'), findsOneWidget);
  });

  testWidgets('calls out division by zero', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('8'));
    await tester.tap(find.text('÷'));
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('You are stupid'), findsOneWidget);
  });
}
