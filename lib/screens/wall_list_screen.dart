import 'package:flutter/material.dart';
import '../models/wall.dart';
import '../widgets/wall/add_wall_sheet.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import 'package:go_router/go_router.dart';
import '../widgets/wall/edit_wall_sheet.dart';

class WallListScreen extends StatefulWidget {
  WallListScreen({super.key, required this.storageService});

  final StorageService storageService;

  @override
  State<WallListScreen> createState() => _WallListScreenState();
}

class _WallListScreenState extends State<WallListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isEditMode = false;

  Future<List<Wall>> _loadWalls() async {
    final wallIds = await widget.storageService.getWalls();
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
    AddWallSheet.show(context, widget.storageService);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _showEditWallSheet(BuildContext context, Wall wall) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditWallSheet(
        wall: wall,
        wallId: wall.id,
        firebaseService: _firebaseService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Walls'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
            ),
        ],
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
                          if (!_isEditMode) {
                            context.goNamed(
                              'wall-detail',
                              pathParameters: {'id': wall.id},
                            );
                          }
                        },
                        onLongPress: _toggleEditMode,
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
                            if (_isEditMode)
                              FutureBuilder<bool>(
                                future:
                                    widget.storageService.isAdminWall(wall.id),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data != true) {
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
                                        onTap: () =>
                                            _showEditWallSheet(context, wall),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.edit),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                          child: Container(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.add,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
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
