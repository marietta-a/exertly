import 'dart:html' as html;
import 'package:flutter/material.dart';
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

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // PDF name dynamically includes the user's name (formatted cleanly)
    final formattedName = provider.resumeName.trim().replaceAll(RegExp(r'\s+'), '_');
    final safeFileName = 'exertly_cv_$formattedName.pdf';

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = safeFileName;

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    return 'Successfully compiled and downloaded PDF "$safeFileName" via browser Downloads.';
  }
}
