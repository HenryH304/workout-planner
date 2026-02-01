// Basic Flutter widget test for Workout Planner app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workout_planner/main.dart';

void main() {
  testWidgets('App launches and shows Today screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app launches with the Today screen
    expect(find.text('Today'), findsAtLeastNWidgets(1));

    // Verify bottom navigation is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify workout type header is shown
    expect(find.text('Push Day'), findsOneWidget);
  });
}
