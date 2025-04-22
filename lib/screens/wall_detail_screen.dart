import 'package:flutter/material.dart';
import '../models/pin.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../widgets/wall/share_wall_sheet.dart';
import '../widgets/pin/create_pin_sheet.dart';
import '../widgets/pin/pin_card.dart';

class WallDetailScreen extends StatelessWidget {
  final String wallId;
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

  WallDetailScreen({
    super.key,
    required this.wallId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseService.getWall(wallId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Fehler beim Laden: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final wall = snapshot.data;
        if (wall == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Wall nicht gefunden'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(wall.title),
            actions: [
              FutureBuilder<bool>(
                future: _storageService.isAdminWall(wallId),
                builder: (context, isAdminSnapshot) {
                  if (isAdminSnapshot.hasData && isAdminSnapshot.data == true) {
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) =>
                                  CreatePinSheet(wallId: wallId),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => ShareWallSheet(wall: wall),
                            );
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: StreamBuilder<List<Pin>>(
            stream: _firebaseService.getPinsStream(wallId),
            builder: (context, pinsSnapshot) {
              return FutureBuilder<bool>(
                future: _storageService.isAdminWall(wallId),
                builder: (context, isAdminSnapshot) {
                  if (pinsSnapshot.hasError) {
                    return Center(
                      child: Text(
                          'Fehler beim Laden der Pins: ${pinsSnapshot.error}'),
                    );
                  }

                  if (!pinsSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final pins = pinsSnapshot.data!;
                  final isAdmin = isAdminSnapshot.data ?? false;

                  if (pins.isEmpty) {
                    return const Center(
                      child: Text(
                        'Keine Pins vorhanden',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return GridView.extent(
                    maxCrossAxisExtent: 300,
                    padding: const EdgeInsets.all(8.0),
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                    children: pins
                        .map((pin) => PinCard(
                              pin: pin,
                              isAdmin: isAdmin,
                            ))
                        .toList(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
