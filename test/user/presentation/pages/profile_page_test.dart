import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/presentation/pages/profile_page.dart';
import 'package:provider/provider.dart';

import 'profile_page_test.mocks.dart';

@GenerateMocks([GetCurrentUserInteractor, UploadProfilePhotoInteractor])
void main() {
  late MockGetCurrentUserInteractor mockGetCurrentUserInteractor;
  late MockUploadProfilePhotoInteractor mockUploadProfilePhotoInteractor;

  setUp(() {
    mockGetCurrentUserInteractor = MockGetCurrentUserInteractor();
    mockUploadProfilePhotoInteractor = MockUploadProfilePhotoInteractor();
  });

  Widget createProfilePage() {
    // Override the ProfilePhotoPicker with our mock version
    return MultiProvider(
      providers: [
        Provider<GetCurrentUserInteractor>.value(
          value: mockGetCurrentUserInteractor,
        ),
        Provider<UploadProfilePhotoInteractor>.value(
          value: mockUploadProfilePhotoInteractor,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              // Replace ProfilePhotoPicker with our mock in tests
              return ProfilePage();
            },
          ),
        ),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      // Arrange
      when(mockGetCurrentUserInteractor.execute())
          .thenAnswer((_) async => null); // Just return null without delay

      // Act
      await tester.pumpWidget(createProfilePage());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when loading fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockGetCurrentUserInteractor.execute())
          .thenThrow(Exception('Test error'));

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester
          .pump(const Duration(milliseconds: 300)); // Wait for UI to update

      // Assert
      expect(
          find.text(
              'Erreur lors du chargement des données: Exception: Test error'),
          findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('should show client profile when user is a client',
        (WidgetTester tester) async {
      // Arrange
      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        // Don't set profilePictureUrl in tests to avoid network image loading issues
        roles: ['client'],
        clientDetails: ClientDetails(rating: 4.5),
      );

      when(mockGetCurrentUserInteractor.execute())
          .thenAnswer((_) async => user);

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester
          .pump(const Duration(milliseconds: 300)); // Wait for UI to update

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Profil Client'), findsOneWidget);
      expect(find.text('4.5/5.0'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('Profil Chauffeur'), findsNothing);
    });

    testWidgets('should show driver profile when user is a driver',
        (WidgetTester tester) async {
      // Arrange
      final vehicle = VehicleEntity(
        id: 'vehicle123',
        licensePlate: 'ABC123',
        brand: 'Toyota',
        model: 'Corolla',
        type: 'car',
        isPrimary: true,
      );

      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        // Don't set profilePictureUrl in tests to avoid network image loading issues
        roles: ['driver'],
        driverDetails: DriverDetails(
          isAvailable: true,
          rating: 4.8,
          vehicles: [vehicle],
        ),
      );

      when(mockGetCurrentUserInteractor.execute())
          .thenAnswer((_) async => user);

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester
          .pump(const Duration(milliseconds: 300)); // Wait for UI to update

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Chauffeur'), findsOneWidget);
      expect(find.text('Profil Chauffeur'), findsOneWidget);
      expect(find.text('4.8/5.0'), findsOneWidget);
      expect(find.text('Disponible'), findsOneWidget);
      expect(find.text('Toyota Corolla'), findsOneWidget);
      expect(find.text('Plaque: ABC123'), findsOneWidget);
      expect(find.text('Principal'), findsOneWidget);
      expect(find.text('Profil Client'), findsNothing);
    });

    testWidgets(
        'should show both client and driver profiles when user has both roles',
        (WidgetTester tester) async {
      // Arrange
      final vehicle = VehicleEntity(
        id: 'vehicle123',
        licensePlate: 'ABC123',
        brand: 'Toyota',
        model: 'Corolla',
        type: 'car',
        isPrimary: true,
      );

      final user = UserEntity(
        id: 'user123',
        givenName: 'John',
        familyName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        // Don't set profilePictureUrl in tests to avoid network image loading issues
        roles: ['client', 'driver'],
        clientDetails: ClientDetails(rating: 4.5),
        driverDetails: DriverDetails(
          isAvailable: true,
          rating: 4.8,
          vehicles: [vehicle],
        ),
      );

      when(mockGetCurrentUserInteractor.execute())
          .thenAnswer((_) async => user);

      // Act
      await tester.pumpWidget(createProfilePage());
      await tester
          .pump(const Duration(milliseconds: 300)); // Wait for UI to update

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Chauffeur'), findsOneWidget);
      expect(find.text('Profil Client'), findsOneWidget);
      expect(find.text('Profil Chauffeur'), findsOneWidget);
    });
  });
}
