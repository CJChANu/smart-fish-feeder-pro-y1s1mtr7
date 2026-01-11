// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_fish_feeder_pro/main.dart';

void main() {
  testWidgets('App shows dashboard and Feed button', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    await tester.pump();

    // Verify AppBar is present (app shows dashboard).
    expect(find.byType(AppBar), findsOneWidget);

    // Verify "FEED NOW" button exists on the dashboard
    expect(find.text('FEED NOW'), findsOneWidget);
  });
}
