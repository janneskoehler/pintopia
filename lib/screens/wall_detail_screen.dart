import 'package:flutter/material.dart';
import '../models/pin.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../widgets/wall/share_wall_sheet.dart';
import '../widgets/pin/pin_card.dart';
import '../widgets/pin/pin_detail_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import '../services/notification_service.dart';

class WallDetailScreen extends StatefulWidget {
  final String wallId;
  final FirebaseService firebaseService = FirebaseService();
  final StorageService storageService;
  final NotificationService notificationService;

  WallDetailScreen({
    super.key,
    required this.wallId,
    required this.notificationService,
    required this.storageService,
  });

  @override
  _WallDetailScreenState createState() => _WallDetailScreenState();
}

class _WallDetailScreenState extends State<WallDetailScreen> {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
  }

  Future<void> _subscribeToNotifications() async {
    await widget.notificationService.subscribeToWall(widget.wallId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.firebaseService.getWall(widget.wallId),
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
                future: widget.storageService.isAdminWall(widget.wallId),
                builder: (context, isAdminSnapshot) {
                  if (isAdminSnapshot.hasData && isAdminSnapshot.data == true) {
                    return Row(
                      children: [
                        if (!_isEditMode) ...[
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _createNewPin,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    ShareWallSheet(wall: wall),
                              );
                            },
                          ),
                        ],
                        if (_isEditMode)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _isEditMode = false;
                              });
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
            stream: widget.firebaseService.getPinsStream(widget.wallId),
            builder: (context, pinsSnapshot) {
              return FutureBuilder<bool>(
                future: widget.storageService.isAdminWall(widget.wallId),
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

                  final pins = pinsSnapshot.data!
                    ..sort((a, b) => a.position.compareTo(b.position));
                  final isAdmin = isAdminSnapshot.data ?? false;

                  if (pins.isEmpty) {
                    return const Center(
                      child: Text(
                        'Keine Pins vorhanden',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ReorderableBuilder(
                    enableDraggable: _isEditMode && isAdmin,
                    onReorder: _isEditMode
                        ? (ReorderedListFunction reorderedListFunction) {
                            setState(() {
                              final reorderedList = reorderedListFunction(pins);
                              final updates = <Future<void>>[];
                              for (var i = 0; i < reorderedList.length; i++) {
                                final pin = reorderedList[i];
                                if (pin.position != i) {
                                  updates.add(widget.firebaseService.updatePin(
                                    pin.copyWith(position: i),
                                  ));
                                }
                              }
                              Future.wait(updates);
                            });
                          }
                        : null,
                    enableLongPress: false,
                    builder: (children) => GridView.extent(
                      maxCrossAxisExtent: 300,
                      padding: const EdgeInsets.all(8.0),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                      children: children,
                    ),
                    children: pins
                        .map((pin) => PinCard(
                              key: ValueKey(pin.id),
                              pin: pin,
                              isAdmin: isAdmin,
                              isEditMode: _isEditMode,
                              onLongPress: () =>
                                  setState(() => _isEditMode = true),
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

  void _createNewPin() {
    final newPinRef = FirebaseFirestore.instance.collection('pins').doc();
    final now = DateTime.now();

    final newPin = Pin(
      id: newPinRef.id,
      wallId: widget.wallId,
      title: '',
      body: '',
      color: Pin.getRandomColor(),
      createdAt: now,
      updatedAt: now,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PinDetailView(
          pin: newPin,
          isAdmin: true,
          initialEditMode: true,
        ),
      ),
    );
  }
}
