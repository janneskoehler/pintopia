import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:pintopia/models/pin.dart';
import 'package:pintopia/services/firebase_service.dart';
import 'package:pintopia/services/notification_service.dart';
import 'package:pintopia/services/storage_service.dart';
import 'package:pintopia/widgets/pin/pin_card.dart';
import 'package:pintopia/widgets/pin/pin_detail_view.dart';
import 'package:pintopia/widgets/wall/share_wall_sheet.dart';

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
  State<WallDetailScreen> createState() => _WallDetailScreenState();
}

class _WallDetailScreenState extends State<WallDetailScreen> {
  bool _isEditMode = false;
  DateTime? _lastOpenedTime;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
    _loadLastOpenedTimeAndUpdateTimestamp();
  }

  Future<void> _subscribeToNotifications() async {
    await widget.notificationService.subscribeToWall(widget.wallId);
  }

  Future<void> _loadLastOpenedTimeAndUpdateTimestamp() async {
    // Read the last opening timestamp from storage
    _lastOpenedTime =
        await widget.storageService.getLastOpenedWallTime(widget.wallId);
    if (_lastOpenedTime != null) {
      widget.storageService.setWallLastOpened(widget.wallId);
    }
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
            body: const Center(
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
                        'Fehler beim Laden der Pins: ${pinsSnapshot.error}',
                      ),
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
                        ? (ReorderedListFunction<Pin> reorderedListFunction) {
                            setState(() {
                              final reorderedList = reorderedListFunction(pins);
                              final updates = <Future<void>>[];
                              for (var i = 0; i < reorderedList.length; i++) {
                                final pin = reorderedList[i];
                                if (pin.position != i) {
                                  updates.add(
                                    widget.firebaseService.updatePin(
                                      pin.copyWith(position: i),
                                    ),
                                  );
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
                      children: children,
                    ),
                    children: pins
                        .map(
                          (pin) => PinCard(
                            key: ValueKey(pin.id),
                            pin: pin,
                            isAdmin: isAdmin,
                            isEditMode: _isEditMode,
                            onLongPress: () =>
                                setState(() => _isEditMode = !_isEditMode),
                            isNew: _lastOpenedTime != null &&
                                pin.createdAt.isAfter(_lastOpenedTime!),
                          ),
                        )
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
