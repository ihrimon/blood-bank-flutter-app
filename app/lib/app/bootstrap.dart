import 'package:blooddonor/app/app.dart';
import 'package:blooddonor/core/env.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared startup for every flavor. Supabase/Firebase init is added in later tasks.
void bootstrap(Flavor flavor) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: App(flavor: flavor)));
}
