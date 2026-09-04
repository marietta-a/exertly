namespace Exertly.Api.Endpoints;

internal static class HttpRequestExtensions
{
    /// Extracts the bearer token from the Authorization header, or null if absent.
    public static string? GetBearerToken(this HttpRequest request)
    {
        var header = request.Headers.Authorization.ToString();
        return header.StartsWith("Bearer ", StringComparison.Ordinal) ? header["Bearer ".Length..] : null;
    }
}
