namespace Exertly.Api.Models;

// Maps to the Flutter "Scholarship" domain model used by the Scholarship Finder screen
public class EducationalOpportunity
{
    public required string Id { get; set; }
    public required string Title { get; set; }
    public required string Institution { get; set; }
    public required string Amount { get; set; }
    public required string Deadline { get; set; }
    public required string Category { get; set; }
}
