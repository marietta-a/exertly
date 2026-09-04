import 'package:flutter_test/flutter_test.dart';
import 'package:exertly/providers/dashboard_provider.dart';

void main() {
  group('DashboardProvider Tests', () {
    late DashboardProvider provider;

    setUp(() {
      provider = DashboardProvider();
    });

    test('Initializes with default mock lists and user details', () {
      expect(provider.jobs.isNotEmpty, true);
      expect(provider.scholarships.isNotEmpty, true);
      expect(provider.templates.isNotEmpty, true);
      expect(provider.resumeName, 'John Doe');
      expect(provider.resumeTitle, 'Senior Software Engineer');
      expect(provider.resumeSkills.contains('Flutter'), true);
    });

    test('updateResumeDetails dynamically updates user profile information', () {
      provider.updateResumeDetails(
        name: 'Jane Miller',
        title: 'Lead Product Designer',
        email: 'jane.miller@exertly.io',
      );

      expect(provider.resumeName, 'Jane Miller');
      expect(provider.resumeTitle, 'Lead Product Designer');
      expect(provider.resumeEmail, 'jane.miller@exertly.io');
    });

    test('addSkill and removeSkill dynamically modify skills list', () {
      // Add skill
      provider.addSkill('Rust');
      expect(provider.resumeSkills.contains('Rust'), true);

      // Duplicate skill should not be added again
      final initialLength = provider.resumeSkills.length;
      provider.addSkill('Rust');
      expect(provider.resumeSkills.length, initialLength);

      // Remove skill
      provider.removeSkill('Rust');
      expect(provider.resumeSkills.contains('Rust'), false);
    });

    test('addExperience and removeExperience dynamically modify experience list', () {
      final initialLength = provider.resumeExperience.length;
      
      provider.addExperience('Senior Specialist', 'OpenAI', '2026');
      expect(provider.resumeExperience.length, initialLength + 1);
      expect(provider.resumeExperience.first.role, 'Senior Specialist');
      expect(provider.resumeExperience.first.company, 'OpenAI');

      final newId = provider.resumeExperience.first.id;
      provider.removeExperience(newId);
      expect(provider.resumeExperience.length, initialLength);
    });

    test('addResponsibilityToExperience and removeResponsibilityFromExperience dynamically modify responsibilities', () {
      final expId = provider.resumeExperience.first.id;
      final initialRespLength = provider.resumeExperience.first.responsibilities.length;

      provider.addResponsibilityToExperience(expId, 'Authored core RLHF training feedback logic.');
      expect(provider.resumeExperience.first.responsibilities.length, initialRespLength + 1);
      expect(provider.resumeExperience.first.responsibilities.last, 'Authored core RLHF training feedback logic.');

      provider.removeResponsibilityFromExperience(expId, initialRespLength);
      expect(provider.resumeExperience.first.responsibilities.length, initialRespLength);
    });

    test('toggleSaveJob updates saved jobs selection state', () {
      const jobId = '2';
      expect(provider.savedJobs.contains(jobId), false);

      // Save job
      provider.toggleSaveJob(jobId);
      expect(provider.savedJobs.contains(jobId), true);

      // Unsave job
      provider.toggleSaveJob(jobId);
      expect(provider.savedJobs.contains(jobId), false);
    });

    test('toggleApplyScholarship updates applied scholarships selection state', () {
      const scholarshipId = '1';
      expect(provider.appliedScholarships.contains(scholarshipId), false);

      // Apply
      provider.toggleApplyScholarship(scholarshipId);
      expect(provider.appliedScholarships.contains(scholarshipId), true);

      // Withdraw
      provider.toggleApplyScholarship(scholarshipId);
      expect(provider.appliedScholarships.contains(scholarshipId), false);
    });
  });
}
