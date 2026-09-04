using Exertly.Api.Models;
using Exertly.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Exertly.Api.Endpoints;

// Backs lib/services/api/storage_api_service.dart (replaces the old
// lib/services/supabase/supabase_storage_service.dart, which called
// Supabase Storage directly from the Flutter app). Every request must carry
// the caller's Supabase access token as a Bearer token; it's forwarded as-is
// to Supabase, so Storage RLS policies decide what's actually allowed.
public static class StorageEndpoints
{
    public static void MapStorageEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/storage/{bucket}").WithTags("Storage");

        group.MapPost("/files", async (string bucket, HttpRequest httpRequest, SupabaseStorageClient storage) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();
            if (!httpRequest.HasFormContentType) return Results.BadRequest("Expected multipart/form-data.");

            var form = await httpRequest.ReadFormAsync();
            var file = form.Files["file"];
            var userId = form["userId"].ToString();
            var fileName = form["fileName"].ToString();
            if (file == null || string.IsNullOrWhiteSpace(userId) || string.IsNullOrWhiteSpace(fileName))
            {
                return Results.BadRequest("file, userId and fileName are required.");
            }

            await using var stream = file.OpenReadStream();
            try
            {
                var path = await storage.UploadAsync(token, bucket, $"{userId}/{fileName}", stream, file.ContentType);
                return Results.Ok(new { path });
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("UploadStorageFile")
        .DisableAntiforgery();

        group.MapGet("/signed-url", async (string bucket, string path, int? expiresIn, HttpRequest httpRequest, SupabaseStorageClient storage) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();

            try
            {
                var url = await storage.CreateSignedUrlAsync(token, bucket, path, expiresIn ?? 3600);
                return Results.Ok(new { url });
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("GetStorageSignedUrl");

        group.MapGet("/public-url", (string bucket, string path, SupabaseStorageClient storage) =>
            Results.Ok(new { url = storage.GetPublicUrl(bucket, path) }))
            .WithName("GetStoragePublicUrl");

        group.MapGet("/files", async (string bucket, string userId, HttpRequest httpRequest, SupabaseStorageClient storage) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();

            try
            {
                var files = await storage.ListAsync(token, bucket, userId);
                return Results.Ok(files.Select(name => new { name }));
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("ListStorageFiles");

        group.MapDelete("/files", async (string bucket, [FromBody] DeleteFilesRequest request, HttpRequest httpRequest, SupabaseStorageClient storage) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();

            try
            {
                await storage.DeleteAsync(token, bucket, request.Paths);
                return Results.NoContent();
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("DeleteStorageFiles");

        group.MapDelete("/files/all", async (string bucket, string userId, HttpRequest httpRequest, SupabaseStorageClient storage) =>
        {
            var token = httpRequest.GetBearerToken();
            if (token == null) return Results.Unauthorized();

            try
            {
                var files = await storage.ListAsync(token, bucket, userId);
                if (files.Count > 0)
                {
                    await storage.DeleteAsync(token, bucket, files.Select(name => $"{userId}/{name}"));
                }
                return Results.NoContent();
            }
            catch (SupabaseApiException ex)
            {
                return Results.Json(new { message = ex.Message }, statusCode: ex.StatusCode);
            }
        })
        .WithName("DeleteAllStorageFiles");
    }
}
