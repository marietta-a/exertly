using System.Text.Json.Serialization;

namespace Exertly.Api.Models;

// Mirrors the `user_avatars` table: id (int8 PK), created_at, updated_at,
// user_id (uuid, unique — one row per user), avatar_url (text).
public record UserAvatar
{
    [JsonPropertyName("id")]
    public long Id { get; init; }

    [JsonPropertyName("user_id")]
    public Guid UserId { get; init; }

    [JsonPropertyName("avatar_url")]
    public string AvatarUrl { get; init; } = string.Empty;

    [JsonPropertyName("created_at")]
    public DateTimeOffset CreatedAt { get; init; }

    [JsonPropertyName("updated_at")]
    public DateTimeOffset? UpdatedAt { get; init; }
}

public record UpsertUserAvatarRequest(string AvatarUrl);
