import '../core/network/api_client.dart';
import '../models/reports/cake_analysis.dart';
import '../models/reports/report_dashboard.dart';
import '../models/reports/report_summary.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService({
    required this.apiClient,
  });

  // =========================================================
  // RAPOR DASHBOARD
  //
  // GET /api/Reports/dashboard
  //
  // SADECE ADMIN
  // =========================================================

  Future<ReportDashboard> getDashboard() async {
    final response =
        await apiClient.dio.get(
      '/Reports/dashboard',
    );

    final data =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    return ReportDashboard.fromJson(
      data,
    );
  }

  // =========================================================
  // RAPOR ÖZETİ
  //
  // GET /api/Reports/summary
  //
  // Query:
  // startDate
  // endDate
  //
  // SADECE ADMIN
  // =========================================================

  Future<ReportSummary> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response =
        await apiClient.dio.get(
      '/Reports/summary',
      queryParameters: {
        'startDate':
            _formatDate(startDate),
        'endDate':
            _formatDate(endDate),
      },
    );

    final data =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    return ReportSummary.fromJson(
      data,
    );
  }

  // =========================================================
  // PASTA ANALİZİ
  //
  // GET /api/Reports/cake-analysis
  //
  // Query:
  // period = day
  // period = week
  // period = month
  //
  // SADECE ADMIN
  // =========================================================

  Future<CakeAnalysis> getCakeAnalysis({
    required String period,
  }) async {
    final response =
        await apiClient.dio.get(
      '/Reports/cake-analysis',
      queryParameters: {
        'period': period,
      },
    );

    final data =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    return CakeAnalysis.fromJson(
      data,
    );
  }

  // =========================================================
  // TARİH FORMATLAMA
  //
  // API'ye:
  // YYYY-MM-DD
  // formatında gönderilir.
  // =========================================================

  String _formatDate(
    DateTime date,
  ) {
    final year =
        date.year.toString();

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$year-$month-$day';
  }
}