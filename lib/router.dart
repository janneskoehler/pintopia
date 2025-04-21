import 'package:go_router/go_router.dart';
import 'screens/wall_list_screen.dart';
import 'screens/wall_detail_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'wall-list',
      builder: (context, state) => WallListScreen(),
      routes: [
        GoRoute(
          path: 'wall/:id',
          name: 'wall-detail',
          builder: (context, state) {
            final wallId = state.pathParameters['id']!;
            return WallDetailScreen(wallId: wallId);
          },
        ),
      ],
    ),
  ],
);
