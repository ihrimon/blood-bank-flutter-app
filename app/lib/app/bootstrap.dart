import 'package:blooddonor/app/app.dart';
import 'package:blooddonor/core/env.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared startup for every flavor. Firebase init is added in a later task.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
  runApp(ProviderScope(child: App(flavor: flavor)));
}
