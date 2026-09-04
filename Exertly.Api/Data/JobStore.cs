using Exertly.Api.Models;

namespace Exertly.Api.Data;

// In-memory store for jobs and the current user's saved-job selections.
// Registered as a singleton so state persists across requests for the life of the process.
public class JobStore
{
    private readonly List<JobListing> _jobs = MockData.Jobs;
    private readonly HashSet<string> _savedJobIds = [];

    public IReadOnlyList<JobListing> GetAll() => _jobs;

    public JobListing? GetById(string id) =>
        _jobs.FirstOrDefault(j => j.Id == id);

    public IReadOnlyCollection<string> SavedJobIds => _savedJobIds;

    public bool ToggleSaved(string jobId)
    {
        if (!_savedJobIds.Add(jobId))
        {
            _savedJobIds.Remove(jobId);
            return false;
        }
        return true;
    }
}
