/// Path constants for Exertly.Api's HTTP endpoints, relative to
/// [ApiConfig.baseUrl][../../services/api/api_config.dart]. Grouped by
/// controller so paths stay in one place instead of being inlined at each
/// call site.
class ApiEndpoints {
  ApiEndpoints._();

  // --- Jobs ---

  static const String jobs = '/api/jobs';
  static const String savedJobs = '/api/jobs/saved';

  static String saveJob(String jobId) => '/api/jobs/$jobId/save';
  static String applyToJob(String jobId) => '/api/jobs/$jobId/apply';

  // --- Educational opportunities ---

  static const String educationalOpportunities = '/api/educational-opportunities';
  static const String appliedEducationalOpportunities = '/api/educational-opportunities/applied';

  static String applyToEducationalOpportunity(String id) => '/api/educational-opportunities/$id/apply';

  // --- Resume ---

  static const String resumeTemplates = '/api/resume/templates';
  static const String selectResumeTemplate = '/api/resume/templates/select';
  static const String resumeProfile = '/api/resume/profile';
  static const String resumeSkills = '/api/resume/skills';
  static const String resumeExperience = '/api/resume/experience';
  static const String resumeSections = '/api/resume/sections';

  static String resumeSkill(String skill) => '/api/resume/skills/${Uri.encodeComponent(skill)}';
  static String resumeExperienceItem(String id) => '/api/resume/experience/$id';
  static String resumeExperienceResponsibilities(String experienceId) =>
      '/api/resume/experience/$experienceId/responsibilities';
  static String resumeExperienceResponsibility(String experienceId, int index) =>
      '/api/resume/experience/$experienceId/responsibilities/$index';
  static String resumeSection(String id) => '/api/resume/sections/$id';
  static String resumeSectionItems(String sectionId) => '/api/resume/sections/$sectionId/items';
  static String resumeSectionItem(String sectionId, int index) => '/api/resume/sections/$sectionId/items/$index';

  // --- Storage ---

  static String storageFiles(String bucket) => '/api/storage/$bucket/files';
  static String storageAllFiles(String bucket) => '/api/storage/$bucket/files/all';
  static String storageSignedUrl(String bucket) => '/api/storage/$bucket/signed-url';
  static String storagePublicUrl(String bucket) => '/api/storage/$bucket/public-url';

  // --- User avatars ---

  static String userAvatar(String userId) => '/api/user-avatars/$userId';
}
