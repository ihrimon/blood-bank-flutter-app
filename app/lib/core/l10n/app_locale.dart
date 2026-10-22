import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_locale.g.dart';

const bnLocale = Locale('bn');
const enLocale = Locale('en');

/// Current UI language. Bangla by default; not persisted yet.
@riverpod
class AppLocale extends _$AppLocale {
  @override
  Locale build() => bnLocale;

  void toggle() => state = state == bnLocale ? enLocale : bnLocale;
}
