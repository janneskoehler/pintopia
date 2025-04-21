import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/wall.dart';
import '../models/pin.dart';

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

  Future<void> createPin({
    required String wallId,
    required String title,
    required String body,
    Color? color,
    String? url,
    bool urlOnly = false,
  }) async {
    final pinColor = color ?? Colors.white;
    await FirebaseFirestore.instance
        .collection('walls')
        .doc(wallId)
        .collection('pins')
        .add({
      'wallId': wallId,
      'title': title,
      'body': body,
      'color': {
        'a': pinColor.a,
        'r': pinColor.r,
        'g': pinColor.g,
        'b': pinColor.b,
      },
      'url': url,
      'urlOnly': urlOnly,
      'attachments': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
}
