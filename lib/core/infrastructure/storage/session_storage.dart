import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving session data
class SessionStorage {
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'user_id';

  /// Save session data
  Future<void> saveSession(String sessionId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setString(_userIdKey, userId);
  }

  /// Get stored session ID
  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Clear session data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_userIdKey);
  }

  /// Check if a session exists
  Future<bool> hasSession() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }
}
