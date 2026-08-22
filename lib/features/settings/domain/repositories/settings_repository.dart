import '../entities/currency.dart';
import '../entities/user_profile.dart';

abstract interface class SettingsRepository {
  Future<UserProfile> getProfile();

  Future<List<Currency>> getCurrencies();

  Future<UserProfile> updateProfile({required String username});

  Future<void> changeEmail({
    required String email,
    required String currentPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}
