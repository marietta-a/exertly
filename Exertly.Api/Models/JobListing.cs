using System.Text.Json.Serialization;

namespace Exertly.Api.Models;

public class JobListing
{
    [JsonPropertyName("id")]
    public required string Id { get; set; }

    [JsonPropertyName("title")]
    public required string Title { get; set; }

    [JsonPropertyName("company")]
    public required string Company { get; set; }

    [JsonPropertyName("location")]
    public required string Location { get; set; }

    // Simple textual initials used as a placeholder company logo
    [JsonPropertyName("logo_text")]
    public required string LogoText { get; set; }

    [JsonPropertyName("salary_range")]
    public required string SalaryRange { get; set; }

    // 'Full-time', 'Part-time', 'Contract', 'Internship'
    [JsonPropertyName("employment_type")]
    public required string EmploymentType { get; set; }

    // 'Remote Only', 'Onsite', 'Hybrid'
    [JsonPropertyName("work_arrangement")]
    public string WorkArrangement { get; set; } = "";

    [JsonPropertyName("date_posted")]
    public string DatePosted { get; set; } = "";

    // Whether the employer offers visa sponsorship for this role
    [JsonPropertyName("sponsorship_available")]
    public bool SponsorshipAvailable { get; set; }

    [JsonPropertyName("tags")]
    public List<string> Tags { get; set; } = [];

    // Full role description shown in the job detail view
    [JsonPropertyName("details")]
    public string Details { get; set; } = "";

    // External URL to the original job posting
    [JsonPropertyName("posting_link")]
    public string PostingLink { get; set; } = "";
}
