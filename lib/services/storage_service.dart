import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'logger_service.dart';

class StorageServiceException implements Exception {
  final String message;
  final String? details;

  StorageServiceException({
    required this.message,
    this.details,
  });

  @override
  String toString() => 'StorageServiceException: $message\nDetails: $details';
}

class StorageService {
  static const String _lastWallKey = 'last_wall_id';
  static const String _wallsKey = 'wall_ids';
  static const String _adminWallsKey = 'admin_wall_ids';

  final SharedPreferences _prefs;
  final Logger _logger = LoggerService.getLogger();

  StorageService(this._prefs);

  Future<T> _handleSharedPreferencesOperation<T>(
    Future<T> Function() operation, {
    String operationName = 'SharedPreferences operation',
  }) async {
    try {
      return await operation();
    } catch (e) {
      _logger.e('Failed $operationName: $e');
      throw StorageServiceException(
        message: 'Error occurred during $operationName',
        details: e.toString(),
      );
    }
  }

  Future<List<String>> getWalls() async {
    return _handleSharedPreferencesOperation(
      () async => _prefs.getStringList(_wallsKey) ?? [],
      operationName: 'get walls',
    );
  }

  Future<List<String>> getAdminWalls() async {
    return _handleSharedPreferencesOperation(
      () async => _prefs.getStringList(_adminWallsKey) ?? [],
      operationName: 'get admin walls',
    );
  }

  Future<bool> isAdminWall(String wallId) async {
    final adminWalls = await getAdminWalls();
    return adminWalls.contains(wallId);
  }

  Future<void> saveLastWallId(String wallId) async {
    await _handleSharedPreferencesOperation(
      () async => _prefs.setString(_lastWallKey, wallId),
      operationName: 'save last wall ID',
    );
  }

  Future<String?> getLastWallId() async {
    return _prefs.getString(_lastWallKey);
  }

  Future<void> addWall(String wallId, {bool isAdmin = false}) async {
    await _handleSharedPreferencesOperation(
      () async {
        // Add to general wall list
        final List<String> wallIds = await getWalls();
        if (!wallIds.contains(wallId)) {
          wallIds.add(wallId);
          await _prefs.setStringList(_wallsKey, wallIds);
        }

        // If it's an admin wall, add it to the admin list as well
        if (isAdmin) {
          final List<String> adminWallIds = await getAdminWalls();
          if (!adminWallIds.contains(wallId)) {
            adminWallIds.add(wallId);
            await _prefs.setStringList(_adminWallsKey, adminWallIds);
          }
        }
      },
      operationName: 'add wall',
    );
  }

  Future<void> removeWall(String wallId) async {
    // Remove from the general wall list
    final List<String> wallIds = await getWalls();
    wallIds.remove(wallId);
    await _prefs.setStringList(_wallsKey, wallIds);

    // Also remove from the admin list
    final List<String> adminWallIds = await getAdminWalls();
    adminWallIds.remove(wallId);
    await _prefs.setStringList(_adminWallsKey, adminWallIds);
  }

  Future<bool> hasWall(String wallId) async {
    final walls = await getWalls();
    return walls.contains(wallId);
  }
}
