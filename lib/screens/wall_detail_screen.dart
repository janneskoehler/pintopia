import 'package:flutter/material.dart';
import '../models/pin.dart';
import '../models/attachment.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../widgets/share_wall_sheet.dart';
import '../widgets/create_pin_sheet.dart';

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
              if (pinsSnapshot.hasError) {
                return Center(
                  child:
                      Text('Fehler beim Laden der Pins: ${pinsSnapshot.error}'),
                );
              }

              if (!pinsSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final pins = pinsSnapshot.data!;

              if (pins.isEmpty) {
                return const Center(
                  child: Text(
                    'Keine Pins vorhanden',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return GridView.extent(
                maxCrossAxisExtent: 600,
                padding: const EdgeInsets.all(8.0),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.8,
                children: pins
                    .map((pin) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (pin.attachments.isNotEmpty &&
                                  pin.attachments.first.type ==
                                      AttachmentType.image)
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    pin.attachments.first.url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pin.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          pin.body,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        );
      },
    );
  }
}
