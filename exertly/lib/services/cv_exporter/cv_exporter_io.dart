import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import '../../providers/dashboard_provider.dart';
import 'cv_pdf_builder.dart';

class CvExporter {
  Future<String> saveCvFile(
    DashboardProvider provider,
    Color primaryColor,
    Color secondaryColor,
  ) async {
    final pdfDoc = await CvPdfBuilder.build(
      provider,
      PdfColor.fromInt(primaryColor.value),
      PdfColor.fromInt(secondaryColor.value),
    );
    final bytes = await pdfDoc.save();

    // Find standard Downloads directory, falling back to Documents on mobile if public Downloads is locked
    Directory? downloadsDir = await getDownloadsDirectory();
    downloadsDir ??= await getApplicationDocumentsDirectory();

    // PDF name dynamically includes the user's name (formatted cleanly)
    final formattedName = provider.resumeName.trim().replaceAll(RegExp(r'\s+'), '_');
    final safeFileName = 'exertly_cv_$formattedName.pdf';
    final filePath = '${downloadsDir.path}/$safeFileName';
    final file = File(filePath);

    await file.writeAsBytes(bytes);

    return 'Successfully compiled and saved PDF as "$safeFileName" inside your device Downloads/Documents directory:\n$filePath';
  }
}
