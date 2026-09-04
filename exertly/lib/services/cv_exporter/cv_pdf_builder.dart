import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../providers/dashboard_provider.dart';

/// Builds the pdf.Document for a resume from [DashboardProvider]'s CV
/// Builder state. Shared by the desktop/mobile and web `CvExporter`s (local
/// download) and by `ResumeFileService` (upload to Supabase Storage), so the
/// PDF layout only needs to live in one place.
class CvPdfBuilder {
  CvPdfBuilder._();

  static Future<pw.Document> build(
    DashboardProvider provider,
    PdfColor primary,
    PdfColor secondary,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Name, Title & Contacts Header (using primary and secondary theme colors)
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      provider.resumeName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      provider.resumeTitle.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: secondary,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '${provider.resumeEmail}  |  ${provider.resumePhone}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // Summary
              _sectionHeader('PROFESSIONAL SUMMARY', primary),
              pw.SizedBox(height: 8),
              pw.Text(
                provider.resumeSummary,
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.3),
              ),
              pw.SizedBox(height: 20),

              // Experience Section
              _sectionHeader('PROFESSIONAL EXPERIENCE', primary),
              pw.SizedBox(height: 12),
              ...provider.resumeExperience.map((exp) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            exp.role,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            exp.period,
                            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        exp.company,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: secondary,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (exp.responsibilities.isEmpty)
                        pw.Text('No responsibilities added yet.', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600))
                      else
                        ...exp.responsibilities.map((resp) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 3.0, left: 10.0),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Bullet color matches the dynamic theme secondary color!
                                pw.Text('•  ', style: pw.TextStyle(color: secondary, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                                pw.Expanded(
                                  child: pw.Text(
                                    resp,
                                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              }),

              // Skills Section
              _sectionHeader('TECHNICAL & CORE SKILLS', primary),
              pw.SizedBox(height: 8),
              pw.Text(
                provider.resumeSkills.join(', '),
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.3),
              ),

              // Custom Sections
              ...provider.customSections.map((sec) {
                if (sec.items.isEmpty) return pw.SizedBox.shrink();
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 20),
                    _sectionHeader(sec.title.toUpperCase(), primary),
                    pw.SizedBox(height: 8),
                    ...sec.items.map((item) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 3.0, left: 10.0),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Bullet color matches the dynamic theme secondary color!
                            pw.Text('•  ', style: pw.TextStyle(color: secondary, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                            pw.Expanded(
                              child: pw.Text(
                                item,
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _sectionHeader(String title, PdfColor primaryColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.1,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          height: 1,
          width: double.infinity,
          color: PdfColors.grey300,
        ),
      ],
    );
  }
}
