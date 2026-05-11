import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_tracker/main.dart';
import 'package:football_tracker/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const FootballTrackerApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
