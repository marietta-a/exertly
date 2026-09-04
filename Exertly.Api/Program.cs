using Exertly.Api.Data;
using Exertly.Api.Endpoints;
using Exertly.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// Local, gitignored overrides (Supabase URL/anon key) — see appsettings.Development.local.json.example.
builder.Configuration.AddJsonFile("appsettings.Development.local.json", optional: true, reloadOnChange: true);

builder.Services.AddOpenApi();

// In-memory mock data stores backing the Exertly presentation layer.
builder.Services.AddSingleton<JobStore>();
builder.Services.AddSingleton<EducationalOpportunityStore>();
builder.Services.AddSingleton<ResumeStore>();

builder.Services.Configure<SupabaseOptions>(builder.Configuration.GetSection("Supabase"));
builder.Services.AddHttpClient<SupabaseStorageClient>();
builder.Services.AddHttpClient<SupabaseUserAvatarsClient>();

const string CorsPolicy = "ExertlyClient";
builder.Services.AddCors(options =>
{
    // Wide-open policy: this API only ever serves mock data to the Exertly
    // Flutter app during local development (web, emulator, or device).
    options.AddPolicy(CorsPolicy, policy =>
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors(CorsPolicy);
// No HTTPS redirect: this API only serves local mock data to the Exertly
// Flutter app (web/emulator/desktop), and redirecting to the HTTPS profile
// would require every client to trust the ASP.NET Core dev cert.

app.MapJobEndpoints();
app.MapEducationalOpportunityEndpoints();
app.MapResumeEndpoints();
app.MapAuthEndpoints();
app.MapStorageEndpoints();
app.MapUserAvatarEndpoints();

app.MapGet("/", () => Results.Ok(new { service = "Exertly API", status = "running" }))
    .ExcludeFromDescription();

app.Run();
