using Exertly.Api.Models;

namespace Exertly.Api.Data;

// Seed/mock data mirroring the values used in the Flutter DashboardProvider,
// so the API returns the same content the app currently ships hardcoded.
public static class MockData
{
    public static List<JobListing> Jobs =>
    [
        new JobListing
        {
            Id = "1",
            Title = "Senior Software Engineer",
            Company = "Stripe",
            Location = "San Francisco, CA (Hybrid)",
            LogoText = "St",
            SalaryRange = "$160k - $210k",
            Type = "Full-time",
            Tags = ["Flutter", "API Design", "Dart"],
        },
        new JobListing
        {
            Id = "2",
            Title = "Growth Marketing Manager",
            Company = "Airbnb",
            Location = "New York, NY (Remote)",
            LogoText = "Ab",
            SalaryRange = "$120k - $150k",
            Type = "Full-time",
            Tags = ["Growth", "SEO", "Analytics"],
        },
        new JobListing
        {
            Id = "3",
            Title = "Product Designer",
            Company = "Figma",
            Location = "London, UK (Remote)",
            LogoText = "Fg",
            SalaryRange = "£90k - £110k",
            Type = "Contract",
            Tags = ["UI/UX", "Figma", "Prototyping"],
        },
        new JobListing
        {
            Id = "4",
            Title = "Data Scientist",
            Company = "Snowflake",
            Location = "Bellevue, WA (On-site)",
            LogoText = "Sf",
            SalaryRange = "$150k - $190k",
            Type = "Full-time",
            Tags = ["SQL", "Python", "Machine Learning"],
        },
        new JobListing
        {
            Id = "5",
            Title = "Backend Engineer, Payments",
            Company = "Shopify",
            Location = "Toronto, ON (Hybrid)",
            LogoText = "Sh",
            SalaryRange = "CA$130k - CA$165k",
            Type = "Full-time",
            Tags = ["Ruby", "SQL", "API Design"],
        },
        new JobListing
        {
            Id = "6",
            Title = "Mobile Engineer (Flutter)",
            Company = "Duolingo",
            Location = "Remote (US)",
            LogoText = "Du",
            SalaryRange = "$140k - $175k",
            Type = "Full-time",
            Tags = ["Flutter", "Dart", "Mobile"],
        },
    ];

    public static List<EducationalOpportunity> EducationalOpportunities =>
    [
        new EducationalOpportunity
        {
            Id = "1",
            Title = "Global MBA Leadership Scholarship",
            Institution = "Stanford Graduate School of Business",
            Amount = "$65,000 / Year",
            Deadline = "Oct 15, 2026",
            Category = "Business / Leadership",
        },
        new EducationalOpportunity
        {
            Id = "2",
            Title = "STEM Research Excellence Grant",
            Institution = "MIT School of Engineering",
            Amount = "$45,000",
            Deadline = "Nov 01, 2026",
            Category = "Technology / STEM",
        },
        new EducationalOpportunity
        {
            Id = "3",
            Title = "Knight-Hennessy Scholars Program",
            Institution = "Stanford University",
            Amount = "Full Tuition + Stipend",
            Deadline = "Jan 10, 2027",
            Category = "Multidisciplinary",
        },
        new EducationalOpportunity
        {
            Id = "4",
            Title = "Erasmus Mundus Joint Masters Scholarship",
            Institution = "European Commission",
            Amount = "€24,000 / Year",
            Deadline = "Feb 15, 2027",
            Category = "All Fields / Europe",
        },
        new EducationalOpportunity
        {
            Id = "5",
            Title = "Women in Data Science Fellowship",
            Institution = "Carnegie Mellon University",
            Amount = "$30,000",
            Deadline = "Dec 05, 2026",
            Category = "Technology / STEM",
        },
        new EducationalOpportunity
        {
            Id = "6",
            Title = "European Innovation Grant for Postgraduates",
            Institution = "ETH Zurich",
            Amount = "CHF 40,000",
            Deadline = "Mar 20, 2027",
            Category = "Multidisciplinary / Europe",
        },
    ];

    public static List<ResumeTemplate> ResumeTemplates =>
    [
        new ResumeTemplate
        {
            Id = "1",
            Name = "Corporate Executive",
            Description = "Elegant deep-blue accents. Crafted for corporate and administrative roles.",
            Complexity = "Executive",
            PreviewText = "John Doe\nSenior Software Engineer\njohn.doe@exertly.io | +1 (555) 019-2834\n\nEXPERIENCE\nLead Developer @ TechCorp (2022 - Present)\n- Managed team of 6 engineers\n- Refactored core infrastructure to boost performance by 40%",
        },
        new ResumeTemplate
        {
            Id = "2",
            Name = "Creative Tech Spec",
            Description = "A modern, high-contrast, column-based template perfect for creative design and engineering.",
            Complexity = "Professional",
            PreviewText = "Jane Smith\nSenior UI/UX Designer\njane.smith@exertly.io | +1 (555) 018-9921\n\nSKILLS\nFigma, Design Systems, Mobile Interaction, Usability Testing",
        },
        new ResumeTemplate
        {
            Id = "3",
            Name = "Modern Minimalist",
            Description = "Clean typography, ample white space. Ideal for entry-level professionals.",
            Complexity = "Entry",
            PreviewText = "Alex Rivera\nJunior Web Developer\nalex.rivera@exertly.io\n\nEDUCATION\nB.S. Computer Science - University of Washington (GPA: 3.8)",
        },
    ];

    public static ResumeProfile ResumeProfile => new()
    {
        Name = "John Doe",
        Title = "Senior Software Engineer",
        Email = "john.doe@exertly.io",
        Phone = "+1 (555) 019-2834",
        Summary = "Passionate and results-driven software engineer with 6+ years of experience designing robust architectures and building high-performance mobile and web solutions.",
        Skills = ["Flutter", "Dart", "TypeScript", "Node.js", "System Architecture", "Cloud APIs"],
        SelectedTemplateIndex = 0,
    };

    public static List<WorkExperience> ResumeExperience =>
    [
        new WorkExperience
        {
            Id = "exp1",
            Role = "Lead Developer",
            Company = "TechCorp",
            Period = "2022 - Present",
            Responsibilities =
            [
                "Managed and directed a high-performing squad of 6 cross-functional software engineers.",
                "Refactored core database infrastructure, boosting request performance by 40%.",
                "Established continuous integration (CI/CD) pipelines, reducing release cycles by 15%.",
            ],
        },
        new WorkExperience
        {
            Id = "exp2",
            Role = "Software Engineer",
            Company = "DevStudio",
            Period = "2020 - 2022",
            Responsibilities =
            [
                "Owned frontend feature development for robust consumer mobile and web applications.",
                "Collaborated with product designers to build and launch an atomic design system.",
                "Optimized image loading pipelines, securing a 30% reduction in app startup latency.",
            ],
        },
    ];

    public static List<CustomSection> CustomSections =>
    [
        new CustomSection
        {
            Id = "cert",
            Title = "Certifications",
            Items =
            [
                "AWS Certified Solutions Architect (2025)",
                "Google Certified Associate Android & Flutter Expert",
            ],
        },
        new CustomSection
        {
            Id = "lang",
            Title = "Languages",
            Items =
            [
                "English (Native Speaker)",
                "Spanish (Professional Working Proficiency)",
                "German (Elementary)",
            ],
        },
        new CustomSection
        {
            Id = "award",
            Title = "Awards & Honors",
            Items =
            [
                "TechCorp Innovator of the Year (2024)",
                "MIT Global Hackathon - 1st Place Winner (2025)",
            ],
        },
    ];
}
