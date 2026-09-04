class JobListing {
  final String id;
  final String title;
  final String company;
  final String location;
  final String logoText; // Simple textual initials for placeholder logos
  final String salaryRange;
  final String employmentType; // 'Full-time', 'Part-time', 'Contract', 'Internship'
  final String workArrangement; // 'Remote Only', 'Onsite', 'Hybrid'
  final String datePosted;
  final bool sponsorshipAvailable;
  final List<String> tags;
  final String details;
  final String postingLink;

  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.logoText,
    required this.salaryRange,
    required this.employmentType,
    this.workArrangement = '',
    this.datePosted = '',
    this.sponsorshipAvailable = false,
    required this.tags,
    this.details = '',
    this.postingLink = '',
  });

  factory JobListing.fromJson(Map<String, dynamic> json) {
    return JobListing(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      logoText: json['logo_text'] as String,
      salaryRange: json['salary_range'] as String,
      employmentType: json['employment_type'] as String,
      workArrangement: json['work_arrangement'] as String? ?? '',
      datePosted: json['date_posted'] as String? ?? '',
      sponsorshipAvailable: json['sponsorship_available'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      details: json['details'] as String? ?? '',
      postingLink: json['posting_link'] as String? ?? '',
    );
  }
}

class Scholarship {
  final String id;
  final String title;
  final String institution;
  final String amount;
  final String deadline;
  final String category;
  final String location;
  final String datePosted;
  final String type; // 'Online Studies', 'Certification Program', 'On Campus'
  final String degreeType; // 'Undergraduate', 'Master's', 'PhD / Research', 'Postdoctoral'
  final List<String> eligibilityCriteria;
  final List<String> eligibleCountries;
  final String details;
  final String postingLink;

  const Scholarship({
    required this.id,
    required this.title,
    required this.institution,
    required this.amount,
    required this.deadline,
    required this.category,
    this.location = '',
    this.datePosted = '',
    this.type = '',
    this.degreeType = '',
    this.eligibilityCriteria = const [],
    this.eligibleCountries = const [],
    this.details = '',
    this.postingLink = '',
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['id'] as String,
      title: json['title'] as String,
      institution: json['institution'] as String,
      amount: json['amount'] as String,
      deadline: json['deadline'] as String,
      category: json['category'] as String,
      location: json['location'] as String? ?? '',
      datePosted: json['date_posted'] as String? ?? '',
      type: json['type'] as String? ?? '',
      degreeType: json['degree_type'] as String? ?? '',
      eligibilityCriteria: (json['eligibility_criteria'] as List<dynamic>? ?? []).cast<String>(),
      eligibleCountries: (json['eligible_countries'] as List<dynamic>? ?? []).cast<String>(),
      details: json['details'] as String? ?? '',
      postingLink: json['posting_link'] as String? ?? '',
    );
  }
}

class ResumeTemplate {
  final String id;
  final String name;
  final String description;
  final String complexity; // 'Entry', 'Professional', 'Executive'
  final String previewText;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.complexity,
    required this.previewText,
  });

  factory ResumeTemplate.fromJson(Map<String, dynamic> json) {
    return ResumeTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      complexity: json['complexity'] as String,
      previewText: json['preview_text'] as String,
    );
  }
}

class CustomSection {
  final String id;
  final String title;
  final List<String> items;

  const CustomSection({
    required this.id,
    required this.title,
    required this.items,
  });

  factory CustomSection.fromJson(Map<String, dynamic> json) {
    return CustomSection(
      id: json['id'] as String,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  CustomSection copyWith({
    String? id,
    String? title,
    List<String>? items,
  }) {
    return CustomSection(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }
}

class WorkExperience {
  final String id;
  final String role;
  final String company;
  final String period;
  final List<String> responsibilities;

  const WorkExperience({
    required this.id,
    required this.role,
    required this.company,
    required this.period,
    required this.responsibilities,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'] as String,
      role: json['role'] as String,
      company: json['company'] as String,
      period: json['period'] as String,
      responsibilities: (json['responsibilities'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  WorkExperience copyWith({
    String? id,
    String? role,
    String? company,
    String? period,
    List<String>? responsibilities,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      period: period ?? this.period,
      responsibilities: responsibilities ?? this.responsibilities,
    );
  }
}
