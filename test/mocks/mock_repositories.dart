import 'package:mockito/annotations.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';

@GenerateNiceMocks([
  MockSpec<AuthRepository>(),
  MockSpec<UserRepository>(),
  MockSpec<VehicleRepository>(),
  MockSpec<StorageRepository>()
])
void main() {}

// The actual mock classes will be generated in mock_repositories.mocks.dart
// Import that file in your tests
