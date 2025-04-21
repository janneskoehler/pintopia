import 'package:flutter/material.dart';
import '../models/wall.dart';
import '../widgets/add_wall_sheet.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'package:go_router/go_router.dart';

class WallListScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

  WallListScreen({super.key});

  Future<List<Wall>> _loadWalls() async {
    final wallIds = await _storageService.getWalls();
    final List<Wall> walls = [];

    for (final wallId in wallIds) {
      final wall = await _firebaseService.getWall(wallId);
      if (wall != null) {
        walls.add(wall);
      }
    }

    return walls;
  }

  void _showBoardSheet(BuildContext context) {
    AddWallSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Walls'),
      ),
      body: FutureBuilder<List<Wall>>(
        future: _loadWalls(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final walls = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.extent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 4 / 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                ...walls.map((wall) => Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          context.goNamed(
                            'wall-detail',
                            pathParameters: {'id': wall.id},
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: wall.assetImageName != null
                                  ? Image.asset(
                                      'assets/images/${wall.assetImageName}',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      wall.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                child: Center(
                                  child: Text(
                                    wall.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                // Neues Board Element -> Neue Pinnwand Element
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showBoardSheet(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            'assets/images/pinboard.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            child: Center(
                              child: Text(
                                'Pinnwand hinzufügen',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
