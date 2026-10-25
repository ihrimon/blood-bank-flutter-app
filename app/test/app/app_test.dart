import 'package:blooddonor/app/app.dart';
import 'package:blooddonor/core/env.dart';
import 'package:blooddonor/core/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('starts in Bangla on Home and toggles language', (tester) async {
    final client = SupabaseClient(
      'http://localhost',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(client),
        ],
        child: const App(flavor: Flavor.prod),
      ),
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
