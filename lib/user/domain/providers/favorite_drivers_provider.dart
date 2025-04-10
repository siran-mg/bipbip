import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Provider for managing favorite drivers
class FavoriteDriversProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final GetCurrentUserInteractor _getCurrentUserInteractor;

  // State
  bool _isLoading = false;
  String? _error;
  List<UserEntity> _favoriteDrivers = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserEntity> get favoriteDrivers => _favoriteDrivers;
  
  /// Creates a new FavoriteDriversProvider
  FavoriteDriversProvider({
    required UserRepository userRepository,
    required GetCurrentUserInteractor getCurrentUserInteractor,
  })  : _userRepository = userRepository,
        _getCurrentUserInteractor = getCurrentUserInteractor;
  
  /// Load favorite drivers for the current user
  Future<void> loadFavoriteDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the current user
      final currentUser = await _getCurrentUserInteractor.execute();
      if (currentUser == null) {
        _isLoading = false;
        _error = 'No user logged in';
        _favoriteDrivers = [];
        notifyListeners();
        return;
      }
      
      // Get favorite drivers
      final drivers = await _userRepository.getFavoriteDrivers(currentUser.id);
      
      // Update state
      _favoriteDrivers = drivers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load favorite drivers: $e';
      notifyListeners();
    }
  }
  
  /// Check if a driver is in favorites
  bool isDriverFavorite(String driverId) {
    return _favoriteDrivers.any((driver) => driver.id == driverId);
  }
  
  /// Add a driver to favorites
  Future<void> addToFavorites(UserEntity driver) async {
    if (isDriverFavorite(driver.id)) {
      return; // Already a favorite
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the current user
      final currentUser = await _getCurrentUserInteractor.execute();
      if (currentUser == null) {
        _isLoading = false;
        _error = 'No user logged in';
        notifyListeners();
        return;
      }
      
      // Add to favorites
      await _userRepository.addFavoriteDriver(currentUser.id, driver.id);
      
      // Add to local list
      _favoriteDrivers.add(driver);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add to favorites: $e';
      notifyListeners();
    }
  }
  
  /// Remove a driver from favorites
  Future<void> removeFromFavorites(String driverId) async {
    if (!isDriverFavorite(driverId)) {
      return; // Not a favorite
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the current user
      final currentUser = await _getCurrentUserInteractor.execute();
      if (currentUser == null) {
        _isLoading = false;
        _error = 'No user logged in';
        notifyListeners();
        return;
      }
      
      // Remove from favorites
      await _userRepository.removeFavoriteDriver(currentUser.id, driverId);
      
      // Remove from local list
      _favoriteDrivers.removeWhere((driver) => driver.id == driverId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to remove from favorites: $e';
      notifyListeners();
    }
  }
  
  /// Toggle favorite status for a driver
  Future<void> toggleFavorite(UserEntity driver) async {
    if (isDriverFavorite(driver.id)) {
      await removeFromFavorites(driver.id);
    } else {
      await addToFavorites(driver);
    }
  }
  
  /// Refresh favorite drivers
  Future<void> refresh() async {
    await loadFavoriteDrivers();
  }
  
  /// Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
