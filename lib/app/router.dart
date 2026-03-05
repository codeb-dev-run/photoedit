import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/editor/editor_screen.dart';
import '../features/presets/presets_screen.dart';
import '../features/batch/batch_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/editor',
        name: 'editor',
        builder: (context, state) => const EditorScreen(),
      ),
      GoRoute(
        path: '/presets',
        name: 'presets',
        builder: (context, state) => const PresetsScreen(),
      ),
      GoRoute(
        path: '/batch',
        name: 'batch',
        builder: (context, state) => const BatchScreen(),
      ),
    ],
  );
});
