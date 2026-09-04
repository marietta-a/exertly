namespace Exertly.Api.Models;

public record LoginRequest(string Email, string Password);

public record UpdateResumeProfileRequest(
    string? Name,
    string? Title,
    string? Email,
    string? Phone,
    string? Summary);

public record AddSkillRequest(string Skill);

public record AddExperienceRequest(string Role, string Company, string Period);

public record AddResponsibilityRequest(string Responsibility);

public record AddCustomSectionRequest(string Title);

public record AddSectionItemRequest(string Item);

public record SelectTemplateRequest(int Index);
