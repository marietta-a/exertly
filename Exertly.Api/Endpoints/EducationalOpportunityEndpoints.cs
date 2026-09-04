using Exertly.Api.Data;

namespace Exertly.Api.Endpoints;

// Backs lib/presentation/screens/scholarship_finder_screen.dart
public static class EducationalOpportunityEndpoints
{
    public static void MapEducationalOpportunityEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/educational-opportunities").WithTags("EducationalOpportunities");

        group.MapGet("/", (EducationalOpportunityStore store, string? search, string? category) =>
        {
            var opportunities = store.GetAll().AsEnumerable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var query = search.Trim();
                opportunities = opportunities.Where(o =>
                    o.Title.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                    o.Institution.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                    o.Category.Contains(query, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(category) && !category.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                opportunities = opportunities.Where(o => o.Category.Contains(category, StringComparison.OrdinalIgnoreCase));
            }

            return Results.Ok(opportunities.ToList());
        })
        .WithName("GetEducationalOpportunities");

        group.MapGet("/{id}", (string id, EducationalOpportunityStore store) =>
        {
            var opportunity = store.GetById(id);
            return opportunity is not null ? Results.Ok(opportunity) : Results.NotFound();
        })
        .WithName("GetEducationalOpportunityById");

        group.MapGet("/applied", (EducationalOpportunityStore store) =>
        {
            var applied = store.GetAll().Where(o => store.AppliedIds.Contains(o.Id)).ToList();
            return Results.Ok(applied);
        })
        .WithName("GetAppliedEducationalOpportunities");

        group.MapPost("/{id}/apply", (string id, EducationalOpportunityStore store, ResumeStore resumeStore) =>
        {
            var opportunity = store.GetById(id);
            if (opportunity is null) return Results.NotFound();

            var isApplied = store.ToggleApplied(id);
            var profile = resumeStore.GetProfile();

            var message = isApplied
                ? $"Application submitted for {opportunity.Title}! Compiled using your active resume ({profile.Name})."
                : $"Withdrew application from {opportunity.Title}.";

            return Results.Ok(new { opportunityId = id, applied = isApplied, message });
        })
        .WithName("ToggleApplyEducationalOpportunity");
    }
}
