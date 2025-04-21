import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wall.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Wall> createWall(String title, String assetImageName) async {
    final docRef = _firestore.collection('walls').doc();

    final wall = Wall(
      id: docRef.id,
      title: title,
      imageUrl: '', // Leer, da wir Asset-Bilder verwenden
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
}
