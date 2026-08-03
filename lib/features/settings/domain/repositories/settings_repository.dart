import '../entities/currency.dart';
import '../entities/user_profile.dart';

abstract interface class SettingsRepository {
  Future<UserProfile> getProfile();

  Future<List<Currency>> getCurrencies();
}
