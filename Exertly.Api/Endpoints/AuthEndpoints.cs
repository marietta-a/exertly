using Exertly.Api.Models;

namespace Exertly.Api.Endpoints;

// Backs lib/presentation/screens/login_screen.dart + lib/providers/auth_provider.dart
// Mirrors AuthProvider's mock behavior: any non-empty email/password succeeds.
public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth").WithTags("Auth");

        group.MapPost("/login", (LoginRequest request) =>
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return Results.BadRequest(new { message = "Email and password are required." });
            }

            return Results.Ok(new
            {
                isAuthenticated = true,
                userEmail = request.Email.Trim(),
                token = Guid.NewGuid().ToString("N"),
            });
        })
        .WithName("Login");

        group.MapPost("/logout", () => Results.Ok(new { isAuthenticated = false }))
            .WithName("Logout");
    }
}
