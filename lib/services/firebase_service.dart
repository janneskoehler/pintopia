import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wall.dart';
import '../models/pin.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Wall> createWall(String title, String assetImageName) async {
    final docRef = _firestore.collection('walls').doc();

    final wall = Wall(
      id: docRef.id,
      title: title,
      imageUrl: '', // Empty, since we use asset images
      assetImageName: assetImageName,
      adminCode: Wall.generateAdminCode(),
    );

    await docRef.set(wall.toJson());
    return wall;
  }

  Future<Wall?> getWall(String id) async {
    final doc = await _firestore.collection('walls').doc(id).get();
    if (!doc.exists) return null;
    return Wall.fromJson(doc.data()!);
  }

  Stream<List<Wall>> getWalls() {
    return _firestore.collection('walls').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Wall.fromJson(doc.data())).toList());
  }

  Future<void> updateWall(
      String id, String title, String assetImageName) async {
    final wallRef = _firestore.collection('walls').doc(id);

    await wallRef.update({
      'title': title,
      'assetImageName': assetImageName,
    });
  }

  Future<void> deleteWall(String id) async {
    await _firestore.collection('walls').doc(id).delete();
  }

  Stream<List<Pin>> getPinsStream(String wallId) {
    return FirebaseFirestore.instance
        .collection('walls')
        .doc(wallId)
        .collection('pins')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pin.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> createPin(Pin pin) async {
    try {
      await FirebaseFirestore.instance
          .collection('walls')
          .doc(pin.wallId)
          .collection('pins')
          .add(pin.toJson());
    } catch (e) {
      throw Exception('Fehler beim Erstellen des Pins: $e');
    }
  }

  Future<void> updatePin(Pin pin) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('walls')
          .doc(pin.wallId)
          .collection('pins')
          .doc(pin.id);

      await docRef.update(pin.toJson());
    } catch (e) {
      throw Exception('Failed to update pin: $e');
    }
  }

  Stream<Pin> getPinStream(String wallId, String pinId) {
    return FirebaseFirestore.instance
        .collection('walls')
        .doc(wallId)
        .collection('pins')
        .doc(pinId)
        .snapshots()
        .map((doc) => Pin.fromJson(doc.data()!));
  }

  Future<void> deletePin(Pin pin) async {
    try {
      await FirebaseFirestore.instance
          .collection('walls')
          .doc(pin.wallId)
          .collection('pins')
          .doc(pin.id)
          .delete();
    } catch (e) {
      throw Exception('Fehler beim Löschen des Pins: $e');
    }
  }
}
