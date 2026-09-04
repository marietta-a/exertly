using Exertly.Api.Models;
using Exertly.Api.Services;

namespace Exertly.Api.Endpoints;

// Backs the `user_avatars` persistence currently done directly against
// Supabase Postgres by lib/providers/auth_provider.dart. Every request must
// carry the caller's Supabase access token as a Bearer token; it's forwarded
// as-is to Supabase, so the table's RLS policies (auth.uid() = user_id)
// decide what's actually allowed.
public static class UserAvatarEndpoints
{
    public static void MapUserAvatarEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/user-avatars/{userId:guid}").WithTags("UserAvatars");

        group.MapGet("", async (Guid userId, HttpRequest httpRequest, SupabaseUserAvatarsClient client) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();

            try
            {
                var avatar = await client.GetByUserIdAsync(token, userId);
                return avatar is null ? Results.NotFound() : Results.Ok(avatar);
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("GetUserAvatar");

        group.MapPost("", async (Guid userId, UpsertUserAvatarRequest request, HttpRequest httpRequest, SupabaseUserAvatarsClient client) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();
            if (string.IsNullOrWhiteSpace(request.AvatarUrl)) return Results.BadRequest("avatarUrl is required.");

            try
            {
                var avatar = await client.CreateAsync(token, userId, request.AvatarUrl);
                return Results.Created($"/api/user-avatars/{userId}", avatar);
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("CreateUserAvatar");

        // Insert-or-replace, keyed by user_id — matches AuthProvider.updateAvatarUrl's current upsert behavior.
        group.MapPut("", async (Guid userId, UpsertUserAvatarRequest request, HttpRequest httpRequest, SupabaseUserAvatarsClient client) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();
            if (string.IsNullOrWhiteSpace(request.AvatarUrl)) return Results.BadRequest("avatarUrl is required.");

            try
            {
                var avatar = await client.UpsertAsync(token, userId, request.AvatarUrl);
                return Results.Ok(avatar);
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("UpsertUserAvatar");

        group.MapPatch("", async (Guid userId, UpsertUserAvatarRequest request, HttpRequest httpRequest, SupabaseUserAvatarsClient client) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();
            if (string.IsNullOrWhiteSpace(request.AvatarUrl)) return Results.BadRequest("avatarUrl is required.");

            try
            {
                var avatar = await client.UpdateAsync(token, userId, request.AvatarUrl);
                return avatar is null ? Results.NotFound() : Results.Ok(avatar);
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("UpdateUserAvatar");

        group.MapDelete("", async (Guid userId, HttpRequest httpRequest, SupabaseUserAvatarsClient client) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();

            try
            {
                await client.DeleteAsync(token, userId);
                return Results.NoContent();
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("DeleteUserAvatar");
    }
}
