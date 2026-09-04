import 'package:flutter/material.dart';
import '../../providers/dashboard_provider.dart';

/// Cross-platform dynamic CV Exporter interface.
/// Directs exports to local downloads or triggers browser downloads, preserving theme colors.
class CvExporter {
  Future<String> saveCvFile(
    DashboardProvider provider,
    Color primaryColor,
    Color secondaryColor,
  ) async {
    throw UnsupportedError('Cannot save CV files on this platform without concrete implementation.');
  }
}
