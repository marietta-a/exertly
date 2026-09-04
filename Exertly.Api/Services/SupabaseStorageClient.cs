using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace Exertly.Api.Services;

public class SupabaseOptions
{
    public string Url { get; set; } = string.Empty;
    public string AnonKey { get; set; } = string.Empty;
}

public class SupabaseApiException(int statusCode, string message) : Exception(message)
{
    public int StatusCode { get; } = statusCode;
}

/// Thin proxy over the Supabase Storage REST API. Every call forwards the
/// caller's own Supabase access token (never a service-role key), so
/// Supabase's Row Level Security policies — auth.uid() = owner — are what
/// actually decide what a user can read or write. This client only saves the
/// Flutter app from talking to Supabase directly.
public class SupabaseStorageClient
{
    private readonly HttpClient _http;
    private readonly string _publicUrlBase;

    public SupabaseStorageClient(HttpClient http, IOptions<SupabaseOptions> options)
    {
        var opts = options.Value;
        if (string.IsNullOrWhiteSpace(opts.Url) || string.IsNullOrWhiteSpace(opts.AnonKey))
        {
            throw new InvalidOperationException(
                "Supabase:Url and Supabase:AnonKey must be configured (see appsettings.Development.local.json).");
        }

        _publicUrlBase = opts.Url.TrimEnd('/');
        _http = http;
        _http.BaseAddress = new Uri($"{_publicUrlBase}/storage/v1/");
        _http.DefaultRequestHeaders.Add("apikey", opts.AnonKey);
    }

    public async Task<string> UploadAsync(string accessToken, string bucket, string path, Stream content, string? contentType)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, $"object/{bucket}/{EncodePath(path)}")
        {
            Content = new StreamContent(content),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        request.Headers.Add("x-upsert", "true");
        if (contentType != null)
        {
            request.Content.Headers.ContentType = MediaTypeHeaderValue.Parse(contentType);
        }

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        return path;
    }

    public async Task<string> CreateSignedUrlAsync(string accessToken, string bucket, string path, int expiresInSeconds)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, $"object/sign/{bucket}/{EncodePath(path)}")
        {
            Content = JsonContent.Create(new { expiresIn = expiresInSeconds }),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        var signedPath = json.GetProperty("signedURL").GetString()
            ?? throw new InvalidOperationException("Supabase did not return a signed URL.");
        return $"{_publicUrlBase}/storage/v1{signedPath}";
    }

    public string GetPublicUrl(string bucket, string path)
        => $"{_publicUrlBase}/storage/v1/object/public/{bucket}/{EncodePath(path)}";

    public async Task DeleteAsync(string accessToken, string bucket, IEnumerable<string> paths)
    {
        using var request = new HttpRequestMessage(HttpMethod.Delete, $"object/{bucket}")
        {
            Content = JsonContent.Create(new { prefixes = paths }),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
    }

    public async Task<List<string>> ListAsync(string accessToken, string bucket, string prefix)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, $"object/list/{bucket}")
        {
            Content = JsonContent.Create(new { prefix, limit = 1000, offset = 0 }),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        using var response = await _http.SendAsync(request);
        await EnsureSuccessAsync(response);
        var items = await response.Content.ReadFromJsonAsync<List<JsonElement>>();
        return items?.Select(item => item.GetProperty("name").GetString()!).ToList() ?? [];
    }

    private static string EncodePath(string path)
        => string.Join('/', path.Split('/').Select(Uri.EscapeDataString));

    private static async Task EnsureSuccessAsync(HttpResponseMessage response)
    {
        if (response.IsSuccessStatusCode) return;
        var body = await response.Content.ReadAsStringAsync();
        throw new SupabaseApiException((int)response.StatusCode, body);
    }
}
