using Exertly.Api.Models;

namespace Exertly.Api.Data;

// In-memory store for educational opportunities (scholarships/grants) and the
// current user's applied selections.
public class EducationalOpportunityStore
{
    private readonly List<EducationalOpportunity> _opportunities = MockData.EducationalOpportunities;
    private readonly HashSet<string> _appliedIds = [];

    public IReadOnlyList<EducationalOpportunity> GetAll() => _opportunities;

    public EducationalOpportunity? GetById(string id) =>
        _opportunities.FirstOrDefault(o => o.Id == id);

    public IReadOnlyCollection<string> AppliedIds => _appliedIds;

    public bool ToggleApplied(string opportunityId)
    {
        if (!_appliedIds.Add(opportunityId))
        {
            _appliedIds.Remove(opportunityId);
            return false;
        }
        return true;
    }
}
