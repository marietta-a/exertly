import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import '../../providers/dashboard_provider.dart';
import '../api/storage_api_service.dart';
import '../cv_exporter/cv_pdf_builder.dart';
import 'supabase_config.dart';

/// Renders the signed-in user's CV Builder data to a PDF and stores it in
/// the `resumes` Supabase Storage bucket via Exertly.Api. Mirrors
/// [AvatarService]'s approach: the bucket is the source of truth — there's no
/// separate database row for it. Each user has at most one stored resume,
/// kept at a fixed name (`resume.pdf`); re-uploading overwrites it in place
/// (the API always sends `x-upsert: true`), so there's nothing to delete
/// first.
class ResumeFileService {
  static const fileName = 'resume.pdf';

  final StorageApiService _storage;

  ResumeFileService({StorageApiService? storage}) : _storage = storage ?? StorageApiService();

  /// Renders [provider]'s current resume data to PDF (using the app's theme
  /// colors) and uploads it, replacing any previously stored resume. Returns
  /// a signed URL for the uploaded file. Throws [StateError] if no user is
  /// signed in.
  Future<String> generateAndUpload(
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

    final path = await _storage.uploadFile(
      bucket: SupabaseConfig.resumesBucket,
      fileName: fileName,
      bytes: bytes,
      contentType: 'application/pdf',
    );
    if (path == null) {
      throw StateError('You must be signed in to upload a resume.');
    }

    final url = await _storage.getSignedUrl(bucket: SupabaseConfig.resumesBucket, path: path);
    if (url == null || url.isEmpty) {
      throw StateError('Unable to resolve the uploaded resume\'s URL.');
    }
    return url;
  }

  /// Returns a signed URL for the current signed-in user's stored resume, or
  /// null if they haven't uploaded one yet or no user is signed in.
  Future<String?> getStoredResumeUrl() {
    return _storage.getUserFileSignedUrl(SupabaseConfig.resumesBucket, fileName);
  }

  /// Deletes the current user's stored resume from the bucket.
  Future<void> deleteStoredResume() {
    return _storage.deleteAllUserFiles(SupabaseConfig.resumesBucket);
  }
}
