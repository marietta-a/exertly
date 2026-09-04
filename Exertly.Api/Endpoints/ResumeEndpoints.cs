using Exertly.Api.Data;
using Exertly.Api.Models;

namespace Exertly.Api.Endpoints;

// Backs lib/presentation/screens/cv_builder_screen.dart
public static class ResumeEndpoints
{
    public static void MapResumeEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/resume").WithTags("Resume");

        group.MapGet("/templates", (ResumeStore store) => Results.Ok(store.Templates))
            .WithName("GetResumeTemplates");

        group.MapPost("/templates/select", (SelectTemplateRequest request, ResumeStore store) =>
            store.SelectTemplate(request.Index) ? Results.Ok(store.GetProfile()) : Results.BadRequest("Invalid template index."))
            .WithName("SelectResumeTemplate");

        group.MapGet("/profile", (ResumeStore store) => Results.Ok(store.GetProfile()))
            .WithName("GetResumeProfile");

        group.MapPut("/profile", (UpdateResumeProfileRequest request, ResumeStore store) =>
        {
            store.UpdateProfile(request.Name, request.Title, request.Email, request.Phone, request.Summary);
            return Results.Ok(store.GetProfile());
        })
        .WithName("UpdateResumeProfile");

        group.MapPost("/skills", (AddSkillRequest request, ResumeStore store) =>
            store.AddSkill(request.Skill) ? Results.Ok(store.GetProfile()) : Results.BadRequest("Skill is empty or already present."))
            .WithName("AddResumeSkill");

        group.MapDelete("/skills/{skill}", (string skill, ResumeStore store) =>
            store.RemoveSkill(skill) ? Results.Ok(store.GetProfile()) : Results.NotFound())
            .WithName("RemoveResumeSkill");

        group.MapGet("/experience", (ResumeStore store) => Results.Ok(store.GetExperience()))
            .WithName("GetResumeExperience");

        group.MapPost("/experience", (AddExperienceRequest request, ResumeStore store) =>
        {
            if (string.IsNullOrWhiteSpace(request.Role) || string.IsNullOrWhiteSpace(request.Company))
            {
                return Results.BadRequest("Role and company are required.");
            }
            var experience = store.AddExperience(request.Role, request.Company, request.Period);
            return Results.Created($"/api/resume/experience/{experience.Id}", experience);
        })
        .WithName("AddResumeExperience");

        group.MapDelete("/experience/{id}", (string id, ResumeStore store) =>
            store.RemoveExperience(id) ? Results.NoContent() : Results.NotFound())
            .WithName("RemoveResumeExperience");

        group.MapPost("/experience/{id}/responsibilities", (string id, AddResponsibilityRequest request, ResumeStore store) =>
            store.AddResponsibility(id, request.Responsibility) ? Results.Ok(store.GetExperience()) : Results.BadRequest())
            .WithName("AddResumeResponsibility");

        group.MapDelete("/experience/{id}/responsibilities/{index:int}", (string id, int index, ResumeStore store) =>
            store.RemoveResponsibility(id, index) ? Results.Ok(store.GetExperience()) : Results.BadRequest())
            .WithName("RemoveResumeResponsibility");

        group.MapGet("/sections", (ResumeStore store) => Results.Ok(store.GetCustomSections()))
            .WithName("GetResumeCustomSections");

        group.MapPost("/sections", (AddCustomSectionRequest request, ResumeStore store) =>
        {
            if (string.IsNullOrWhiteSpace(request.Title)) return Results.BadRequest("Title is required.");
            var section = store.AddCustomSection(request.Title);
            return Results.Created($"/api/resume/sections/{section.Id}", section);
        })
        .WithName("AddResumeCustomSection");

        group.MapDelete("/sections/{id}", (string id, ResumeStore store) =>
            store.RemoveCustomSection(id) ? Results.NoContent() : Results.NotFound())
            .WithName("RemoveResumeCustomSection");

        group.MapPost("/sections/{id}/items", (string id, AddSectionItemRequest request, ResumeStore store) =>
            store.AddItemToSection(id, request.Item) ? Results.Ok(store.GetCustomSections()) : Results.BadRequest())
            .WithName("AddResumeSectionItem");

        group.MapDelete("/sections/{id}/items/{index:int}", (string id, int index, ResumeStore store) =>
            store.RemoveItemFromSection(id, index) ? Results.Ok(store.GetCustomSections()) : Results.BadRequest())
            .WithName("RemoveResumeSectionItem");
    }
}
