import '../entities/monthly_summary.dart';

abstract interface class AnalyticsRepository {
  Future<MonthlySummary> getMonthlySummary(DateTime month);
}
