namespace Exertly.Api.Models;

public class JobListing
{
    public required string Id { get; set; }
    public required string Title { get; set; }
    public required string Company { get; set; }
    public required string Location { get; set; }

    // Simple textual initials used as a placeholder company logo
    public required string LogoText { get; set; }
    public required string SalaryRange { get; set; }
    public required string Type { get; set; }
    public List<string> Tags { get; set; } = [];
}
