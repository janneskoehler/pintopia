import 'package:flutter/material.dart';
import '../models/pin.dart';
import '../models/attachment.dart';
import '../services/firebase_service.dart';

class WallDetailScreen extends StatelessWidget {
  final String wallId;
  final FirebaseService _firebaseService = FirebaseService();

  // Beispiel-Pins - später durch echte Daten ersetzen
  final List<Pin> pins = [
    Pin(
      id: 'p1n2m3k4j5h6g7f8d9s0',
      title: 'Erster Pin',
      body: 'Das ist der erste Pin mit einem längeren Text als Beispiel.',
      attachments: [
        Attachment(
          url: 'https://picsum.photos/800/600',
          type: AttachmentType.image,
        ),
      ],
    ),
    Pin(
      id: 'a1b2c3d4e5f6g7h8i9j0',
      title: 'Zweiter Pin',
      body: 'Ein weiterer Pin mit einem Bild.',
      attachments: [
        Attachment(
          url: 'https://picsum.photos/800/600?random=2',
          type: AttachmentType.image,
        ),
      ],
    ),
  ];

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
          ),
          body: GridView.extent(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pin.title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Neuen Pin hinzufügen
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
