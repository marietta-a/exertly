using Exertly.Api.Data;

namespace Exertly.Api.Endpoints;

// Backs lib/presentation/screens/job_opportunities_screen.dart
public static class JobEndpoints
{
    public static void MapJobEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/jobs").WithTags("Jobs");

        group.MapGet("/", (JobStore store, string? search, string? category) =>
        {
            var jobs = store.GetAll().AsEnumerable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var query = search.Trim();
                jobs = jobs.Where(j =>
                    j.Title.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                    j.Company.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                    j.Location.Contains(query, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(category) && !category.Equals("All", StringComparison.OrdinalIgnoreCase))
            {
                jobs = jobs.Where(j => j.Tags.Contains(category, StringComparer.OrdinalIgnoreCase));
            }

            return Results.Ok(jobs.ToList());
        })
        .WithName("GetJobs");

        group.MapGet("/{id}", (string id, JobStore store) =>
        {
            var job = store.GetById(id);
            return job is not null ? Results.Ok(job) : Results.NotFound();
        })
        .WithName("GetJobById");

        group.MapGet("/saved", (JobStore store) =>
        {
            var saved = store.GetAll().Where(j => store.SavedJobIds.Contains(j.Id)).ToList();
            return Results.Ok(saved);
        })
        .WithName("GetSavedJobs");

        group.MapPost("/{id}/save", (string id, JobStore store) =>
        {
            var job = store.GetById(id);
            if (job is null) return Results.NotFound();

            var isSaved = store.ToggleSaved(id);
            return Results.Ok(new { jobId = id, saved = isSaved });
        })
        .WithName("ToggleSaveJob");

        group.MapPost("/{id}/apply", (string id, JobStore store, ResumeStore resumeStore) =>
        {
            var job = store.GetById(id);
            if (job is null) return Results.NotFound();

            var profile = resumeStore.GetProfile();
            return Results.Ok(new
            {
                message = $"Successfully applied to {job.Title} at {job.Company}!",
                applicant = profile.Name,
                appliedWithResume = profile.Title,
            });
        })
        .WithName("ApplyToJob");
    }
}
