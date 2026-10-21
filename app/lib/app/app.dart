import 'package:blooddonor/core/env.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const new({required this.flavor, super.key});

  final Flavor flavor;

  // Placeholder; theme, router and l10n arrive in S0-T3.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: flavor == Flavor.staging,
      home: const Scaffold(),
    );
  }
}
