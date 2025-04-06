import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';

/// Provides Appwrite client instances
class ClientProviders {
  /// Get all client providers
  static List<SingleChildWidget> getProviders() {
    return [
      // Appwrite clients
      Provider<AppwriteClientInitializer>(
        create: (_) => AppwriteClientInitializer.instance,
      ),

      // Session storage
      Provider<SessionStorage>(
        create: (_) => SessionStorage(),
      ),
    ];
  }
}
