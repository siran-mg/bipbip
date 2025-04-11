import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ndao/core/infrastructure/database/database_helper_web.dart';

/// Helper class for SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static DatabaseHelperWeb? _webDatabase;
  static final bool _isWeb = kIsWeb;

  /// Factory constructor
  factory DatabaseHelper() => _instance;

  /// Private constructor
  DatabaseHelper._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_isWeb) {
      throw UnsupportedError(
          'SQLite database is not supported on web. Use web-specific methods instead.');
    }

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Get web database instance
  DatabaseHelperWeb get webDatabase {
    if (!_isWeb) {
      throw UnsupportedError('Web database is only supported on web platform.');
    }

    _webDatabase ??= DatabaseHelperWeb();
    return _webDatabase!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    if (_isWeb) {
      throw UnsupportedError('SQLite database is not supported on web.');
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ndao.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Favorite drivers cache table
    await db.execute('''
      CREATE TABLE favorite_drivers_cache (
        client_id TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        driver_data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (client_id, driver_id)
      )
    ''');

    // Favorite status cache table
    await db.execute('''
      CREATE TABLE favorite_status_cache (
        client_id TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        is_favorite INTEGER NOT NULL,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (client_id, driver_id)
      )
    ''');

    // Cache metadata table for tracking last update times
    await db.execute('''
      CREATE TABLE cache_metadata (
        cache_key TEXT PRIMARY KEY,
        last_updated TEXT NOT NULL
      )
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
    if (oldVersion < 2) {
      // Migration code for version 2
    }
  }

  /// Clear all cache data
  Future<void> clearAllCache() async {
    if (_isWeb) {
      await webDatabase.clearAll();
    } else {
      final db = await database;
      await db.delete('favorite_drivers_cache');
      await db.delete('favorite_status_cache');
      await db.delete('cache_metadata');
    }
  }
}
