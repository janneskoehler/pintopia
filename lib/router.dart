import 'package:go_router/go_router.dart';
import 'screens/wall_list_screen.dart';
import 'screens/wall_detail_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

GoRouter getRouter(
    NotificationService notificationService, StorageService storageService) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'wall-list',
        builder: (context, state) => WallListScreen(
          storageService: storageService,
        ),
        routes: [
          GoRoute(
            path: 'wall/:id',
            name: 'wall-detail',
            builder: (context, state) {
              final wallId = state.pathParameters['id']!;
              return WallDetailScreen(
                wallId: wallId,
                notificationService: notificationService,
                storageService: storageService,
              );
            },
          ),
        ],
      ),
    ],
  );
}
