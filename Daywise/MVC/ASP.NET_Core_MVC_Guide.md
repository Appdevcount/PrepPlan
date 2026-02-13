# ASP.NET Core MVC - Comprehensive Guide

## Table of Contents

1. [Introduction & Architecture](#1-introduction--architecture)
2. [Project Structure & Program.cs](#2-project-structure--programcs)
3. [Middleware Pipeline](#3-middleware-pipeline)
4. [Routing](#4-routing)
5. [Controllers & Actions](#5-controllers--actions)
6. [Model Binding & Validation](#6-model-binding--validation)
7. [Views & Razor Syntax](#7-views--razor-syntax)
8. [Tag Helpers & HTML Helpers](#8-tag-helpers--html-helpers)
9. [Dependency Injection](#9-dependency-injection)
10. [Entity Framework Core](#10-entity-framework-core)
11. [State Management](#11-state-management)
12. [Filters](#12-filters)
13. [View Components & Partial Views](#13-view-components--partial-views)
14. [Areas](#14-areas)
15. [Authentication & Authorization](#15-authentication--authorization)
16. [Web API in MVC](#16-web-api-in-mvc)
17. [Configuration & Environments](#17-configuration--environments)
18. [Logging](#18-logging)
19. [Caching](#19-caching)
20. [Error Handling](#20-error-handling)
21. [SignalR (Real-Time)](#21-signalr-real-time)
22. [Unit Testing](#22-unit-testing)
23. [Deployment](#23-deployment)
24. [Real Interview Experiences - Indian Service Companies](#24-real-interview-experiences---indian-service-companies)

---

## 1. Introduction & Architecture

### What is ASP.NET Core MVC?

ASP.NET Core MVC is a cross-platform, high-performance framework for building web applications using the **Model-View-Controller** design pattern.

### MVC Pattern

```
┌─────────────────────────────────────────────┐
│                  Browser                     │
│            (HTTP Request/Response)           │
└─────────────┬───────────────────┬───────────┘
              │ Request           │ Response (HTML)
              ▼                   ▲
┌─────────────────────────────────────────────┐
│               CONTROLLER                     │
│  - Receives request                          │
│  - Processes input                           │
│  - Calls Model                               │
│  - Selects View                              │
└──────┬──────────────────────────┬───────────┘
       │ Reads/Writes             │ Passes Model
       ▼                          ▼
┌──────────────┐          ┌──────────────────┐
│    MODEL     │          │      VIEW        │
│ - Data       │          │ - Razor (.cshtml)│
│ - Business   │          │ - Displays data  │
│   Logic      │          │ - UI rendering   │
│ - Validation │          │                  │
└──────────────┘          └──────────────────┘
```

### .NET Core vs .NET Framework

| Feature | .NET Core / .NET 6+ | .NET Framework |
|---------|---------------------|----------------|
| Platform | Cross-platform (Win/Linux/Mac) | Windows only |
| Performance | High (Kestrel) | Moderate (IIS) |
| Deployment | Self-contained / Framework-dependent | GAC / bin |
| Open Source | Yes | Partially |
| Microservices | Built for it | Not ideal |
| Hosting | Kestrel, IIS, Docker | IIS only |
| NuGet | All libraries via NuGet | Mix of GAC + NuGet |
| Minimal API | Supported | Not available |
| Future | Active development | Maintenance mode |

### Key Features of ASP.NET Core

- **Cross-Platform**: Runs on Windows, Linux, macOS
- **High Performance**: One of the fastest web frameworks (TechEmpower benchmarks)
- **Built-in DI**: First-class Dependency Injection support
- **Unified Framework**: MVC + Web API merged into single framework
- **Middleware Pipeline**: Composable request processing
- **Cloud-Ready**: Built for containers, microservices, cloud deployment
- **Open Source**: Fully open source on GitHub

---

## 2. Project Structure & Program.cs

### Typical MVC Project Structure

```
MyMvcApp/
├── Controllers/
│   ├── HomeController.cs
│   └── ProductController.cs
├── Models/
│   ├── Product.cs
│   └── ErrorViewModel.cs
├── Views/
│   ├── Home/
│   │   ├── Index.cshtml
│   │   └── Privacy.cshtml
│   ├── Product/
│   │   ├── Index.cshtml
│   │   ├── Create.cshtml
│   │   └── Edit.cshtml
│   ├── Shared/
│   │   ├── _Layout.cshtml
│   │   ├── _ValidationScriptsPartial.cshtml
│   │   └── Error.cshtml
│   ├── _ViewImports.cshtml
│   └── _ViewStart.cshtml
├── wwwroot/
│   ├── css/
│   ├── js/
│   └── lib/
├── Data/
│   └── ApplicationDbContext.cs
├── Services/
│   └── EmailService.cs
├── appsettings.json
├── appsettings.Development.json
└── Program.cs
```

### Program.cs (.NET 6+ Minimal Hosting Model)

```csharp
var builder = WebApplication.CreateBuilder(args);

// ===== SERVICE REGISTRATION (ConfigureServices) =====
builder.Services.AddControllersWithViews();
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
});
builder.Services.AddMemoryCache();

var app = builder.Build();

// ===== MIDDLEWARE PIPELINE (Configure) =====
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.UseSession();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
```

### Old Startup.cs Pattern (Before .NET 6)

```csharp
public class Startup
{
    public IConfiguration Configuration { get; }

    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    // Service registration
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllersWithViews();
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(Configuration.GetConnectionString("Default")));
    }

    // Middleware pipeline
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
            app.UseDeveloperExceptionPage();
        else
            app.UseExceptionHandler("/Home/Error");

        app.UseStaticFiles();
        app.UseRouting();
        app.UseAuthentication();
        app.UseAuthorization();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllerRoute("default", "{controller=Home}/{action=Index}/{id?}");
        });
    }
}
```

> **Interview Tip**: Know both patterns. Many companies still have legacy projects using Startup.cs.

---

## 3. Middleware Pipeline

### What is Middleware?

Middleware is software assembled into an application pipeline to handle requests and responses. Each component:
- Chooses whether to pass the request to the next component
- Can perform work before and after the next component

```
Request → [Middleware 1] → [Middleware 2] → [Middleware 3] → Endpoint
Response ← [Middleware 1] ← [Middleware 2] ← [Middleware 3] ←
```

### Middleware Order (CRITICAL - Order Matters!)

```csharp
app.UseExceptionHandler("/Error");  // 1. Exception handling (outermost)
app.UseHsts();                       // 2. HSTS
app.UseHttpsRedirection();           // 3. HTTPS redirect
app.UseStaticFiles();                // 4. Static files (short-circuits)
app.UseRouting();                    // 5. Routing
app.UseCors();                       // 6. CORS
app.UseAuthentication();             // 7. Authentication
app.UseAuthorization();              // 8. Authorization
app.UseSession();                    // 9. Session
app.UseResponseCaching();            // 10. Response caching
app.MapControllers();                // 11. Endpoint execution
```

### Custom Middleware - Inline

```csharp
app.Use(async (context, next) =>
{
    // Before next middleware
    Console.WriteLine($"Request: {context.Request.Path}");
    var stopwatch = Stopwatch.StartNew();

    await next.Invoke(); // Call next middleware

    // After next middleware
    stopwatch.Stop();
    Console.WriteLine($"Response Time: {stopwatch.ElapsedMilliseconds}ms");
});
```

### Custom Middleware - Class Based

```csharp
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next,
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Pre-processing
        _logger.LogInformation("Handling request: {Path}", context.Request.Path);

        await _next(context);

        // Post-processing
        _logger.LogInformation("Response status: {StatusCode}",
            context.Response.StatusCode);
    }
}

// Extension method for clean registration
public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(
        this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}

// Usage in Program.cs
app.UseRequestLogging();
```

### Map / MapWhen - Conditional Middleware

```csharp
// Branch pipeline based on path
app.Map("/api", apiApp =>
{
    apiApp.UseMiddleware<ApiKeyMiddleware>();
});

// Branch based on condition
app.MapWhen(context => context.Request.Query.ContainsKey("branch"), appBranch =>
{
    appBranch.UseMiddleware<BranchMiddleware>();
});

// UseWhen - rejoins the main pipeline
app.UseWhen(context => context.Request.Path.StartsWithSegments("/admin"), appBuilder =>
{
    appBuilder.UseMiddleware<AdminLoggingMiddleware>();
});
```

### Terminal Middleware (app.Run)

```csharp
// Run = terminal middleware, does NOT call next
app.Run(async context =>
{
    await context.Response.WriteAsync("Terminal - pipeline ends here");
});
```

### Key Differences: Use vs Run vs Map

| Method | Calls Next? | Purpose |
|--------|-------------|---------|
| `Use` | Yes (optional) | General-purpose middleware |
| `Run` | No (terminal) | Ends the pipeline |
| `Map` | Branches | Conditional branching by path |
| `MapWhen` | Branches | Conditional branching by predicate |
| `UseWhen` | Yes (rejoins) | Conditional + rejoins main pipeline |

---

## 4. Routing

### Convention-Based Routing

```csharp
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Multiple routes
app.MapControllerRoute(
    name: "blog",
    pattern: "blog/{year}/{month}/{slug}",
    defaults: new { controller = "Blog", action = "Post" });

app.MapControllerRoute(
    name: "admin",
    pattern: "admin/{controller=Dashboard}/{action=Index}/{id?}");
```

### Attribute Routing

```csharp
[Route("products")]
public class ProductController : Controller
{
    [HttpGet]             // GET /products
    public IActionResult Index() => View();

    [HttpGet("{id:int}")] // GET /products/5
    public IActionResult Details(int id) => View();

    [HttpGet("category/{name}")] // GET /products/category/electronics
    public IActionResult ByCategory(string name) => View();

    [HttpPost("create")]  // POST /products/create
    public IActionResult Create(Product model) => View();
}
```

### Route Constraints

```csharp
[HttpGet("{id:int}")]               // Integer only
[HttpGet("{name:alpha}")]           // Letters only
[HttpGet("{id:min(1)}")]            // Minimum value 1
[HttpGet("{id:range(1,100)}")]      // Between 1 and 100
[HttpGet("{slug:regex(^[a-z-]+$)}")] // Regex pattern
[HttpGet("{filename:length(5,50)}")] // String length 5-50
[HttpGet("{id:guid}")]              // GUID format
[HttpGet("{date:datetime}")]        // DateTime format

// Combined constraints
[HttpGet("{id:int:min(1):max(1000)}")]

// Optional parameter with constraint
[HttpGet("{id:int?}")]
```

### Custom Route Constraint

```csharp
public class EvenNumberConstraint : IRouteConstraint
{
    public bool Match(HttpContext? httpContext, IRouter? route,
        string routeKey, RouteValueDictionary values,
        RouteDirection routeDirection)
    {
        if (values.TryGetValue(routeKey, out var value) &&
            int.TryParse(value?.ToString(), out int intValue))
        {
            return intValue % 2 == 0;
        }
        return false;
    }
}

// Register in Program.cs
builder.Services.AddRouting(options =>
{
    options.ConstraintMap.Add("even", typeof(EvenNumberConstraint));
});

// Usage
[HttpGet("{id:even}")]
public IActionResult EvenProduct(int id) => View();
```

---

## 5. Controllers & Actions

### Basic Controller

```csharp
public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger; // Injected via DI
    }

    public IActionResult Index()
    {
        return View(); // Returns Views/Home/Index.cshtml
    }

    public IActionResult About()
    {
        ViewData["Title"] = "About Us";
        return View();
    }
}
```

### Action Result Types

```csharp
public class DemoController : Controller
{
    // ViewResult - renders a view
    public IActionResult ShowView() => View();
    public IActionResult NamedView() => View("CustomView");
    public IActionResult ViewWithModel() => View(new Product { Name = "Phone" });

    // RedirectResult - HTTP redirect
    public IActionResult GoHome() => Redirect("/Home/Index");
    public IActionResult GoAction() => RedirectToAction("Index", "Home");
    public IActionResult GoPermanent() => RedirectPermanent("/new-url");
    public IActionResult GoRoute() =>
        RedirectToRoute(new { controller = "Home", action = "Index" });

    // JsonResult - returns JSON
    public IActionResult GetJson() => Json(new { name = "Test", id = 1 });

    // ContentResult - plain text
    public IActionResult GetText() => Content("Hello World", "text/plain");

    // FileResult - file download
    public IActionResult Download()
    {
        byte[] fileBytes = System.IO.File.ReadAllBytes("report.pdf");
        return File(fileBytes, "application/pdf", "report.pdf");
    }

    // StatusCodeResult
    public IActionResult NotFoundPage() => NotFound();                // 404
    public IActionResult BadReq() => BadRequest("Invalid input");     // 400
    public IActionResult Denied() => Unauthorized();                   // 401
    public IActionResult Forbidden() => Forbid();                      // 403
    public IActionResult NoContent() => NoContent();                   // 204
    public IActionResult ServerError() => StatusCode(500);             // 500
    public IActionResult Created() =>
        CreatedAtAction("Details", new { id = 1 }, new Product());    // 201

    // PartialViewResult
    public IActionResult GetPartial() => PartialView("_ProductCard");

    // EmptyResult
    public IActionResult DoNothing() => new EmptyResult();
}
```

### IActionResult vs ActionResult<T>

```csharp
// IActionResult - can return any result type
public IActionResult Get(int id)
{
    var product = _repo.Find(id);
    if (product == null) return NotFound();
    return Ok(product);
}

// ActionResult<T> - strongly typed (better for API documentation / Swagger)
public ActionResult<Product> Get(int id)
{
    var product = _repo.Find(id);
    if (product == null) return NotFound();
    return product; // Implicit conversion
}
```

### Async Actions

```csharp
public class ProductController : Controller
{
    private readonly IProductService _productService;

    public ProductController(IProductService productService)
    {
        _productService = productService;
    }

    public async Task<IActionResult> Index()
    {
        var products = await _productService.GetAllAsync();
        return View(products);
    }

    public async Task<IActionResult> Details(int id)
    {
        var product = await _productService.GetByIdAsync(id);
        if (product == null)
            return NotFound();
        return View(product);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(ProductViewModel model)
    {
        if (!ModelState.IsValid)
            return View(model);

        await _productService.CreateAsync(model);
        TempData["Success"] = "Product created successfully!";
        return RedirectToAction(nameof(Index));
    }
}
```

---

## 6. Model Binding & Validation

### Model Binding Sources

```csharp
public class OrderController : Controller
{
    // From route: /order/5
    public IActionResult Details([FromRoute] int id) => View();

    // From query string: /order/search?name=phone&page=1
    public IActionResult Search([FromQuery] string name,
                                [FromQuery] int page = 1) => View();

    // From form body (POST)
    [HttpPost]
    public IActionResult Create([FromForm] OrderModel model) => View();

    // From JSON body (API)
    [HttpPost]
    public IActionResult CreateApi([FromBody] OrderModel model) => Ok();

    // From header
    public IActionResult Check([FromHeader(Name = "X-Api-Key")] string apiKey)
        => Ok();

    // From services (DI)
    public IActionResult Index([FromServices] IOrderService service) => View();
}
```

### Binding Priority Order
1. Form data (POST body)
2. Route values (`{id}`)
3. Query string (`?id=5`)

### Data Annotations Validation

```csharp
public class RegisterViewModel
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2,
        ErrorMessage = "Name must be between 2 and 100 characters")]
    [Display(Name = "Full Name")]
    public string Name { get; set; }

    [Required]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; }

    [Required]
    [DataType(DataType.Password)]
    [StringLength(100, MinimumLength = 6)]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$",
        ErrorMessage = "Must have uppercase, lowercase, and digit")]
    public string Password { get; set; }

    [DataType(DataType.Password)]
    [Compare("Password", ErrorMessage = "Passwords do not match")]
    [Display(Name = "Confirm Password")]
    public string ConfirmPassword { get; set; }

    [Range(18, 120, ErrorMessage = "Age must be between 18 and 120")]
    public int Age { get; set; }

    [Required]
    [Phone]
    public string PhoneNumber { get; set; }

    [Url]
    public string Website { get; set; }

    [Range(typeof(bool), "true", "true",
        ErrorMessage = "You must accept the terms")]
    public bool AcceptTerms { get; set; }
}
```

### Custom Validation Attribute

```csharp
public class FutureDateAttribute : ValidationAttribute
{
    protected override ValidationResult? IsValid(
        object? value, ValidationContext validationContext)
    {
        if (value is DateTime date)
        {
            if (date <= DateTime.Now)
                return new ValidationResult("Date must be in the future");
        }
        return ValidationResult.Success;
    }
}

// Usage
public class Event
{
    [Required]
    public string Title { get; set; }

    [FutureDate(ErrorMessage = "Event date must be in the future")]
    public DateTime EventDate { get; set; }
}
```

### IValidatableObject - Model-Level Validation

```csharp
public class DateRangeModel : IValidatableObject
{
    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    public IEnumerable<ValidationResult> Validate(
        ValidationContext validationContext)
    {
        if (EndDate <= StartDate)
        {
            yield return new ValidationResult(
                "End date must be after start date",
                new[] { nameof(EndDate) });
        }

        if (StartDate < DateTime.Today)
        {
            yield return new ValidationResult(
                "Start date cannot be in the past",
                new[] { nameof(StartDate) });
        }
    }
}
```

### FluentValidation (Popular Library)

```csharp
// Install: dotnet add package FluentValidation.AspNetCore

public class ProductValidator : AbstractValidator<Product>
{
    public ProductValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Product name is required")
            .MaximumLength(200);

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Price must be positive")
            .LessThan(1000000);

        RuleFor(x => x.Category)
            .NotEmpty()
            .Must(BeAValidCategory).WithMessage("Invalid category");

        RuleFor(x => x.Email)
            .EmailAddress()
            .When(x => !string.IsNullOrEmpty(x.Email));
    }

    private bool BeAValidCategory(string category)
    {
        var validCategories = new[] { "Electronics", "Books", "Clothing" };
        return validCategories.Contains(category);
    }
}

// Register in Program.cs
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<ProductValidator>();
```

### Controller Validation Check

```csharp
[HttpPost]
[ValidateAntiForgeryToken]
public async Task<IActionResult> Create(ProductViewModel model)
{
    if (!ModelState.IsValid)
    {
        // Return view with validation errors
        return View(model);
    }

    // Manual model state error
    if (await _service.ExistsAsync(model.Name))
    {
        ModelState.AddModelError(nameof(model.Name),
            "Product with this name already exists");
        return View(model);
    }

    await _service.CreateAsync(model);
    return RedirectToAction(nameof(Index));
}
```

---

## 7. Views & Razor Syntax

### Razor Syntax Basics

```html
@* This is a Razor comment *@

@{
    // C# code block
    var title = "Welcome";
    var items = new List<string> { "Apple", "Banana", "Cherry" };
}

<!-- Implicit expression -->
<h1>@title</h1>
<p>Current time: @DateTime.Now</p>

<!-- Explicit expression -->
<p>Total: @(items.Count * 10)</p>

<!-- HTML encoding (automatic - prevents XSS) -->
<p>@("<script>alert('xss')</script>")</p>  <!-- Encoded output -->

<!-- Raw HTML (use carefully!) -->
<p>@Html.Raw("<strong>Bold text</strong>")</p>

<!-- Conditionals -->
@if (items.Count > 0)
{
    <ul>
    @foreach (var item in items)
    {
        <li>@item</li>
    }
    </ul>
}
else
{
    <p>No items found.</p>
}

<!-- Switch -->
@switch (ViewBag.Role)
{
    case "Admin":
        <p>Admin Panel</p>
        break;
    case "User":
        <p>User Dashboard</p>
        break;
    default:
        <p>Guest View</p>
        break;
}

<!-- For loop -->
@for (int i = 0; i < 5; i++)
{
    <span>Item @i</span>
}

<!-- Ternary in Razor -->
<div class="@(isActive ? "active" : "inactive")">Status</div>

<!-- @: to output plain text inside code block -->
@if (true)
{
    @:This is plain text output
}
```

### Strongly Typed Views

```csharp
// Controller
public IActionResult Details(int id)
{
    var product = _service.GetById(id);
    return View(product); // Pass model to view
}
```

```html
<!-- Views/Product/Details.cshtml -->
@model Product

<h2>@Model.Name</h2>
<p>Price: @Model.Price.ToString("C")</p>
<p>Category: @Model.Category</p>
```

### ViewModel Pattern

```csharp
// ViewModel
public class ProductListViewModel
{
    public IEnumerable<Product> Products { get; set; }
    public string SearchTerm { get; set; }
    public int CurrentPage { get; set; }
    public int TotalPages { get; set; }
    public string SortBy { get; set; }
}

// Controller
public async Task<IActionResult> Index(string search, int page = 1)
{
    var viewModel = new ProductListViewModel
    {
        Products = await _service.SearchAsync(search, page),
        SearchTerm = search,
        CurrentPage = page,
        TotalPages = await _service.GetTotalPagesAsync(search)
    };
    return View(viewModel);
}
```

```html
@model ProductListViewModel

<form asp-action="Index" method="get">
    <input asp-for="SearchTerm" placeholder="Search..." />
    <button type="submit">Search</button>
</form>

<table>
    <thead>
        <tr><th>Name</th><th>Price</th></tr>
    </thead>
    <tbody>
    @foreach (var product in Model.Products)
    {
        <tr>
            <td>@product.Name</td>
            <td>@product.Price.ToString("C")</td>
        </tr>
    }
    </tbody>
</table>

<!-- Pagination -->
@for (int i = 1; i <= Model.TotalPages; i++)
{
    <a asp-action="Index"
       asp-route-page="@i"
       asp-route-search="@Model.SearchTerm"
       class="@(i == Model.CurrentPage ? "active" : "")">@i</a>
}
```

### _Layout.cshtml

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - MyApp</title>
    <link rel="stylesheet" href="~/css/site.css" />
    @await RenderSectionAsync("Styles", required: false)
</head>
<body>
    <nav>
        <a asp-controller="Home" asp-action="Index">Home</a>
        <a asp-controller="Product" asp-action="Index">Products</a>
    </nav>

    <main>
        @RenderBody()
    </main>

    <footer>
        <p>&copy; @DateTime.Now.Year - MyApp</p>
    </footer>

    <script src="~/lib/jquery/dist/jquery.min.js"></script>
    @await RenderSectionAsync("Scripts", required: false)
</body>
</html>
```

### _ViewStart.cshtml & _ViewImports.cshtml

```html
<!-- _ViewStart.cshtml - runs before every view -->
@{
    Layout = "_Layout";
}
```

```html
<!-- _ViewImports.cshtml - shared directives -->
@using MyApp.Models
@using MyApp.ViewModels
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
@addTagHelper *, MyApp
```

### Sections

```html
<!-- In child view -->
@section Scripts {
    <script src="~/js/product-validation.js"></script>
}

@section Styles {
    <link rel="stylesheet" href="~/css/product.css" />
}

<!-- In _Layout.cshtml -->
@await RenderSectionAsync("Scripts", required: false)
```

---

## 8. Tag Helpers & HTML Helpers

### Common Tag Helpers

```html
<!-- Anchor Tag Helper -->
<a asp-controller="Product"
   asp-action="Details"
   asp-route-id="5"
   asp-route-category="electronics">View Product</a>
<!-- Generates: <a href="/Product/Details/5?category=electronics">View Product</a> -->

<!-- Form Tag Helper -->
<form asp-controller="Account" asp-action="Login" method="post">
    <!-- Anti-forgery token auto-generated -->
</form>

<!-- Input Tag Helper -->
<input asp-for="Email" class="form-control" />
<!-- Generates: <input type="email" id="Email" name="Email" class="form-control" /> -->

<!-- Label Tag Helper -->
<label asp-for="Email"></label>
<!-- Uses [Display(Name = "...")] attribute -->

<!-- Validation Tag Helpers -->
<span asp-validation-for="Email" class="text-danger"></span>
<div asp-validation-summary="ModelOnly" class="text-danger"></div>
<!-- ValidationSummary values: None, ModelOnly, All -->

<!-- Select Tag Helper -->
<select asp-for="CategoryId"
        asp-items="@(new SelectList(Model.Categories, "Id", "Name"))">
    <option value="">-- Select Category --</option>
</select>

<!-- Textarea Tag Helper -->
<textarea asp-for="Description" rows="5" class="form-control"></textarea>

<!-- Environment Tag Helper -->
<environment include="Development">
    <link rel="stylesheet" href="~/css/site.css" />
</environment>
<environment exclude="Development">
    <link rel="stylesheet" href="~/css/site.min.css" asp-append-version="true" />
</environment>

<!-- Image Tag Helper (cache busting) -->
<img src="~/images/logo.png" asp-append-version="true" />
<!-- Generates: <img src="/images/logo.png?v=abc123hash" /> -->

<!-- Cache Tag Helper -->
<cache expires-after="@TimeSpan.FromMinutes(10)">
    <p>Cached at: @DateTime.Now</p>
</cache>

<!-- Partial Tag Helper -->
<partial name="_ProductCard" model="product" />
```

### Complete Form Example

```html
@model RegisterViewModel

<form asp-action="Register" asp-controller="Account" method="post">
    <div asp-validation-summary="ModelOnly" class="text-danger"></div>

    <div class="form-group">
        <label asp-for="Name"></label>
        <input asp-for="Name" class="form-control" />
        <span asp-validation-for="Name" class="text-danger"></span>
    </div>

    <div class="form-group">
        <label asp-for="Email"></label>
        <input asp-for="Email" class="form-control" />
        <span asp-validation-for="Email" class="text-danger"></span>
    </div>

    <div class="form-group">
        <label asp-for="Password"></label>
        <input asp-for="Password" class="form-control" />
        <span asp-validation-for="Password" class="text-danger"></span>
    </div>

    <button type="submit" class="btn btn-primary">Register</button>
</form>

@section Scripts {
    <partial name="_ValidationScriptsPartial" />
}
```

### Tag Helpers vs HTML Helpers

```html
<!-- TAG HELPER (Modern - Recommended) -->
<a asp-controller="Home" asp-action="Index">Home</a>
<input asp-for="Name" />
<form asp-action="Create" method="post"></form>

<!-- HTML HELPER (Legacy) -->
@Html.ActionLink("Home", "Index", "Home")
@Html.TextBoxFor(m => m.Name)
@using (Html.BeginForm("Create", "Home", FormMethod.Post)) { }
```

| Feature | Tag Helpers | HTML Helpers |
|---------|-------------|--------------|
| Syntax | HTML-like attributes | C# method calls |
| Readability | Better (looks like HTML) | Harder to read |
| IntelliSense | Full support | Limited |
| Custom | Easy to create | More complex |
| Recommended | Yes (.NET Core) | Legacy support |

### Custom Tag Helper

```csharp
// EmailTagHelper.cs
[HtmlTargetElement("email")]
public class EmailTagHelper : TagHelper
{
    public string Address { get; set; }

    public override void Process(TagHelperContext context,
        TagHelperOutput output)
    {
        output.TagName = "a";
        output.Attributes.SetAttribute("href", $"mailto:{Address}");
        output.Content.SetContent(Address);
    }
}

// Register in _ViewImports.cshtml
@addTagHelper *, MyApp

// Usage in view
<email address="support@example.com"></email>
<!-- Renders: <a href="mailto:support@example.com">support@example.com</a> -->
```

---

## 9. Dependency Injection

### Service Lifetimes

```csharp
// TRANSIENT - New instance every time it's requested
builder.Services.AddTransient<IEmailService, EmailService>();

// SCOPED - One instance per HTTP request
builder.Services.AddScoped<IProductRepository, ProductRepository>();

// SINGLETON - One instance for the entire application lifetime
builder.Services.AddSingleton<ICacheService, CacheService>();
```

### Lifetime Comparison

```
Request 1:                          Request 2:
┌─────────────────────────┐        ┌─────────────────────────┐
│ Transient A (instance 1)│        │ Transient A (instance 3)│
│ Transient A (instance 2)│        │ Transient A (instance 4)│
│ Scoped B    (instance 1)│        │ Scoped B    (instance 2)│
│ Scoped B    (instance 1)│ same!  │ Scoped B    (instance 2)│ same!
│ Singleton C (instance 1)│        │ Singleton C (instance 1)│
└─────────────────────────┘        └─────────────────────────┘
                                    ↑ Singleton SAME across all requests
```

| Lifetime | New per request? | New per injection? | When to Use |
|----------|------------------|--------------------|-------------|
| Transient | Yes | Yes | Lightweight, stateless services |
| Scoped | Yes | No (same in request) | DbContext, per-request repos |
| Singleton | No (app-wide) | No | Caching, configuration, logging |

### Registration Methods

```csharp
// Interface → Implementation
builder.Services.AddScoped<IProductService, ProductService>();

// Concrete type only
builder.Services.AddScoped<ProductService>();

// Factory method
builder.Services.AddScoped<IProductService>(provider =>
{
    var config = provider.GetRequiredService<IConfiguration>();
    var logger = provider.GetRequiredService<ILogger<ProductService>>();
    return new ProductService(config["ApiKey"], logger);
});

// Multiple implementations
builder.Services.AddScoped<INotificationService, EmailNotification>();
builder.Services.AddScoped<INotificationService, SmsNotification>();
// IEnumerable<INotificationService> resolves both

// TryAdd - only adds if not already registered
builder.Services.TryAddScoped<IProductService, ProductService>();

// Replace existing registration
builder.Services.Replace(ServiceDescriptor.Scoped<IProductService, MockProductService>());

// Register with options pattern
builder.Services.Configure<SmtpSettings>(
    builder.Configuration.GetSection("Smtp"));
```

### Injecting Dependencies

```csharp
// 1. Constructor Injection (PREFERRED)
public class ProductController : Controller
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductController> _logger;

    public ProductController(IProductService productService,
        ILogger<ProductController> logger)
    {
        _productService = productService;
        _logger = logger;
    }
}

// 2. Action Method Injection (using [FromServices])
public IActionResult Index([FromServices] IProductService service)
{
    return View(service.GetAll());
}

// 3. View Injection
// In .cshtml:
@inject IProductService ProductService
<p>Total Products: @ProductService.GetCount()</p>

// 4. Middleware Injection (via InvokeAsync parameters)
public async Task InvokeAsync(HttpContext context,
    IProductService productService) // Scoped service injected here
{
    await _next(context);
}
```

### Options Pattern

```csharp
// appsettings.json
{
  "SmtpSettings": {
    "Host": "smtp.example.com",
    "Port": 587,
    "Username": "user@example.com",
    "EnableSsl": true
  }
}

// Options class
public class SmtpSettings
{
    public string Host { get; set; }
    public int Port { get; set; }
    public string Username { get; set; }
    public bool EnableSsl { get; set; }
}

// Registration
builder.Services.Configure<SmtpSettings>(
    builder.Configuration.GetSection("SmtpSettings"));

// Usage via injection
public class EmailService : IEmailService
{
    private readonly SmtpSettings _settings;

    public EmailService(IOptions<SmtpSettings> options)
    {
        _settings = options.Value;
    }

    // IOptionsSnapshot<T> - reloads on change (Scoped)
    // IOptionsMonitor<T> - reloads on change (Singleton-friendly)
}
```

---

## 10. Entity Framework Core

### DbContext Setup

```csharp
// Models
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }

    // Navigation property
    public Category Category { get; set; }
    public ICollection<OrderItem> OrderItems { get; set; }
}

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; }
    public ICollection<Product> Products { get; set; }
}

// DbContext
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    public DbSet<Product> Products { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Order> Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Fluent API configuration
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");

            entity.HasOne(e => e.Category)
                  .WithMany(c => c.Products)
                  .HasForeignKey(e => e.CategoryId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => e.Name).IsUnique();
        });

        // Seed data
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Electronics" },
            new Category { Id = 2, Name = "Books" }
        );
    }
}

// Registration in Program.cs
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
           .EnableSensitiveDataLogging()  // Development only
           .LogTo(Console.WriteLine));    // SQL logging
```

### Migrations

```bash
# Install EF Core tools
dotnet tool install --global dotnet-ef

# Add migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# Remove last migration (if not applied)
dotnet ef migrations remove

# Generate SQL script
dotnet ef migrations script

# Revert to specific migration
dotnet ef database update MigrationName
```

### CRUD Operations

```csharp
public class ProductRepository : IProductRepository
{
    private readonly ApplicationDbContext _context;

    public ProductRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // CREATE
    public async Task<Product> CreateAsync(Product product)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        return product;
    }

    // READ - All
    public async Task<List<Product>> GetAllAsync()
    {
        return await _context.Products
            .Include(p => p.Category) // Eager loading
            .AsNoTracking()           // Read-only (better performance)
            .ToListAsync();
    }

    // READ - By ID
    public async Task<Product?> GetByIdAsync(int id)
    {
        return await _context.Products
            .Include(p => p.Category)
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    // UPDATE
    public async Task UpdateAsync(Product product)
    {
        _context.Entry(product).State = EntityState.Modified;
        // OR: _context.Products.Update(product);
        await _context.SaveChangesAsync();
    }

    // DELETE
    public async Task DeleteAsync(int id)
    {
        var product = await _context.Products.FindAsync(id);
        if (product != null)
        {
            _context.Products.Remove(product);
            await _context.SaveChangesAsync();
        }
    }

    // SEARCH with pagination
    public async Task<(List<Product> Items, int Total)> SearchAsync(
        string? search, int page = 1, int pageSize = 10)
    {
        var query = _context.Products
            .Include(p => p.Category)
            .AsNoTracking();

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(p =>
                p.Name.Contains(search) ||
                p.Category.Name.Contains(search));
        }

        var total = await query.CountAsync();

        var items = await query
            .OrderBy(p => p.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, total);
    }
}
```

### Loading Strategies

```csharp
// 1. EAGER LOADING - Load related data upfront
var products = await _context.Products
    .Include(p => p.Category)
    .Include(p => p.OrderItems)
        .ThenInclude(oi => oi.Order)  // Nested include
    .ToListAsync();

// 2. EXPLICIT LOADING - Load on demand
var product = await _context.Products.FindAsync(id);
await _context.Entry(product)
    .Reference(p => p.Category)
    .LoadAsync();
await _context.Entry(product)
    .Collection(p => p.OrderItems)
    .LoadAsync();

// 3. LAZY LOADING - Automatic (requires virtual + proxy package)
// Install: Microsoft.EntityFrameworkCore.Proxies
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseLazyLoadingProxies()
           .UseSqlServer(connectionString));

public class Product
{
    public int Id { get; set; }
    public virtual Category Category { get; set; }  // virtual keyword
    public virtual ICollection<OrderItem> OrderItems { get; set; }
}
```

### LINQ Queries

```csharp
// Where + Select (projection)
var productNames = await _context.Products
    .Where(p => p.Price > 100)
    .Select(p => new { p.Name, p.Price })
    .ToListAsync();

// GroupBy
var categoryStats = await _context.Products
    .GroupBy(p => p.Category.Name)
    .Select(g => new
    {
        Category = g.Key,
        Count = g.Count(),
        AvgPrice = g.Average(p => p.Price),
        MaxPrice = g.Max(p => p.Price)
    })
    .ToListAsync();

// Join
var results = await _context.Products
    .Join(_context.Categories,
        p => p.CategoryId,
        c => c.Id,
        (p, c) => new { Product = p.Name, Category = c.Name })
    .ToListAsync();

// Raw SQL
var products = await _context.Products
    .FromSqlRaw("SELECT * FROM Products WHERE Price > {0}", 50)
    .ToListAsync();

// Raw SQL (interpolated - parameterized automatically)
var minPrice = 50m;
var products2 = await _context.Products
    .FromSqlInterpolated($"SELECT * FROM Products WHERE Price > {minPrice}")
    .ToListAsync();

// ExecuteSql for non-query
await _context.Database
    .ExecuteSqlRawAsync("UPDATE Products SET Price = Price * 1.1 WHERE CategoryId = {0}", categoryId);
```

---

## 11. State Management

### ViewData, ViewBag, TempData Comparison

| Feature | ViewData | ViewBag | TempData |
|---------|----------|---------|----------|
| Type | `ViewDataDictionary` | `dynamic` wrapper | `ITempDataDictionary` |
| Casting | Requires casting | No casting needed | Requires casting |
| Scope | Current request only | Current request only | Current + next request |
| Null check | Required | Required | Required |
| Survives redirect | No | No | Yes (one redirect) |
| Storage | Dictionary | Dictionary | Session/Cookies |

### ViewData

```csharp
// Controller
public IActionResult Index()
{
    ViewData["Title"] = "Product List";
    ViewData["Count"] = 42;
    ViewData["Products"] = _service.GetAll();
    return View();
}
```

```html
<!-- View -->
<h1>@ViewData["Title"]</h1>
<p>Total: @ViewData["Count"]</p>
@foreach (var product in (List<Product>)ViewData["Products"])
{
    <p>@product.Name</p>
}
```

### ViewBag

```csharp
// Controller
public IActionResult Index()
{
    ViewBag.Title = "Product List";
    ViewBag.Count = 42;
    ViewBag.Categories = new SelectList(categories, "Id", "Name");
    return View();
}
```

```html
<!-- View -->
<h1>@ViewBag.Title</h1>
<select asp-items="@ViewBag.Categories"></select>
```

### TempData

```csharp
// Controller - Set
[HttpPost]
public IActionResult Delete(int id)
{
    _service.Delete(id);
    TempData["SuccessMessage"] = "Product deleted successfully!";
    return RedirectToAction(nameof(Index)); // Survives this redirect
}

// Controller - Read
public IActionResult Index()
{
    // TempData is auto-deleted after reading
    var message = TempData["SuccessMessage"] as string;

    // Keep for another request
    TempData.Keep("SuccessMessage");

    // Peek without marking for deletion
    var peeked = TempData.Peek("SuccessMessage") as string;

    return View();
}
```

```html
<!-- View -->
@if (TempData["SuccessMessage"] != null)
{
    <div class="alert alert-success">@TempData["SuccessMessage"]</div>
}
```

### Session

```csharp
// Program.cs - Configuration
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.Name = ".MyApp.Session";
});

// Middleware
app.UseSession(); // After UseRouting, before MapControllers

// Usage in Controller
public class CartController : Controller
{
    // Set session values
    public IActionResult AddToCart(int productId)
    {
        // String
        HttpContext.Session.SetString("LastVisited", DateTime.Now.ToString());

        // Integer
        HttpContext.Session.SetInt32("CartCount",
            (HttpContext.Session.GetInt32("CartCount") ?? 0) + 1);

        // Complex object (requires JSON serialization)
        var cart = GetCartFromSession();
        cart.Add(productId);
        HttpContext.Session.SetString("Cart", JsonSerializer.Serialize(cart));

        return RedirectToAction(nameof(Index));
    }

    // Get session values
    public IActionResult Index()
    {
        var lastVisited = HttpContext.Session.GetString("LastVisited");
        var cartCount = HttpContext.Session.GetInt32("CartCount") ?? 0;
        var cart = GetCartFromSession();
        return View(cart);
    }

    private List<int> GetCartFromSession()
    {
        var json = HttpContext.Session.GetString("Cart");
        return json != null
            ? JsonSerializer.Deserialize<List<int>>(json)
            : new List<int>();
    }
}
```

### Session Extension Methods (for complex objects)

```csharp
public static class SessionExtensions
{
    public static void SetObject<T>(this ISession session, string key, T value)
    {
        session.SetString(key, JsonSerializer.Serialize(value));
    }

    public static T? GetObject<T>(this ISession session, string key)
    {
        var json = session.GetString(key);
        return json == null ? default : JsonSerializer.Deserialize<T>(json);
    }
}

// Usage
HttpContext.Session.SetObject("Cart", cartObject);
var cart = HttpContext.Session.GetObject<ShoppingCart>("Cart");
```

---

## 12. Filters

### Filter Types & Execution Order

```
┌─────────────────────────────────────────────────────┐
│  Authorization Filters     (runs first)              │
│  ┌─────────────────────────────────────────────────┐│
│  │  Resource Filters       (before model binding)  ││
│  │  ┌─────────────────────────────────────────────┐││
│  │  │  Action Filters      (before/after action)  │││
│  │  │  ┌─────────────────────────────────────────┐│││
│  │  │  │  Exception Filters (on exception)       ││││
│  │  │  │  ┌─────────────────────────────────────┐││││
│  │  │  │  │  Result Filters  (before/after      │││││
│  │  │  │  │                   result execution)  │││││
│  │  │  │  └─────────────────────────────────────┘││││
│  │  │  └─────────────────────────────────────────┘│││
│  │  └─────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

### Action Filter

```csharp
// Attribute-based
public class LogActionFilter : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        // Before action executes
        var controllerName = context.RouteData.Values["controller"];
        var actionName = context.RouteData.Values["action"];
        Console.WriteLine($"Executing: {controllerName}/{actionName}");
    }

    public override void OnActionExecuted(ActionExecutedContext context)
    {
        // After action executes
        Console.WriteLine($"Executed: Status {context.HttpContext.Response.StatusCode}");
    }
}

// Interface-based (supports DI)
public class AuditFilter : IAsyncActionFilter
{
    private readonly IAuditService _auditService;

    public AuditFilter(IAuditService auditService)
    {
        _auditService = auditService;
    }

    public async Task OnActionExecutionAsync(
        ActionExecutingContext context,
        ActionExecutionDelegate next)
    {
        // Before
        var user = context.HttpContext.User.Identity?.Name;
        _auditService.LogAction(user, context.ActionDescriptor.DisplayName);

        var result = await next(); // Execute action

        // After
        if (result.Exception != null)
            _auditService.LogError(user, result.Exception.Message);
    }
}

// Register as service filter
builder.Services.AddScoped<AuditFilter>();

// Apply
[ServiceFilter(typeof(AuditFilter))]
public class AdminController : Controller { }
```

### Authorization Filter

```csharp
public class ApiKeyAuthFilter : IAuthorizationFilter
{
    private readonly IConfiguration _config;

    public ApiKeyAuthFilter(IConfiguration config)
    {
        _config = config;
    }

    public void OnAuthorization(AuthorizationFilterContext context)
    {
        if (!context.HttpContext.Request.Headers
            .TryGetValue("X-Api-Key", out var apiKey))
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        if (apiKey != _config["ApiKey"])
        {
            context.Result = new ForbidResult();
        }
    }
}
```

### Exception Filter

```csharp
public class GlobalExceptionFilter : IExceptionFilter
{
    private readonly ILogger<GlobalExceptionFilter> _logger;
    private readonly IWebHostEnvironment _env;

    public GlobalExceptionFilter(ILogger<GlobalExceptionFilter> logger,
        IWebHostEnvironment env)
    {
        _logger = logger;
        _env = env;
    }

    public void OnException(ExceptionContext context)
    {
        _logger.LogError(context.Exception, "Unhandled exception occurred");

        context.Result = new ViewResult
        {
            ViewName = "Error",
            ViewData = new ViewDataDictionary(
                new EmptyModelMetadataProvider(), context.ModelState)
            {
                { "Exception", _env.IsDevelopment()
                    ? context.Exception.Message
                    : "An error occurred" }
            }
        };
        context.ExceptionHandled = true;
    }
}

// Register globally
builder.Services.AddControllersWithViews(options =>
{
    options.Filters.Add<GlobalExceptionFilter>();
});
```

### Result Filter

```csharp
public class AddHeaderResultFilter : IResultFilter
{
    public void OnResultExecuting(ResultExecutingContext context)
    {
        context.HttpContext.Response.Headers.Add(
            "X-Custom-Header", "MyValue");
    }

    public void OnResultExecuted(ResultExecutedContext context)
    {
        // After result is written to response
    }
}
```

### Resource Filter (Caching Example)

```csharp
public class CacheResourceFilter : IResourceFilter
{
    private static readonly Dictionary<string, object> _cache = new();

    public void OnResourceExecuting(ResourceExecutingContext context)
    {
        var key = context.HttpContext.Request.Path;
        if (_cache.TryGetValue(key, out var cachedResult))
        {
            context.Result = (IActionResult)cachedResult; // Short-circuit
        }
    }

    public void OnResourceExecuted(ResourceExecutedContext context)
    {
        var key = context.HttpContext.Request.Path;
        if (context.Result != null)
        {
            _cache[key] = context.Result;
        }
    }
}
```

### Filter Registration Levels

```csharp
// 1. GLOBAL - applies to all controllers/actions
builder.Services.AddControllersWithViews(options =>
{
    options.Filters.Add<GlobalExceptionFilter>();
    options.Filters.Add(new RequireHttpsAttribute());
});

// 2. CONTROLLER level
[ServiceFilter(typeof(AuditFilter))]
[TypeFilter(typeof(LogActionFilter))]
public class ProductController : Controller { }

// 3. ACTION level
[LogActionFilter]
public IActionResult Create() => View();
```

### ServiceFilter vs TypeFilter

```csharp
// ServiceFilter - resolved from DI container (must be registered)
builder.Services.AddScoped<AuditFilter>();

[ServiceFilter(typeof(AuditFilter))]

// TypeFilter - creates new instance, can pass parameters
[TypeFilter(typeof(CustomFilter), Arguments = new object[] { "param1" })]
```

---

## 13. View Components & Partial Views

### Partial Views

```csharp
// _ProductCard.cshtml (in Views/Shared/)
@model Product

<div class="card">
    <h3>@Model.Name</h3>
    <p>Price: @Model.Price.ToString("C")</p>
    <a asp-action="Details" asp-route-id="@Model.Id">View Details</a>
</div>
```

```html
<!-- Using partial views -->
<!-- Method 1: Partial Tag Helper (recommended) -->
<partial name="_ProductCard" model="product" />

<!-- Method 2: HTML Helper -->
@await Html.PartialAsync("_ProductCard", product)

<!-- Method 3: Renders directly to response stream (legacy) -->
@{ await Html.RenderPartialAsync("_ProductCard", product); }

<!-- In a loop -->
@foreach (var product in Model.Products)
{
    <partial name="_ProductCard" model="product" />
}
```

### View Components (Mini-controllers for reusable UI)

```csharp
// ViewComponent class
public class ShoppingCartSummaryViewComponent : ViewComponent
{
    private readonly ICartService _cartService;

    public ShoppingCartSummaryViewComponent(ICartService cartService)
    {
        _cartService = cartService;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var items = await _cartService.GetCartItemsAsync(
            HttpContext.Session.GetString("CartId"));
        return View(items); // Default.cshtml
    }
}
```

```html
<!-- Views/Shared/Components/ShoppingCartSummary/Default.cshtml -->
@model List<CartItem>

<div class="cart-summary">
    <span>Cart: @Model.Count items</span>
    <span>Total: @Model.Sum(x => x.Price * x.Quantity).ToString("C")</span>
</div>
```

```html
<!-- Using View Component in any view -->
<!-- Method 1: Tag Helper -->
<vc:shopping-cart-summary></vc:shopping-cart-summary>

<!-- Method 2: Invoke -->
@await Component.InvokeAsync("ShoppingCartSummary")

<!-- With parameters -->
@await Component.InvokeAsync("ProductList", new { category = "Electronics", count = 5 })
```

### View Component with Parameters

```csharp
public class TopProductsViewComponent : ViewComponent
{
    private readonly IProductService _productService;

    public TopProductsViewComponent(IProductService productService)
    {
        _productService = productService;
    }

    public async Task<IViewComponentResult> InvokeAsync(
        string category, int count = 5)
    {
        var products = await _productService
            .GetTopProductsAsync(category, count);
        return View(products);
    }
}
```

### Partial View vs View Component

| Feature | Partial View | View Component |
|---------|-------------|----------------|
| Logic | No C# logic | Has own class with logic |
| DI | No DI support | Full DI support |
| Data | Passed from parent | Fetches its own data |
| Testable | Not easily | Unit testable |
| Use case | Simple UI reuse | Complex reusable widgets |

---

## 14. Areas

### Area Structure

```
MyApp/
├── Areas/
│   ├── Admin/
│   │   ├── Controllers/
│   │   │   └── DashboardController.cs
│   │   ├── Models/
│   │   └── Views/
│   │       ├── Dashboard/
│   │       │   └── Index.cshtml
│   │       ├── _ViewImports.cshtml
│   │       └── _ViewStart.cshtml
│   └── Customer/
│       ├── Controllers/
│       └── Views/
├── Controllers/       (default area)
├── Views/
└── Program.cs
```

### Area Controller

```csharp
namespace MyApp.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Authorize(Roles = "Admin")]
    public class DashboardController : Controller
    {
        public IActionResult Index() => View();

        public IActionResult Users() => View();
    }
}
```

### Area Routing

```csharp
// Program.cs
app.MapControllerRoute(
    name: "areas",
    pattern: "{area:exists}/{controller=Home}/{action=Index}/{id?}");

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");
```

### Linking to Areas

```html
<!-- Link to area -->
<a asp-area="Admin" asp-controller="Dashboard" asp-action="Index">Admin</a>

<!-- Link from area back to default (empty area) -->
<a asp-area="" asp-controller="Home" asp-action="Index">Home</a>
```

---

## 15. Authentication & Authorization

### Cookie Authentication

```csharp
// Program.cs
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.LogoutPath = "/Account/Logout";
        options.AccessDeniedPath = "/Account/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    });

app.UseAuthentication(); // Before UseAuthorization
app.UseAuthorization();
```

### Login / Logout

```csharp
public class AccountController : Controller
{
    private readonly IUserService _userService;

    public AccountController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public IActionResult Login(string returnUrl = "/")
    {
        ViewData["ReturnUrl"] = returnUrl;
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginViewModel model,
        string returnUrl = "/")
    {
        if (!ModelState.IsValid)
            return View(model);

        var user = await _userService.ValidateAsync(model.Email, model.Password);
        if (user == null)
        {
            ModelState.AddModelError("", "Invalid email or password");
            return View(model);
        }

        // Create claims
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Name, user.Name),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role),
            new Claim("Department", user.Department),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
        };

        var identity = new ClaimsIdentity(claims,
            CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);

        await HttpContext.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            principal,
            new AuthenticationProperties
            {
                IsPersistent = model.RememberMe,
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)
            });

        return LocalRedirect(returnUrl);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync(
            CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction("Index", "Home");
    }
}
```

### ASP.NET Core Identity

```csharp
// Program.cs
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequireUppercase = true;

    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
    options.Lockout.MaxFailedAccessAttempts = 5;

    // User settings
    options.User.RequireUniqueEmail = true;
    options.SignIn.RequireConfirmedEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Custom User class
public class ApplicationUser : IdentityUser
{
    public string FullName { get; set; }
    public string Department { get; set; }
    public DateTime DateOfBirth { get; set; }
}
```

### Authorization Types

```csharp
// 1. SIMPLE AUTHORIZATION
[Authorize]  // Must be authenticated
public class ProfileController : Controller { }

[AllowAnonymous]  // Override - allow unauthenticated
public IActionResult PublicPage() => View();

// 2. ROLE-BASED AUTHORIZATION
[Authorize(Roles = "Admin")]
public class AdminController : Controller { }

[Authorize(Roles = "Admin,Manager")]  // Either role
public IActionResult ManageUsers() => View();

// 3. POLICY-BASED AUTHORIZATION
// Program.cs
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));

    options.AddPolicy("MinAge18", policy =>
        policy.RequireClaim("DateOfBirth")
              .RequireAssertion(context =>
              {
                  var dob = DateTime.Parse(
                      context.User.FindFirst("DateOfBirth")?.Value ?? "");
                  return DateTime.Today.Year - dob.Year >= 18;
              }));

    options.AddPolicy("CanEditProducts", policy =>
        policy.RequireRole("Admin", "ProductManager")
              .RequireClaim("Department", "Sales", "Inventory"));
});

// Apply policy
[Authorize(Policy = "CanEditProducts")]
public IActionResult Edit(int id) => View();

// 4. CUSTOM AUTHORIZATION HANDLER
public class MinimumExperienceRequirement : IAuthorizationRequirement
{
    public int Years { get; }
    public MinimumExperienceRequirement(int years) => Years = years;
}

public class MinimumExperienceHandler
    : AuthorizationHandler<MinimumExperienceRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        MinimumExperienceRequirement requirement)
    {
        var experienceClaim = context.User.FindFirst("ExperienceYears");
        if (experienceClaim != null &&
            int.Parse(experienceClaim.Value) >= requirement.Years)
        {
            context.Succeed(requirement);
        }
        return Task.CompletedTask;
    }
}

// Register
builder.Services.AddSingleton<IAuthorizationHandler, MinimumExperienceHandler>();
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Senior", policy =>
        policy.Requirements.Add(new MinimumExperienceRequirement(5)));
});
```

### JWT Authentication (for APIs)

```csharp
// Program.cs
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// Token generation
public class TokenService : ITokenService
{
    private readonly IConfiguration _config;

    public TokenService(IConfiguration config) => _config = config;

    public string GenerateToken(ApplicationUser user, IList<string> roles)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(ClaimTypes.Name, user.UserName),
            new Claim(ClaimTypes.Email, user.Email)
        };

        foreach (var role in roles)
            claims.Add(new Claim(ClaimTypes.Role, role));

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
        var credentials = new SigningCredentials(key,
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(8),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

### Anti-Forgery Token (CSRF Protection)

```csharp
// Automatically included with form tag helper
<form asp-action="Create" method="post">
    <!-- Hidden __RequestVerificationToken auto-generated -->
</form>

// Validate on action
[HttpPost]
[ValidateAntiForgeryToken]
public IActionResult Create(ProductModel model) { }

// Global auto-validation
builder.Services.AddControllersWithViews(options =>
{
    options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());
});

// For AJAX calls
@Html.AntiForgeryToken()
<script>
    fetch('/api/data', {
        method: 'POST',
        headers: {
            'RequestVerificationToken':
                document.querySelector('input[name="__RequestVerificationToken"]').value
        }
    });
</script>
```

---

## 16. Web API in MVC

### API Controller

```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsApiController : ControllerBase
{
    private readonly IProductService _service;

    public ProductsApiController(IProductService service)
    {
        _service = service;
    }

    // GET api/productsapi
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<ProductDto>), 200)]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetAll(
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var products = await _service.GetAllAsync(search, page, pageSize);
        return Ok(products);
    }

    // GET api/productsapi/5
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), 200)]
    [ProducesResponseType(404)]
    public async Task<ActionResult<ProductDto>> GetById(int id)
    {
        var product = await _service.GetByIdAsync(id);
        if (product == null) return NotFound();
        return Ok(product);
    }

    // POST api/productsapi
    [HttpPost]
    [ProducesResponseType(typeof(ProductDto), 201)]
    [ProducesResponseType(400)]
    public async Task<ActionResult<ProductDto>> Create(
        [FromBody] CreateProductDto dto)
    {
        var product = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById),
            new { id = product.Id }, product);
    }

    // PUT api/productsapi/5
    [HttpPut("{id:int}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Update(int id,
        [FromBody] UpdateProductDto dto)
    {
        if (!await _service.ExistsAsync(id)) return NotFound();
        await _service.UpdateAsync(id, dto);
        return NoContent();
    }

    // DELETE api/productsapi/5
    [HttpDelete("{id:int}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> Delete(int id)
    {
        if (!await _service.ExistsAsync(id)) return NotFound();
        await _service.DeleteAsync(id);
        return NoContent();
    }
}
```

### [ApiController] Attribute Effects

- Automatic model validation (returns 400 if `ModelState` invalid)
- Attribute routing required
- Binding source inference (`[FromBody]`, `[FromRoute]`, etc.)
- Problem details for error responses

### Content Negotiation

```csharp
// Program.cs - Support XML + JSON
builder.Services.AddControllers()
    .AddXmlSerializerFormatters()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy =
            JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.WriteIndented = true;
        options.JsonSerializerOptions.ReferenceHandler =
            ReferenceHandler.IgnoreCycles;
    });
```

### Consuming APIs with HttpClient

```csharp
// Program.cs - Named client
builder.Services.AddHttpClient("ProductApi", client =>
{
    client.BaseAddress = new Uri("https://api.example.com/");
    client.DefaultRequestHeaders.Add("Accept", "application/json");
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Typed client
builder.Services.AddHttpClient<IProductApiClient, ProductApiClient>(client =>
{
    client.BaseAddress = new Uri("https://api.example.com/");
});

// Usage
public class ProductApiClient : IProductApiClient
{
    private readonly HttpClient _httpClient;

    public ProductApiClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<List<Product>> GetAllAsync()
    {
        var response = await _httpClient.GetAsync("api/products");
        response.EnsureSuccessStatusCode();
        return await response.Content
            .ReadFromJsonAsync<List<Product>>();
    }

    public async Task<Product> CreateAsync(Product product)
    {
        var response = await _httpClient.PostAsJsonAsync(
            "api/products", product);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<Product>();
    }
}
```

---

## 17. Configuration & Environments

### appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=MyApp;Trusted_Connection=true;"
  },
  "SmtpSettings": {
    "Host": "smtp.example.com",
    "Port": 587,
    "Username": "noreply@example.com"
  },
  "AllowedHosts": "*",
  "ApiKeys": {
    "PaymentGateway": "pk_test_12345",
    "EmailService": "em_key_67890"
  },
  "FeatureFlags": {
    "EnableNewCheckout": true,
    "EnableDarkMode": false
  }
}
```

### Reading Configuration

```csharp
public class HomeController : Controller
{
    private readonly IConfiguration _config;

    public HomeController(IConfiguration config)
    {
        _config = config;
    }

    public IActionResult Index()
    {
        // Direct access
        var connStr = _config.GetConnectionString("DefaultConnection");
        var host = _config["SmtpSettings:Host"];
        var port = _config.GetValue<int>("SmtpSettings:Port");

        // Section
        var smtpSection = _config.GetSection("SmtpSettings");
        var smtpHost = smtpSection["Host"];

        // Bind to object
        var smtp = new SmtpSettings();
        _config.GetSection("SmtpSettings").Bind(smtp);

        // Get or default
        var timeout = _config.GetValue<int>("Timeout", 30); // default 30

        return View();
    }
}
```

### Configuration Priority (highest to lowest)

1. Command-line arguments
2. Environment variables
3. User secrets (Development)
4. `appsettings.{Environment}.json`
5. `appsettings.json`

### Environment-Specific Configuration

```json
// appsettings.Development.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyApp_Dev;..."
  },
  "Logging": {
    "LogLevel": { "Default": "Debug" }
  }
}

// appsettings.Production.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=prod-server;Database=MyApp;..."
  },
  "Logging": {
    "LogLevel": { "Default": "Warning" }
  }
}
```

### Environment Checks

```csharp
// In Program.cs
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else if (app.Environment.IsProduction())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

// In Controller
public class HomeController : Controller
{
    private readonly IWebHostEnvironment _env;

    public HomeController(IWebHostEnvironment env) => _env = env;

    public IActionResult Index()
    {
        if (_env.IsDevelopment())
            ViewBag.Debug = true;
        return View();
    }
}
```

```html
<!-- In View -->
<environment include="Development">
    <p>Debug mode enabled</p>
</environment>
```

### User Secrets (Development Only)

```bash
# Initialize user secrets
dotnet user-secrets init

# Set secrets
dotnet user-secrets set "SmtpSettings:Password" "my-secret-password"
dotnet user-secrets set "ApiKeys:Stripe" "sk_test_abc123"

# List secrets
dotnet user-secrets list

# Remove
dotnet user-secrets remove "ApiKeys:Stripe"
```

---

## 18. Logging

### Built-in Logging

```csharp
public class ProductController : Controller
{
    private readonly ILogger<ProductController> _logger;

    public ProductController(ILogger<ProductController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        _logger.LogTrace("Trace: Entering Index");       // Most detailed
        _logger.LogDebug("Debug: Loading products");
        _logger.LogInformation("Info: Products loaded");
        _logger.LogWarning("Warning: Slow query detected");
        _logger.LogError("Error: Failed to load product {Id}", 42);
        _logger.LogCritical("Critical: Database connection lost");

        // Structured logging
        _logger.LogInformation(
            "User {UserId} viewed product {ProductId} at {Time}",
            User.Identity?.Name, 42, DateTime.UtcNow);

        // With exception
        try
        {
            // ...
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing request for product {Id}", 42);
        }

        return View();
    }
}
```

### Log Levels (lowest to highest)

| Level | Value | Use For |
|-------|-------|---------|
| Trace | 0 | Detailed debug info |
| Debug | 1 | Development debugging |
| Information | 2 | General flow tracking |
| Warning | 3 | Unexpected but non-breaking |
| Error | 4 | Errors that stop specific operations |
| Critical | 5 | System-wide failures |
| None | 6 | Disable logging |

### Serilog Integration (Popular Third-Party)

```csharp
// Install packages:
// dotnet add package Serilog.AspNetCore
// dotnet add package Serilog.Sinks.File
// dotnet add package Serilog.Sinks.Seq

// Program.cs
builder.Host.UseSerilog((context, config) =>
{
    config
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .Enrich.WithMachineName()
        .WriteTo.Console()
        .WriteTo.File("logs/app-.log",
            rollingInterval: RollingInterval.Day,
            retainedFileCountLimit: 30)
        .WriteTo.Seq("http://localhost:5341");
});

// Request logging middleware
app.UseSerilogRequestLogging();
```

---

## 19. Caching

### In-Memory Cache

```csharp
// Program.cs
builder.Services.AddMemoryCache();

// Usage
public class ProductService : IProductService
{
    private readonly IMemoryCache _cache;
    private readonly ApplicationDbContext _context;

    public ProductService(IMemoryCache cache, ApplicationDbContext context)
    {
        _cache = cache;
        _context = context;
    }

    public async Task<List<Product>> GetAllAsync()
    {
        var cacheKey = "products_all";

        if (!_cache.TryGetValue(cacheKey, out List<Product> products))
        {
            products = await _context.Products.ToListAsync();

            var cacheOptions = new MemoryCacheEntryOptions()
                .SetSlidingExpiration(TimeSpan.FromMinutes(5))
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(30))
                .SetPriority(CacheItemPriority.Normal);

            _cache.Set(cacheKey, products, cacheOptions);
        }

        return products;
    }

    // GetOrCreate pattern
    public async Task<Product> GetByIdAsync(int id)
    {
        return await _cache.GetOrCreateAsync($"product_{id}", async entry =>
        {
            entry.SlidingExpiration = TimeSpan.FromMinutes(10);
            return await _context.Products.FindAsync(id);
        });
    }

    // Invalidate cache
    public async Task UpdateAsync(Product product)
    {
        _context.Products.Update(product);
        await _context.SaveChangesAsync();

        _cache.Remove($"product_{product.Id}");
        _cache.Remove("products_all");
    }
}
```

### Distributed Cache (Redis)

```csharp
// Install: dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = "localhost:6379";
    options.InstanceName = "MyApp_";
});

// Usage with IDistributedCache
public class CacheService
{
    private readonly IDistributedCache _cache;

    public CacheService(IDistributedCache cache) => _cache = cache;

    public async Task<T?> GetAsync<T>(string key)
    {
        var json = await _cache.GetStringAsync(key);
        return json == null ? default : JsonSerializer.Deserialize<T>(json);
    }

    public async Task SetAsync<T>(string key, T value, int expiryMinutes = 30)
    {
        var options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(expiryMinutes)
        };
        var json = JsonSerializer.Serialize(value);
        await _cache.SetStringAsync(key, json, options);
    }

    public async Task RemoveAsync(string key)
    {
        await _cache.RemoveAsync(key);
    }
}
```

### Response Caching

```csharp
// Program.cs
builder.Services.AddResponseCaching();
app.UseResponseCaching();

// Controller
[ResponseCache(Duration = 60, Location = ResponseCacheLocation.Client)]
public IActionResult Index() => View();

[ResponseCache(Duration = 300, VaryByQueryKeys = new[] { "search", "page" })]
public IActionResult Search(string search, int page) => View();

[ResponseCache(NoStore = true)] // Never cache
public IActionResult Profile() => View();

// Cache profiles in Program.cs
builder.Services.AddControllersWithViews(options =>
{
    options.CacheProfiles.Add("Default30", new CacheProfile
    {
        Duration = 30,
        Location = ResponseCacheLocation.Any
    });
});

[ResponseCache(CacheProfileName = "Default30")]
public IActionResult Index() => View();
```

---

## 20. Error Handling

### Developer Exception Page (Development Only)

```csharp
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage(); // Shows detailed error page
}
else
{
    app.UseExceptionHandler("/Home/Error"); // Production error handler
    app.UseHsts();
}
```

### Custom Error Handling Middleware

```csharp
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next,
        ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception: {Message}", ex.Message);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context,
        Exception exception)
    {
        context.Response.ContentType = "application/json";

        var (statusCode, message) = exception switch
        {
            NotFoundException => (404, "Resource not found"),
            UnauthorizedAccessException => (401, "Unauthorized"),
            ValidationException ex => (400, ex.Message),
            _ => (500, "An internal server error occurred")
        };

        context.Response.StatusCode = statusCode;

        var response = new
        {
            StatusCode = statusCode,
            Message = message,
            Detail = exception.Message
        };

        await context.Response.WriteAsJsonAsync(response);
    }
}
```

### Status Code Pages

```csharp
// Show friendly error pages for HTTP status codes
app.UseStatusCodePagesWithReExecute("/Error/{0}");
// OR
app.UseStatusCodePagesWithRedirects("/Error/{0}");

// Controller
public class ErrorController : Controller
{
    [Route("Error/{statusCode}")]
    public IActionResult HttpStatusCodeHandler(int statusCode)
    {
        return statusCode switch
        {
            404 => View("NotFound"),
            403 => View("Forbidden"),
            500 => View("ServerError"),
            _ => View("Error")
        };
    }
}
```

### UseExceptionHandler with Error Model

```csharp
// In HomeController
[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
public IActionResult Error()
{
    var exceptionFeature = HttpContext.Features
        .Get<IExceptionHandlerPathFeature>();

    return View(new ErrorViewModel
    {
        RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier,
        Path = exceptionFeature?.Path,
        ErrorMessage = exceptionFeature?.Error.Message
    });
}
```

---

## 21. SignalR (Real-Time)

### Hub

```csharp
// Install: Microsoft.AspNetCore.SignalR (included in framework)

public class ChatHub : Hub
{
    // Called by client
    public async Task SendMessage(string user, string message)
    {
        // Send to all connected clients
        await Clients.All.SendAsync("ReceiveMessage", user, message);
    }

    // Send to specific group
    public async Task SendToGroup(string groupName, string message)
    {
        await Clients.Group(groupName).SendAsync("ReceiveMessage", message);
    }

    // Join group
    public async Task JoinGroup(string groupName)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
        await Clients.Group(groupName)
            .SendAsync("UserJoined", Context.User?.Identity?.Name);
    }

    // Connection events
    public override async Task OnConnectedAsync()
    {
        await Clients.Others.SendAsync("UserConnected",
            Context.User?.Identity?.Name);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        await Clients.Others.SendAsync("UserDisconnected",
            Context.User?.Identity?.Name);
        await base.OnDisconnectedAsync(exception);
    }
}
```

### SignalR Setup

```csharp
// Program.cs
builder.Services.AddSignalR();

app.MapHub<ChatHub>("/chatHub");
```

### Client-Side (JavaScript)

```html
<script src="~/lib/microsoft/signalr/dist/browser/signalr.js"></script>
<script>
    const connection = new signalR.HubConnectionBuilder()
        .withUrl("/chatHub")
        .withAutomaticReconnect()
        .build();

    // Receive messages
    connection.on("ReceiveMessage", (user, message) => {
        const li = document.createElement("li");
        li.textContent = `${user}: ${message}`;
        document.getElementById("messageList").appendChild(li);
    });

    // Start connection
    connection.start()
        .then(() => console.log("Connected to SignalR"))
        .catch(err => console.error("Connection failed: ", err));

    // Send message
    function sendMessage() {
        const user = document.getElementById("userInput").value;
        const message = document.getElementById("messageInput").value;
        connection.invoke("SendMessage", user, message)
            .catch(err => console.error(err));
    }
</script>
```

---

## 22. Unit Testing

### Controller Testing with xUnit + Moq

```csharp
// Install packages:
// dotnet add package xunit
// dotnet add package Moq
// dotnet add package Microsoft.AspNetCore.Mvc.Testing

public class ProductControllerTests
{
    private readonly Mock<IProductService> _mockService;
    private readonly ProductController _controller;

    public ProductControllerTests()
    {
        _mockService = new Mock<IProductService>();
        _controller = new ProductController(_mockService.Object);
    }

    [Fact]
    public async Task Index_ReturnsViewWithProducts()
    {
        // Arrange
        var products = new List<Product>
        {
            new Product { Id = 1, Name = "Phone", Price = 999 },
            new Product { Id = 2, Name = "Laptop", Price = 1499 }
        };
        _mockService.Setup(s => s.GetAllAsync())
            .ReturnsAsync(products);

        // Act
        var result = await _controller.Index();

        // Assert
        var viewResult = Assert.IsType<ViewResult>(result);
        var model = Assert.IsAssignableFrom<IEnumerable<Product>>(
            viewResult.ViewData.Model);
        Assert.Equal(2, model.Count());
    }

    [Fact]
    public async Task Details_WithValidId_ReturnsView()
    {
        // Arrange
        var product = new Product { Id = 1, Name = "Phone" };
        _mockService.Setup(s => s.GetByIdAsync(1))
            .ReturnsAsync(product);

        // Act
        var result = await _controller.Details(1);

        // Assert
        var viewResult = Assert.IsType<ViewResult>(result);
        var model = Assert.IsType<Product>(viewResult.ViewData.Model);
        Assert.Equal("Phone", model.Name);
    }

    [Fact]
    public async Task Details_WithInvalidId_ReturnsNotFound()
    {
        // Arrange
        _mockService.Setup(s => s.GetByIdAsync(999))
            .ReturnsAsync((Product?)null);

        // Act
        var result = await _controller.Details(999);

        // Assert
        Assert.IsType<NotFoundResult>(result);
    }

    [Fact]
    public async Task Create_WithValidModel_RedirectsToIndex()
    {
        // Arrange
        var model = new ProductViewModel { Name = "Phone", Price = 999 };

        // Act
        var result = await _controller.Create(model);

        // Assert
        var redirect = Assert.IsType<RedirectToActionResult>(result);
        Assert.Equal("Index", redirect.ActionName);
        _mockService.Verify(s => s.CreateAsync(model), Times.Once);
    }

    [Fact]
    public async Task Create_WithInvalidModel_ReturnsView()
    {
        // Arrange
        _controller.ModelState.AddModelError("Name", "Required");
        var model = new ProductViewModel();

        // Act
        var result = await _controller.Create(model);

        // Assert
        var viewResult = Assert.IsType<ViewResult>(result);
        Assert.Equal(model, viewResult.Model);
    }

    [Theory]
    [InlineData(1)]
    [InlineData(5)]
    [InlineData(10)]
    public async Task Details_WithMultipleValidIds_ReturnsView(int id)
    {
        // Arrange
        _mockService.Setup(s => s.GetByIdAsync(id))
            .ReturnsAsync(new Product { Id = id, Name = $"Product {id}" });

        // Act
        var result = await _controller.Details(id);

        // Assert
        Assert.IsType<ViewResult>(result);
    }
}
```

### Integration Testing

```csharp
public class ProductIntegrationTests
    : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ProductIntegrationTests(
        WebApplicationFactory<Program> factory)
    {
        _client = factory.WithWebApplicationBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Replace real DB with in-memory
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
                if (descriptor != null) services.Remove(descriptor);

                services.AddDbContext<AppDbContext>(options =>
                    options.UseInMemoryDatabase("TestDb"));
            });
        }).CreateClient();
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessStatusCode()
    {
        var response = await _client.GetAsync("/Product");
        response.EnsureSuccessStatusCode();
        Assert.Equal("text/html; charset=utf-8",
            response.Content.Headers.ContentType?.ToString());
    }
}
```

---

## 23. Deployment

### Publish Commands

```bash
# Framework-dependent deployment
dotnet publish -c Release -o ./publish

# Self-contained deployment (includes .NET runtime)
dotnet publish -c Release -r win-x64 --self-contained true -o ./publish

# Single file
dotnet publish -c Release -r win-x64 --self-contained true \
    -p:PublishSingleFile=true -o ./publish

# Trimmed (smaller size)
dotnet publish -c Release -r win-x64 --self-contained true \
    -p:PublishTrimmed=true -o ./publish
```

### IIS Hosting

```xml
<!-- web.config (auto-generated) -->
<configuration>
  <system.webServer>
    <handlers>
      <add name="aspNetCore" path="*" verb="*"
           modules="AspNetCoreModuleV2" resourceType="Unspecified" />
    </handlers>
    <aspNetCore processPath="dotnet" arguments=".\MyApp.dll"
                stdoutLogEnabled="true" stdoutLogFile=".\logs\stdout"
                hostingModel="inprocess">
      <environmentVariables>
        <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
      </environmentVariables>
    </aspNetCore>
  </system.webServer>
</configuration>
```

### Docker

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyApp.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

---

## 24. Real Interview Experiences - Indian Service Companies

> The following section is compiled from real interview experiences shared on Glassdoor, LinkedIn, Medium, and other platforms by candidates who interviewed at top Indian service-based companies for .NET / ASP.NET Core MVC roles (2023-2025).

---

### 24.1 TCS (Tata Consultancy Services)

**Interview Process**: Typically 2-3 rounds - Technical Round (40-50 min) + Managerial/HR Round (20-30 min).

**Real Experience #1** (Senior .NET Developer, 4 years exp, 2024):
> "The interviewer started with project discussion, asked me to explain the architecture of my current project. Then moved to MVC lifecycle - I had to explain what happens from the time a request hits the server to when the response is sent. Questions on filters, especially the order of execution. Then routing - conventional vs attribute routing. SQL was heavy - joins, indexes, stored procedures, temp tables vs table variables."

**Real Experience #2** (Cochin, Face-to-Face, 2024):
> "They asked about project details first, then .NET Core vs .NET Framework differences. Then Angular lifecycle hooks (since my resume had Angular). Deep questions on filters and middleware pipeline order. SQL joins and indexes. One scenario-based question: how would you handle 10,000 concurrent users hitting your MVC app?"

**Commonly Asked Questions at TCS**:
1. Explain the MVC request lifecycle in ASP.NET Core
2. Difference between .NET Core and .NET Framework
3. What is middleware? How do you create custom middleware?
4. Explain dependency injection and service lifetimes
5. ViewData vs ViewBag vs TempData - with examples
6. What are filters? Types and execution order?
7. How does routing work in MVC? Conventional vs attribute routing
8. What is Entity Framework? Code First vs Database First
9. SQL: Joins, stored procedures, indexes, CTE, triggers
10. SOLID principles and design patterns used in projects

---

### 24.2 Infosys

**Interview Process**: Usually 2 rounds - Technical Round (30-45 min, often via WebEx/Teams) + Manager/HR Round (15-30 min).

**Real Experience #1** (WebEx Technical Round, 2024):
> "The interviewer focused mainly on Web API. He asked me to open Notepad and write code to call a Web API using an AJAX call from scratch - no IntelliSense, no Google. Then he asked about filters in MVC, CRUD operations using EF Core, difference between `IActionResult` and `ActionResult<T>`. SQL questions: joins, indexes, and 'write a query to find the second highest salary'."

**Real Experience #2** (2025, 2 rounds):
> "First round was pure technical - they asked about OOPs concepts (polymorphism, abstraction), function overloading vs overriding, middleware pipeline, Kestrel server, dependency injection with all three lifetimes, and async/await. Second round was manager round with project-related questions and scenario-based questions like 'how would you handle a production bug in your MVC application?'"

**Commonly Asked Questions at Infosys**:
1. What is Kestrel? How is it different from IIS?
2. Explain AddSingleton vs AddScoped vs AddTransient with real examples
3. How does model binding work?
4. Write code to consume a Web API using HttpClient
5. What is the difference between `IActionResult` and `ActionResult<T>`?
6. Explain async/await and Task in .NET
7. OOPs: Abstract class vs Interface (with .NET 8 context)
8. What is Entity Framework Core? Explain migrations
9. SQL: Second highest salary, joins, indexes, group by with having
10. What is Razor Pages? How is it different from MVC?

---

### 24.3 Cognizant (CTS)

**Interview Process**: 2-3 rounds - Online Assessment (MCQs) + Technical Round + HR/Manager Round.

**Real Experience #1** (GenC Pro, 2024):
> "Online assessment had MCQs on C#, SQL, and general aptitude. The technical interview started with 'explain MVC architecture with a diagram'. Then authentication and authorization - cookie vs JWT. Questions on EF Core - eager vs lazy loading, how to handle N+1 query problem. They asked about SignalR too since my resume mentioned real-time features. Then a coding question: implement a simple repository pattern."

**Real Experience #2** (Senior Associate, 2024):
> "They asked me to explain my project's architecture end-to-end. Then deep dive into middleware - asked me to write a custom middleware for request logging. Dependency injection - what happens if a Singleton service depends on a Scoped service? (Captive dependency problem). State management comparison. Finally SQL Server performance tuning questions."

**Commonly Asked Questions at Cognizant**:
1. Draw and explain MVC architecture
2. What is middleware pipeline? Write custom middleware
3. Cookie authentication vs JWT - when to use which?
4. Eager loading vs lazy loading vs explicit loading in EF Core
5. What is the N+1 query problem and how to solve it?
6. Repository pattern and Unit of Work pattern
7. What happens if a Singleton depends on a Scoped service?
8. Tag Helpers vs HTML Helpers
9. How do you deploy an ASP.NET Core app to Azure?
10. Design a REST API for an e-commerce cart system

---

### 24.4 Capgemini

**Interview Process**: 3 rounds - Technical Round 1 + Technical Round 2 + HR Round. Process takes ~4 weeks.

**Real Experience #1** (Hyderabad, Sept 2024):
> "First technical round was basic - OOPs concepts, generics in C#, MVC overview, what are filters, MVC lifecycle. SQL: basic joins, group by, difference between RANK and DENSE_RANK, clustered vs non-clustered indexes (asked which one is faster and why). Second round was deeper - Web API best practices, how to secure an API, exception handling strategies in MVC, SOLID principles."

**Real Experience #2** (Online, Aug 2024):
> "The interview was smooth. They asked about dependency injection - explain all three lifetimes with code examples. Then configuration in ASP.NET Core - appsettings.json, how to read config, IOptions pattern. Entity Framework Core - Code First approach with migrations. One question on caching strategies - when to use in-memory cache vs distributed cache."

**Commonly Asked Questions at Capgemini**:
1. Explain OOPs concepts with real-world examples
2. Generics in C# - why and when to use them?
3. MVC lifecycle - request to response flow
4. Filters: types and their execution order
5. SQL: RANK vs DENSE_RANK vs ROW_NUMBER
6. Clustered vs non-clustered index - which is faster and why?
7. Web API security best practices
8. IOptions vs IOptionsSnapshot vs IOptionsMonitor
9. EF Core Code First with migrations workflow
10. In-memory caching vs distributed caching

---

### 24.5 Wipro

**Interview Process**: 2 rounds - Technical + HR. Often project-based discussion heavy.

**Real Experience #1** (2024):
> "Mostly project discussion. They asked me to explain the complete architecture of my current project. Then questions on ASP.NET Core MVC specifically: what's new in .NET 6/7/8, minimal APIs, how Program.cs replaced Startup.cs. Action method return types - when to use `IActionResult` vs specific types. Model validation - Data Annotations vs FluentValidation. They love SQL here - complex query with multiple joins and subqueries."

**Commonly Asked Questions at Wipro**:
1. What's new in .NET 6/7/8?
2. Explain minimal hosting model (Program.cs vs Startup.cs)
3. Action result types - name and explain at least 5
4. Model validation approaches
5. Data Annotations vs FluentValidation
6. How does session management work in ASP.NET Core?
7. Partial views vs View Components
8. SQL: Complex queries, window functions, CTEs
9. Unit testing in ASP.NET Core MVC
10. CI/CD pipeline for .NET applications

---

### 24.6 HCLTech

**Interview Process**: 2 rounds typically - Technical + HR.

**Real Experience #1** (2024):
> "They asked about Startup.cs vs Program.cs, middleware pipeline with correct order, authentication and authorization mechanisms, Role-based vs Policy-based authorization. Design pattern questions - Repository pattern, Singleton, Factory. EF Core: how to handle database migrations in production. Docker basics for .NET deployment."

**Commonly Asked Questions at HCLTech**:
1. Startup.cs vs Program.cs - explain both
2. Middleware pipeline - what is the correct order?
3. Role-based vs Policy-based vs Claims-based authorization
4. Design patterns: Repository, Unit of Work, Factory, Singleton
5. How to handle EF Core migrations in production?
6. What is Kestrel? Kestrel vs IIS
7. How to implement logging in ASP.NET Core?
8. Caching strategies and implementation
9. Docker containerization of .NET apps
10. Microservices vs Monolithic architecture

---

### 24.7 Tech Mahindra

**Interview Process**: 2 rounds - Technical + HR.

**Real Experience #1** (2024):
> "Questions focused on fundamentals. MVC pattern explanation, controller lifecycle, action filters. Then EF Core - DbContext, SaveChanges, tracking vs no-tracking queries. Dependency injection in detail. One coding question: 'Write an action method that returns paginated results'. SQL was straightforward - joins and basic aggregates."

**Commonly Asked Questions at Tech Mahindra**:
1. Explain MVC pattern with request flow
2. Controller lifecycle in ASP.NET Core
3. DbContext - what is it and how does change tracking work?
4. Tracking vs AsNoTracking queries in EF Core
5. How to implement pagination in MVC?
6. Dependency injection - constructor vs method injection
7. How do you handle errors globally in MVC?
8. What is anti-forgery token and why is it needed?
9. How to call one controller's action from another?
10. SQL: Joins, aggregates, subqueries

---

### 24.8 Accenture

**Interview Process**: 2-3 rounds. Known for scenario-based and design questions.

**Real Experience #1** (2024):
> "Heavy on design and architecture. They asked how I would design a ticket booking system using MVC. Questions on SOLID principles with code examples. How to make an MVC app scalable - load balancing, caching, async patterns. Clean architecture vs N-layer architecture. Then coding: implement a custom action filter that logs execution time."

**Commonly Asked Questions at Accenture**:
1. Design a feature using MVC (scenario-based)
2. SOLID principles with real code examples
3. Clean Architecture vs N-Layer Architecture
4. How to make an MVC app scalable?
5. Implement custom middleware/filter (live coding)
6. Async programming - Task, async/await, when to use?
7. How to handle concurrent requests to the same resource?
8. Microservices communication patterns
9. API versioning strategies
10. CQRS and Mediator pattern

---

### 24.9 Common Tricky Questions Asked Across Companies

These are questions that caught candidates off guard in real interviews:

**Q1: What happens if you register a service as Singleton but it depends on a Scoped service?**
> It's called the "Captive Dependency" problem. The Scoped service effectively becomes a Singleton because it's captured by the Singleton's longer lifetime. This can cause bugs with services like DbContext that shouldn't be shared across requests. ASP.NET Core throws an `InvalidOperationException` if `ValidateScopes` is enabled (default in Development).

**Q2: Can you inject a Scoped service into middleware?**
> Not via constructor injection since middleware is created once (Singleton lifetime). You must inject Scoped services through the `InvokeAsync` method parameters instead.

```csharp
// WRONG - middleware constructor (Singleton lifetime)
public class MyMiddleware
{
    private readonly IProductService _service; // Scoped - PROBLEM!
    public MyMiddleware(RequestDelegate next, IProductService service) { }
}

// CORRECT - via InvokeAsync
public async Task InvokeAsync(HttpContext context, IProductService service)
{
    // service is properly Scoped here
}
```

**Q3: What is the difference between `app.Use()` and `app.Run()`?**
> `Use` adds middleware that can call the next middleware in the pipeline (via `next()`). `Run` is terminal - it does NOT call `next()` and short-circuits the pipeline. After `Run`, no more middleware executes.

**Q4: ViewData vs ViewBag - which is faster?**
> ViewData is slightly faster because ViewBag uses `dynamic` which involves runtime resolution via the DLR (Dynamic Language Runtime). ViewData uses dictionary lookup. However, the performance difference is negligible in practice.

**Q5: What happens to TempData after it is read?**
> TempData is marked for deletion after it is read. It survives exactly one subsequent request (e.g., a redirect). Use `TempData.Keep()` to retain it for another request, or `TempData.Peek()` to read without marking for deletion.

**Q6: How is `AddControllersWithViews()` different from `AddControllers()`?**
> `AddControllers()` adds only controller support (for Web APIs). `AddControllersWithViews()` adds controllers + Razor view engine + other MVC features. `AddMvc()` adds everything including Razor Pages.

```csharp
builder.Services.AddControllers();            // API only
builder.Services.AddControllersWithViews();   // MVC (controllers + views)
builder.Services.AddRazorPages();             // Razor Pages only
builder.Services.AddMvc();                    // Everything
```

**Q7: How do you prevent over-posting / mass assignment?**
> Use ViewModels (bind only what you need), `[Bind]` attribute, or `[BindNever]` / `[FromQuery]` selectively. Never bind domain entities directly from forms.

```csharp
// BAD - binds everything including Role, IsAdmin etc.
public IActionResult Create(User user) { }

// GOOD - ViewModel with only allowed properties
public IActionResult Create(CreateUserViewModel model) { }

// OK - Bind attribute
public IActionResult Create([Bind("Name,Email")] User user) { }
```

**Q8: What is the difference between `RedirectToAction` and `RedirectToRoute`?**
> `RedirectToAction` targets a specific controller/action, while `RedirectToRoute` uses the registered route name. Both issue a 302 redirect. Use `RedirectToActionPermanent` for 301.

---

### 24.10 Preparation Strategy - What Top Companies Actually Test

Based on 50+ real interview experiences, here is the weighted importance of topics:

| Topic | Weight | Companies That Focus On This |
|-------|--------|------------------------------|
| **MVC Architecture & Lifecycle** | Very High | All companies |
| **Dependency Injection & Lifetimes** | Very High | TCS, Infosys, Cognizant, Capgemini |
| **Middleware Pipeline** | High | Cognizant, HCL, Accenture |
| **Entity Framework Core** | High | All companies |
| **SQL (Joins, Indexes, Queries)** | Very High | TCS, Infosys, Capgemini, Wipro |
| **Filters (Types & Order)** | High | TCS, Capgemini, Tech Mahindra |
| **Authentication/Authorization** | High | Cognizant, HCL, Accenture |
| **Routing (Convention + Attribute)** | Medium | TCS, Infosys |
| **ViewData/ViewBag/TempData** | Medium | All companies |
| **Async/Await & Task** | High | Infosys, Accenture |
| **Design Patterns (Repository, SOLID)** | High | Cognizant, Accenture, HCL |
| **Caching Strategies** | Medium | Capgemini, HCL |
| **Web API & HttpClient** | High | Infosys, TCS, Wipro |
| **Configuration & Options Pattern** | Medium | Capgemini, Wipro |
| **Unit Testing** | Medium | Wipro, Accenture |
| **Docker / Deployment** | Low-Medium | HCL, Accenture |

### Pro Tips from Candidates Who Got Selected

1. **Know your project deeply** - Every company starts with "Tell me about your project." Be ready to explain architecture, tech stack, challenges, and your specific contributions.

2. **SQL is non-negotiable** - Every Indian service company will ask SQL. Practice joins, subqueries, window functions (RANK, DENSE_RANK, ROW_NUMBER), CTEs, and performance tuning.

3. **Write code on demand** - Infosys and Cognizant may ask you to write code in Notepad/browser without IntelliSense. Practice writing DI registrations, middleware, controller actions from memory.

4. **Understand "why" not just "what"** - Companies like Accenture and Cognizant ask "why would you choose X over Y?" Understand trade-offs.

5. **Scenario-based answers win** - Instead of textbook definitions, explain with real project scenarios. "In my project, we used Scoped lifetime for DbContext because..."

6. **Keep .NET version knowledge current** - Know what changed from .NET 5 → 6 → 7 → 8 (minimal hosting, top-level statements, etc.)

---

### Quick Revision - Top 30 One-Liner Answers

| # | Question | Answer |
|---|----------|--------|
| 1 | What is MVC? | Design pattern: Model (data), View (UI), Controller (logic/flow) |
| 2 | Kestrel? | Cross-platform web server for ASP.NET Core, built on libuv/sockets |
| 3 | Middleware? | Software components in request/response pipeline, executed in order |
| 4 | AddSingleton? | One instance for entire app lifetime |
| 5 | AddScoped? | One instance per HTTP request |
| 6 | AddTransient? | New instance every time it's requested |
| 7 | ViewData? | Dictionary-based, requires casting, current request only |
| 8 | ViewBag? | Dynamic wrapper over ViewData, no casting, current request only |
| 9 | TempData? | Survives one redirect, stored in session/cookies |
| 10 | Tag Helpers? | Server-side HTML attributes (asp-for, asp-action) that look like HTML |
| 11 | Razor Pages? | Page-focused model (PageModel), simpler than MVC for page-centric apps |
| 12 | Model Binding? | Maps HTTP request data to action method parameters automatically |
| 13 | Filters? | Auth → Resource → Action → Exception → Result (execution order) |
| 14 | Areas? | Logical grouping of controllers/views/models for large apps |
| 15 | Partial View? | Reusable view fragment, no own logic, data passed from parent |
| 16 | View Component? | Mini-controller with own logic and DI, fetches its own data |
| 17 | IActionResult? | Base return type for all action results |
| 18 | ActionResult\<T\>? | Strongly typed, better for API docs/Swagger |
| 19 | [ApiController]? | Auto validation, attribute routing required, binding source inference |
| 20 | Eager Loading? | `.Include()` - loads related data in same query |
| 21 | Lazy Loading? | Auto-loads related data on access, requires virtual + proxies |
| 22 | AsNoTracking? | Read-only queries, better performance, no change tracking |
| 23 | Code First? | Define models in C#, generate DB via migrations |
| 24 | Database First? | Scaffold models from existing database |
| 25 | Anti-Forgery? | CSRF protection via hidden token in forms |
| 26 | Claims? | Key-value pairs representing user identity properties |
| 27 | Policy auth? | Flexible authorization using requirements and handlers |
| 28 | IOptions\<T\>? | Read config at startup, no reload |
| 29 | IOptionsSnapshot? | Reloads config per request (Scoped) |
| 30 | IOptionsMonitor? | Reloads config live, works with Singleton services |

---

*Sources for Interview Experiences:*
- *[Glassdoor - TCS .NET Developer Interviews](https://www.glassdoor.co.in/Interview/Tata-Consultancy-Services-Interview-Questions-E13461.htm)*
- *[Glassdoor - Infosys .NET Developer Interviews](https://www.glassdoor.com/Interview/Infosys-Dot-NET-Developer-Interview-Questions-EI_IE7927.0,7_KO8,25.htm)*
- *[Glassdoor - Capgemini .NET Developer Interviews](https://www.glassdoor.co.in/Interview/Capgemini-Interview-Questions-E3803.htm)*
- *[Glassdoor - Cognizant Interviews](https://www.glassdoor.com/Interview/Cognizant-Technology-Solutions-Interview-Questions-E8014.htm)*
- *[Glassdoor - Tech Mahindra .NET Interviews](https://www.glassdoor.co.in/Interview/Tech-Mahindra-Interview-Questions-E135932.htm)*
- *[Medium - Top 20 ASP.NET Core MVC Interview Questions at MNCs](https://medium.com/@ajit34555/top-20-asp-net-core-mvc-interview-questions-asked-in-mncs-2024-2025-for-2-5-years-net-developers-8ff54a749938)*
- *[InterviewBit - ASP.NET Interview Questions](https://www.interviewbit.com/asp-net-interview-questions/)*
- *[ScholarHat - ASP.NET Core Interview Questions](https://www.scholarhat.com/tutorial/aspnet/asp-net-core-interview-questions)*
