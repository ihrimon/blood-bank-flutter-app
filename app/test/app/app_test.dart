import 'package:blooddonor/app/app.dart';
import 'package:blooddonor/core/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts in Bangla on Home and toggles language', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(flavor: Flavor.prod)),
    );
    await tester.pumpAndSettle();

    expect(find.text('হোম'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();
    expect(find.text('হোম'), findsOneWidget);
  });
}
