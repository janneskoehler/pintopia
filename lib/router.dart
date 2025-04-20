import 'package:go_router/go_router.dart';
import 'screens/wall_list_screen.dart';
import 'screens/wall_detail_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'walls',
      builder: (context, state) => WallListScreen(),
      routes: [
        GoRoute(
          path: 'wall/:id',
          name: 'wall-detail',
          builder: (context, state) {
            final wallId = state.pathParameters['id']!;
            // TODO: Später durch echte Datenabruf ersetzen
            final wall = WallListScreen().walls.firstWhere(
                  (wall) => wall.id == wallId,
                  orElse: () => throw Exception('Wall not found'),
                );
            return WallDetailScreen(wall: wall);
          },
        ),
      ],
    ),
  ],
);
