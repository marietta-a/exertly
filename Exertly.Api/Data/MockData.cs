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
            EmploymentType = "Full-time",
            WorkArrangement = "Hybrid",
            DatePosted = "Aug 18, 2026",
            SponsorshipAvailable = true,
            Tags = ["Flutter", "API Design", "Dart"],
            Details = "Join Stripe's Platform team to design and build the APIs and SDKs that power payments for millions of businesses worldwide. You'll work closely with product and infrastructure teams to ship reliable, well-documented interfaces used by developers everywhere.",
            PostingLink = "https://stripe.com/jobs/listing/senior-software-engineer",
        },
        new JobListing
        {
            Id = "2",
            Title = "Growth Marketing Manager",
            Company = "Airbnb",
            Location = "New York, NY (Remote)",
            LogoText = "Ab",
            SalaryRange = "$120k - $150k",
            EmploymentType = "Full-time",
            WorkArrangement = "Remote Only",
            DatePosted = "Aug 22, 2026",
            SponsorshipAvailable = false,
            Tags = ["Growth", "SEO", "Analytics"],
            Details = "Own the growth strategy for a key Airbnb market segment. You'll run experiments across acquisition channels, partner with data science to build attribution models, and drive SEO initiatives that scale organic traffic.",
            PostingLink = "https://careers.airbnb.com/positions/growth-marketing-manager",
        },
        new JobListing
        {
            Id = "3",
            Title = "Product Designer",
            Company = "Figma",
            Location = "London, UK (Remote)",
            LogoText = "Fg",
            SalaryRange = "£90k - £110k",
            EmploymentType = "Contract",
            WorkArrangement = "Remote Only",
            DatePosted = "Aug 25, 2026",
            SponsorshipAvailable = false,
            Tags = ["UI/UX", "Figma", "Prototyping"],
            Details = "Shape the next generation of Figma's design tools. You'll partner with engineers and researchers to prototype, test, and ship features used by millions of designers, from early concept sketches to polished, production-ready flows.",
            PostingLink = "https://www.figma.com/careers/roles/product-designer",
        },
        new JobListing
        {
            Id = "4",
            Title = "Data Scientist",
            Company = "Snowflake",
            Location = "Bellevue, WA (On-site)",
            LogoText = "Sf",
            SalaryRange = "$150k - $190k",
            EmploymentType = "Full-time",
            WorkArrangement = "Onsite",
            DatePosted = "Aug 12, 2026",
            SponsorshipAvailable = true,
            Tags = ["SQL", "Python", "Machine Learning"],
            Details = "Build predictive models and analytics pipelines on top of the Snowflake platform. You'll partner with product teams to surface insights from massive datasets and help drive data-informed decisions across the company.",
            PostingLink = "https://careers.snowflake.com/us/en/job/data-scientist",
        },
        new JobListing
        {
            Id = "5",
            Title = "Backend Engineer, Payments",
            Company = "Shopify",
            Location = "Toronto, ON (Hybrid)",
            LogoText = "Sh",
            SalaryRange = "CA$130k - CA$165k",
            EmploymentType = "Full-time",
            WorkArrangement = "Hybrid",
            DatePosted = "Aug 29, 2026",
            SponsorshipAvailable = false,
            Tags = ["Ruby", "SQL", "API Design"],
            Details = "Help build and scale the payments infrastructure that powers checkout for over a million merchants. You'll design resilient APIs, optimize transaction throughput, and ensure every payment is processed safely and reliably.",
            PostingLink = "https://www.shopify.com/careers/backend-engineer-payments",
        },
        new JobListing
        {
            Id = "6",
            Title = "Mobile Engineer (Flutter)",
            Company = "Duolingo",
            Location = "Remote (US)",
            LogoText = "Du",
            SalaryRange = "$140k - $175k",
            EmploymentType = "Full-time",
            WorkArrangement = "Remote Only",
            DatePosted = "Sep 01, 2026",
            SponsorshipAvailable = false,
            Tags = ["Flutter", "Dart", "Mobile"],
            Details = "Build delightful, high-performance learning experiences for Duolingo's mobile apps using Flutter. You'll collaborate with designers and learning scientists to ship features that keep millions of learners coming back every day.",
            PostingLink = "https://careers.duolingo.com/jobs/mobile-engineer-flutter",
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
            Location = "Stanford, CA",
            DatePosted = "Aug 05, 2026",
            Type = "On Campus",
            DegreeType = "Master's",
            EligibilityCriteria = ["Admitted to the Stanford MBA program", "Minimum 3 years of leadership or management experience", "Demonstrated community impact"],
            EligibleCountries = ["All"],
            Details = "Awarded to incoming MBA candidates who demonstrate exceptional leadership potential and a track record of driving impact in their communities or workplaces. Covers tuition, and recipients join a mentorship cohort with Stanford GSB alumni.",
            PostingLink = "https://www.gsb.stanford.edu/programs/mba/financial-aid/fellowships",
        },
        new EducationalOpportunity
        {
            Id = "2",
            Title = "STEM Research Excellence Grant",
            Institution = "MIT School of Engineering",
            Amount = "$45,000",
            Deadline = "Nov 01, 2026",
            Category = "Technology / STEM",
            Location = "Cambridge, MA",
            DatePosted = "Aug 10, 2026",
            Type = "On Campus",
            DegreeType = "PhD / Research",
            EligibilityCriteria = ["Enrolled in an MIT graduate engineering or applied science program", "Original, unpublished research proposal"],
            EligibleCountries = ["United States"],
            Details = "Supports graduate researchers pursuing original work in engineering or applied sciences. Grant funds cover research materials, conference travel, and a stipend for up to one year, with priority given to projects addressing sustainability or accessibility.",
            PostingLink = "https://engineering.mit.edu/research/graduate-funding",
        },
        new EducationalOpportunity
        {
            Id = "3",
            Title = "Knight-Hennessy Scholars Program",
            Institution = "Stanford University",
            Amount = "Full Tuition + Stipend",
            Deadline = "Jan 10, 2027",
            Category = "Multidisciplinary",
            Location = "Stanford, CA",
            DatePosted = "Jul 28, 2026",
            Type = "On Campus",
            DegreeType = "PhD / Research",
            EligibilityCriteria = ["Applying to or admitted into any Stanford graduate program", "No more than 5 years of relevant work experience", "Demonstrated leadership potential"],
            EligibleCountries = ["All"],
            Details = "A fully-funded, multidisciplinary graduate fellowship for future global leaders across any Stanford graduate program. Scholars join a three-year leadership development experience alongside a diverse, interdisciplinary cohort.",
            PostingLink = "https://knight-hennessy.stanford.edu/apply",
        },
        new EducationalOpportunity
        {
            Id = "4",
            Title = "Erasmus Mundus Joint Masters Scholarship",
            Institution = "European Commission",
            Amount = "€24,000 / Year",
            Deadline = "Feb 15, 2027",
            Category = "All Fields / Europe",
            Location = "Multiple EU campuses",
            DatePosted = "Aug 01, 2026",
            Type = "On Campus",
            DegreeType = "Master's",
            EligibilityCriteria = ["Bachelor's degree or equivalent", "Admission to a participating Erasmus Mundus Joint Master Degree program"],
            EligibleCountries = ["All"],
            Details = "Fully-funded scholarship for students admitted to an Erasmus Mundus Joint Master Degree, covering tuition, travel, installation, and a monthly living allowance while studying across two or more European universities.",
            PostingLink = "https://ec.europa.eu/programmes/erasmus-plus/opportunities/individuals/students/erasmus-mundus-joint-master-degrees_en",
        },
        new EducationalOpportunity
        {
            Id = "5",
            Title = "Women in Data Science Fellowship",
            Institution = "Carnegie Mellon University",
            Amount = "$30,000",
            Deadline = "Dec 05, 2026",
            Category = "Technology / STEM",
            Location = "Pittsburgh, PA",
            DatePosted = "Aug 14, 2026",
            Type = "Online Studies",
            DegreeType = "Master's",
            EligibilityCriteria = ["Identifies as a woman", "Enrolled in a graduate data science, statistics, or machine learning program"],
            EligibleCountries = ["United States", "Canada"],
            Details = "Supports women pursuing graduate studies in data science, statistics, or machine learning. Fellows receive funding, a faculty mentor, and access to CMU's data science industry partner network for internships and research collaborations.",
            PostingLink = "https://www.cmu.edu/graduate/funding/women-in-data-science-fellowship",
        },
        new EducationalOpportunity
        {
            Id = "6",
            Title = "European Innovation Grant for Postgraduates",
            Institution = "ETH Zurich",
            Amount = "CHF 40,000",
            Deadline = "Mar 20, 2027",
            Category = "Multidisciplinary / Europe",
            Location = "Zurich, Switzerland",
            DatePosted = "Aug 20, 2026",
            Type = "Certification Program",
            DegreeType = "PhD / Research",
            EligibilityCriteria = ["Postgraduate researcher in science or engineering", "Original, high-impact project proposal"],
            EligibleCountries = ["All"],
            Details = "Funds postgraduate researchers developing innovative, high-impact projects across science and engineering disciplines. Includes access to ETH Zurich's labs and an annual innovation showcase with European industry partners.",
            PostingLink = "https://ethz.ch/en/studies/financial/scholarships/innovation-grant.html",
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
