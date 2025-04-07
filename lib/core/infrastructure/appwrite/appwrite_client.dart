import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initializes and provides Appwrite clients
class AppwriteClientInitializer {
  static final AppwriteClientInitializer _instance =
      AppwriteClientInitializer._internal();

  /// Singleton instance of AppwriteClientInitializer
  static AppwriteClientInitializer get instance => _instance;

  /// Appwrite client for general API access
  late final Client client;

  /// Appwrite client with API key for server-side operations
  late final Client serverClient;

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
      final apiKey = dotenv.env['APPWRITE_API_KEY'] ?? '';

      debugPrint('Initializing Appwrite with:');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Project ID: $projectId');
      debugPrint('Database ID: $databaseId');
      debugPrint('API Key: ${apiKey.isNotEmpty ? 'Provided' : 'Not provided'}');

      // Initialize the main client for user operations
      client = Client()
        ..setEndpoint(endpoint)
        ..setProject(projectId);

      debugPrint('Appwrite client initialized with project ID: $projectId');

      // Initialize the server client with API key for server-side operations
      if (apiKey.isNotEmpty) {
        // Create a server client with API key
        serverClient = Client()
          ..setEndpoint(endpoint)
          ..setProject(projectId)
          // For Appwrite SDK version 8.x and above, use this:
          // ..setKey(apiKey)
          // For older versions, you might need to use:
          // ..addHeader('X-Appwrite-Key', apiKey)
          // Choose the appropriate method based on your SDK version
          ..addHeader('X-Appwrite-Key',
              apiKey) // Use API key for server-side operations
          ..setSelfSigned(status: true); // Remove in production

        debugPrint('Appwrite server client initialized with API key');
      } else {
        // If no API key is provided, use the regular client
        serverClient = client;
        debugPrint(
            'WARNING: No API key provided. Using regular client for server operations.');
        debugPrint('Some operations may fail due to permission issues.');
      }

      // Initialize service clients
      account = Account(client);

      // Use regular client for database operations
      databases = Databases(client);

      // Use server client for storage operations to bypass permissions
      storage = Storage(client);

      // Use regular client for realtime operations
      realtime = Realtime(client);

      debugPrint('Appwrite clients initialized successfully');

      // Print a reminder about database setup
      debugPrint(
          'Make sure you have created the following in your Appwrite console:');
      debugPrint('1. Database with ID: "$databaseId"');
      debugPrint(
          '2. Collections: "${dotenv.env['APPWRITE_USERS_COLLECTION_ID'] ?? 'users'}", "${dotenv.env['APPWRITE_USER_ROLES_COLLECTION_ID'] ?? 'user_roles'}", etc.');
      debugPrint(
          '3. Storage bucket with ID: "${dotenv.env['APPWRITE_PROFILE_PHOTOS_BUCKET_ID'] ?? 'profile_photos'}"');
    } catch (e) {
      debugPrint('Error initializing Appwrite: $e');
      rethrow;
    }
  }
}
