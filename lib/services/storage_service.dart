import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _lastWallKey = 'last_wall_id';
  static const String _wallsKey = 'wall_ids';
  static const String _adminWallsKey = 'admin_wall_ids';

  Future<void> saveLastWallId(String wallId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWallKey, wallId);
  }

  Future<String?> getLastWallId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastWallKey);
  }

  Future<void> addWall(String wallId, {bool isAdmin = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Füge zur allgemeinen Wall-Liste hinzu
    final List<String> wallIds = await getWalls();
    if (!wallIds.contains(wallId)) {
      wallIds.add(wallId);
      await prefs.setStringList(_wallsKey, wallIds);
    }

    // Wenn es eine Admin-Wall ist, füge sie auch zur Admin-Liste hinzu
    if (isAdmin) {
      final List<String> adminWallIds = await getAdminWalls();
      if (!adminWallIds.contains(wallId)) {
        adminWallIds.add(wallId);
        await prefs.setStringList(_adminWallsKey, adminWallIds);
      }
    }
  }

  Future<List<String>> getWalls() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_wallsKey) ?? [];
  }

  Future<List<String>> getAdminWalls() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_adminWallsKey) ?? [];
  }

  Future<void> removeWall(String wallId) async {
    final prefs = await SharedPreferences.getInstance();

    // Entferne aus der allgemeinen Wall-Liste
    final List<String> wallIds = await getWalls();
    wallIds.remove(wallId);
    await prefs.setStringList(_wallsKey, wallIds);

    // Entferne auch aus der Admin-Liste
    final List<String> adminWallIds = await getAdminWalls();
    adminWallIds.remove(wallId);
    await prefs.setStringList(_adminWallsKey, adminWallIds);
  }

  Future<bool> hasWall(String wallId) async {
    final walls = await getWalls();
    return walls.contains(wallId);
  }

  Future<bool> isAdminWall(String wallId) async {
    final adminWalls = await getAdminWalls();
    return adminWalls.contains(wallId);
  }
}
