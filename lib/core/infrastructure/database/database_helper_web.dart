import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for database operations on web platform using SharedPreferences
class DatabaseHelperWeb {
  static final DatabaseHelperWeb _instance = DatabaseHelperWeb._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Factory constructor
  factory DatabaseHelperWeb() => _instance;

  /// Private constructor
  DatabaseHelperWeb._internal();

  /// Initialize the database
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// Insert data into a table
  Future<int> insert(String table, Map<String, dynamic> values,
      {String? conflictAlgorithm}) async {
    await init();
    final key = '${table}_${values['client_id']}_${values['driver_id']}';
    await _prefs.setString(key, jsonEncode(values));
    return 1;
  }

  /// Query data from a table
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    await init();
    final result = <Map<String, dynamic>>[];

    // Get all keys for this table
    final allKeys =
        _prefs.getKeys().where((key) => key.startsWith('${table}_'));

    if (where != null && whereArgs != null) {
      // Parse the where clause
      if (where.contains('client_id = ?')) {
        final clientId = whereArgs[0];
        final filteredKeys = allKeys.where((key) => key.contains('_$clientId'));

        if (where.contains('driver_id = ?')) {
          // Filter by both client_id and driver_id
          final driverId = whereArgs[1];
          final matchingKeys =
              filteredKeys.where((key) => key.endsWith('_$driverId'));

          for (final key in matchingKeys) {
            final value = _prefs.getString(key);
            if (value != null) {
              result.add(jsonDecode(value));
            }
          }
        } else {
          // Filter by client_id only
          for (final key in filteredKeys) {
            final value = _prefs.getString(key);
            if (value != null) {
              result.add(jsonDecode(value));
            }
          }
        }
      } else if (where.contains('cache_key = ?')) {
        // Handle cache_metadata queries
        final cacheKey = whereArgs[0];
        final key = '${table}_$cacheKey';
        final value = _prefs.getString(key);
        if (value != null) {
          result.add(jsonDecode(value));
        }
      }
    } else {
      // Return all entries for this table
      for (final key in allKeys) {
        final value = _prefs.getString(key);
        if (value != null) {
          result.add(jsonDecode(value));
        }
      }
    }

    return result;
  }

  /// Delete data from a table
  Future<int> delete(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    await init();
    int count = 0;

    if (where != null && whereArgs != null) {
      // Parse the where clause
      if (where.contains('client_id = ?')) {
        final clientId = whereArgs[0];
        final keysToRemove = <String>[];

        // Get all keys for this table and client
        final allKeys = _prefs.getKeys();
        final filteredKeys = allKeys.where(
            (key) => key.startsWith('${table}_') && key.contains('_$clientId'));

        if (where.contains('driver_id = ?')) {
          // Filter by both client_id and driver_id
          final driverId = whereArgs[1];
          keysToRemove
              .addAll(filteredKeys.where((key) => key.endsWith('_$driverId')));
        } else {
          // Filter by client_id only
          keysToRemove.addAll(filteredKeys);
        }

        // Remove all matching keys
        for (final key in keysToRemove) {
          await _prefs.remove(key);
          count++;
        }
      } else if (where.contains('cache_key = ?')) {
        // Handle cache_metadata queries
        final cacheKey = whereArgs[0];
        final key = '${table}_$cacheKey';
        if (_prefs.containsKey(key)) {
          await _prefs.remove(key);
          count++;
        }
      }
    } else {
      // Remove all entries for this table
      final keysToRemove =
          _prefs.getKeys().where((key) => key.startsWith('${table}_'));
      for (final key in keysToRemove) {
        await _prefs.remove(key);
        count++;
      }
    }

    return count;
  }

  /// Create a batch operation
  WebBatch batch() {
    return WebBatch(_prefs);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
  }
}

/// Batch operations for web
class WebBatch {
  final SharedPreferences _prefs;
  final List<Map<String, dynamic>> _operations = [];

  WebBatch(this._prefs);

  /// Add an insert operation to the batch
  void insert(String table, Map<String, dynamic> values,
      {String? conflictAlgorithm}) {
    _operations.add({
      'type': 'insert',
      'table': table,
      'values': values,
    });
  }

  /// Execute all operations in the batch
  Future<List<dynamic>> commit({bool? noResult}) async {
    final results = <dynamic>[];

    for (final op in _operations) {
      if (op['type'] == 'insert') {
        final table = op['table'];
        final values = op['values'];
        final key = '${table}_${values['client_id']}';

        if (values.containsKey('driver_id')) {
          // For favorite_drivers_cache and favorite_status_cache
          await _prefs.setString(
              '${key}_${values['driver_id']}', jsonEncode(values));
        } else if (values.containsKey('cache_key')) {
          // For cache_metadata
          await _prefs.setString(
              '${table}_${values['cache_key']}', jsonEncode(values));
        } else {
          // Generic case
          await _prefs.setString(
              '${key}_${DateTime.now().millisecondsSinceEpoch}',
              jsonEncode(values));
        }

        if (noResult != true) {
          results.add(1);
        }
      }
    }

    _operations.clear();
    return results;
  }
}
