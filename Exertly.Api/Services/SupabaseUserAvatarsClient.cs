using System.Net.Http.Headers;
using System.Net.Http.Json;
using Exertly.Api.Models;
using Microsoft.Extensions.Options;

namespace Exertly.Api.Services;

/// Thin proxy over the Supabase PostgREST API for the `user_avatars` table.
/// Every call forwards the caller's own Supabase access token (never a
/// service-role key), so the table's Row Level Security policies — scoped to
/// auth.uid() = user_id — are what actually decide what a user can read or
/// write. Mirrors SupabaseStorageClient's approach for Storage.
public class SupabaseUserAvatarsClient
{
    private const string Table = "user_avatars";

    private readonly HttpClient _http;

    public SupabaseUserAvatarsClient(HttpClient http, IOptions<SupabaseOptions> options)
    {
        var opts = options.Value;
        if (string.IsNullOrWhiteSpace(opts.Url) || string.IsNullOrWhiteSpace(opts.AnonKey))
        {
            throw new InvalidOperationException(
                "Supabase:Url and Supabase:AnonKey must be configured (see appsettings.Development.local.json).");
        }

        _http = http;
        _http.BaseAddress = new Uri($"{opts.Url.TrimEnd('/')}/rest/v1/");
        _http.DefaultRequestHeaders.Add("apikey", opts.AnonKey);
    }

    /// Creates a new row for `userId`. Fails with a 409 SupabaseApiException
    /// if one already exists (`user_id` is unique) — use UpsertAsync to
    /// insert-or-replace instead.
    public async Task<UserAvatar> CreateAsync(string accessToken, Guid userId, string avatarUrl)
    {
        using var request = NewRequest(HttpMethod.Post, Table, accessToken);
        request.Headers.Add("Prefer", "return=representation");
        request.Content = JsonContent.Create(new { user_id = userId, avatar_url = avatarUrl });

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        return await FirstRowAsync(response) ?? throw new InvalidOperationException("Supabase did not return the created row.");
    }

    /// Inserts a row for `userId`, or replaces its existing one if present.
    public async Task<UserAvatar> UpsertAsync(string accessToken, Guid userId, string avatarUrl)
    {
        using var request = NewRequest(HttpMethod.Post, $"{Table}?on_conflict=user_id", accessToken);
        request.Headers.Add("Prefer", "resolution=merge-duplicates,return=representation");
        request.Content = JsonContent.Create(new { user_id = userId, avatar_url = avatarUrl });

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        return await FirstRowAsync(response) ?? throw new InvalidOperationException("Supabase did not return the upserted row.");
    }

    /// Returns `userId`'s avatar row, or null if they don't have one.
    public async Task<UserAvatar?> GetByUserIdAsync(string accessToken, Guid userId)
    {
        using var request = NewRequest(HttpMethod.Get, $"{Table}?user_id=eq.{userId}&select=*", accessToken);

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        return await FirstRowAsync(response);
    }

    /// Updates `userId`'s avatar URL. Returns null if they have no row yet.
    public async Task<UserAvatar?> UpdateAsync(string accessToken, Guid userId, string avatarUrl)
    {
        using var request = NewRequest(HttpMethod.Patch, $"{Table}?user_id=eq.{userId}", accessToken);
        request.Headers.Add("Prefer", "return=representation");
        request.Content = JsonContent.Create(new { avatar_url = avatarUrl });

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        return await FirstRowAsync(response);
    }

    /// Deletes `userId`'s avatar row, if any.
    public async Task DeleteAsync(string accessToken, Guid userId)
    {
        using var request = NewRequest(HttpMethod.Delete, $"{Table}?user_id=eq.{userId}", accessToken);

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
    }

    private static HttpRequestMessage NewRequest(HttpMethod method, string requestUri, string accessToken)
    {
        var request = new HttpRequestMessage(method, requestUri);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        return request;
    }

    private static async Task<UserAvatar?> FirstRowAsync(HttpResponseMessage response)
    {
        var rows = await response.Content.ReadFromJsonAsync<List<UserAvatar>>();
        return rows?.FirstOrDefault();
    }

    private static async Task EnsureSuccessAsync(HttpResponseMessage response)
    {
        if (response.IsSuccessStatusCode) return;
        var body = await response.Content.ReadAsStringAsync();
        throw new SupabaseApiException((int)response.StatusCode, body);
    }
}
