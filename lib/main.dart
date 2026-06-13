import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/wakeon_app.dart';

/// Application entry point.
void main() {
  // Ensure Flutter bindings are available before app initialization.
  WidgetsFlutterBinding.ensureInitialized();

  // Expose Riverpod dependencies to the entire widget tree.
  runApp(const ProviderScope(child: WakeonApp()));
}
