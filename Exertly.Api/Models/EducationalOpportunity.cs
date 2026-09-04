using System.Text.Json.Serialization;

namespace Exertly.Api.Models;

// Maps to the Flutter "Scholarship" domain model used by the Scholarship Finder screen
public class EducationalOpportunity
{
    [JsonPropertyName("id")]
    public required string Id { get; set; }

    [JsonPropertyName("title")]
    public required string Title { get; set; }

    [JsonPropertyName("institution")]
    public required string Institution { get; set; }

    [JsonPropertyName("amount")]
    public required string Amount { get; set; }

    [JsonPropertyName("deadline")]
    public required string Deadline { get; set; }

    [JsonPropertyName("category")]
    public required string Category { get; set; }

    [JsonPropertyName("location")]
    public string Location { get; set; } = "";

    [JsonPropertyName("date_posted")]
    public string DatePosted { get; set; } = "";

    // 'Online Studies', 'Certification Program', 'On Campus'
    [JsonPropertyName("type")]
    public string Type { get; set; } = "";

    // 'Undergraduate', 'Master's', 'PhD / Research', 'Postdoctoral'
    [JsonPropertyName("degree_type")]
    public string DegreeType { get; set; } = "";

    [JsonPropertyName("eligibility_criteria")]
    public List<string> EligibilityCriteria { get; set; } = [];

    // ISO country names, or e.g. ["All"] when open worldwide
    [JsonPropertyName("eligible_countries")]
    public List<string> EligibleCountries { get; set; } = [];

    // Full opportunity description shown in the detail view
    [JsonPropertyName("details")]
    public string Details { get; set; } = "";

    // External URL to the original scholarship/grant posting
    [JsonPropertyName("posting_link")]
    public string PostingLink { get; set; } = "";
}
