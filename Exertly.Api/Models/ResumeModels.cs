namespace Exertly.Api.Models;

public class ResumeTemplate
{
    public required string Id { get; set; }
    public required string Name { get; set; }
    public required string Description { get; set; }

    // 'Entry', 'Professional', 'Executive'
    public required string Complexity { get; set; }
    public required string PreviewText { get; set; }
}

public class WorkExperience
{
    public required string Id { get; set; }
    public required string Role { get; set; }
    public required string Company { get; set; }
    public required string Period { get; set; }
    public List<string> Responsibilities { get; set; } = [];
}

public class CustomSection
{
    public required string Id { get; set; }
    public required string Title { get; set; }
    public List<string> Items { get; set; } = [];
}

public class ResumeProfile
{
    public string Name { get; set; } = "";
    public string Title { get; set; } = "";
    public string Email { get; set; } = "";
    public string Phone { get; set; } = "";
    public string Summary { get; set; } = "";
    public List<string> Skills { get; set; } = [];
    public int SelectedTemplateIndex { get; set; }
}
