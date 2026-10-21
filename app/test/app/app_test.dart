import 'package:blooddonor/app/app.dart';
import 'package:blooddonor/core/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds for staging', (tester) async {
    await tester.pumpWidget(const App(flavor: Flavor.staging));
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
