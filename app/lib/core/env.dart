/// Build flavor, chosen by the entrypoint (`main_staging.dart` / `main_prod.dart`).
enum Flavor { staging, prod }

/// Build-time config from `--dart-define-from-file`. Never commit values.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
}
