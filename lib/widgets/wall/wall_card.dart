import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pintopia/models/wall.dart';
import 'package:pintopia/services/storage_service.dart';

class WallCard extends StatelessWidget {
  final Wall wall;
  final StorageService storageService;
  final bool isEditMode;
  final VoidCallback onLongPress;
  final Function(BuildContext, Wall) onEditWall;

  const WallCard({
    super.key,
    required this.wall,
    required this.storageService,
    required this.isEditMode,
    required this.onLongPress,
    required this.onEditWall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (!isEditMode) {
            await storageService.setWallLastOpened(wall.id);
            if (context.mounted) {
              context.goNamed(
                'wall-detail',
                pathParameters: {'id': wall.id},
              );
            }
          }
        },
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: wall.assetImageName != null
                      ? Image.asset(
                          'assets/images/${wall.assetImageName}',
                          fit: BoxFit.cover,
                        )
                      : wall.imageUrl != null
                          ? Image.network(
                              wall.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                );
                              },
                            )
                          : ColoredBox(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                            ),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      wall.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (isEditMode)
              FutureBuilder<bool>(
                future: storageService.isAdminWall(wall.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data != true) {
                    return const SizedBox();
                  }

                  return Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => onEditWall(context, wall),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (!isEditMode)
              FutureBuilder<int>(
                future: wall.countNewPinsSinceLastVisit(storageService),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  if (snapshot.data! > 0) {
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          snapshot.data.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
          ],
        ),
      ),
    );
  }
}
