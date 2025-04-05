import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initializes and provides Appwrite clients
class AppwriteClientInitializer {
  static final AppwriteClientInitializer _instance =
      AppwriteClientInitializer._internal();

  /// Singleton instance of AppwriteClientInitializer
  static AppwriteClientInitializer get instance => _instance;

  /// Appwrite client for general API access
  late final Client client;

  /// Appwrite account client for authentication
  late final Account account;

  /// Appwrite databases client for data storage
  late final Databases databases;

  /// Appwrite storage client for file storage
  late final Storage storage;

  /// Appwrite realtime client for realtime updates
  late final Realtime realtime;

  /// Private constructor
  AppwriteClientInitializer._internal();

  /// Initialize Appwrite clients
  Future<void> initialize() async {
    try {
      // Get Appwrite configuration from environment variables
      final endpoint =
          dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
      final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
      final databaseId = dotenv.env['APPWRITE_DATABASE_ID'] ?? 'ndao';

      print('Initializing Appwrite with:');
      print('Endpoint: $endpoint');
      print('Project ID: $projectId');
      print('Database ID: $databaseId');

      // Initialize the main client
      client = Client()
        ..setEndpoint(endpoint)
        ..setProject(projectId)
        ..setSelfSigned(status: true); // Remove in production

      // Initialize service clients
      account = Account(client);
      databases = Databases(client);
      storage = Storage(client);
      realtime = Realtime(client);

      print('Appwrite clients initialized successfully');

      // Print a reminder about database setup
      print(
          'Make sure you have created the following in your Appwrite console:');
      print('1. Database with ID: "$databaseId"');
      print(
          '2. Collections: "${dotenv.env['APPWRITE_USERS_COLLECTION_ID'] ?? 'users'}", "${dotenv.env['APPWRITE_USER_ROLES_COLLECTION_ID'] ?? 'user_roles'}", etc.');
      print(
          '3. Storage bucket with ID: "${dotenv.env['APPWRITE_PROFILE_PHOTOS_BUCKET_ID'] ?? 'profile_photos'}"');
    } catch (e) {
      print('Error initializing Appwrite: $e');
      rethrow;
    }
  }
}
