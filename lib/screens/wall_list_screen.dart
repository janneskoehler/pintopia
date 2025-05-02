import 'package:flutter/material.dart';

import 'package:pintopia/models/wall.dart';
import 'package:pintopia/services/firebase_service.dart';
import 'package:pintopia/services/storage_service.dart';
import 'package:pintopia/widgets/wall/add_wall_card.dart';
import 'package:pintopia/widgets/wall/add_wall_sheet.dart';
import 'package:pintopia/widgets/wall/edit_wall_sheet.dart';
import 'package:pintopia/widgets/wall/wall_card.dart';

class WallListScreen extends StatefulWidget {
  const WallListScreen({super.key, required this.storageService});

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

  void _showWallSheet(BuildContext context) {
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
                ...walls.map(
                  (wall) => WallCard(
                    wall: wall,
                    storageService: widget.storageService,
                    isEditMode: _isEditMode,
                    onLongPress: _toggleEditMode,
                    onEditWall: _showEditWallSheet,
                  ),
                ),

                // New Wall Element
                AddWallCard(
                  onTap: _showWallSheet,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
