import 'package:flutter/material.dart';
import '../domain/models/models.dart';
import '../services/api/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _api;

  DashboardProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    loadJobs();
    loadScholarships();
    loadResumeData();
  }

  // Jobs (GET /api/jobs, /api/jobs/saved)
  List<JobListing> _jobs = [];
  bool isLoadingJobs = true;
  String? jobsError;

  // Scholarships (GET /api/educational-opportunities, /applied)
  List<Scholarship> _scholarships = [];
  bool isLoadingScholarships = true;
  String? scholarshipsError;

  // Resume: templates, profile, experience, custom sections
  // (GET /api/resume/templates, /profile, /experience, /sections)
  List<ResumeTemplate> _templates = [];
  bool isLoadingResume = true;
  String? resumeError;

  String _resumeName = '';
  String _resumeTitle = '';
  String _resumeEmail = '';
  String _resumePhone = '';
  String _resumeSummary = '';
  final List<String> _resumeSkills = [];
  List<WorkExperience> _resumeExperience = [];
  List<CustomSection> _customSections = [];

  int _selectedTemplateIndex = 0;
  final List<String> _savedJobs = [];
  final List<String> _appliedScholarships = [];

  // Getters
  List<JobListing> get jobs => _jobs;
  List<Scholarship> get scholarships => _scholarships;
  List<ResumeTemplate> get templates => _templates;

  String get resumeName => _resumeName;
  String get resumeTitle => _resumeTitle;
  String get resumeEmail => _resumeEmail;
  String get resumePhone => _resumePhone;
  String get resumeSummary => _resumeSummary;
  List<String> get resumeSkills => _resumeSkills;
  List<WorkExperience> get resumeExperience => _resumeExperience;
  List<CustomSection> get customSections => _customSections;

  int get selectedTemplateIndex => _selectedTemplateIndex;
  List<String> get savedJobs => _savedJobs;
  List<String> get appliedScholarships => _appliedScholarships;

  // --- Loading ---

  Future<void> loadJobs() async {
    isLoadingJobs = true;
    jobsError = null;
    notifyListeners();
    try {
      final jobsJson = await _api.get('/api/jobs') as List<dynamic>;
      _jobs = jobsJson.map((e) => JobListing.fromJson(e as Map<String, dynamic>)).toList();

      final savedJson = await _api.get('/api/jobs/saved') as List<dynamic>;
      _savedJobs
        ..clear()
        ..addAll(savedJson.map((e) => (e as Map<String, dynamic>)['id'] as String));
    } catch (_) {
      jobsError = 'Unable to load job opportunities from the API.';
    } finally {
      isLoadingJobs = false;
      notifyListeners();
    }
  }

  Future<void> loadScholarships() async {
    isLoadingScholarships = true;
    scholarshipsError = null;
    notifyListeners();
    try {
      final oppsJson = await _api.get('/api/educational-opportunities') as List<dynamic>;
      _scholarships = oppsJson.map((e) => Scholarship.fromJson(e as Map<String, dynamic>)).toList();

      final appliedJson = await _api.get('/api/educational-opportunities/applied') as List<dynamic>;
      _appliedScholarships
        ..clear()
        ..addAll(appliedJson.map((e) => (e as Map<String, dynamic>)['id'] as String));
    } catch (_) {
      scholarshipsError = 'Unable to load scholarships from the API.';
    } finally {
      isLoadingScholarships = false;
      notifyListeners();
    }
  }

  Future<void> loadResumeData() async {
    isLoadingResume = true;
    resumeError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.get('/api/resume/templates'),
        _api.get('/api/resume/profile'),
        _api.get('/api/resume/experience'),
        _api.get('/api/resume/sections'),
      ]);

      _templates = (results[0] as List<dynamic>)
          .map((e) => ResumeTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
      _applyProfile(results[1] as Map<String, dynamic>);
      _resumeExperience = (results[2] as List<dynamic>)
          .map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList();
      _customSections = (results[3] as List<dynamic>)
          .map((e) => CustomSection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      resumeError = 'Unable to load resume data from the API.';
    } finally {
      isLoadingResume = false;
      notifyListeners();
    }
  }

  void _applyProfile(Map<String, dynamic> profile) {
    _resumeName = profile['name'] as String? ?? _resumeName;
    _resumeTitle = profile['title'] as String? ?? _resumeTitle;
    _resumeEmail = profile['email'] as String? ?? _resumeEmail;
    _resumePhone = profile['phone'] as String? ?? _resumePhone;
    _resumeSummary = profile['summary'] as String? ?? _resumeSummary;
    final skills = profile['skills'] as List<dynamic>?;
    if (skills != null) {
      _resumeSkills
        ..clear()
        ..addAll(skills.cast<String>());
    }
    _selectedTemplateIndex = profile['selectedTemplateIndex'] as int? ?? _selectedTemplateIndex;
  }

  // --- Actions ---

  Future<void> updateResumeDetails({
    String? name,
    String? title,
    String? email,
    String? phone,
    String? summary,
  }) async {
    if (name != null) _resumeName = name;
    if (title != null) _resumeTitle = title;
    if (email != null) _resumeEmail = email;
    if (phone != null) _resumePhone = phone;
    if (summary != null) _resumeSummary = summary;
    notifyListeners();

    try {
      final response = await _api.put('/api/resume/profile', body: {
        'name': name,
        'title': title,
        'email': email,
        'phone': phone,
        'summary': summary,
      }) as Map<String, dynamic>;
      _applyProfile(response);
      notifyListeners();
    } catch (_) {
      // Keep the optimistic local edit; the API will be retried on next mutation.
    }
  }

  Future<void> addSkill(String skill) async {
    final trimmed = skill.trim();
    if (trimmed.isEmpty || _resumeSkills.contains(trimmed)) return;
    _resumeSkills.add(trimmed);
    notifyListeners();
    try {
      final response = await _api.post('/api/resume/skills', body: {'skill': trimmed}) as Map<String, dynamic>;
      _applyProfile(response);
      notifyListeners();
    } catch (_) {
      _resumeSkills.remove(trimmed);
      notifyListeners();
    }
  }

  Future<void> removeSkill(String skill) async {
    if (!_resumeSkills.remove(skill)) return;
    notifyListeners();
    try {
      final response = await _api.delete('/api/resume/skills/${Uri.encodeComponent(skill)}') as Map<String, dynamic>;
      _applyProfile(response);
      notifyListeners();
    } catch (_) {
      _resumeSkills.add(skill);
      notifyListeners();
    }
  }

  Future<void> addExperience(String role, String company, String period) async {
    final trimmedRole = role.trim();
    final trimmedCompany = company.trim();
    if (trimmedRole.isEmpty || trimmedCompany.isEmpty) return;

    try {
      final response = await _api.post('/api/resume/experience', body: {
        'role': trimmedRole,
        'company': trimmedCompany,
        'period': period.trim(),
      }) as Map<String, dynamic>;
      _resumeExperience.insert(0, WorkExperience.fromJson(response));
      notifyListeners();
    } catch (_) {
      // Nothing to roll back; the role wasn't added locally.
    }
  }

  Future<void> removeExperience(String id) async {
    final index = _resumeExperience.indexWhere((exp) => exp.id == id);
    if (index == -1) return;
    final removed = _resumeExperience.removeAt(index);
    notifyListeners();
    try {
      await _api.delete('/api/resume/experience/$id');
    } catch (_) {
      _resumeExperience.insert(index, removed);
      notifyListeners();
    }
  }

  Future<void> addResponsibilityToExperience(String expId, String responsibility) async {
    if (responsibility.trim().isEmpty) return;
    try {
      final response = await _api.post('/api/resume/experience/$expId/responsibilities', body: {
        'responsibility': responsibility.trim(),
      }) as List<dynamic>;
      _resumeExperience = response.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {
      // No local change to revert.
    }
  }

  Future<void> removeResponsibilityFromExperience(String expId, int respIndex) async {
    try {
      final response = await _api.delete('/api/resume/experience/$expId/responsibilities/$respIndex') as List<dynamic>;
      _resumeExperience = response.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {
      // No local change to revert.
    }
  }

  Future<void> addCustomSection(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    try {
      final response = await _api.post('/api/resume/sections', body: {'title': trimmed}) as Map<String, dynamic>;
      _customSections.add(CustomSection.fromJson(response));
      notifyListeners();
    } catch (_) {
      // Nothing to roll back; the section wasn't added locally.
    }
  }

  Future<void> removeCustomSection(String sectionId) async {
    final index = _customSections.indexWhere((sec) => sec.id == sectionId);
    if (index == -1) return;
    final removed = _customSections.removeAt(index);
    notifyListeners();
    try {
      await _api.delete('/api/resume/sections/$sectionId');
    } catch (_) {
      _customSections.insert(index, removed);
      notifyListeners();
    }
  }

  Future<void> addItemToSection(String sectionId, String item) async {
    if (item.trim().isEmpty) return;
    try {
      final response = await _api.post('/api/resume/sections/$sectionId/items', body: {
        'item': item.trim(),
      }) as List<dynamic>;
      _customSections = response.map((e) => CustomSection.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {
      // No local change to revert.
    }
  }

  Future<void> removeItemFromSection(String sectionId, int itemIndex) async {
    try {
      final response = await _api.delete('/api/resume/sections/$sectionId/items/$itemIndex') as List<dynamic>;
      _customSections = response.map((e) => CustomSection.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {
      // No local change to revert.
    }
  }

  Future<void> selectTemplate(int index) async {
    if (index < 0 || index >= _templates.length) return;
    final previous = _selectedTemplateIndex;
    _selectedTemplateIndex = index;
    notifyListeners();
    try {
      final response = await _api.post('/api/resume/templates/select', body: {'index': index}) as Map<String, dynamic>;
      _applyProfile(response);
      notifyListeners();
    } catch (_) {
      _selectedTemplateIndex = previous;
      notifyListeners();
    }
  }

  Future<void> toggleSaveJob(String jobId) async {
    final wasSaved = _savedJobs.contains(jobId);
    wasSaved ? _savedJobs.remove(jobId) : _savedJobs.add(jobId);
    notifyListeners();
    try {
      final response = await _api.post('/api/jobs/$jobId/save') as Map<String, dynamic>;
      final saved = response['saved'] as bool? ?? !wasSaved;
      if (saved && !_savedJobs.contains(jobId)) _savedJobs.add(jobId);
      if (!saved) _savedJobs.remove(jobId);
      notifyListeners();
    } catch (_) {
      wasSaved ? _savedJobs.add(jobId) : _savedJobs.remove(jobId);
      notifyListeners();
    }
  }

  /// Calls POST /api/jobs/{id}/apply and returns the API's confirmation message.
  Future<String> applyToJob(String jobId) async {
    try {
      final response = await _api.post('/api/jobs/$jobId/apply') as Map<String, dynamic>;
      return response['message'] as String? ?? 'Application submitted.';
    } on ApiException catch (e) {
      return 'Failed to apply: ${e.message}';
    } catch (_) {
      return 'Failed to apply. Please check your connection to the Exertly API.';
    }
  }

  Future<void> toggleApplyScholarship(String scholarshipId) async {
    final wasApplied = _appliedScholarships.contains(scholarshipId);
    wasApplied ? _appliedScholarships.remove(scholarshipId) : _appliedScholarships.add(scholarshipId);
    notifyListeners();
    try {
      final response = await _api.post('/api/educational-opportunities/$scholarshipId/apply') as Map<String, dynamic>;
      final applied = response['applied'] as bool? ?? !wasApplied;
      if (applied && !_appliedScholarships.contains(scholarshipId)) _appliedScholarships.add(scholarshipId);
      if (!applied) _appliedScholarships.remove(scholarshipId);
      notifyListeners();
    } catch (_) {
      wasApplied ? _appliedScholarships.add(scholarshipId) : _appliedScholarships.remove(scholarshipId);
      notifyListeners();
    }
  }
}
