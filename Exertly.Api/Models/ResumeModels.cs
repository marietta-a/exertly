using System.Text.Json.Serialization;

namespace Exertly.Api.Models;

public class ResumeTemplate
{
    [JsonPropertyName("id")]
    public required string Id { get; set; }

    [JsonPropertyName("name")]
    public required string Name { get; set; }

    [JsonPropertyName("description")]
    public required string Description { get; set; }

    // 'Entry', 'Professional', 'Executive'
    [JsonPropertyName("complexity")]
    public required string Complexity { get; set; }

    [JsonPropertyName("preview_text")]
    public required string PreviewText { get; set; }
}

public class WorkExperience
{
    [JsonPropertyName("id")]
    public required string Id { get; set; }

    [JsonPropertyName("role")]
    public required string Role { get; set; }

    [JsonPropertyName("company")]
    public required string Company { get; set; }

    [JsonPropertyName("period")]
    public required string Period { get; set; }

    [JsonPropertyName("responsibilities")]
    public List<string> Responsibilities { get; set; } = [];
}

public class CustomSection
{
    [JsonPropertyName("id")]
    public required string Id { get; set; }

    [JsonPropertyName("title")]
    public required string Title { get; set; }

    [JsonPropertyName("items")]
    public List<string> Items { get; set; } = [];
}

public class ResumeProfile
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("title")]
    public string Title { get; set; } = "";

    [JsonPropertyName("email")]
    public string Email { get; set; } = "";

    [JsonPropertyName("phone")]
    public string Phone { get; set; } = "";

    [JsonPropertyName("summary")]
    public string Summary { get; set; } = "";

    [JsonPropertyName("skills")]
    public List<string> Skills { get; set; } = [];

    [JsonPropertyName("selected_template_index")]
    public int SelectedTemplateIndex { get; set; }
}
