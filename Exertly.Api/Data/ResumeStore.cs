using Exertly.Api.Models;

namespace Exertly.Api.Data;

// In-memory store backing the CV/Resume builder screen. Mirrors the mutable
// state and actions found in the Flutter app's DashboardProvider.
public class ResumeStore
{
    private readonly ResumeProfile _profile = MockData.ResumeProfile;
    private readonly List<WorkExperience> _experience = MockData.ResumeExperience;
    private readonly List<CustomSection> _sections = MockData.CustomSections;
    private readonly List<ResumeTemplate> _templates = MockData.ResumeTemplates;

    public IReadOnlyList<ResumeTemplate> Templates => _templates;

    public ResumeProfile GetProfile() => _profile;

    public void UpdateProfile(string? name, string? title, string? email, string? phone, string? summary)
    {
        if (name is not null) _profile.Name = name;
        if (title is not null) _profile.Title = title;
        if (email is not null) _profile.Email = email;
        if (phone is not null) _profile.Phone = phone;
        if (summary is not null) _profile.Summary = summary;
    }

    public bool SelectTemplate(int index)
    {
        if (index < 0 || index >= _templates.Count) return false;
        _profile.SelectedTemplateIndex = index;
        return true;
    }

    public bool AddSkill(string skill)
    {
        if (string.IsNullOrWhiteSpace(skill) || _profile.Skills.Contains(skill)) return false;
        _profile.Skills.Add(skill);
        return true;
    }

    public bool RemoveSkill(string skill) => _profile.Skills.Remove(skill);

    public IReadOnlyList<WorkExperience> GetExperience() => _experience;

    public WorkExperience AddExperience(string role, string company, string period)
    {
        var experience = new WorkExperience
        {
            Id = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString(),
            Role = role.Trim(),
            Company = company.Trim(),
            Period = string.IsNullOrWhiteSpace(period) ? "Present" : period.Trim(),
            Responsibilities = [],
        };
        _experience.Insert(0, experience);
        return experience;
    }

    public bool RemoveExperience(string id) => _experience.RemoveAll(e => e.Id == id) > 0;

    public bool AddResponsibility(string experienceId, string responsibility)
    {
        if (string.IsNullOrWhiteSpace(responsibility)) return false;
        var experience = _experience.FirstOrDefault(e => e.Id == experienceId);
        if (experience is null) return false;
        experience.Responsibilities.Add(responsibility.Trim());
        return true;
    }

    public bool RemoveResponsibility(string experienceId, int index)
    {
        var experience = _experience.FirstOrDefault(e => e.Id == experienceId);
        if (experience is null || index < 0 || index >= experience.Responsibilities.Count) return false;
        experience.Responsibilities.RemoveAt(index);
        return true;
    }

    public IReadOnlyList<CustomSection> GetCustomSections() => _sections;

    public CustomSection AddCustomSection(string title)
    {
        var section = new CustomSection
        {
            Id = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString(),
            Title = title.Trim(),
            Items = [],
        };
        _sections.Add(section);
        return section;
    }

    public bool RemoveCustomSection(string id) => _sections.RemoveAll(s => s.Id == id) > 0;

    public bool AddItemToSection(string sectionId, string item)
    {
        if (string.IsNullOrWhiteSpace(item)) return false;
        var section = _sections.FirstOrDefault(s => s.Id == sectionId);
        if (section is null) return false;
        section.Items.Add(item.Trim());
        return true;
    }

    public bool RemoveItemFromSection(string sectionId, int index)
    {
        var section = _sections.FirstOrDefault(s => s.Id == sectionId);
        if (section is null || index < 0 || index >= section.Items.Count) return false;
        section.Items.RemoveAt(index);
        return true;
    }
}
