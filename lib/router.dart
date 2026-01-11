import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Start app directly on the dashboard (login removed)
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/dashboard/:deviceId',
        builder: (context, state) => DashboardScreen(deviceId: state.params['deviceId']),
      ),
    ],
  );
});
