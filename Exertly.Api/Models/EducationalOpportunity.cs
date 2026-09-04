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

    // Full opportunity description shown in the detail view
    public string Details { get; set; } = "";

    // External URL to the original scholarship/grant posting
    public string PostingLink { get; set; } = "";
}
