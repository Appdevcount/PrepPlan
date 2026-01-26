# AZ-204 Interview Questions: In-Depth, Practical, and Scenario-Based

This document provides a comprehensive set of interview questions for the AZ-204: Developing Solutions for Microsoft Azure certification. Each section covers a major topic area, with scenario-based questions, practical coding challenges, and detailed answers.

---


## 1. Azure Compute Services (App Service, Functions, VMs, Containers)


### 1.1 Azure App Service
1. How do you implement blue-green deployment in Azure App Service? What are the benefits?
     - **Answer:**
         Blue-green deployment in Azure App Service is achieved using deployment slots. You deploy your new version to a staging slot, validate it, and then swap it with the production slot for zero-downtime deployment. If issues arise, you can swap back instantly. This approach enables safe validation, easy rollback, and no downtime for users.
     - **Implementation:**
         **Step 1: Create a Staging Slot**
         ```sh
         az webapp deployment slot create --name myapp --resource-group myrg --slot staging
         ```
         **Step 2: Deploy to Staging Slot**
         - In your CI/CD pipeline, deploy your app to the 'staging' slot using Azure DevOps or GitHub Actions.
         - Example GitHub Actions step:
             ```yaml
             - uses: azure/webapps-deploy@v2
                 with:
                     app-name: myapp
                     slot-name: staging
                     publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
                     package: .
             ```
         **Step 3: Swap Slots**
         ```sh
         az webapp deployment slot swap --name myapp --resource-group myrg --slot staging
         ```
         **Step 4: Rollback (if needed)**
         ```sh
         az webapp deployment slot swap --name myapp --resource-group myrg --slot staging
         ```
         **References:**
         - [Azure CLI Webapp Slots](https://docs.microsoft.com/en-us/cli/azure/webapp/slot)

2. How do you secure an App Service from public internet access?
     - **Answer:**
         To secure an App Service, use Access Restrictions, VNet integration, and Private Endpoints. This ensures only allowed IPs or networks can access your app.
     - **Implementation:**
         **Step 1: Add Access Restriction (IP Filtering)**
         ```sh
         az webapp config access-restriction add --resource-group myrg --name myapp --rule-name AllowMyOffice --priority 100 --action Allow --ip-address 203.0.113.0/24
         ```
         **Step 2: Integrate with VNet (for backend access)**
         ```sh
         az webapp vnet-integration add --name myapp --resource-group myrg --vnet myvnet --subnet mysubnet
         ```
         **Step 3: Use Private Endpoint (for full isolation)**
         - In Azure Portal: Networking > Private Endpoint > Add
         **Step 4: Remove Public Access**
         - Remove all Allow rules except for required IPs or networks.
         **References:**
         - [App Service Access Restrictions](https://learn.microsoft.com/en-us/azure/app-service/app-service-ip-restrictions)

3. How do you automate scaling for unpredictable workloads?
     - **Answer:**
         Use Azure autoscale rules to automatically scale out/in based on metrics like CPU, memory, or HTTP queue length. You can also schedule scaling for known busy periods.
     - **Implementation:**
         **Step 1: Configure Autoscale in Azure Portal**
         - Go to App Service > Scale out (App Service plan) > Add a rule
         - Example: Scale out by 1 instance if CPU > 70% for 10 minutes
         **Step 2: Configure Autoscale via ARM Template**
         ```json
         "resources": [
             {
                 "type": "Microsoft.Insights/autoscalesettings",
                 "apiVersion": "2015-04-01",
                 "name": "autoscale-myapp",
                 "properties": {
                     "targetResourceUri": "[resourceId('Microsoft.Web/serverfarms', parameters('hostingPlanName'))]",
                     "enabled": true,
                     "profiles": [
                         {
                             "name": "Auto created scale condition",
                             "capacity": {
                                 "minimum": "1",
                                 "maximum": "5",
                                 "default": "1"
                             },
                             "rules": [
                                 {
                                     "metricTrigger": {
                                         "metricName": "CpuPercentage",
                                         "metricResourceUri": "[resourceId('Microsoft.Web/serverfarms', parameters('hostingPlanName'))]",
                                         "timeGrain": "PT1M",
                                         "statistic": "Average",
                                         "timeWindow": "PT5M",
                                         "timeAggregation": "Average",
                                         "operator": "GreaterThan",
                                         "threshold": 70
                                     },
                                     "scaleAction": {
                                         "direction": "Increase",
                                         "type": "ChangeCount",
                                         "value": "1",
                                         "cooldown": "PT5M"
                                     }
                                 }
                             ]
                         }
                     ]
                 }
             }
         ]
         ```
         **References:**
         - [Azure Autoscale Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-get-started)

4. How do you troubleshoot a 500 error in App Service?
     - **Answer:**
         Use App Service diagnostics, Application Insights, and Kudu to investigate 500 errors. Check logs, deployment history, and recent code changes.
     - **Implementation:**
         **Step 1: Enable Application Insights**
         - In Azure Portal: App Service > Application Insights > Enable
         **Step 2: Log Exceptions in Code (C#)**
         ```csharp
         using Microsoft.ApplicationInsights;
         using Microsoft.ApplicationInsights.Extensibility;
     
         public class HomeController : Controller
         {
                 private readonly TelemetryClient _telemetry;
                 public HomeController(TelemetryClient telemetry)
                 {
                         _telemetry = telemetry;
                 }
                 public IActionResult Index()
                 {
                         try
                         {
                                 // ... your logic ...
                         }
                         catch (Exception ex)
                         {
                                 _telemetry.TrackException(ex);
                                 throw;
                         }
                         return View();
                 }
         }
         ```
         **Step 3: Use Kudu Console**
         - Go to https://<app-name>.scm.azurewebsites.net/DebugConsole
         - Check logs under LogFiles\eventlog.xml or LogFiles\Application\
         **Step 4: Use Diagnose and Solve Problems in Portal**
         - App Service > Diagnose and solve problems > Availability and Performance
         **References:**
         - [App Service Diagnostics](https://learn.microsoft.com/en-us/azure/app-service/overview-diagnostics)

5. How do you enable custom domains and SSL?
     - **Answer:**
         Add your custom domain in the Azure Portal, validate ownership, upload or purchase an SSL certificate, and bind it to your domain.
     - **Implementation:**
         **Step 1: Add Custom Domain**
         - In Azure Portal: App Service > Custom domains > Add custom domain
         - Add a CNAME or A record in your DNS provider as instructed
         **Step 2: Upload or Purchase SSL Certificate**
         - App Service > TLS/SSL settings > Private Key Certificates (.pfx) > Upload Certificate
         **Step 3: Bind SSL to Domain**
         - App Service > TLS/SSL bindings > Add TLS/SSL binding
         - Select your domain and certificate
         **Step 4: Enforce HTTPS**
         - App Service > TLS/SSL settings > HTTPS Only > On
         **References:**
         - [Custom domains and SSL](https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain)

6. How do you use Managed Identity in App Service?
     - **Answer:**
         Enable system-assigned Managed Identity for your App Service, grant it access to Azure resources (like Key Vault), and use DefaultAzureCredential in your code.
     - **Implementation:**
         **Step 1: Enable Managed Identity**
         - Azure Portal: App Service > Identity > System assigned > On
         **Step 2: Grant Access to Key Vault**
         - Azure Portal: Key Vault > Access policies > Add access policy > Select your App Service
         **Step 3: Access Key Vault in Code (C#)**
         ```csharp
         using Azure.Identity;
         using Azure.Security.KeyVault.Secrets;
     
         var kvUri = "https://<your-keyvault-name>.vault.azure.net/";
         var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
         KeyVaultSecret secret = await client.GetSecretAsync("MySecret");
         string secretValue = secret.Value;
         ```
         **Packages:** Azure.Identity, Azure.Security.KeyVault.Secrets
         **References:**
         - [Managed Identity](https://learn.microsoft.com/en-us/azure/app-service/overview-managed-identity)

7. How do you configure health checks?
     - **Answer:**
         Set a health check path in App Service settings. Azure will ping this endpoint and remove unhealthy instances from the load balancer.
     - **Implementation:**
         **Step 1: Add Health Check Endpoint in App**
         - In ASP.NET Core, add a health check endpoint:
         ```csharp
         // In Startup.cs
         public void ConfigureServices(IServiceCollection services)
         {
                 services.AddHealthChecks();
         }
         public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
         {
                 app.UseHealthChecks("/health");
         }
         ```
         **Step 2: Configure Health Check in Portal**
         - App Service > Settings > Health check > Set path to /health
         **References:**
         - [App Service Health Check](https://learn.microsoft.com/en-us/azure/app-service/monitor-instances-health-check)

8. How do you implement CI/CD for App Service?
     - **Answer:**
         Use GitHub Actions, Azure DevOps, or the built-in deployment center for automated builds and deployments.
     - **Implementation:**
         **Step 1: GitHub Actions Workflow Example**
         - .github/workflows/azure-webapp.yml
         ```yaml
         name: Build and deploy ASP.NET Core app to Azure Web App
         on:
             push:
                 branches:
                     - main
         jobs:
             build-and-deploy:
                 runs-on: ubuntu-latest
                 steps:
                     - uses: actions/checkout@v2
                     - name: Setup .NET
                         uses: actions/setup-dotnet@v2
                         with:
                             dotnet-version: '6.0.x'
                     - name: Build
                         run: dotnet build --configuration Release
                     - name: Publish
                         run: dotnet publish -c Release -o ./publish
                     - name: Deploy to Azure Web App
                         uses: azure/webapps-deploy@v2
                         with:
                             app-name: myapp
                             publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
                             package: ./publish
         ```
         **Step 2: Azure DevOps Pipeline Example**
         - azure-pipelines.yml
         ```yaml
         trigger:
             - main
         pool:
             vmImage: 'ubuntu-latest'
         steps:
             - task: UseDotNet@2
                 inputs:
                     packageType: 'sdk'
                     version: '6.0.x'
             - script: dotnet build --configuration Release
             - script: dotnet publish -c Release -o $(Build.ArtifactStagingDirectory)
             - task: AzureWebApp@1
                 inputs:
                     azureSubscription: '<Azure Service Connection>'
                     appName: 'myapp'
                     package: '$(Build.ArtifactStagingDirectory)'
         ```
         **References:**
         - [GitHub Actions for Azure](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions)

9. How do you handle application secrets?
     - **Answer:**
         Store secrets in Azure Key Vault, access them via Managed Identity in your application code, and never store secrets in code or app settings.
     - **Implementation:**
         **Step 1: Store Secret in Key Vault**
         ```sh
         az keyvault secret set --vault-name <your-keyvault-name> --name MySecret --value "SuperSecretValue"
         ```
         **Step 2: Access Secret in ASP.NET Core**
         ```csharp
         using Azure.Identity;
         using Azure.Security.KeyVault.Secrets;
     
         var kvUri = "https://<your-keyvault-name>.vault.azure.net/";
         var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
         KeyVaultSecret secret = await client.GetSecretAsync("MySecret");
         string secretValue = secret.Value;
         ```
         **Packages:** Azure.Identity, Azure.Security.KeyVault.Secrets
         **References:**
         - [Key Vault with App Service](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references)

10. How do you monitor performance?
     - **Answer:**
         Integrate Application Insights with your App Service, set up alerts, and review metrics and logs for performance monitoring.
     - **Implementation:**
         **Step 1: Add Application Insights SDK**
         - NuGet: Microsoft.ApplicationInsights.AspNetCore
         **Step 2: Configure in Program.cs (ASP.NET Core 6+)**
         ```csharp
         var builder = WebApplication.CreateBuilder(args);
         builder.Services.AddApplicationInsightsTelemetry();
         var app = builder.Build();
         app.MapGet("/", () => "Hello World!");
         app.Run();
         ```
         **Step 3: Track Custom Events**
         ```csharp
         var telemetry = new TelemetryClient();
         telemetry.TrackEvent("EventName");
         ```
         **Step 4: Set Up Alerts in Portal**
         - Application Insights > Alerts > New alert rule
         **References:**
         - [Application Insights for ASP.NET Core](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core)

11. How do you roll back a failed deployment?
     - **Answer:**
         Use deployment slots to swap back to the previous version, or redeploy a previous build from deployment history.
     - **Implementation:**
         **Step 1: Swap Slots Back**
         ```sh
         az webapp deployment slot swap --name myapp --resource-group myrg --slot staging
         ```
         **Step 2: Redeploy Previous Build**
         - In Azure Portal: App Service > Deployment Center > Logs > Redeploy
         **References:**
         - [Deployment slots](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots)

12. How do you configure custom startup scripts?
     - **Answer:**
         For Linux, set the Startup Command in App Service configuration. For Windows, use web.config or startup scripts.
     - **Implementation:**
         **Linux Example:**
         - Azure Portal: Configuration > Startup Command > `dotnet MyApp.dll`
         **Windows Example:**
         - web.config:
         ```xml
         <configuration>
             <system.webServer>
                 <handlers>
                     <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
                 </handlers>
                 <aspNetCore processPath="dotnet" arguments=".\MyApp.dll" stdoutLogEnabled="false" />
             </system.webServer>
         </configuration>
         ```
         **References:**
         - [Startup Command](https://learn.microsoft.com/en-us/azure/app-service/configure-custom-container?pivots=container-linux)

13. How do you restrict outbound traffic?
     - **Answer:**
         Use VNet integration, Network Security Groups (NSGs), and service endpoints to restrict outbound traffic from your App Service.
     - **Implementation:**
         **Step 1: Integrate with VNet**
         ```sh
         az webapp vnet-integration add --name myapp --resource-group myrg --vnet myvnet --subnet mysubnet
         ```
         **Step 2: Configure NSGs and Service Endpoints**
         - In Azure Portal: Networking > VNet Integration > Configure NSGs
         **References:**
         - [VNet Integration](https://learn.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet)

14. How do you enable authentication?
     - **Answer:**
         Use App Service Authentication (Easy Auth) to enable authentication with Azure AD, social logins, or custom providers.
     - **Implementation:**
         **Step 1: Enable Authentication in Portal**
         - App Service > Authentication > Add identity provider
         - Choose Azure Active Directory, Google, Facebook, etc.
         **Step 2: Configure App Registration (for Azure AD)**
         - Register your app in Azure AD, set redirect URIs, and grant permissions
         **Step 3: Use [Authorize] in Code (ASP.NET Core)**
         ```csharp
         [Authorize]
         public class SecureController : Controller
         {
                 public IActionResult Index() => View();
         }
         ```
         **Packages:** Microsoft.AspNetCore.Authentication.AzureAD.UI
         **References:**
         - [App Service Authentication](https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad)

15. How do you optimize cost for App Service?
     - **Answer:**
         Use reserved instances, scale down during off-peak hours, monitor usage, and use lower SKUs for development/test environments.
     - **Implementation:**
         **Step 1: Purchase Reserved Instance**
         - Azure Portal: App Service plan > Pricing tier > Purchase reserved instance
         **Step 2: Scale Down During Off-Peak**
         - Use autoscale schedules to reduce instance count at night/weekends
         **Step 3: Monitor Usage**
         - Azure Portal: App Service plan > Metrics > Review CPU, memory, and instance count
         **Step 4: Use Lower SKUs for Dev/Test**
         - Azure Portal: App Service plan > Change pricing tier > Select Basic/Free for non-production
         **References:**
         - [App Service Pricing](https://azure.microsoft.com/en-us/pricing/details/app-service/windows/)

16. How do you implement health checks for App Service?
     - **Answer:**
         Configure health check endpoint to automatically remove unhealthy instances from load balancer rotation.
     - **Implementation:**
         **Step 1: Create Health Check Endpoint**
         ```csharp
         app.MapGet("/health", async (IServiceProvider services) =>
         {
             var dbContext = services.GetRequiredService<AppDbContext>();
             try
             {
                 await dbContext.Database.CanConnectAsync();
                 return Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
             }
             catch
             {
                 return Results.StatusCode(503);
             }
         });
         ```
         **Step 2: Configure Health Check in Azure**
         ```sh
         az webapp config set --resource-group myrg --name myapp --generic-configurations '{"healthCheckPath": "/health"}'
         ```
         **Step 3: Advanced Health Checks with ASP.NET Core**
         ```csharp
         builder.Services.AddHealthChecks()
             .AddDbContextCheck<AppDbContext>()
             .AddRedis(redisConnectionString)
             .AddAzureBlobStorage(blobConnectionString);

         app.MapHealthChecks("/health", new HealthCheckOptions
         {
             ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
         });
         ```
         **References:**
         - [App Service Health Check](https://learn.microsoft.com/en-us/azure/app-service/monitor-instances-health-check)

17. How do you implement WebJobs for background processing?
     - **Answer:**
         Use WebJobs for continuous or triggered background tasks that run alongside your web app.
     - **Implementation:**
         **Step 1: Create Triggered WebJob**
         ```csharp
         public class Functions
         {
             public static void ProcessQueueMessage(
                 [QueueTrigger("myqueue")] string message,
                 ILogger logger)
             {
                 logger.LogInformation($"Processing: {message}");
             }
         }
         ```
         **Step 2: Configure WebJobs Host**
         ```csharp
         var builder = new HostBuilder()
             .ConfigureWebJobs(b =>
             {
                 b.AddAzureStorageCoreServices();
                 b.AddAzureStorageQueues();
             })
             .ConfigureLogging(logging => logging.AddConsole());

         var host = builder.Build();
         await host.RunAsync();
         ```
         **Step 3: Deploy via CLI**
         ```sh
         az webapp webjob continuous create --resource-group myrg --name myapp --webjob-name mywebjob --webjob-type continuous
         ```
         **Step 4: Schedule Triggered WebJob (settings.job)**
         ```json
         { "schedule": "0 */5 * * * *" }
         ```
         **References:**
         - [WebJobs SDK](https://learn.microsoft.com/en-us/azure/app-service/webjobs-sdk-how-to)

18. How do you configure custom domains and SSL certificates?
     - **Answer:**
         Map custom domains, configure DNS records, and bind SSL certificates for secure HTTPS access.
     - **Implementation:**
         **Step 1: Add Custom Domain**
         ```sh
         az webapp config hostname add --resource-group myrg --webapp-name myapp --hostname www.mydomain.com
         ```
         **Step 2: Create DNS Records**
         - CNAME: www -> myapp.azurewebsites.net
         - TXT: asuid.www -> verification ID from Azure
         **Step 3: Add Managed Certificate (Free)**
         ```sh
         az webapp config ssl create --resource-group myrg --name myapp --hostname www.mydomain.com
         ```
         **Step 4: Bind Certificate**
         ```sh
         az webapp config ssl bind --resource-group myrg --name myapp --certificate-thumbprint <thumbprint> --ssl-type SNI
         ```
         **Step 5: Import Custom Certificate**
         ```sh
         az webapp config ssl upload --resource-group myrg --name myapp --certificate-file mycert.pfx --certificate-password <password>
         ```
         **References:**
         - [Custom Domain Configuration](https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain)

19. How do you implement hybrid connections for on-premises access?
     - **Answer:**
         Use Hybrid Connections to securely access on-premises resources without opening firewall ports.
     - **Implementation:**
         **Step 1: Create Hybrid Connection**
         - Azure Portal: App Service > Networking > Hybrid connections > Add hybrid connection
         **Step 2: Install Hybrid Connection Manager On-Premises**
         - Download HCM from Azure portal
         - Configure endpoint: hostname:port of on-premises resource
         **Step 3: Use in Application**
         ```csharp
         // Access on-premises SQL Server via hybrid connection
         var connectionString = "Server=onprem-sqlserver;Database=mydb;User Id=user;Password=pass;";
         using var connection = new SqlConnection(connectionString);
         await connection.OpenAsync();
         ```
         **Step 4: Configure Connection String**
         ```sh
         az webapp config connection-string set --resource-group myrg --name myapp --settings OnPremDb="Server=onprem-sqlserver;..." --connection-string-type SQLServer
         ```
         **References:**
         - [Hybrid Connections](https://learn.microsoft.com/en-us/azure/app-service/app-service-hybrid-connections)

20. How do you implement container deployment in App Service?
     - **Answer:**
         Deploy Docker containers to App Service for Linux with custom images from Azure Container Registry or Docker Hub.
     - **Implementation:**
         **Step 1: Create Container-Based App Service**
         ```sh
         az webapp create --resource-group myrg --plan myplan --name myapp --deployment-container-image-name myregistry.azurecr.io/myapp:latest
         ```
         **Step 2: Configure Registry Credentials**
         ```sh
         az webapp config container set --resource-group myrg --name myapp --docker-registry-server-url https://myregistry.azurecr.io --docker-registry-server-user myuser --docker-registry-server-password mypassword
         ```
         **Step 3: Enable Continuous Deployment**
         ```sh
         az webapp deployment container config --resource-group myrg --name myapp --enable-cd true
         ```
         **Step 4: Multi-Container with Docker Compose**
         ```sh
         az webapp config container set --resource-group myrg --name myapp --multicontainer-config-type compose --multicontainer-config-file docker-compose.yml
         ```
         **Step 5: Configure Startup Command**
         ```sh
         az webapp config set --resource-group myrg --name myapp --startup-file "dotnet myapp.dll"
         ```
         **References:**
         - [Container Deployment](https://learn.microsoft.com/en-us/azure/app-service/quickstart-custom-container)


### 1.2 Azure Functions
1. How do you choose between Consumption and Premium plans?
     - **Answer:**
         The Consumption plan is cost-effective for bursty, event-driven workloads and scales automatically, but has cold start and timeout limitations. The Premium plan supports VNet integration, unlimited execution duration, and advanced scaling.
     - **Implementation:**
         **Step 1: Create a Function App in Consumption Plan**
         ```sh
         az functionapp create --resource-group myrg --consumption-plan-location westeurope --runtime dotnet --functions-version 4 --name myfuncapp
         ```
         **Step 2: Create a Function App in Premium Plan**
         ```sh
         az functionapp plan create --name mypremiumplan --resource-group myrg --location westeurope --number-of-workers 1 --sku EP1
         az functionapp create --resource-group myrg --plan mypremiumplan --runtime dotnet --functions-version 4 --name myfuncapppremium
         ```
         **References:**
         - [Azure Functions hosting plans](https://learn.microsoft.com/en-us/azure/azure-functions/functions-scale)

2. How do you implement durable workflows?
     - **Answer:**
         Use Durable Functions to create stateful workflows, such as orchestrations, chaining, and fan-out/fan-in patterns. Durable Functions manage state, checkpoints, and restarts for you.
     - **Implementation:**
         **Step 1: Add NuGet Package**
         - Microsoft.Azure.WebJobs.Extensions.DurableTask
         **Step 2: Create an Orchestrator Function**
         ```csharp
         using Microsoft.Azure.WebJobs;
         using Microsoft.Azure.WebJobs.Extensions.DurableTask;
         using Microsoft.Extensions.Logging;
         using System.Collections.Generic;
         using System.Threading.Tasks;
     
         public static class DurableSample
         {
                 [FunctionName("Orchestrator")]
                 public static async Task<List<string>> RunOrchestrator(
                         [OrchestrationTrigger] IDurableOrchestrationContext context)
                 {
                         var outputs = new List<string>();
                         outputs.Add(await context.CallActivityAsync<string>("SayHello", "Tokyo"));
                         outputs.Add(await context.CallActivityAsync<string>("SayHello", "Seattle"));
                         outputs.Add(await context.CallActivityAsync<string>("SayHello", "London"));
                         return outputs;
                 }
                 [FunctionName("SayHello")]
                 public static string SayHello([ActivityTrigger] string name, ILogger log)
                 {
                         log.LogInformation($"Saying hello to {name}.");
                         return $"Hello {name}!";
                 }
         }
         ```
         **Step 3: Start the Orchestration**
         ```csharp
         [FunctionName("HttpStart")]
         public static async Task<HttpResponseMessage> HttpStart(
                 [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestMessage req,
                 [DurableClient] IDurableOrchestrationClient starter,
                 ILogger log)
         {
                 string instanceId = await starter.StartNewAsync("Orchestrator", null);
                 return starter.CreateCheckStatusResponse(req, instanceId);
         }
         ```
         **References:**
         - [Durable Functions documentation](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview)

3. How do you secure HTTP-triggered functions?
     - **Answer:**
         Use function keys, Azure AD authentication, or API Management to secure HTTP-triggered Azure Functions.
     - **Implementation:**
         **Step 1: Use Function Keys**
         - In Azure Portal: Function > Keys > Add
         - In code, require the key in the request URL or header.
         **Step 2: Use Azure AD Authentication**
         - App Service > Authentication > Add identity provider > Azure Active Directory
         - In code, validate the JWT token:
         ```csharp
         [FunctionName("SecureFunction")]
         public static IActionResult Run(
                 [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
         {
                 // Validate token using Microsoft.Identity.Web or custom middleware
                 // ...
                 return new OkResult();
         }
         ```
         **Step 3: Use API Management**
         - Import your function into APIM, apply policies for authentication, rate limiting, etc.
         **References:**
         - [Secure Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/security-concepts)

4. How do you handle dependency injection?
     - **Answer:**
         Register services in the Startup class and use constructor injection in function classes.
     - **Implementation:**
         **Step 1: Add NuGet Package**
         - Microsoft.Azure.Functions.Extensions
         **Step 2: Create Startup Class**
         ```csharp
         using Microsoft.Azure.Functions.Extensions.DependencyInjection;
         using Microsoft.Extensions.DependencyInjection;
     
         [assembly: FunctionsStartup(typeof(MyNamespace.Startup))]
         namespace MyNamespace
         {
                 public class Startup : FunctionsStartup
                 {
                         public override void Configure(IFunctionsHostBuilder builder)
                         {
                                 builder.Services.AddSingleton<IMyService, MyService>();
                         }
                 }
         }
         ```
         **Step 3: Use Constructor Injection**
         ```csharp
         public class MyFunction
         {
                 private readonly IMyService _service;
                 public MyFunction(IMyService service)
                 {
                         _service = service;
                 }
                 [FunctionName("MyFunction")]
                 public void Run([TimerTrigger("0 */5 * * * *")] TimerInfo timer, ILogger log)
                 {
                         _service.DoWork();
                 }
         }
         ```
         **References:**
         - [Dependency injection in Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-dotnet-dependency-injection)

5. How do you manage function timeouts?
     - **Answer:**
         Set the timeout in host.json for the Consumption plan (max 5 or 10 minutes), or use the Premium plan for longer executions.
     - **Implementation:**
         **Step 1: Set Timeout in host.json**
         ```json
         {
             "functionTimeout": "00:10:00"
         }
         ```
         **Step 2: Use Premium Plan for Unlimited Timeout**
         - Create your function app in a Premium plan (see question 1)
         **References:**
         - [host.json reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-host-json)

6. How do you monitor function executions?
     - **Answer:**
         Use Application Insights to monitor executions, review logs, and set up alerts.
     - **Implementation:**
         **Step 1: Add Application Insights SDK**
         - NuGet: Microsoft.ApplicationInsights
         **Step 2: Configure in host.json**
         ```json
         {
             "logging": {
                 "applicationInsights": {
                     "samplingSettings": {
                         "isEnabled": true
                     }
                 }
             }
         }
         ```
         **Step 3: Track Custom Events**
         ```csharp
         var telemetry = new TelemetryClient();
         telemetry.TrackEvent("FunctionExecuted");
         ```
         **Step 4: Set Up Alerts in Portal**
         - Application Insights > Alerts > New alert rule
         **References:**
         - [Monitor Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-monitoring)

7. How do you handle failed executions?
     - **Answer:**
         Use retry policies, dead-letter queues, and monitor poison queues for failed executions.
     - **Implementation:**
         **Step 1: Configure Retry Policy in function.json**
         ```json
         {
             "retry": {
                 "strategy": "fixedDelay",
                 "maxRetryCount": 5,
                 "delayInterval": "00:00:10"
             }
         }
         ```
         **Step 2: Use Dead-Letter Queues**
         - For Service Bus triggers, set the dead-letter queue property in the Service Bus namespace.
         **Step 3: Monitor Poison Queues**
         - Use Azure Monitor or custom logging to alert on poison queue activity.
         **References:**
         - [Azure Functions error handling](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-error-pages)

8. How do you deploy functions as containers?
     - **Answer:**
         Package your function app as a Docker image, push it to a container registry, and deploy to Azure Functions with a custom container.
     - **Implementation:**
         **Step 1: Create Dockerfile**
         ```dockerfile
         FROM mcr.microsoft.com/azure-functions/dotnet:4
         COPY . /home/site/wwwroot
         ```
         **Step 2: Build and Push Image**
         ```sh
         docker build -t myregistry.azurecr.io/myfunc:v1 .
         docker push myregistry.azurecr.io/myfunc:v1
         ```
         **Step 3: Create Function App with Custom Container**
         ```sh
         az functionapp create --name myfuncapp --storage-account mystorage --resource-group myrg --plan myplan --deployment-container-image-name myregistry.azurecr.io/myfunc:v1
         ```
         **References:**
         - [Azure Functions custom containers](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image)

9. How do you access secrets securely?
     - **Answer:**
         Use Managed Identity to access Azure Key Vault from your function code.
     - **Implementation:**
         **Step 1: Enable Managed Identity**
         - Azure Portal: Function App > Identity > System assigned > On
         **Step 2: Grant Access in Key Vault**
         - Key Vault > Access policies > Add access policy > Select your Function App
         **Step 3: Access Secret in Code**
         ```csharp
         using Azure.Identity;
         using Azure.Security.KeyVault.Secrets;
     
         var kvUri = "https://<your-keyvault-name>.vault.azure.net/";
         var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
         KeyVaultSecret secret = await client.GetSecretAsync("MySecret");
         string secretValue = secret.Value;
         ```
         **Packages:** Azure.Identity, Azure.Security.KeyVault.Secrets
         **References:**
         - [Key Vault with Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-key-vault-reference)

10. How do you test functions locally?
     - **Answer:**
         Use Azure Functions Core Tools, configure local.settings.json, and use VS Code or Visual Studio for local debugging.
     - **Implementation:**
         **Step 1: Install Core Tools**
         ```sh
         npm install -g azure-functions-core-tools@4 --unsafe-perm true
         ```
         **Step 2: Configure local.settings.json**
         ```json
         {
             "IsEncrypted": false,
             "Values": {
                 "AzureWebJobsStorage": "UseDevelopmentStorage=true",
                 "FUNCTIONS_WORKER_RUNTIME": "dotnet"
             }
         }
         ```
         **Step 3: Run Locally**
         ```sh
         func start
         ```
         **References:**
         - [Local development with Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-local)

11. How do you implement input/output bindings?
     - **Answer:**
         Use binding attributes for triggers and outputs, such as [BlobTrigger], [QueueOutput], etc.
     - **Implementation:**
         **Example: Blob Trigger and Queue Output**
         ```csharp
         [FunctionName("BlobToQueue")]
         public static void Run(
                 [BlobTrigger("samples-workitems/{name}", Connection = "AzureWebJobsStorage")] Stream myBlob,
                 string name,
                 [Queue("output-queue", Connection = "AzureWebJobsStorage")] out string queueMessage,
                 ILogger log)
         {
                 log.LogInformation($"Processing blob: {name}");
                 queueMessage = $"Processed blob {name}";
         }
         ```
         **References:**
         - [Azure Functions triggers and bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings)

12. How do you version functions?
     - **Answer:**
         Use separate function apps for major versions, or version in the route/path for minor changes.
     - **Implementation:**
         **Step 1: Version in Route**
         ```csharp
         [FunctionName("MyFunctionV1")]
         [Route("api/v1/myfunction")]
         public IActionResult RunV1(...)
         {
                 // ...
         }
         [FunctionName("MyFunctionV2")]
         [Route("api/v2/myfunction")]
         public IActionResult RunV2(...)
         {
                 // ...
         }
         ```
         **Step 2: Use Separate Function Apps for Major Versions**
         - Deploy v1 and v2 as separate function apps
         **References:**
         - [Versioning Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-versions)

13. How do you handle scaling issues?
     - **Answer:**
         Use the Premium plan for higher scaling limits, monitor concurrency, and optimize code to reduce cold starts.
     - **Implementation:**
         **Step 1: Use Premium Plan**
         - See question 1 for creation
         **Step 2: Monitor Concurrency**
         - Application Insights > Live Metrics > Server requests
         **Step 3: Optimize Code**
         - Minimize static initialization, use dependency injection, and keep function code lightweight
         **References:**
         - [Azure Functions scaling](https://learn.microsoft.com/en-us/azure/azure-functions/functions-scale)

14. How do you restrict network access?
     - **Answer:**
         Use VNet integration, private endpoints, and access restrictions to limit network access to your function app.
     - **Implementation:**
         **Step 1: Integrate with VNet**
         ```sh
         az functionapp vnet-integration add --name myfuncapp --resource-group myrg --vnet myvnet --subnet mysubnet
         ```
         **Step 2: Configure Access Restrictions**
         - Azure Portal: Networking > Access Restrictions > Add Rule
         **Step 3: Use Private Endpoints**
         - Azure Portal: Networking > Private Endpoint > Add
         **References:**
         - [Azure Functions networking options](https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options)

15. How do you automate deployments?
     - **Answer:**
         Use CI/CD pipelines with Azure DevOps or GitHub Actions to automate deployments of your function app.
     - **Implementation:**
         **Step 1: GitHub Actions Workflow Example**
         - .github/workflows/azure-functions.yml
         ```yaml
         name: Build and deploy Azure Function app
         on:
             push:
                 branches:
                     - main
         jobs:
             build-and-deploy:
                 runs-on: ubuntu-latest
                 steps:
                     - uses: actions/checkout@v2
                     - name: Setup .NET
                         uses: actions/setup-dotnet@v2
                         with:
                             dotnet-version: '6.0.x'
                     - name: Build
                         run: dotnet build --configuration Release
                     - name: Publish
                         run: dotnet publish -c Release -o ./publish
                     - name: Deploy to Azure Function App
                         uses: Azure/functions-action@v1
                         with:
                             app-name: myfuncapp
                             publish-profile: ${{ secrets.AZUREAPPSERVICE_PUBLISHPROFILE }}
                             package: ./publish
         ```
         **Step 2: Azure DevOps Pipeline Example**
         - azure-pipelines.yml
         ```yaml
         trigger:
             - main
         pool:
             vmImage: 'ubuntu-latest'
         steps:
             - task: UseDotNet@2
                 inputs:
                     packageType: 'sdk'
                     version: '6.0.x'
             - script: dotnet build --configuration Release
             - script: dotnet publish -c Release -o $(Build.ArtifactStagingDirectory)
             - task: AzureFunctionApp@1
                 inputs:
                     appType: functionApp
                     appName: 'myfuncapp'
                     package: '$(Build.ArtifactStagingDirectory)'
         ```
         **References:**
         - [CI/CD for Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-continuous-deployment)

16. How do you implement retry policies and error handling in Azure Functions?
    - **Answer:**
        Azure Functions supports built-in retry policies for triggers and custom retry logic for output bindings. You can configure exponential backoff or fixed delay retries.
    - **Implementation:**
        **Step 1: Configure Retry Policy in host.json (for queue triggers)**
        ```json
        {
            "version": "2.0",
            "extensions": {
                "queues": {
                    "maxDequeueCount": 5,
                    "visibilityTimeout": "00:00:30"
                }
            },
            "retry": {
                "strategy": "exponentialBackoff",
                "maxRetryCount": 5,
                "minimumInterval": "00:00:10",
                "maximumInterval": "00:15:00"
            }
        }
        ```
        **Step 2: Implement Custom Retry Logic in C#**
        ```csharp
        using Polly;
        using Polly.Retry;

        public class OrderProcessor
        {
            private readonly AsyncRetryPolicy _retryPolicy;

            public OrderProcessor()
            {
                _retryPolicy = Policy
                    .Handle<HttpRequestException>()
                    .Or<TimeoutException>()
                    .WaitAndRetryAsync(
                        retryCount: 3,
                        sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)),
                        onRetry: (exception, timeSpan, retryCount, context) =>
                        {
                            _logger.LogWarning($"Retry {retryCount} after {timeSpan.TotalSeconds}s due to: {exception.Message}");
                        });
            }

            [Function("ProcessOrder")]
            public async Task Run([QueueTrigger("orders")] string orderJson)
            {
                await _retryPolicy.ExecuteAsync(async () =>
                {
                    await ProcessOrderAsync(orderJson);
                });
            }
        }
        ```
        **Step 3: Configure Dead Letter Queue for Failed Messages**
        ```csharp
        [Function("ProcessWithDeadLetter")]
        public async Task Run(
            [ServiceBusTrigger("orders", Connection = "ServiceBusConnection")] ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            try
            {
                await ProcessMessageAsync(message);
                await messageActions.CompleteMessageAsync(message);
            }
            catch (Exception ex) when (message.DeliveryCount >= 5)
            {
                await messageActions.DeadLetterMessageAsync(message,
                    deadLetterReason: "MaxRetriesExceeded",
                    deadLetterErrorDescription: ex.Message);
            }
        }
        ```
        **References:**
        - [Azure Functions Retry Policies](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-error-pages)

17. How do you implement Durable Functions for stateful workflows?
    - **Answer:**
        Durable Functions extend Azure Functions to write stateful functions. They support patterns like function chaining, fan-out/fan-in, async HTTP APIs, and human interaction workflows.
    - **Implementation:**
        **Step 1: Create Orchestrator Function**
        ```csharp
        [Function(nameof(OrderOrchestrator))]
        public static async Task<OrderResult> OrderOrchestrator(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var order = context.GetInput<Order>();

            // Function chaining pattern
            var validated = await context.CallActivityAsync<bool>("ValidateOrder", order);
            if (!validated) return new OrderResult { Success = false };

            var inventory = await context.CallActivityAsync<InventoryResult>("CheckInventory", order);

            // Fan-out/Fan-in pattern - process items in parallel
            var tasks = order.Items.Select(item =>
                context.CallActivityAsync<ProcessResult>("ProcessItem", item));
            var results = await Task.WhenAll(tasks);

            // Timer for delayed processing
            var deadline = context.CurrentUtcDateTime.AddHours(24);
            await context.CreateTimer(deadline, CancellationToken.None);

            var shipment = await context.CallActivityAsync<ShipmentResult>("CreateShipment", order);

            return new OrderResult { Success = true, ShipmentId = shipment.Id };
        }
        ```
        **Step 2: Create Activity Functions**
        ```csharp
        [Function("ValidateOrder")]
        public static async Task<bool> ValidateOrder(
            [ActivityTrigger] Order order, FunctionContext context)
        {
            var logger = context.GetLogger("ValidateOrder");
            logger.LogInformation($"Validating order {order.Id}");

            // Validation logic
            return order.Items.Any() && order.TotalAmount > 0;
        }

        [Function("ProcessItem")]
        public static async Task<ProcessResult> ProcessItem(
            [ActivityTrigger] OrderItem item, FunctionContext context)
        {
            // Process individual item
            await Task.Delay(100); // Simulate processing
            return new ProcessResult { ItemId = item.Id, Processed = true };
        }
        ```
        **Step 3: Create HTTP Starter Function**
        ```csharp
        [Function("OrderWorkflow_HttpStart")]
        public static async Task<HttpResponseData> HttpStart(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
            [DurableClient] DurableTaskClient client,
            FunctionContext context)
        {
            var order = await req.ReadFromJsonAsync<Order>();
            string instanceId = await client.ScheduleNewOrchestrationInstanceAsync(
                nameof(OrderOrchestrator), order);

            return await client.CreateCheckStatusResponseAsync(req, instanceId);
        }
        ```
        **Step 4: Implement Human Interaction Pattern**
        ```csharp
        [Function(nameof(ApprovalWorkflow))]
        public static async Task<bool> ApprovalWorkflow(
            [OrchestrationTrigger] TaskOrchestrationContext context)
        {
            var request = context.GetInput<ApprovalRequest>();

            await context.CallActivityAsync("SendApprovalEmail", request);

            // Wait for external event with timeout
            using var cts = new CancellationTokenSource();
            var approvalTask = context.WaitForExternalEvent<bool>("ApprovalResponse");
            var timeoutTask = context.CreateTimer(
                context.CurrentUtcDateTime.AddDays(7), cts.Token);

            var winner = await Task.WhenAny(approvalTask, timeoutTask);

            if (winner == approvalTask)
            {
                cts.Cancel();
                return approvalTask.Result;
            }
            return false; // Timeout - auto-reject
        }
        ```
        **References:**
        - [Durable Functions Overview](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview)
        - [Durable Functions Patterns](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-orchestrations)

18. How do you create and use custom bindings in Azure Functions?
    - **Answer:**
        Custom bindings allow you to integrate Azure Functions with services not supported by built-in bindings. You can create input, output, or trigger bindings using the WebJobs SDK extensibility model.
    - **Implementation:**
        **Step 1: Create Custom Binding Attribute**
        ```csharp
        [Binding]
        [AttributeUsage(AttributeTargets.Parameter)]
        public class CustomApiBindingAttribute : Attribute
        {
            public string Endpoint { get; set; }
            public string ApiKey { get; set; }
        }
        ```
        **Step 2: Implement Binding Extension**
        ```csharp
        public class CustomApiBinding : IExtensionConfigProvider
        {
            public void Initialize(ExtensionConfigContext context)
            {
                var rule = context.AddBindingRule<CustomApiBindingAttribute>();

                rule.BindToInput<ApiClient>(attribute =>
                    new ApiClient(attribute.Endpoint, attribute.ApiKey));

                rule.BindToCollector<ApiMessage>(attribute =>
                    new ApiMessageCollector(attribute.Endpoint, attribute.ApiKey));
            }
        }

        public class ApiMessageCollector : IAsyncCollector<ApiMessage>
        {
            private readonly string _endpoint;
            private readonly HttpClient _client;

            public ApiMessageCollector(string endpoint, string apiKey)
            {
                _endpoint = endpoint;
                _client = new HttpClient();
                _client.DefaultRequestHeaders.Add("X-API-Key", apiKey);
            }

            public async Task AddAsync(ApiMessage item, CancellationToken cancellationToken)
            {
                await _client.PostAsJsonAsync(_endpoint, item, cancellationToken);
            }

            public Task FlushAsync(CancellationToken cancellationToken) => Task.CompletedTask;
        }
        ```
        **Step 3: Register Extension in Program.cs**
        ```csharp
        var host = new HostBuilder()
            .ConfigureFunctionsWorkerDefaults()
            .ConfigureServices(services =>
            {
                services.AddSingleton<IExtensionConfigProvider, CustomApiBinding>();
            })
            .Build();

        host.Run();
        ```
        **Step 4: Use Custom Binding in Function**
        ```csharp
        [Function("SendToCustomApi")]
        public async Task Run(
            [QueueTrigger("messages")] string message,
            [CustomApiBinding(Endpoint = "https://api.example.com/messages",
                              ApiKey = "%CustomApiKey%")] IAsyncCollector<ApiMessage> apiCollector)
        {
            await apiCollector.AddAsync(new ApiMessage { Content = message });
        }
        ```
        **References:**
        - [Azure Functions Binding Extensions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-register)

19. How do you implement function authorization and manage API keys?
    - **Answer:**
        Azure Functions supports multiple authorization levels: Anonymous, Function, Admin, and System. You can also implement custom authentication using Azure AD, API keys, or JWT tokens.
    - **Implementation:**
        **Step 1: Configure Authorization Levels**
        ```csharp
        // Anonymous - No key required
        [Function("PublicApi")]
        public async Task<HttpResponseData> PublicApi(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            return req.CreateResponse(HttpStatusCode.OK);
        }

        // Function level - Requires function-specific key
        [Function("ProtectedApi")]
        public async Task<HttpResponseData> ProtectedApi(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
        {
            return req.CreateResponse(HttpStatusCode.OK);
        }

        // Admin level - Requires master key
        [Function("AdminApi")]
        public async Task<HttpResponseData> AdminApi(
            [HttpTrigger(AuthorizationLevel.Admin, "delete")] HttpRequestData req)
        {
            return req.CreateResponse(HttpStatusCode.OK);
        }
        ```
        **Step 2: Implement Azure AD Authentication**
        ```csharp
        [Function("AzureAdProtected")]
        public async Task<HttpResponseData> AzureAdProtected(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req,
            FunctionContext context)
        {
            var principal = context.Features.Get<IFunctionsClaimsPrincipal>()?.Principal;

            if (principal?.Identity?.IsAuthenticated != true)
            {
                var response = req.CreateResponse(HttpStatusCode.Unauthorized);
                return response;
            }

            var userId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new { UserId = userId });
            return response;
        }
        ```
        **Step 3: Configure Azure AD in Azure Portal/CLI**
        ```sh
        # Enable Azure AD authentication for Function App
        az webapp auth update --resource-group myrg --name myfuncapp \
            --enabled true \
            --action LoginWithAzureActiveDirectory \
            --aad-client-id <client-id> \
            --aad-token-issuer-url https://sts.windows.net/<tenant-id>/
        ```
        **Step 4: Implement Custom JWT Validation**
        ```csharp
        public class JwtValidator
        {
            private readonly TokenValidationParameters _validationParams;

            public JwtValidator(IConfiguration config)
            {
                _validationParams = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = config["Jwt:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = config["Jwt:Audience"],
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(config["Jwt:Secret"])),
                    ValidateLifetime = true
                };
            }

            public ClaimsPrincipal ValidateToken(string token)
            {
                var handler = new JwtSecurityTokenHandler();
                return handler.ValidateToken(token, _validationParams, out _);
            }
        }

        [Function("CustomJwtProtected")]
        public async Task<HttpResponseData> CustomJwtProtected(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
        {
            var authHeader = req.Headers.GetValues("Authorization").FirstOrDefault();
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return req.CreateResponse(HttpStatusCode.Unauthorized);
            }

            try
            {
                var token = authHeader.Substring(7);
                var principal = _jwtValidator.ValidateToken(token);
                // Process authenticated request
            }
            catch (SecurityTokenException)
            {
                return req.CreateResponse(HttpStatusCode.Unauthorized);
            }
        }
        ```
        **Step 5: Manage Function Keys via CLI**
        ```sh
        # List function keys
        az functionapp keys list --resource-group myrg --name myfuncapp

        # Create new function key
        az functionapp keys set --resource-group myrg --name myfuncapp \
            --key-type functionKeys --key-name mykey --key-value <key-value>

        # Rotate host key
        az functionapp keys set --resource-group myrg --name myfuncapp \
            --key-type systemKeys --key-name newkey
        ```
        **References:**
        - [Azure Functions Authentication](https://learn.microsoft.com/en-us/azure/azure-functions/security-concepts)
        - [Configure Azure AD Auth](https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad)

20. How do you monitor and troubleshoot Azure Functions effectively?
    - **Answer:**
        Use Application Insights for telemetry, distributed tracing, and custom metrics. Leverage Azure Monitor for alerts, log queries, and performance monitoring.
    - **Implementation:**
        **Step 1: Configure Application Insights in host.json**
        ```json
        {
            "version": "2.0",
            "logging": {
                "applicationInsights": {
                    "samplingSettings": {
                        "isEnabled": true,
                        "maxTelemetryItemsPerSecond": 20,
                        "excludedTypes": "Request"
                    },
                    "enableLiveMetrics": true,
                    "httpAutoCollectionOptions": {
                        "enableHttpTriggerExtendedInfoCollection": true,
                        "enableW3CDistributedTracing": true,
                        "enableResponseHeaderInjection": true
                    }
                },
                "logLevel": {
                    "default": "Information",
                    "Host.Results": "Error",
                    "Function": "Information",
                    "Host.Aggregator": "Trace"
                }
            }
        }
        ```
        **Step 2: Implement Custom Telemetry**
        ```csharp
        public class OrderFunction
        {
            private readonly TelemetryClient _telemetry;
            private readonly ILogger<OrderFunction> _logger;

            public OrderFunction(TelemetryClient telemetry, ILogger<OrderFunction> logger)
            {
                _telemetry = telemetry;
                _logger = logger;
            }

            [Function("ProcessOrder")]
            public async Task<HttpResponseData> ProcessOrder(
                [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
            {
                var stopwatch = Stopwatch.StartNew();

                try
                {
                    var order = await req.ReadFromJsonAsync<Order>();

                    // Track custom event
                    _telemetry.TrackEvent("OrderReceived", new Dictionary<string, string>
                    {
                        ["OrderId"] = order.Id,
                        ["CustomerId"] = order.CustomerId
                    }, new Dictionary<string, double>
                    {
                        ["ItemCount"] = order.Items.Count,
                        ["TotalAmount"] = (double)order.TotalAmount
                    });

                    // Process order with dependency tracking
                    using (_telemetry.StartOperation<DependencyTelemetry>("ProcessPayment"))
                    {
                        await ProcessPaymentAsync(order);
                    }

                    // Track custom metric
                    _telemetry.TrackMetric("OrderProcessingTime", stopwatch.ElapsedMilliseconds);

                    return req.CreateResponse(HttpStatusCode.OK);
                }
                catch (Exception ex)
                {
                    _telemetry.TrackException(ex, new Dictionary<string, string>
                    {
                        ["Operation"] = "ProcessOrder"
                    });
                    throw;
                }
            }
        }
        ```
        **Step 3: Query Function Logs with KQL**
        ```kusto
        // Find slow function executions
        requests
        | where cloud_RoleName == "myfuncapp"
        | where duration > 5000
        | project timestamp, name, duration, resultCode
        | order by duration desc

        // Analyze function failures
        exceptions
        | where cloud_RoleName == "myfuncapp"
        | summarize count() by type, outerMessage
        | order by count_ desc

        // Track function invocation trends
        requests
        | where cloud_RoleName == "myfuncapp"
        | summarize count() by bin(timestamp, 1h), name
        | render timechart

        // Find cold start issues
        customMetrics
        | where name == "FunctionExecutionTimeMs"
        | summarize avg(value), percentile(value, 95), max(value) by bin(timestamp, 1h)
        ```
        **Step 4: Create Azure Monitor Alert**
        ```sh
        # Create alert for function failures
        az monitor metrics alert create --name "FunctionFailures" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/sites/myfuncapp \
            --condition "total requests > 10 where ResultCode != 200" \
            --window-size 5m \
            --evaluation-frequency 1m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/myactiongroup
        ```
        **Step 5: Enable Diagnostic Logging**
        ```sh
        az monitor diagnostic-settings create --name "FuncDiagnostics" \
            --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/sites/myfuncapp \
            --workspace /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.OperationalInsights/workspaces/myworkspace \
            --logs '[{"category": "FunctionAppLogs", "enabled": true}]' \
            --metrics '[{"category": "AllMetrics", "enabled": true}]'
        ```
        **References:**
        - [Monitor Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-monitoring)
        - [Application Insights for Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-monitoring?tabs=cmd#application-insights-integration)

### 1.3 Azure Virtual Machines
1. How do you automate VM provisioning?
    - **Answer:**
        Use ARM/Bicep templates, Azure CLI, or Terraform to provision VMs consistently and repeatably.
    - **Implementation:**
        **Step 1: Create VM with Azure CLI**
        ```sh
        az vm create --resource-group myrg --name myvm --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --size Standard_B2s
        ```
        **Step 2: Create VM with Bicep Template**
        ```bicep
        resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
            name: 'myvm'
            location: resourceGroup().location
            properties: {
                hardwareProfile: { vmSize: 'Standard_B2s' }
                osProfile: {
                    computerName: 'myvm'
                    adminUsername: 'azureuser'
                    linuxConfiguration: {
                        disablePasswordAuthentication: true
                        ssh: { publicKeys: [{ path: '/home/azureuser/.ssh/authorized_keys', keyData: '<ssh-public-key>' }] }
                    }
                }
                storageProfile: {
                    imageReference: { publisher: 'Canonical', offer: '0001-com-ubuntu-server-jammy', sku: '22_04-lts', version: 'latest' }
                    osDisk: { createOption: 'FromImage', managedDisk: { storageAccountType: 'Standard_LRS' } }
                }
                networkProfile: { networkInterfaces: [{ id: nic.id }] }
            }
        }
        ```
        **References:**
        - [Create VM with Azure CLI](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-cli)

2. How do you secure VM access?
    - **Answer:**
        Use Just-In-Time (JIT) access, NSGs, disable RDP/SSH from internet, and use Azure Bastion for secure remote access.
    - **Implementation:**
        **Step 1: Enable Just-In-Time Access**
        ```sh
        az security jit-policy create --resource-group myrg --location eastus --jit-network-access-policy-name myjitpolicy --virtual-machines "[{\"id\":\"/subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm\",\"ports\":[{\"number\":22,\"protocol\":\"TCP\",\"allowedSourceAddressPrefix\":\"*\",\"maxRequestAccessDuration\":\"PT3H\"}]}]"
        ```
        **Step 2: Create NSG Rule to Block Direct SSH/RDP**
        ```sh
        az network nsg rule create --resource-group myrg --nsg-name mynsg --name DenySSHFromInternet --priority 100 --direction Inbound --access Deny --protocol Tcp --destination-port-ranges 22
        ```
        **Step 3: Deploy Azure Bastion**
        ```sh
        az network bastion create --name mybastion --resource-group myrg --vnet-name myvnet --public-ip-address mybastionpip
        ```
        **References:**
        - [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
        - [JIT VM access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)

3. How do you implement VM backups?
    - **Answer:**
        Use Azure Backup service, configure backup policies, and set retention periods for recovery points.
    - **Implementation:**
        **Step 1: Create Recovery Services Vault**
        ```sh
        az backup vault create --resource-group myrg --name myvault --location eastus
        ```
        **Step 2: Enable Backup for VM**
        ```sh
        az backup protection enable-for-vm --resource-group myrg --vault-name myvault --vm myvm --policy-name DefaultPolicy
        ```
        **Step 3: Trigger Backup Manually**
        ```sh
        az backup protection backup-now --resource-group myrg --vault-name myvault --container-name myvm --item-name myvm --retain-until 30-12-2026
        ```
        **Step 4: Restore VM from Backup**
        ```sh
        az backup restore restore-disks --resource-group myrg --vault-name myvault --container-name myvm --item-name myvm --rp-name <recovery-point-name> --storage-account mystorageaccount
        ```
        **References:**
        - [Azure Backup for VMs](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-first-look-arm)

4. How do you monitor VM health?
    - **Answer:**
        Use Azure Monitor, Log Analytics, and VM Insights to collect metrics, logs, and visualize VM performance.
    - **Implementation:**
        **Step 1: Enable VM Insights**
        ```sh
        az vm extension set --resource-group myrg --vm-name myvm --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor --version 1.0
        ```
        **Step 2: Create Log Analytics Workspace**
        ```sh
        az monitor log-analytics workspace create --resource-group myrg --workspace-name myworkspace
        ```
        **Step 3: Query VM Metrics (Kusto)**
        ```kusto
        Perf
        | where ObjectName == "Processor" and CounterName == "% Processor Time"
        | summarize avg(CounterValue) by bin(TimeGenerated, 5m), Computer
        ```
        **References:**
        - [VM Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)

5. How do you scale VMs automatically?
    - **Answer:**
        Use Virtual Machine Scale Sets (VMSS) with autoscale rules based on metrics like CPU or memory.
    - **Implementation:**
        **Step 1: Create VMSS**
        ```sh
        az vmss create --resource-group myrg --name myvmss --image Ubuntu2204 --upgrade-policy-mode automatic --admin-username azureuser --generate-ssh-keys --instance-count 2
        ```
        **Step 2: Configure Autoscale Rule**
        ```sh
        az monitor autoscale create --resource-group myrg --resource myvmss --resource-type Microsoft.Compute/virtualMachineScaleSets --name myautoscale --min-count 2 --max-count 10 --count 2
        az monitor autoscale rule create --resource-group myrg --autoscale-name myautoscale --condition "Percentage CPU > 70 avg 5m" --scale out 1
        az monitor autoscale rule create --resource-group myrg --autoscale-name myautoscale --condition "Percentage CPU < 30 avg 5m" --scale in 1
        ```
        **References:**
        - [VMSS Autoscale](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-autoscale-overview)

6. How do you patch VMs?
    - **Answer:**
        Use Azure Update Management for scheduled patching, compliance tracking, and automated updates.
    - **Implementation:**
        **Step 1: Enable Update Management**
        - Azure Portal: Automation Account > Update Management > Add VMs
        **Step 2: Create Update Deployment Schedule**
        ```sh
        az automation software-update-configuration create --automation-account-name myautomation --resource-group myrg --name myupdateconfig --frequency Week --interval 1 --azure-virtual-machines "/subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm" --included-update-classifications Critical Security
        ```
        **Step 3: View Compliance Reports**
        - Azure Portal: Automation Account > Update Management > Compliance
        **References:**
        - [Azure Update Management](https://learn.microsoft.com/en-us/azure/automation/update-management/overview)

7. How do you manage secrets on VMs?
    - **Answer:**
        Use Managed Identity to access Key Vault secrets, never store secrets on disk or in code.
    - **Implementation:**
        **Step 1: Enable System-Assigned Managed Identity**
        ```sh
        az vm identity assign --resource-group myrg --name myvm
        ```
        **Step 2: Grant VM Access to Key Vault**
        ```sh
        az keyvault set-policy --name myvault --object-id <vm-principal-id> --secret-permissions get list
        ```
        **Step 3: Access Secret from VM (Python)**
        ```python
        from azure.identity import ManagedIdentityCredential
        from azure.keyvault.secrets import SecretClient

        credential = ManagedIdentityCredential()
        client = SecretClient(vault_url="https://myvault.vault.azure.net/", credential=credential)
        secret = client.get_secret("MySecret")
        print(secret.value)
        ```
        **References:**
        - [VM Managed Identity with Key Vault](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-linux-vm-access-nonaad)

8. How do you optimize VM costs?
    - **Answer:**
        Use reserved instances for predictable workloads, spot VMs for interruptible workloads, and right-size VMs based on usage.
    - **Implementation:**
        **Step 1: Purchase Reserved Instance**
        - Azure Portal: Reservations > Add > Virtual Machines > Select term (1 or 3 years)
        **Step 2: Create Spot VM**
        ```sh
        az vm create --resource-group myrg --name myspotvm --image Ubuntu2204 --priority Spot --eviction-policy Deallocate --max-price 0.05 --admin-username azureuser --generate-ssh-keys
        ```
        **Step 3: Right-Size VM**
        - Azure Portal: VM > Insights > Performance > Review recommendations
        ```sh
        az vm resize --resource-group myrg --name myvm --size Standard_B1s
        ```
        **References:**
        - [Azure Reserved Instances](https://learn.microsoft.com/en-us/azure/cost-management-billing/reservations/save-compute-costs-reservations)
        - [Spot VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/spot-vms)

9. How do you implement disaster recovery?
    - **Answer:**
        Use Azure Site Recovery (ASR) for replication and failover to a secondary region.
    - **Implementation:**
        **Step 1: Create Recovery Services Vault in Secondary Region**
        ```sh
        az backup vault create --resource-group myrg-dr --name myvault-dr --location westus
        ```
        **Step 2: Enable Replication for VM**
        - Azure Portal: VM > Disaster recovery > Enable replication > Select target region
        **Step 3: Test Failover**
        - Azure Portal: Recovery Services Vault > Replicated items > Test failover
        **Step 4: Perform Actual Failover**
        - Azure Portal: Recovery Services Vault > Replicated items > Failover
        **References:**
        - [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)

10. How do you automate configuration?
    - **Answer:**
        Use Custom Script Extensions, Desired State Configuration (DSC), or Ansible for automated VM configuration.
    - **Implementation:**
        **Step 1: Use Custom Script Extension**
        ```sh
        az vm extension set --resource-group myrg --vm-name myvm --name customScript --publisher Microsoft.Azure.Extensions --settings '{"fileUris":["https://mystorageaccount.blob.core.windows.net/scripts/install.sh"],"commandToExecute":"./install.sh"}'
        ```
        **Step 2: Use DSC Extension (PowerShell)**
        ```powershell
        Set-AzVMDscExtension -ResourceGroupName "myrg" -VMName "myvm" -ArchiveBlobName "MyConfiguration.ps1.zip" -ArchiveStorageAccountName "mystorageaccount" -ConfigurationName "MyConfiguration" -Version "2.77"
        ```
        **Step 3: Use Ansible Playbook**
        ```yaml
        - hosts: all
          tasks:
            - name: Install nginx
              apt:
                name: nginx
                state: present
        ```
        **References:**
        - [Custom Script Extension](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux)

11. How do you monitor network traffic?
    - **Answer:**
        Use Network Watcher, NSG flow logs, and traffic analytics to monitor and analyze network traffic.
    - **Implementation:**
        **Step 1: Enable Network Watcher**
        ```sh
        az network watcher configure --resource-group NetworkWatcherRG --locations eastus --enabled
        ```
        **Step 2: Enable NSG Flow Logs**
        ```sh
        az network watcher flow-log create --resource-group myrg --nsg mynsg --storage-account mystorageaccount --enabled true --retention 7 --name myflowlog
        ```
        **Step 3: Enable Traffic Analytics**
        - Azure Portal: Network Watcher > Traffic Analytics > Configure workspace
        **Step 4: Analyze Traffic (Kusto)**
        ```kusto
        AzureNetworkAnalytics_CL
        | where FlowType_s == "ExternalPublic"
        | summarize count() by DestIP_s
        ```
        **References:**
        - [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)

12. How do you handle VM image management?
    - **Answer:**
        Use Azure Compute Gallery (formerly Shared Image Gallery) for versioning, sharing, and distributing VM images.
    - **Implementation:**
        **Step 1: Create Compute Gallery**
        ```sh
        az sig create --resource-group myrg --gallery-name mygallery
        ```
        **Step 2: Create Image Definition**
        ```sh
        az sig image-definition create --resource-group myrg --gallery-name mygallery --gallery-image-definition myimagedef --publisher mycompany --offer myoffer --sku mysku --os-type Linux
        ```
        **Step 3: Create Image Version from VM**
        ```sh
        az sig image-version create --resource-group myrg --gallery-name mygallery --gallery-image-definition myimagedef --gallery-image-version 1.0.0 --managed-image /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/images/myimage
        ```
        **References:**
        - [Azure Compute Gallery](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries)

13. How do you restrict outbound internet access?
    - **Answer:**
        Use NSGs, User Defined Routes (UDR), and Azure Firewall to control and restrict outbound traffic.
    - **Implementation:**
        **Step 1: Create NSG Rule to Deny Outbound Internet**
        ```sh
        az network nsg rule create --resource-group myrg --nsg-name mynsg --name DenyOutboundInternet --priority 100 --direction Outbound --access Deny --protocol "*" --destination-address-prefixes Internet
        ```
        **Step 2: Create Route Table with Azure Firewall**
        ```sh
        az network route-table create --resource-group myrg --name myrt
        az network route-table route create --resource-group myrg --route-table-name myrt --name ToFirewall --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address <firewall-private-ip>
        ```
        **Step 3: Associate Route Table with Subnet**
        ```sh
        az network vnet subnet update --resource-group myrg --vnet-name myvnet --name mysubnet --route-table myrt
        ```
        **References:**
        - [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview)

14. How do you implement high availability?
    - **Answer:**
        Use Availability Sets (fault/update domains) or Availability Zones (datacenter-level redundancy) for high availability.
    - **Implementation:**
        **Step 1: Create Availability Set**
        ```sh
        az vm availability-set create --resource-group myrg --name myavset --platform-fault-domain-count 2 --platform-update-domain-count 5
        ```
        **Step 2: Create VM in Availability Set**
        ```sh
        az vm create --resource-group myrg --name myvm1 --image Ubuntu2204 --availability-set myavset --admin-username azureuser --generate-ssh-keys
        ```
        **Step 3: Create VM in Availability Zone**
        ```sh
        az vm create --resource-group myrg --name myvm-zone1 --image Ubuntu2204 --zone 1 --admin-username azureuser --generate-ssh-keys
        ```
        **References:**
        - [Availability Sets](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)
        - [Availability Zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview)

15. How do you automate scaling policies?
    - **Answer:**
        Use autoscale rules in VMSS with metric-based triggers, monitor metrics, and adjust thresholds as needed.
    - **Implementation:**
        **Step 1: Create Autoscale Profile**
        ```sh
        az monitor autoscale create --resource-group myrg --resource myvmss --resource-type Microsoft.Compute/virtualMachineScaleSets --name myautoscale --min-count 2 --max-count 10 --count 2
        ```
        **Step 2: Add Scale-Out Rule (CPU > 70%)**
        ```sh
        az monitor autoscale rule create --resource-group myrg --autoscale-name myautoscale --condition "Percentage CPU > 70 avg 10m" --scale out 2
        ```
        **Step 3: Add Scale-In Rule (CPU < 30%)**
        ```sh
        az monitor autoscale rule create --resource-group myrg --autoscale-name myautoscale --condition "Percentage CPU < 30 avg 10m" --scale in 1
        ```
        **Step 4: Add Schedule-Based Profile**
        ```sh
        az monitor autoscale profile create --resource-group myrg --autoscale-name myautoscale --name weekday --min-count 5 --max-count 15 --count 5 --recurrence week Monday Tuesday Wednesday Thursday Friday --start 08:00 --end 18:00 --timezone "Eastern Standard Time"
        ```
        **References:**
        - [VMSS Autoscale Rules](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-autoscale-overview)

16. How do you implement custom script extensions for VM configuration?
    - **Answer:**
        Custom Script Extension downloads and executes scripts on Azure VMs for post-deployment configuration, software installation, or any other configuration task.
    - **Implementation:**
        **Step 1: Deploy Custom Script Extension with Azure CLI**
        ```sh
        az vm extension set \
            --resource-group myrg \
            --vm-name myvm \
            --name CustomScriptExtension \
            --publisher Microsoft.Compute \
            --version 1.10 \
            --settings '{"fileUris":["https://mystorageaccount.blob.core.windows.net/scripts/setup.sh"]}' \
            --protected-settings '{"commandToExecute":"sh setup.sh","storageAccountName":"mystorageaccount","storageAccountKey":"<storage-key>"}'
        ```
        **Step 2: Custom Script Extension with Bicep**
        ```bicep
        resource customScript 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
            parent: vm
            name: 'CustomScriptExtension'
            location: resourceGroup().location
            properties: {
                publisher: 'Microsoft.Compute'
                type: 'CustomScriptExtension'
                typeHandlerVersion: '1.10'
                autoUpgradeMinorVersion: true
                settings: {
                    fileUris: [
                        'https://mystorageaccount.blob.core.windows.net/scripts/install-web-server.ps1'
                    ]
                }
                protectedSettings: {
                    commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File install-web-server.ps1'
                    storageAccountName: storageAccount.name
                    storageAccountKey: storageAccount.listKeys().keys[0].value
                }
            }
        }
        ```
        **Step 3: Example PowerShell Script for Windows VM**
        ```powershell
        # install-web-server.ps1
        Install-WindowsFeature -Name Web-Server -IncludeManagementTools
        Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value "Hello from Azure VM!"

        # Configure firewall
        New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
        ```
        **Step 4: Linux Custom Script Example**
        ```sh
        # setup.sh
        #!/bin/bash
        apt-get update
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
        echo "Hello from Azure VM!" > /var/www/html/index.html
        ```
        **References:**
        - [Custom Script Extension for Windows](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows)
        - [Custom Script Extension for Linux](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux)

17. How do you implement Azure Disk Encryption for VMs?
    - **Answer:**
        Azure Disk Encryption uses BitLocker (Windows) or DM-Crypt (Linux) to encrypt OS and data disks. Keys are stored in Azure Key Vault for secure management.
    - **Implementation:**
        **Step 1: Create Key Vault and Enable Disk Encryption**
        ```sh
        # Create Key Vault
        az keyvault create --name mykeyvault --resource-group myrg --location eastus \
            --enabled-for-disk-encryption true

        # Create encryption key
        az keyvault key create --vault-name mykeyvault --name mydiskencryptionkey \
            --protection software
        ```
        **Step 2: Enable Encryption on Windows VM**
        ```sh
        az vm encryption enable --resource-group myrg --name mywindowsvm \
            --disk-encryption-keyvault mykeyvault \
            --key-encryption-key mydiskencryptionkey \
            --volume-type All
        ```
        **Step 3: Enable Encryption on Linux VM**
        ```sh
        az vm encryption enable --resource-group myrg --name mylinuxvm \
            --disk-encryption-keyvault mykeyvault \
            --volume-type All \
            --encrypt-format-all
        ```
        **Step 4: Check Encryption Status**
        ```sh
        az vm encryption show --resource-group myrg --name myvm
        ```
        **Step 5: Bicep Template for Encrypted VM**
        ```bicep
        resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
            name: 'encryptedvm'
            location: resourceGroup().location
            properties: {
                hardwareProfile: { vmSize: 'Standard_D2s_v3' }
                storageProfile: {
                    imageReference: {
                        publisher: 'MicrosoftWindowsServer'
                        offer: 'WindowsServer'
                        sku: '2022-datacenter'
                        version: 'latest'
                    }
                    osDisk: {
                        createOption: 'FromImage'
                        managedDisk: {
                            storageAccountType: 'Premium_LRS'
                        }
                        encryptionSettings: {
                            enabled: true
                            diskEncryptionKey: {
                                sourceVault: { id: keyVault.id }
                                secretUrl: diskEncryptionSecret.properties.secretUri
                            }
                        }
                    }
                }
                osProfile: { /* ... */ }
                networkProfile: { /* ... */ }
            }
        }
        ```
        **References:**
        - [Azure Disk Encryption Overview](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview)
        - [Enable Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disk-encryption-linux)

18. How do you implement VM backup and disaster recovery?
    - **Answer:**
        Azure Backup provides agent-based or agentless backup for VMs. Azure Site Recovery enables disaster recovery by replicating VMs to secondary regions.
    - **Implementation:**
        **Step 1: Create Recovery Services Vault**
        ```sh
        az backup vault create --resource-group myrg --name myrecoveryvault --location eastus
        ```
        **Step 2: Enable Backup for VM**
        ```sh
        # Set backup policy
        az backup protection enable-for-vm \
            --resource-group myrg \
            --vault-name myrecoveryvault \
            --vm myvm \
            --policy-name DefaultPolicy
        ```
        **Step 3: Create Custom Backup Policy**
        ```sh
        az backup policy create \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --name DailyBackupPolicy \
            --backup-management-type AzureIaasVM \
            --policy '{
                "schedulePolicy": {
                    "schedulePolicyType": "SimpleSchedulePolicy",
                    "scheduleRunFrequency": "Daily",
                    "scheduleRunTimes": ["2023-01-01T02:00:00Z"]
                },
                "retentionPolicy": {
                    "retentionPolicyType": "LongTermRetentionPolicy",
                    "dailySchedule": {
                        "retentionTimes": ["2023-01-01T02:00:00Z"],
                        "retentionDuration": { "count": 30, "durationType": "Days" }
                    },
                    "weeklySchedule": {
                        "daysOfTheWeek": ["Sunday"],
                        "retentionTimes": ["2023-01-01T02:00:00Z"],
                        "retentionDuration": { "count": 12, "durationType": "Weeks" }
                    }
                }
            }'
        ```
        **Step 4: Trigger On-Demand Backup**
        ```sh
        az backup protection backup-now \
            --resource-group myrg \
            --vault-name myrecoveryvault \
            --container-name "IaasVMContainer;myvm" \
            --item-name myvm \
            --retain-until 31-12-2024
        ```
        **Step 5: Enable Azure Site Recovery for DR**
        ```sh
        # Enable replication to secondary region
        az site-recovery replication-protected-item create \
            --fabric-name primaryfabric \
            --protection-container primarycontainer \
            --name myvm-replication \
            --resource-group myrg \
            --vault-name myrecoveryvault \
            --policy-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.RecoveryServices/vaults/myrecoveryvault/replicationPolicies/24-hour-retention-policy \
            --provider-specific-details '{
                "instanceType": "A2A",
                "recoveryResourceGroupId": "/subscriptions/<sub-id>/resourceGroups/myrg-dr",
                "recoveryAvailabilitySetId": null,
                "recoveryAzureNetworkId": "/subscriptions/<sub-id>/resourceGroups/myrg-dr/providers/Microsoft.Network/virtualNetworks/dr-vnet"
            }'
        ```
        **Step 6: Restore VM from Backup**
        ```sh
        # List recovery points
        az backup recoverypoint list \
            --resource-group myrg \
            --vault-name myrecoveryvault \
            --container-name "IaasVMContainer;myvm" \
            --item-name myvm

        # Restore VM
        az backup restore restore-disks \
            --resource-group myrg \
            --vault-name myrecoveryvault \
            --container-name "IaasVMContainer;myvm" \
            --item-name myvm \
            --rp-name <recovery-point-name> \
            --storage-account mystorageaccount
        ```
        **References:**
        - [Azure VM Backup](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-introduction)
        - [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)

19. How do you configure VM availability using Availability Zones and Sets?
    - **Answer:**
        Availability Zones protect against datacenter failures (99.99% SLA), while Availability Sets protect against hardware failures within a datacenter (99.95% SLA).
    - **Implementation:**
        **Step 1: Create VM in Availability Zone**
        ```sh
        az vm create \
            --resource-group myrg \
            --name myvm-zone1 \
            --image Ubuntu2204 \
            --zone 1 \
            --admin-username azureuser \
            --generate-ssh-keys
        ```
        **Step 2: Create Availability Set**
        ```sh
        az vm availability-set create \
            --resource-group myrg \
            --name myavailabilityset \
            --platform-fault-domain-count 3 \
            --platform-update-domain-count 5
        ```
        **Step 3: Create VM in Availability Set**
        ```sh
        az vm create \
            --resource-group myrg \
            --name myvm-as \
            --image Ubuntu2204 \
            --availability-set myavailabilityset \
            --admin-username azureuser \
            --generate-ssh-keys
        ```
        **Step 4: Bicep Template with Availability Zones**
        ```bicep
        resource vm1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
            name: 'vm-zone1'
            location: resourceGroup().location
            zones: ['1']
            properties: {
                hardwareProfile: { vmSize: 'Standard_D2s_v3' }
                storageProfile: {
                    imageReference: {
                        publisher: 'Canonical'
                        offer: '0001-com-ubuntu-server-jammy'
                        sku: '22_04-lts'
                        version: 'latest'
                    }
                    osDisk: {
                        createOption: 'FromImage'
                        managedDisk: { storageAccountType: 'Premium_LRS' }
                    }
                }
                networkProfile: { networkInterfaces: [{ id: nic1.id }] }
            }
        }

        resource vm2 'Microsoft.Compute/virtualMachines@2023-03-01' = {
            name: 'vm-zone2'
            location: resourceGroup().location
            zones: ['2']
            properties: { /* Similar to vm1 */ }
        }

        resource vm3 'Microsoft.Compute/virtualMachines@2023-03-01' = {
            name: 'vm-zone3'
            location: resourceGroup().location
            zones: ['3']
            properties: { /* Similar to vm1 */ }
        }
        ```
        **Step 5: Zone-Redundant Load Balancer**
        ```sh
        az network lb create \
            --resource-group myrg \
            --name mylb \
            --sku Standard \
            --frontend-ip-name myFrontEnd \
            --backend-pool-name myBackEndPool \
            --public-ip-address myPublicIP \
            --public-ip-zone 1 2 3

        # Add VMs from different zones to backend pool
        az network nic ip-config address-pool add \
            --address-pool myBackEndPool \
            --ip-config-name ipconfig1 \
            --nic-name vm-zone1-nic \
            --resource-group myrg \
            --lb-name mylb
        ```
        **References:**
        - [Availability Zones](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview)
        - [Availability Sets](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)

20. How do you monitor VM performance and configure alerts?
    - **Answer:**
        Use Azure Monitor with VM Insights for comprehensive monitoring. Configure metric alerts for CPU, memory, disk, and network. Use Log Analytics for custom queries.
    - **Implementation:**
        **Step 1: Enable VM Insights**
        ```sh
        # Create Log Analytics Workspace
        az monitor log-analytics workspace create \
            --resource-group myrg \
            --workspace-name myworkspace

        # Enable VM Insights
        az vm extension set \
            --resource-group myrg \
            --vm-name myvm \
            --name AzureMonitorLinuxAgent \
            --publisher Microsoft.Azure.Monitor \
            --version 1.0

        # Enable dependency agent for mapping
        az vm extension set \
            --resource-group myrg \
            --vm-name myvm \
            --name DependencyAgentLinux \
            --publisher Microsoft.Azure.Monitoring.DependencyAgent
        ```
        **Step 2: Create CPU Alert Rule**
        ```sh
        az monitor metrics alert create \
            --name "High CPU Alert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm \
            --condition "avg Percentage CPU > 80" \
            --window-size 5m \
            --evaluation-frequency 1m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/myactiongroup \
            --description "Alert when CPU exceeds 80%"
        ```
        **Step 3: Create Memory and Disk Alerts**
        ```sh
        # Memory alert (requires VM Insights)
        az monitor metrics alert create \
            --name "High Memory Alert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm \
            --condition "avg Available Memory Bytes < 1073741824" \
            --window-size 5m \
            --evaluation-frequency 1m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/myactiongroup

        # Disk space alert
        az monitor metrics alert create \
            --name "Low Disk Space Alert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm \
            --condition "avg Logical Disk Bytes/sec > 100000000" \
            --window-size 5m
        ```
        **Step 4: Query VM Performance with KQL**
        ```kusto
        // CPU utilization over time
        Perf
        | where ObjectName == "Processor" and CounterName == "% Processor Time"
        | where Computer == "myvm"
        | summarize avg(CounterValue) by bin(TimeGenerated, 5m)
        | render timechart

        // Memory utilization
        Perf
        | where ObjectName == "Memory" and CounterName == "% Committed Bytes In Use"
        | where Computer == "myvm"
        | summarize avg(CounterValue) by bin(TimeGenerated, 5m)

        // Disk I/O
        Perf
        | where ObjectName == "LogicalDisk" and CounterName == "Disk Bytes/sec"
        | where Computer == "myvm"
        | summarize sum(CounterValue) by bin(TimeGenerated, 5m), InstanceName

        // Network throughput
        Perf
        | where ObjectName == "Network Adapter" and CounterName == "Bytes Total/sec"
        | where Computer == "myvm"
        | summarize sum(CounterValue) by bin(TimeGenerated, 5m)
        ```
        **Step 5: Bicep Template for Monitoring**
        ```bicep
        resource vmInsights 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
            name: 'vm-monitoring-rule'
            location: resourceGroup().location
            properties: {
                dataSources: {
                    performanceCounters: [
                        {
                            streams: ['Microsoft-Perf']
                            samplingFrequencyInSeconds: 60
                            counterSpecifiers: [
                                '\\Processor(_Total)\\% Processor Time'
                                '\\Memory\\% Committed Bytes In Use'
                                '\\LogicalDisk(_Total)\\% Free Space'
                                '\\Network Interface(*)\\Bytes Total/sec'
                            ]
                            name: 'perfCounterDataSource'
                        }
                    ]
                }
                destinations: {
                    logAnalytics: [
                        {
                            workspaceResourceId: workspace.id
                            name: 'la-destination'
                        }
                    ]
                }
                dataFlows: [
                    {
                        streams: ['Microsoft-Perf']
                        destinations: ['la-destination']
                    }
                ]
            }
        }
        ```
        **References:**
        - [VM Insights Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)
        - [Azure Monitor Alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)

### 1.4 Azure Container Instances & AKS
1. How do you deploy a container to Azure Container Instances (ACI)?
    - **Answer:**
        Use Azure CLI or ARM template to deploy containers with specified image, resources, and environment variables.
    - **Implementation:**
        **Step 1: Deploy Container with Azure CLI**
        ```sh
        az container create --resource-group myrg --name mycontainer --image mcr.microsoft.com/azuredocs/aci-helloworld --dns-name-label myapp --ports 80 --cpu 1 --memory 1.5
        ```
        **Step 2: Deploy with Environment Variables**
        ```sh
        az container create --resource-group myrg --name mycontainer --image myregistry.azurecr.io/myapp:v1 --environment-variables DB_HOST=mydb.database.azure.com DB_NAME=mydb --secure-environment-variables DB_PASSWORD=secret123
        ```
        **Step 3: Deploy with ARM Template**
        ```json
        {
            "type": "Microsoft.ContainerInstance/containerGroups",
            "apiVersion": "2023-05-01",
            "name": "mycontainer",
            "location": "eastus",
            "properties": {
                "containers": [{
                    "name": "myapp",
                    "properties": {
                        "image": "mcr.microsoft.com/azuredocs/aci-helloworld",
                        "resources": { "requests": { "cpu": 1, "memoryInGb": 1.5 } },
                        "ports": [{ "port": 80 }]
                    }
                }],
                "osType": "Linux",
                "ipAddress": { "type": "Public", "ports": [{ "protocol": "TCP", "port": 80 }] }
            }
        }
        ```
        **References:**
        - [Deploy ACI](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart)

2. How do you secure containers in ACI?
    - **Answer:**
        Use VNet integration for network isolation, restrict public IP access, and use managed identities for secure resource access.
    - **Implementation:**
        **Step 1: Deploy ACI in VNet**
        ```sh
        az container create --resource-group myrg --name mycontainer --image myapp:v1 --vnet myvnet --subnet mysubnet
        ```
        **Step 2: Enable Managed Identity**
        ```sh
        az container create --resource-group myrg --name mycontainer --image myapp:v1 --assign-identity --scope /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.KeyVault/vaults/myvault
        ```
        **Step 3: Use Private Registry with Service Principal**
        ```sh
        az container create --resource-group myrg --name mycontainer --image myregistry.azurecr.io/myapp:v1 --registry-login-server myregistry.azurecr.io --registry-username <sp-client-id> --registry-password <sp-client-secret>
        ```
        **References:**
        - [Secure ACI](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-vnet)

3. How do you monitor container logs?
    - **Answer:**
        Use Log Analytics workspace, Azure Monitor, or direct log streaming with Azure CLI.
    - **Implementation:**
        **Step 1: Stream Logs in Real-Time**
        ```sh
        az container logs --resource-group myrg --name mycontainer --follow
        ```
        **Step 2: Attach to Container Console**
        ```sh
        az container attach --resource-group myrg --name mycontainer
        ```
        **Step 3: Send Logs to Log Analytics**
        ```sh
        az container create --resource-group myrg --name mycontainer --image myapp:v1 --log-analytics-workspace <workspace-id> --log-analytics-workspace-key <workspace-key>
        ```
        **Step 4: Query Logs in Log Analytics (Kusto)**
        ```kusto
        ContainerInstanceLog_CL
        | where ContainerGroup_s == "mycontainer"
        | project TimeGenerated, Message
        | order by TimeGenerated desc
        ```
        **References:**
        - [Monitor ACI](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-log-analytics)

4. How do you scale containers in AKS?
    - **Answer:**
        Use Cluster Autoscaler for node scaling and Horizontal Pod Autoscaler (HPA) for pod scaling based on metrics.
    - **Implementation:**
        **Step 1: Enable Cluster Autoscaler**
        ```sh
        az aks update --resource-group myrg --name myaks --enable-cluster-autoscaler --min-count 1 --max-count 10
        ```
        **Step 2: Deploy HPA for Pods**
        ```yaml
        apiVersion: autoscaling/v2
        kind: HorizontalPodAutoscaler
        metadata:
          name: myapp-hpa
        spec:
          scaleTargetRef:
            apiVersion: apps/v1
            kind: Deployment
            name: myapp
          minReplicas: 2
          maxReplicas: 10
          metrics:
          - type: Resource
            resource:
              name: cpu
              target:
                type: Utilization
                averageUtilization: 70
        ```
        **Step 3: Apply HPA**
        ```sh
        kubectl apply -f hpa.yaml
        kubectl get hpa
        ```
        **References:**
        - [AKS Autoscaling](https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler)

5. How do you manage secrets in AKS?
    - **Answer:**
        Use Kubernetes secrets or integrate with Azure Key Vault using the CSI driver for secure secret management.
    - **Implementation:**
        **Step 1: Create Kubernetes Secret**
        ```sh
        kubectl create secret generic mydbsecret --from-literal=username=admin --from-literal=password=secret123
        ```
        **Step 2: Use Secret in Pod**
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: myapp
        spec:
          containers:
          - name: myapp
            image: myapp:v1
            env:
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: mydbsecret
                  key: username
        ```
        **Step 3: Enable Key Vault CSI Driver**
        ```sh
        az aks enable-addons --resource-group myrg --name myaks --addons azure-keyvault-secrets-provider
        ```
        **Step 4: Mount Key Vault Secrets**
        ```yaml
        apiVersion: secrets-store.csi.x-k8s.io/v1
        kind: SecretProviderClass
        metadata:
          name: azure-kvname
        spec:
          provider: azure
          parameters:
            keyvaultName: "myvault"
            objects: |
              array:
                - |
                  objectName: MySecret
                  objectType: secret
            tenantId: "<tenant-id>"
        ```
        **References:**
        - [Key Vault CSI Driver](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)

6. How do you implement rolling updates in AKS?
    - **Answer:**
        Use Kubernetes deployment strategies with rolling updates, configure maxSurge and maxUnavailable for controlled rollouts.
    - **Implementation:**
        **Step 1: Configure Rolling Update Strategy**
        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: myapp
        spec:
          replicas: 4
          strategy:
            type: RollingUpdate
            rollingUpdate:
              maxSurge: 1
              maxUnavailable: 1
          selector:
            matchLabels:
              app: myapp
          template:
            metadata:
              labels:
                app: myapp
            spec:
              containers:
              - name: myapp
                image: myapp:v2
                readinessProbe:
                  httpGet:
                    path: /health
                    port: 80
                  initialDelaySeconds: 5
                  periodSeconds: 5
        ```
        **Step 2: Apply and Monitor Rollout**
        ```sh
        kubectl apply -f deployment.yaml
        kubectl rollout status deployment/myapp
        ```
        **Step 3: Rollback if Needed**
        ```sh
        kubectl rollout undo deployment/myapp
        kubectl rollout history deployment/myapp
        ```
        **References:**
        - [Kubernetes Rolling Updates](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-app-update)

7. How do you secure AKS API server?
    - **Answer:**
        Use private clusters, restrict API server authorized IP ranges, enable RBAC, and integrate with Azure AD.
    - **Implementation:**
        **Step 1: Create Private AKS Cluster**
        ```sh
        az aks create --resource-group myrg --name myaks --enable-private-cluster --node-count 3
        ```
        **Step 2: Restrict API Server Access by IP**
        ```sh
        az aks update --resource-group myrg --name myaks --api-server-authorized-ip-ranges 203.0.113.0/24
        ```
        **Step 3: Enable Azure AD Integration**
        ```sh
        az aks update --resource-group myrg --name myaks --enable-aad --aad-admin-group-object-ids <group-object-id>
        ```
        **Step 4: Create RBAC Role Binding**
        ```yaml
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: admin-binding
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: cluster-admin
        subjects:
        - kind: Group
          name: "<azure-ad-group-object-id>"
          apiGroup: rbac.authorization.k8s.io
        ```
        **References:**
        - [Secure AKS](https://learn.microsoft.com/en-us/azure/aks/private-clusters)

8. How do you automate AKS deployments?
    - **Answer:**
        Use Helm charts for package management, GitOps with Flux/Argo CD, or CI/CD pipelines with Azure DevOps/GitHub Actions.
    - **Implementation:**
        **Step 1: Deploy with Helm**
        ```sh
        helm repo add bitnami https://charts.bitnami.com/bitnami
        helm install myrelease bitnami/nginx --namespace mynamespace
        ```
        **Step 2: GitHub Actions for AKS Deployment**
        ```yaml
        name: Deploy to AKS
        on: [push]
        jobs:
          deploy:
            runs-on: ubuntu-latest
            steps:
            - uses: actions/checkout@v3
            - uses: azure/login@v1
              with:
                creds: ${{ secrets.AZURE_CREDENTIALS }}
            - uses: azure/aks-set-context@v3
              with:
                resource-group: myrg
                cluster-name: myaks
            - run: kubectl apply -f k8s/deployment.yaml
        ```
        **Step 3: Enable GitOps with Flux**
        ```sh
        az k8s-configuration flux create --resource-group myrg --cluster-name myaks --cluster-type managedClusters --name myconfig --namespace flux-system --scope cluster --url https://github.com/myorg/myrepo --branch main --kustomization name=app path=./manifests
        ```
        **References:**
        - [GitOps with Flux](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2)

9. How do you monitor AKS health?
    - **Answer:**
        Use Azure Monitor for containers, Container Insights, Prometheus, and Grafana for comprehensive monitoring.
    - **Implementation:**
        **Step 1: Enable Container Insights**
        ```sh
        az aks enable-addons --resource-group myrg --name myaks --addons monitoring --workspace-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.OperationalInsights/workspaces/myworkspace
        ```
        **Step 2: Query Container Metrics (Kusto)**
        ```kusto
        KubePodInventory
        | where ClusterName == "myaks"
        | summarize count() by PodStatus
        ```
        **Step 3: Deploy Prometheus and Grafana**
        ```sh
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
        ```
        **Step 4: Access Grafana Dashboard**
        ```sh
        kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
        ```
        **References:**
        - [Monitor AKS](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview)

10. How do you handle persistent storage?
    - **Answer:**
        Use Azure Disks for block storage, Azure Files for shared storage, or Blob CSI driver for object storage.
    - **Implementation:**
        **Step 1: Create PersistentVolumeClaim with Azure Disk**
        ```yaml
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: azure-disk-pvc
        spec:
          accessModes:
          - ReadWriteOnce
          storageClassName: managed-premium
          resources:
            requests:
              storage: 10Gi
        ```
        **Step 2: Use Azure Files for Shared Storage**
        ```yaml
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: azure-file-pvc
        spec:
          accessModes:
          - ReadWriteMany
          storageClassName: azurefile
          resources:
            requests:
              storage: 5Gi
        ```
        **Step 3: Mount PVC in Pod**
        ```yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: myapp
        spec:
          containers:
          - name: myapp
            image: myapp:v1
            volumeMounts:
            - name: data
              mountPath: /data
          volumes:
          - name: data
            persistentVolumeClaim:
              claimName: azure-disk-pvc
        ```
        **References:**
        - [AKS Storage](https://learn.microsoft.com/en-us/azure/aks/concepts-storage)

11. How do you implement network policies?
    - **Answer:**
        Use Azure CNI with Calico or Azure Network Policy, define Kubernetes NetworkPolicy resources to control traffic.
    - **Implementation:**
        **Step 1: Create AKS with Network Policy**
        ```sh
        az aks create --resource-group myrg --name myaks --network-plugin azure --network-policy calico
        ```
        **Step 2: Define Network Policy**
        ```yaml
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: deny-all-ingress
          namespace: production
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
        ```
        **Step 3: Allow Traffic from Specific Pods**
        ```yaml
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: allow-frontend
          namespace: production
        spec:
          podSelector:
            matchLabels:
              app: backend
          ingress:
          - from:
            - podSelector:
                matchLabels:
                  app: frontend
            ports:
            - protocol: TCP
              port: 8080
        ```
        **References:**
        - [AKS Network Policies](https://learn.microsoft.com/en-us/azure/aks/use-network-policies)

12. How do you upgrade AKS clusters?
    - **Answer:**
        Use Azure CLI or portal to upgrade control plane and node pools, test in staging first, use surge upgrades for minimal downtime.
    - **Implementation:**
        **Step 1: Check Available Versions**
        ```sh
        az aks get-upgrades --resource-group myrg --name myaks --output table
        ```
        **Step 2: Upgrade Cluster**
        ```sh
        az aks upgrade --resource-group myrg --name myaks --kubernetes-version 1.28.0
        ```
        **Step 3: Upgrade Specific Node Pool**
        ```sh
        az aks nodepool upgrade --resource-group myrg --cluster-name myaks --name mynodepool --kubernetes-version 1.28.0
        ```
        **Step 4: Configure Surge Upgrade**
        ```sh
        az aks nodepool update --resource-group myrg --cluster-name myaks --name mynodepool --max-surge 33%
        ```
        **References:**
        - [Upgrade AKS](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster)

13. How do you troubleshoot pod failures?
    - **Answer:**
        Use kubectl logs, describe, events, exec into pods, and Azure Monitor for comprehensive troubleshooting.
    - **Implementation:**
        **Step 1: Check Pod Status**
        ```sh
        kubectl get pods -n mynamespace
        kubectl describe pod mypod -n mynamespace
        ```
        **Step 2: View Pod Logs**
        ```sh
        kubectl logs mypod -n mynamespace
        kubectl logs mypod -n mynamespace --previous  # For crashed containers
        ```
        **Step 3: Check Events**
        ```sh
        kubectl get events -n mynamespace --sort-by='.lastTimestamp'
        ```
        **Step 4: Exec into Pod for Debugging**
        ```sh
        kubectl exec -it mypod -n mynamespace -- /bin/sh
        ```
        **Step 5: Query Container Insights (Kusto)**
        ```kusto
        ContainerLog
        | where PodName == "mypod"
        | project TimeGenerated, LogEntry
        | order by TimeGenerated desc
        ```
        **References:**
        - [Troubleshoot AKS](https://learn.microsoft.com/en-us/azure/aks/troubleshooting)

14. How do you restrict egress traffic?
    - **Answer:**
        Use NSGs, Azure Firewall, and Kubernetes network policies to control and restrict outbound traffic from AKS.
    - **Implementation:**
        **Step 1: Create AKS with Outbound Type**
        ```sh
        az aks create --resource-group myrg --name myaks --outbound-type userDefinedRouting --vnet-subnet-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/mysubnet
        ```
        **Step 2: Configure Azure Firewall Rules**
        ```sh
        az network firewall application-rule create --firewall-name myfw --resource-group myrg --collection-name AKS-FQDN --name AllowAKS --protocols https=443 --source-addresses 10.0.0.0/8 --target-fqdns *.hcp.eastus.azmk8s.io *.tun.eastus.azmk8s.io --action Allow --priority 100
        ```
        **Step 3: Create Egress Network Policy**
        ```yaml
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: deny-external-egress
          namespace: production
        spec:
          podSelector: {}
          policyTypes:
          - Egress
          egress:
          - to:
            - namespaceSelector: {}
        ```
        **References:**
        - [AKS Egress](https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic)

15. How do you integrate AKS with Azure AD?
    - **Answer:**
        Enable Azure AD integration for RBAC, use managed identities for pods with Azure AD Workload Identity.
    - **Implementation:**
        **Step 1: Enable Azure AD Integration**
        ```sh
        az aks update --resource-group myrg --name myaks --enable-aad --aad-admin-group-object-ids <admin-group-id>
        ```
        **Step 2: Create Azure AD RBAC Binding**
        ```yaml
        apiVersion: rbac.authorization.k8s.io/v1
        kind: RoleBinding
        metadata:
          name: dev-team-binding
          namespace: development
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: Role
          name: developer
        subjects:
        - kind: Group
          name: "<azure-ad-group-object-id>"
          apiGroup: rbac.authorization.k8s.io
        ```
        **Step 3: Enable Workload Identity**
        ```sh
        az aks update --resource-group myrg --name myaks --enable-oidc-issuer --enable-workload-identity
        ```
        **Step 4: Configure Pod with Workload Identity**
        ```yaml
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: myapp-sa
          annotations:
            azure.workload.identity/client-id: "<managed-identity-client-id>"
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: myapp
          labels:
            azure.workload.identity/use: "true"
        spec:
          serviceAccountName: myapp-sa
          containers:
          - name: myapp
            image: myapp:v1
        ```
        **References:**
        - [AKS Azure AD Integration](https://learn.microsoft.com/en-us/azure/aks/azure-ad-integration-cli)

16. How do you implement container groups with multiple containers in ACI?
    - **Answer:**
        Container groups allow multiple containers to share lifecycle, local network, and storage volumes. Use YAML or ARM templates to define multi-container deployments with sidecar patterns.
    - **Implementation:**
        **Step 1: Create Container Group YAML**
        ```yaml
        # container-group.yaml
        apiVersion: '2021-09-01'
        location: eastus
        name: mycontainergroup
        properties:
            containers:
                - name: webapp
                  properties:
                      image: myregistry.azurecr.io/webapp:v1
                      ports:
                          - port: 80
                            protocol: TCP
                      resources:
                          requests:
                              cpu: 1.0
                              memoryInGb: 1.5
                      environmentVariables:
                          - name: ASPNETCORE_URLS
                            value: http://+:80
                - name: sidecar-logging
                  properties:
                      image: fluent/fluent-bit:latest
                      resources:
                          requests:
                              cpu: 0.5
                              memoryInGb: 0.5
                      volumeMounts:
                          - name: logs
                            mountPath: /var/log/app
                - name: sidecar-proxy
                  properties:
                      image: nginx:alpine
                      ports:
                          - port: 443
                            protocol: TCP
                      resources:
                          requests:
                              cpu: 0.5
                              memoryInGb: 0.5
            osType: Linux
            ipAddress:
                type: Public
                ports:
                    - port: 80
                      protocol: TCP
                    - port: 443
                      protocol: TCP
            volumes:
                - name: logs
                  emptyDir: {}
            imageRegistryCredentials:
                - server: myregistry.azurecr.io
                  username: myregistry
                  password: <acr-password>
        type: Microsoft.ContainerInstance/containerGroups
        ```
        **Step 2: Deploy Container Group**
        ```sh
        az container create --resource-group myrg --file container-group.yaml
        ```
        **Step 3: Container Group with Azure File Share Volume**
        ```sh
        az container create \
            --resource-group myrg \
            --name mycontainergroup \
            --image myregistry.azurecr.io/webapp:v1 \
            --cpu 1 \
            --memory 1.5 \
            --azure-file-volume-account-name mystorageaccount \
            --azure-file-volume-account-key <storage-key> \
            --azure-file-volume-share-name myshare \
            --azure-file-volume-mount-path /mnt/data
        ```
        **Step 4: Bicep Template for Container Group**
        ```bicep
        resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
            name: 'mycontainergroup'
            location: resourceGroup().location
            properties: {
                containers: [
                    {
                        name: 'webapp'
                        properties: {
                            image: 'myregistry.azurecr.io/webapp:v1'
                            ports: [{ port: 80, protocol: 'TCP' }]
                            resources: { requests: { cpu: 1, memoryInGB: 2 } }
                        }
                    }
                    {
                        name: 'redis-cache'
                        properties: {
                            image: 'redis:alpine'
                            ports: [{ port: 6379, protocol: 'TCP' }]
                            resources: { requests: { cpu: json('0.5'), memoryInGB: 1 } }
                        }
                    }
                ]
                osType: 'Linux'
                ipAddress: { type: 'Public', ports: [{ port: 80, protocol: 'TCP' }] }
                imageRegistryCredentials: [
                    {
                        server: 'myregistry.azurecr.io'
                        username: acr.listCredentials().username
                        password: acr.listCredentials().passwords[0].value
                    }
                ]
            }
        }
        ```
        **References:**
        - [Container Groups in ACI](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-container-groups)
        - [Deploy Multi-Container Group](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-multi-container-yaml)

17. How do you implement AKS cluster autoscaling?
    - **Answer:**
        AKS supports cluster autoscaler (node-level) and Horizontal Pod Autoscaler (pod-level). Combine both for comprehensive autoscaling based on resource utilization.
    - **Implementation:**
        **Step 1: Enable Cluster Autoscaler**
        ```sh
        # Create AKS with autoscaler enabled
        az aks create \
            --resource-group myrg \
            --name myakscluster \
            --node-count 3 \
            --enable-cluster-autoscaler \
            --min-count 1 \
            --max-count 10 \
            --node-vm-size Standard_DS2_v2

        # Enable autoscaler on existing cluster
        az aks update \
            --resource-group myrg \
            --name myakscluster \
            --enable-cluster-autoscaler \
            --min-count 1 \
            --max-count 10
        ```
        **Step 2: Configure Horizontal Pod Autoscaler**
        ```yaml
        # hpa.yaml
        apiVersion: autoscaling/v2
        kind: HorizontalPodAutoscaler
        metadata:
            name: webapp-hpa
            namespace: default
        spec:
            scaleTargetRef:
                apiVersion: apps/v1
                kind: Deployment
                name: webapp
            minReplicas: 2
            maxReplicas: 20
            metrics:
                - type: Resource
                  resource:
                      name: cpu
                      target:
                          type: Utilization
                          averageUtilization: 70
                - type: Resource
                  resource:
                      name: memory
                      target:
                          type: Utilization
                          averageUtilization: 80
            behavior:
                scaleDown:
                    stabilizationWindowSeconds: 300
                    policies:
                        - type: Percent
                          value: 10
                          periodSeconds: 60
                scaleUp:
                    stabilizationWindowSeconds: 0
                    policies:
                        - type: Percent
                          value: 100
                          periodSeconds: 15
                        - type: Pods
                          value: 4
                          periodSeconds: 15
                    selectPolicy: Max
        ```
        **Step 3: Deploy with Resource Requests**
        ```yaml
        # deployment.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
            name: webapp
        spec:
            replicas: 3
            selector:
                matchLabels:
                    app: webapp
            template:
                metadata:
                    labels:
                        app: webapp
                spec:
                    containers:
                        - name: webapp
                          image: myregistry.azurecr.io/webapp:v1
                          resources:
                              requests:
                                  cpu: 250m
                                  memory: 256Mi
                              limits:
                                  cpu: 500m
                                  memory: 512Mi
                          ports:
                              - containerPort: 80
        ```
        **Step 4: Configure KEDA for Event-Driven Autoscaling**
        ```sh
        # Install KEDA
        az aks update --resource-group myrg --name myakscluster --enable-keda
        ```
        ```yaml
        # keda-scaledobject.yaml
        apiVersion: keda.sh/v1alpha1
        kind: ScaledObject
        metadata:
            name: azure-queue-scaler
        spec:
            scaleTargetRef:
                name: queue-processor
            minReplicaCount: 0
            maxReplicaCount: 30
            triggers:
                - type: azure-queue
                  metadata:
                      queueName: orders
                      queueLength: '5'
                      connectionFromEnv: AZURE_STORAGE_CONNECTION_STRING
        ```
        **References:**
        - [AKS Cluster Autoscaler](https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler)
        - [Horizontal Pod Autoscaler](https://learn.microsoft.com/en-us/azure/aks/concepts-scale#horizontal-pod-autoscaler)

18. How do you implement persistent storage in AKS?
    - **Answer:**
        AKS supports Azure Disks (block storage) and Azure Files (shared storage) through storage classes and persistent volume claims. Choose based on access mode requirements.
    - **Implementation:**
        **Step 1: Create Storage Class for Azure Disk**
        ```yaml
        # storageclass-disk.yaml
        apiVersion: storage.k8s.io/v1
        kind: StorageClass
        metadata:
            name: managed-premium
        provisioner: disk.csi.azure.com
        parameters:
            skuName: Premium_LRS
            cachingMode: ReadOnly
        reclaimPolicy: Delete
        volumeBindingMode: WaitForFirstConsumer
        allowVolumeExpansion: true
        ```
        **Step 2: Create Persistent Volume Claim**
        ```yaml
        # pvc-disk.yaml
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
            name: database-pvc
        spec:
            accessModes:
                - ReadWriteOnce
            storageClassName: managed-premium
            resources:
                requests:
                    storage: 100Gi
        ```
        **Step 3: Use PVC in Deployment**
        ```yaml
        # deployment-with-storage.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
            name: postgres
        spec:
            replicas: 1
            selector:
                matchLabels:
                    app: postgres
            template:
                metadata:
                    labels:
                        app: postgres
                spec:
                    containers:
                        - name: postgres
                          image: postgres:15
                          env:
                              - name: POSTGRES_PASSWORD
                                valueFrom:
                                    secretKeyRef:
                                        name: postgres-secret
                                        key: password
                          volumeMounts:
                              - name: data
                                mountPath: /var/lib/postgresql/data
                    volumes:
                        - name: data
                          persistentVolumeClaim:
                              claimName: database-pvc
        ```
        **Step 4: Azure Files for Shared Storage (ReadWriteMany)**
        ```yaml
        # storageclass-azurefile.yaml
        apiVersion: storage.k8s.io/v1
        kind: StorageClass
        metadata:
            name: azurefile-premium
        provisioner: file.csi.azure.com
        parameters:
            skuName: Premium_LRS
        reclaimPolicy: Delete
        volumeBindingMode: Immediate
        allowVolumeExpansion: true
        mountOptions:
            - dir_mode=0777
            - file_mode=0777
            - uid=0
            - gid=0
            - mfsymlinks
            - cache=strict
        ```
        **Step 5: StatefulSet with Volume Claim Templates**
        ```yaml
        # statefulset.yaml
        apiVersion: apps/v1
        kind: StatefulSet
        metadata:
            name: redis
        spec:
            serviceName: redis
            replicas: 3
            selector:
                matchLabels:
                    app: redis
            template:
                metadata:
                    labels:
                        app: redis
                spec:
                    containers:
                        - name: redis
                          image: redis:7
                          ports:
                              - containerPort: 6379
                          volumeMounts:
                              - name: data
                                mountPath: /data
            volumeClaimTemplates:
                - metadata:
                      name: data
                  spec:
                      accessModes: ['ReadWriteOnce']
                      storageClassName: managed-premium
                      resources:
                          requests:
                              storage: 10Gi
        ```
        **References:**
        - [AKS Storage Options](https://learn.microsoft.com/en-us/azure/aks/concepts-storage)
        - [Azure Disk CSI Driver](https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi)

19. How do you implement service mesh with AKS?
    - **Answer:**
        Service mesh provides traffic management, security (mTLS), and observability for microservices. AKS supports Istio, Linkerd, and Open Service Mesh as add-ons.
    - **Implementation:**
        **Step 1: Enable Istio Add-on**
        ```sh
        # Enable Istio service mesh
        az aks mesh enable --resource-group myrg --name myakscluster

        # Enable sidecar injection for namespace
        kubectl label namespace default istio.io/rev=asm-1-17
        ```
        **Step 2: Configure Traffic Management**
        ```yaml
        # virtualservice.yaml
        apiVersion: networking.istio.io/v1beta1
        kind: VirtualService
        metadata:
            name: webapp-routing
        spec:
            hosts:
                - webapp
            http:
                - match:
                      - headers:
                            x-version:
                                exact: 'v2'
                  route:
                      - destination:
                            host: webapp
                            subset: v2
                - route:
                      - destination:
                            host: webapp
                            subset: v1
                        weight: 90
                      - destination:
                            host: webapp
                            subset: v2
                        weight: 10
        ---
        apiVersion: networking.istio.io/v1beta1
        kind: DestinationRule
        metadata:
            name: webapp-destination
        spec:
            host: webapp
            trafficPolicy:
                connectionPool:
                    tcp:
                        maxConnections: 100
                    http:
                        h2UpgradePolicy: UPGRADE
                        http1MaxPendingRequests: 100
                        http2MaxRequests: 1000
                loadBalancer:
                    simple: ROUND_ROBIN
            subsets:
                - name: v1
                  labels:
                      version: v1
                - name: v2
                  labels:
                      version: v2
        ```
        **Step 3: Configure Circuit Breaker**
        ```yaml
        # circuit-breaker.yaml
        apiVersion: networking.istio.io/v1beta1
        kind: DestinationRule
        metadata:
            name: payment-service-cb
        spec:
            host: payment-service
            trafficPolicy:
                outlierDetection:
                    consecutive5xxErrors: 5
                    interval: 30s
                    baseEjectionTime: 60s
                    maxEjectionPercent: 50
                connectionPool:
                    tcp:
                        maxConnections: 50
                    http:
                        http1MaxPendingRequests: 50
                        http2MaxRequests: 100
                        maxRetries: 3
        ```
        **Step 4: Enable mTLS**
        ```yaml
        # peer-authentication.yaml
        apiVersion: security.istio.io/v1beta1
        kind: PeerAuthentication
        metadata:
            name: default
            namespace: default
        spec:
            mtls:
                mode: STRICT
        ---
        apiVersion: security.istio.io/v1beta1
        kind: AuthorizationPolicy
        metadata:
            name: webapp-auth
            namespace: default
        spec:
            selector:
                matchLabels:
                    app: webapp
            action: ALLOW
            rules:
                - from:
                      - source:
                            principals:
                                - cluster.local/ns/default/sa/frontend
                  to:
                      - operation:
                            methods: ['GET', 'POST']
                            paths: ['/api/*']
        ```
        **Step 5: Configure Observability**
        ```sh
        # Install Kiali dashboard
        kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/kiali.yaml

        # Access Kiali dashboard
        kubectl port-forward svc/kiali -n istio-system 20001:20001
        ```
        **References:**
        - [AKS Istio Add-on](https://learn.microsoft.com/en-us/azure/aks/istio-about)
        - [Istio Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)

20. How do you implement GitOps deployment with AKS?
    - **Answer:**
        GitOps uses Git as the single source of truth for infrastructure and application deployments. AKS supports Flux v2 for automated synchronization between Git repositories and clusters.
    - **Implementation:**
        **Step 1: Enable GitOps Extension**
        ```sh
        # Enable GitOps extension
        az k8s-extension create \
            --resource-group myrg \
            --cluster-name myakscluster \
            --cluster-type managedClusters \
            --name flux \
            --extension-type microsoft.flux
        ```
        **Step 2: Create Flux Configuration**
        ```sh
        az k8s-configuration flux create \
            --resource-group myrg \
            --cluster-name myakscluster \
            --cluster-type managedClusters \
            --name cluster-config \
            --namespace flux-system \
            --scope cluster \
            --url https://github.com/myorg/k8s-config \
            --branch main \
            --kustomization name=infra path=./infrastructure prune=true \
            --kustomization name=apps path=./apps prune=true dependsOn=["infra"]
        ```
        **Step 3: Repository Structure**
        ```
        k8s-config/
        ├── infrastructure/
        │   ├── namespaces.yaml
        │   ├── rbac.yaml
        │   └── kustomization.yaml
        ├── apps/
        │   ├── webapp/
        │   │   ├── deployment.yaml
        │   │   ├── service.yaml
        │   │   └── kustomization.yaml
        │   └── kustomization.yaml
        └── clusters/
            └── production/
                └── kustomization.yaml
        ```
        **Step 4: Kustomization Configuration**
        ```yaml
        # apps/webapp/kustomization.yaml
        apiVersion: kustomize.config.k8s.io/v1beta1
        kind: Kustomization
        namespace: production
        resources:
            - deployment.yaml
            - service.yaml
        images:
            - name: webapp
              newName: myregistry.azurecr.io/webapp
              newTag: v1.2.3
        ```
        **Step 5: Image Automation with Flux**
        ```yaml
        # image-repository.yaml
        apiVersion: image.toolkit.fluxcd.io/v1beta2
        kind: ImageRepository
        metadata:
            name: webapp
            namespace: flux-system
        spec:
            image: myregistry.azurecr.io/webapp
            interval: 1m
            secretRef:
                name: acr-credentials
        ---
        # image-policy.yaml
        apiVersion: image.toolkit.fluxcd.io/v1beta2
        kind: ImagePolicy
        metadata:
            name: webapp
            namespace: flux-system
        spec:
            imageRepositoryRef:
                name: webapp
            policy:
                semver:
                    range: '>=1.0.0'
        ---
        # image-update-automation.yaml
        apiVersion: image.toolkit.fluxcd.io/v1beta1
        kind: ImageUpdateAutomation
        metadata:
            name: webapp-automation
            namespace: flux-system
        spec:
            interval: 1m
            sourceRef:
                kind: GitRepository
                name: k8s-config
            git:
                checkout:
                    ref:
                        branch: main
                commit:
                    author:
                        email: flux@myorg.com
                        name: Flux
                    messageTemplate: 'Update image to {{.NewTag}}'
                push:
                    branch: main
            update:
                path: ./apps
                strategy: Setters
        ```
        **Step 6: Monitor GitOps Sync Status**
        ```sh
        # Check Flux status
        flux get all

        # Check kustomization reconciliation
        kubectl get kustomizations -n flux-system

        # View sync events
        kubectl describe kustomization cluster-config -n flux-system
        ```
        **References:**
        - [GitOps with Flux on AKS](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2)
        - [Flux Image Automation](https://fluxcd.io/flux/guides/image-update/)


## 2. Azure Storage Services (Blob, Table, Queue, File)


### 2.1 Azure Blob Storage
1. How do you implement secure file uploads from a web app?
     - **Answer:**
         Use SAS tokens with limited permissions and expiry, validate file type/size, use HTTPS, and store secrets in Key Vault.
     - **Implementation:**
         **Step 1: Generate SAS Token in Backend (C#)**
         ```csharp
         using Azure.Storage.Blobs;
         using Azure.Storage.Sas;
     
         var blobServiceClient = new BlobServiceClient(connectionString);
         var containerClient = blobServiceClient.GetBlobContainerClient("mycontainer");
         var blobClient = containerClient.GetBlobClient("myfile.txt");
         var sasBuilder = new BlobSasBuilder
         {
                 BlobContainerName = "mycontainer",
                 BlobName = "myfile.txt",
                 Resource = "b",
                 ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(10)
         };
         sasBuilder.SetPermissions(BlobSasPermissions.Write);
         var sasUri = blobClient.GenerateSasUri(sasBuilder);
         ```
         **Step 2: Upload File from Frontend (JavaScript)**
         ```js
         fetch(sasUri, {
             method: 'PUT',
             body: file,
             headers: { 'x-ms-blob-type': 'BlockBlob' }
         });
         ```
         **Step 3: Validate File Type/Size in Backend**
         - Check Content-Type and file size before generating SAS.
         **Packages:** Azure.Storage.Blobs
         **References:**
         - [Upload files securely to Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-upload-javascript)

2. How do you enable versioning for blobs?
     - **Answer:**
         Enable blob versioning in storage account settings, access previous versions via API.
     - **Implementation:**
         **Step 1: Enable Versioning in Portal**
         - Storage Account > Data Protection > Enable versioning
         **Step 2: Access Previous Versions (C#)**
         ```csharp
         await foreach (BlobItem blobItem in containerClient.GetBlobsAsync(BlobTraits.Version, BlobStates.Version))
         {
                 Console.WriteLine($"Blob: {blobItem.Name}, Version: {blobItem.VersionId}");
         }
         ```
         **References:**
         - [Blob versioning](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)

3. How do you implement soft delete for blobs?
     - **Answer:**
         Enable soft delete, configure retention period, restore deleted blobs via portal or API.
     - **Implementation:**
         **Step 1: Enable Soft Delete in Portal**
         - Storage Account > Data Protection > Enable soft delete
         **Step 2: Restore Deleted Blob (C#)**
         ```csharp
         var blobClient = containerClient.GetBlobClient("myfile.txt");
         await blobClient.UndeleteAsync();
         ```
         **References:**
         - [Soft delete for blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-overview)

4. How do you restrict public access?
     - **Answer:**
         Set public access level to private, use Azure AD or SAS for access.
     - **Implementation:**
         **Step 1: Set Public Access Level to Private**
         - Azure Portal: Containers > Access level > Private (no anonymous access)
         **Step 2: Use Azure AD or SAS for Access**
         - Use DefaultAzureCredential in code for Azure AD
         ```csharp
         var client = new BlobServiceClient(new Uri(blobUri), new DefaultAzureCredential());
         ```
         **References:**
         - [Secure access to blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-prevent)

5. How do you automate blob lifecycle management?
     - **Answer:**
         Use lifecycle management policies to move or delete blobs based on rules.
     - **Implementation:**
         **Step 1: Add Lifecycle Policy in Portal**
         - Storage Account > Data Management > Lifecycle Management > Add rule
         **Step 2: Example Policy (JSON)**
         ```json
         {
             "rules": [
                 {
                     "enabled": true,
                     "name": "move-to-cool",
                     "type": "Lifecycle",
                     "definition": {
                         "actions": {
                             "baseBlob": {
                                 "tierToCool": { "daysAfterModificationGreaterThan": 30 }
                             }
                         },
                         "filters": { "blobTypes": ["blockBlob"] }
                     }
                 }
             ]
         }
         ```
         **References:**
         - [Blob lifecycle management](https://learn.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-policy-configure)

6. How do you monitor blob access?
     - **Answer:**
         Enable storage analytics logging, use Azure Monitor and diagnostic settings.
     - **Implementation:**
         **Step 1: Enable Diagnostics in Portal**
         - Storage Account > Monitoring > Diagnostic settings > Add diagnostic setting
         - Select Blob, read, write, delete operations
         **Step 2: Query Logs in Log Analytics**
         ```kusto
         AzureDiagnostics
         | where ResourceType == "MICROSOFT.STORAGE/STORAGEACCOUNTS" and OperationName_s == "GetBlob"
         ```
         **References:**
         - [Monitor Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-monitoring-diagnosing-troubleshooting)

7. How do you handle large file uploads?
     - **Answer:**
         Use block blobs and upload in chunks (Put Block/Put Block List API).
     - **Implementation:**
         **Step 1: Upload in Chunks (C#)**
         ```csharp
         var blobClient = containerClient.GetBlobClient("largefile.bin");
         using FileStream fs = File.OpenRead("largefile.bin");
         await blobClient.UploadAsync(fs, new BlobUploadOptions { TransferOptions = new StorageTransferOptions { MaximumTransferSize = 4 * 1024 * 1024 } });
         ```
         **References:**
         - [Upload large blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-upload)

8. How do you implement geo-redundancy?
     - **Answer:**
         Use GRS, RA-GRS, or GZRS for replication across regions.
     - **Implementation:**
         **Step 1: Set Replication in Portal**
         - Storage Account > Configuration > Replication > Select GRS/RA-GRS/GZRS
         **Step 2: Test Failover**
         - Storage Account > Geo-replication > Initiate account failover
         **References:**
         - [Geo-redundant storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)

9. How do you secure access from VMs or Functions?
     - **Answer:**
         Use Managed Identity and RBAC for storage access.
     - **Implementation:**
         **Step 1: Assign Role to Managed Identity**
         - Azure Portal: Storage Account > Access Control (IAM) > Add role assignment > Storage Blob Data Contributor > Select your VM or Function
         **Step 2: Access Blob in Code (C#)**
         ```csharp
         var client = new BlobServiceClient(new Uri(blobUri), new DefaultAzureCredential());
         ```
         **References:**
         - [Access Azure Storage with Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-windows-vm-access-storage)

10. How do you serve static websites?
     - **Answer:**
         Enable static website hosting, upload files to $web container, configure index and error docs.
     - **Implementation:**
         **Step 1: Enable Static Website in Portal**
         - Storage Account > Static website > Enable
         - Set index.html and error.html
         **Step 2: Upload Files to $web Container**
         - Use Azure Portal, AzCopy, or Azure CLI
         ```sh
         az storage blob upload-batch -d '$web' -s ./site --account-name mystorage
         ```
         **References:**
         - [Static website hosting](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website)

11. How do you handle CORS for blobs?
     - **Answer:**
         Configure CORS rules in storage account settings.
     - **Implementation:**
         **Step 1: Set CORS in Portal**
         - Storage Account > Resource sharing (CORS) > Add rule
         **Step 2: Set CORS via CLI**
         ```sh
         az storage cors add --services b --origins https://myapp.com --methods GET PUT --allowed-headers * --exposed-headers * --max-age 200
         ```
         **References:**
         - [CORS for Azure Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-cors)

12. How do you audit access?
     - **Answer:**
         Use Azure Activity Log and storage analytics.
     - **Implementation:**
         **Step 1: Enable Diagnostics (see question 6)**
         **Step 2: Query Activity Log**
         - Azure Portal: Monitor > Activity Log > Filter by Storage Account
         **References:**
         - [Audit storage access](https://learn.microsoft.com/en-us/azure/storage/common/storage-monitoring-diagnosing-troubleshooting)

13. How do you optimize costs for infrequently accessed data?
     - **Answer:**
         Use cool/archive tiers and lifecycle policies.
     - **Implementation:**
         **Step 1: Set Access Tier in Portal**
         - Storage Account > Containers > Select blob > Change tier > Cool/Archive
         **Step 2: Use Lifecycle Policy (see question 5)**
         **References:**
         - [Blob storage tiers](https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview)

14. How do you recover from accidental deletion?
     - **Answer:**
         Use soft delete and versioning to restore blobs.
     - **Implementation:**
         **Step 1: Enable Soft Delete and Versioning (see questions 2 and 3)**
         **Step 2: Restore Blob (C#)**
         ```csharp
         var blobClient = containerClient.GetBlobClient("myfile.txt");
         await blobClient.UndeleteAsync();
         // Or restore previous version
         await blobClient.WithVersion("<versionId>").DownloadToAsync("restored.txt");
         ```
         **References:**
         - [Restore deleted blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-overview)

15. How do you automate uploads from CI/CD?
     - **Answer:**
         Use Azure CLI, AzCopy, or SDK in pipeline scripts.
     - **Implementation:**
         **Step 1: Use AzCopy in Pipeline**
         ```sh
         azcopy copy "./build/*" "https://<account>.blob.core.windows.net/<container>?<sas>" --recursive
         ```
         **Step 2: Use Azure CLI in Pipeline**
         ```sh
         az storage blob upload-batch -d mycontainer -s ./build --account-name mystorage
         ```
         **References:**
         - [AzCopy documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10)

16. How do you implement blob versioning and soft delete?
    - **Answer:**
        Blob versioning automatically maintains previous versions of blobs. Soft delete provides a retention period to recover deleted blobs. Both features protect against accidental deletion or overwrites.
    - **Implementation:**
        **Step 1: Enable Versioning and Soft Delete**
        ```sh
        # Enable blob versioning
        az storage account blob-service-properties update \
            --account-name mystorageaccount \
            --resource-group myrg \
            --enable-versioning true

        # Enable soft delete for blobs
        az storage blob service-properties delete-policy update \
            --account-name mystorageaccount \
            --enable true \
            --days-retained 30

        # Enable soft delete for containers
        az storage account blob-service-properties update \
            --account-name mystorageaccount \
            --resource-group myrg \
            --enable-container-delete-retention true \
            --container-delete-retention-days 30
        ```
        **Step 2: Work with Blob Versions in C#**
        ```csharp
        using Azure.Storage.Blobs;
        using Azure.Storage.Blobs.Models;
        using Azure.Storage.Blobs.Specialized;

        public class BlobVersioningService
        {
            private readonly BlobContainerClient _container;

            public BlobVersioningService(string connectionString, string containerName)
            {
                _container = new BlobContainerClient(connectionString, containerName);
            }

            // List all versions of a blob
            public async Task<List<BlobItem>> ListBlobVersionsAsync(string blobName)
            {
                var versions = new List<BlobItem>();
                await foreach (var blob in _container.GetBlobsAsync(
                    traits: BlobTraits.None,
                    states: BlobStates.Version,
                    prefix: blobName))
                {
                    versions.Add(blob);
                }
                return versions.OrderByDescending(v => v.VersionId).ToList();
            }

            // Restore specific version as current
            public async Task RestoreVersionAsync(string blobName, string versionId)
            {
                var sourceBlob = _container.GetBlobClient(blobName).WithVersion(versionId);
                var destBlob = _container.GetBlobClient(blobName);

                await destBlob.StartCopyFromUriAsync(sourceBlob.Uri);
            }

            // Delete specific version
            public async Task DeleteVersionAsync(string blobName, string versionId)
            {
                var versionedBlob = _container.GetBlobClient(blobName).WithVersion(versionId);
                await versionedBlob.DeleteAsync();
            }
        }
        ```
        **Step 3: Recover Soft-Deleted Blobs**
        ```csharp
        public async Task<List<BlobItem>> ListDeletedBlobsAsync()
        {
            var deletedBlobs = new List<BlobItem>();
            await foreach (var blob in _container.GetBlobsAsync(
                states: BlobStates.Deleted))
            {
                deletedBlobs.Add(blob);
            }
            return deletedBlobs;
        }

        public async Task UndeleteBlbAsync(string blobName)
        {
            var blobClient = _container.GetBlobClient(blobName);
            await blobClient.UndeleteAsync();
        }
        ```
        **Step 4: Bicep Template for Versioning Configuration**
        ```bicep
        resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
            name: 'mystorageaccount'
            location: resourceGroup().location
            sku: { name: 'Standard_LRS' }
            kind: 'StorageV2'
        }

        resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
            parent: storageAccount
            name: 'default'
            properties: {
                isVersioningEnabled: true
                deleteRetentionPolicy: {
                    enabled: true
                    days: 30
                }
                containerDeleteRetentionPolicy: {
                    enabled: true
                    days: 30
                }
                changeFeed: {
                    enabled: true
                    retentionInDays: 14
                }
            }
        }
        ```
        **References:**
        - [Blob Versioning](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)
        - [Soft Delete for Blobs](https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-overview)

17. How do you implement blob change feed for event processing?
    - **Answer:**
        Change feed provides an ordered, read-only log of all changes to blobs. It's useful for audit trails, data synchronization, and triggering downstream processing.
    - **Implementation:**
        **Step 1: Enable Change Feed**
        ```sh
        az storage account blob-service-properties update \
            --account-name mystorageaccount \
            --resource-group myrg \
            --enable-change-feed true \
            --change-feed-retention-days 30
        ```
        **Step 2: Process Change Feed with C#**
        ```csharp
        using Azure.Storage.Blobs;
        using Azure.Storage.Blobs.ChangeFeed;

        public class ChangeFeedProcessor
        {
            private readonly BlobServiceClient _blobServiceClient;
            private readonly string _checkpointPath;

            public ChangeFeedProcessor(string connectionString, string checkpointPath)
            {
                _blobServiceClient = new BlobServiceClient(connectionString);
                _checkpointPath = checkpointPath;
            }

            public async Task ProcessChangesAsync(CancellationToken cancellationToken)
            {
                var changeFeed = _blobServiceClient.GetChangeFeedClient();

                // Load checkpoint for resuming
                string continuationToken = await LoadCheckpointAsync();

                await foreach (var page in changeFeed.GetChangesAsync(
                    continuationToken: continuationToken).AsPages())
                {
                    foreach (var changeEvent in page.Values)
                    {
                        await ProcessEventAsync(changeEvent);
                    }

                    // Save checkpoint after each page
                    await SaveCheckpointAsync(page.ContinuationToken);
                }
            }

            private async Task ProcessEventAsync(BlobChangeFeedEvent changeEvent)
            {
                Console.WriteLine($"Event Type: {changeEvent.EventType}");
                Console.WriteLine($"Subject: {changeEvent.Subject}");
                Console.WriteLine($"Event Time: {changeEvent.EventTime}");
                Console.WriteLine($"Blob URL: {changeEvent.EventData.BlobUrl}");
                Console.WriteLine($"Operation: {changeEvent.EventData.BlobOperationName}");

                switch (changeEvent.EventType.ToString())
                {
                    case "BlobCreated":
                        await HandleBlobCreatedAsync(changeEvent);
                        break;
                    case "BlobDeleted":
                        await HandleBlobDeletedAsync(changeEvent);
                        break;
                    case "BlobTierChanged":
                        await HandleTierChangedAsync(changeEvent);
                        break;
                }
            }

            private async Task HandleBlobCreatedAsync(BlobChangeFeedEvent evt)
            {
                // Trigger downstream processing
                await _messageQueue.SendAsync(new BlobCreatedMessage
                {
                    BlobUrl = evt.EventData.BlobUrl,
                    ContentType = evt.EventData.ContentType,
                    ContentLength = evt.EventData.ContentLength
                });
            }
        }
        ```
        **Step 3: Query Change Feed for Time Range**
        ```csharp
        public async Task<List<BlobChangeFeedEvent>> GetChangesInRangeAsync(
            DateTimeOffset start, DateTimeOffset end)
        {
            var events = new List<BlobChangeFeedEvent>();
            var changeFeed = _blobServiceClient.GetChangeFeedClient();

            await foreach (var evt in changeFeed.GetChangesAsync(
                start: start, end: end))
            {
                events.Add(evt);
            }

            return events;
        }
        ```
        **References:**
        - [Blob Change Feed](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-change-feed)
        - [Process Change Feed](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-change-feed-how-to)

18. How do you implement blob immutability policies?
    - **Answer:**
        Immutability policies prevent blobs from being modified or deleted for a specified period. Supports time-based retention and legal holds for compliance requirements (WORM storage).
    - **Implementation:**
        **Step 1: Create Container with Immutability Policy**
        ```sh
        # Create container with immutable storage
        az storage container-rm create \
            --storage-account mystorageaccount \
            --resource-group myrg \
            --name compliance-data

        # Set time-based retention policy
        az storage container immutability-policy create \
            --account-name mystorageaccount \
            --container-name compliance-data \
            --period 365 \
            --allow-protected-append-writes true
        ```
        **Step 2: Lock Immutability Policy (Irreversible)**
        ```sh
        # Lock policy - cannot be decreased after locking
        az storage container immutability-policy lock \
            --account-name mystorageaccount \
            --container-name compliance-data \
            --if-match <etag>
        ```
        **Step 3: Implement Legal Hold**
        ```sh
        # Add legal hold
        az storage container legal-hold set \
            --account-name mystorageaccount \
            --container-name compliance-data \
            --tags "case-12345" "investigation-2024"

        # Remove legal hold
        az storage container legal-hold clear \
            --account-name mystorageaccount \
            --container-name compliance-data \
            --tags "case-12345"
        ```
        **Step 4: Version-Level Immutability in C#**
        ```csharp
        using Azure.Storage.Blobs;
        using Azure.Storage.Blobs.Models;

        public class ImmutableStorageService
        {
            private readonly BlobContainerClient _container;

            public async Task UploadWithImmutabilityAsync(
                string blobName, Stream content, int retentionDays)
            {
                var blobClient = _container.GetBlobClient(blobName);

                var options = new BlobUploadOptions
                {
                    ImmutabilityPolicy = new BlobImmutabilityPolicy
                    {
                        ExpiresOn = DateTimeOffset.UtcNow.AddDays(retentionDays),
                        PolicyMode = BlobImmutabilityPolicyMode.Unlocked
                    }
                };

                await blobClient.UploadAsync(content, options);
            }

            public async Task SetLegalHoldAsync(string blobName, bool hasLegalHold)
            {
                var blobClient = _container.GetBlobClient(blobName);
                await blobClient.SetLegalHoldAsync(hasLegalHold);
            }

            public async Task ExtendRetentionAsync(string blobName, DateTimeOffset newExpiry)
            {
                var blobClient = _container.GetBlobClient(blobName);
                var policy = new BlobImmutabilityPolicy
                {
                    ExpiresOn = newExpiry,
                    PolicyMode = BlobImmutabilityPolicyMode.Unlocked
                };
                await blobClient.SetImmutabilityPolicyAsync(policy);
            }
        }
        ```
        **Step 5: Bicep Template for Immutable Container**
        ```bicep
        resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
            name: '${storageAccount.name}/default/compliance'
            properties: {
                immutableStorageWithVersioning: {
                    enabled: true
                }
            }
        }

        resource immutabilityPolicy 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2023-01-01' = {
            parent: container
            name: 'default'
            properties: {
                immutabilityPeriodSinceCreationInDays: 365
                allowProtectedAppendWrites: true
                allowProtectedAppendWritesAll: false
            }
        }
        ```
        **References:**
        - [Immutable Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-storage-overview)
        - [Legal Hold](https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-legal-hold-overview)

19. How do you implement blob inventory and analytics?
    - **Answer:**
        Blob inventory provides automated reports of blob metadata. Combined with Azure Synapse Analytics, you can analyze storage patterns, costs, and compliance.
    - **Implementation:**
        **Step 1: Create Blob Inventory Policy**
        ```sh
        az storage account blob-inventory-policy create \
            --account-name mystorageaccount \
            --resource-group myrg \
            --policy '{
                "enabled": true,
                "rules": [
                    {
                        "enabled": true,
                        "name": "daily-inventory",
                        "destination": "inventory-reports",
                        "definition": {
                            "filters": {
                                "blobTypes": ["blockBlob", "appendBlob"],
                                "prefixMatch": ["data/", "logs/"],
                                "includeSnapshots": true,
                                "includeBlobVersions": true
                            },
                            "format": "Parquet",
                            "schedule": "Daily",
                            "objectType": "Blob",
                            "schemaFields": [
                                "Name", "CreationTime", "LastModified",
                                "ContentLength", "BlobType", "AccessTier",
                                "AccessTierChangeTime", "Metadata", "Tags",
                                "VersionId", "IsCurrentVersion", "Deleted"
                            ]
                        }
                    }
                ]
            }'
        ```
        **Step 2: Analyze Inventory with Synapse**
        ```sql
        -- Create external data source
        CREATE EXTERNAL DATA SOURCE InventoryData
        WITH (
            LOCATION = 'https://mystorageaccount.blob.core.windows.net/inventory-reports'
        );

        -- Query inventory reports
        SELECT
            Name,
            ContentLength / (1024 * 1024) AS SizeMB,
            AccessTier,
            LastModified,
            DATEDIFF(day, LastModified, GETUTCDATE()) AS DaysSinceModified
        FROM OPENROWSET(
            BULK 'inventory/2024/01/15/*.parquet',
            DATA_SOURCE = 'InventoryData',
            FORMAT = 'PARQUET'
        ) AS inventory
        WHERE AccessTier = 'Hot'
          AND DATEDIFF(day, LastModified, GETUTCDATE()) > 90
        ORDER BY ContentLength DESC;

        -- Storage cost analysis
        SELECT
            AccessTier,
            COUNT(*) AS BlobCount,
            SUM(ContentLength) / (1024.0 * 1024 * 1024) AS TotalSizeGB
        FROM OPENROWSET(
            BULK 'inventory/2024/01/15/*.parquet',
            DATA_SOURCE = 'InventoryData',
            FORMAT = 'PARQUET'
        ) AS inventory
        GROUP BY AccessTier;
        ```
        **Step 3: C# Code to Process Inventory**
        ```csharp
        using Azure.Storage.Blobs;
        using Parquet.Data;
        using Parquet;

        public class InventoryAnalyzer
        {
            public async Task<StorageReport> AnalyzeInventoryAsync(
                string connectionString, string inventoryContainer, string reportDate)
            {
                var container = new BlobContainerClient(connectionString, inventoryContainer);
                var report = new StorageReport();

                await foreach (var blob in container.GetBlobsAsync(
                    prefix: $"inventory/{reportDate}"))
                {
                    if (blob.Name.EndsWith(".parquet"))
                    {
                        var blobClient = container.GetBlobClient(blob.Name);
                        using var stream = await blobClient.OpenReadAsync();
                        using var reader = await ParquetReader.CreateAsync(stream);

                        for (int i = 0; i < reader.RowGroupCount; i++)
                        {
                            using var rowGroup = reader.OpenRowGroupReader(i);
                            ProcessRowGroup(rowGroup, report);
                        }
                    }
                }

                return report;
            }
        }
        ```
        **Step 4: Azure Function for Automated Analysis**
        ```csharp
        [Function("AnalyzeInventory")]
        public async Task Run(
            [BlobTrigger("inventory-reports/{date}/manifest.json")] string manifest,
            string date,
            FunctionContext context)
        {
            var logger = context.GetLogger("AnalyzeInventory");
            logger.LogInformation($"Processing inventory for {date}");

            var report = await _analyzer.AnalyzeInventoryAsync(date);

            // Alert on storage anomalies
            if (report.HotTierGrowthPercent > 20)
            {
                await SendAlertAsync($"Hot tier grew {report.HotTierGrowthPercent}% - review lifecycle policies");
            }

            // Save report
            await SaveReportAsync(report);
        }
        ```
        **References:**
        - [Blob Inventory](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-inventory)
        - [Analyze Inventory with Synapse](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-inventory-how-to)

20. How do you implement point-in-time restore for blobs?
    - **Answer:**
        Point-in-time restore allows you to restore block blobs to a previous state within the retention period. Requires versioning, change feed, and soft delete to be enabled.
    - **Implementation:**
        **Step 1: Enable Point-in-Time Restore Prerequisites**
        ```sh
        # Enable all required features
        az storage account blob-service-properties update \
            --account-name mystorageaccount \
            --resource-group myrg \
            --enable-versioning true \
            --enable-change-feed true \
            --change-feed-retention-days 14

        # Enable soft delete
        az storage blob service-properties delete-policy update \
            --account-name mystorageaccount \
            --enable true \
            --days-retained 14

        # Enable point-in-time restore
        az storage account blob-service-properties update \
            --account-name mystorageaccount \
            --resource-group myrg \
            --enable-restore-policy true \
            --restore-days 13
        ```
        **Step 2: Perform Point-in-Time Restore via CLI**
        ```sh
        # Restore entire account to specific time
        az storage blob restore \
            --account-name mystorageaccount \
            --resource-group myrg \
            --time-to-restore "2024-01-15T10:30:00Z"

        # Restore specific container
        az storage blob restore \
            --account-name mystorageaccount \
            --resource-group myrg \
            --time-to-restore "2024-01-15T10:30:00Z" \
            --blob-range '["container1/","container1/\uffff"]'

        # Restore specific prefix
        az storage blob restore \
            --account-name mystorageaccount \
            --resource-group myrg \
            --time-to-restore "2024-01-15T10:30:00Z" \
            --blob-range '["container1/folder1/","container1/folder1/\uffff"]'
        ```
        **Step 3: Restore Using C# SDK**
        ```csharp
        using Azure.ResourceManager;
        using Azure.ResourceManager.Storage;
        using Azure.ResourceManager.Storage.Models;

        public class PointInTimeRestoreService
        {
            private readonly ArmClient _armClient;

            public async Task<BlobRestoreStatus> RestoreContainerAsync(
                string subscriptionId,
                string resourceGroup,
                string accountName,
                string containerName,
                DateTimeOffset restoreTime)
            {
                var storageAccount = _armClient
                    .GetSubscriptionResource(new ResourceIdentifier($"/subscriptions/{subscriptionId}"))
                    .GetResourceGroup(resourceGroup)
                    .GetStorageAccount(accountName);

                var ranges = new List<BlobRestoreRange>
                {
                    new BlobRestoreRange
                    {
                        StartRange = $"{containerName}/",
                        EndRange = $"{containerName}/\uffff"
                    }
                };

                var restoreParameters = new BlobRestoreContent(restoreTime, ranges);

                var operation = await storageAccount.Value.RestoreBlobRangesAsync(
                    WaitUntil.Started, restoreParameters);

                return operation.Value;
            }

            public async Task<BlobRestoreStatus> GetRestoreStatusAsync(
                string subscriptionId,
                string resourceGroup,
                string accountName)
            {
                var storageAccount = await _armClient
                    .GetStorageAccountResource(new ResourceIdentifier(
                        $"/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Storage/storageAccounts/{accountName}"))
                    .GetAsync();

                return storageAccount.Value.Data.BlobRestoreStatus;
            }
        }
        ```
        **Step 4: Monitor Restore Progress**
        ```sh
        # Check restore status
        az storage account show \
            --name mystorageaccount \
            --resource-group myrg \
            --query blobRestoreStatus

        # Monitor with polling
        while true; do
            status=$(az storage account show --name mystorageaccount --resource-group myrg --query blobRestoreStatus.status -o tsv)
            echo "Status: $status"
            if [ "$status" == "Complete" ] || [ "$status" == "Failed" ]; then
                break
            fi
            sleep 30
        done
        ```
        **Step 5: Bicep Template for PITR Configuration**
        ```bicep
        resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
            name: 'mystorageaccount'
            location: resourceGroup().location
            sku: { name: 'Standard_LRS' }
            kind: 'StorageV2'
        }

        resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
            parent: storageAccount
            name: 'default'
            properties: {
                isVersioningEnabled: true
                changeFeed: {
                    enabled: true
                    retentionInDays: 14
                }
                deleteRetentionPolicy: {
                    enabled: true
                    days: 14
                }
                restorePolicy: {
                    enabled: true
                    days: 13  // Must be less than deleteRetentionPolicy days
                }
            }
        }
        ```
        **References:**
        - [Point-in-Time Restore](https://learn.microsoft.com/en-us/azure/storage/blobs/point-in-time-restore-overview)
        - [Perform Point-in-Time Restore](https://learn.microsoft.com/en-us/azure/storage/blobs/point-in-time-restore-manage)

### 2.2 Azure Table Storage
1. How do you design a scalable table schema?
    - **Answer:**
        Use partition keys for even data distribution, avoid hot partitions, and design based on query patterns.
    - **Implementation:**
        **Step 1: Define Entity with PartitionKey and RowKey**
        ```csharp
        using Azure.Data.Tables;

        public class OrderEntity : ITableEntity
        {
            public string PartitionKey { get; set; }  // e.g., CustomerId or Date
            public string RowKey { get; set; }        // e.g., OrderId
            public DateTimeOffset? Timestamp { get; set; }
            public ETag ETag { get; set; }
            public string ProductName { get; set; }
            public double Price { get; set; }
        }
        ```
        **Step 2: Design for Query Patterns**
        ```csharp
        // Good: Query by partition (fast)
        var orders = tableClient.Query<OrderEntity>(e => e.PartitionKey == "2024-01");

        // Avoid: Full table scan (slow)
        var allOrders = tableClient.Query<OrderEntity>(e => e.Price > 100);
        ```
        **Best Practices:**
        - Use date-based partitions for time-series data
        - Use customer/tenant ID for multi-tenant apps
        - Avoid single partition key (creates hot partition)
        **References:**
        - [Table Storage Design Guide](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-guidelines)

2. How do you query data efficiently?
    - **Answer:**
        Use partition and row keys in queries to avoid full table scans, use point queries when possible.
    - **Implementation:**
        **Step 1: Point Query (Fastest)**
        ```csharp
        using Azure.Data.Tables;

        var tableClient = new TableClient(connectionString, "Orders");
        var entity = await tableClient.GetEntityAsync<OrderEntity>("2024-01", "order-123");
        ```
        **Step 2: Partition Query**
        ```csharp
        var orders = tableClient.Query<OrderEntity>(
            filter: $"PartitionKey eq '2024-01'",
            maxPerPage: 100);
        await foreach (var order in orders)
        {
            Console.WriteLine($"{order.RowKey}: {order.ProductName}");
        }
        ```
        **Step 3: Range Query within Partition**
        ```csharp
        var orders = tableClient.Query<OrderEntity>(
            filter: $"PartitionKey eq '2024-01' and RowKey ge 'order-100' and RowKey lt 'order-200'");
        ```
        **References:**
        - [Query Table Storage](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-for-query)

3. How do you secure table access?
    - **Answer:**
        Use SAS tokens for time-limited access, Azure AD with RBAC, and restrict via firewall/VNet.
    - **Implementation:**
        **Step 1: Generate SAS Token**
        ```csharp
        var sasBuilder = new TableSasBuilder("Orders", TableSasPermissions.Read, DateTimeOffset.UtcNow.AddHours(1))
        {
            StartsOn = DateTimeOffset.UtcNow
        };
        var sasToken = sasBuilder.Sign(new TableSharedKeyCredential(accountName, accountKey));
        var sasUri = $"https://{accountName}.table.core.windows.net/Orders?{sasToken}";
        ```
        **Step 2: Use Azure AD Authentication**
        ```csharp
        var tableClient = new TableClient(
            new Uri($"https://{accountName}.table.core.windows.net"),
            "Orders",
            new DefaultAzureCredential());
        ```
        **Step 3: Configure Firewall (CLI)**
        ```sh
        az storage account network-rule add --resource-group myrg --account-name mystorage --ip-address 203.0.113.0/24
        ```
        **References:**
        - [Table Storage Security](https://learn.microsoft.com/en-us/azure/storage/common/storage-sas-overview)

4. How do you handle schema changes?
    - **Answer:**
        Use flexible entity properties, version entities with a version field, or migrate data incrementally.
    - **Implementation:**
        **Step 1: Add New Properties (Backward Compatible)**
        ```csharp
        public class OrderEntityV2 : ITableEntity
        {
            public string PartitionKey { get; set; }
            public string RowKey { get; set; }
            public DateTimeOffset? Timestamp { get; set; }
            public ETag ETag { get; set; }
            public string ProductName { get; set; }
            public double Price { get; set; }
            public string NewField { get; set; }  // New property - null for old entities
            public int SchemaVersion { get; set; } = 2;  // Version tracking
        }
        ```
        **Step 2: Handle Multiple Versions in Code**
        ```csharp
        var entity = await tableClient.GetEntityAsync<TableEntity>(pk, rk);
        var version = entity.Value.GetInt32("SchemaVersion") ?? 1;
        if (version == 1)
        {
            // Handle v1 schema
        }
        else
        {
            // Handle v2 schema
        }
        ```
        **References:**
        - [Table Storage Schema Evolution](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-patterns)

5. How do you monitor table operations?
    - **Answer:**
        Enable diagnostic logging, use Azure Monitor metrics, and set up alerts.
    - **Implementation:**
        **Step 1: Enable Diagnostics (CLI)**
        ```sh
        az monitor diagnostic-settings create --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorage --name mydiag --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true}]' --workspace <workspace-id>
        ```
        **Step 2: Query Table Metrics (Kusto)**
        ```kusto
        StorageTableLogs
        | where AccountName == "mystorage"
        | summarize count() by OperationName, bin(TimeGenerated, 1h)
        ```
        **Step 3: Create Alert for High Latency**
        - Azure Portal: Storage Account > Monitoring > Alerts > New alert rule
        - Condition: Success E2E Latency > 1000ms
        **References:**
        - [Monitor Table Storage](https://learn.microsoft.com/en-us/azure/storage/tables/monitor-table-storage)

6. How do you handle large datasets?
    - **Answer:**
        Use batch operations for bulk inserts, partition data effectively, and paginate query results.
    - **Implementation:**
        **Step 1: Batch Operations (Max 100 entities, same partition)**
        ```csharp
        var batch = new List<TableTransactionAction>();
        foreach (var entity in entitiesToInsert.Take(100))
        {
            batch.Add(new TableTransactionAction(TableTransactionActionType.Add, entity));
        }
        await tableClient.SubmitTransactionAsync(batch);
        ```
        **Step 2: Paginate Query Results**
        ```csharp
        string continuationToken = null;
        do
        {
            var page = tableClient.Query<OrderEntity>(maxPerPage: 1000)
                .AsPages(continuationToken).First();
            foreach (var entity in page.Values)
            {
                // Process entity
            }
            continuationToken = page.ContinuationToken;
        } while (continuationToken != null);
        ```
        **References:**
        - [Table Storage Batch Operations](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-patterns)

7. How do you implement optimistic concurrency?
    - **Answer:**
        Use ETag property for version tracking and If-Match header to prevent concurrent update conflicts.
    - **Implementation:**
        **Step 1: Read Entity with ETag**
        ```csharp
        var response = await tableClient.GetEntityAsync<OrderEntity>("2024-01", "order-123");
        var entity = response.Value;
        var etag = entity.ETag;
        ```
        **Step 2: Update with ETag Check**
        ```csharp
        entity.Price = 99.99;
        try
        {
            await tableClient.UpdateEntityAsync(entity, etag, TableUpdateMode.Replace);
        }
        catch (RequestFailedException ex) when (ex.Status == 412)
        {
            Console.WriteLine("Conflict: Entity was modified by another process");
            // Retry logic: re-read and re-apply changes
        }
        ```
        **Step 3: Force Update (Ignore Concurrency)**
        ```csharp
        await tableClient.UpdateEntityAsync(entity, ETag.All, TableUpdateMode.Replace);
        ```
        **References:**
        - [Optimistic Concurrency](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-patterns)

8. How do you backup table data?
    - **Answer:**
        Export to Blob Storage using Data Factory, AzCopy, or custom scripts.
    - **Implementation:**
        **Step 1: Export with Azure Data Factory**
        - Create pipeline: Table Storage (source) → Blob Storage (sink)
        - Schedule daily/weekly backups
        **Step 2: Custom Backup Script (C#)**
        ```csharp
        var entities = tableClient.Query<TableEntity>();
        var json = JsonSerializer.Serialize(entities.ToList());
        var blobClient = containerClient.GetBlobClient($"backup-{DateTime.UtcNow:yyyy-MM-dd}.json");
        await blobClient.UploadAsync(BinaryData.FromString(json), overwrite: true);
        ```
        **Step 3: Use AzCopy for Export**
        ```sh
        azcopy copy "https://mystorage.table.core.windows.net/Orders?<sas>" "https://mystorage.blob.core.windows.net/backups/orders.json" --recursive
        ```
        **References:**
        - [Data Factory Table Copy](https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-table-storage)

9. How do you restore deleted entities?
    - **Answer:**
        Implement soft delete pattern with IsDeleted flag and DeletedAt timestamp, or restore from backups.
    - **Implementation:**
        **Step 1: Implement Soft Delete Pattern**
        ```csharp
        public class OrderEntity : ITableEntity
        {
            // ... other properties
            public bool IsDeleted { get; set; }
            public DateTimeOffset? DeletedAt { get; set; }
        }

        // Soft delete
        entity.IsDeleted = true;
        entity.DeletedAt = DateTimeOffset.UtcNow;
        await tableClient.UpdateEntityAsync(entity, entity.ETag);

        // Query active entities only
        var activeOrders = tableClient.Query<OrderEntity>(e => !e.IsDeleted);
        ```
        **Step 2: Restore Soft-Deleted Entity**
        ```csharp
        entity.IsDeleted = false;
        entity.DeletedAt = null;
        await tableClient.UpdateEntityAsync(entity, entity.ETag);
        ```
        **Step 3: Purge Old Deleted Entities**
        ```csharp
        var oldDeleted = tableClient.Query<OrderEntity>(
            e => e.IsDeleted && e.DeletedAt < DateTimeOffset.UtcNow.AddDays(-30));
        foreach (var entity in oldDeleted)
        {
            await tableClient.DeleteEntityAsync(entity.PartitionKey, entity.RowKey);
        }
        ```
        **References:**
        - [Table Storage Patterns](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-patterns)

10. How do you automate data import/export?
    - **Answer:**
        Use Azure Data Factory for scheduled ETL, AzCopy for bulk transfers, or custom scripts with SDK.
    - **Implementation:**
        **Step 1: Data Factory Pipeline (JSON)**
        ```json
        {
            "name": "TableToBlob",
            "properties": {
                "activities": [{
                    "name": "CopyTableData",
                    "type": "Copy",
                    "inputs": [{ "referenceName": "TableSource", "type": "DatasetReference" }],
                    "outputs": [{ "referenceName": "BlobSink", "type": "DatasetReference" }]
                }],
                "trigger": { "type": "ScheduleTrigger", "recurrence": { "frequency": "Day", "interval": 1 } }
            }
        }
        ```
        **Step 2: Bulk Import with SDK**
        ```csharp
        var data = JsonSerializer.Deserialize<List<OrderEntity>>(File.ReadAllText("orders.json"));
        foreach (var batch in data.Chunk(100))
        {
            var actions = batch.Select(e => new TableTransactionAction(TableTransactionActionType.UpsertReplace, e));
            await tableClient.SubmitTransactionAsync(actions);
        }
        ```
        **References:**
        - [Data Factory with Table Storage](https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-table-storage)

11. How do you handle access from Functions or Logic Apps?
    - **Answer:**
        Use connection strings stored in app settings, or Managed Identity with RBAC for secure access.
    - **Implementation:**
        **Step 1: Azure Function with Table Binding**
        ```csharp
        [FunctionName("GetOrder")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req,
            [Table("Orders", Connection = "AzureWebJobsStorage")] TableClient tableClient)
        {
            var entity = await tableClient.GetEntityAsync<OrderEntity>("2024-01", req.Query["id"]);
            return new OkObjectResult(entity.Value);
        }
        ```
        **Step 2: Use Managed Identity**
        ```csharp
        var tableClient = new TableClient(
            new Uri("https://mystorage.table.core.windows.net"),
            "Orders",
            new DefaultAzureCredential());
        ```
        **Step 3: Logic App Table Connector**
        - Add action: Azure Table Storage > Get entity
        - Configure: Storage account, Table name, Partition Key, Row Key
        **References:**
        - [Table Storage Bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-table)

12. How do you optimize for cost?
    - **Answer:**
        Store only necessary data, use batch operations to reduce transactions, and monitor usage patterns.
    - **Implementation:**
        **Step 1: Use Batch Operations**
        ```csharp
        // Single batch = 1 transaction cost (up to 100 entities)
        var batch = entities.Take(100)
            .Select(e => new TableTransactionAction(TableTransactionActionType.Add, e))
            .ToList();
        await tableClient.SubmitTransactionAsync(batch);
        ```
        **Step 2: Remove Unused Properties**
        ```csharp
        // Store only required fields to reduce storage costs
        var leanEntity = new TableEntity(partitionKey, rowKey)
        {
            { "Name", order.Name },
            { "Amount", order.Amount }
            // Omit rarely-used fields
        };
        ```
        **Step 3: Monitor Storage Costs**
        - Azure Portal: Storage Account > Metrics > Transactions, Data stored
        - Set up budget alerts in Cost Management
        **References:**
        - [Table Storage Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/tables/)

13. How do you audit access?
    - **Answer:**
        Enable diagnostic logs for storage operations, review Activity Log for management operations.
    - **Implementation:**
        **Step 1: Enable Storage Analytics Logging**
        ```sh
        az storage logging update --account-name mystorage --services t --log rwd --retention 30
        ```
        **Step 2: Query Audit Logs (Kusto)**
        ```kusto
        StorageTableLogs
        | where AccountName == "mystorage"
        | where OperationName in ("GetEntity", "InsertEntity", "DeleteEntity")
        | project TimeGenerated, CallerIpAddress, OperationName, Uri
        | order by TimeGenerated desc
        ```
        **Step 3: Set Up Alerts for Suspicious Activity**
        - Azure Monitor > Alerts > Condition: Unusual number of delete operations
        **References:**
        - [Storage Analytics Logging](https://learn.microsoft.com/en-us/azure/storage/common/storage-analytics-logging)

14. How do you handle multi-region replication?
    - **Answer:**
        Use geo-redundant storage (GRS/RA-GRS) for automatic replication, or implement custom replication logic.
    - **Implementation:**
        **Step 1: Enable Geo-Redundant Storage**
        ```sh
        az storage account update --name mystorage --resource-group myrg --sku Standard_GRS
        ```
        **Step 2: Custom Active-Active Replication**
        ```csharp
        // Write to both regions
        var primaryClient = new TableClient(primaryConnectionString, "Orders");
        var secondaryClient = new TableClient(secondaryConnectionString, "Orders");

        await Task.WhenAll(
            primaryClient.UpsertEntityAsync(entity),
            secondaryClient.UpsertEntityAsync(entity));
        ```
        **Step 3: Read from Secondary (RA-GRS)**
        ```csharp
        var options = new TableClientOptions
        {
            GeoRedundantSecondaryUri = new Uri($"https://{accountName}-secondary.table.core.windows.net")
        };
        var client = new TableClient(connectionString, "Orders", options);
        ```
        **References:**
        - [Storage Redundancy](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy)

15. How do you enforce data retention policies?
    - **Answer:**
        Use scheduled Azure Functions or Logic Apps to delete old data based on timestamp properties.
    - **Implementation:**
        **Step 1: Add Timestamp Property**
        ```csharp
        public class OrderEntity : ITableEntity
        {
            // ... other properties
            public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
        }
        ```
        **Step 2: Scheduled Cleanup Function**
        ```csharp
        [FunctionName("DataRetentionCleanup")]
        public static async Task Run([TimerTrigger("0 0 2 * * *")] TimerInfo timer, ILogger log)
        {
            var tableClient = new TableClient(connectionString, "Orders");
            var cutoff = DateTimeOffset.UtcNow.AddDays(-365);  // 1 year retention

            var oldEntities = tableClient.Query<OrderEntity>(e => e.CreatedAt < cutoff);
            foreach (var entity in oldEntities)
            {
                await tableClient.DeleteEntityAsync(entity.PartitionKey, entity.RowKey);
                log.LogInformation($"Deleted: {entity.RowKey}");
            }
        }
        ```
        **Step 3: Logic App Alternative**
        - Recurrence trigger (daily) → Query old entities → For each → Delete entity
        **References:**
        - [Data Lifecycle Management](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-guidelines)

16. How do you implement secondary indexes in Table Storage?
    - **Answer:**
        Table Storage only supports PartitionKey and RowKey queries natively. Implement secondary indexes using denormalization (duplicate data with different keys) or maintain a separate index table.
    - **Implementation:**
        **Step 1: Index Table Pattern**
        ```csharp
        public class OrderEntity : ITableEntity
        {
            public string PartitionKey { get; set; } // CustomerId
            public string RowKey { get; set; }       // OrderId
            public string ProductId { get; set; }
            public decimal Amount { get; set; }
            public DateTimeOffset OrderDate { get; set; }
            public DateTimeOffset? Timestamp { get; set; }
            public ETag ETag { get; set; }
        }

        // Secondary index entity for querying by ProductId
        public class OrderByProductIndex : ITableEntity
        {
            public string PartitionKey { get; set; } // ProductId
            public string RowKey { get; set; }       // CustomerId_OrderId
            public string CustomerId { get; set; }
            public string OrderId { get; set; }
            public DateTimeOffset? Timestamp { get; set; }
            public ETag ETag { get; set; }
        }

        public class OrderRepository
        {
            private readonly TableClient _ordersTable;
            private readonly TableClient _ordersByProductTable;

            public async Task CreateOrderAsync(OrderEntity order)
            {
                // Insert main entity
                await _ordersTable.AddEntityAsync(order);

                // Insert index entity
                var indexEntity = new OrderByProductIndex
                {
                    PartitionKey = order.ProductId,
                    RowKey = $"{order.PartitionKey}_{order.RowKey}",
                    CustomerId = order.PartitionKey,
                    OrderId = order.RowKey
                };
                await _ordersByProductTable.AddEntityAsync(indexEntity);
            }

            // Query by secondary index (ProductId)
            public async Task<List<OrderEntity>> GetOrdersByProductAsync(string productId)
            {
                var orders = new List<OrderEntity>();

                // Get index entries
                var indexEntries = _ordersByProductTable.QueryAsync<OrderByProductIndex>(
                    filter: $"PartitionKey eq '{productId}'");

                await foreach (var index in indexEntries)
                {
                    // Fetch actual order using index data
                    var order = await _ordersTable.GetEntityAsync<OrderEntity>(
                        index.CustomerId, index.OrderId);
                    orders.Add(order.Value);
                }

                return orders;
            }
        }
        ```
        **Step 2: Denormalized Entity Pattern**
        ```csharp
        public class OrderDenormalized
        {
            // Store same data with different partition strategies
            public async Task CreateOrderWithIndexesAsync(Order order)
            {
                var tasks = new List<Task>();

                // Primary: by CustomerId
                tasks.Add(_tableClient.AddEntityAsync(new TableEntity(order.CustomerId, order.Id)
                {
                    { "ProductId", order.ProductId },
                    { "Amount", order.Amount },
                    { "OrderDate", order.OrderDate }
                }));

                // Index: by ProductId
                tasks.Add(_tableClient.AddEntityAsync(new TableEntity($"PRODUCT_{order.ProductId}", $"{order.CustomerId}_{order.Id}")
                {
                    { "CustomerId", order.CustomerId },
                    { "Amount", order.Amount },
                    { "OrderDate", order.OrderDate }
                }));

                // Index: by Date (for date range queries)
                tasks.Add(_tableClient.AddEntityAsync(new TableEntity($"DATE_{order.OrderDate:yyyyMMdd}", $"{order.CustomerId}_{order.Id}")
                {
                    { "CustomerId", order.CustomerId },
                    { "ProductId", order.ProductId },
                    { "Amount", order.Amount }
                }));

                await Task.WhenAll(tasks);
            }
        }
        ```
        **Step 3: Event-Driven Index Maintenance**
        ```csharp
        [Function("MaintainOrderIndexes")]
        public async Task Run(
            [QueueTrigger("order-events")] OrderEvent orderEvent)
        {
            switch (orderEvent.EventType)
            {
                case "Created":
                    await CreateIndexesAsync(orderEvent.Order);
                    break;
                case "Updated":
                    await UpdateIndexesAsync(orderEvent.OldOrder, orderEvent.NewOrder);
                    break;
                case "Deleted":
                    await DeleteIndexesAsync(orderEvent.Order);
                    break;
            }
        }
        ```
        **References:**
        - [Table Design Patterns](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-patterns)
        - [Index Table Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/index-table)

17. How do you implement efficient pagination in Table Storage?
    - **Answer:**
        Use continuation tokens for stateless pagination. Table Storage returns continuation tokens when more results exist beyond the page size.
    - **Implementation:**
        **Step 1: Implement Pagination with Continuation Tokens**
        ```csharp
        public class PagedResult<T>
        {
            public List<T> Items { get; set; }
            public string ContinuationToken { get; set; }
            public bool HasMore => !string.IsNullOrEmpty(ContinuationToken);
        }

        public class TablePaginationService
        {
            private readonly TableClient _tableClient;

            public async Task<PagedResult<OrderEntity>> GetOrdersPagedAsync(
                string customerId,
                int pageSize,
                string continuationToken = null)
            {
                var result = new PagedResult<OrderEntity> { Items = new List<OrderEntity>() };

                var query = _tableClient.QueryAsync<OrderEntity>(
                    filter: $"PartitionKey eq '{customerId}'",
                    maxPerPage: pageSize);

                await foreach (var page in query.AsPages(continuationToken, pageSize))
                {
                    result.Items.AddRange(page.Values);
                    result.ContinuationToken = page.ContinuationToken;
                    break; // Only get first page
                }

                return result;
            }

            // API endpoint usage
            public async Task<IActionResult> GetOrders(
                [FromQuery] string customerId,
                [FromQuery] int pageSize = 50,
                [FromQuery] string continuationToken = null)
            {
                // Decode base64 continuation token from client
                var decodedToken = continuationToken != null
                    ? Encoding.UTF8.GetString(Convert.FromBase64String(continuationToken))
                    : null;

                var result = await GetOrdersPagedAsync(customerId, pageSize, decodedToken);

                // Encode continuation token for client
                var response = new
                {
                    items = result.Items,
                    nextPage = result.ContinuationToken != null
                        ? Convert.ToBase64String(Encoding.UTF8.GetBytes(result.ContinuationToken))
                        : null
                };

                return Ok(response);
            }
        }
        ```
        **Step 2: Cursor-Based Pagination Alternative**
        ```csharp
        public async Task<PagedResult<OrderEntity>> GetOrdersByCursorAsync(
            string customerId,
            string lastRowKey,
            int pageSize)
        {
            var filter = string.IsNullOrEmpty(lastRowKey)
                ? $"PartitionKey eq '{customerId}'"
                : $"PartitionKey eq '{customerId}' and RowKey gt '{lastRowKey}'";

            var result = new PagedResult<OrderEntity> { Items = new List<OrderEntity>() };

            var query = _tableClient.QueryAsync<OrderEntity>(
                filter: filter,
                maxPerPage: pageSize + 1); // Fetch one extra to check if more exist

            await foreach (var entity in query)
            {
                if (result.Items.Count < pageSize)
                {
                    result.Items.Add(entity);
                }
                else
                {
                    result.ContinuationToken = result.Items.Last().RowKey;
                    break;
                }
            }

            return result;
        }
        ```
        **References:**
        - [Query Entities](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-for-query)

18. How do you handle concurrent updates in Table Storage?
    - **Answer:**
        Use optimistic concurrency with ETags. Table Storage returns an ETag with each entity that changes on every update. Use If-Match header to ensure atomic updates.
    - **Implementation:**
        **Step 1: Optimistic Concurrency Update**
        ```csharp
        public class ConcurrencyHandler
        {
            private readonly TableClient _tableClient;

            public async Task<bool> UpdateWithOptimisticConcurrencyAsync(
                string partitionKey,
                string rowKey,
                Action<OrderEntity> updateAction,
                int maxRetries = 5)
            {
                for (int attempt = 0; attempt < maxRetries; attempt++)
                {
                    try
                    {
                        // Read current entity with ETag
                        var response = await _tableClient.GetEntityAsync<OrderEntity>(
                            partitionKey, rowKey);
                        var entity = response.Value;

                        // Apply updates
                        updateAction(entity);

                        // Update with If-Match (ETag check)
                        await _tableClient.UpdateEntityAsync(
                            entity,
                            entity.ETag,
                            TableUpdateMode.Replace);

                        return true;
                    }
                    catch (RequestFailedException ex) when (ex.Status == 412)
                    {
                        // Precondition failed - entity was modified
                        if (attempt == maxRetries - 1) throw;
                        await Task.Delay(TimeSpan.FromMilliseconds(100 * Math.Pow(2, attempt)));
                    }
                }
                return false;
            }

            // Usage example: Increment counter
            public async Task IncrementOrderCountAsync(string customerId, string orderId)
            {
                await UpdateWithOptimisticConcurrencyAsync(
                    customerId,
                    orderId,
                    entity => entity.ProcessedCount++);
            }
        }
        ```
        **Step 2: Merge vs Replace Operations**
        ```csharp
        public async Task UpdatePartialEntityAsync(
            string partitionKey,
            string rowKey,
            Dictionary<string, object> propertiesToUpdate)
        {
            // Merge only updates specified properties
            var entity = new TableEntity(partitionKey, rowKey);
            foreach (var prop in propertiesToUpdate)
            {
                entity[prop.Key] = prop.Value;
            }

            // Use Merge to update only specified fields
            await _tableClient.UpdateEntityAsync(entity, ETag.All, TableUpdateMode.Merge);
        }

        // Force update regardless of concurrent changes (use with caution)
        public async Task ForceUpdateAsync(OrderEntity entity)
        {
            await _tableClient.UpdateEntityAsync(entity, ETag.All, TableUpdateMode.Replace);
        }
        ```
        **Step 3: Pessimistic Locking Pattern**
        ```csharp
        public class TableLockManager
        {
            private readonly TableClient _lockTable;

            public async Task<bool> AcquireLockAsync(string resourceId, string lockOwner, TimeSpan duration)
            {
                var lockEntity = new TableEntity("LOCKS", resourceId)
                {
                    { "Owner", lockOwner },
                    { "ExpiresAt", DateTimeOffset.UtcNow.Add(duration) }
                };

                try
                {
                    await _lockTable.AddEntityAsync(lockEntity);
                    return true;
                }
                catch (RequestFailedException ex) when (ex.Status == 409)
                {
                    // Lock exists - check if expired
                    var existing = await _lockTable.GetEntityAsync<TableEntity>("LOCKS", resourceId);
                    if (existing.Value.GetDateTimeOffset("ExpiresAt") < DateTimeOffset.UtcNow)
                    {
                        // Lock expired - try to take over
                        await _lockTable.UpdateEntityAsync(lockEntity, existing.Value.ETag, TableUpdateMode.Replace);
                        return true;
                    }
                    return false;
                }
            }

            public async Task ReleaseLockAsync(string resourceId, string lockOwner)
            {
                var existing = await _lockTable.GetEntityAsync<TableEntity>("LOCKS", resourceId);
                if (existing.Value.GetString("Owner") == lockOwner)
                {
                    await _lockTable.DeleteEntityAsync("LOCKS", resourceId, existing.Value.ETag);
                }
            }
        }
        ```
        **References:**
        - [Optimistic Concurrency](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-for-modification)

19. How do you migrate from Table Storage to Cosmos DB Table API?
    - **Answer:**
        Cosmos DB Table API provides premium features (global distribution, SLA guarantees) with Table Storage API compatibility. Use Data Migration Tool or custom migration code.
    - **Implementation:**
        **Step 1: Create Cosmos DB Table API Account**
        ```sh
        az cosmosdb create \
            --name mycosmosaccount \
            --resource-group myrg \
            --capabilities EnableTable \
            --default-consistency-level Session \
            --locations regionName=eastus failoverPriority=0 isZoneRedundant=true

        az cosmosdb table create \
            --account-name mycosmosaccount \
            --resource-group myrg \
            --name orders \
            --throughput 10000
        ```
        **Step 2: Migrate Data Using Data Migration Tool**
        ```sh
        # Download Azure Cosmos DB Data Migration Tool
        # Configure source (Table Storage)
        dt.exe /s:AzureTable /s.ConnectionString:"DefaultEndpointsProtocol=https;AccountName=mystorage;AccountKey=..." /s.Table:orders

        # Configure target (Cosmos DB Table API)
        /t:TableAPIBulk /t.ConnectionString:"DefaultEndpointsProtocol=https;AccountName=mycosmosaccount;AccountKey=...;TableEndpoint=https://mycosmosaccount.table.cosmos.azure.com:443/;" /t.TableName:orders
        ```
        **Step 3: Custom Migration with C#**
        ```csharp
        public class TableMigrationService
        {
            private readonly TableClient _sourceTable;
            private readonly TableClient _targetTable;

            public async Task MigrateAsync(CancellationToken cancellationToken)
            {
                var batch = new List<TableTransactionAction>();
                int migratedCount = 0;

                await foreach (var entity in _sourceTable.QueryAsync<TableEntity>(cancellationToken: cancellationToken))
                {
                    batch.Add(new TableTransactionAction(TableTransactionActionType.UpsertReplace, entity));

                    if (batch.Count >= 100)
                    {
                        // Group by partition key for batch operations
                        var groups = batch.GroupBy(a => ((TableEntity)a.Entity).PartitionKey);
                        foreach (var group in groups)
                        {
                            await _targetTable.SubmitTransactionAsync(group, cancellationToken);
                        }
                        migratedCount += batch.Count;
                        batch.Clear();
                        Console.WriteLine($"Migrated {migratedCount} entities");
                    }
                }

                // Process remaining
                if (batch.Any())
                {
                    var groups = batch.GroupBy(a => ((TableEntity)a.Entity).PartitionKey);
                    foreach (var group in groups)
                    {
                        await _targetTable.SubmitTransactionAsync(group, cancellationToken);
                    }
                }
            }
        }
        ```
        **Step 4: Update Connection String (No Code Changes)**
        ```csharp
        // Before (Table Storage)
        var connectionString = "DefaultEndpointsProtocol=https;AccountName=mystorage;AccountKey=...";

        // After (Cosmos DB Table API)
        var connectionString = "DefaultEndpointsProtocol=https;AccountName=mycosmosaccount;AccountKey=...;TableEndpoint=https://mycosmosaccount.table.cosmos.azure.com:443/;";

        // Same code works with both!
        var tableClient = new TableClient(connectionString, "orders");
        ```
        **References:**
        - [Cosmos DB Table API](https://learn.microsoft.com/en-us/azure/cosmos-db/table/introduction)
        - [Migrate to Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/import-data)

20. How do you implement entity versioning and audit trails?
    - **Answer:**
        Store entity versions using composite RowKeys with version numbers or timestamps. Maintain audit trail in separate partition or table for change history.
    - **Implementation:**
        **Step 1: Versioned Entity Pattern**
        ```csharp
        public class VersionedEntity<T> where T : class, ITableEntity, new()
        {
            private readonly TableClient _tableClient;

            public async Task<T> CreateVersionedAsync(T entity, string userId)
            {
                // Store current version
                entity.RowKey = $"{entity.RowKey}_v1";
                await _tableClient.AddEntityAsync(entity);

                // Store audit entry
                var audit = new AuditEntity
                {
                    PartitionKey = $"AUDIT_{entity.PartitionKey}",
                    RowKey = $"{DateTime.UtcNow:yyyyMMddHHmmssfff}",
                    EntityRowKey = entity.RowKey,
                    Action = "Created",
                    UserId = userId,
                    Changes = JsonSerializer.Serialize(entity)
                };
                await _tableClient.AddEntityAsync(audit);

                return entity;
            }

            public async Task<T> UpdateVersionedAsync(T entity, string userId)
            {
                // Parse current version
                var parts = entity.RowKey.Split("_v");
                var baseRowKey = parts[0];
                var currentVersion = int.Parse(parts[1]);

                // Create new version
                var newVersion = currentVersion + 1;
                entity.RowKey = $"{baseRowKey}_v{newVersion}";
                await _tableClient.AddEntityAsync(entity);

                // Archive old version
                var oldEntity = await _tableClient.GetEntityAsync<T>(
                    entity.PartitionKey, $"{baseRowKey}_v{currentVersion}");
                var archived = new TableEntity(
                    $"ARCHIVE_{entity.PartitionKey}",
                    $"{baseRowKey}_v{currentVersion}");
                // Copy properties...
                await _tableClient.AddEntityAsync(archived);
                await _tableClient.DeleteEntityAsync(entity.PartitionKey, $"{baseRowKey}_v{currentVersion}");

                // Store audit
                await CreateAuditEntryAsync(entity, "Updated", userId);

                return entity;
            }

            public async Task<List<T>> GetEntityHistoryAsync(string partitionKey, string baseRowKey)
            {
                var history = new List<T>();
                var filter = $"PartitionKey eq 'ARCHIVE_{partitionKey}' and RowKey ge '{baseRowKey}_v' and RowKey lt '{baseRowKey}_w'";

                await foreach (var entity in _tableClient.QueryAsync<T>(filter))
                {
                    history.Add(entity);
                }

                return history.OrderByDescending(e => e.RowKey).ToList();
            }
        }
        ```
        **Step 2: Temporal Table Pattern (Point-in-Time Queries)**
        ```csharp
        public class TemporalEntity : ITableEntity
        {
            public string PartitionKey { get; set; }
            public string RowKey { get; set; }  // EntityId_ValidFrom
            public DateTimeOffset ValidFrom { get; set; }
            public DateTimeOffset? ValidTo { get; set; }
            public string Data { get; set; }
            public DateTimeOffset? Timestamp { get; set; }
            public ETag ETag { get; set; }
        }

        public class TemporalRepository
        {
            public async Task<T> GetEntityAtTimeAsync<T>(
                string partitionKey,
                string entityId,
                DateTimeOffset asOfTime)
            {
                var filter = $"PartitionKey eq '{partitionKey}' and " +
                            $"RowKey ge '{entityId}_' and RowKey lt '{entityId}~' and " +
                            $"ValidFrom le datetime'{asOfTime:o}' and " +
                            $"(ValidTo eq null or ValidTo gt datetime'{asOfTime:o}')";

                await foreach (var entity in _tableClient.QueryAsync<TemporalEntity>(filter))
                {
                    return JsonSerializer.Deserialize<T>(entity.Data);
                }

                return default;
            }
        }
        ```
        **Step 3: Change Data Capture Pattern**
        ```csharp
        public class ChangeDataCapture
        {
            public async Task CaptureChangeAsync<T>(
                T oldEntity,
                T newEntity,
                string userId,
                string correlationId) where T : ITableEntity
            {
                var changes = GetChangedProperties(oldEntity, newEntity);

                var cdcEntry = new TableEntity($"CDC_{typeof(T).Name}", $"{DateTime.UtcNow.Ticks}")
                {
                    { "EntityPartitionKey", newEntity.PartitionKey },
                    { "EntityRowKey", newEntity.RowKey },
                    { "UserId", userId },
                    { "CorrelationId", correlationId },
                    { "Changes", JsonSerializer.Serialize(changes) },
                    { "OldValues", JsonSerializer.Serialize(oldEntity) },
                    { "NewValues", JsonSerializer.Serialize(newEntity) }
                };

                await _cdcTable.AddEntityAsync(cdcEntry);

                // Publish to Event Grid for real-time processing
                await _eventPublisher.PublishAsync(new EntityChangedEvent
                {
                    EntityType = typeof(T).Name,
                    PartitionKey = newEntity.PartitionKey,
                    RowKey = newEntity.RowKey,
                    Changes = changes
                });
            }

            private Dictionary<string, ChangeInfo> GetChangedProperties<T>(T old, T @new)
            {
                var changes = new Dictionary<string, ChangeInfo>();
                var properties = typeof(T).GetProperties();

                foreach (var prop in properties)
                {
                    var oldValue = prop.GetValue(old);
                    var newValue = prop.GetValue(@new);

                    if (!Equals(oldValue, newValue))
                    {
                        changes[prop.Name] = new ChangeInfo
                        {
                            OldValue = oldValue?.ToString(),
                            NewValue = newValue?.ToString()
                        };
                    }
                }

                return changes;
            }
        }
        ```
        **References:**
        - [Table Design Patterns](https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-design-patterns)
        - [Audit Trail Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing)

### 2.3 Azure Queue Storage
1. How do you implement reliable message processing?
    - **Answer:**
        Use dequeue count tracking, poison queues for failed messages, and retry logic with exponential backoff.
    - **Implementation:**
        **Step 1: Process Messages with Visibility Timeout**
        ```csharp
        using Azure.Storage.Queues;
        using Azure.Storage.Queues.Models;

        var queueClient = new QueueClient(connectionString, "myqueue");
        QueueMessage[] messages = await queueClient.ReceiveMessagesAsync(maxMessages: 10, visibilityTimeout: TimeSpan.FromMinutes(5));

        foreach (var message in messages)
        {
            try
            {
                await ProcessMessageAsync(message.Body.ToString());
                await queueClient.DeleteMessageAsync(message.MessageId, message.PopReceipt);
            }
            catch (Exception ex)
            {
                if (message.DequeueCount >= 5)
                {
                    // Move to poison queue
                    var poisonQueue = new QueueClient(connectionString, "myqueue-poison");
                    await poisonQueue.SendMessageAsync(message.Body);
                    await queueClient.DeleteMessageAsync(message.MessageId, message.PopReceipt);
                }
                // Message becomes visible again after timeout for retry
            }
        }
        ```
        **References:**
        - [Queue Storage Patterns](https://learn.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction)

2. How do you scale queue consumers?
    - **Answer:**
        Use Azure Functions with queue triggers that autoscale based on queue length.
    - **Implementation:**
        **Step 1: Azure Function with Queue Trigger**
        ```csharp
        [FunctionName("ProcessQueueMessage")]
        public static async Task Run(
            [QueueTrigger("myqueue", Connection = "AzureWebJobsStorage")] string message,
            ILogger log)
        {
            log.LogInformation($"Processing: {message}");
            await ProcessAsync(message);
        }
        ```
        **Step 2: Configure Scaling in host.json**
        ```json
        {
            "extensions": {
                "queues": {
                    "batchSize": 16,
                    "newBatchThreshold": 8,
                    "maxDequeueCount": 5,
                    "visibilityTimeout": "00:05:00"
                }
            }
        }
        ```
        **Step 3: Monitor Scale Events**
        - Azure Portal: Function App > Metrics > Scale controller logs
        **References:**
        - [Queue Trigger Scaling](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-queue-trigger)

3. How do you secure queue access?
    - **Answer:**
        Use SAS tokens for time-limited access, Azure AD with RBAC, and firewall rules.
    - **Implementation:**
        **Step 1: Generate SAS Token**
        ```csharp
        var sasBuilder = new QueueSasBuilder
        {
            QueueName = "myqueue",
            Resource = "q",
            ExpiresOn = DateTimeOffset.UtcNow.AddHours(1)
        };
        sasBuilder.SetPermissions(QueueSasPermissions.Process | QueueSasPermissions.Add);
        var sasToken = sasBuilder.ToSasQueryParameters(new StorageSharedKeyCredential(accountName, accountKey));
        ```
        **Step 2: Use Azure AD Authentication**
        ```csharp
        var queueClient = new QueueClient(
            new Uri($"https://{accountName}.queue.core.windows.net/myqueue"),
            new DefaultAzureCredential());
        ```
        **Step 3: Configure Firewall**
        ```sh
        az storage account network-rule add --resource-group myrg --account-name mystorage --ip-address 203.0.113.0/24
        ```
        **References:**
        - [Queue Storage Security](https://learn.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction#queue-storage-security)

4. How do you monitor queue length and activity?
    - **Answer:**
        Use Azure Monitor metrics for queue length, set up alerts, and review diagnostic logs.
    - **Implementation:**
        **Step 1: Get Queue Properties Programmatically**
        ```csharp
        var properties = await queueClient.GetPropertiesAsync();
        int approximateMessageCount = properties.Value.ApproximateMessagesCount;
        ```
        **Step 2: Query Queue Metrics (Kusto)**
        ```kusto
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.STORAGE"
        | where MetricName == "QueueMessageCount"
        | summarize avg(Average) by bin(TimeGenerated, 5m)
        ```
        **Step 3: Create Alert for Queue Backlog**
        - Azure Portal: Storage Account > Alerts > New alert rule
        - Condition: Queue Message Count > 1000
        **References:**
        - [Monitor Queue Storage](https://learn.microsoft.com/en-us/azure/storage/queues/monitor-queue-storage)

5. How do you handle message ordering?
    - **Answer:**
        Queue Storage does not guarantee ordering; use Service Bus with sessions for strict FIFO ordering.
    - **Implementation:**
        **Step 1: Understand Queue Behavior**
        ```csharp
        // Queue Storage: Best-effort FIFO, no strict guarantees
        await queueClient.SendMessageAsync("Message 1");
        await queueClient.SendMessageAsync("Message 2");
        // Messages may be processed out of order
        ```
        **Step 2: Add Sequence Number for Client-Side Ordering**
        ```csharp
        var message = new { SequenceNumber = 1, Data = "payload" };
        await queueClient.SendMessageAsync(JsonSerializer.Serialize(message));

        // Consumer sorts by sequence before processing
        var messages = receivedMessages.OrderBy(m => m.SequenceNumber);
        ```
        **Step 3: Use Service Bus for Strict Ordering**
        ```csharp
        // Service Bus with sessions guarantees FIFO within session
        var sender = serviceBusClient.CreateSender("myqueue");
        await sender.SendMessageAsync(new ServiceBusMessage("data") { SessionId = "order-123" });
        ```
        **References:**
        - [Queue vs Service Bus](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-azure-and-service-bus-queues-compared-contrasted)

6. How do you handle large messages?
    - **Answer:**
        Store payload in Blob Storage, put blob reference in queue message (claim check pattern).
    - **Implementation:**
        **Step 1: Upload Large Payload to Blob**
        ```csharp
        var blobClient = containerClient.GetBlobClient($"payloads/{Guid.NewGuid()}.json");
        await blobClient.UploadAsync(BinaryData.FromString(largePayload));
        ```
        **Step 2: Send Blob Reference in Queue**
        ```csharp
        var message = new { BlobUri = blobClient.Uri.ToString(), Metadata = "info" };
        await queueClient.SendMessageAsync(JsonSerializer.Serialize(message));
        ```
        **Step 3: Consumer Downloads Blob**
        ```csharp
        var queueMessage = await queueClient.ReceiveMessageAsync();
        var reference = JsonSerializer.Deserialize<MessageReference>(queueMessage.Value.Body.ToString());
        var blobClient = new BlobClient(new Uri(reference.BlobUri), new DefaultAzureCredential());
        var payload = await blobClient.DownloadContentAsync();
        ```
        **References:**
        - [Claim Check Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/claim-check)

7. How do you implement dead-lettering?
    - **Answer:**
        Move failed messages to a separate poison queue after maximum retry attempts.
    - **Implementation:**
        **Step 1: Create Poison Queue**
        ```csharp
        var poisonQueueClient = new QueueClient(connectionString, "myqueue-poison");
        await poisonQueueClient.CreateIfNotExistsAsync();
        ```
        **Step 2: Move Failed Messages**
        ```csharp
        var message = await queueClient.ReceiveMessageAsync();
        if (message.Value.DequeueCount > 5)
        {
            await poisonQueueClient.SendMessageAsync(message.Value.Body);
            await queueClient.DeleteMessageAsync(message.Value.MessageId, message.Value.PopReceipt);
            // Alert operations team
        }
        ```
        **Step 3: Azure Function Auto Dead-Letter**
        ```json
        // host.json - automatically moves to {queuename}-poison after maxDequeueCount
        {
            "extensions": {
                "queues": { "maxDequeueCount": 5 }
            }
        }
        ```
        **References:**
        - [Poison Message Handling](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-queue-trigger#poison-messages)

8. How do you automate queue creation?
    - **Answer:**
        Use ARM/Bicep templates, Azure CLI, or SDK for infrastructure as code.
    - **Implementation:**
        **Step 1: Create Queue with CLI**
        ```sh
        az storage queue create --name myqueue --account-name mystorage
        ```
        **Step 2: Bicep Template**
        ```bicep
        resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
            name: 'mystorage'
        }
        resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
            parent: storageAccount
            name: 'default'
        }
        resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
            parent: queueService
            name: 'myqueue'
        }
        ```
        **Step 3: Create with SDK**
        ```csharp
        var queueClient = new QueueClient(connectionString, "myqueue");
        await queueClient.CreateIfNotExistsAsync();
        ```
        **References:**
        - [Queue Storage ARM Template](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/queueservices/queues)

9. How do you handle duplicate messages?
    - **Answer:**
        Implement idempotent processing using message IDs or deduplication tracking.
    - **Implementation:**
        **Step 1: Track Processed Message IDs**
        ```csharp
        var processedIds = new HashSet<string>();  // Use Redis/Table Storage in production

        var message = await queueClient.ReceiveMessageAsync();
        if (processedIds.Contains(message.Value.MessageId))
        {
            await queueClient.DeleteMessageAsync(message.Value.MessageId, message.Value.PopReceipt);
            return;  // Skip duplicate
        }

        await ProcessAsync(message.Value.Body.ToString());
        processedIds.Add(message.Value.MessageId);
        await queueClient.DeleteMessageAsync(message.Value.MessageId, message.Value.PopReceipt);
        ```
        **Step 2: Idempotent Database Operations**
        ```csharp
        // Use UPSERT instead of INSERT to handle duplicates
        await dbContext.Database.ExecuteSqlRawAsync(
            "MERGE INTO Orders AS target USING ...");
        ```
        **References:**
        - [Idempotent Message Processing](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/serverless/event-processing)

10. How do you audit queue operations?
    - **Answer:**
        Enable diagnostic logging, send logs to Log Analytics, and review Activity Log.
    - **Implementation:**
        **Step 1: Enable Storage Diagnostics**
        ```sh
        az storage logging update --account-name mystorage --services q --log rwd --retention 30
        ```
        **Step 2: Query Queue Logs (Kusto)**
        ```kusto
        StorageQueueLogs
        | where AccountName == "mystorage"
        | where OperationName in ("PutMessage", "GetMessage", "DeleteMessage")
        | project TimeGenerated, CallerIpAddress, OperationName, StatusCode
        | order by TimeGenerated desc
        ```
        **References:**
        - [Storage Analytics Logging](https://learn.microsoft.com/en-us/azure/storage/common/storage-analytics-logging)

11. How do you optimize for cost?
    - **Answer:**
        Delete processed messages promptly, batch operations, and monitor transaction usage.
    - **Implementation:**
        **Step 1: Delete Messages Immediately After Processing**
        ```csharp
        var message = await queueClient.ReceiveMessageAsync();
        await ProcessAsync(message.Value.Body.ToString());
        await queueClient.DeleteMessageAsync(message.Value.MessageId, message.Value.PopReceipt);
        ```
        **Step 2: Batch Receive Messages**
        ```csharp
        // Receive up to 32 messages in one transaction
        var messages = await queueClient.ReceiveMessagesAsync(maxMessages: 32);
        ```
        **Step 3: Monitor Costs**
        - Azure Portal: Cost Management > Cost analysis > Filter by storage
        **References:**
        - [Queue Storage Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/queues/)

12. How do you integrate with Logic Apps?
    - **Answer:**
        Use built-in Azure Queue Storage connectors for triggers and actions.
    - **Implementation:**
        **Step 1: Queue Trigger in Logic App**
        - Logic App Designer > Add trigger > Azure Queues > When there are messages in a queue
        - Configure: Storage account, Queue name, Polling interval
        **Step 2: Send Message Action**
        - Add action > Azure Queues > Put a message on a queue
        - Configure message content with dynamic expressions
        **Step 3: Complete Message Flow**
        ```json
        {
            "triggers": {
                "When_messages_available": {
                    "type": "ApiConnection",
                    "inputs": {
                        "host": { "connection": { "name": "@parameters('$connections')['azurequeues']['connectionId']" } },
                        "method": "get",
                        "path": "/v2/storageAccounts/{storageAccountName}/queues/{queueName}/message_trigger"
                    }
                }
            }
        }
        ```
        **References:**
        - [Queue Storage Connector](https://learn.microsoft.com/en-us/connectors/azurequeues/)

13. How do you handle poison messages?
    - **Answer:**
        Move to poison queue after max retries, set up alerts, and investigate root cause.
    - **Implementation:**
        **Step 1: Configure Max Dequeue Count**
        ```json
        // host.json for Azure Functions
        {
            "extensions": {
                "queues": {
                    "maxDequeueCount": 5
                }
            }
        }
        ```
        **Step 2: Monitor Poison Queue**
        ```csharp
        var poisonQueue = new QueueClient(connectionString, "myqueue-poison");
        var props = await poisonQueue.GetPropertiesAsync();
        if (props.Value.ApproximateMessagesCount > 0)
        {
            // Send alert
            await alertService.SendAlertAsync($"Poison queue has {props.Value.ApproximateMessagesCount} messages");
        }
        ```
        **Step 3: Process Poison Queue Manually**
        ```csharp
        [FunctionName("ProcessPoisonQueue")]
        public static async Task Run(
            [QueueTrigger("myqueue-poison")] string message,
            ILogger log)
        {
            log.LogError($"Poison message: {message}");
            // Store for investigation, notify team
        }
        ```
        **References:**
        - [Poison Message Handling](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-queue-trigger#poison-messages)

14. How do you automate message processing?
    - **Answer:**
        Use Azure Functions, WebJobs, or Logic Apps for automated queue processing.
    - **Implementation:**
        **Step 1: Azure Function (Recommended)**
        ```csharp
        [FunctionName("ProcessOrder")]
        public static async Task Run(
            [QueueTrigger("orders")] string orderJson,
            [CosmosDB("mydb", "orders", Connection = "CosmosConnection")] IAsyncCollector<Order> orders,
            ILogger log)
        {
            var order = JsonSerializer.Deserialize<Order>(orderJson);
            await orders.AddAsync(order);
        }
        ```
        **Step 2: WebJob (Legacy)**
        ```csharp
        public static void ProcessQueueMessage([QueueTrigger("myqueue")] string message)
        {
            Console.WriteLine($"Processing: {message}");
        }
        ```
        **Step 3: Console App with Continuous Processing**
        ```csharp
        while (true)
        {
            var messages = await queueClient.ReceiveMessagesAsync(maxMessages: 10);
            foreach (var message in messages.Value)
            {
                await ProcessAsync(message);
                await queueClient.DeleteMessageAsync(message.MessageId, message.PopReceipt);
            }
            await Task.Delay(1000);
        }
        ```
        **References:**
        - [Queue Triggered Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-queue)

15. How do you test queue-based workflows?
    - **Answer:**
        Use Azurite (storage emulator) for local testing, integration tests with real queues in test environment.
    - **Implementation:**
        **Step 1: Run Azurite Locally**
        ```sh
        npm install -g azurite
        azurite --silent --location ./azurite-data --debug ./azurite-debug.log
        ```
        **Step 2: Configure Local Connection**
        ```json
        // local.settings.json
        {
            "Values": {
                "AzureWebJobsStorage": "UseDevelopmentStorage=true"
            }
        }
        ```
        **Step 3: Integration Test**
        ```csharp
        [Fact]
        public async Task ProcessMessage_ShouldComplete()
        {
            var queueClient = new QueueClient("UseDevelopmentStorage=true", "test-queue");
            await queueClient.CreateIfNotExistsAsync();
            await queueClient.SendMessageAsync("test-message");

            // Trigger function and verify processing
            var message = await queueClient.ReceiveMessageAsync();
            Assert.NotNull(message.Value);
        }
        ```
        **References:**
        - [Azurite Emulator](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite)

16. How do you implement the Claim Check pattern with Queue Storage?
    - **Answer:**
        Store large payloads in Blob Storage and send only a reference (claim check) via the queue. This avoids queue message size limits (64KB) and improves throughput.
    - **Implementation:**
        **Step 1: Implement Claim Check Publisher**
        ```csharp
        public class ClaimCheckPublisher
        {
            private readonly BlobContainerClient _blobContainer;
            private readonly QueueClient _queueClient;
            private const int MaxQueueMessageSize = 48 * 1024; // Leave room for encoding

            public async Task PublishAsync<T>(T payload)
            {
                var json = JsonSerializer.Serialize(payload);

                if (json.Length > MaxQueueMessageSize)
                {
                    // Store payload in blob
                    var blobId = Guid.NewGuid().ToString();
                    var blobClient = _blobContainer.GetBlobClient($"payloads/{blobId}.json");
                    await blobClient.UploadAsync(BinaryData.FromString(json));

                    // Send claim check reference
                    var claimCheck = new ClaimCheckMessage
                    {
                        BlobReference = blobClient.Uri.ToString(),
                        PayloadType = typeof(T).FullName,
                        CreatedAt = DateTimeOffset.UtcNow
                    };
                    await _queueClient.SendMessageAsync(
                        Convert.ToBase64String(Encoding.UTF8.GetBytes(
                            JsonSerializer.Serialize(claimCheck))));
                }
                else
                {
                    // Small enough - send directly
                    var message = new ClaimCheckMessage
                    {
                        InlinePayload = json,
                        PayloadType = typeof(T).FullName,
                        CreatedAt = DateTimeOffset.UtcNow
                    };
                    await _queueClient.SendMessageAsync(
                        Convert.ToBase64String(Encoding.UTF8.GetBytes(
                            JsonSerializer.Serialize(message))));
                }
            }
        }

        public class ClaimCheckMessage
        {
            public string BlobReference { get; set; }
            public string InlinePayload { get; set; }
            public string PayloadType { get; set; }
            public DateTimeOffset CreatedAt { get; set; }
        }
        ```
        **Step 2: Implement Claim Check Consumer**
        ```csharp
        public class ClaimCheckConsumer
        {
            private readonly BlobContainerClient _blobContainer;

            public async Task<T> RetrieveAsync<T>(ClaimCheckMessage claimCheck)
            {
                string json;

                if (!string.IsNullOrEmpty(claimCheck.BlobReference))
                {
                    // Retrieve from blob
                    var blobUri = new Uri(claimCheck.BlobReference);
                    var blobClient = _blobContainer.GetBlobClient(
                        blobUri.Segments.Last());

                    var response = await blobClient.DownloadContentAsync();
                    json = response.Value.Content.ToString();

                    // Delete blob after retrieval (optional)
                    await blobClient.DeleteAsync();
                }
                else
                {
                    json = claimCheck.InlinePayload;
                }

                return JsonSerializer.Deserialize<T>(json);
            }
        }
        ```
        **Step 3: Azure Function with Claim Check**
        ```csharp
        [Function("ProcessClaimCheck")]
        public async Task Run(
            [QueueTrigger("orders")] string messageJson,
            [Blob("payloads", Connection = "StorageConnection")] BlobContainerClient blobContainer)
        {
            var claimCheck = JsonSerializer.Deserialize<ClaimCheckMessage>(
                Encoding.UTF8.GetString(Convert.FromBase64String(messageJson)));

            var order = await _consumer.RetrieveAsync<LargeOrder>(claimCheck);
            await ProcessOrderAsync(order);
        }
        ```
        **References:**
        - [Claim Check Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/claim-check)

17. How do you implement priority queues with Azure Queue Storage?
    - **Answer:**
        Create separate queues for each priority level and process high-priority queues first. Use weighted processing or dedicated consumers for different priorities.
    - **Implementation:**
        **Step 1: Priority Queue Setup**
        ```csharp
        public class PriorityQueueService
        {
            private readonly Dictionary<Priority, QueueClient> _queues;

            public PriorityQueueService(string connectionString)
            {
                _queues = new Dictionary<Priority, QueueClient>
                {
                    [Priority.Critical] = new QueueClient(connectionString, "orders-critical"),
                    [Priority.High] = new QueueClient(connectionString, "orders-high"),
                    [Priority.Normal] = new QueueClient(connectionString, "orders-normal"),
                    [Priority.Low] = new QueueClient(connectionString, "orders-low")
                };

                foreach (var queue in _queues.Values)
                {
                    queue.CreateIfNotExists();
                }
            }

            public async Task EnqueueAsync<T>(T message, Priority priority)
            {
                var queue = _queues[priority];
                var json = JsonSerializer.Serialize(message);
                await queue.SendMessageAsync(Convert.ToBase64String(Encoding.UTF8.GetBytes(json)));
            }
        }

        public enum Priority { Critical = 0, High = 1, Normal = 2, Low = 3 }
        ```
        **Step 2: Weighted Priority Consumer**
        ```csharp
        public class PriorityQueueConsumer
        {
            private readonly Dictionary<Priority, (QueueClient Queue, int Weight)> _queues;

            public async Task ProcessMessagesAsync(CancellationToken cancellationToken)
            {
                while (!cancellationToken.IsCancellationRequested)
                {
                    bool processedAny = false;

                    // Process based on weight (Critical: 4, High: 2, Normal: 1, Low: 1)
                    processedAny |= await ProcessQueueAsync(Priority.Critical, 4, cancellationToken);
                    processedAny |= await ProcessQueueAsync(Priority.High, 2, cancellationToken);
                    processedAny |= await ProcessQueueAsync(Priority.Normal, 1, cancellationToken);
                    processedAny |= await ProcessQueueAsync(Priority.Low, 1, cancellationToken);

                    if (!processedAny)
                    {
                        await Task.Delay(1000, cancellationToken);
                    }
                }
            }

            private async Task<bool> ProcessQueueAsync(
                Priority priority, int maxMessages, CancellationToken ct)
            {
                var messages = await _queues[priority].Queue
                    .ReceiveMessagesAsync(maxMessages, cancellationToken: ct);

                foreach (var msg in messages.Value)
                {
                    await ProcessMessageAsync(msg);
                    await _queues[priority].Queue.DeleteMessageAsync(msg.MessageId, msg.PopReceipt);
                }

                return messages.Value.Any();
            }
        }
        ```
        **Step 3: Azure Function with Priority Processing**
        ```csharp
        // Separate functions with different batch sizes based on priority
        [Function("ProcessCriticalOrders")]
        public async Task ProcessCritical(
            [QueueTrigger("orders-critical")] string[] messages)
        {
            // Process immediately with full resources
            await Parallel.ForEachAsync(messages, async (msg, ct) =>
            {
                await ProcessOrderAsync(msg, Priority.Critical);
            });
        }

        [Function("ProcessNormalOrders")]
        public async Task ProcessNormal(
            [QueueTrigger("orders-normal")] string message)
        {
            // Process sequentially
            await ProcessOrderAsync(message, Priority.Normal);
        }

        // host.json configuration
        // {
        //     "extensions": {
        //         "queues": {
        //             "batchSize": 32,
        //             "newBatchThreshold": 16,
        //             "queues": ["orders-critical", "orders-high", "orders-normal", "orders-low"]
        //         }
        //     }
        // }
        ```
        **References:**
        - [Priority Queue Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/priority-queue)

18. How do you implement message deduplication with Queue Storage?
    - **Answer:**
        Implement idempotency using message IDs stored in a deduplication store (Redis, Table Storage). Check for duplicates before processing.
    - **Implementation:**
        **Step 1: Deduplication Service**
        ```csharp
        public class MessageDeduplicationService
        {
            private readonly TableClient _deduplicationTable;
            private readonly TimeSpan _deduplicationWindow = TimeSpan.FromHours(24);

            public async Task<bool> TryProcessAsync(string messageId, Func<Task> processAction)
            {
                // Try to claim the message
                var dedupEntity = new TableEntity("DEDUP", messageId)
                {
                    { "ProcessedAt", DateTimeOffset.UtcNow },
                    { "ExpiresAt", DateTimeOffset.UtcNow.Add(_deduplicationWindow) }
                };

                try
                {
                    await _deduplicationTable.AddEntityAsync(dedupEntity);

                    // Successfully claimed - process
                    try
                    {
                        await processAction();
                        await MarkCompletedAsync(messageId);
                        return true;
                    }
                    catch
                    {
                        // Processing failed - remove claim to allow retry
                        await _deduplicationTable.DeleteEntityAsync("DEDUP", messageId);
                        throw;
                    }
                }
                catch (RequestFailedException ex) when (ex.Status == 409)
                {
                    // Already processed or being processed
                    var existing = await _deduplicationTable.GetEntityAsync<TableEntity>("DEDUP", messageId);
                    if (existing.Value.GetString("Status") == "Completed")
                    {
                        return false; // Already successfully processed
                    }

                    // Check if stale claim
                    var processedAt = existing.Value.GetDateTimeOffset("ProcessedAt");
                    if (processedAt?.AddMinutes(10) < DateTimeOffset.UtcNow)
                    {
                        // Stale claim - try to take over
                        await _deduplicationTable.DeleteEntityAsync("DEDUP", messageId, existing.Value.ETag);
                        return await TryProcessAsync(messageId, processAction);
                    }

                    return false;
                }
            }

            private async Task MarkCompletedAsync(string messageId)
            {
                var entity = new TableEntity("DEDUP", messageId)
                {
                    { "Status", "Completed" },
                    { "CompletedAt", DateTimeOffset.UtcNow }
                };
                await _deduplicationTable.UpdateEntityAsync(entity, ETag.All, TableUpdateMode.Merge);
            }
        }
        ```
        **Step 2: Use with Azure Function**
        ```csharp
        [Function("ProcessOrderIdempotent")]
        public async Task Run(
            [QueueTrigger("orders")] QueueMessage message,
            FunctionContext context)
        {
            var messageId = $"{message.MessageId}_{message.DequeueCount}";

            var processed = await _deduplicationService.TryProcessAsync(
                messageId,
                async () =>
                {
                    var order = JsonSerializer.Deserialize<Order>(message.Body);
                    await ProcessOrderAsync(order);
                });

            if (!processed)
            {
                _logger.LogInformation($"Message {messageId} already processed, skipping");
            }
        }
        ```
        **Step 3: Redis-Based Deduplication (Higher Performance)**
        ```csharp
        public class RedisDeduplicationService
        {
            private readonly IDatabase _redis;

            public async Task<bool> TryClaimAsync(string messageId, TimeSpan window)
            {
                // SETNX with expiration
                return await _redis.StringSetAsync(
                    $"dedup:{messageId}",
                    DateTimeOffset.UtcNow.ToString("O"),
                    window,
                    When.NotExists);
            }

            public async Task ReleaseClaimAsync(string messageId)
            {
                await _redis.KeyDeleteAsync($"dedup:{messageId}");
            }
        }
        ```
        **References:**
        - [Idempotent Consumer Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/idempotent-consumer)

19. How do you implement scheduled/delayed messages with Queue Storage?
    - **Answer:**
        Use the visibility timeout parameter to delay message availability. Messages become visible only after the specified delay period.
    - **Implementation:**
        **Step 1: Send Delayed Message**
        ```csharp
        public class DelayedMessageService
        {
            private readonly QueueClient _queueClient;

            public async Task SendDelayedAsync<T>(T message, TimeSpan delay)
            {
                if (delay > TimeSpan.FromDays(7))
                {
                    throw new ArgumentException("Maximum delay is 7 days");
                }

                var json = JsonSerializer.Serialize(new DelayedMessage<T>
                {
                    Payload = message,
                    ScheduledFor = DateTimeOffset.UtcNow.Add(delay),
                    CreatedAt = DateTimeOffset.UtcNow
                });

                await _queueClient.SendMessageAsync(
                    Convert.ToBase64String(Encoding.UTF8.GetBytes(json)),
                    visibilityTimeout: delay);
            }

            public async Task ScheduleAtAsync<T>(T message, DateTimeOffset executeAt)
            {
                var delay = executeAt - DateTimeOffset.UtcNow;
                if (delay <= TimeSpan.Zero)
                {
                    delay = TimeSpan.Zero; // Execute immediately
                }
                await SendDelayedAsync(message, delay);
            }
        }

        public class DelayedMessage<T>
        {
            public T Payload { get; set; }
            public DateTimeOffset ScheduledFor { get; set; }
            public DateTimeOffset CreatedAt { get; set; }
        }
        ```
        **Step 2: Long-Term Scheduling (Beyond 7 Days)**
        ```csharp
        public class LongTermScheduler
        {
            private readonly TableClient _scheduleTable;
            private readonly QueueClient _queueClient;

            public async Task ScheduleLongTermAsync<T>(T message, DateTimeOffset executeAt)
            {
                if (executeAt - DateTimeOffset.UtcNow <= TimeSpan.FromDays(7))
                {
                    // Within queue visibility timeout limit
                    await SendDelayedAsync(message, executeAt - DateTimeOffset.UtcNow);
                }
                else
                {
                    // Store in table for later queuing
                    var scheduleEntry = new TableEntity(
                        executeAt.ToString("yyyyMMdd"),
                        Guid.NewGuid().ToString())
                    {
                        { "ExecuteAt", executeAt },
                        { "Payload", JsonSerializer.Serialize(message) },
                        { "PayloadType", typeof(T).FullName },
                        { "Status", "Scheduled" }
                    };
                    await _scheduleTable.AddEntityAsync(scheduleEntry);
                }
            }

            // Timer-triggered function to move scheduled items to queue
            [Function("ProcessScheduledMessages")]
            public async Task ProcessScheduled([TimerTrigger("0 */5 * * * *")] TimerInfo timer)
            {
                var now = DateTimeOffset.UtcNow;
                var filter = $"ExecuteAt le datetime'{now:o}' and Status eq 'Scheduled'";

                await foreach (var entry in _scheduleTable.QueryAsync<TableEntity>(filter))
                {
                    var executeAt = entry.GetDateTimeOffset("ExecuteAt").Value;
                    var delay = executeAt > now ? executeAt - now : TimeSpan.Zero;

                    await _queueClient.SendMessageAsync(
                        entry.GetString("Payload"),
                        visibilityTimeout: delay);

                    entry["Status"] = "Queued";
                    await _scheduleTable.UpdateEntityAsync(entry, entry.ETag);
                }
            }
        }
        ```
        **Step 3: Recurring Schedule Pattern**
        ```csharp
        public class RecurringScheduler
        {
            public async Task ScheduleRecurringAsync<T>(
                T message,
                string cronExpression,
                DateTimeOffset? endDate = null)
            {
                var cron = CronExpression.Parse(cronExpression);
                var next = cron.GetNextOccurrence(DateTimeOffset.UtcNow);

                while (next.HasValue && (endDate == null || next <= endDate))
                {
                    var scheduleEntry = new TableEntity("RECURRING", Guid.NewGuid().ToString())
                    {
                        { "ExecuteAt", next.Value },
                        { "CronExpression", cronExpression },
                        { "Payload", JsonSerializer.Serialize(message) },
                        { "EndDate", endDate }
                    };
                    await _scheduleTable.AddEntityAsync(scheduleEntry);

                    next = cron.GetNextOccurrence(next.Value);
                }
            }
        }
        ```
        **References:**
        - [Queue Message Visibility](https://learn.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction)

20. How do you monitor Queue Storage health and performance?
    - **Answer:**
        Use Azure Monitor metrics for queue length, message counts, and latency. Set up alerts for queue depth and implement custom telemetry for processing metrics.
    - **Implementation:**
        **Step 1: Query Queue Metrics**
        ```sh
        # Get queue message count
        az storage queue metadata show --name orders --account-name mystorageaccount --query approximateMessageCount

        # Monitor via Azure Monitor
        az monitor metrics list \
            --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount/queueServices/default \
            --metric QueueMessageCount \
            --interval PT1M
        ```
        **Step 2: Create Alerts for Queue Depth**
        ```sh
        az monitor metrics alert create \
            --name "QueueDepthAlert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount/queueServices/default \
            --condition "avg QueueMessageCount > 1000" \
            --window-size 5m \
            --evaluation-frequency 1m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/myactiongroup
        ```
        **Step 3: Implement Custom Telemetry**
        ```csharp
        public class QueueMonitor
        {
            private readonly QueueClient _queueClient;
            private readonly TelemetryClient _telemetry;

            public async Task EmitMetricsAsync()
            {
                var properties = await _queueClient.GetPropertiesAsync();
                var messageCount = properties.Value.ApproximateMessagesCount;

                _telemetry.TrackMetric("QueueMessageCount", messageCount, new Dictionary<string, string>
                {
                    ["QueueName"] = _queueClient.Name,
                    ["StorageAccount"] = _queueClient.AccountName
                });

                // Track processing rate
                _telemetry.TrackMetric("MessagesProcessedPerMinute", _processedCount, new Dictionary<string, string>
                {
                    ["QueueName"] = _queueClient.Name
                });
            }

            public async Task<QueueHealthReport> GetHealthReportAsync()
            {
                var properties = await _queueClient.GetPropertiesAsync();

                return new QueueHealthReport
                {
                    QueueName = _queueClient.Name,
                    ApproximateMessageCount = properties.Value.ApproximateMessagesCount,
                    IsHealthy = properties.Value.ApproximateMessagesCount < 10000,
                    Timestamp = DateTimeOffset.UtcNow
                };
            }
        }
        ```
        **Step 4: KQL Query for Queue Analytics**
        ```kusto
        // Queue processing latency
        customMetrics
        | where name == "QueueProcessingTime"
        | summarize avg(value), percentile(value, 95), max(value) by bin(timestamp, 5m)
        | render timechart

        // Dead letter queue growth
        customMetrics
        | where name == "QueueMessageCount"
        | where customDimensions.QueueName endswith "-poison"
        | summarize maxCount = max(value) by bin(timestamp, 1h), tostring(customDimensions.QueueName)

        // Processing throughput
        customMetrics
        | where name == "MessagesProcessedPerMinute"
        | summarize sum(value) by bin(timestamp, 1h)
        | render columnchart
        ```
        **Step 5: Azure Function with Processing Metrics**
        ```csharp
        [Function("ProcessOrderWithMetrics")]
        public async Task Run(
            [QueueTrigger("orders")] QueueMessage message,
            FunctionContext context)
        {
            var stopwatch = Stopwatch.StartNew();

            try
            {
                var order = JsonSerializer.Deserialize<Order>(message.Body);
                await ProcessOrderAsync(order);

                _telemetry.TrackEvent("OrderProcessed", new Dictionary<string, string>
                {
                    ["OrderId"] = order.Id,
                    ["DequeueCount"] = message.DequeueCount.ToString()
                });

                _telemetry.TrackMetric("QueueProcessingTime", stopwatch.ElapsedMilliseconds);
            }
            catch (Exception ex)
            {
                _telemetry.TrackException(ex);
                _telemetry.TrackMetric("QueueProcessingErrors", 1);
                throw;
            }
        }
        ```
        **References:**
        - [Monitor Queue Storage](https://learn.microsoft.com/en-us/azure/storage/queues/monitor-queue-storage)
        - [Storage Analytics](https://learn.microsoft.com/en-us/azure/storage/common/storage-analytics)

### 2.4 Azure File Storage
1. How do you mount Azure File shares on Windows/Linux?
    - **Answer:**
        Use SMB protocol with storage account key, Azure AD credentials, or identity-based authentication.
    - **Implementation:**
        **Step 1: Mount on Windows (PowerShell)**
        ```powershell
        $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName "myrg" -Name "mystorage")[0].Value
        $connectTestResult = Test-NetConnection -ComputerName mystorage.file.core.windows.net -Port 445
        if ($connectTestResult.TcpTestSucceeded) {
            cmd.exe /C "cmdkey /add:mystorage.file.core.windows.net /user:Azure\mystorage /pass:$storageAccountKey"
            New-PSDrive -Name Z -PSProvider FileSystem -Root "\\mystorage.file.core.windows.net\myshare" -Persist
        }
        ```
        **Step 2: Mount on Linux**
        ```sh
        sudo mkdir /mnt/myshare
        sudo mount -t cifs //mystorage.file.core.windows.net/myshare /mnt/myshare -o vers=3.0,username=mystorage,password=<account-key>,dir_mode=0777,file_mode=0777
        ```
        **Step 3: Persistent Mount (Linux fstab)**
        ```sh
        # /etc/fstab entry
        //mystorage.file.core.windows.net/myshare /mnt/myshare cifs vers=3.0,credentials=/etc/smbcredentials/mystorage.cred,dir_mode=0777,file_mode=0777 0 0
        ```
        **References:**
        - [Mount Azure Files on Windows](https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows)

2. How do you secure file shares?
    - **Answer:**
        Use private endpoints, firewall rules, Azure AD DS authentication, and SMB encryption.
    - **Implementation:**
        **Step 1: Enable Private Endpoint**
        ```sh
        az network private-endpoint create --resource-group myrg --name myfilepe --vnet-name myvnet --subnet mysubnet --private-connection-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorage --group-id file --connection-name myconnection
        ```
        **Step 2: Configure Firewall**
        ```sh
        az storage account network-rule add --resource-group myrg --account-name mystorage --ip-address 203.0.113.0/24
        az storage account update --resource-group myrg --name mystorage --default-action Deny
        ```
        **Step 3: Enable Azure AD DS Authentication**
        ```sh
        az storage account update --resource-group myrg --name mystorage --enable-files-aadds true
        ```
        **References:**
        - [Azure Files Security](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-networking-overview)

3. How do you monitor file share usage?
    - **Answer:**
        Use Azure Monitor metrics for capacity, transactions, and set up alerts for quota limits.
    - **Implementation:**
        **Step 1: View Metrics in Portal**
        - Storage Account > Monitoring > Metrics > Select File Capacity, Transactions
        **Step 2: Query Usage (Kusto)**
        ```kusto
        StorageFileLogs
        | where AccountName == "mystorage"
        | summarize TotalOperations = count() by OperationName, bin(TimeGenerated, 1h)
        ```
        **Step 3: Create Capacity Alert**
        - Azure Monitor > Alerts > New alert rule
        - Condition: File Capacity > 90% of quota
        **References:**
        - [Monitor Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-monitoring)

4. How do you automate file share creation?
    - **Answer:**
        Use ARM/Bicep templates, Azure CLI, or PowerShell for infrastructure as code.
    - **Implementation:**
        **Step 1: Create with Azure CLI**
        ```sh
        az storage share create --name myshare --account-name mystorage --quota 100
        ```
        **Step 2: Bicep Template**
        ```bicep
        resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
            name: 'mystorage'
        }
        resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
            parent: storageAccount
            name: 'default'
        }
        resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
            parent: fileService
            name: 'myshare'
            properties: {
                shareQuota: 100
                accessTier: 'Hot'
            }
        }
        ```
        **References:**
        - [File Share ARM Template](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileservices/shares)

5. How do you backup file shares?
    - **Answer:**
        Use Azure Backup service with Recovery Services vault, configure backup policies and retention.
    - **Implementation:**
        **Step 1: Create Recovery Services Vault**
        ```sh
        az backup vault create --resource-group myrg --name myvault --location eastus
        ```
        **Step 2: Enable Backup for File Share**
        ```sh
        az backup protection enable-for-azurefileshare --resource-group myrg --vault-name myvault --storage-account mystorage --azure-file-share myshare --policy-name DefaultPolicy
        ```
        **Step 3: Trigger Manual Backup**
        ```sh
        az backup protection backup-now --resource-group myrg --vault-name myvault --container-name "StorageContainer;storage;myrg;mystorage" --item-name myshare
        ```
        **References:**
        - [Azure Files Backup](https://learn.microsoft.com/en-us/azure/backup/azure-file-share-backup-overview)

6. How do you restore deleted files?
    - **Answer:**
        Use soft delete feature for share snapshots, or restore individual files from backup.
    - **Implementation:**
        **Step 1: Enable Soft Delete**
        ```sh
        az storage account file-service-properties update --resource-group myrg --account-name mystorage --enable-delete-retention true --delete-retention-days 14
        ```
        **Step 2: List Deleted Shares**
        ```sh
        az storage share list --account-name mystorage --include-deleted
        ```
        **Step 3: Restore from Backup**
        - Azure Portal: Recovery Services Vault > Backup items > Azure File Share > Restore
        **Step 4: Restore Specific File from Snapshot**
        - Storage Account > File shares > myshare > Snapshots > Browse and restore
        **References:**
        - [Soft Delete for Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-enable-soft-delete)

7. How do you optimize for cost?
    - **Answer:**
        Use appropriate access tiers (Hot/Cool/Transaction Optimized), monitor usage, and delete unused data.
    - **Implementation:**
        **Step 1: Set Access Tier**
        ```sh
        az storage share update --name myshare --account-name mystorage --access-tier Cool
        ```
        **Step 2: Monitor Usage**
        - Azure Portal: Storage Account > Metrics > File Capacity
        **Step 3: Clean Up Unused Files (PowerShell)**
        ```powershell
        $ctx = New-AzStorageContext -StorageAccountName "mystorage" -StorageAccountKey $key
        Get-AzStorageFile -ShareName "myshare" -Context $ctx | Where-Object { $_.LastModified -lt (Get-Date).AddDays(-365) } | Remove-AzStorageFile
        ```
        **References:**
        - [Azure Files Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/files/)

8. How do you handle large file transfers?
    - **Answer:**
        Use AzCopy for efficient parallel transfers, robocopy for incremental sync, or Data Box for offline migration.
    - **Implementation:**
        **Step 1: AzCopy Upload**
        ```sh
        azcopy copy "/local/path/*" "https://mystorage.file.core.windows.net/myshare?<sas>" --recursive
        ```
        **Step 2: AzCopy Sync (Incremental)**
        ```sh
        azcopy sync "/local/path" "https://mystorage.file.core.windows.net/myshare?<sas>" --recursive
        ```
        **Step 3: Robocopy for Windows**
        ```sh
        robocopy C:\LocalFolder Z:\RemoteShare /MIR /MT:8 /R:3 /W:10
        ```
        **References:**
        - [AzCopy with Azure Files](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-files)

9. How do you integrate with on-premises?
    - **Answer:**
        Use Azure File Sync for hybrid scenarios with local caching and cloud tiering.
    - **Implementation:**
        **Step 1: Create Storage Sync Service**
        ```sh
        az storagesync create --resource-group myrg --name mysync --location eastus
        ```
        **Step 2: Create Sync Group**
        ```sh
        az storagesync sync-group create --resource-group myrg --storage-sync-service mysync --name mysyncgroup
        ```
        **Step 3: Install Azure File Sync Agent on Server**
        - Download from Microsoft, install on Windows Server
        - Register server with Storage Sync Service
        **Step 4: Create Server Endpoint**
        ```sh
        az storagesync server-endpoint create --resource-group myrg --storage-sync-service mysync --sync-group-name mysyncgroup --name myserverendpoint --server-id <server-id> --server-local-path "D:\Sync" --cloud-tiering on --volume-free-space-percent 20
        ```
        **References:**
        - [Azure File Sync](https://learn.microsoft.com/en-us/azure/storage/file-sync/file-sync-deployment-guide)

10. How do you audit access?
    - **Answer:**
        Enable diagnostic logging, send to Log Analytics, and review storage access patterns.
    - **Implementation:**
        **Step 1: Enable Diagnostics**
        ```sh
        az monitor diagnostic-settings create --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorage/fileServices/default --name mydiag --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true}]' --workspace <workspace-id>
        ```
        **Step 2: Query Access Logs (Kusto)**
        ```kusto
        StorageFileLogs
        | where AccountName == "mystorage"
        | where OperationName in ("ReadFile", "WriteFile", "DeleteFile")
        | project TimeGenerated, CallerIpAddress, OperationName, Uri
        | order by TimeGenerated desc
        ```
        **References:**
        - [Azure Files Logging](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-monitoring)

11. How do you enforce quotas?
    - **Answer:**
        Set share quota limits at creation or update, monitor usage to prevent exceeding limits.
    - **Implementation:**
        **Step 1: Set Quota at Creation**
        ```sh
        az storage share create --name myshare --account-name mystorage --quota 500  # 500 GB
        ```
        **Step 2: Update Existing Share Quota**
        ```sh
        az storage share update --name myshare --account-name mystorage --quota 1000  # Increase to 1 TB
        ```
        **Step 3: Monitor Quota Usage (C#)**
        ```csharp
        var shareClient = new ShareClient(connectionString, "myshare");
        var props = await shareClient.GetPropertiesAsync();
        Console.WriteLine($"Used: {props.Value.ShareUsageInBytes} / Quota: {props.Value.QuotaInGB} GB");
        ```
        **References:**
        - [File Share Quotas](https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share)

12. How do you automate file uploads/downloads?
    - **Answer:**
        Use AzCopy, PowerShell, Azure CLI, or SDK in scripts and CI/CD pipelines.
    - **Implementation:**
        **Step 1: Upload with Azure CLI**
        ```sh
        az storage file upload --share-name myshare --source /local/file.txt --path remote/file.txt --account-name mystorage
        ```
        **Step 2: Download with PowerShell**
        ```powershell
        $ctx = New-AzStorageContext -StorageAccountName "mystorage" -StorageAccountKey $key
        Get-AzStorageFileContent -ShareName "myshare" -Path "remote/file.txt" -Destination "C:\local\file.txt" -Context $ctx
        ```
        **Step 3: SDK Upload (C#)**
        ```csharp
        var shareClient = new ShareClient(connectionString, "myshare");
        var directoryClient = shareClient.GetDirectoryClient("mydir");
        var fileClient = directoryClient.GetFileClient("file.txt");
        using var stream = File.OpenRead("local/file.txt");
        await fileClient.CreateAsync(stream.Length);
        await fileClient.UploadAsync(stream);
        ```
        **References:**
        - [Azure Files SDK](https://learn.microsoft.com/en-us/azure/storage/files/storage-dotnet-how-to-use-files)

13. How do you handle file locking?
    - **Answer:**
        SMB protocol provides opportunistic locks (oplocks) and lease-based locking for concurrent access.
    - **Implementation:**
        **Step 1: Understand SMB Locking**
        - SMB oplocks allow caching and exclusive access
        - Shared locks allow multiple readers
        - Exclusive locks for write operations
        **Step 2: Handle Lock Conflicts in Code**
        ```csharp
        try
        {
            using var stream = new FileStream(@"\\mystorage.file.core.windows.net\myshare\file.txt",
                FileMode.Open, FileAccess.ReadWrite, FileShare.None);  // Exclusive lock
            // Work with file
        }
        catch (IOException ex) when (ex.HResult == -2147024864)  // Sharing violation
        {
            Console.WriteLine("File is locked by another process");
            // Implement retry logic
        }
        ```
        **Step 3: Use Advisory Locks for Coordination**
        ```csharp
        var lockFile = $"{filePath}.lock";
        while (File.Exists(lockFile))
        {
            await Task.Delay(100);  // Wait for lock release
        }
        File.Create(lockFile).Dispose();  // Acquire lock
        // Process file
        File.Delete(lockFile);  // Release lock
        ```
        **References:**
        - [SMB File Locking](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-smb-overview)

14. How do you manage access keys securely?
    - **Answer:**
        Store keys in Key Vault, rotate regularly, use RBAC and managed identities where possible.
    - **Implementation:**
        **Step 1: Store Key in Key Vault**
        ```sh
        az keyvault secret set --vault-name myvault --name StorageKey --value "<storage-account-key>"
        ```
        **Step 2: Rotate Keys Regularly**
        ```sh
        az storage account keys renew --resource-group myrg --account-name mystorage --key primary
        # Update Key Vault secret after rotation
        ```
        **Step 3: Use RBAC Instead of Keys**
        ```sh
        az role assignment create --role "Storage File Data SMB Share Contributor" --assignee <user-principal-id> --scope /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorage
        ```
        **References:**
        - [Azure Files Authentication](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-active-directory-enable)

15. How do you test file share access?
    - **Answer:**
        Use Azurite emulator for local testing, or create test shares in development storage accounts.
    - **Implementation:**
        **Step 1: Run Azurite**
        ```sh
        npm install -g azurite
        azurite --silent --location ./azurite-data
        ```
        **Step 2: Connect to Local Emulator**
        ```csharp
        var connectionString = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=...;FileEndpoint=http://127.0.0.1:10000/devstoreaccount1;";
        var shareClient = new ShareClient(connectionString, "testshare");
        await shareClient.CreateIfNotExistsAsync();
        ```
        **Step 3: Integration Test**
        ```csharp
        [Fact]
        public async Task CanUploadAndDownloadFile()
        {
            var fileClient = directoryClient.GetFileClient("test.txt");
            await fileClient.CreateAsync(1024);
            await fileClient.UploadAsync(BinaryData.FromString("test content"));

            var download = await fileClient.DownloadAsync();
            Assert.Equal("test content", download.Value.Content.ToString());
        }
        ```
        **References:**
        - [Azurite Emulator](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite)

16. How do you implement Azure File Sync for hybrid scenarios?
    - **Answer:**
        Azure File Sync extends Azure Files to on-premises Windows servers, enabling centralized file storage with local caching for fast access. Supports cloud tiering and multi-site sync.
    - **Implementation:**
        **Step 1: Create Storage Sync Service**
        ```sh
        az storagesync create \
            --resource-group myrg \
            --name myfilesync \
            --location eastus
        ```
        **Step 2: Create Sync Group and Cloud Endpoint**
        ```sh
        # Create sync group
        az storagesync sync-group create \
            --resource-group myrg \
            --storage-sync-service myfilesync \
            --name mysyncgroup

        # Add cloud endpoint (Azure File Share)
        az storagesync sync-group cloud-endpoint create \
            --resource-group myrg \
            --storage-sync-service myfilesync \
            --sync-group-name mysyncgroup \
            --name mycloudendpoint \
            --storage-account-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount \
            --azure-file-share-name myfileshare
        ```
        **Step 3: Register Server and Create Server Endpoint**
        ```powershell
        # Install Azure File Sync agent on Windows Server
        # Download from: https://go.microsoft.com/fwlink/?linkid=858257

        # Register server with Storage Sync Service
        Register-AzStorageSyncServer -ResourceGroupName "myrg" -StorageSyncServiceName "myfilesync"

        # Create server endpoint
        New-AzStorageSyncServerEndpoint `
            -ResourceGroupName "myrg" `
            -StorageSyncServiceName "myfilesync" `
            -SyncGroupName "mysyncgroup" `
            -ServerLocalPath "D:\SyncFolder" `
            -CloudTiering `
            -VolumeFreeSpacePercent 20 `
            -TierFilesOlderThanDays 30
        ```
        **Step 4: Configure Cloud Tiering**
        ```powershell
        # Enable cloud tiering with date and volume policies
        Set-AzStorageSyncServerEndpoint `
            -ResourceGroupName "myrg" `
            -StorageSyncServiceName "myfilesync" `
            -SyncGroupName "mysyncgroup" `
            -ServerEndpointName "myserverendpoint" `
            -CloudTiering `
            -VolumeFreeSpacePercent 20 `
            -TierFilesOlderThanDays 60 `
            -LocalCacheMode DownloadNewAndModifiedFiles
        ```
        **Step 5: Monitor Sync Status**
        ```powershell
        # Check sync status
        Get-AzStorageSyncServerEndpoint `
            -ResourceGroupName "myrg" `
            -StorageSyncServiceName "myfilesync" `
            -SyncGroupName "mysyncgroup" | Select SyncStatus, HealthStatus

        # View detailed sync activity
        Invoke-AzStorageSyncFileRecall -Path "D:\SyncFolder\ImportantFile.docx"
        ```
        **References:**
        - [Azure File Sync Overview](https://learn.microsoft.com/en-us/azure/storage/file-sync/file-sync-introduction)
        - [Deploy Azure File Sync](https://learn.microsoft.com/en-us/azure/storage/file-sync/file-sync-deployment-guide)

17. How do you implement NFS access for Azure Files?
    - **Answer:**
        Azure Files supports NFS 4.1 protocol for Linux clients. Requires Premium file shares and private endpoint for secure access (NFS doesn't support encryption in transit).
    - **Implementation:**
        **Step 1: Create Premium File Share with NFS**
        ```sh
        # Create storage account (Premium required for NFS)
        az storage account create \
            --name mynfsstorage \
            --resource-group myrg \
            --location eastus \
            --sku Premium_LRS \
            --kind FileStorage \
            --enable-large-file-share

        # Create NFS file share
        az storage share-rm create \
            --resource-group myrg \
            --storage-account mynfsstorage \
            --name nfsshare \
            --enabled-protocol NFS \
            --root-squash NoRootSquash \
            --quota 100
        ```
        **Step 2: Configure Private Endpoint (Required for NFS)**
        ```sh
        # Create private endpoint
        az network private-endpoint create \
            --resource-group myrg \
            --name nfs-private-endpoint \
            --vnet-name myvnet \
            --subnet mysubnet \
            --private-connection-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mynfsstorage \
            --group-id file \
            --connection-name nfs-connection

        # Create private DNS zone
        az network private-dns zone create \
            --resource-group myrg \
            --name privatelink.file.core.windows.net

        az network private-dns link vnet create \
            --resource-group myrg \
            --zone-name privatelink.file.core.windows.net \
            --name nfs-dns-link \
            --virtual-network myvnet \
            --registration-enabled false

        az network private-endpoint dns-zone-group create \
            --resource-group myrg \
            --endpoint-name nfs-private-endpoint \
            --name nfs-dns-group \
            --private-dns-zone privatelink.file.core.windows.net \
            --zone-name file
        ```
        **Step 3: Mount NFS Share on Linux**
        ```sh
        # Install NFS client
        sudo apt-get install nfs-common

        # Create mount point
        sudo mkdir -p /mnt/nfsshare

        # Mount NFS share
        sudo mount -t nfs mynfsstorage.privatelink.file.core.windows.net:/mynfsstorage/nfsshare /mnt/nfsshare -o vers=4,minorversion=1,sec=sys

        # Add to /etc/fstab for persistence
        echo "mynfsstorage.privatelink.file.core.windows.net:/mynfsstorage/nfsshare /mnt/nfsshare nfs vers=4,minorversion=1,sec=sys 0 0" | sudo tee -a /etc/fstab
        ```
        **Step 4: Bicep Template for NFS Setup**
        ```bicep
        resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
            name: 'mynfsstorage'
            location: resourceGroup().location
            sku: { name: 'Premium_LRS' }
            kind: 'FileStorage'
            properties: {
                supportsHttpsTrafficOnly: false  // NFS doesn't use HTTPS
                networkAcls: {
                    defaultAction: 'Deny'
                    bypass: 'None'
                }
            }
        }

        resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
            name: '${storageAccount.name}/default/nfsshare'
            properties: {
                shareQuota: 100
                enabledProtocols: 'NFS'
                rootSquash: 'NoRootSquash'
            }
        }
        ```
        **References:**
        - [NFS Azure File Shares](https://learn.microsoft.com/en-us/azure/storage/files/files-nfs-protocol)
        - [Create NFS Share](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-how-to-create-nfs-shares)

18. How do you implement snapshot management for Azure Files?
    - **Answer:**
        Share snapshots provide point-in-time copies of Azure file shares for backup and recovery. They are incremental (only changed data is stored) and can be automated.
    - **Implementation:**
        **Step 1: Create Share Snapshot**
        ```sh
        # Create snapshot
        az storage share snapshot \
            --name myfileshare \
            --account-name mystorageaccount \
            --account-key <storage-key>

        # Create with metadata
        az storage share snapshot \
            --name myfileshare \
            --account-name mystorageaccount \
            --metadata "reason=daily-backup" "createdBy=automation"
        ```
        **Step 2: List and Manage Snapshots**
        ```sh
        # List all snapshots
        az storage share list \
            --account-name mystorageaccount \
            --include-snapshot \
            --query "[?snapshot!=null]"

        # Delete specific snapshot
        az storage share delete \
            --name myfileshare \
            --snapshot "2024-01-15T10:30:00.0000000Z" \
            --account-name mystorageaccount
        ```
        **Step 3: C# SDK for Snapshot Operations**
        ```csharp
        using Azure.Storage.Files.Shares;

        public class FileShareSnapshotService
        {
            private readonly ShareClient _shareClient;

            public async Task<ShareSnapshotInfo> CreateSnapshotAsync(
                Dictionary<string, string> metadata = null)
            {
                var response = await _shareClient.CreateSnapshotAsync(metadata);
                return response.Value;
            }

            public async Task<List<ShareItem>> ListSnapshotsAsync()
            {
                var snapshots = new List<ShareItem>();
                var serviceClient = new ShareServiceClient(_connectionString);

                await foreach (var share in serviceClient.GetSharesAsync(
                    ShareTraits.Metadata,
                    ShareStates.Snapshots))
                {
                    if (share.Name == _shareClient.Name && share.IsDeleted != true)
                    {
                        snapshots.Add(share);
                    }
                }

                return snapshots.OrderByDescending(s => s.Snapshot).ToList();
            }

            public async Task RestoreFileFromSnapshotAsync(
                string snapshotTimestamp,
                string filePath,
                string destinationPath)
            {
                // Get file from snapshot
                var snapshotShare = _shareClient.WithSnapshot(snapshotTimestamp);
                var snapshotFile = snapshotShare.GetRootDirectoryClient()
                    .GetFileClient(filePath);

                // Copy to current share
                var destFile = _shareClient.GetRootDirectoryClient()
                    .GetFileClient(destinationPath);

                await destFile.StartCopyAsync(snapshotFile.Uri);
            }

            public async Task DeleteOldSnapshotsAsync(int retentionDays)
            {
                var cutoffDate = DateTimeOffset.UtcNow.AddDays(-retentionDays);
                var snapshots = await ListSnapshotsAsync();

                foreach (var snapshot in snapshots.Where(s =>
                    DateTimeOffset.Parse(s.Snapshot) < cutoffDate))
                {
                    var snapshotShare = _shareClient.WithSnapshot(snapshot.Snapshot);
                    await snapshotShare.DeleteAsync();
                }
            }
        }
        ```
        **Step 4: Automated Snapshot with Azure Function**
        ```csharp
        [Function("AutomatedFileShareSnapshot")]
        public async Task Run([TimerTrigger("0 0 2 * * *")] TimerInfo timer)
        {
            var metadata = new Dictionary<string, string>
            {
                ["type"] = "automated",
                ["createdAt"] = DateTimeOffset.UtcNow.ToString("o")
            };

            await _snapshotService.CreateSnapshotAsync(metadata);

            // Cleanup old snapshots (keep 30 days)
            await _snapshotService.DeleteOldSnapshotsAsync(30);

            _logger.LogInformation($"Snapshot created and cleanup completed");
        }
        ```
        **References:**
        - [Share Snapshots](https://learn.microsoft.com/en-us/azure/storage/files/storage-snapshots-files)
        - [Restore from Snapshot](https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-portal#restore-from-a-share-snapshot)

19. How do you implement Azure Files backup with Azure Backup?
    - **Answer:**
        Azure Backup provides enterprise-grade backup for Azure Files with configurable retention, recovery points, and instant restore capabilities.
    - **Implementation:**
        **Step 1: Create Recovery Services Vault**
        ```sh
        az backup vault create \
            --resource-group myrg \
            --name myrecoveryvault \
            --location eastus
        ```
        **Step 2: Enable Backup for File Share**
        ```sh
        # Register storage account
        az backup container register \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --backup-management-type AzureStorage \
            --storage-account mystorageaccount

        # Enable protection
        az backup protection enable-for-azurefileshare \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --storage-account mystorageaccount \
            --azure-file-share myfileshare \
            --policy-name EnhancedPolicy
        ```
        **Step 3: Create Custom Backup Policy**
        ```sh
        az backup policy create \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --name DailyFileShareBackup \
            --backup-management-type AzureStorage \
            --workload-type AzureFileShare \
            --policy '{
                "schedulePolicy": {
                    "schedulePolicyType": "SimpleSchedulePolicy",
                    "scheduleRunFrequency": "Daily",
                    "scheduleRunTimes": ["2024-01-01T02:00:00Z"]
                },
                "retentionPolicy": {
                    "retentionPolicyType": "LongTermRetentionPolicy",
                    "dailySchedule": {
                        "retentionTimes": ["2024-01-01T02:00:00Z"],
                        "retentionDuration": { "count": 30, "durationType": "Days" }
                    },
                    "weeklySchedule": {
                        "daysOfTheWeek": ["Sunday"],
                        "retentionTimes": ["2024-01-01T02:00:00Z"],
                        "retentionDuration": { "count": 12, "durationType": "Weeks" }
                    },
                    "monthlySchedule": {
                        "retentionScheduleFormatType": "Weekly",
                        "retentionScheduleWeekly": {
                            "daysOfTheWeek": ["Sunday"],
                            "weeksOfTheMonth": ["First"]
                        },
                        "retentionDuration": { "count": 12, "durationType": "Months" }
                    }
                }
            }'
        ```
        **Step 4: Restore Files**
        ```sh
        # List recovery points
        az backup recoverypoint list \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --container-name "StorageContainer;storage;myrg;mystorageaccount" \
            --item-name "AzureFileShare;myfileshare" \
            --backup-management-type AzureStorage

        # Full share restore
        az backup restore restore-azurefileshare \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --rp-name <recovery-point-name> \
            --container-name "StorageContainer;storage;myrg;mystorageaccount" \
            --item-name "AzureFileShare;myfileshare" \
            --restore-mode OriginalLocation \
            --resolve-conflict Overwrite

        # Item-level restore
        az backup restore restore-azurefiles \
            --vault-name myrecoveryvault \
            --resource-group myrg \
            --rp-name <recovery-point-name> \
            --container-name "StorageContainer;storage;myrg;mystorageaccount" \
            --item-name "AzureFileShare;myfileshare" \
            --source-file-path "folder/file.txt" \
            --restore-mode OriginalLocation
        ```
        **Step 5: Bicep Template for Backup Configuration**
        ```bicep
        resource vault 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
            name: 'myrecoveryvault'
            location: resourceGroup().location
            sku: { name: 'RS0', tier: 'Standard' }
        }

        resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-01-01' = {
            parent: vault
            name: 'FileShareBackupPolicy'
            properties: {
                backupManagementType: 'AzureStorage'
                workloadType: 'AzureFileShare'
                schedulePolicy: {
                    schedulePolicyType: 'SimpleSchedulePolicy'
                    scheduleRunFrequency: 'Daily'
                    scheduleRunTimes: ['2024-01-01T02:00:00Z']
                }
                retentionPolicy: {
                    retentionPolicyType: 'LongTermRetentionPolicy'
                    dailySchedule: {
                        retentionTimes: ['2024-01-01T02:00:00Z']
                        retentionDuration: { count: 30, durationType: 'Days' }
                    }
                }
            }
        }
        ```
        **References:**
        - [Azure Files Backup](https://learn.microsoft.com/en-us/azure/backup/azure-file-share-backup-overview)
        - [Restore Azure Files](https://learn.microsoft.com/en-us/azure/backup/restore-afs)

20. How do you implement performance optimization for Azure Files?
    - **Answer:**
        Optimize Azure Files performance by choosing appropriate tier (Standard/Premium), configuring proper IOPS/throughput, using SMB Multichannel, and implementing caching strategies.
    - **Implementation:**
        **Step 1: Choose Appropriate Tier and Size**
        ```sh
        # Premium file share for high IOPS workloads
        az storage account create \
            --name mypremiumstorage \
            --resource-group myrg \
            --location eastus \
            --sku Premium_LRS \
            --kind FileStorage

        # Larger shares = more IOPS (1 IOPS per GiB baseline, up to 100,000 IOPS)
        az storage share-rm create \
            --resource-group myrg \
            --storage-account mypremiumstorage \
            --name highperfshare \
            --quota 1024 \
            --enabled-protocol SMB
        ```
        **Step 2: Enable SMB Multichannel (Premium)**
        ```sh
        az storage account file-service-properties update \
            --account-name mypremiumstorage \
            --resource-group myrg \
            --enable-smb-multichannel
        ```
        **Step 3: Configure Large File Shares (Standard)**
        ```sh
        # Enable large file shares for up to 100 TiB
        az storage account update \
            --name mystorageaccount \
            --resource-group myrg \
            --enable-large-file-share
        ```
        **Step 4: Optimize Mount Options**
        ```sh
        # Linux mount with performance options
        sudo mount -t cifs //mystorageaccount.file.core.windows.net/myshare /mnt/share \
            -o username=mystorageaccount,password=<key>,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30,mfsymlinks

        # Windows mount with larger cache
        net use Z: \\mystorageaccount.file.core.windows.net\myshare /user:Azure\mystorageaccount <key>

        # PowerShell with specific SMB settings
        New-SmbMapping -LocalPath "Z:" -RemotePath "\\mystorageaccount.file.core.windows.net\myshare" -UserName "Azure\mystorageaccount" -Password (ConvertTo-SecureString "<key>" -AsPlainText -Force)
        ```
        **Step 5: Monitor Performance Metrics**
        ```kusto
        // Azure Files performance metrics
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.STORAGE"
        | where MetricName in ("FileShareSuccessServerLatency", "FileShareSuccessE2ELatency", "Transactions")
        | summarize avg(Average), max(Maximum) by bin(TimeGenerated, 5m), MetricName
        | render timechart

        // Identify throttling
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.STORAGE"
        | where MetricName == "Transactions"
        | where ResponseType contains "Throttling"
        | summarize count() by bin(TimeGenerated, 1h)
        ```
        **Step 6: Application-Level Optimization**
        ```csharp
        public class OptimizedFileShareClient
        {
            private readonly ShareClient _shareClient;
            private readonly IMemoryCache _metadataCache;

            public async Task<byte[]> ReadFileWithCachingAsync(string filePath)
            {
                var cacheKey = $"file:{filePath}:etag";

                // Check cache for unchanged file
                if (_metadataCache.TryGetValue(cacheKey, out string cachedETag))
                {
                    var fileClient = _shareClient.GetRootDirectoryClient()
                        .GetFileClient(filePath);
                    var properties = await fileClient.GetPropertiesAsync();

                    if (properties.Value.ETag.ToString() == cachedETag)
                    {
                        // File unchanged, return cached data
                        return _metadataCache.Get<byte[]>($"file:{filePath}:content");
                    }
                }

                // Download and cache
                var file = _shareClient.GetRootDirectoryClient().GetFileClient(filePath);
                var download = await file.DownloadAsync();

                using var memoryStream = new MemoryStream();
                await download.Value.Content.CopyToAsync(memoryStream);
                var content = memoryStream.ToArray();

                var props = await file.GetPropertiesAsync();
                _metadataCache.Set($"file:{filePath}:etag", props.Value.ETag.ToString(), TimeSpan.FromMinutes(5));
                _metadataCache.Set($"file:{filePath}:content", content, TimeSpan.FromMinutes(5));

                return content;
            }

            // Parallel upload for large files
            public async Task UploadLargeFileAsync(string localPath, string remotePath)
            {
                var fileClient = _shareClient.GetRootDirectoryClient().GetFileClient(remotePath);
                var fileInfo = new FileInfo(localPath);

                await fileClient.CreateAsync(fileInfo.Length);

                const int chunkSize = 4 * 1024 * 1024; // 4 MB chunks
                var chunks = (int)Math.Ceiling((double)fileInfo.Length / chunkSize);

                await Parallel.ForEachAsync(
                    Enumerable.Range(0, chunks),
                    new ParallelOptions { MaxDegreeOfParallelism = 4 },
                    async (i, ct) =>
                    {
                        var offset = (long)i * chunkSize;
                        var length = Math.Min(chunkSize, fileInfo.Length - offset);

                        using var stream = new FileStream(localPath, FileMode.Open, FileAccess.Read, FileShare.Read);
                        stream.Seek(offset, SeekOrigin.Begin);
                        var buffer = new byte[length];
                        await stream.ReadAsync(buffer, 0, (int)length, ct);

                        await fileClient.UploadRangeAsync(
                            new HttpRange(offset, length),
                            new MemoryStream(buffer));
                    });
            }
        }
        ```
        **References:**
        - [Azure Files Performance](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-scale-targets)
        - [SMB Multichannel](https://learn.microsoft.com/en-us/azure/storage/files/files-smb-protocol#smb-multichannel)


## 2.5 Azure Cosmos DB

### 2.5.1 Core Concepts & Operations
1. How do you choose the right partition key for Cosmos DB?
    - **Answer:**
        Choose a partition key with high cardinality, even distribution, and alignment with query patterns. Avoid hot partitions by selecting keys that spread data evenly.
    - **Implementation:**
        **Step 1: Analyze Access Patterns**
        ```csharp
        // Good partition key examples:
        // - UserId for user-centric data
        // - TenantId for multi-tenant apps
        // - DeviceId for IoT scenarios
        // - OrderDate (year-month) for time-series with date range queries

        public class Order
        {
            [JsonProperty("id")]
            public string Id { get; set; }

            [JsonProperty("customerId")]  // Good partition key - high cardinality
            public string CustomerId { get; set; }

            public string ProductName { get; set; }
            public decimal Amount { get; set; }
        }
        ```
        **Step 2: Create Container with Partition Key**
        ```sh
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --partition-key-path "/customerId" --throughput 400
        ```
        **Step 3: Avoid Anti-Patterns**
        ```csharp
        // BAD: Low cardinality (only few values)
        // partitionKey: "/status"  // Only "pending", "completed", "cancelled"

        // BAD: Monotonically increasing
        // partitionKey: "/timestamp"  // Creates hot partition

        // GOOD: Synthetic partition key for flexibility
        public string PartitionKey => $"{CustomerId}-{OrderDate:yyyy-MM}";
        ```
        **References:**
        - [Partition Key Best Practices](https://learn.microsoft.com/en-us/azure/cosmos-db/partitioning-overview)

2. How do you implement CRUD operations in Cosmos DB?
    - **Answer:**
        Use the Cosmos DB SDK with Container methods for Create, Read, Update, Delete operations with proper partition key usage.
    - **Implementation:**
        **Step 1: Setup Cosmos Client**
        ```csharp
        using Microsoft.Azure.Cosmos;

        var cosmosClient = new CosmosClient(connectionString);
        var database = cosmosClient.GetDatabase("mydb");
        var container = database.GetContainer("orders");
        ```
        **Step 2: Create (Insert) Document**
        ```csharp
        var order = new Order { Id = Guid.NewGuid().ToString(), CustomerId = "C001", ProductName = "Laptop", Amount = 999.99m };
        var response = await container.CreateItemAsync(order, new PartitionKey(order.CustomerId));
        Console.WriteLine($"Created item. RU charge: {response.RequestCharge}");
        ```
        **Step 3: Read (Point Read - Most Efficient)**
        ```csharp
        var response = await container.ReadItemAsync<Order>("order-id", new PartitionKey("C001"));
        Console.WriteLine($"Read item. RU charge: {response.RequestCharge}");
        ```
        **Step 4: Update (Replace)**
        ```csharp
        order.Amount = 899.99m;
        var response = await container.ReplaceItemAsync(order, order.Id, new PartitionKey(order.CustomerId));
        ```
        **Step 5: Delete**
        ```csharp
        await container.DeleteItemAsync<Order>("order-id", new PartitionKey("C001"));
        ```
        **Step 6: Upsert (Create or Update)**
        ```csharp
        var response = await container.UpsertItemAsync(order, new PartitionKey(order.CustomerId));
        ```
        **References:**
        - [Cosmos DB CRUD Operations](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/how-to-dotnet-create-item)

3. How do you query data efficiently in Cosmos DB?
    - **Answer:**
        Use SQL queries with partition key filters for single-partition queries, avoid cross-partition queries, and use indexing effectively.
    - **Implementation:**
        **Step 1: Single-Partition Query (Efficient)**
        ```csharp
        var query = new QueryDefinition("SELECT * FROM c WHERE c.customerId = @customerId AND c.amount > @minAmount")
            .WithParameter("@customerId", "C001")
            .WithParameter("@minAmount", 100);

        var iterator = container.GetItemQueryIterator<Order>(query, requestOptions: new QueryRequestOptions
        {
            PartitionKey = new PartitionKey("C001"),
            MaxItemCount = 100
        });

        while (iterator.HasMoreResults)
        {
            var response = await iterator.ReadNextAsync();
            Console.WriteLine($"RU charge: {response.RequestCharge}");
            foreach (var order in response) { /* process */ }
        }
        ```
        **Step 2: Cross-Partition Query (Use Sparingly)**
        ```csharp
        var query = new QueryDefinition("SELECT * FROM c WHERE c.productName = @product")
            .WithParameter("@product", "Laptop");

        var options = new QueryRequestOptions { MaxConcurrency = -1 };  // Parallel execution
        var iterator = container.GetItemQueryIterator<Order>(query, requestOptions: options);
        ```
        **Step 3: Use LINQ for Type Safety**
        ```csharp
        using Microsoft.Azure.Cosmos.Linq;

        var orders = container.GetItemLinqQueryable<Order>()
            .Where(o => o.CustomerId == "C001" && o.Amount > 100)
            .ToFeedIterator();
        ```
        **Step 4: Pagination**
        ```csharp
        string continuationToken = null;
        do
        {
            var response = await iterator.ReadNextAsync();
            continuationToken = response.ContinuationToken;
            // Process items
        } while (continuationToken != null);
        ```
        **References:**
        - [Query Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/query/getting-started)

4. How do you implement change feed processing?
    - **Answer:**
        Use Change Feed Processor to react to document changes in real-time for event-driven architectures.
    - **Implementation:**
        **Step 1: Create Lease Container**
        ```sh
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name leases --partition-key-path "/id"
        ```
        **Step 2: Setup Change Feed Processor**
        ```csharp
        var leaseContainer = database.GetContainer("leases");

        var changeFeedProcessor = container
            .GetChangeFeedProcessorBuilder<Order>("orderProcessor", HandleChangesAsync)
            .WithInstanceName("instance1")
            .WithLeaseContainer(leaseContainer)
            .WithStartTime(DateTime.UtcNow.AddHours(-1))  // Start from 1 hour ago
            .Build();

        await changeFeedProcessor.StartAsync();
        ```
        **Step 3: Handle Changes**
        ```csharp
        static async Task HandleChangesAsync(
            ChangeFeedProcessorContext context,
            IReadOnlyCollection<Order> changes,
            CancellationToken cancellationToken)
        {
            Console.WriteLine($"Partition: {context.LeaseToken}, Changes: {changes.Count}");
            foreach (var order in changes)
            {
                Console.WriteLine($"Order {order.Id} changed: {order.Amount}");
                // Process change: send notification, update cache, sync to other systems
            }
        }
        ```
        **Step 4: Azure Function with Change Feed Trigger**
        ```csharp
        [FunctionName("OrderChangeFeed")]
        public static void Run(
            [CosmosDBTrigger(
                databaseName: "mydb",
                containerName: "orders",
                Connection = "CosmosConnection",
                LeaseContainerName = "leases",
                CreateLeaseContainerIfNotExists = true)]
            IReadOnlyList<Order> changes,
            ILogger log)
        {
            foreach (var order in changes)
            {
                log.LogInformation($"Order changed: {order.Id}");
            }
        }
        ```
        **References:**
        - [Change Feed Processor](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/change-feed-processor)

5. How do you handle transactions in Cosmos DB?
    - **Answer:**
        Use TransactionalBatch for ACID transactions within a single partition key. All operations succeed or fail together.
    - **Implementation:**
        **Step 1: Create Transactional Batch**
        ```csharp
        var partitionKey = new PartitionKey("C001");

        var order = new Order { Id = "order-1", CustomerId = "C001", Amount = 100 };
        var orderItem = new OrderItem { Id = "item-1", CustomerId = "C001", ProductId = "P001", Quantity = 2 };

        var batch = container.CreateTransactionalBatch(partitionKey)
            .CreateItem(order)
            .CreateItem(orderItem)
            .ReplaceItem("existing-order-id", updatedOrder)
            .DeleteItem("old-item-id");

        using var response = await batch.ExecuteAsync();

        if (response.IsSuccessStatusCode)
        {
            Console.WriteLine($"Transaction succeeded. RU: {response.RequestCharge}");
        }
        else
        {
            Console.WriteLine($"Transaction failed: {response.StatusCode}");
        }
        ```
        **Step 2: Handle Batch Results**
        ```csharp
        for (int i = 0; i < response.Count; i++)
        {
            var result = response.GetOperationResultAtIndex<dynamic>(i);
            Console.WriteLine($"Operation {i}: {result.StatusCode}");
        }
        ```
        **Step 3: Optimistic Concurrency with ETags**
        ```csharp
        var readResponse = await container.ReadItemAsync<Order>("order-1", partitionKey);
        var etag = readResponse.ETag;

        var options = new ItemRequestOptions { IfMatchEtag = etag };
        try
        {
            await container.ReplaceItemAsync(updatedOrder, "order-1", partitionKey, options);
        }
        catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.PreconditionFailed)
        {
            Console.WriteLine("Conflict: Document was modified by another process");
        }
        ```
        **References:**
        - [Transactional Batch](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/transactional-batch)

6. How do you configure and manage throughput (RU/s)?
    - **Answer:**
        Choose between provisioned throughput (dedicated RU/s) or serverless, use autoscale for variable workloads, and monitor RU consumption.
    - **Implementation:**
        **Step 1: Create Container with Provisioned Throughput**
        ```sh
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --partition-key-path "/customerId" --throughput 1000
        ```
        **Step 2: Enable Autoscale**
        ```sh
        az cosmosdb sql container throughput migrate --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --throughput-type autoscale
        az cosmosdb sql container throughput update --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --max-throughput 10000
        ```
        **Step 3: Monitor RU Usage (C#)**
        ```csharp
        var response = await container.CreateItemAsync(order, new PartitionKey(order.CustomerId));
        Console.WriteLine($"RU Charge: {response.RequestCharge}");

        // For queries
        double totalRU = 0;
        var iterator = container.GetItemQueryIterator<Order>(query);
        while (iterator.HasMoreResults)
        {
            var result = await iterator.ReadNextAsync();
            totalRU += result.RequestCharge;
        }
        Console.WriteLine($"Total Query RU: {totalRU}");
        ```
        **Step 4: Query RU Metrics (Kusto)**
        ```kusto
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.DOCUMENTDB"
        | where MetricName == "TotalRequestUnits"
        | summarize sum(Total) by bin(TimeGenerated, 1h)
        ```
        **References:**
        - [Throughput Management](https://learn.microsoft.com/en-us/azure/cosmos-db/set-throughput)

7. How do you implement global distribution and multi-region writes?
    - **Answer:**
        Enable geo-replication for read scaling and disaster recovery, configure multi-region writes for low-latency writes globally.
    - **Implementation:**
        **Step 1: Add Read Regions**
        ```sh
        az cosmosdb update --resource-group myrg --name mycosmosaccount --locations regionName=eastus failoverPriority=0 --locations regionName=westus failoverPriority=1 --locations regionName=westeurope failoverPriority=2
        ```
        **Step 2: Enable Multi-Region Writes**
        ```sh
        az cosmosdb update --resource-group myrg --name mycosmosaccount --enable-multiple-write-locations true
        ```
        **Step 3: Configure Client for Preferred Regions**
        ```csharp
        var cosmosClient = new CosmosClient(connectionString, new CosmosClientOptions
        {
            ApplicationRegion = Regions.WestUS,  // Nearest region
            // Or for multi-region writes:
            ApplicationPreferredRegions = new List<string> { Regions.WestUS, Regions.EastUS }
        });
        ```
        **Step 4: Handle Conflict Resolution**
        ```sh
        # Last Writer Wins (default)
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --partition-key-path "/customerId" --conflict-resolution-policy-mode LastWriterWins --conflict-resolution-policy-path "/_ts"
        ```
        **References:**
        - [Global Distribution](https://learn.microsoft.com/en-us/azure/cosmos-db/distribute-data-globally)

8. How do you secure Cosmos DB access?
    - **Answer:**
        Use Azure AD RBAC for identity-based access, private endpoints for network isolation, and encryption at rest/in transit.
    - **Implementation:**
        **Step 1: Enable Azure AD Authentication**
        ```sh
        az cosmosdb update --resource-group myrg --name mycosmosaccount --enable-automatic-failover true
        ```
        **Step 2: Assign RBAC Role**
        ```sh
        az cosmosdb sql role assignment create --resource-group myrg --account-name mycosmosaccount --role-definition-id "00000000-0000-0000-0000-000000000002" --principal-id <user-or-sp-object-id> --scope "/dbs/mydb/colls/orders"
        ```
        **Step 3: Use Managed Identity (C#)**
        ```csharp
        var cosmosClient = new CosmosClient(
            "https://mycosmosaccount.documents.azure.com:443/",
            new DefaultAzureCredential());
        ```
        **Step 4: Configure Private Endpoint**
        ```sh
        az network private-endpoint create --resource-group myrg --name mycosmospe --vnet-name myvnet --subnet mysubnet --private-connection-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.DocumentDB/databaseAccounts/mycosmosaccount --group-id Sql --connection-name myconnection
        ```
        **Step 5: Disable Public Access**
        ```sh
        az cosmosdb update --resource-group myrg --name mycosmosaccount --enable-public-network false
        ```
        **References:**
        - [Cosmos DB Security](https://learn.microsoft.com/en-us/azure/cosmos-db/secure-access-to-data)

9. How do you implement indexing strategies?
    - **Answer:**
        Customize indexing policy to include/exclude paths, optimize for query patterns, and reduce RU costs for writes.
    - **Implementation:**
        **Step 1: Default Indexing (All Paths)**
        ```json
        {
            "indexingMode": "consistent",
            "automatic": true,
            "includedPaths": [{ "path": "/*" }],
            "excludedPaths": [{ "path": "/\"_etag\"/?" }]
        }
        ```
        **Step 2: Selective Indexing for Write-Heavy Workloads**
        ```json
        {
            "indexingMode": "consistent",
            "automatic": true,
            "includedPaths": [
                { "path": "/customerId/?" },
                { "path": "/orderDate/?" },
                { "path": "/status/?" }
            ],
            "excludedPaths": [
                { "path": "/*" },
                { "path": "/metadata/*" }
            ]
        }
        ```
        **Step 3: Add Composite Index for ORDER BY**
        ```json
        {
            "indexingMode": "consistent",
            "includedPaths": [{ "path": "/*" }],
            "compositeIndexes": [
                [
                    { "path": "/customerId", "order": "ascending" },
                    { "path": "/orderDate", "order": "descending" }
                ]
            ]
        }
        ```
        **Step 4: Update Indexing Policy (CLI)**
        ```sh
        az cosmosdb sql container update --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --idx @indexing-policy.json
        ```
        **References:**
        - [Indexing Policies](https://learn.microsoft.com/en-us/azure/cosmos-db/index-policy)

10. How do you handle Time-to-Live (TTL) for automatic data expiration?
    - **Answer:**
        Enable TTL at container level and set per-item TTL values for automatic document expiration and cleanup.
    - **Implementation:**
        **Step 1: Enable TTL on Container**
        ```sh
        az cosmosdb sql container update --resource-group myrg --account-name mycosmosaccount --database-name mydb --name sessions --ttl 3600  # 1 hour default
        ```
        **Step 2: Set Item-Level TTL (C#)**
        ```csharp
        public class Session
        {
            [JsonProperty("id")]
            public string Id { get; set; }

            [JsonProperty("ttl")]
            public int TimeToLive { get; set; }  // Seconds until expiration

            public string UserId { get; set; }
            public DateTime CreatedAt { get; set; }
        }

        var session = new Session
        {
            Id = Guid.NewGuid().ToString(),
            UserId = "user-123",
            TimeToLive = 1800,  // 30 minutes
            CreatedAt = DateTime.UtcNow
        };
        await container.CreateItemAsync(session, new PartitionKey(session.UserId));
        ```
        **Step 3: Disable TTL for Specific Item**
        ```csharp
        var permanentItem = new Session
        {
            Id = "permanent-session",
            TimeToLive = -1,  // Never expires
            UserId = "admin"
        };
        ```
        **References:**
        - [Time to Live](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/time-to-live)

11. How do you implement stored procedures, triggers, and UDFs?
    - **Answer:**
        Use server-side programming for complex transactions, pre/post triggers for validation, and UDFs for custom query logic.
    - **Implementation:**
        **Step 1: Create Stored Procedure**
        ```javascript
        // bulkDelete.js
        function bulkDelete(query) {
            var context = getContext();
            var container = context.getCollection();
            var response = context.getResponse();
            var deleted = 0;

            container.queryDocuments(container.getSelfLink(), query, {},
                function(err, documents) {
                    if (err) throw err;
                    documents.forEach(function(doc) {
                        container.deleteDocument(doc._self, {}, function(err) {
                            if (err) throw err;
                            deleted++;
                        });
                    });
                    response.setBody({ deleted: deleted });
                });
        }
        ```
        **Step 2: Register Stored Procedure**
        ```csharp
        var spDefinition = new StoredProcedureProperties
        {
            Id = "bulkDelete",
            Body = File.ReadAllText("bulkDelete.js")
        };
        await container.Scripts.CreateStoredProcedureAsync(spDefinition);
        ```
        **Step 3: Execute Stored Procedure**
        ```csharp
        var result = await container.Scripts.ExecuteStoredProcedureAsync<dynamic>(
            "bulkDelete",
            new PartitionKey("C001"),
            new[] { "SELECT * FROM c WHERE c.status = 'cancelled'" });
        Console.WriteLine($"Deleted: {result.Resource.deleted}");
        ```
        **Step 4: Create Pre-Trigger for Validation**
        ```javascript
        function validateOrder() {
            var context = getContext();
            var request = context.getRequest();
            var doc = request.getBody();

            if (!doc.customerId) {
                throw new Error("customerId is required");
            }
            if (doc.amount < 0) {
                throw new Error("amount cannot be negative");
            }
            doc.createdAt = new Date().toISOString();
            request.setBody(doc);
        }
        ```
        **References:**
        - [Server-Side Programming](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/stored-procedures-triggers-udfs)

12. How do you monitor and troubleshoot Cosmos DB performance?
    - **Answer:**
        Use Azure Monitor metrics, diagnostic logs, Query Insights, and analyze RU consumption patterns.
    - **Implementation:**
        **Step 1: Enable Diagnostics**
        ```sh
        az monitor diagnostic-settings create --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.DocumentDB/databaseAccounts/mycosmosaccount --name mydiag --logs '[{"category":"DataPlaneRequests","enabled":true},{"category":"QueryRuntimeStatistics","enabled":true}]' --workspace <workspace-id>
        ```
        **Step 2: Query Slow Operations (Kusto)**
        ```kusto
        CDBDataPlaneRequests
        | where TimeGenerated > ago(1h)
        | where DurationMs > 100
        | summarize count(), avg(DurationMs), avg(RequestCharge) by OperationType, CollectionName
        | order by avg_DurationMs desc
        ```
        **Step 3: Analyze Query Performance**
        ```kusto
        CDBQueryRuntimeStatistics
        | where TimeGenerated > ago(1h)
        | project TimeGenerated, QueryText, RequestCharge, ResponseLengthBytes, TotalQueryExecutionTime
        | order by RequestCharge desc
        | take 20
        ```
        **Step 4: Create Alert for High RU Consumption**
        - Azure Monitor > Alerts > Condition: Total Request Units > 80% of provisioned
        **References:**
        - [Monitor Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/monitor)

13. How do you implement backup and restore?
    - **Answer:**
        Use continuous backup for point-in-time restore or periodic backup for scheduled snapshots.
    - **Implementation:**
        **Step 1: Enable Continuous Backup (at creation)**
        ```sh
        az cosmosdb create --resource-group myrg --name mycosmosaccount --backup-policy-type Continuous --continuous-tier Continuous7Days --locations regionName=eastus
        ```
        **Step 2: Point-in-Time Restore**
        ```sh
        az cosmosdb restore --resource-group myrg --name mycosmosaccount-restored --source-account mycosmosaccount --restore-timestamp "2024-01-15T10:00:00Z" --location eastus --databases-to-restore name=mydb collections=orders,customers
        ```
        **Step 3: Check Restorable Resources**
        ```sh
        az cosmosdb restorable-database-account list --account-name mycosmosaccount
        az cosmosdb sql restorable-database list --instance-id <instance-id> --location eastus
        ```
        **References:**
        - [Continuous Backup](https://learn.microsoft.com/en-us/azure/cosmos-db/continuous-backup-restore-introduction)

14. How do you use Cosmos DB with Azure Functions?
    - **Answer:**
        Use Cosmos DB input/output bindings and Change Feed trigger for serverless data processing.
    - **Implementation:**
        **Step 1: Cosmos DB Input Binding**
        ```csharp
        [FunctionName("GetOrder")]
        public static IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req,
            [CosmosDB(
                databaseName: "mydb",
                containerName: "orders",
                Connection = "CosmosConnection",
                Id = "{Query.id}",
                PartitionKey = "{Query.customerId}")] Order order,
            ILogger log)
        {
            return order != null ? new OkObjectResult(order) : new NotFoundResult();
        }
        ```
        **Step 2: Cosmos DB Output Binding**
        ```csharp
        [FunctionName("CreateOrder")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post")] Order order,
            [CosmosDB(
                databaseName: "mydb",
                containerName: "orders",
                Connection = "CosmosConnection")] IAsyncCollector<Order> orders,
            ILogger log)
        {
            order.Id = Guid.NewGuid().ToString();
            await orders.AddAsync(order);
            return new CreatedResult($"/orders/{order.Id}", order);
        }
        ```
        **Step 3: Change Feed Trigger**
        ```csharp
        [FunctionName("ProcessOrderChanges")]
        public static void Run(
            [CosmosDBTrigger(
                databaseName: "mydb",
                containerName: "orders",
                Connection = "CosmosConnection",
                LeaseContainerName = "leases",
                CreateLeaseContainerIfNotExists = true)]
            IReadOnlyList<Order> changes,
            ILogger log)
        {
            foreach (var order in changes)
            {
                log.LogInformation($"Order {order.Id} changed: {order.Status}");
            }
        }
        ```
        **References:**
        - [Cosmos DB Azure Functions Bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2)

15. How do you optimize query performance and reduce costs?
    - **Answer:**
        Use point reads over queries, filter on partition key, proper indexing, and projection to select only needed fields.
    - **Implementation:**
        **Step 1: Point Read (1 RU)**
        ```csharp
        // Most efficient - always use when you have id and partition key
        var response = await container.ReadItemAsync<Order>(orderId, new PartitionKey(customerId));
        // Cost: ~1 RU
        ```
        **Step 2: Single-Partition Query**
        ```csharp
        // Efficient - query within partition
        var query = "SELECT * FROM c WHERE c.customerId = 'C001' AND c.status = 'pending'";
        // Cost: Depends on data scanned
        ```
        **Step 3: Use Projection**
        ```csharp
        // Select only needed fields
        var query = "SELECT c.id, c.amount, c.status FROM c WHERE c.customerId = @id";
        // Reduces response size and can reduce RU
        ```
        **Step 4: Avoid Cross-Partition Fan-Out**
        ```csharp
        // BAD: Scans all partitions
        var query = "SELECT * FROM c WHERE c.productName = 'Laptop'";

        // GOOD: Include partition key
        var query = "SELECT * FROM c WHERE c.customerId = @id AND c.productName = 'Laptop'";
        ```
        **Step 5: Bulk Operations for Large Inserts**
        ```csharp
        var cosmosClient = new CosmosClient(connectionString, new CosmosClientOptions
        {
            AllowBulkExecution = true
        });

        var tasks = orders.Select(order => container.CreateItemAsync(order, new PartitionKey(order.CustomerId)));
        await Task.WhenAll(tasks);
        ```
        **References:**
        - [Query Performance Tips](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/performance-tips-query-sdk)

16. How do you implement hierarchical partition keys?
    - **Answer:**
        Use hierarchical partition keys (up to 3 levels) for multi-tenant scenarios to improve data distribution and query efficiency.
    - **Implementation:**
        **Step 1: Create Container with Hierarchical Partition Key**
        ```sh
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name events --partition-key-path "/tenantId" "/userId" "/sessionId"
        ```
        **Step 2: Insert with Hierarchical Key (C#)**
        ```csharp
        var container = database.GetContainer("events");
        var partitionKeyBuilder = new PartitionKeyBuilder()
            .Add("tenant-1")
            .Add("user-123")
            .Add("session-abc");

        var eventDoc = new { id = "event-1", tenantId = "tenant-1", userId = "user-123", sessionId = "session-abc", data = "click" };
        await container.CreateItemAsync(eventDoc, partitionKeyBuilder.Build());
        ```
        **Step 3: Query at Different Levels**
        ```csharp
        // Query all data for a tenant (prefix query)
        var tenantKey = new PartitionKeyBuilder().Add("tenant-1").Build();
        var query = container.GetItemQueryIterator<dynamic>(
            "SELECT * FROM c",
            requestOptions: new QueryRequestOptions { PartitionKey = tenantKey });

        // Query specific user within tenant
        var userKey = new PartitionKeyBuilder().Add("tenant-1").Add("user-123").Build();
        ```
        **References:**
        - [Hierarchical Partition Keys](https://learn.microsoft.com/en-us/azure/cosmos-db/hierarchical-partition-keys)

17. How do you implement the repository pattern with Cosmos DB?
    - **Answer:**
        Create a generic repository abstraction for Cosmos DB operations to improve testability and maintainability.
    - **Implementation:**
        **Step 1: Define Repository Interface**
        ```csharp
        public interface ICosmosRepository<T> where T : class
        {
            Task<T> GetByIdAsync(string id, string partitionKey);
            Task<IEnumerable<T>> GetAllAsync(string partitionKey);
            Task<IEnumerable<T>> QueryAsync(string query, string partitionKey = null);
            Task<T> CreateAsync(T entity);
            Task<T> UpdateAsync(T entity);
            Task DeleteAsync(string id, string partitionKey);
        }
        ```
        **Step 2: Implement Repository**
        ```csharp
        public class CosmosRepository<T> : ICosmosRepository<T> where T : class, IEntity
        {
            private readonly Container _container;

            public CosmosRepository(CosmosClient client, string databaseName, string containerName)
            {
                _container = client.GetContainer(databaseName, containerName);
            }

            public async Task<T> GetByIdAsync(string id, string partitionKey)
            {
                try
                {
                    var response = await _container.ReadItemAsync<T>(id, new PartitionKey(partitionKey));
                    return response.Resource;
                }
                catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
                {
                    return null;
                }
            }

            public async Task<T> CreateAsync(T entity)
            {
                var response = await _container.CreateItemAsync(entity, new PartitionKey(entity.PartitionKey));
                return response.Resource;
            }

            public async Task<IEnumerable<T>> QueryAsync(string queryText, string partitionKey = null)
            {
                var query = new QueryDefinition(queryText);
                var options = partitionKey != null
                    ? new QueryRequestOptions { PartitionKey = new PartitionKey(partitionKey) }
                    : null;
                var results = new List<T>();
                var iterator = _container.GetItemQueryIterator<T>(query, requestOptions: options);
                while (iterator.HasMoreResults)
                {
                    var response = await iterator.ReadNextAsync();
                    results.AddRange(response);
                }
                return results;
            }
        }
        ```
        **Step 3: Register in DI**
        ```csharp
        builder.Services.AddSingleton<CosmosClient>(sp => new CosmosClient(connectionString));
        builder.Services.AddScoped<ICosmosRepository<Order>>(sp =>
            new CosmosRepository<Order>(sp.GetRequiredService<CosmosClient>(), "mydb", "orders"));
        ```
        **References:**
        - [Repository Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/repository)

18. How do you handle conflict resolution in multi-region writes?
    - **Answer:**
        Configure conflict resolution policy: Last Writer Wins (LWW) with custom path, or custom stored procedure for merge logic.
    - **Implementation:**
        **Step 1: Last Writer Wins (Default)**
        ```sh
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --partition-key-path "/customerId" --conflict-resolution-policy-mode LastWriterWins --conflict-resolution-policy-path "/_ts"
        ```
        **Step 2: Custom Conflict Resolution Property**
        ```csharp
        public class Order
        {
            [JsonProperty("id")]
            public string Id { get; set; }

            [JsonProperty("_ts")]
            public long Timestamp { get; set; }

            [JsonProperty("version")]
            public int Version { get; set; }  // Custom LWW property
        }
        ```
        **Step 3: Custom Stored Procedure for Merge**
        ```javascript
        function resolveConflict(incomingItem, existingItem, isTombstone, conflictingItems) {
            var context = getContext();
            var response = context.getResponse();

            if (isTombstone) {
                // Delete wins
                return;
            }

            // Merge logic: take highest amount
            var merged = existingItem;
            if (incomingItem.amount > existingItem.amount) {
                merged = incomingItem;
            }

            response.setBody(merged);
        }
        ```
        **Step 4: Monitor Conflicts**
        ```kusto
        CDBDataPlaneRequests
        | where OperationType == "Conflict"
        | project TimeGenerated, CollectionName, PartitionKey
        ```
        **References:**
        - [Conflict Resolution](https://learn.microsoft.com/en-us/azure/cosmos-db/conflict-resolution-policies)

19. How do you migrate data to Cosmos DB?
    - **Answer:**
        Use Azure Data Factory for large migrations, Data Migration Tool for small datasets, or Spark connector for big data scenarios.
    - **Implementation:**
        **Step 1: Azure Data Factory Pipeline**
        - Create linked services for source and Cosmos DB
        - Create copy activity with mapping
        ```json
        {
            "name": "CopyToCosmosDB",
            "type": "Copy",
            "inputs": [{ "referenceName": "SqlSource", "type": "DatasetReference" }],
            "outputs": [{ "referenceName": "CosmosSink", "type": "DatasetReference" }],
            "typeProperties": {
                "source": { "type": "SqlSource", "sqlReaderQuery": "SELECT * FROM Orders" },
                "sink": { "type": "CosmosDbSqlApiSink", "writeBehavior": "upsert" }
            }
        }
        ```
        **Step 2: Data Migration Tool**
        ```sh
        dt.exe /s:JsonFile /s.Files:*.json /t:CosmosDBBulk /t.ConnectionString:"AccountEndpoint=https://mycosmosaccount.documents.azure.com:443/;AccountKey=xxx;Database=mydb" /t.Collection:orders /t.PartitionKey:/customerId
        ```
        **Step 3: Bulk Import with SDK**
        ```csharp
        var options = new CosmosClientOptions { AllowBulkExecution = true };
        var client = new CosmosClient(connectionString, options);
        var container = client.GetContainer("mydb", "orders");

        var tasks = sourceData.Select(async item =>
        {
            try
            {
                await container.CreateItemAsync(item, new PartitionKey(item.CustomerId));
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.Conflict)
            {
                // Handle duplicate
            }
        });
        await Task.WhenAll(tasks);
        ```
        **References:**
        - [Data Migration Options](https://learn.microsoft.com/en-us/azure/cosmos-db/import-data)

20. How do you integrate Cosmos DB with Azure Synapse Analytics?
    - **Answer:**
        Use Azure Synapse Link for no-ETL analytics on operational data with automatic sync to analytical store.
    - **Implementation:**
        **Step 1: Enable Synapse Link on Account**
        ```sh
        az cosmosdb update --resource-group myrg --name mycosmosaccount --enable-analytical-storage true
        ```
        **Step 2: Enable Analytical Store on Container**
        ```sh
        az cosmosdb sql container create --resource-group myrg --account-name mycosmosaccount --database-name mydb --name orders --partition-key-path "/customerId" --analytical-storage-ttl -1
        ```
        **Step 3: Query from Synapse (Spark)**
        ```python
        df = spark.read.format("cosmos.olap")\
            .option("spark.synapse.linkedService", "CosmosDbLink")\
            .option("spark.cosmos.container", "orders")\
            .load()

        df.groupBy("status").count().show()
        ```
        **Step 4: Query with Synapse SQL Serverless**
        ```sql
        SELECT TOP 100 *
        FROM OPENROWSET(
            'CosmosDB',
            'Account=mycosmosaccount;Database=mydb;Key=xxx',
            orders) AS orders
        WHERE orders.status = 'completed'
        ```
        **References:**
        - [Azure Synapse Link](https://learn.microsoft.com/en-us/azure/cosmos-db/synapse-link)


## 3. Azure Security (Identity, Key Vault, RBAC, Networking)


### 3.1 Azure Key Vault
1. How do you store and retrieve secrets securely?
     - **Answer:**
         Store secrets in Azure Key Vault, access them via SDK or REST API, and use Managed Identity for authentication.
     - **Implementation:**
         **Step 1: Store Secret in Key Vault (CLI)**
         ```sh
         az keyvault secret set --vault-name myvault --name MySecret --value "SuperSecretValue"
         ```
         **Step 2: Access Secret in .NET (C#)**
         ```csharp
         using Azure.Identity;
         using Azure.Security.KeyVault.Secrets;
     
         var kvUri = "https://myvault.vault.azure.net/";
         var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());
         KeyVaultSecret secret = await client.GetSecretAsync("MySecret");
         string secretValue = secret.Value;
         ```
         **Packages:** Azure.Identity, Azure.Security.KeyVault.Secrets
         **References:**
         - [Key Vault quickstart](https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-net)

2. How do you automate secret rotation?
     - **Answer:**
         Use Key Vault event triggers and Azure Functions to rotate secrets automatically.
     - **Implementation:**
         **Step 1: Enable Event Grid on Key Vault**
         - Azure Portal: Key Vault > Events > + Event Subscription
         **Step 2: Create Azure Function to Rotate Secret**
         ```csharp
         [FunctionName("RotateSecret")]
         public static async Task Run([EventGridTrigger] EventGridEvent eventGridEvent, ILogger log)
         {
                 // Parse event, rotate secret, update Key Vault
                 var client = new SecretClient(new Uri("https://myvault.vault.azure.net/"), new DefaultAzureCredential());
                 await client.SetSecretAsync("MySecret", "NewSecretValue");
         }
         ```
         **References:**
         - [Automate Key Vault secret rotation](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation)

3. How do you audit access to secrets?
     - **Answer:**
         Enable diagnostic logging and review access logs in Azure Monitor.
     - **Implementation:**
         **Step 1: Enable Diagnostic Settings**
         - Key Vault > Monitoring > Diagnostic settings > Add diagnostic setting
         - Send logs to Log Analytics
         **Step 2: Query Access Logs (Kusto)**
         ```kusto
         AzureDiagnostics
         | where ResourceType == "VAULTS" and OperationName == "SecretGet"
         ```
         **References:**
         - [Monitor Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/monitor-logs)

4. How do you restrict access to Key Vault?
     - **Answer:**
         Use RBAC or access policies, restrict by VNet/firewall, and use private endpoints.
     - **Implementation:**
         **Step 1: Assign RBAC Role**
         - Key Vault > Access control (IAM) > Add role assignment > Key Vault Secrets User
         **Step 2: Restrict by VNet/Firewall**
         - Key Vault > Networking > Firewalls and virtual networks > Selected networks
         **Step 3: Use Private Endpoint**
         - Key Vault > Networking > Private endpoint connections > + Private endpoint
         **References:**
         - [Secure access to Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/secure-your-key-vault)

5. How do you handle certificate management?
     - **Answer:**
         Store, issue, and renew certificates in Key Vault, and automate renewal with event triggers.
     - **Implementation:**
         **Step 1: Import or Generate Certificate**
         - Key Vault > Certificates > Generate/Import
         **Step 2: Enable Auto-Renewal**
         - For integrated CAs, enable auto-renewal in Key Vault
         **Step 3: Use Event Grid to Trigger Renewal Logic**
         - As in secret rotation, use Event Grid and Azure Functions
         **References:**
         - [Key Vault certificates](https://learn.microsoft.com/en-us/azure/key-vault/certificates/about-certificates)

6. How do you manage keys for encryption?
     - **Answer:**
         Store keys in Key Vault, use for disk or app encryption, and rotate keys regularly.
     - **Implementation:**
         **Step 1: Create Key in Key Vault**
         ```sh
         az keyvault key create --vault-name myvault --name mykey --protection software
         ```
         **Step 2: Use Key for Encryption in .NET**
         ```csharp
         using Azure.Identity;
         using Azure.Security.KeyVault.Keys;
     
         var client = new KeyClient(new Uri("https://myvault.vault.azure.net/"), new DefaultAzureCredential());
         KeyVaultKey key = await client.GetKeyAsync("mykey");
         // Use key.Key for encryption logic
         ```
         **References:**
         - [Key Vault keys](https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys)

7. How do you integrate Key Vault with App Service/Functions?
     - **Answer:**
         Use Managed Identity, reference secrets in app settings.
     - **Implementation:**
         **Step 1: Enable Managed Identity on App Service/Function**
         - App Service/Function > Identity > System assigned > On
         **Step 2: Reference Secret in App Settings**
         - In App Settings: @Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/MySecret/)
         **Step 3: Access in Code (see question 1)**
         **References:**
         - [Key Vault references in App Service](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references)

8. How do you monitor for unauthorized access?
     - **Answer:**
         Set up alerts on failed access attempts and review logs.
     - **Implementation:**
         **Step 1: Enable Diagnostic Settings (see question 3)**
         **Step 2: Create Alert Rule**
         - Azure Monitor > Alerts > New alert rule > Condition: Failed access attempts
         **References:**
         - [Monitor Key Vault access](https://learn.microsoft.com/en-us/azure/key-vault/general/monitor-logs)

9. How do you handle soft delete and purge protection?
     - **Answer:**
         Enable both features to prevent accidental or malicious deletion.
     - **Implementation:**
         **Step 1: Enable Soft Delete and Purge Protection**
         - Key Vault > Properties > Soft delete: Enabled, Purge protection: Enabled
         **References:**
         - [Soft delete and purge protection](https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview)

10. How do you automate backup/restore of Key Vault?
     - **Answer:**
         Use Azure CLI or PowerShell scripts for backup/restore operations.
     - **Implementation:**
         **Step 1: Backup Secret**
         ```sh
         az keyvault secret backup --vault-name myvault --name MySecret --file MySecretBackup
         ```
         **Step 2: Restore Secret**
         ```sh
         az keyvault secret restore --vault-name myvault --file MySecretBackup
         ```
         **References:**
         - [Backup and restore Key Vault objects](https://learn.microsoft.com/en-us/azure/key-vault/secrets/backup-restore)

11. How do you secure access from on-premises?
     - **Answer:**
         Use VPN or ExpressRoute, restrict by IP, and use RBAC.
     - **Implementation:**
         **Step 1: Set Up VPN/ExpressRoute**
         - Azure Portal: Virtual Network Gateway > Configure VPN/ExpressRoute
         **Step 2: Restrict by IP**
         - Key Vault > Networking > Firewalls and virtual networks > Add on-premises IP
         **Step 3: Use RBAC (see question 4)**
         **References:**
         - [Access Key Vault from on-premises](https://learn.microsoft.com/en-us/azure/key-vault/general/overview-vnet-service-endpoints)

12. How do you handle secret expiration?
     - **Answer:**
         Set expiration dates, monitor with alerts, and automate renewal.
     - **Implementation:**
         **Step 1: Set Expiry When Creating Secret**
         ```sh
         az keyvault secret set --vault-name myvault --name MySecret --value "value" --expires "2026-12-31T23:59:59Z"
         ```
         **Step 2: Monitor Expiry with Alerts**
         - Azure Monitor > Alerts > New alert rule > Condition: Secret expiring soon
         **Step 3: Automate Renewal (see question 2)**
         **References:**
         - [Secret expiration](https://learn.microsoft.com/en-us/azure/key-vault/secrets/about-secrets)

13. How do you integrate with third-party apps?
     - **Answer:**
         Use service principals, client credentials, and Key Vault APIs.
     - **Implementation:**
         **Step 1: Register App in Azure AD**
         - Azure Portal: Azure Active Directory > App registrations > New registration
         **Step 2: Grant App Access to Key Vault**
         - Key Vault > Access policies > Add access policy > Select app
         **Step 3: Use Client Credentials in Code**
         ```csharp
         var clientSecretCredential = new ClientSecretCredential(
                 "<tenant-id>", "<client-id>", "<client-secret>");
         var client = new SecretClient(new Uri("https://myvault.vault.azure.net/"), clientSecretCredential);
         ```
         **Packages:** Azure.Identity, Azure.Security.KeyVault.Secrets
         **References:**
         - [Key Vault with service principals](https://learn.microsoft.com/en-us/azure/key-vault/general/authentication)

14. How do you test Key Vault access locally?
     - **Answer:**
         Use Azure CLI login, set environment variables, and use local emulators if available.
     - **Implementation:**
         **Step 1: Login with Azure CLI**
         ```sh
         az login
         ```
         **Step 2: Use DefaultAzureCredential in Code (see question 1)**
         **References:**
         - [Develop locally with Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-net)

15. How do you enforce least privilege?
     - **Answer:**
         Grant only necessary permissions, review regularly, and use RBAC.
     - **Implementation:**
         **Step 1: Assign Only Required Roles/Policies**
         - Key Vault > Access control (IAM) > Add role assignment > Select minimum required role
         **Step 2: Review Access Regularly**
         - Azure Portal: Key Vault > Access control (IAM) > Review assignments
         **References:**
         - [Least privilege in Azure](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)

16. How do you implement Key Vault backup and disaster recovery?
    - **Answer:**
        Back up secrets, keys, and certificates using the SDK or CLI. For disaster recovery, use geo-redundant vaults or replicate secrets across regions.
    - **Implementation:**
        **Step 1: Backup Secrets Using CLI**
        ```sh
        # Backup individual secret
        az keyvault secret backup --vault-name myvault --name mysecret --file mysecret.bak

        # Backup all secrets
        for secret in $(az keyvault secret list --vault-name myvault --query "[].name" -o tsv); do
            az keyvault secret backup --vault-name myvault --name $secret --file "${secret}.bak"
        done

        # Backup keys
        az keyvault key backup --vault-name myvault --name mykey --file mykey.bak

        # Backup certificates
        az keyvault certificate backup --vault-name myvault --name mycert --file mycert.bak
        ```
        **Step 2: Restore Secrets to Another Vault**
        ```sh
        # Restore secret
        az keyvault secret restore --vault-name myvault-dr --file mysecret.bak

        # Restore key
        az keyvault key restore --vault-name myvault-dr --file mykey.bak
        ```
        **Step 3: C# Backup and Restore Service**
        ```csharp
        using Azure.Security.KeyVault.Secrets;

        public class KeyVaultBackupService
        {
            private readonly SecretClient _sourceClient;
            private readonly SecretClient _targetClient;

            public async Task BackupAllSecretsAsync(string backupFolder)
            {
                await foreach (var secretProperties in _sourceClient.GetPropertiesOfSecretsAsync())
                {
                    var backupBytes = await _sourceClient.BackupSecretAsync(secretProperties.Name);
                    var backupPath = Path.Combine(backupFolder, $"{secretProperties.Name}.bak");
                    await File.WriteAllBytesAsync(backupPath, backupBytes.Value);
                }
            }

            public async Task RestoreSecretsAsync(string backupFolder)
            {
                foreach (var backupFile in Directory.GetFiles(backupFolder, "*.bak"))
                {
                    var backupBytes = await File.ReadAllBytesAsync(backupFile);
                    await _targetClient.RestoreSecretBackupAsync(backupBytes);
                }
            }

            public async Task ReplicateSecretAsync(string secretName)
            {
                var secret = await _sourceClient.GetSecretAsync(secretName);
                await _targetClient.SetSecretAsync(secretName, secret.Value.Value);
            }
        }
        ```
        **Step 4: Automated Cross-Region Replication**
        ```csharp
        [Function("ReplicateKeyVaultSecrets")]
        public async Task Run([TimerTrigger("0 0 * * * *")] TimerInfo timer)
        {
            var sourceSecrets = _sourceClient.GetPropertiesOfSecretsAsync();

            await foreach (var prop in sourceSecrets)
            {
                try
                {
                    var secret = await _sourceClient.GetSecretAsync(prop.Name);

                    // Check if target needs update
                    try
                    {
                        var targetSecret = await _targetClient.GetSecretAsync(prop.Name);
                        if (targetSecret.Value.Value == secret.Value.Value)
                            continue; // Already in sync
                    }
                    catch (RequestFailedException ex) when (ex.Status == 404)
                    {
                        // Secret doesn't exist in target
                    }

                    await _targetClient.SetSecretAsync(prop.Name, secret.Value.Value);
                    _logger.LogInformation($"Replicated secret: {prop.Name}");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, $"Failed to replicate secret: {prop.Name}");
                }
            }
        }
        ```
        **References:**
        - [Key Vault Backup](https://learn.microsoft.com/en-us/azure/key-vault/general/backup)
        - [Key Vault Disaster Recovery](https://learn.microsoft.com/en-us/azure/key-vault/general/disaster-recovery-guidance)

17. How do you implement Key Vault with Private Link?
    - **Answer:**
        Private Link enables secure access to Key Vault over a private endpoint in your VNet, eliminating exposure to the public internet.
    - **Implementation:**
        **Step 1: Create Private Endpoint**
        ```sh
        # Create private endpoint
        az network private-endpoint create \
            --resource-group myrg \
            --name keyvault-private-endpoint \
            --vnet-name myvnet \
            --subnet mysubnet \
            --private-connection-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.KeyVault/vaults/myvault \
            --group-id vault \
            --connection-name keyvault-connection

        # Create private DNS zone
        az network private-dns zone create \
            --resource-group myrg \
            --name privatelink.vaultcore.azure.net

        # Link DNS zone to VNet
        az network private-dns link vnet create \
            --resource-group myrg \
            --zone-name privatelink.vaultcore.azure.net \
            --name keyvault-dns-link \
            --virtual-network myvnet \
            --registration-enabled false

        # Create DNS zone group
        az network private-endpoint dns-zone-group create \
            --resource-group myrg \
            --endpoint-name keyvault-private-endpoint \
            --name keyvault-dns-group \
            --private-dns-zone privatelink.vaultcore.azure.net \
            --zone-name vault
        ```
        **Step 2: Disable Public Network Access**
        ```sh
        az keyvault update \
            --name myvault \
            --resource-group myrg \
            --public-network-access Disabled
        ```
        **Step 3: Bicep Template for Private Endpoint**
        ```bicep
        resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
            name: 'myvault'
            location: resourceGroup().location
            properties: {
                sku: { family: 'A', name: 'standard' }
                tenantId: subscription().tenantId
                enableRbacAuthorization: true
                networkAcls: {
                    defaultAction: 'Deny'
                    bypass: 'AzureServices'
                }
                publicNetworkAccess: 'Disabled'
            }
        }

        resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
            name: 'keyvault-pe'
            location: resourceGroup().location
            properties: {
                subnet: { id: subnet.id }
                privateLinkServiceConnections: [
                    {
                        name: 'keyvault-connection'
                        properties: {
                            privateLinkServiceId: keyVault.id
                            groupIds: ['vault']
                        }
                    }
                ]
            }
        }

        resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
            name: 'privatelink.vaultcore.azure.net'
            location: 'global'
        }

        resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
            parent: privateDnsZone
            name: 'vnet-link'
            location: 'global'
            properties: {
                registrationEnabled: false
                virtualNetwork: { id: vnet.id }
            }
        }
        ```
        **References:**
        - [Key Vault Private Link](https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service)

18. How do you implement certificate auto-renewal with Key Vault?
    - **Answer:**
        Key Vault integrates with certificate authorities (DigiCert, GlobalSign) for automatic certificate renewal. Configure renewal policies and Event Grid notifications.
    - **Implementation:**
        **Step 1: Create Certificate with Auto-Renewal Policy**
        ```sh
        az keyvault certificate create \
            --vault-name myvault \
            --name mydomain-cert \
            --policy '{
                "issuerParameters": {
                    "name": "Self"
                },
                "keyProperties": {
                    "exportable": true,
                    "keyType": "RSA",
                    "keySize": 2048,
                    "reuseKey": false
                },
                "secretProperties": {
                    "contentType": "application/x-pkcs12"
                },
                "x509CertificateProperties": {
                    "subject": "CN=mydomain.com",
                    "validityInMonths": 12,
                    "subjectAlternativeNames": {
                        "dnsNames": ["mydomain.com", "*.mydomain.com"]
                    }
                },
                "lifetimeActions": [
                    {
                        "trigger": { "daysBeforeExpiry": 30 },
                        "action": { "actionType": "AutoRenew" }
                    },
                    {
                        "trigger": { "daysBeforeExpiry": 7 },
                        "action": { "actionType": "EmailContacts" }
                    }
                ]
            }'
        ```
        **Step 2: Configure Certificate Authority Integration**
        ```sh
        # Set up DigiCert issuer
        az keyvault certificate issuer create \
            --vault-name myvault \
            --issuer-name DigiCertIssuer \
            --provider-name DigiCert \
            --account-id <digicert-account-id> \
            --password <api-key> \
            --organization-id <org-id>

        # Create certificate with CA
        az keyvault certificate create \
            --vault-name myvault \
            --name ca-signed-cert \
            --policy '{
                "issuerParameters": {
                    "name": "DigiCertIssuer",
                    "certificateType": "OV-SSL"
                },
                "x509CertificateProperties": {
                    "subject": "CN=mydomain.com, O=MyOrg, C=US",
                    "validityInMonths": 24
                },
                "lifetimeActions": [
                    {
                        "trigger": { "daysBeforeExpiry": 60 },
                        "action": { "actionType": "AutoRenew" }
                    }
                ]
            }'
        ```
        **Step 3: Event Grid Notification for Certificate Events**
        ```sh
        az eventgrid event-subscription create \
            --name cert-expiry-notification \
            --source-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.KeyVault/vaults/myvault \
            --endpoint https://myfunctionapp.azurewebsites.net/api/CertificateEvent \
            --included-event-types Microsoft.KeyVault.CertificateNearExpiry Microsoft.KeyVault.CertificateExpired
        ```
        **Step 4: Azure Function for Certificate Events**
        ```csharp
        [Function("HandleCertificateEvents")]
        public async Task Run(
            [EventGridTrigger] EventGridEvent eventGridEvent)
        {
            var data = eventGridEvent.Data.ToObjectFromJson<KeyVaultCertificateEventData>();

            switch (eventGridEvent.EventType)
            {
                case "Microsoft.KeyVault.CertificateNearExpiry":
                    await _alertService.SendAlertAsync(
                        $"Certificate {data.ObjectName} expires on {data.Exp}");
                    break;
                case "Microsoft.KeyVault.CertificateExpired":
                    await _alertService.SendCriticalAlertAsync(
                        $"Certificate {data.ObjectName} has expired!");
                    break;
            }
        }
        ```
        **References:**
        - [Certificate Auto-Renewal](https://learn.microsoft.com/en-us/azure/key-vault/certificates/overview-renew-certificate)
        - [Key Vault Event Grid](https://learn.microsoft.com/en-us/azure/key-vault/general/event-grid-overview)

19. How do you implement Key Vault audit logging and monitoring?
    - **Answer:**
        Enable diagnostic settings to send Key Vault audit logs to Log Analytics, Storage, or Event Hubs. Monitor access patterns, failures, and anomalies.
    - **Implementation:**
        **Step 1: Enable Diagnostic Logging**
        ```sh
        az monitor diagnostic-settings create \
            --name keyvault-diagnostics \
            --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.KeyVault/vaults/myvault \
            --workspace /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.OperationalInsights/workspaces/myworkspace \
            --logs '[{"category": "AuditEvent", "enabled": true, "retentionPolicy": {"enabled": true, "days": 90}}]' \
            --metrics '[{"category": "AllMetrics", "enabled": true}]'
        ```
        **Step 2: Query Audit Logs with KQL**
        ```kusto
        // All Key Vault operations
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.KEYVAULT"
        | where Category == "AuditEvent"
        | project TimeGenerated, OperationName, ResultType, CallerIPAddress, identity_claim_upn_s
        | order by TimeGenerated desc

        // Failed access attempts
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.KEYVAULT"
        | where ResultType != "Success"
        | summarize FailedAttempts = count() by OperationName, CallerIPAddress, bin(TimeGenerated, 1h)
        | where FailedAttempts > 10

        // Secret access by identity
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.KEYVAULT"
        | where OperationName == "SecretGet"
        | summarize AccessCount = count() by identity_claim_upn_s, id_s
        | order by AccessCount desc

        // Unusual access patterns
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.KEYVAULT"
        | where OperationName in ("SecretGet", "KeySign", "KeyDecrypt")
        | summarize OperationCount = count() by CallerIPAddress, bin(TimeGenerated, 1h)
        | where OperationCount > 100
        ```
        **Step 3: Create Alert Rules**
        ```sh
        # Alert on unauthorized access
        az monitor scheduled-query create \
            --name "KeyVault-UnauthorizedAccess" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.OperationalInsights/workspaces/myworkspace \
            --condition "count 'AzureDiagnostics | where ResourceProvider == \"MICROSOFT.KEYVAULT\" | where ResultType == \"Unauthorized\"' > 5" \
            --window-size 5m \
            --evaluation-frequency 5m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/security-alerts
        ```
        **Step 4: Bicep Template for Monitoring**
        ```bicep
        resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
            name: 'keyvault-diag'
            scope: keyVault
            properties: {
                workspaceId: logAnalyticsWorkspace.id
                logs: [
                    {
                        category: 'AuditEvent'
                        enabled: true
                        retentionPolicy: { enabled: true, days: 90 }
                    }
                ]
                metrics: [
                    {
                        category: 'AllMetrics'
                        enabled: true
                    }
                ]
            }
        }
        ```
        **References:**
        - [Key Vault Logging](https://learn.microsoft.com/en-us/azure/key-vault/general/logging)
        - [Monitor Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/monitor-key-vault)

20. How do you implement Key Vault secrets rotation?
    - **Answer:**
        Implement automated secret rotation using Azure Functions triggered by Event Grid or timer. Update dependent applications using Key Vault references.
    - **Implementation:**
        **Step 1: Create Rotation Function**
        ```csharp
        [Function("RotateStorageKey")]
        public async Task Run(
            [EventGridTrigger] EventGridEvent eventGridEvent,
            FunctionContext context)
        {
            var data = eventGridEvent.Data.ToObjectFromJson<SecretNearExpiryEventData>();

            if (data.ObjectName == "storageAccountKey")
            {
                await RotateStorageKeyAsync(data.ObjectName);
            }
        }

        private async Task RotateStorageKeyAsync(string secretName)
        {
            // 1. Regenerate storage account key (key2)
            var keys = await _storageClient.RegenerateKeyAsync(
                _resourceGroup, _storageAccountName,
                new StorageAccountRegenerateKeyParameters { KeyName = "key2" });

            // 2. Update Key Vault with new key
            var newKey = keys.Keys.First(k => k.KeyName == "key2").Value;
            await _secretClient.SetSecretAsync(secretName, newKey);

            // 3. Wait for applications to pick up new key
            await Task.Delay(TimeSpan.FromMinutes(5));

            // 4. Regenerate key1 (applications now use key2)
            await _storageClient.RegenerateKeyAsync(
                _resourceGroup, _storageAccountName,
                new StorageAccountRegenerateKeyParameters { KeyName = "key1" });
        }
        ```
        **Step 2: SQL Password Rotation**
        ```csharp
        [Function("RotateSqlPassword")]
        public async Task RotateSqlPassword([TimerTrigger("0 0 0 1 * *")] TimerInfo timer)
        {
            // Generate new password
            var newPassword = GenerateSecurePassword(32);

            // Update SQL Server
            await _sqlClient.Servers.UpdateAsync(_resourceGroup, _sqlServerName,
                new ServerUpdate { AdministratorLoginPassword = newPassword });

            // Update Key Vault
            await _secretClient.SetSecretAsync("sql-admin-password", newPassword);

            // Update applications using connection string
            var connectionString = $"Server={_sqlServerName}.database.windows.net;Database=mydb;User Id=admin;Password={newPassword};";
            await _secretClient.SetSecretAsync("sql-connection-string", connectionString);
        }

        private string GenerateSecurePassword(int length)
        {
            const string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
            using var rng = RandomNumberGenerator.Create();
            var bytes = new byte[length];
            rng.GetBytes(bytes);
            return new string(bytes.Select(b => chars[b % chars.Length]).ToArray());
        }
        ```
        **Step 3: Event Grid Subscription for Near Expiry**
        ```sh
        az eventgrid event-subscription create \
            --name secret-rotation-trigger \
            --source-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.KeyVault/vaults/myvault \
            --endpoint /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/sites/myfuncapp/functions/RotateStorageKey \
            --endpoint-type azurefunction \
            --included-event-types Microsoft.KeyVault.SecretNearExpiry
        ```
        **Step 4: Set Secret Expiration**
        ```csharp
        public async Task SetSecretWithExpirationAsync(string name, string value, int expirationDays)
        {
            var secret = new KeyVaultSecret(name, value)
            {
                Properties =
                {
                    ExpiresOn = DateTimeOffset.UtcNow.AddDays(expirationDays),
                    NotBefore = DateTimeOffset.UtcNow,
                    Tags = { ["RotationPolicy"] = "90days" }
                }
            };

            await _secretClient.SetSecretAsync(secret);
        }
        ```
        **References:**
        - [Secret Rotation Tutorial](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation)
        - [Rotation Functions](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation-dual)

### 3.2 Azure Active Directory (Identity & RBAC)
1. How do you implement RBAC for Azure resources?
    - **Answer:**
        Assign built-in or custom roles to users/groups/service principals at resource, group, or subscription level.
    - **Implementation:**
        **Step 1: Assign Built-in Role (CLI)**
        ```sh
        az role assignment create --assignee user@example.com --role "Contributor" --scope /subscriptions/<sub-id>/resourceGroups/myrg
        ```
        **Step 2: Create Custom Role**
        ```json
        {
            "Name": "VM Operator",
            "IsCustom": true,
            "Actions": ["Microsoft.Compute/virtualMachines/start/action", "Microsoft.Compute/virtualMachines/restart/action"],
            "NotActions": [],
            "AssignableScopes": ["/subscriptions/<sub-id>"]
        }
        ```
        ```sh
        az role definition create --role-definition custom-role.json
        ```
        **References:**
        - [Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)

2. How do you secure app authentication?
    - **Answer:**
        Use Azure AD for OAuth/OpenID Connect, register apps, and use client secrets or certificates.
    - **Implementation:**
        **Step 1: Register App in Azure AD**
        ```sh
        az ad app create --display-name "MyApp" --sign-in-audience AzureADMyOrg
        ```
        **Step 2: Configure Authentication in ASP.NET Core**
        ```csharp
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));
        ```
        **Step 3: Protect API Endpoint**
        ```csharp
        [Authorize]
        [ApiController]
        public class SecureController : ControllerBase
        {
            [HttpGet]
            public IActionResult Get() => Ok("Authenticated!");
        }
        ```
        **References:**
        - [Microsoft Identity Platform](https://learn.microsoft.com/en-us/azure/active-directory/develop/)

3. How do you implement multi-factor authentication (MFA)?
    - **Answer:**
        Enable MFA in Azure AD and enforce via Conditional Access policies.
    - **Implementation:**
        **Step 1: Create Conditional Access Policy (Portal)**
        - Azure AD > Security > Conditional Access > New policy
        - Assignments: All users, Target: All cloud apps
        - Grant: Require MFA
        **Step 2: Create via PowerShell**
        ```powershell
        New-AzureADMSConditionalAccessPolicy -DisplayName "Require MFA" -State "Enabled" -Conditions @{Users=@{IncludeUsers="All"}} -GrantControls @{BuiltInControls=@("mfa")}
        ```
        **References:**
        - [Conditional Access MFA](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-all-users-mfa)

4. How do you audit sign-ins and access?
    - **Answer:**
        Use Azure AD sign-in logs, review risky sign-ins, and set up alerts.
    - **Implementation:**
        **Step 1: View Sign-in Logs**
        - Azure AD > Monitoring > Sign-in logs
        **Step 2: Query via Graph API**
        ```csharp
        var signIns = await graphClient.AuditLogs.SignIns.GetAsync();
        ```
        **Step 3: Export to Log Analytics (Kusto)**
        ```kusto
        SigninLogs
        | where ResultType != 0
        | project TimeGenerated, UserPrincipalName, ResultDescription, IPAddress
        ```
        **References:**
        - [Azure AD Sign-in Logs](https://learn.microsoft.com/en-us/azure/active-directory/reports-monitoring/concept-sign-ins)

5. How do you automate user provisioning?
    - **Answer:**
        Use SCIM for SaaS apps, Azure AD Connect for hybrid, or Graph API for programmatic provisioning.
    - **Implementation:**
        **Step 1: Create User via Graph API**
        ```csharp
        var user = new User
        {
            DisplayName = "John Doe",
            UserPrincipalName = "john@example.com",
            PasswordProfile = new PasswordProfile { Password = "TempPass123!" },
            AccountEnabled = true
        };
        await graphClient.Users.PostAsync(user);
        ```
        **Step 2: Enable SCIM Provisioning**
        - Azure AD > Enterprise applications > App > Provisioning > Enable
        **References:**
        - [Azure AD Provisioning](https://learn.microsoft.com/en-us/azure/active-directory/app-provisioning/user-provisioning)

6. How do you secure APIs with Azure AD?
    - **Answer:**
        Register API, expose scopes, require tokens, and validate in middleware.
    - **Implementation:**
        **Step 1: Expose API Scope**
        - Azure AD > App registrations > MyAPI > Expose an API > Add scope
        **Step 2: Configure API to Validate Tokens**
        ```csharp
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddMicrosoftIdentityWebApi(options =>
            {
                builder.Configuration.Bind("AzureAd", options);
                options.TokenValidationParameters.ValidAudience = "api://<client-id>";
            }, options => builder.Configuration.Bind("AzureAd", options));
        ```
        **Step 3: Require Scope in Controller**
        ```csharp
        [Authorize]
        [RequiredScope("access_as_user")]
        public IActionResult SecureEndpoint() => Ok();
        ```
        **References:**
        - [Protected Web API](https://learn.microsoft.com/en-us/azure/active-directory/develop/scenario-protected-web-api-overview)

7. How do you implement B2C scenarios?
    - **Answer:**
        Use Azure AD B2C for external users, configure identity providers, and customize user flows.
    - **Implementation:**
        **Step 1: Create Azure AD B2C Tenant**
        - Azure Portal > Create resource > Azure AD B2C
        **Step 2: Configure User Flow**
        - B2C tenant > User flows > New user flow > Sign up and sign in
        **Step 3: Configure in App**
        ```json
        {
            "AzureAdB2C": {
                "Instance": "https://myb2ctenant.b2clogin.com",
                "Domain": "myb2ctenant.onmicrosoft.com",
                "ClientId": "<client-id>",
                "SignUpSignInPolicyId": "B2C_1_signupsignin"
            }
        }
        ```
        **References:**
        - [Azure AD B2C](https://learn.microsoft.com/en-us/azure/active-directory-b2c/overview)

8. How do you handle passwordless authentication?
    - **Answer:**
        Enable passwordless options like FIDO2 security keys or Microsoft Authenticator in Azure AD.
    - **Implementation:**
        **Step 1: Enable FIDO2 in Azure AD**
        - Azure AD > Security > Authentication methods > FIDO2 security key > Enable
        **Step 2: Enable Authenticator App**
        - Azure AD > Security > Authentication methods > Microsoft Authenticator > Enable
        **Step 3: User Registration**
        - Users register at https://mysignins.microsoft.com/security-info
        **References:**
        - [Passwordless Authentication](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless)

9. How do you manage service principals securely?
    - **Answer:**
        Use certificates over secrets, rotate credentials regularly, and restrict permissions with least privilege.
    - **Implementation:**
        **Step 1: Create Service Principal with Certificate**
        ```sh
        az ad sp create-for-rbac --name "myapp" --cert @mycert.pem
        ```
        **Step 2: Authenticate with Certificate (C#)**
        ```csharp
        var cert = new X509Certificate2("mycert.pfx", "password");
        var credential = new ClientCertificateCredential(tenantId, clientId, cert);
        ```
        **Step 3: Set Credential Expiry**
        ```sh
        az ad app credential reset --id <app-id> --years 1
        ```
        **References:**
        - [Service Principal Best Practices](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)

10. How do you automate RBAC assignments?
    - **Answer:**
        Use Azure CLI, PowerShell, ARM/Bicep templates, or Graph API.
    - **Implementation:**
        **Step 1: CLI**
        ```sh
        az role assignment create --assignee <principal-id> --role "Reader" --scope /subscriptions/<sub-id>
        ```
        **Step 2: Bicep Template**
        ```bicep
        resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
            name: guid(resourceGroup().id, principalId, roleDefinitionId)
            properties: {
                principalId: principalId
                roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
            }
        }
        ```
        **References:**
        - [Automate RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli)

11. How do you monitor privilege escalation?
    - **Answer:**
        Set up alerts for role changes and review Azure AD audit logs.
    - **Implementation:**
        **Step 1: Query Role Changes (Kusto)**
        ```kusto
        AuditLogs
        | where OperationName == "Add member to role"
        | project TimeGenerated, InitiatedBy, TargetResources
        ```
        **Step 2: Create Alert**
        - Azure Monitor > Alerts > New alert rule > Condition: Role assignment created
        **References:**
        - [Monitor Azure AD](https://learn.microsoft.com/en-us/azure/active-directory/reports-monitoring/concept-audit-logs)

12. How do you restrict access to management APIs?
    - **Answer:**
        Use RBAC for permissions, Conditional Access for policies, and network restrictions.
    - **Implementation:**
        **Step 1: Require MFA for Azure Management**
        - Conditional Access > New policy > Cloud apps: Microsoft Azure Management > Grant: Require MFA
        **Step 2: Restrict by Location**
        - Conditional Access > Conditions > Locations > Block except trusted
        **References:**
        - [Secure Azure Management](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-azure-management)

13. How do you implement Just-In-Time access?
    - **Answer:**
        Use Privileged Identity Management (PIM) for time-limited, approval-based role assignments.
    - **Implementation:**
        **Step 1: Enable PIM for Role**
        - Azure AD > PIM > Azure AD roles > Roles > Select role > Settings
        **Step 2: Activate Role as User**
        - Azure AD > PIM > My roles > Activate
        **Step 3: Configure Approval Workflow**
        - PIM > Role settings > Require approval to activate
        **References:**
        - [Azure AD PIM](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure)

14. How do you integrate with on-premises AD?
    - **Answer:**
        Use Azure AD Connect for directory sync and configure hybrid identity with password hash sync or federation.
    - **Implementation:**
        **Step 1: Install Azure AD Connect**
        - Download from Microsoft, install on on-premises server
        **Step 2: Configure Sync Method**
        - Password Hash Sync (recommended) or Pass-through Authentication
        **Step 3: Enable Seamless SSO**
        - Azure AD Connect > User sign-in > Enable Seamless SSO
        **References:**
        - [Azure AD Connect](https://learn.microsoft.com/en-us/azure/active-directory/hybrid/whatis-azure-ad-connect)

15. How do you enforce Conditional Access policies?
    - **Answer:**
        Define policies based on user, location, device, risk level, and require MFA or block access.
    - **Implementation:**
        **Step 1: Create Policy**
        - Azure AD > Security > Conditional Access > New policy
        **Step 2: Configure Conditions**
        ```json
        {
            "displayName": "Block risky sign-ins",
            "state": "enabled",
            "conditions": {
                "signInRiskLevels": ["high", "medium"],
                "users": { "includeUsers": ["All"] }
            },
            "grantControls": { "builtInControls": ["block"] }
        }
        ```
        **Step 3: Test with What If**
        - Conditional Access > What If > Test policy evaluation
        **References:**
        - [Conditional Access Policies](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-policies)

16. How do you implement app roles and role-based claims?
    - **Answer:**
        Define app roles in the Azure AD app registration manifest, assign users/groups to roles, and validate role claims in your application.
    - **Implementation:**
        **Step 1: Define App Roles in Manifest**
        ```json
        {
            "appRoles": [
                {
                    "allowedMemberTypes": ["User", "Application"],
                    "description": "Administrators can manage all aspects of the app",
                    "displayName": "Administrator",
                    "id": "1b4f816e-5eaf-48b9-8613-7923830595ad",
                    "isEnabled": true,
                    "value": "Admin"
                },
                {
                    "allowedMemberTypes": ["User"],
                    "description": "Readers can view content",
                    "displayName": "Reader",
                    "id": "2b4f816e-5eaf-48b9-8613-7923830595ae",
                    "isEnabled": true,
                    "value": "Reader"
                },
                {
                    "allowedMemberTypes": ["User"],
                    "description": "Writers can create and edit content",
                    "displayName": "Writer",
                    "id": "3b4f816e-5eaf-48b9-8613-7923830595af",
                    "isEnabled": true,
                    "value": "Writer"
                }
            ]
        }
        ```
        **Step 2: Assign Roles via CLI**
        ```sh
        # Get service principal object ID
        spId=$(az ad sp list --filter "appId eq '<app-id>'" --query "[0].id" -o tsv)

        # Assign user to app role
        az rest --method POST \
            --uri "https://graph.microsoft.com/v1.0/users/<user-id>/appRoleAssignments" \
            --body '{
                "principalId": "<user-object-id>",
                "resourceId": "'$spId'",
                "appRoleId": "1b4f816e-5eaf-48b9-8613-7923830595ad"
            }'
        ```
        **Step 3: Validate Roles in ASP.NET Core**
        ```csharp
        // Configure role-based authorization
        builder.Services.AddAuthorization(options =>
        {
            options.AddPolicy("AdminOnly", policy =>
                policy.RequireRole("Admin"));

            options.AddPolicy("WriterOrAbove", policy =>
                policy.RequireRole("Admin", "Writer"));

            options.AddPolicy("AnyRole", policy =>
                policy.RequireRole("Admin", "Writer", "Reader"));
        });

        // Use in controller
        [Authorize(Policy = "AdminOnly")]
        [ApiController]
        [Route("api/[controller]")]
        public class AdminController : ControllerBase
        {
            [HttpDelete("{id}")]
            public IActionResult DeleteUser(string id)
            {
                // Only admins can delete
                return Ok();
            }
        }

        // Check roles programmatically
        [Authorize]
        public IActionResult GetContent()
        {
            if (User.IsInRole("Admin"))
            {
                return Ok(GetAllContent());
            }
            else if (User.IsInRole("Writer"))
            {
                return Ok(GetWriterContent());
            }
            return Ok(GetReaderContent());
        }
        ```
        **Step 4: Extract Roles from Token**
        ```csharp
        public class RoleClaimsTransformation : IClaimsTransformation
        {
            public Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
            {
                var identity = (ClaimsIdentity)principal.Identity;

                // Azure AD sends roles in 'roles' claim
                var roleClaims = principal.FindAll("roles");

                foreach (var role in roleClaims)
                {
                    // Add as standard role claim
                    identity.AddClaim(new Claim(ClaimTypes.Role, role.Value));
                }

                return Task.FromResult(principal);
            }
        }
        ```
        **References:**
        - [App Roles](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-add-app-roles-in-azure-ad-apps)
        - [Role-Based Authorization](https://learn.microsoft.com/en-us/aspnet/core/security/authorization/roles)

17. How do you implement Workload Identity Federation?
    - **Answer:**
        Workload Identity Federation allows external identity providers (GitHub, GitLab, Kubernetes) to authenticate without storing secrets, using OIDC federation.
    - **Implementation:**
        **Step 1: Create Federated Credential for GitHub Actions**
        ```sh
        # Create app registration
        az ad app create --display-name "github-actions-app"

        # Add federated credential
        az ad app federated-credential create \
            --id <app-object-id> \
            --parameters '{
                "name": "github-actions-main",
                "issuer": "https://token.actions.githubusercontent.com",
                "subject": "repo:myorg/myrepo:ref:refs/heads/main",
                "audiences": ["api://AzureADTokenExchange"]
            }'

        # Create service principal
        az ad sp create --id <app-id>

        # Assign role
        az role assignment create \
            --assignee <app-id> \
            --role "Contributor" \
            --scope /subscriptions/<sub-id>/resourceGroups/myrg
        ```
        **Step 2: GitHub Actions Workflow**
        ```yaml
        name: Deploy to Azure
        on:
            push:
                branches: [main]

        permissions:
            id-token: write
            contents: read

        jobs:
            deploy:
                runs-on: ubuntu-latest
                steps:
                    - uses: actions/checkout@v4

                    - name: Azure Login
                      uses: azure/login@v2
                      with:
                          client-id: ${{ secrets.AZURE_CLIENT_ID }}
                          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
                          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

                    - name: Deploy
                      run: |
                          az webapp deploy --name mywebapp --resource-group myrg --src-path ./app.zip
        ```
        **Step 3: Kubernetes Workload Identity**
        ```sh
        # Enable workload identity on AKS
        az aks update \
            --resource-group myrg \
            --name myakscluster \
            --enable-oidc-issuer \
            --enable-workload-identity

        # Get OIDC issuer URL
        oidcIssuer=$(az aks show --resource-group myrg --name myakscluster --query oidcIssuerProfile.issuerUrl -o tsv)

        # Create federated credential for Kubernetes service account
        az ad app federated-credential create \
            --id <app-object-id> \
            --parameters '{
                "name": "kubernetes-workload",
                "issuer": "'$oidcIssuer'",
                "subject": "system:serviceaccount:default:myserviceaccount",
                "audiences": ["api://AzureADTokenExchange"]
            }'
        ```
        **Step 4: Kubernetes Pod Configuration**
        ```yaml
        apiVersion: v1
        kind: ServiceAccount
        metadata:
            name: myserviceaccount
            namespace: default
            annotations:
                azure.workload.identity/client-id: <app-client-id>
        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
            name: myapp
        spec:
            template:
                metadata:
                    labels:
                        azure.workload.identity/use: "true"
                spec:
                    serviceAccountName: myserviceaccount
                    containers:
                        - name: myapp
                          image: myregistry.azurecr.io/myapp:v1
                          env:
                              - name: AZURE_CLIENT_ID
                                value: <app-client-id>
                              - name: AZURE_TENANT_ID
                                value: <tenant-id>
        ```
        **References:**
        - [Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation)
        - [AKS Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)

18. How do you implement Microsoft Graph API integration?
    - **Answer:**
        Use Microsoft Graph SDK to access user data, groups, mail, calendar, and other Microsoft 365 resources. Requires appropriate API permissions.
    - **Implementation:**
        **Step 1: Configure App Registration Permissions**
        ```sh
        # Add delegated permission
        az ad app permission add \
            --id <app-id> \
            --api 00000003-0000-0000-c000-000000000000 \
            --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope

        # Add application permission
        az ad app permission add \
            --id <app-id> \
            --api 00000003-0000-0000-c000-000000000000 \
            --api-permissions df021288-bdef-4463-88db-98f22de89214=Role

        # Grant admin consent
        az ad app permission admin-consent --id <app-id>
        ```
        **Step 2: Use Graph SDK in C#**
        ```csharp
        using Microsoft.Graph;
        using Azure.Identity;

        public class GraphService
        {
            private readonly GraphServiceClient _graphClient;

            public GraphService(IConfiguration config)
            {
                var credential = new ClientSecretCredential(
                    config["AzureAd:TenantId"],
                    config["AzureAd:ClientId"],
                    config["AzureAd:ClientSecret"]);

                _graphClient = new GraphServiceClient(credential,
                    new[] { "https://graph.microsoft.com/.default" });
            }

            // Get user profile
            public async Task<User> GetUserAsync(string userId)
            {
                return await _graphClient.Users[userId]
                    .GetAsync(config => config.QueryParameters.Select =
                        new[] { "displayName", "mail", "userPrincipalName", "id" });
            }

            // Get user's groups
            public async Task<List<Group>> GetUserGroupsAsync(string userId)
            {
                var memberOf = await _graphClient.Users[userId].MemberOf
                    .GetAsync();

                return memberOf.Value
                    .OfType<Group>()
                    .ToList();
            }

            // Send email on behalf of user
            public async Task SendMailAsync(string userId, string to, string subject, string body)
            {
                var message = new Message
                {
                    Subject = subject,
                    Body = new ItemBody
                    {
                        ContentType = BodyType.Html,
                        Content = body
                    },
                    ToRecipients = new List<Recipient>
                    {
                        new Recipient { EmailAddress = new EmailAddress { Address = to } }
                    }
                };

                await _graphClient.Users[userId]
                    .SendMail
                    .PostAsync(new SendMailPostRequestBody { Message = message });
            }

            // Create group
            public async Task<Group> CreateGroupAsync(string name, string description)
            {
                var group = new Group
                {
                    DisplayName = name,
                    Description = description,
                    MailEnabled = false,
                    MailNickname = name.Replace(" ", ""),
                    SecurityEnabled = true
                };

                return await _graphClient.Groups.PostAsync(group);
            }
        }
        ```
        **Step 3: On-Behalf-Of Flow**
        ```csharp
        public class OnBehalfOfGraphService
        {
            private readonly IConfidentialClientApplication _cca;

            public OnBehalfOfGraphService(IConfiguration config)
            {
                _cca = ConfidentialClientApplicationBuilder
                    .Create(config["AzureAd:ClientId"])
                    .WithClientSecret(config["AzureAd:ClientSecret"])
                    .WithAuthority($"https://login.microsoftonline.com/{config["AzureAd:TenantId"]}")
                    .Build();
            }

            public async Task<GraphServiceClient> GetGraphClientForUserAsync(string userAccessToken)
            {
                var userAssertion = new UserAssertion(userAccessToken);
                var result = await _cca.AcquireTokenOnBehalfOf(
                    new[] { "https://graph.microsoft.com/.default" },
                    userAssertion)
                    .ExecuteAsync();

                return new GraphServiceClient(
                    new DelegateAuthenticationProvider(request =>
                    {
                        request.Headers.Authorization =
                            new AuthenticationHeaderValue("Bearer", result.AccessToken);
                        return Task.CompletedTask;
                    }));
            }
        }
        ```
        **References:**
        - [Microsoft Graph SDK](https://learn.microsoft.com/en-us/graph/sdks/sdks-overview)
        - [Graph API Permissions](https://learn.microsoft.com/en-us/graph/permissions-reference)

19. How do you implement Privileged Identity Management (PIM)?
    - **Answer:**
        PIM provides just-in-time privileged access, enforces approval workflows, and maintains audit trails for elevated permissions.
    - **Implementation:**
        **Step 1: Configure PIM Settings via Graph API**
        ```csharp
        public class PimService
        {
            private readonly GraphServiceClient _graphClient;

            // Request role activation
            public async Task RequestRoleActivationAsync(
                string userId,
                string roleDefinitionId,
                string resourceScope,
                TimeSpan duration,
                string justification)
            {
                var scheduleRequest = new UnifiedRoleAssignmentScheduleRequest
                {
                    Action = UnifiedRoleScheduleRequestActions.SelfActivate,
                    PrincipalId = userId,
                    RoleDefinitionId = roleDefinitionId,
                    DirectoryScopeId = resourceScope,
                    Justification = justification,
                    ScheduleInfo = new RequestSchedule
                    {
                        StartDateTime = DateTimeOffset.UtcNow,
                        Expiration = new ExpirationPattern
                        {
                            Type = ExpirationPatternType.AfterDuration,
                            Duration = duration
                        }
                    }
                };

                await _graphClient.RoleManagement.Directory
                    .RoleAssignmentScheduleRequests
                    .PostAsync(scheduleRequest);
            }

            // Get pending approval requests
            public async Task<List<UnifiedRoleAssignmentScheduleRequest>> GetPendingApprovalsAsync()
            {
                var requests = await _graphClient.RoleManagement.Directory
                    .RoleAssignmentScheduleRequests
                    .GetAsync(config =>
                    {
                        config.QueryParameters.Filter = "status eq 'PendingApproval'";
                    });

                return requests.Value.ToList();
            }

            // Approve request
            public async Task ApproveRequestAsync(string requestId, string justification)
            {
                var approval = new Approval
                {
                    Stages = new List<ApprovalStage>
                    {
                        new ApprovalStage
                        {
                            ReviewResult = "Approve",
                            Justification = justification
                        }
                    }
                };

                // Note: Actual approval API call
            }
        }
        ```
        **Step 2: Configure Role Settings**
        ```sh
        # Configure PIM settings via Azure CLI/PowerShell
        # (Most PIM configuration requires Graph API or Portal)

        # Get role management policies
        az rest --method GET \
            --uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies" \
            --query "value[?contains(displayName, 'Contributor')]"
        ```
        **Step 3: Azure Function for PIM Notifications**
        ```csharp
        [Function("PimRoleActivated")]
        public async Task Run([EventGridTrigger] EventGridEvent eventGridEvent)
        {
            if (eventGridEvent.EventType == "Microsoft.Authorization.RoleAssignmentCreated")
            {
                var data = eventGridEvent.Data.ToObjectFromJson<RoleAssignmentEventData>();

                // Check if it's a privileged role
                if (IsPrivilegedRole(data.RoleDefinitionId))
                {
                    await _alertService.SendSecurityAlertAsync(
                        $"Privileged role {data.RoleDefinitionId} activated for {data.PrincipalId}");

                    await _auditService.LogPrivilegedAccessAsync(data);
                }
            }
        }
        ```
        **References:**
        - [Privileged Identity Management](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure)
        - [PIM API](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagementv3-overview)

20. How do you implement cross-tenant access?
    - **Answer:**
        Configure cross-tenant access settings to control B2B collaboration, external identities, and trust relationships between Azure AD tenants.
    - **Implementation:**
        **Step 1: Configure Cross-Tenant Access Policy**
        ```sh
        # Create cross-tenant access policy for partner tenant
        az rest --method POST \
            --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners" \
            --body '{
                "tenantId": "<partner-tenant-id>",
                "b2bCollaborationInbound": {
                    "usersAndGroups": {
                        "accessType": "allowed",
                        "targets": [
                            { "target": "AllUsers", "targetType": "user" }
                        ]
                    },
                    "applications": {
                        "accessType": "allowed",
                        "targets": [
                            { "target": "AllApplications", "targetType": "application" }
                        ]
                    }
                },
                "b2bCollaborationOutbound": {
                    "usersAndGroups": {
                        "accessType": "allowed",
                        "targets": [
                            { "target": "<security-group-id>", "targetType": "group" }
                        ]
                    }
                },
                "inboundTrust": {
                    "isMfaAccepted": true,
                    "isCompliantDeviceAccepted": true
                }
            }'
        ```
        **Step 2: Multi-Tenant Application Registration**
        ```json
        {
            "signInAudience": "AzureADMultipleOrgs",
            "identifierUris": ["api://<app-id>"],
            "api": {
                "oauth2PermissionScopes": [
                    {
                        "adminConsentDescription": "Allow the app to access resources",
                        "adminConsentDisplayName": "Access resources",
                        "id": "<scope-id>",
                        "isEnabled": true,
                        "type": "Admin",
                        "value": "access_as_user"
                    }
                ]
            }
        }
        ```
        **Step 3: Authenticate Cross-Tenant Users**
        ```csharp
        public class MultiTenantAuthService
        {
            public async Task<AuthenticationResult> AuthenticateAsync(string tenantId)
            {
                var app = ConfidentialClientApplicationBuilder
                    .Create(_clientId)
                    .WithClientSecret(_clientSecret)
                    .WithAuthority($"https://login.microsoftonline.com/{tenantId}")
                    .Build();

                return await app.AcquireTokenForClient(
                    new[] { "https://graph.microsoft.com/.default" })
                    .ExecuteAsync();
            }

            // Validate tokens from any tenant
            public TokenValidationParameters GetMultiTenantValidationParameters()
            {
                return new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuers = new[]
                    {
                        "https://login.microsoftonline.com/{tenantid}/v2.0",
                        "https://sts.windows.net/{tenantid}/"
                    },
                    IssuerValidator = (issuer, token, parameters) =>
                    {
                        // Custom validation for allowed tenants
                        var tenantId = GetTenantIdFromIssuer(issuer);
                        if (IsAllowedTenant(tenantId))
                        {
                            return issuer;
                        }
                        throw new SecurityTokenInvalidIssuerException("Tenant not allowed");
                    },
                    ValidAudience = _clientId,
                    ValidateLifetime = true
                };
            }
        }
        ```
        **Step 4: Cross-Tenant Resource Access**
        ```csharp
        [Authorize]
        public class CrossTenantController : ControllerBase
        {
            [HttpGet("resources")]
            public async Task<IActionResult> GetResources()
            {
                // Get caller's tenant ID
                var tenantId = User.FindFirst("tid")?.Value;

                // Check cross-tenant access policy
                if (!await _accessPolicyService.IsAllowedAsync(tenantId))
                {
                    return Forbid();
                }

                // Apply tenant-specific filtering
                var resources = await _resourceService.GetResourcesForTenantAsync(tenantId);

                return Ok(resources);
            }
        }
        ```
        **References:**
        - [Cross-Tenant Access](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/cross-tenant-access-overview)
        - [Multi-Tenant Apps](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-convert-app-to-be-multi-tenant)

### 3.3 Azure Networking Security
1. How do you secure web apps from DDoS?
    - **Answer:**
        Use Azure DDoS Protection Standard, WAF on Application Gateway, and NSGs.
    - **Implementation:**
        **Step 1: Enable DDoS Protection**
        ```sh
        az network ddos-protection create --resource-group myrg --name myddosplan
        az network vnet update --resource-group myrg --name myvnet --ddos-protection-plan myddosplan
        ```
        **Step 2: Configure WAF on Application Gateway**
        ```sh
        az network application-gateway waf-config set --gateway-name myappgw --resource-group myrg --enabled true --firewall-mode Prevention --rule-set-version 3.2
        ```
        **References:**
        - [Azure DDoS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)

2. How do you restrict access to APIs?
    - **Answer:**
        Use API Management policies, IP restrictions, client certificates, and OAuth validation.
    - **Implementation:**
        **Step 1: IP Restriction Policy**
        ```xml
        <inbound>
            <ip-filter action="allow">
                <address-range from="203.0.113.0" to="203.0.113.255"/>
            </ip-filter>
        </inbound>
        ```
        **Step 2: Require Subscription Key**
        ```xml
        <inbound>
            <check-header name="Ocp-Apim-Subscription-Key" failed-check-httpcode="401"/>
        </inbound>
        ```
        **References:**
        - [API Management Policies](https://learn.microsoft.com/en-us/azure/api-management/api-management-access-restriction-policies)

3. How do you secure traffic between services?
    - **Answer:**
        Use VNet integration, private endpoints, service endpoints, and mutual TLS.
    - **Implementation:**
        **Step 1: Create Private Endpoint**
        ```sh
        az network private-endpoint create --resource-group myrg --name myendpoint --vnet-name myvnet --subnet mysubnet --private-connection-resource-id <resource-id> --group-id <group-id> --connection-name myconnection
        ```
        **Step 2: Enable Service Endpoint**
        ```sh
        az network vnet subnet update --resource-group myrg --vnet-name myvnet --name mysubnet --service-endpoints Microsoft.Storage Microsoft.Sql
        ```
        **References:**
        - [Private Link](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview)

4. How do you monitor network security?
    - **Answer:**
        Use Azure Security Center, Network Watcher, NSG flow logs, and traffic analytics.
    - **Implementation:**
        **Step 1: Enable NSG Flow Logs**
        ```sh
        az network watcher flow-log create --resource-group myrg --nsg mynsg --storage-account mystorageaccount --enabled true --name myflowlog
        ```
        **Step 2: Query Network Traffic (Kusto)**
        ```kusto
        AzureNetworkAnalytics_CL
        | where FlowStatus_s == "Denied"
        | summarize count() by SrcIP_s, DestPort_d
        ```
        **References:**
        - [Network Watcher](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview)

5. How do you implement zero trust?
    - **Answer:**
        Apply least privilege, verify explicitly with strong authentication, micro-segment networks, and monitor continuously.
    - **Implementation:**
        **Step 1: Verify Explicitly**
        - Use Azure AD + MFA for all access
        - Validate device compliance via Conditional Access
        **Step 2: Use Least Privilege**
        - Implement RBAC with minimal permissions
        - Use PIM for elevated access
        **Step 3: Micro-segmentation**
        ```sh
        az network nsg rule create --resource-group myrg --nsg-name mynsg --name DenyAllInbound --priority 4096 --direction Inbound --access Deny --protocol '*'
        az network nsg rule create --resource-group myrg --nsg-name mynsg --name AllowWebTier --priority 100 --direction Inbound --access Allow --source-address-prefixes 10.0.1.0/24 --destination-port-ranges 80 443
        ```
        **References:**
        - [Zero Trust in Azure](https://learn.microsoft.com/en-us/azure/security/fundamentals/zero-trust)

6. How do you secure hybrid connections?
    - **Answer:**
        Use Site-to-Site VPN or ExpressRoute with private peering, and restrict access via NSGs and firewalls.
    - **Implementation:**
        **Step 1: Create VPN Gateway**
        ```sh
        az network vnet-gateway create --resource-group myrg --name myvpngw --vnet myvnet --gateway-type Vpn --vpn-type RouteBased --sku VpnGw1
        ```
        **Step 2: Create Site-to-Site Connection**
        ```sh
        az network vpn-connection create --resource-group myrg --name myconnection --vnet-gateway1 myvpngw --local-gateway2 mylocalgateway --shared-key <shared-key>
        ```
        **References:**
        - [Site-to-Site VPN](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-cli)

7. How do you automate network security configuration?
    - **Answer:**
        Use ARM/Bicep templates, Azure CLI, Terraform, or Azure Policy for consistent deployments.
    - **Implementation:**
        **Step 1: NSG Bicep Template**
        ```bicep
        resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
            name: 'mynsg'
            location: resourceGroup().location
            properties: {
                securityRules: [{
                    name: 'AllowHTTPS'
                    properties: {
                        priority: 100
                        direction: 'Inbound'
                        access: 'Allow'
                        protocol: 'Tcp'
                        sourceAddressPrefix: '*'
                        destinationPortRange: '443'
                    }
                }]
            }
        }
        ```
        **References:**
        - [Network ARM Templates](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups)

8. How do you audit network changes?
    - **Answer:**
        Use Activity Log, Azure Policy, change tracking, and alerts.
    - **Implementation:**
        **Step 1: Query Network Changes (Kusto)**
        ```kusto
        AzureActivity
        | where CategoryValue == "Administrative"
        | where ResourceProviderValue == "MICROSOFT.NETWORK"
        | project TimeGenerated, OperationNameValue, Caller, Properties
        ```
        **Step 2: Create Alert for NSG Changes**
        - Azure Monitor > Alerts > Activity Log > Operation: Create or Update NSG
        **References:**
        - [Azure Activity Log](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log)

9. How do you secure DNS in Azure?
    - **Answer:**
        Use Azure DNS with RBAC, private DNS zones for internal resolution, and DNSSEC where supported.
    - **Implementation:**
        **Step 1: Create Private DNS Zone**
        ```sh
        az network private-dns zone create --resource-group myrg --name private.contoso.com
        az network private-dns link vnet create --resource-group myrg --zone-name private.contoso.com --name mylink --virtual-network myvnet --registration-enabled true
        ```
        **Step 2: Add DNS Record**
        ```sh
        az network private-dns record-set a add-record --resource-group myrg --zone-name private.contoso.com --record-set-name myapp --ipv4-address 10.0.1.5
        ```
        **References:**
        - [Azure Private DNS](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)

10. How do you handle SSL/TLS certificates?
    - **Answer:**
        Store in Key Vault, automate renewal with App Service managed certificates or Let's Encrypt, enforce HTTPS.
    - **Implementation:**
        **Step 1: Import Certificate to Key Vault**
        ```sh
        az keyvault certificate import --vault-name myvault --name mycert --file mycert.pfx --password <password>
        ```
        **Step 2: Use Key Vault Reference in App Service**
        - App Service > TLS/SSL settings > Private Key Certificates > Import from Key Vault
        **Step 3: Enforce HTTPS**
        ```sh
        az webapp update --resource-group myrg --name myapp --https-only true
        ```
        **References:**
        - [App Service TLS](https://learn.microsoft.com/en-us/azure/app-service/configure-ssl-certificate)

11. How do you secure API endpoints?
    - **Answer:**
        Use OAuth/JWT validation, API Management policies, mutual TLS, and IP filtering.
    - **Implementation:**
        **Step 1: Validate JWT in API Management**
        ```xml
        <inbound>
            <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
                <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration"/>
                <audiences><audience>api://myapi</audience></audiences>
            </validate-jwt>
        </inbound>
        ```
        **Step 2: Require Client Certificate**
        ```xml
        <inbound>
            <validate-client-certificate validate-revocation="true" validate-trust="true"/>
        </inbound>
        ```
        **References:**
        - [API Management Security](https://learn.microsoft.com/en-us/azure/api-management/api-management-authentication-policies)

12. How do you monitor for suspicious activity?
    - **Answer:**
        Use Azure Security Center, Microsoft Defender for Cloud, set up alerts, and review recommendations.
    - **Implementation:**
        **Step 1: Enable Microsoft Defender**
        - Azure Portal > Microsoft Defender for Cloud > Environment settings > Enable plans
        **Step 2: Create Security Alert**
        ```kusto
        SecurityAlert
        | where AlertSeverity == "High"
        | project TimeGenerated, AlertName, Description, Entities
        ```
        **Step 3: Review Security Recommendations**
        - Defender for Cloud > Recommendations > Review and remediate
        **References:**
        - [Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)

13. How do you implement network segmentation?
    - **Answer:**
        Use VNets with subnets, NSGs for traffic control, Azure Firewall for centralized policies.
    - **Implementation:**
        **Step 1: Create Segmented VNet**
        ```sh
        az network vnet create --resource-group myrg --name myvnet --address-prefix 10.0.0.0/16
        az network vnet subnet create --resource-group myrg --vnet-name myvnet --name web-tier --address-prefix 10.0.1.0/24
        az network vnet subnet create --resource-group myrg --vnet-name myvnet --name app-tier --address-prefix 10.0.2.0/24
        az network vnet subnet create --resource-group myrg --vnet-name myvnet --name data-tier --address-prefix 10.0.3.0/24
        ```
        **Step 2: Apply NSGs to Subnets**
        ```sh
        az network vnet subnet update --resource-group myrg --vnet-name myvnet --name web-tier --network-security-group web-nsg
        ```
        **References:**
        - [Network Segmentation](https://learn.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)

14. How do you secure outbound traffic?
    - **Answer:**
        Use NSGs, Azure Firewall with application rules, and User Defined Routes.
    - **Implementation:**
        **Step 1: Create Azure Firewall**
        ```sh
        az network firewall create --resource-group myrg --name myfw --location eastus
        ```
        **Step 2: Add Application Rule**
        ```sh
        az network firewall application-rule create --firewall-name myfw --resource-group myrg --collection-name AllowedSites --name AllowMicrosoft --protocols https=443 --source-addresses 10.0.0.0/16 --target-fqdns *.microsoft.com --action Allow --priority 100
        ```
        **Step 3: Route Traffic Through Firewall**
        ```sh
        az network route-table route create --resource-group myrg --route-table-name myrt --name ToInternet --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address <firewall-private-ip>
        ```
        **References:**
        - [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview)

15. How do you test network security?
    - **Answer:**
        Use penetration testing (with authorization), vulnerability scans, and Azure Security Center assessments.
    - **Implementation:**
        **Step 1: Request Pen Test Authorization**
        - Azure requires notification for penetration testing
        - Submit via Azure Support
        **Step 2: Use Network Watcher Diagnostics**
        ```sh
        az network watcher test-connectivity --resource-group myrg --source-resource myvm --dest-address www.microsoft.com --dest-port 443
        ```
        **Step 3: Review Security Score**
        - Defender for Cloud > Security posture > Review score and recommendations
        **References:**
        - [Azure Penetration Testing](https://learn.microsoft.com/en-us/azure/security/fundamentals/pen-testing)

16. How do you implement Azure Front Door with WAF?
    - **Answer:**
        Azure Front Door provides global load balancing with Web Application Firewall for DDoS protection, SSL termination, and caching at the edge.
    - **Implementation:**
        **Step 1: Create Front Door with WAF Policy**
        ```sh
        # Create WAF policy
        az network front-door waf-policy create \
            --name myWafPolicy \
            --resource-group myrg \
            --sku Premium_AzureFrontDoor

        # Configure managed rules
        az network front-door waf-policy managed-rules add \
            --policy-name myWafPolicy \
            --resource-group myrg \
            --type Microsoft_DefaultRuleSet \
            --version 2.1

        az network front-door waf-policy managed-rules add \
            --policy-name myWafPolicy \
            --resource-group myrg \
            --type Microsoft_BotManagerRuleSet \
            --version 1.0

        # Create custom rule
        az network front-door waf-policy rule create \
            --policy-name myWafPolicy \
            --resource-group myrg \
            --name BlockBadBots \
            --priority 100 \
            --rule-type MatchRule \
            --action Block \
            --match-variable RequestHeader \
            --operator Contains \
            --match-values "BadBot" "Scraper" \
            --selector "User-Agent"
        ```
        **Step 2: Create Front Door Profile**
        ```sh
        # Create Front Door
        az afd profile create \
            --profile-name myFrontDoor \
            --resource-group myrg \
            --sku Premium_AzureFrontDoor

        # Add endpoint
        az afd endpoint create \
            --endpoint-name myendpoint \
            --profile-name myFrontDoor \
            --resource-group myrg

        # Add origin group
        az afd origin-group create \
            --origin-group-name myOriginGroup \
            --profile-name myFrontDoor \
            --resource-group myrg \
            --probe-request-type GET \
            --probe-protocol Https \
            --probe-path /health

        # Add origin
        az afd origin create \
            --origin-name myOrigin \
            --origin-group-name myOriginGroup \
            --profile-name myFrontDoor \
            --resource-group myrg \
            --host-name mywebapp.azurewebsites.net \
            --origin-host-header mywebapp.azurewebsites.net \
            --http-port 80 \
            --https-port 443 \
            --priority 1 \
            --weight 1000

        # Create route with WAF
        az afd route create \
            --route-name myRoute \
            --endpoint-name myendpoint \
            --profile-name myFrontDoor \
            --resource-group myrg \
            --origin-group myOriginGroup \
            --supported-protocols Https \
            --https-redirect Enabled \
            --link-to-default-domain Enabled
        ```
        **Step 3: Associate WAF Policy with Endpoint**
        ```sh
        az afd security-policy create \
            --security-policy-name mySecurityPolicy \
            --profile-name myFrontDoor \
            --resource-group myrg \
            --waf-policy /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies/myWafPolicy \
            --domains /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Cdn/profiles/myFrontDoor/afdEndpoints/myendpoint
        ```
        **Step 4: Bicep Template**
        ```bicep
        resource frontDoor 'Microsoft.Cdn/profiles@2023-05-01' = {
            name: 'myFrontDoor'
            location: 'global'
            sku: { name: 'Premium_AzureFrontDoor' }
        }

        resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
            name: 'myWafPolicy'
            location: 'global'
            sku: { name: 'Premium_AzureFrontDoor' }
            properties: {
                policySettings: {
                    enabledState: 'Enabled'
                    mode: 'Prevention'
                }
                managedRules: {
                    managedRuleSets: [
                        { ruleSetType: 'Microsoft_DefaultRuleSet', ruleSetVersion: '2.1' }
                        { ruleSetType: 'Microsoft_BotManagerRuleSet', ruleSetVersion: '1.0' }
                    ]
                }
            }
        }
        ```
        **References:**
        - [Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview)
        - [WAF on Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)

17. How do you implement Virtual Network peering and hub-spoke topology?
    - **Answer:**
        VNet peering connects VNets for private communication. Hub-spoke topology centralizes shared services (firewall, VPN) in a hub VNet connected to spoke VNets.
    - **Implementation:**
        **Step 1: Create Hub VNet**
        ```sh
        # Create hub VNet
        az network vnet create \
            --name hub-vnet \
            --resource-group myrg \
            --address-prefixes 10.0.0.0/16 \
            --subnet-name GatewaySubnet \
            --subnet-prefixes 10.0.0.0/24

        az network vnet subnet create \
            --vnet-name hub-vnet \
            --resource-group myrg \
            --name AzureFirewallSubnet \
            --address-prefixes 10.0.1.0/24

        az network vnet subnet create \
            --vnet-name hub-vnet \
            --resource-group myrg \
            --name SharedServicesSubnet \
            --address-prefixes 10.0.2.0/24
        ```
        **Step 2: Create Spoke VNets**
        ```sh
        # Spoke 1
        az network vnet create \
            --name spoke1-vnet \
            --resource-group myrg \
            --address-prefixes 10.1.0.0/16 \
            --subnet-name WorkloadSubnet \
            --subnet-prefixes 10.1.0.0/24

        # Spoke 2
        az network vnet create \
            --name spoke2-vnet \
            --resource-group myrg \
            --address-prefixes 10.2.0.0/16 \
            --subnet-name WorkloadSubnet \
            --subnet-prefixes 10.2.0.0/24
        ```
        **Step 3: Create VNet Peerings**
        ```sh
        # Hub to Spoke 1
        az network vnet peering create \
            --name hub-to-spoke1 \
            --resource-group myrg \
            --vnet-name hub-vnet \
            --remote-vnet spoke1-vnet \
            --allow-vnet-access \
            --allow-forwarded-traffic \
            --allow-gateway-transit

        az network vnet peering create \
            --name spoke1-to-hub \
            --resource-group myrg \
            --vnet-name spoke1-vnet \
            --remote-vnet hub-vnet \
            --allow-vnet-access \
            --allow-forwarded-traffic \
            --use-remote-gateways

        # Hub to Spoke 2
        az network vnet peering create \
            --name hub-to-spoke2 \
            --resource-group myrg \
            --vnet-name hub-vnet \
            --remote-vnet spoke2-vnet \
            --allow-vnet-access \
            --allow-forwarded-traffic \
            --allow-gateway-transit

        az network vnet peering create \
            --name spoke2-to-hub \
            --resource-group myrg \
            --vnet-name spoke2-vnet \
            --remote-vnet hub-vnet \
            --allow-vnet-access \
            --allow-forwarded-traffic \
            --use-remote-gateways
        ```
        **Step 4: Deploy Azure Firewall in Hub**
        ```sh
        az network firewall create \
            --name myFirewall \
            --resource-group myrg \
            --location eastus \
            --vnet-name hub-vnet \
            --sku AZFW_VNet

        # Create route table for spoke traffic
        az network route-table create \
            --name spoke-route-table \
            --resource-group myrg

        az network route-table route create \
            --route-table-name spoke-route-table \
            --resource-group myrg \
            --name to-internet \
            --address-prefix 0.0.0.0/0 \
            --next-hop-type VirtualAppliance \
            --next-hop-ip-address 10.0.1.4  # Firewall private IP
        ```
        **References:**
        - [VNet Peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
        - [Hub-Spoke Topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)

18. How do you implement network traffic filtering with NSGs and ASGs?
    - **Answer:**
        Network Security Groups filter traffic at subnet/NIC level. Application Security Groups allow grouping VMs by function for easier rule management.
    - **Implementation:**
        **Step 1: Create Application Security Groups**
        ```sh
        # Create ASGs
        az network asg create --name WebServers --resource-group myrg
        az network asg create --name AppServers --resource-group myrg
        az network asg create --name DbServers --resource-group myrg
        ```
        **Step 2: Create NSG with ASG Rules**
        ```sh
        az network nsg create --name myNSG --resource-group myrg

        # Allow HTTP/HTTPS to web servers from internet
        az network nsg rule create \
            --nsg-name myNSG \
            --resource-group myrg \
            --name AllowWebFromInternet \
            --priority 100 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --source-address-prefixes Internet \
            --destination-asgs WebServers \
            --destination-port-ranges 80 443

        # Allow web servers to app servers
        az network nsg rule create \
            --nsg-name myNSG \
            --resource-group myrg \
            --name AllowWebToApp \
            --priority 110 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --source-asgs WebServers \
            --destination-asgs AppServers \
            --destination-port-ranges 8080

        # Allow app servers to DB servers
        az network nsg rule create \
            --nsg-name myNSG \
            --resource-group myrg \
            --name AllowAppToDb \
            --priority 120 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --source-asgs AppServers \
            --destination-asgs DbServers \
            --destination-port-ranges 1433

        # Deny all other inbound
        az network nsg rule create \
            --nsg-name myNSG \
            --resource-group myrg \
            --name DenyAllInbound \
            --priority 4096 \
            --direction Inbound \
            --access Deny \
            --protocol '*' \
            --source-address-prefixes '*' \
            --destination-address-prefixes '*' \
            --destination-port-ranges '*'
        ```
        **Step 3: Associate NICs with ASGs**
        ```sh
        # Add VM NIC to ASG
        az network nic ip-config update \
            --resource-group myrg \
            --nic-name web-vm-nic \
            --name ipconfig1 \
            --application-security-groups WebServers
        ```
        **Step 4: Bicep Template**
        ```bicep
        resource webAsg 'Microsoft.Network/applicationSecurityGroups@2023-04-01' = {
            name: 'WebServers'
            location: resourceGroup().location
        }

        resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
            name: 'myNSG'
            location: resourceGroup().location
            properties: {
                securityRules: [
                    {
                        name: 'AllowWebFromInternet'
                        properties: {
                            priority: 100
                            direction: 'Inbound'
                            access: 'Allow'
                            protocol: 'Tcp'
                            sourceAddressPrefix: 'Internet'
                            destinationApplicationSecurityGroups: [{ id: webAsg.id }]
                            destinationPortRanges: ['80', '443']
                            sourcePortRange: '*'
                        }
                    }
                ]
            }
        }
        ```
        **References:**
        - [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
        - [Application Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups)

19. How do you implement Azure Bastion for secure VM access?
    - **Answer:**
        Azure Bastion provides secure RDP/SSH access to VMs without exposing public IPs. It eliminates the need for jump boxes and VPN connections.
    - **Implementation:**
        **Step 1: Create Bastion Host**
        ```sh
        # Create AzureBastionSubnet (required name)
        az network vnet subnet create \
            --vnet-name myvnet \
            --resource-group myrg \
            --name AzureBastionSubnet \
            --address-prefixes 10.0.255.0/26

        # Create public IP for Bastion
        az network public-ip create \
            --name bastion-pip \
            --resource-group myrg \
            --sku Standard \
            --allocation-method Static

        # Create Bastion host
        az network bastion create \
            --name myBastion \
            --resource-group myrg \
            --vnet-name myvnet \
            --public-ip-address bastion-pip \
            --sku Standard \
            --enable-tunneling true \
            --enable-ip-connect true
        ```
        **Step 2: Connect to VM via Bastion**
        ```sh
        # Connect using native client (requires Bastion Standard SKU)
        az network bastion ssh \
            --name myBastion \
            --resource-group myrg \
            --target-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm \
            --auth-type password \
            --username azureuser

        # RDP connection
        az network bastion rdp \
            --name myBastion \
            --resource-group myrg \
            --target-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/mywindowsvm
        ```
        **Step 3: Shareable Link (Standard SKU)**
        ```sh
        # Create shareable link
        az network bastion create-shareable-link \
            --name myBastion \
            --resource-group myrg \
            --target-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Compute/virtualMachines/myvm
        ```
        **Step 4: Bicep Template**
        ```bicep
        resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
            parent: vnet
            name: 'AzureBastionSubnet'
            properties: {
                addressPrefix: '10.0.255.0/26'
            }
        }

        resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
            name: 'bastion-pip'
            location: resourceGroup().location
            sku: { name: 'Standard' }
            properties: { publicIPAllocationMethod: 'Static' }
        }

        resource bastion 'Microsoft.Network/bastionHosts@2023-04-01' = {
            name: 'myBastion'
            location: resourceGroup().location
            sku: { name: 'Standard' }
            properties: {
                enableTunneling: true
                enableIpConnect: true
                ipConfigurations: [
                    {
                        name: 'bastionIpConfig'
                        properties: {
                            subnet: { id: bastionSubnet.id }
                            publicIPAddress: { id: bastionPip.id }
                        }
                    }
                ]
            }
        }
        ```
        **References:**
        - [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
        - [Connect via Native Client](https://learn.microsoft.com/en-us/azure/bastion/connect-native-client-windows)

20. How do you implement Azure Private DNS zones?
    - **Answer:**
        Private DNS zones provide name resolution within VNets without exposing DNS queries to the internet. Required for Private Endpoints to work correctly.
    - **Implementation:**
        **Step 1: Create Private DNS Zone**
        ```sh
        # Create private DNS zone
        az network private-dns zone create \
            --resource-group myrg \
            --name privatelink.blob.core.windows.net

        # Link to VNet
        az network private-dns link vnet create \
            --resource-group myrg \
            --zone-name privatelink.blob.core.windows.net \
            --name storage-dns-link \
            --virtual-network myvnet \
            --registration-enabled false
        ```
        **Step 2: Create Custom Private DNS Zone**
        ```sh
        # Custom domain for internal apps
        az network private-dns zone create \
            --resource-group myrg \
            --name internal.mycompany.com

        # Link to VNet with auto-registration
        az network private-dns link vnet create \
            --resource-group myrg \
            --zone-name internal.mycompany.com \
            --name internal-link \
            --virtual-network myvnet \
            --registration-enabled true

        # Add A record
        az network private-dns record-set a create \
            --resource-group myrg \
            --zone-name internal.mycompany.com \
            --name webapp

        az network private-dns record-set a add-record \
            --resource-group myrg \
            --zone-name internal.mycompany.com \
            --record-set-name webapp \
            --ipv4-address 10.0.1.10
        ```
        **Step 3: Private Endpoint DNS Integration**
        ```sh
        # Create private endpoint with DNS zone group
        az network private-endpoint create \
            --name storage-pe \
            --resource-group myrg \
            --vnet-name myvnet \
            --subnet mysubnet \
            --private-connection-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount \
            --group-id blob \
            --connection-name storage-connection

        az network private-endpoint dns-zone-group create \
            --resource-group myrg \
            --endpoint-name storage-pe \
            --name storage-dns-group \
            --private-dns-zone privatelink.blob.core.windows.net \
            --zone-name blob
        ```
        **Step 4: Bicep Template**
        ```bicep
        resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
            name: 'privatelink.blob.core.windows.net'
            location: 'global'
        }

        resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
            parent: privateDnsZone
            name: 'vnet-link'
            location: 'global'
            properties: {
                registrationEnabled: false
                virtualNetwork: { id: vnet.id }
            }
        }

        resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
            name: 'storage-pe'
            location: resourceGroup().location
            properties: {
                subnet: { id: subnet.id }
                privateLinkServiceConnections: [
                    {
                        name: 'storage-connection'
                        properties: {
                            privateLinkServiceId: storageAccount.id
                            groupIds: ['blob']
                        }
                    }
                ]
            }
        }

        resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
            parent: privateEndpoint
            name: 'default'
            properties: {
                privateDnsZoneConfigs: [
                    {
                        name: 'blob-dns'
                        properties: {
                            privateDnsZoneId: privateDnsZone.id
                        }
                    }
                ]
            }
        }
        ```
        **References:**
        - [Private DNS Zones](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
        - [Private Endpoint DNS](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)


## 4. Monitoring, Troubleshooting, and Optimization (App Insights, Monitor, Diagnostics)


### 4.1 Application Insights
1. How do you instrument an app for telemetry?
     - **Answer:**
         Install the Application Insights SDK, configure the instrumentation key, and add custom events/metrics in your code.
     - **Implementation:**
         **Step 1: Add NuGet Package**
         - Microsoft.ApplicationInsights.AspNetCore
         **Step 2: Configure in Program.cs (ASP.NET Core 6+)**
         ```csharp
         var builder = WebApplication.CreateBuilder(args);
         builder.Services.AddApplicationInsightsTelemetry("<instrumentation-key>");
         var app = builder.Build();
         app.MapGet("/", () => "Hello World!");
         app.Run();
         ```
         **Step 3: Track Custom Events**
         ```csharp
         using Microsoft.ApplicationInsights;
         var telemetry = new TelemetryClient();
         telemetry.TrackEvent("UserLoggedIn");
         ```
         **References:**
         - [Application Insights for ASP.NET Core](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core)

2. How do you track dependencies?
     - **Answer:**
         Enable dependency tracking in Application Insights and use telemetry initializers for custom dependencies.
     - **Implementation:**
         **Step 1: Automatic Dependency Tracking**
         - Application Insights automatically tracks HTTP, SQL, and other dependencies.
         **Step 2: Track Custom Dependency (C#)**
         ```csharp
         var telemetry = new TelemetryClient();
         var dependencyId = telemetry.StartOperation<DependencyTelemetry>("CustomDependency");
         // ... call external service ...
         telemetry.StopOperation(dependencyId);
         ```
         **References:**
         - [Dependency tracking](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-dependencies)

3. How do you correlate logs across services?
     - **Answer:**
         Use operation and parent IDs, and propagate context in distributed tracing.
     - **Implementation:**
         **Step 1: Enable Distributed Tracing**
         - Application Insights supports W3C Trace Context by default in .NET Core 3.1+.
         **Step 2: Propagate Trace Context**
         - Pass traceparent and tracestate headers in HTTP calls between services.
         **Step 3: Access Correlation Data in Code**
         ```csharp
         var operationId = Activity.Current?.RootId;
         var parentId = Activity.Current?.ParentId;
         ```
         **References:**
         - [Distributed tracing](https://learn.microsoft.com/en-us/azure/azure-monitor/app/distributed-tracing)

4. How do you set up alerts?
     - **Answer:**
         Define metric or log-based alerts in Azure Monitor.
     - **Implementation:**
         **Step 1: Create Alert Rule in Portal**
         - Application Insights > Alerts > New alert rule
         - Select metric (e.g., Server response time) or log query
         - Set condition, threshold, and action group
         **References:**
         - [Alerts in Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)

5. How do you analyze failures?
     - **Answer:**
         Use the Failure blade in Application Insights, review exceptions, and failed requests.
     - **Implementation:**
         **Step 1: Application Insights > Failures**
         - Review exception and failed request trends
         - Drill into stack traces and request details
         **Step 2: Query Failures in Analytics**
         ```kusto
         exceptions
         | where timestamp > ago(1d)
         | summarize count() by type, outerMessage
         ```
         **References:**
         - [Failure diagnostics](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-exceptions)

6. How do you monitor live metrics?
     - **Answer:**
         Use Live Metrics Stream for real-time monitoring.
     - **Implementation:**
         **Step 1: Application Insights > Live Metrics**
         - View real-time requests, failures, and performance
         **References:**
         - [Live Metrics Stream](https://learn.microsoft.com/en-us/azure/azure-monitor/app/live-stream)

7. How do you export telemetry?
     - **Answer:**
         Use Continuous Export or Diagnostic Settings to send data to Log Analytics or Event Hub.
     - **Implementation:**
         **Step 1: Application Insights > Diagnostic settings > Add diagnostic setting**
         - Choose destination: Log Analytics, Event Hub, or Storage Account
         **References:**
         - [Export telemetry](https://learn.microsoft.com/en-us/azure/azure-monitor/app/export-telemetry)

8. How do you reduce telemetry costs?
     - **Answer:**
         Sample data, filter unnecessary telemetry, and set retention policies.
     - **Implementation:**
         **Step 1: Configure Sampling in host.json or appsettings.json**
         ```json
         {
             "ApplicationInsights": {
                 "SamplingSettings": {
                     "IsEnabled": true,
                     "MaxTelemetryItemsPerSecond": 5
                 }
             }
         }
         ```
         **Step 2: Filter Telemetry in Code**
         ```csharp
         builder.Services.AddApplicationInsightsTelemetry(options =>
         {
                 options.EnableAdaptiveSampling = true;
                 options.SamplingPercentage = 10;
         });
         ```
         **References:**
         - [Sampling in Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/sampling)

9. How do you monitor user behavior?
     - **Answer:**
         Use custom events, user/session tracking, and funnels.
     - **Implementation:**
         **Step 1: Track Custom Events**
         ```csharp
         var telemetry = new TelemetryClient();
         telemetry.TrackEvent("ButtonClicked", new Dictionary<string, string> { { "ButtonName", "Save" } });
         ```
         **Step 2: Analyze in Application Insights > Users**
         - Review user/session flows and funnels
         **References:**
         - [User behavior analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/app/usage-segmentation)

10. How do you integrate with dashboards?
     - **Answer:**
         Pin charts to Azure dashboards or use Power BI integration.
     - **Implementation:**
         **Step 1: Application Insights > Metrics > Pin to dashboard**
         **Step 2: Export Analytics query to Power BI**
         - Application Insights > Analytics > Export > Power BI (M query)
         **References:**
         - [Azure dashboards](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks)

11. How do you monitor performance bottlenecks?
     - **Answer:**
         Use the performance blade, analyze dependencies, and review slow requests.
     - **Implementation:**
         **Step 1: Application Insights > Performance**
         - Review slowest requests and dependencies
         **Step 2: Drill into traces and stack traces
         **References:**
         - [Performance monitoring](https://learn.microsoft.com/en-us/azure/azure-monitor/app/performance)

12. How do you handle GDPR compliance?
     - **Answer:**
         Mask PII, set data retention, and honor user requests for data deletion.
     - **Implementation:**
         **Step 1: Mask PII in Telemetry**
         ```csharp
         telemetry.TrackEvent("UserAction", new Dictionary<string, string> { { "UserId", "[REDACTED]" } });
         ```
         **Step 2: Set Data Retention in Portal**
         - Application Insights > Usage and estimated costs > Data retention
         **Step 3: Delete User Data**
         - Application Insights > Search > Find user/session > Delete
         **References:**
         - [GDPR and Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/gdpr)

13. How do you monitor custom metrics?
     - **Answer:**
         Track custom metrics via SDK and query in Analytics.
     - **Implementation:**
         **Step 1: Track Custom Metric**
         ```csharp
         var telemetry = new TelemetryClient();
         telemetry.GetMetric("CustomMetric").TrackValue(42);
         ```
         **Step 2: Query in Analytics**
         ```kusto
         customMetrics
         | where name == "CustomMetric"
         ```
         **References:**
         - [Custom metrics](https://learn.microsoft.com/en-us/azure/azure-monitor/app/metrics)

14. How do you automate incident response?
     - **Answer:**
         Use Action Groups to trigger Logic Apps, Functions, or notifications.
     - **Implementation:**
         **Step 1: Create Action Group**
         - Azure Monitor > Action Groups > Create
         **Step 2: Link to Alert Rule**
         - Application Insights > Alerts > New alert rule > Action group
         **Step 3: Trigger Logic App/Function**
         - Action Group > Actions > Logic App/Function
         **References:**
         - [Action Groups](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups)

15. How do you test telemetry locally?
     - **Answer:**
         Use emulator or debug output, and verify in Application Insights portal.
     - **Implementation:**
         **Step 1: Run App Locally with Instrumentation Key**
         - Set APPINSIGHTS_INSTRUMENTATIONKEY in local.settings.json or environment variable
         **Step 2: Use Debug Output**
         - Check console/log output for telemetry events
         **Step 3: Verify Events in Application Insights Portal**
         - Application Insights > Search > Find your events
         **References:**
         - [Local development with Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core#local-development)

16. How do you implement distributed tracing across microservices?
    - **Answer:**
        Use Application Insights with W3C Trace Context for automatic correlation. The SDK propagates trace IDs across HTTP calls and messaging systems.
    - **Implementation:**
        **Step 1: Enable W3C Correlation**
        ```csharp
        builder.Services.AddApplicationInsightsTelemetry(options =>
        {
            options.EnableW3CDistributedTracing = true;
            options.EnableRequestTrackingTelemetryModule = true;
            options.EnableDependencyTrackingTelemetryModule = true;
        });

        builder.Services.AddHttpClient("downstream")
            .AddHttpMessageHandler<CorrelatingHandler>();
        ```
        **Step 2: Custom Activity for Non-HTTP Operations**
        ```csharp
        public class OrderService
        {
            private readonly TelemetryClient _telemetry;

            public async Task ProcessOrderAsync(Order order)
            {
                using var activity = new Activity("ProcessOrder");
                activity.SetTag("orderId", order.Id);
                activity.Start();

                using (_telemetry.StartOperation<RequestTelemetry>("ProcessOrder"))
                {
                    // Step 1: Validate
                    using (_telemetry.StartOperation<DependencyTelemetry>("ValidateOrder"))
                    {
                        await ValidateOrderAsync(order);
                    }

                    // Step 2: Reserve inventory
                    using (_telemetry.StartOperation<DependencyTelemetry>("ReserveInventory"))
                    {
                        await _inventoryService.ReserveAsync(order);
                    }

                    // Step 3: Process payment
                    using (_telemetry.StartOperation<DependencyTelemetry>("ProcessPayment"))
                    {
                        await _paymentService.ChargeAsync(order);
                    }
                }
            }
        }
        ```
        **Step 3: Query Distributed Traces with KQL**
        ```kusto
        // End-to-end transaction view
        union requests, dependencies, traces, exceptions
        | where operation_Id == "<operation-id>"
        | project timestamp, itemType, name, duration, success,
                  operation_ParentId, id, cloud_RoleName
        | order by timestamp asc

        // Find slow cross-service calls
        dependencies
        | where duration > 1000
        | summarize count(), avg(duration) by target, name, cloud_RoleName
        | order by avg_duration desc

        // Service dependency map
        dependencies
        | where timestamp > ago(1h)
        | summarize calls = count() by source = cloud_RoleName, target
        | where source != target
        ```
        **References:**
        - [Distributed Tracing](https://learn.microsoft.com/en-us/azure/azure-monitor/app/distributed-tracing)
        - [Correlation in Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/correlation)

17. How do you implement Application Insights availability tests?
    - **Answer:**
        Availability tests probe your application endpoints from multiple Azure regions. Use URL ping tests for basic monitoring or multi-step web tests for complex scenarios.
    - **Implementation:**
        **Step 1: Create URL Ping Test via CLI**
        ```sh
        az monitor app-insights web-test create \
            --resource-group myrg \
            --app-insights myappinsights \
            --web-test-name "Homepage Availability" \
            --web-test-kind "ping" \
            --location "East US" \
            --frequency 300 \
            --timeout 120 \
            --enabled true \
            --retry-enabled true \
            --locations "us-tx-sn1-azr" "us-il-ch1-azr" "emea-nl-ams-azr" "apac-jp-kaw-edge" \
            --defined-web-test-name "Homepage" \
            --request-url "https://myapp.azurewebsites.net/health"
        ```
        **Step 2: Create Standard Test with Validation**
        ```csharp
        // Using Application Insights SDK to create test
        var webTest = new WebTest
        {
            Name = "API Health Check",
            Kind = WebTestKind.Standard,
            Locations = new[]
            {
                new WebTestGeolocation { Location = "us-ca-sjc-azr" },
                new WebTestGeolocation { Location = "emea-gb-db3-azr" }
            },
            Request = new WebTestPropertiesRequest
            {
                RequestUrl = "https://api.myapp.com/health",
                HttpVerb = "GET",
                Headers = new[]
                {
                    new HeaderField { Name = "X-API-Key", Value = "{{ApiKey}}" }
                }
            },
            ValidationRules = new WebTestPropertiesValidationRules
            {
                ExpectedHttpStatusCode = 200,
                ContentValidation = new WebTestPropertiesContentValidation
                {
                    ContentMatch = "\"status\":\"healthy\"",
                    IgnoreCase = true
                },
                SslCheck = true
            }
        };
        ```
        **Step 3: Create Alert for Availability Test**
        ```sh
        az monitor metrics alert create \
            --name "Availability Alert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/components/myappinsights \
            --condition "avg availabilityResults/availabilityPercentage < 99" \
            --window-size 5m \
            --evaluation-frequency 1m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/oncall
        ```
        **Step 4: Query Availability Results**
        ```kusto
        availabilityResults
        | where timestamp > ago(24h)
        | summarize SuccessRate = 100.0 * countif(success == true) / count(),
                    AvgDuration = avg(duration),
                    Tests = count()
          by location, name
        | order by SuccessRate asc
        ```
        **References:**
        - [Availability Tests](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-overview)
        - [Standard Availability Tests](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-standard-tests)

18. How do you implement smart detection and alerts?
    - **Answer:**
        Smart detection uses machine learning to automatically detect performance anomalies, failure patterns, and potential issues without manual threshold configuration.
    - **Implementation:**
        **Step 1: Configure Smart Detection Rules**
        ```sh
        # List smart detection rules
        az rest --method GET \
            --uri "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/components/myappinsights/ProactiveDetectionConfigs?api-version=2015-05-01"

        # Update smart detection rule
        az rest --method PUT \
            --uri "https://management.azure.com/subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/components/myappinsights/ProactiveDetectionConfigs/slowpageloadtime?api-version=2015-05-01" \
            --body '{
                "name": "slowpageloadtime",
                "properties": {
                    "ruleDefinitions": {
                        "name": "Slow page load time",
                        "isEnabled": true,
                        "sendEmailsToSubscriptionOwners": true,
                        "customEmails": ["alerts@mycompany.com"]
                    }
                }
            }'
        ```
        **Step 2: Create Custom Metric Alert**
        ```csharp
        // Track custom metric for alerting
        public class PerformanceMonitor
        {
            private readonly TelemetryClient _telemetry;

            public void TrackQueueDepth(string queueName, int depth)
            {
                _telemetry.TrackMetric(new MetricTelemetry
                {
                    Name = "QueueDepth",
                    Sum = depth,
                    Properties = { ["QueueName"] = queueName }
                });

                // Track as aggregated metric
                _telemetry.GetMetric("QueueDepth", "QueueName")
                    .TrackValue(depth, queueName);
            }
        }
        ```
        **Step 3: Create Dynamic Threshold Alert**
        ```sh
        az monitor metrics alert create \
            --name "Dynamic Response Time Alert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/components/myappinsights \
            --condition "avg requests/duration > dynamic upper strictness high" \
            --window-size 5m \
            --evaluation-frequency 1m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/oncall
        ```
        **Step 4: Query Smart Detection Events**
        ```kusto
        // View smart detection alerts
        traces
        | where customDimensions.Category == "SmartDetection"
        | project timestamp, message, customDimensions
        | order by timestamp desc

        // Anomaly detection pattern
        requests
        | make-series RequestCount = count() on timestamp from ago(7d) to now() step 1h
        | extend anomalies = series_decompose_anomalies(RequestCount, 1.5)
        | mv-expand timestamp, RequestCount, anomalies
        | where anomalies != 0
        ```
        **References:**
        - [Smart Detection](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/proactive-diagnostics)
        - [Dynamic Thresholds](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-dynamic-thresholds)

19. How do you implement application map and dependency tracking?
    - **Answer:**
        Application Map visualizes dependencies between components. SDK automatically tracks HTTP, SQL, Redis, and other dependencies, showing health and call volumes.
    - **Implementation:**
        **Step 1: Enable Dependency Tracking**
        ```csharp
        builder.Services.AddApplicationInsightsTelemetry(options =>
        {
            options.EnableDependencyTrackingTelemetryModule = true;
            options.DependencyTrackingTelemetryModule = new DependencyTrackingTelemetryModule
            {
                ExcludeComponentCorrelationHttpHeadersOnDomains = new List<string>
                {
                    "core.windows.net",
                    "localhost"
                },
                EnableW3CHeadersInjection = true
            };
        });
        ```
        **Step 2: Custom Dependency Tracking**
        ```csharp
        public class ExternalApiClient
        {
            private readonly TelemetryClient _telemetry;

            public async Task<T> CallExternalApiAsync<T>(string endpoint)
            {
                var startTime = DateTimeOffset.UtcNow;
                var timer = Stopwatch.StartNew();
                var success = false;

                try
                {
                    var result = await _httpClient.GetFromJsonAsync<T>(endpoint);
                    success = true;
                    return result;
                }
                finally
                {
                    timer.Stop();

                    var dependency = new DependencyTelemetry
                    {
                        Name = "ExternalAPI",
                        Target = new Uri(endpoint).Host,
                        Data = endpoint,
                        Timestamp = startTime,
                        Duration = timer.Elapsed,
                        Success = success,
                        Type = "HTTP"
                    };

                    _telemetry.TrackDependency(dependency);
                }
            }
        }
        ```
        **Step 3: Query Dependency Data**
        ```kusto
        // Dependency failure rate by target
        dependencies
        | where timestamp > ago(1h)
        | summarize Calls = count(),
                    Failures = countif(success == false),
                    AvgDuration = avg(duration)
          by target, name
        | extend FailureRate = round(100.0 * Failures / Calls, 2)
        | order by FailureRate desc

        // Slow dependencies
        dependencies
        | where timestamp > ago(1h)
        | where duration > 1000
        | summarize count(), percentile(duration, 95) by target, name
        | order by percentile_duration_95 desc

        // Application map data
        dependencies
        | where timestamp > ago(1h)
        | summarize Calls = count(),
                    AvgDuration = avg(duration),
                    FailedCalls = countif(success == false)
          by source = cloud_RoleName, target
        | where source != target
        ```
        **References:**
        - [Application Map](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-map)
        - [Dependency Tracking](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-dependencies)

20. How do you implement profiler and snapshot debugging?
    - **Answer:**
        Application Insights Profiler captures detailed performance traces. Snapshot Debugger captures memory snapshots on exceptions for post-mortem debugging.
    - **Implementation:**
        **Step 1: Enable Profiler**
        ```csharp
        builder.Services.AddApplicationInsightsTelemetry();
        builder.Services.AddServiceProfiler();  // Microsoft.ApplicationInsights.Profiler.AspNetCore
        ```
        **Step 2: Configure Profiler via App Settings**
        ```json
        {
            "ApplicationInsights": {
                "InstrumentationKey": "<key>",
                "ProfilerEnabled": true
            },
            "APPINSIGHTS_PROFILERFEATURE_VERSION": "1.0.0",
            "DiagnosticServices_EXTENSION_VERSION": "~3"
        }
        ```
        **Step 3: Enable Snapshot Debugger**
        ```csharp
        builder.Services.AddSnapshotCollector(config =>
        {
            config.IsEnabled = true;
            config.IsEnabledInDeveloperMode = false;
            config.ThresholdForSnapshotting = 1;
            config.MaximumSnapshotsRequired = 3;
            config.MaximumCollectionPlanSize = 50;
            config.SnapshotsPerTenMinutesLimit = 1;
            config.SnapshotsPerDayLimit = 30;
            config.ProblemCounterResetInterval = TimeSpan.FromDays(1);
        });
        ```
        **Step 4: Trigger Profiler Manually**
        ```sh
        # Trigger profiler session
        az webapp config appsettings set \
            --name mywebapp \
            --resource-group myrg \
            --settings "APPINSIGHTS_PROFILER_TRIGGER_ENABLED=true"

        # Profile for specific duration
        curl -X POST "https://mywebapp.scm.azurewebsites.net/api/profiler/start?seconds=120" \
            -H "Authorization: Bearer <token>"
        ```
        **Step 5: Query Profiler Data**
        ```kusto
        // Find profiler traces
        performanceCounters
        | where timestamp > ago(1h)
        | where name == "Profiler Sessions"
        | project timestamp, value

        // Find snapshots
        exceptions
        | where timestamp > ago(24h)
        | where customDimensions.SnapshotId != ""
        | project timestamp, problemId, outerMessage, customDimensions.SnapshotId
        ```
        **References:**
        - [Application Insights Profiler](https://learn.microsoft.com/en-us/azure/azure-monitor/profiler/profiler-overview)
        - [Snapshot Debugger](https://learn.microsoft.com/en-us/azure/azure-monitor/snapshot-debugger/snapshot-debugger)

### 4.2 Azure Monitor & Diagnostics
1. How do you collect logs from multiple resources?
    - **Answer:**
        Use Log Analytics workspace and configure diagnostic settings for each resource to send logs.
    - **Implementation:**
        **Step 1: Create Log Analytics Workspace**
        ```sh
        az monitor log-analytics workspace create --resource-group myrg --workspace-name myworkspace --location eastus
        ```
        **Step 2: Configure Diagnostic Settings**
        ```sh
        az monitor diagnostic-settings create --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/sites/myapp --name mydiag --workspace myworkspace --logs '[{"category":"AppServiceHTTPLogs","enabled":true}]' --metrics '[{"category":"AllMetrics","enabled":true}]'
        ```
        **References:**
        - [Diagnostic Settings](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)

2. How do you analyze logs?
    - **Answer:**
        Use Kusto Query Language (KQL) in Log Analytics to query and analyze logs.
    - **Implementation:**
        **Step 1: Basic Query**
        ```kusto
        AzureDiagnostics
        | where TimeGenerated > ago(1h)
        | summarize count() by ResourceType
        ```
        **Step 2: Find Errors**
        ```kusto
        AppServiceHTTPLogs
        | where ScStatus >= 500
        | project TimeGenerated, CsUriStem, ScStatus, TimeTaken
        | order by TimeGenerated desc
        ```
        **Step 3: Join Multiple Tables**
        ```kusto
        AppRequests
        | join kind=inner (AppExceptions) on OperationId
        | project TimeGenerated, Name, ExceptionType, OuterMessage
        ```
        **References:**
        - [KQL Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)

3. How do you set up dashboards?
    - **Answer:**
        Use Azure Monitor dashboards, pin charts from metrics/logs, and create workbooks.
    - **Implementation:**
        **Step 1: Pin Metric Chart**
        - Resource > Metrics > Select metric > Pin to dashboard
        **Step 2: Pin Log Query**
        - Log Analytics > Query > Run > Pin to dashboard
        **Step 3: Create Workbook**
        - Azure Monitor > Workbooks > New > Add visualizations
        **References:**
        - [Azure Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)

4. How do you monitor resource health?
    - **Answer:**
        Use Resource Health blade to check status and set up alerts for unhealthy resources.
    - **Implementation:**
        **Step 1: View Resource Health**
        - Resource > Resource health > View status
        **Step 2: Create Health Alert**
        ```sh
        az monitor activity-log alert create --resource-group myrg --name myhealthalert --condition category=ResourceHealth --action-group myactiongroup
        ```
        **Step 3: Query Health Events (Kusto)**
        ```kusto
        AzureActivity
        | where CategoryValue == "ResourceHealth"
        | project TimeGenerated, ResourceId, OperationNameValue, Properties
        ```
        **References:**
        - [Resource Health](https://learn.microsoft.com/en-us/azure/service-health/resource-health-overview)

5. How do you troubleshoot VM issues?
    - **Answer:**
        Use VM Insights, review boot diagnostics, serial console, and run command.
    - **Implementation:**
        **Step 1: Enable VM Insights**
        ```sh
        az vm extension set --resource-group myrg --vm-name myvm --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor
        ```
        **Step 2: Use Serial Console**
        - Azure Portal > VM > Serial console > Connect
        **Step 3: Run Command**
        ```sh
        az vm run-command invoke --resource-group myrg --name myvm --command-id RunShellScript --scripts "cat /var/log/syslog | tail -100"
        ```
        **References:**
        - [VM Troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/welcome-virtual-machines)

6. How do you monitor network traffic?
    - **Answer:**
        Use Network Watcher, NSG flow logs, traffic analytics, and connection monitor.
    - **Implementation:**
        **Step 1: Enable Flow Logs**
        ```sh
        az network watcher flow-log create --resource-group myrg --nsg mynsg --storage-account mystorageaccount --enabled true --name myflowlog --traffic-analytics true --workspace myworkspace
        ```
        **Step 2: Connection Monitor**
        ```sh
        az network watcher connection-monitor create --resource-group myrg --name mymonitor --source-resource myvm --dest-address www.microsoft.com --dest-port 443
        ```
        **References:**
        - [Network Watcher](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview)

7. How do you automate remediation?
    - **Answer:**
        Use Azure Automation runbooks, Logic Apps, or Functions triggered by alert action groups.
    - **Implementation:**
        **Step 1: Create Automation Runbook**
        ```powershell
        param([object]$WebhookData)
        $alert = ConvertFrom-Json $WebhookData.RequestBody
        # Remediation logic
        Restart-AzVM -ResourceGroupName $alert.resourceGroupName -Name $alert.vmName
        ```
        **Step 2: Link to Alert**
        - Azure Monitor > Alerts > Action Groups > Add Automation Runbook
        **Step 3: Logic App Trigger**
        - Logic App > Trigger: Azure Monitor Alert > Actions: Remediation steps
        **References:**
        - [Alert Automation](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups)

8. How do you monitor costs?
    - **Answer:**
        Use Cost Management + Billing, set up budgets, alerts, and analyze spending patterns.
    - **Implementation:**
        **Step 1: Create Budget**
        ```sh
        az consumption budget create --budget-name mybudget --amount 1000 --time-grain Monthly --start-date 2024-01-01 --end-date 2024-12-31 --resource-group myrg
        ```
        **Step 2: Set Up Cost Alert**
        - Cost Management > Budgets > Create > Set threshold alerts
        **Step 3: Analyze Costs (Kusto)**
        ```kusto
        AzureCostManagement
        | summarize TotalCost = sum(CostInBillingCurrency) by ServiceName
        | order by TotalCost desc
        ```
        **References:**
        - [Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/quick-acm-cost-analysis)

9. How do you monitor SLAs?
    - **Answer:**
        Track uptime metrics, set up availability tests in Application Insights, and monitor SLIs.
    - **Implementation:**
        **Step 1: Create Availability Test**
        - Application Insights > Availability > Add test > URL ping test
        **Step 2: Calculate SLA (Kusto)**
        ```kusto
        availabilityResults
        | summarize SuccessRate = 100.0 * countif(success == true) / count() by bin(timestamp, 1d)
        ```
        **Step 3: Set Up SLA Alert**
        - Azure Monitor > Alerts > Condition: Availability < 99.9%
        **References:**
        - [Availability Tests](https://learn.microsoft.com/en-us/azure/azure-monitor/app/availability-overview)

10. How do you monitor scaling events?
    - **Answer:**
        Use autoscale logs, Activity Log, and set up alerts for scale operations.
    - **Implementation:**
        **Step 1: Query Autoscale Events (Kusto)**
        ```kusto
        AzureActivity
        | where OperationNameValue contains "Autoscale"
        | project TimeGenerated, OperationNameValue, Properties
        ```
        **Step 2: Create Scale Alert**
        - Azure Monitor > Alerts > Activity Log > Operation: Autoscale scale up/down
        **Step 3: Review in Portal**
        - Resource > Autoscale > Run history
        **References:**
        - [Autoscale Diagnostics](https://learn.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-troubleshoot)

11. How do you monitor for security threats?
    - **Answer:**
        Use Microsoft Defender for Cloud, set up threat detection alerts, and review security recommendations.
    - **Implementation:**
        **Step 1: Enable Defender Plans**
        - Defender for Cloud > Environment settings > Enable plans
        **Step 2: Query Security Alerts (Kusto)**
        ```kusto
        SecurityAlert
        | where AlertSeverity in ("High", "Medium")
        | project TimeGenerated, AlertName, Description, RemediationSteps
        ```
        **Step 3: Set Up Alert Notification**
        - Defender for Cloud > Environment settings > Email notifications
        **References:**
        - [Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)

12. How do you monitor API usage?
    - **Answer:**
        Use API Management analytics, Application Insights integration, and custom logging.
    - **Implementation:**
        **Step 1: Enable Application Insights in APIM**
        - API Management > Application Insights > Add > Select App Insights
        **Step 2: Query API Metrics (Kusto)**
        ```kusto
        ApiManagementGatewayLogs
        | summarize RequestCount = count(), AvgDuration = avg(TotalTime) by OperationId, bin(TimeGenerated, 1h)
        ```
        **Step 3: APIM Built-in Analytics**
        - API Management > Analytics > View usage, latency, errors
        **References:**
        - [APIM Analytics](https://learn.microsoft.com/en-us/azure/api-management/howto-use-analytics)

13. How do you monitor storage performance?
    - **Answer:**
        Use storage metrics, diagnostic logs, and set up alerts for latency/throughput.
    - **Implementation:**
        **Step 1: View Metrics**
        - Storage Account > Metrics > Select: Transactions, Success E2E Latency
        **Step 2: Query Storage Logs (Kusto)**
        ```kusto
        StorageBlobLogs
        | where DurationMs > 1000
        | summarize SlowRequests = count() by OperationName
        ```
        **Step 3: Create Performance Alert**
        - Azure Monitor > Alerts > Condition: E2E Latency > 500ms
        **References:**
        - [Monitor Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-monitoring-diagnosing-troubleshooting)

14. How do you monitor database performance?
    - **Answer:**
        Use SQL Insights, Query Performance Insight, Intelligent Insights, and alerts.
    - **Implementation:**
        **Step 1: Enable SQL Insights**
        - SQL Database > Intelligent Performance > Query Performance Insight
        **Step 2: Query DTU/CPU Usage (Kusto)**
        ```kusto
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.SQL"
        | where MetricName == "cpu_percent"
        | summarize AvgCPU = avg(Average) by bin(TimeGenerated, 5m)
        ```
        **Step 3: Set Up Deadlock Alert**
        - Azure Monitor > Alerts > Condition: Deadlocks > 0
        **References:**
        - [SQL Database Monitoring](https://learn.microsoft.com/en-us/azure/azure-sql/database/monitor-tune-overview)

15. How do you monitor for configuration drift?
    - **Answer:**
        Use Azure Policy for compliance, Change Tracking for resource changes, and Inventory for VMs.
    - **Implementation:**
        **Step 1: Assign Policy**
        ```sh
        az policy assignment create --name "RequireTag" --policy "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62" --scope /subscriptions/<sub-id>
        ```
        **Step 2: Enable Change Tracking**
        - Automation Account > Change tracking > Add VMs
        **Step 3: Query Changes (Kusto)**
        ```kusto
        ConfigurationChange
        | where ChangeCategory == "Software"
        | project TimeGenerated, Computer, SoftwareName, ChangeCategory
        ```
        **References:**
        - [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview)

16. How do you implement Azure Workbooks for interactive reports?
    - **Answer:**
        Workbooks combine text, queries, metrics, and parameters into interactive reports. They support multiple data sources and can be shared across teams.
    - **Implementation:**
        **Step 1: Create Workbook with KQL Query**
        ```json
        {
            "version": "Notebook/1.0",
            "items": [
                {
                    "type": 1,
                    "content": { "json": "# Application Performance Dashboard" }
                },
                {
                    "type": 3,
                    "content": {
                        "version": "KqlItem/1.0",
                        "query": "requests\n| where timestamp > ago(24h)\n| summarize count(), avg(duration), percentile(duration, 95) by bin(timestamp, 1h)\n| render timechart",
                        "size": 0,
                        "title": "Request Trends",
                        "queryType": 0,
                        "resourceType": "microsoft.insights/components"
                    }
                },
                {
                    "type": 9,
                    "content": {
                        "version": "KqlParameterItem/1.0",
                        "parameters": [
                            {
                                "name": "TimeRange",
                                "type": 4,
                                "defaultValue": "Last 24 hours"
                            }
                        ]
                    }
                }
            ]
        }
        ```
        **Step 2: Create Parameterized Query**
        ```kusto
        let timeRange = {TimeRange};
        let environment = "{Environment}";
        requests
        | where timestamp > ago(timeRange)
        | where cloud_RoleName contains environment
        | summarize Requests = count(),
                    AvgDuration = avg(duration),
                    P95 = percentile(duration, 95),
                    Errors = countif(success == false)
          by cloud_RoleName
        | order by Requests desc
        ```
        **References:**
        - [Azure Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)

17. How do you implement container insights for AKS monitoring?
    - **Answer:**
        Container Insights provides monitoring for AKS clusters, including node metrics, pod health, and container logs through Log Analytics integration.
    - **Implementation:**
        **Step 1: Enable Container Insights**
        ```sh
        az aks enable-addons \
            --resource-group myrg \
            --name myakscluster \
            --addons monitoring \
            --workspace-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.OperationalInsights/workspaces/myworkspace
        ```
        **Step 2: Query Container Logs**
        ```kusto
        // Pod restart counts
        KubePodInventory
        | where TimeGenerated > ago(1h)
        | summarize RestartCount = sum(PodRestartCount) by PodName, Namespace
        | where RestartCount > 0
        | order by RestartCount desc

        // Container CPU/Memory usage
        Perf
        | where ObjectName == "K8SContainer"
        | where CounterName in ("cpuUsageNanoCores", "memoryWorkingSetBytes")
        | summarize avg(CounterValue) by CounterName, InstanceName, bin(TimeGenerated, 5m)
        | render timechart

        // Failed pods
        KubeEvents
        | where Reason in ("Failed", "FailedScheduling", "FailedMount")
        | project TimeGenerated, Name, Namespace, Reason, Message
        | order by TimeGenerated desc
        ```
        **Step 3: Create Container Alert**
        ```sh
        az monitor scheduled-query create \
            --name "High Pod Restart Alert" \
            --resource-group myrg \
            --scopes /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.OperationalInsights/workspaces/myworkspace \
            --condition "count 'KubePodInventory | where PodRestartCount > 5 | distinct PodName' > 0" \
            --window-size 15m \
            --evaluation-frequency 5m \
            --action /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/actionGroups/oncall
        ```
        **References:**
        - [Container Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview)

18. How do you implement autoscaling based on custom metrics?
    - **Answer:**
        Use Azure Monitor custom metrics with autoscale rules to scale resources based on application-specific metrics beyond standard CPU/memory.
    - **Implementation:**
        **Step 1: Emit Custom Metric from Application**
        ```csharp
        public class MetricsPublisher
        {
            private readonly TelemetryClient _telemetry;

            public void TrackQueueBacklog(int backlogSize)
            {
                _telemetry.TrackMetric("QueueBacklog", backlogSize);

                // Also emit to Azure Monitor for autoscale
                _telemetry.GetMetric("QueueBacklog").TrackValue(backlogSize);
            }
        }
        ```
        **Step 2: Create Autoscale Rule with Custom Metric**
        ```sh
        az monitor autoscale create \
            --resource-group myrg \
            --name custom-metric-autoscale \
            --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/serverFarms/myappplan \
            --min-count 2 \
            --max-count 10 \
            --count 2

        az monitor autoscale rule create \
            --resource-group myrg \
            --autoscale-name custom-metric-autoscale \
            --condition "QueueBacklog > 100 avg 5m" \
            --scale out 2

        az monitor autoscale rule create \
            --resource-group myrg \
            --autoscale-name custom-metric-autoscale \
            --condition "QueueBacklog < 20 avg 10m" \
            --scale in 1
        ```
        **Step 3: KEDA for AKS Custom Metric Scaling**
        ```yaml
        apiVersion: keda.sh/v1alpha1
        kind: ScaledObject
        metadata:
            name: custom-metric-scaler
        spec:
            scaleTargetRef:
                name: mydeployment
            minReplicaCount: 1
            maxReplicaCount: 20
            triggers:
                - type: azure-monitor
                  metadata:
                      resourceURI: /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Insights/components/myappinsights
                      metricName: QueueBacklog
                      metricAggregationType: Average
                      targetValue: "50"
        ```
        **References:**
        - [Custom Metrics Autoscale](https://learn.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-custom-metric)

19. How do you implement Azure Data Explorer for advanced analytics?
    - **Answer:**
        Azure Data Explorer (ADX) provides fast, scalable analytics for telemetry data. It integrates with Azure Monitor for long-term retention and complex queries.
    - **Implementation:**
        **Step 1: Create ADX Cluster**
        ```sh
        az kusto cluster create \
            --name myadxcluster \
            --resource-group myrg \
            --location eastus \
            --sku name="Standard_D13_v2" tier="Standard" capacity=2

        az kusto database create \
            --cluster-name myadxcluster \
            --resource-group myrg \
            --database-name telemetry \
            --soft-delete-period P365D \
            --hot-cache-period P31D
        ```
        **Step 2: Export Application Insights to ADX**
        ```sh
        az monitor app-insights component linked-storage create \
            --resource-group myrg \
            --app myappinsights \
            --storage-account mystorageaccount \
            --type continuous-export

        # Create continuous export to ADX
        az kusto data-connection event-hub create \
            --cluster-name myadxcluster \
            --database-name telemetry \
            --resource-group myrg \
            --data-connection-name appinsights-connection \
            --event-hub-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.EventHub/namespaces/myeventhub/eventhubs/telemetry
        ```
        **Step 3: Advanced KQL Query in ADX**
        ```kusto
        // Time series anomaly detection
        requests
        | make-series RequestCount = count() on timestamp from ago(30d) to now() step 1h
        | extend anomalies = series_decompose_anomalies(RequestCount, 3)
        | mv-expand timestamp, RequestCount, anomalies
        | where anomalies != 0
        | project timestamp, RequestCount, AnomalyType = iff(anomalies > 0, "Spike", "Dip")

        // Cohort analysis
        let cohorts = requests
        | where timestamp > ago(30d)
        | summarize FirstRequest = min(timestamp) by user_Id
        | extend Cohort = startofweek(FirstRequest);
        requests
        | where timestamp > ago(30d)
        | join cohorts on user_Id
        | summarize Users = dcount(user_Id) by Cohort, Week = startofweek(timestamp)
        | evaluate pivot(Week, sum(Users))
        ```
        **References:**
        - [Azure Data Explorer](https://learn.microsoft.com/en-us/azure/data-explorer/data-explorer-overview)

20. How do you implement Azure Monitor OpenTelemetry integration?
    - **Answer:**
        OpenTelemetry provides vendor-neutral instrumentation. Azure Monitor Exporter sends OpenTelemetry data to Application Insights for analysis.
    - **Implementation:**
        **Step 1: Configure OpenTelemetry SDK**
        ```csharp
        builder.Services.AddOpenTelemetry()
            .WithTracing(tracing => tracing
                .AddSource("MyApp")
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation()
                .AddSqlClientInstrumentation()
                .AddAzureMonitorTraceExporter(options =>
                    options.ConnectionString = config["ApplicationInsights:ConnectionString"]))
            .WithMetrics(metrics => metrics
                .AddMeter("MyApp")
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation()
                .AddAzureMonitorMetricExporter(options =>
                    options.ConnectionString = config["ApplicationInsights:ConnectionString"]));

        builder.Logging.AddOpenTelemetry(logging => logging
            .AddAzureMonitorLogExporter(options =>
                options.ConnectionString = config["ApplicationInsights:ConnectionString"]));
        ```
        **Step 2: Create Custom Traces and Metrics**
        ```csharp
        public class OrderService
        {
            private static readonly ActivitySource _activitySource = new("MyApp");
            private static readonly Meter _meter = new("MyApp");
            private static readonly Counter<long> _ordersProcessed = _meter.CreateCounter<long>("orders_processed");

            public async Task ProcessOrderAsync(Order order)
            {
                using var activity = _activitySource.StartActivity("ProcessOrder");
                activity?.SetTag("order.id", order.Id);
                activity?.SetTag("order.customer", order.CustomerId);

                await ValidateOrderAsync(order);

                activity?.AddEvent(new ActivityEvent("OrderValidated"));

                await SaveOrderAsync(order);

                _ordersProcessed.Add(1, new KeyValuePair<string, object?>("status", "success"));
            }
        }
        ```
        **Step 3: Configure Sampling**
        ```csharp
        builder.Services.AddOpenTelemetry()
            .WithTracing(tracing => tracing
                .SetSampler(new ParentBasedSampler(new TraceIdRatioBasedSampler(0.1))) // 10% sampling
                .AddAzureMonitorTraceExporter());
        ```
        **References:**
        - [OpenTelemetry with Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-enable)


## 5. Connecting to Azure and Third-Party Services (Event Grid, Logic Apps, REST, Service Bus)


### 5.1 Azure Event Grid
1. How do you publish custom events?
     - **Answer:**
         Use Event Grid SDK or REST API, define event schema, and publish to a custom topic.
     - **Implementation:**
         **Step 1: Create Event Grid Topic**
         ```sh
         az eventgrid topic create --name mytopic --resource-group myrg --location eastus
         ```
         **Step 2: Publish Event (C#)**
         ```csharp
         using Azure.Messaging.EventGrid;
         var client = new EventGridPublisherClient(
                 new Uri("https://mytopic.eastus-1.eventgrid.azure.net/api/events"),
                 new AzureKeyCredential("<topic-key>"));
         var events = new[]
         {
                 new EventGridEvent(
                         subject: "myapp/objects",
                         eventType: "MyApp.ObjectCreated",
                         dataVersion: "1.0",
                         data: new { Id = 123, Name = "Test" })
         };
         await client.SendEventsAsync(events);
         ```
         **References:**
         - [Publish events to Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/custom-event-quickstart)

2. How do you secure event delivery?
     - **Answer:**
         Use authentication (AAD, SAS), and validate event subscription endpoints.
     - **Implementation:**
         **Step 1: Use Azure AD Auth for Topic**
         - Event Grid Topic > Identity > Enable system-assigned identity
         **Step 2: Validate Webhook Endpoint**
         - Implement validation handshake in your webhook receiver:
         ```csharp
         [HttpPost]
         public async Task<IActionResult> Post([FromBody] JObject events)
         {
                 var eventType = events[0]["eventType"].ToString();
                 if (eventType == "Microsoft.EventGrid.SubscriptionValidationEvent")
                 {
                         var validationCode = events[0]["data"]["validationCode"].ToString();
                         return Ok(new { validationResponse = validationCode });
                 }
                 // Handle other events
                 return Ok();
         }
         ```
         **References:**
         - [Event Grid security](https://learn.microsoft.com/en-us/azure/event-grid/security-authentication)

3. How do you handle event retries?
     - **Answer:**
         Event Grid retries with exponential backoff and supports dead-lettering for failed events.
     - **Implementation:**
         **Step 1: Enable Dead-Lettering**
         - Event Subscription > Dead-letter destination > Storage account
         **Step 2: Review Retry Policy**
         - Event Grid automatically retries for up to 24 hours
         **References:**
         - [Event Grid delivery and retry](https://learn.microsoft.com/en-us/azure/event-grid/delivery-and-retry)

4. How do you filter events?
     - **Answer:**
         Use event subscription filters (subject, event type, advanced filters).
     - **Implementation:**
         **Step 1: Add Filter in Portal**
         - Event Subscription > Filters > Add subject begins with, event type, or advanced filters
         **Step 2: CLI Example**
         ```sh
         az eventgrid event-subscription create --name mysub --source-resource-id <topic-id> --endpoint <endpoint-url> --included-event-types MyApp.ObjectCreated
         ```
         **References:**
         - [Event Grid filters](https://learn.microsoft.com/en-us/azure/event-grid/event-filtering)

5. How do you monitor event delivery?
     - **Answer:**
         Use metrics, diagnostics, and dead-letter logs.
     - **Implementation:**
         **Step 1: Enable Diagnostics**
         - Event Grid Topic > Monitoring > Diagnostic settings > Add diagnostic setting
         **Step 2: Query Delivery Logs in Log Analytics**
         ```kusto
         AzureDiagnostics
         | where ResourceType == "EVENTGRIDTOPICS" and OperationName == "PublishEvents"
         ```
         **References:**
         - [Monitor Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/monitor-event-delivery)

6. How do you integrate with Functions/Logic Apps?
     - **Answer:**
         Create event subscriptions with Function/Logic App endpoints.
     - **Implementation:**
         **Step 1: Create Event Subscription to Azure Function**
         ```sh
         az eventgrid event-subscription create --name mysub --source-resource-id <topic-id> --endpoint-type azurefunction --endpoint <function-resource-id>
         ```
         **Step 2: Create Event Subscription to Logic App**
         ```sh
         az eventgrid event-subscription create --name mysub --source-resource-id <topic-id> --endpoint-type logicapp --endpoint <logicapp-resource-id>
         ```
         **References:**
         - [Event Grid with Functions](https://learn.microsoft.com/en-us/azure/event-grid/trigger-on-event)

7. How do you handle schema evolution?
     - **Answer:**
         Use versioning in event data, document changes, and support backward compatibility.
     - **Implementation:**
         **Step 1: Add Version Field to Event Data**
         ```json
         {
             "eventType": "MyApp.ObjectCreated",
             "dataVersion": "2.0",
             "data": { ... }
         }
         ```
         **Step 2: Update Consumers to Handle Multiple Versions**
         - In your handler, check dataVersion and process accordingly
         **References:**
         - [Event Grid event schema](https://learn.microsoft.com/en-us/azure/event-grid/event-schema)

8. How do you automate topic/subscription creation?
     - **Answer:**
         Use ARM/Bicep templates, Azure CLI, or SDK.
     - **Implementation:**
         **Step 1: ARM Template Example**
         ```json
         {
             "type": "Microsoft.EventGrid/topics",
             "apiVersion": "2021-12-01",
             "name": "mytopic",
             "location": "eastus",
             "properties": {}
         }
         ```
         **Step 2: CLI Example**
         ```sh
         az eventgrid topic create --name mytopic --resource-group myrg --location eastus
         ```
         **References:**
         - [Automate Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/scripts/event-grid-cli-create-custom-topic)

9. How do you secure topics?
     - **Answer:**
         Use RBAC, private endpoints, and firewall rules.
     - **Implementation:**
         **Step 1: Assign RBAC Role**
         - Event Grid Topic > Access control (IAM) > Add role assignment
         **Step 2: Enable Private Endpoint**
         - Event Grid Topic > Networking > Private endpoint > Add
         **Step 3: Set Firewall Rules**
         - Event Grid Topic > Networking > Firewalls
         **References:**
         - [Secure Event Grid topics](https://learn.microsoft.com/en-us/azure/event-grid/security-authentication)

10. How do you test event-driven workflows?
     - **Answer:**
         Use Event Grid Viewer, test events in portal, or local emulators.
     - **Implementation:**
         **Step 1: Use Event Grid Viewer**
         - https://eventgridviewer.azurewebsites.net/
         **Step 2: Send Test Event in Portal**
         - Event Grid Topic > Events > Send test event
         **References:**
         - [Test Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/monitor-event-delivery)

11. How do you handle high-throughput scenarios?
     - **Answer:**
         Use batch publishing, monitor throttling, and scale consumers.
     - **Implementation:**
         **Step 1: Batch Publish Events (C#)**
         ```csharp
         await client.SendEventsAsync(eventsBatch);
         ```
         **Step 2: Monitor Throttling in Metrics**
         - Event Grid Topic > Monitoring > Metrics > Throttled events
         **Step 3: Scale Consumers**
         - Use Azure Functions with multiple instances
         **References:**
         - [Event Grid throughput](https://learn.microsoft.com/en-us/azure/event-grid/throughput)

12. How do you integrate with third-party webhooks?
     - **Answer:**
         Register webhook endpoints, validate handshake, and secure with secrets.
     - **Implementation:**
         **Step 1: Register Webhook Endpoint**
         - Event Subscription > Endpoint type: Webhook > Enter URL
         **Step 2: Implement Validation Handshake (see question 2)**
         **Step 3: Secure with Secret Header**
         - Add a secret header to the webhook subscription
         **References:**
         - [Webhooks with Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/webhook-event-delivery)

13. How do you monitor for undelivered events?
     - **Answer:**
         Use dead-lettering, set up alerts, and review logs.
     - **Implementation:**
         **Step 1: Enable Dead-Lettering (see question 3)**
         **Step 2: Set Up Alerts in Azure Monitor**
         - Event Grid Topic > Alerts > New alert rule > Condition: Dead-lettered events
         **References:**
         - [Monitor undelivered events](https://learn.microsoft.com/en-us/azure/event-grid/monitor-event-delivery)

14. How do you automate event processing?
     - **Answer:**
         Use Functions, Logic Apps, or custom consumers.
     - **Implementation:**
         **Step 1: Create Azure Function with Event Grid Trigger**
         ```csharp
         [FunctionName("EventGridProcessor")]
         public static void Run([EventGridTrigger] EventGridEvent eventGridEvent, ILogger log)
         {
                 log.LogInformation($"Event received: {eventGridEvent.Data.ToString()}");
         }
         ```
         **Step 2: Create Logic App with Event Grid Trigger**
         - Logic App Designer > Trigger: When a resource event occurs
         **References:**
         - [Event Grid triggers](https://learn.microsoft.com/en-us/azure/event-grid/trigger-on-event)

15. How do you handle event ordering?
     - **Answer:**
         Event Grid does not guarantee ordering; design idempotent consumers.
     - **Implementation:**
         **Step 1: Implement Idempotency in Consumer**
         - Store processed event IDs and skip duplicates
         ```csharp
         if (processedEventIds.Contains(eventGridEvent.Id)) return;
         processedEventIds.Add(eventGridEvent.Id);
         ```
         **References:**
         - [Event Grid event ordering](https://learn.microsoft.com/en-us/azure/event-grid/overview)

16. How do you implement Event Grid dead-letter handling?
    - **Answer:**
        Configure dead-letter destination for events that fail delivery after all retry attempts. Store in blob storage for later analysis and reprocessing.
    - **Implementation:**
        **Step 1: Configure Dead-Letter Destination**
        ```sh
        az eventgrid event-subscription create \
            --name mysubscription \
            --source-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.EventGrid/topics/mytopic \
            --endpoint https://myfunction.azurewebsites.net/api/eventhandler \
            --deadletter-endpoint /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount/blobServices/default/containers/deadletters \
            --max-delivery-attempts 30 \
            --event-ttl 1440
        ```
        **Step 2: Process Dead-Lettered Events**
        ```csharp
        [Function("ProcessDeadLetterEvents")]
        public async Task Run([BlobTrigger("deadletters/{name}")] Stream blob, string name)
        {
            using var reader = new StreamReader(blob);
            var content = await reader.ReadToEndAsync();
            var events = JsonSerializer.Deserialize<EventGridEvent[]>(content);

            foreach (var evt in events)
            {
                _logger.LogWarning($"Dead-lettered event: {evt.Id}, Type: {evt.EventType}");
                await _deadLetterService.AnalyzeAndReprocessAsync(evt);
            }
        }
        ```
        **References:**
        - [Event Grid Dead-Letter](https://learn.microsoft.com/en-us/azure/event-grid/manage-event-delivery)

17. How do you implement Event Grid system topics?
    - **Answer:**
        System topics are created automatically for Azure service events (Blob Storage, Resource Groups). Subscribe to receive notifications about resource changes.
    - **Implementation:**
        **Step 1: Create System Topic for Storage Account**
        ```sh
        az eventgrid system-topic create \
            --name storage-events \
            --resource-group myrg \
            --source /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount \
            --topic-type Microsoft.Storage.StorageAccounts \
            --location eastus

        az eventgrid system-topic event-subscription create \
            --name blob-created-subscription \
            --system-topic-name storage-events \
            --resource-group myrg \
            --endpoint https://myfunction.azurewebsites.net/api/blobhandler \
            --included-event-types Microsoft.Storage.BlobCreated
        ```
        **Step 2: Subscribe to Resource Group Events**
        ```sh
        az eventgrid system-topic create \
            --name rg-events \
            --resource-group myrg \
            --source /subscriptions/<sub-id>/resourceGroups/myrg \
            --topic-type Microsoft.Resources.ResourceGroups

        az eventgrid system-topic event-subscription create \
            --name resource-changes \
            --system-topic-name rg-events \
            --resource-group myrg \
            --endpoint https://myfunction.azurewebsites.net/api/resourcechanges \
            --included-event-types Microsoft.Resources.ResourceWriteSuccess Microsoft.Resources.ResourceDeleteSuccess
        ```
        **References:**
        - [System Topics](https://learn.microsoft.com/en-us/azure/event-grid/system-topics)

18. How do you implement partner events with Event Grid?
    - **Answer:**
        Partner events allow SaaS providers to publish events to your Event Grid namespace. Subscribe to partner events like Auth0, Datadog, or SAP.
    - **Implementation:**
        **Step 1: Enable Partner Topic**
        ```sh
        # Authorize partner
        az eventgrid partner-topic activate \
            --resource-group myrg \
            --name auth0-events

        # Create subscription
        az eventgrid partner-topic event-subscription create \
            --resource-group myrg \
            --partner-topic-name auth0-events \
            --name auth0-subscription \
            --endpoint https://myfunction.azurewebsites.net/api/auth0events
        ```
        **Step 2: Handle Partner Events**
        ```csharp
        [Function("Auth0EventHandler")]
        public async Task HandleAuth0Event([EventGridTrigger] EventGridEvent evt)
        {
            if (evt.EventType == "Auth0.User.Created")
            {
                var userData = evt.Data.ToObjectFromJson<Auth0UserData>();
                await _userService.SyncUserAsync(userData);
            }
        }
        ```
        **References:**
        - [Partner Events](https://learn.microsoft.com/en-us/azure/event-grid/partner-events-overview)

19. How do you implement advanced filtering with Event Grid?
    - **Answer:**
        Use advanced filtering with operators (StringContains, NumberIn, etc.) to route events based on data properties, not just event type.
    - **Implementation:**
        **Step 1: Create Subscription with Advanced Filters**
        ```sh
        az eventgrid event-subscription create \
            --name filtered-subscription \
            --source-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.EventGrid/topics/mytopic \
            --endpoint https://myfunction.azurewebsites.net/api/handler \
            --advanced-filter data.priority NumberGreaterThan 5 \
            --advanced-filter data.category StringIn Critical High \
            --advanced-filter subject StringContains /orders/
        ```
        **Step 2: Filter on Multiple Conditions**
        ```json
        {
            "filter": {
                "advancedFilters": [
                    {
                        "operatorType": "StringContains",
                        "key": "data.productCategory",
                        "values": ["Electronics", "Computers"]
                    },
                    {
                        "operatorType": "NumberGreaterThanOrEquals",
                        "key": "data.orderAmount",
                        "value": 1000
                    },
                    {
                        "operatorType": "BoolEquals",
                        "key": "data.isPremiumCustomer",
                        "value": true
                    }
                ]
            }
        }
        ```
        **References:**
        - [Event Filtering](https://learn.microsoft.com/en-us/azure/event-grid/event-filtering)

20. How do you implement Event Grid with Managed Identity?
    - **Answer:**
        Use Managed Identity for secure authentication when delivering events to Azure services like Service Bus, Storage, or Event Hubs.
    - **Implementation:**
        **Step 1: Assign Identity to Event Grid Topic**
        ```sh
        az eventgrid topic update \
            --name mytopic \
            --resource-group myrg \
            --identity systemassigned
        ```
        **Step 2: Grant Permissions to Target Resource**
        ```sh
        topicId=$(az eventgrid topic show --name mytopic --resource-group myrg --query identity.principalId -o tsv)

        az role assignment create \
            --assignee $topicId \
            --role "Azure Service Bus Data Sender" \
            --scope /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.ServiceBus/namespaces/myservicebus
        ```
        **Step 3: Create Subscription with Identity**
        ```sh
        az eventgrid event-subscription create \
            --name sb-subscription \
            --source-resource-id /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.EventGrid/topics/mytopic \
            --endpoint-type servicebusqueue \
            --endpoint /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.ServiceBus/namespaces/myservicebus/queues/events \
            --delivery-identity-endpoint-type servicebusqueue \
            --delivery-identity systemassigned
        ```
        **References:**
        - [Managed Identity Delivery](https://learn.microsoft.com/en-us/azure/event-grid/managed-service-identity)


### 5.2 Azure Logic Apps
1. How do you design a workflow to integrate multiple services?
     - **Answer:**
         Use Logic Apps designer, add triggers/actions for each service, and handle errors with scopes.
     - **Implementation:**
         **Step 1: Create Logic App in Portal**
         - Azure Portal > Create resource > Logic App
         **Step 2: Add Trigger (e.g., HTTP Request)**
         - Logic App Designer > + New step > Choose trigger (e.g., When an HTTP request is received)
         **Step 3: Add Actions for Each Service**
         - Add connectors for Office 365, Azure Functions, SQL, etc.
         **Step 4: Handle Errors with Scopes**
         - Add Scope action, configure runAfter for error handling
         **References:**
         - [Logic Apps designer](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-overview)

2. How do you secure Logic Apps?
     - **Answer:**
         Use managed identities, restrict access with IP filtering, and use private endpoints.
     - **Implementation:**
         **Step 1: Enable Managed Identity**
         - Logic App > Identity > System assigned > On
         **Step 2: Restrict Access with IP Filtering**
         - Logic App > Workflow settings > Access control configuration
         **Step 3: Use Private Endpoints**
         - Logic App > Networking > Private endpoint > Add
         **References:**
         - [Secure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-securing-a-logic-app)

3. How do you monitor Logic App runs?
     - **Answer:**
         Use run history, diagnostics, and Azure Monitor.
     - **Implementation:**
         **Step 1: View Run History**
         - Logic App > Overview > Runs history
         **Step 2: Enable Diagnostics**
         - Logic App > Diagnostic settings > Add diagnostic setting
         **Step 3: Use Azure Monitor**
         - Azure Monitor > Logs > Query Logic App logs
         **References:**
         - [Monitor Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/monitor-logic-apps)

4. How do you handle errors and retries?
     - **Answer:**
         Use retry policies, configure error handling scopes, and alert on failures.
     - **Implementation:**
         **Step 1: Configure Retry Policy**
         - In action settings, set retry policy (default, none, fixed interval, exponential)
         **Step 2: Use Scope for Error Handling**
         - Add Scope action, configure runAfter to handle failures
         **Step 3: Set Up Alerts**
         - Azure Monitor > Alerts > New alert rule > Condition: Failed runs
         **References:**
         - [Error handling in Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-exception-handling)

5. How do you automate deployment?
     - **Answer:**
         Use ARM/Bicep templates, Azure DevOps, or GitHub Actions.
     - **Implementation:**
         **Step 1: Export Logic App as ARM Template**
         - Logic App > Automation > Export template
         **Step 2: Deploy with Azure CLI**
         ```sh
         az deployment group create --resource-group myrg --template-file logicapp-template.json
         ```
         **Step 3: Use CI/CD Pipeline**
         - Azure DevOps or GitHub Actions: Add deployment step for ARM/Bicep template
         **References:**
         - [Deploy Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-azure-resource-manager-templates-deploy)

6. How do you integrate with on-premises systems?
     - **Answer:**
         Use On-Premises Data Gateway and hybrid connectors.
     - **Implementation:**
         **Step 1: Install On-Premises Data Gateway**
         - Download and install from https://aka.ms/onpremgateway
         **Step 2: Register Gateway in Azure**
         - Azure Portal > On-premises data gateways > Register
         **Step 3: Use Gateway in Logic App**
         - Add connector (e.g., SQL Server), select gateway
         **References:**
         - [On-premises data gateway](https://learn.microsoft.com/en-us/data-integration/gateway/service-gateway-install)

7. How do you manage secrets?
     - **Answer:**
         Use Key Vault integration, managed identities, and secure inputs/outputs.
     - **Implementation:**
         **Step 1: Enable Managed Identity (see question 2)**
         **Step 2: Add Key Vault Action**
         - Logic App Designer > Add action > Azure Key Vault > Get secret
         **Step 3: Secure Inputs/Outputs**
         - Action settings > Secure Inputs/Outputs: On
         **References:**
         - [Key Vault with Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-securing-a-logic-app#securing-inputs-and-outputs)

8. How do you handle long-running workflows?
     - **Answer:**
         Use stateful Logic Apps, configure timeouts and persistence.
     - **Implementation:**
         **Step 1: Create Stateful Logic App**
         - Azure Portal > Create resource > Logic App (Stateful)
         **Step 2: Configure Timeouts**
         - In action settings, set timeout property
         **Step 3: Use Delay/Until Actions for Waiting**
         - Add Delay or Until action for long waits
         **References:**
         - [Long-running workflows](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-exception-handling#long-running-workflows)

9. How do you optimize for cost?
     - **Answer:**
         Use consumption plan, optimize workflow steps, and monitor usage.
     - **Implementation:**
         **Step 1: Use Consumption Plan**
         - Azure Portal > Logic App > Pricing tier: Consumption
         **Step 2: Optimize Workflow**
         - Remove unnecessary actions, use parallelism
         **Step 3: Monitor Usage**
         - Logic App > Metrics > Runs, actions, and billable executions
         **References:**
         - [Logic Apps pricing](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-pricing)

10. How do you version Logic Apps?
     - **Answer:**
         Use source control, export templates, and document changes.
     - **Implementation:**
         **Step 1: Export Logic App as ARM Template (see question 5)**
         **Step 2: Store in Source Control (e.g., GitHub)**
         - Commit template and workflow definition files
         **Step 3: Document Changes**
         - Use README or changelog in repo
         **References:**
         - [Versioning Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-azure-resource-manager-templates-deploy)

11. How do you test workflows?
     - **Answer:**
         Use run history, test triggers, and mock connectors.
     - **Implementation:**
         **Step 1: Use Run History**
         - Logic App > Overview > Runs history
         **Step 2: Test Triggers**
         - Logic App Designer > Run Trigger > Select trigger to test
         **Step 3: Use Mock Data/Connectors**
         - Add HTTP or custom connector to simulate external systems
         **References:**
         - [Test Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-monitor-your-logic-apps)

12. How do you handle concurrency?
     - **Answer:**
         Configure concurrency control in triggers/actions.
     - **Implementation:**
         **Step 1: Set Concurrency in Trigger Settings**
         - Trigger > Settings > Concurrency Control > Enable, set degree of parallelism
         **Step 2: Set Concurrency in For Each Actions**
         - For Each > Settings > Concurrency Control
         **References:**
         - [Concurrency in Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-control-flow-run-concurrent-instances)

13. How do you integrate with REST APIs?
     - **Answer:**
         Use HTTP actions, handle authentication, and parse responses.
     - **Implementation:**
         **Step 1: Add HTTP Action**
         - Logic App Designer > Add action > HTTP
         **Step 2: Configure Authentication**
         - Set authentication type (Basic, OAuth, Managed Identity)
         **Step 3: Parse Response**
         - Add Parse JSON action after HTTP action
         **References:**
         - [HTTP actions in Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-http-endpoint)

14. How do you monitor for throttling?
     - **Answer:**
         Set up alerts and review run history for throttled actions.
     - **Implementation:**
         **Step 1: Enable Diagnostics (see question 3)**
         **Step 2: Set Up Alerts**
         - Azure Monitor > Alerts > New alert rule > Condition: Throttled actions
         **Step 3: Review Run History**
         - Logic App > Overview > Runs history > Check for throttling errors
         **References:**
         - [Throttling in Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-limits-and-config)

15. How do you automate error notifications?
     - **Answer:**
         Use Action Groups, email, or Teams connectors for alerts.
     - **Implementation:**
         **Step 1: Add Email or Teams Action in Workflow**
         - Logic App Designer > Add action > Office 365 Outlook > Send an email
         - Or: Teams > Post a message
         **Step 2: Use Azure Monitor Action Group**
         - Azure Monitor > Action Groups > Create > Add Logic App as action
         **References:**
         - [Error notifications in Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-monitor-your-logic-apps)

16. How do you implement Logic Apps Standard with stateful workflows?
    - **Answer:**
        Logic Apps Standard runs on Azure Functions runtime, supporting stateful and stateless workflows with better performance and local development.
    - **Implementation:**
        **Step 1: Create Stateful Workflow Definition**
        ```json
        {
            "definition": {
                "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
                "actions": {
                    "Process_Order": {
                        "type": "ServiceProvider",
                        "inputs": {
                            "parameters": { "entityName": "orders" },
                            "serviceProviderConfiguration": {
                                "connectionName": "serviceBus",
                                "operationId": "receiveMessage"
                            }
                        }
                    },
                    "Validate_Inventory": {
                        "type": "Http",
                        "inputs": {
                            "method": "GET",
                            "uri": "@concat('https://api.myapp.com/inventory/', triggerBody()?['productId'])"
                        },
                        "runAfter": { "Process_Order": ["Succeeded"] }
                    },
                    "Store_State": {
                        "type": "Compose",
                        "inputs": {
                            "orderId": "@triggerBody()?['orderId']",
                            "status": "validated",
                            "timestamp": "@utcNow()"
                        },
                        "runAfter": { "Validate_Inventory": ["Succeeded"] }
                    }
                },
                "triggers": {
                    "manual": { "type": "Request", "kind": "Http" }
                }
            },
            "kind": "Stateful"
        }
        ```
        **Step 2: Deploy with VS Code Extension**
        ```sh
        # Local development
        func host start

        # Deploy to Azure
        az logicapp deployment source config-zip \
            --resource-group myrg \
            --name mylogicapp \
            --src workflow.zip
        ```
        **References:**
        - [Logic Apps Standard](https://learn.microsoft.com/en-us/azure/logic-apps/single-tenant-overview-compare)

17. How do you implement approval workflows in Logic Apps?
    - **Answer:**
        Use the Approval connector to send approval requests via email or Teams, then branch workflow based on response.
    - **Implementation:**
        **Workflow Definition:**
        ```json
        {
            "actions": {
                "Send_Approval_Email": {
                    "type": "ApiConnectionWebhook",
                    "inputs": {
                        "host": { "connection": { "name": "@parameters('$connections')['office365']['connectionId']" } },
                        "body": {
                            "NotificationUrl": "@listCallbackUrl()",
                            "Message": {
                                "To": "manager@company.com",
                                "Subject": "Approval Required: @{triggerBody()?['requestTitle']}",
                                "Options": "Approve, Reject",
                                "Body": "Please review: @{triggerBody()?['details']}"
                            }
                        },
                        "path": "/approvalmail"
                    }
                },
                "Condition": {
                    "type": "If",
                    "expression": "@equals(body('Send_Approval_Email')?['SelectedOption'], 'Approve')",
                    "actions": {
                        "Process_Approved": { "type": "Http", "inputs": { "method": "POST", "uri": "https://api.myapp.com/approved" } }
                    },
                    "else": {
                        "actions": {
                            "Send_Rejection_Notice": { "type": "ApiConnection", "inputs": { /* Send email */ } }
                        }
                    },
                    "runAfter": { "Send_Approval_Email": ["Succeeded"] }
                }
            }
        }
        ```
        **References:**
        - [Approval Workflows](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-create-approval-workflows)

18. How do you implement long-running Logic Apps with checkpoints?
    - **Answer:**
        Use durable patterns with compose actions to save state. Implement checkpoint patterns for workflows that may exceed timeout limits.
    - **Implementation:**
        ```json
        {
            "actions": {
                "Initialize_State": {
                    "type": "InitializeVariable",
                    "inputs": {
                        "variables": [{ "name": "ProcessingState", "type": "object", "value": { "step": 0, "processedItems": [] } }]
                    }
                },
                "For_Each_Item": {
                    "type": "Foreach",
                    "foreach": "@triggerBody()?['items']",
                    "actions": {
                        "Process_Item": {
                            "type": "Http",
                            "inputs": { "method": "POST", "uri": "https://api.myapp.com/process", "body": "@items('For_Each_Item')" }
                        },
                        "Update_Checkpoint": {
                            "type": "SetVariable",
                            "inputs": {
                                "name": "ProcessingState",
                                "value": {
                                    "step": "@add(variables('ProcessingState').step, 1)",
                                    "processedItems": "@union(variables('ProcessingState').processedItems, array(items('For_Each_Item').id))"
                                }
                            },
                            "runAfter": { "Process_Item": ["Succeeded"] }
                        }
                    },
                    "runtimeConfiguration": { "concurrency": { "repetitions": 5 } }
                }
            }
        }
        ```
        **References:**
        - [Long-Running Actions](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-handle-long-running-operations)

19. How do you implement Logic Apps with Azure Functions integration?
    - **Answer:**
        Call Azure Functions from Logic Apps for custom code execution, complex transformations, or accessing services not available as connectors.
    - **Implementation:**
        ```json
        {
            "actions": {
                "Transform_Data": {
                    "type": "Function",
                    "inputs": {
                        "function": {
                            "id": "/subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/sites/myfuncapp/functions/TransformOrder"
                        },
                        "body": "@triggerBody()",
                        "method": "POST"
                    }
                },
                "Validate_With_Custom_Logic": {
                    "type": "Function",
                    "inputs": {
                        "function": {
                            "id": "/subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Web/sites/myfuncapp/functions/ValidateOrder"
                        },
                        "body": {
                            "order": "@body('Transform_Data')",
                            "rules": ["inventory-check", "credit-check", "fraud-detection"]
                        }
                    },
                    "runAfter": { "Transform_Data": ["Succeeded"] }
                }
            }
        }
        ```
        **References:**
        - [Logic Apps with Functions](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-azure-functions)

20. How do you implement B2B integration with Logic Apps Enterprise Integration Pack?
    - **Answer:**
        Use Integration Accounts for EDI, AS2, and X12 message processing. Define trading partners, agreements, and schemas for B2B workflows.
    - **Implementation:**
        **Step 1: Create Integration Account**
        ```sh
        az logic integration-account create \
            --resource-group myrg \
            --name myintegrationaccount \
            --sku Standard
        ```
        **Step 2: Upload Schemas and Maps**
        ```sh
        az logic integration-account schema create \
            --resource-group myrg \
            --integration-account-name myintegrationaccount \
            --schema-name OrderSchema \
            --schema-type Xml \
            --content-type "application/xml" \
            --content @order-schema.xsd
        ```
        **Step 3: Configure EDI Workflow**
        ```json
        {
            "actions": {
                "Decode_X12": {
                    "type": "X12Decode",
                    "inputs": {
                        "body": "@triggerBody()",
                        "integrationAccount": {
                            "name": "myintegrationaccount"
                        }
                    }
                },
                "Transform_To_Internal": {
                    "type": "Transform",
                    "inputs": {
                        "body": "@body('Decode_X12')?['payload']",
                        "integrationAccount": { "map": { "name": "X12ToInternal" } }
                    },
                    "runAfter": { "Decode_X12": ["Succeeded"] }
                }
            }
        }
        ```
        **References:**
        - [Enterprise Integration Pack](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-enterprise-integration-overview)

### 5.3 Azure REST APIs
1. How do you authenticate REST API calls?
    - **Answer:**
        Use Azure AD tokens with MSAL, client credentials flow, or managed identities.
    - **Implementation:**
        **Step 1: Get Token with Client Credentials (C#)**
        ```csharp
        var app = ConfidentialClientApplicationBuilder.Create(clientId)
            .WithClientSecret(clientSecret)
            .WithAuthority($"https://login.microsoftonline.com/{tenantId}")
            .Build();
        var result = await app.AcquireTokenForClient(new[] { "https://management.azure.com/.default" }).ExecuteAsync();
        var token = result.AccessToken;
        ```
        **Step 2: Use Managed Identity**
        ```csharp
        var credential = new DefaultAzureCredential();
        var token = await credential.GetTokenAsync(new TokenRequestContext(new[] { "https://management.azure.com/.default" }));
        ```
        **Step 3: Call API with Token**
        ```csharp
        httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var response = await httpClient.GetAsync("https://management.azure.com/subscriptions?api-version=2022-01-01");
        ```
        **References:**
        - [Azure AD Authentication](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow)

2. How do you secure APIs from unauthorized access?
    - **Answer:**
        Use OAuth/OpenID Connect, API Management policies, and validate tokens in middleware.
    - **Implementation:**
        **Step 1: Validate JWT in ASP.NET Core**
        ```csharp
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));
        ```
        **Step 2: API Management JWT Validation**
        ```xml
        <inbound>
            <validate-jwt header-name="Authorization">
                <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration"/>
            </validate-jwt>
        </inbound>
        ```
        **References:**
        - [Secure APIs](https://learn.microsoft.com/en-us/azure/api-management/api-management-authentication-policies)

3. How do you handle throttling and rate limits?
    - **Answer:**
        Implement retry with exponential backoff, respect Retry-After headers, and monitor usage.
    - **Implementation:**
        **Step 1: Implement Retry with Polly**
        ```csharp
        var retryPolicy = Policy
            .HandleResult<HttpResponseMessage>(r => r.StatusCode == HttpStatusCode.TooManyRequests)
            .WaitAndRetryAsync(3, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));
        var response = await retryPolicy.ExecuteAsync(() => httpClient.GetAsync(url));
        ```
        **Step 2: Respect Retry-After Header**
        ```csharp
        if (response.StatusCode == HttpStatusCode.TooManyRequests)
        {
            var retryAfter = response.Headers.RetryAfter?.Delta ?? TimeSpan.FromSeconds(60);
            await Task.Delay(retryAfter);
        }
        ```
        **References:**
        - [Handle Throttling](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry)

4. How do you document APIs?
    - **Answer:**
        Use OpenAPI/Swagger for specification, publish docs in API Management developer portal.
    - **Implementation:**
        **Step 1: Add Swagger to ASP.NET Core**
        ```csharp
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen();
        app.UseSwagger();
        app.UseSwaggerUI();
        ```
        **Step 2: Import to API Management**
        - API Management > APIs > Add API > OpenAPI > Import Swagger JSON
        **Step 3: Enable Developer Portal**
        - API Management > Portal overview > Publish
        **References:**
        - [API Documentation](https://learn.microsoft.com/en-us/azure/api-management/import-and-publish)

5. How do you monitor API usage?
    - **Answer:**
        Use API Management analytics, Application Insights integration, and custom logging.
    - **Implementation:**
        **Step 1: Enable App Insights in APIM**
        - API Management > Application Insights > Add
        **Step 2: Query Usage (Kusto)**
        ```kusto
        ApiManagementGatewayLogs
        | summarize RequestCount = count() by ApiId, bin(TimeGenerated, 1h)
        ```
        **Step 3: View Built-in Analytics**
        - API Management > Analytics > Usage, Performance, Health
        **References:**
        - [APIM Analytics](https://learn.microsoft.com/en-us/azure/api-management/howto-use-analytics)

6. How do you handle versioning?
    - **Answer:**
        Use path-based (v1/v2), query string, or header-based versioning with proper documentation.
    - **Implementation:**
        **Step 1: Path-Based Versioning**
        ```csharp
        app.MapGet("/api/v1/products", () => "V1 Products");
        app.MapGet("/api/v2/products", () => "V2 Products with new fields");
        ```
        **Step 2: API Management Versioning**
        - API Management > APIs > Add version > Select scheme (Path/Header/Query)
        **Step 3: Header-Based Versioning**
        ```csharp
        [ApiVersion("1.0")]
        [ApiVersion("2.0")]
        [Route("api/products")]
        public class ProductsController : ControllerBase { }
        ```
        **References:**
        - [API Versioning](https://learn.microsoft.com/en-us/azure/api-management/api-management-versions)

7. How do you automate API deployment?
    - **Answer:**
        Use ARM/Bicep templates for APIM, CI/CD pipelines for backend APIs.
    - **Implementation:**
        **Step 1: Bicep for API Management API**
        ```bicep
        resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
            parent: apimService
            name: 'myapi'
            properties: {
                displayName: 'My API'
                path: 'myapi'
                protocols: ['https']
            }
        }
        ```
        **Step 2: GitHub Actions Deployment**
        ```yaml
        - name: Deploy API
          uses: azure/arm-deploy@v1
          with:
            resourceGroupName: myrg
            template: ./api.bicep
        ```
        **References:**
        - [APIM DevOps](https://learn.microsoft.com/en-us/azure/api-management/devops-api-development-templates)

8. How do you test APIs?
    - **Answer:**
        Use Postman, API Management test console, and automated integration tests.
    - **Implementation:**
        **Step 1: Test in APIM Portal**
        - API Management > APIs > Select API > Test tab
        **Step 2: Integration Test (C#)**
        ```csharp
        [Fact]
        public async Task GetProducts_ReturnsOk()
        {
            var response = await _client.GetAsync("/api/products");
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }
        ```
        **Step 3: Use Postman Collections in CI**
        ```sh
        newman run collection.json --environment env.json
        ```
        **References:**
        - [API Testing](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-test-apis)

9. How do you handle CORS?
    - **Answer:**
        Configure CORS policies in API Management or ASP.NET Core middleware.
    - **Implementation:**
        **Step 1: ASP.NET Core CORS**
        ```csharp
        builder.Services.AddCors(options =>
            options.AddPolicy("AllowFrontend", policy =>
                policy.WithOrigins("https://myapp.com").AllowAnyMethod().AllowAnyHeader()));
        app.UseCors("AllowFrontend");
        ```
        **Step 2: API Management CORS Policy**
        ```xml
        <inbound>
            <cors allow-credentials="true">
                <allowed-origins><origin>https://myapp.com</origin></allowed-origins>
                <allowed-methods><method>*</method></allowed-methods>
                <allowed-headers><header>*</header></allowed-headers>
            </cors>
        </inbound>
        ```
        **References:**
        - [CORS in APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-cross-domain-policies)

10. How do you secure sensitive data in transit?
    - **Answer:**
        Enforce HTTPS only, use TLS 1.2+, and encrypt sensitive payloads if needed.
    - **Implementation:**
        **Step 1: Enforce HTTPS in App Service**
        ```sh
        az webapp update --resource-group myrg --name myapp --https-only true
        ```
        **Step 2: Require TLS 1.2**
        ```sh
        az webapp config set --resource-group myrg --name myapp --min-tls-version 1.2
        ```
        **Step 3: Encrypt Payload (Optional)**
        ```csharp
        var encrypted = Encrypt(sensitiveData, publicKey);
        ```
        **References:**
        - [TLS in Azure](https://learn.microsoft.com/en-us/azure/app-service/configure-ssl-bindings)

11. How do you handle large payloads?
    - **Answer:**
        Use chunked uploads, pagination for large result sets, and streaming for downloads.
    - **Implementation:**
        **Step 1: Chunked Upload**
        ```csharp
        [HttpPost("upload")]
        public async Task<IActionResult> Upload()
        {
            using var stream = new FileStream(path, FileMode.Create);
            await Request.Body.CopyToAsync(stream);
            return Ok();
        }
        ```
        **Step 2: Pagination**
        ```csharp
        [HttpGet("items")]
        public IActionResult GetItems(int page = 1, int size = 20)
        {
            var items = _db.Items.Skip((page - 1) * size).Take(size).ToList();
            return Ok(new { items, page, size, total = _db.Items.Count() });
        }
        ```
        **References:**
        - [Large File Uploads](https://learn.microsoft.com/en-us/aspnet/core/mvc/models/file-uploads)

12. How do you integrate with third-party APIs?
    - **Answer:**
        Use HttpClient in code, Logic Apps connectors, or Azure Functions for orchestration.
    - **Implementation:**
        **Step 1: HttpClient with Retry**
        ```csharp
        builder.Services.AddHttpClient("ThirdParty", client =>
            client.BaseAddress = new Uri("https://api.third-party.com/"))
            .AddPolicyHandler(GetRetryPolicy());
        ```
        **Step 2: Logic App Custom Connector**
        - Logic Apps > Custom connectors > Create from OpenAPI
        **References:**
        - [Call External APIs](https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends)

13. How do you monitor for errors?
    - **Answer:**
        Use Application Insights for telemetry, set up alerts, and review exception logs.
    - **Implementation:**
        **Step 1: Log Exceptions**
        ```csharp
        try { /* code */ }
        catch (Exception ex)
        {
            _telemetryClient.TrackException(ex);
            throw;
        }
        ```
        **Step 2: Query Errors (Kusto)**
        ```kusto
        exceptions
        | where timestamp > ago(24h)
        | summarize count() by type, outerMessage
        ```
        **Step 3: Create Error Alert**
        - Azure Monitor > Alerts > Condition: Exception count > 10
        **References:**
        - [Monitor Exceptions](https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-exceptions)

14. How do you automate API key rotation?
    - **Answer:**
        Store keys in Key Vault, use automatic rotation, and update references.
    - **Implementation:**
        **Step 1: Store in Key Vault**
        ```sh
        az keyvault secret set --vault-name myvault --name ApiKey --value "secret-key"
        ```
        **Step 2: Enable Auto-Rotation**
        - Key Vault > Secrets > ApiKey > Rotation policy > Enable
        **Step 3: Reference in App**
        ```json
        "ApiKey": "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/ApiKey/)"
        ```
        **References:**
        - [Key Rotation](https://learn.microsoft.com/en-us/azure/key-vault/secrets/tutorial-rotation)

15. How do you enforce quotas and limits?
    - **Answer:**
        Use API Management rate-limit and quota policies, monitor usage, and alert on thresholds.
    - **Implementation:**
        **Step 1: Rate Limit Policy**
        ```xml
        <inbound>
            <rate-limit calls="100" renewal-period="60"/>
        </inbound>
        ```
        **Step 2: Quota Policy**
        ```xml
        <inbound>
            <quota calls="10000" renewal-period="86400"/>
        </inbound>
        ```
        **Step 3: Monitor Usage**
        - API Management > Analytics > Usage > Track quota consumption
        **References:**
        - [APIM Rate Limiting](https://learn.microsoft.com/en-us/azure/api-management/api-management-access-restriction-policies)

16. How do you implement GraphQL APIs with Azure?
    - **Answer:**
        Use Hot Chocolate or GraphQL.NET with App Service, or Azure API Management GraphQL gateway for existing REST APIs.
    - **Implementation:**
        **Step 1: Hot Chocolate Setup**
        ```csharp
        builder.Services
            .AddGraphQLServer()
            .AddQueryType<Query>()
            .AddMutationType<Mutation>()
            .AddSubscriptionType<Subscription>()
            .AddFiltering()
            .AddSorting()
            .AddProjections();

        app.MapGraphQL();
        ```
        **Step 2: Define GraphQL Schema**
        ```csharp
        public class Query
        {
            [UseProjection]
            [UseFiltering]
            [UseSorting]
            public IQueryable<Order> GetOrders([Service] AppDbContext context)
                => context.Orders;

            public async Task<Order?> GetOrder(Guid id, [Service] IOrderService service)
                => await service.GetByIdAsync(id);
        }

        public class Mutation
        {
            public async Task<Order> CreateOrder(CreateOrderInput input, [Service] IOrderService service)
                => await service.CreateAsync(input);
        }
        ```
        **Step 3: API Management GraphQL Gateway**
        ```sh
        az apim graphql-api create \
            --resource-group myrg \
            --service-name myapim \
            --api-id orders-graphql \
            --display-name "Orders GraphQL API" \
            --path /graphql
        ```
        **References:**
        - [GraphQL with Hot Chocolate](https://chillicream.com/docs/hotchocolate)
        - [APIM GraphQL](https://learn.microsoft.com/en-us/azure/api-management/graphql-api)

17. How do you implement API versioning?
    - **Answer:**
        Use URL path, query string, or header-based versioning. Implement with ASP.NET Core API Versioning package and API Management.
    - **Implementation:**
        **Step 1: Configure API Versioning**
        ```csharp
        builder.Services.AddApiVersioning(options =>
        {
            options.DefaultApiVersion = new ApiVersion(1, 0);
            options.AssumeDefaultVersionWhenUnspecified = true;
            options.ReportApiVersions = true;
            options.ApiVersionReader = ApiVersionReader.Combine(
                new UrlSegmentApiVersionReader(),
                new HeaderApiVersionReader("X-Api-Version"),
                new QueryStringApiVersionReader("api-version"));
        });

        builder.Services.AddVersionedApiExplorer(options =>
        {
            options.GroupNameFormat = "'v'VVV";
            options.SubstituteApiVersionInUrl = true;
        });
        ```
        **Step 2: Version Controllers**
        ```csharp
        [ApiController]
        [ApiVersion("1.0")]
        [Route("api/v{version:apiVersion}/[controller]")]
        public class OrdersV1Controller : ControllerBase
        {
            [HttpGet]
            public IActionResult Get() => Ok("V1 response");
        }

        [ApiController]
        [ApiVersion("2.0")]
        [Route("api/v{version:apiVersion}/[controller]")]
        public class OrdersV2Controller : ControllerBase
        {
            [HttpGet]
            public IActionResult Get() => Ok(new { version = "2.0", data = "V2 response" });
        }
        ```
        **References:**
        - [API Versioning](https://learn.microsoft.com/en-us/aspnet/core/web-api/advanced/conventions)

18. How do you implement resilient HTTP clients?
    - **Answer:**
        Use HttpClientFactory with Polly for retry, circuit breaker, and timeout policies. Configure in DI for proper connection management.
    - **Implementation:**
        **Step 1: Configure Resilient HttpClient**
        ```csharp
        builder.Services.AddHttpClient<IOrderApiClient, OrderApiClient>(client =>
        {
            client.BaseAddress = new Uri("https://api.orders.com/");
            client.DefaultRequestHeaders.Add("Accept", "application/json");
        })
        .AddPolicyHandler(GetRetryPolicy())
        .AddPolicyHandler(GetCircuitBreakerPolicy())
        .AddPolicyHandler(Policy.TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(10)));

        static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
        {
            return HttpPolicyExtensions
                .HandleTransientHttpError()
                .OrResult(msg => msg.StatusCode == HttpStatusCode.TooManyRequests)
                .WaitAndRetryAsync(3, retryAttempt =>
                    TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                    onRetry: (outcome, timespan, retryCount, context) =>
                    {
                        // Log retry
                    });
        }

        static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
        {
            return HttpPolicyExtensions
                .HandleTransientHttpError()
                .CircuitBreakerAsync(5, TimeSpan.FromSeconds(30));
        }
        ```
        **References:**
        - [HttpClientFactory with Polly](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/implement-http-call-retries-exponential-backoff-polly)

19. How do you implement OpenAPI/Swagger documentation?
    - **Answer:**
        Use Swashbuckle or NSwag to generate OpenAPI specs. Configure authentication, examples, and descriptions for comprehensive documentation.
    - **Implementation:**
        **Step 1: Configure Swagger**
        ```csharp
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "Orders API",
                Version = "v1",
                Description = "API for managing orders",
                Contact = new OpenApiContact { Name = "Support", Email = "support@mycompany.com" }
            });

            c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                Description = "JWT Authorization header"
            });

            c.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } },
                    Array.Empty<string>()
                }
            });

            c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, "MyApi.xml"));
        });
        ```
        **Step 2: Document Endpoints**
        ```csharp
        /// <summary>
        /// Creates a new order
        /// </summary>
        /// <param name="request">Order creation request</param>
        /// <returns>Created order</returns>
        /// <response code="201">Order created successfully</response>
        /// <response code="400">Invalid request</response>
        [HttpPost]
        [ProducesResponseType(typeof(OrderResponse), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
        ```
        **References:**
        - [Swagger in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/tutorials/web-api-help-pages-using-swagger)

20. How do you implement webhook endpoints securely?
    - **Answer:**
        Validate webhook signatures, use HTTPS, implement idempotency, and verify sender identity with shared secrets or certificates.
    - **Implementation:**
        **Step 1: Validate Webhook Signature**
        ```csharp
        [HttpPost("webhook")]
        public async Task<IActionResult> HandleWebhook()
        {
            // Read raw body for signature verification
            Request.EnableBuffering();
            using var reader = new StreamReader(Request.Body, leaveOpen: true);
            var body = await reader.ReadToEndAsync();
            Request.Body.Position = 0;

            // Verify signature
            var signature = Request.Headers["X-Signature"].FirstOrDefault();
            if (!VerifySignature(body, signature, _webhookSecret))
            {
                return Unauthorized();
            }

            // Parse and process
            var payload = JsonSerializer.Deserialize<WebhookPayload>(body);

            // Check idempotency
            if (await _webhookStore.IsProcessedAsync(payload.Id))
            {
                return Ok(); // Already processed
            }

            await ProcessWebhookAsync(payload);
            await _webhookStore.MarkProcessedAsync(payload.Id);

            return Ok();
        }

        private bool VerifySignature(string body, string signature, string secret)
        {
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(body));
            var expected = Convert.ToHexString(hash);
            return signature.Equals(expected, StringComparison.OrdinalIgnoreCase);
        }
        ```
        **References:**
        - [Webhook Security](https://learn.microsoft.com/en-us/azure/event-grid/webhook-event-delivery)


## 6. Azure Cache and Messaging (Redis, Service Bus, Event Hubs)


### 6.1 Azure Cache for Redis
1. How do you implement distributed caching in ASP.NET Core?
     - **Answer:**
         Use Microsoft.Extensions.Caching.StackExchangeRedis, configure Redis, and use IDistributedCache in your services/controllers.
     - **Implementation:**
         **Step 1: Add NuGet Package**
         - Microsoft.Extensions.Caching.StackExchangeRedis
         **Step 2: Configure in Program.cs**
         ```csharp
         builder.Services.AddStackExchangeRedisCache(options =>
         {
                 options.Configuration = "<redis-connection-string>";
         });
         ```
         **Step 3: Use IDistributedCache in Service**
         ```csharp
         public class MyService
         {
                 private readonly IDistributedCache _cache;
                 public MyService(IDistributedCache cache) => _cache = cache;
                 public async Task SetValueAsync(string key, string value)
                 {
                         await _cache.SetStringAsync(key, value, new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10) });
                 }
                 public async Task<string> GetValueAsync(string key)
                 {
                         return await _cache.GetStringAsync(key);
                 }
         }
         ```
         **References:**
         - [Distributed caching with Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-aspnet-core-how-to)

2. How do you secure Redis access?
     - **Answer:**
         Use SSL, firewall rules, private endpoints, and Managed Identity for access.
     - **Implementation:**
         **Step 1: Enable SSL**
         - Azure Portal: Redis > Settings > Advanced > Enable SSL
         **Step 2: Restrict by Firewall/Virtual Network**
         - Redis > Networking > Allow access only from selected networks
         **Step 3: Use Private Endpoint**
         - Redis > Networking > Private endpoint > Add
         **References:**
         - [Secure Azure Cache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-networking)

3. How do you monitor cache performance?
     - **Answer:**
         Use Azure Monitor metrics, set up alerts, and review logs.
     - **Implementation:**
         **Step 1: Azure Portal > Redis > Monitoring > Metrics**
         - Review metrics like server load, memory usage, and connections
         **Step 2: Set Up Alerts**
         - Redis > Alerts > New alert rule
         **References:**
         - [Monitor Redis performance](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-monitor)

4. How do you handle cache expiration?
     - **Answer:**
         Set TTL on cache entries, use sliding or absolute expiration.
     - **Implementation:**
         **Step 1: Set Expiration in Code**
         ```csharp
         await _cache.SetStringAsync(key, value, new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10) });
         ```
         **References:**
         - [Cache expiration](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-how-to-use-azure-redis-cache)

5. How do you automate failover?
     - **Answer:**
         Use Premium tier with geo-replication and automatic failover.
     - **Implementation:**
         **Step 1: Create Premium Redis Cache**
         - Azure Portal: Create > Azure Cache for Redis > Pricing tier: Premium
         **Step 2: Configure Geo-Replication**
         - Redis > Geo-replication > Add secondary cache
         **References:**
         - [Geo-replication and failover](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-geo-replication)

6. How do you scale Redis?
     - **Answer:**
         Use scaling options in portal, shard data, and monitor usage.
     - **Implementation:**
         **Step 1: Scale in Portal**
         - Redis > Scale > Change pricing tier or shard count
         **Step 2: Monitor Usage**
         - Redis > Monitoring > Metrics
         **References:**
         - [Scaling Azure Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale)

7. How do you handle large objects?
     - **Answer:**
         Store references in cache, keep payloads small, use compression if needed.
     - **Implementation:**
         **Step 1: Store Reference to Blob/File**
         - Save a URL or key to the large object in Redis, not the object itself
         **Step 2: Use Compression (C#)**
         ```csharp
         using System.IO.Compression;
         // Compress before storing, decompress after retrieving
         ```
         **References:**
         - [Best practices for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices)

8. How do you implement pub/sub?
     - **Answer:**
         Use Redis pub/sub channels for messaging between services.
     - **Implementation:**
         **Step 1: Use StackExchange.Redis**
         ```csharp
         var redis = ConnectionMultiplexer.Connect("<redis-connection-string>");
         var sub = redis.GetSubscriber();
         // Subscribe
         sub.Subscribe("messages", (channel, message) => Console.WriteLine(message));
         // Publish
         sub.Publish("messages", "Hello from publisher!");
         ```
         **References:**
         - [Redis pub/sub](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-how-to-use-azure-redis-cache#publish-and-subscribe)

9. How do you automate cache warm-up?
     - **Answer:**
         Preload frequently used data on startup or after failover.
     - **Implementation:**
         **Step 1: On App Startup, Load Data into Cache**
         ```csharp
         foreach (var key in importantKeys)
         {
                 var value = await _db.StringGetAsync(key);
                 if (value.IsNullOrEmpty)
                 {
                         var data = await LoadFromDbAsync(key);
                         await _db.StringSetAsync(key, data);
                 }
         }
         ```
         **References:**
         - [Cache warm-up](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices)

10. How do you handle cache consistency?
     - **Answer:**
         Use cache invalidation strategies and monitor for stale data.
     - **Implementation:**
         **Step 1: Invalidate Cache on Data Change**
         ```csharp
         await _cache.RemoveAsync(key);
         ```
         **Step 2: Use Pub/Sub to Notify Other Services**
         - See question 8
         **References:**
         - [Cache consistency](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices)

11. How do you integrate with Functions or Logic Apps?
     - **Answer:**
         Use SDKs or REST API, manage connections securely.
     - **Implementation:**
         **Step 1: Use StackExchange.Redis in Azure Functions**
         ```csharp
         [FunctionName("RedisFunction")]
         public static async Task Run([TimerTrigger("0 */5 * * * *")] TimerInfo timer, ILogger log)
         {
                 var redis = ConnectionMultiplexer.Connect("<redis-connection-string>");
                 var db = redis.GetDatabase();
                 await db.StringSetAsync("key", "value");
         }
         ```
         **References:**
         - [Redis with Azure Functions](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-how-to-use-azure-redis-cache)

12. How do you optimize for cost?
     - **Answer:**
         Use appropriate tier, monitor usage, and evict unused data.
     - **Implementation:**
         **Step 1: Choose Right Tier in Portal**
         - Redis > Scale > Select tier
         **Step 2: Monitor Usage and Set Expirations**
         - See question 4
         **References:**
         - [Cost optimization](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices)

13. How do you audit cache access?
     - **Answer:**
         Enable diagnostics, review logs, and monitor access patterns.
     - **Implementation:**
         **Step 1: Enable Diagnostics in Portal**
         - Redis > Diagnostics > Enable
         **Step 2: Review Logs in Log Analytics**
         - Azure Monitor > Logs > Query Redis logs
         **References:**
         - [Audit Redis access](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-monitor-diagnostic-logs)

14. How do you automate cache provisioning?
     - **Answer:**
         Use ARM/Bicep templates, Azure CLI, or Terraform.
     - **Implementation:**
         **Step 1: Azure CLI Example**
         ```sh
         az redis create --name mycache --resource-group myrg --location eastus --sku Basic --vm-size c0
         ```
         **References:**
         - [Provision Redis with CLI](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-manage-cli)

15. How do you test cache integration?
     - **Answer:**
         Use a local Redis instance or Azure Cache emulator.
     - **Implementation:**
         **Step 1: Run Redis Locally (Docker)**
         ```sh
         docker run -d -p 6379:6379 redis
         ```
         **Step 2: Point Connection String to localhost:6379 in your app**
         **References:**
         - [Test with local Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-how-to-use-azure-redis-cache)

16. How do you implement Redis pub/sub for real-time messaging?
    - **Answer:**
        Use Redis pub/sub for lightweight real-time messaging between services. Good for notifications but not for guaranteed delivery.
    - **Implementation:**
        **Step 1: Publish Messages**
        ```csharp
        public class RedisPublisher
        {
            private readonly IConnectionMultiplexer _redis;

            public async Task PublishAsync(string channel, string message)
            {
                var subscriber = _redis.GetSubscriber();
                await subscriber.PublishAsync(channel, message);
            }
        }
        ```
        **Step 2: Subscribe to Messages**
        ```csharp
        public class RedisSubscriber : BackgroundService
        {
            private readonly IConnectionMultiplexer _redis;

            protected override async Task ExecuteAsync(CancellationToken stoppingToken)
            {
                var subscriber = _redis.GetSubscriber();

                await subscriber.SubscribeAsync("notifications", (channel, message) =>
                {
                    Console.WriteLine($"Received: {message}");
                });

                // Pattern subscription
                await subscriber.SubscribeAsync(new RedisChannel("orders:*", RedisChannel.PatternMode.Pattern),
                    (channel, message) =>
                    {
                        Console.WriteLine($"Order event on {channel}: {message}");
                    });
            }
        }
        ```
        **References:**
        - [Redis Pub/Sub](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-core-quickstart)

17. How do you implement Redis Streams for event sourcing?
    - **Answer:**
        Redis Streams provide append-only log data structure for event sourcing, with consumer groups for parallel processing.
    - **Implementation:**
        **Step 1: Add Events to Stream**
        ```csharp
        public class EventStore
        {
            private readonly IDatabase _db;

            public async Task<string> AppendEventAsync(string streamKey, Dictionary<string, string> eventData)
            {
                var entries = eventData.Select(kv => new NameValueEntry(kv.Key, kv.Value)).ToArray();
                return await _db.StreamAddAsync(streamKey, entries);
            }
        }
        ```
        **Step 2: Create Consumer Group**
        ```csharp
        await _db.StreamCreateConsumerGroupAsync("orders", "order-processors", StreamPosition.NewMessages, createStream: true);
        ```
        **Step 3: Process with Consumer Group**
        ```csharp
        public async Task ProcessEventsAsync(string stream, string group, string consumer)
        {
            while (true)
            {
                var entries = await _db.StreamReadGroupAsync(stream, group, consumer, ">", count: 10);

                foreach (var entry in entries)
                {
                    await ProcessEventAsync(entry);
                    await _db.StreamAcknowledgeAsync(stream, group, entry.Id);
                }

                await Task.Delay(100);
            }
        }
        ```
        **References:**
        - [Redis Streams](https://redis.io/docs/data-types/streams/)

18. How do you implement cache-aside pattern with Redis?
    - **Answer:**
        Check cache first, load from database on miss, and populate cache. Handle cache invalidation on updates.
    - **Implementation:**
        **Step 1: Implement Cache-Aside**
        ```csharp
        public class ProductRepository
        {
            private readonly IDistributedCache _cache;
            private readonly AppDbContext _db;

            public async Task<Product> GetByIdAsync(int id)
            {
                var cacheKey = $"product:{id}";

                // Try cache first
                var cached = await _cache.GetStringAsync(cacheKey);
                if (cached != null)
                {
                    return JsonSerializer.Deserialize<Product>(cached);
                }

                // Cache miss - load from DB
                var product = await _db.Products.FindAsync(id);
                if (product != null)
                {
                    await _cache.SetStringAsync(cacheKey,
                        JsonSerializer.Serialize(product),
                        new DistributedCacheEntryOptions
                        {
                            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30)
                        });
                }

                return product;
            }

            public async Task UpdateAsync(Product product)
            {
                _db.Products.Update(product);
                await _db.SaveChangesAsync();

                // Invalidate cache
                await _cache.RemoveAsync($"product:{product.Id}");
            }
        }
        ```
        **References:**
        - [Cache-Aside Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside)

19. How do you implement Redis data persistence and backup?
    - **Answer:**
        Use Premium tier with RDB persistence (snapshots) or AOF (append-only file). Configure backup schedules for disaster recovery.
    - **Implementation:**
        **Step 1: Enable Data Persistence**
        ```sh
        az redis update \
            --name mycache \
            --resource-group myrg \
            --set "redisConfiguration.rdb-backup-enabled=true" \
            --set "redisConfiguration.rdb-backup-frequency=60" \
            --set "redisConfiguration.rdb-storage-connection-string=<storage-connection-string>"
        ```
        **Step 2: Configure AOF Persistence**
        ```sh
        az redis update \
            --name mycache \
            --resource-group myrg \
            --set "redisConfiguration.aof-backup-enabled=true" \
            --set "redisConfiguration.aof-storage-connection-string0=<storage-connection-string>"
        ```
        **Step 3: Export Data Manually**
        ```sh
        az redis export \
            --name mycache \
            --resource-group myrg \
            --prefix backup \
            --container /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount/blobServices/default/containers/redis-backups
        ```
        **References:**
        - [Redis Data Persistence](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-persistence)

20. How do you implement Redis clustering for high availability?
    - **Answer:**
        Use Premium tier with clustering for horizontal scaling. Data is automatically sharded across nodes with automatic failover.
    - **Implementation:**
        **Step 1: Create Clustered Cache**
        ```sh
        az redis create \
            --name mycache \
            --resource-group myrg \
            --location eastus \
            --sku Premium \
            --vm-size P1 \
            --shard-count 3 \
            --replicas-per-master 1
        ```
        **Step 2: Configure Client for Cluster**
        ```csharp
        var options = new ConfigurationOptions
        {
            EndPoints = { "mycache.redis.cache.windows.net:6380" },
            Password = "<access-key>",
            Ssl = true,
            AbortOnConnectFail = false,
            ConnectTimeout = 5000,
            SyncTimeout = 5000
        };

        var connection = ConnectionMultiplexer.Connect(options);
        ```
        **Step 3: Monitor Cluster Health**
        ```sh
        az redis show --name mycache --resource-group myrg --query "shardCount"

        # Check cluster status via Redis CLI
        redis-cli -h mycache.redis.cache.windows.net -p 6380 -a <password> --tls cluster info
        ```
        **References:**
        - [Redis Clustering](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-clustering)

### 6.2 Azure Service Bus
1. How do you implement message sessions?
    - **Answer:**
        Use sessions for FIFO ordered message processing by setting SessionId on messages and enabling sessions on queue/subscription.
    - **Implementation:**
        **Step 1: Create Session-Enabled Queue**
        ```sh
        az servicebus queue create --resource-group myrg --namespace-name mynamespace --name myqueue --enable-session true
        ```
        **Step 2: Send Message with SessionId (C#)**
        ```csharp
        var message = new ServiceBusMessage("Order data")
        {
            SessionId = "order-123"
        };
        await sender.SendMessageAsync(message);
        ```
        **Step 3: Receive with Session**
        ```csharp
        var receiver = client.AcceptSessionAsync("myqueue", "order-123");
        var message = await receiver.ReceiveMessageAsync();
        ```
        **References:**
        - [Service Bus Sessions](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-sessions)

2. How do you secure Service Bus access?
    - **Answer:**
        Use SAS tokens for temporary access, Azure AD with RBAC for identity-based access, and firewall rules.
    - **Implementation:**
        **Step 1: Use Azure AD Authentication (C#)**
        ```csharp
        var client = new ServiceBusClient("mynamespace.servicebus.windows.net", new DefaultAzureCredential());
        ```
        **Step 2: Generate SAS Token**
        ```csharp
        var sasToken = ServiceBusExtensions.CreateSharedAccessSignature(queueUri, sasKeyName, sasKey, TimeSpan.FromHours(1));
        ```
        **Step 3: Configure Firewall**
        ```sh
        az servicebus namespace network-rule add --resource-group myrg --namespace-name mynamespace --ip-address 203.0.113.0/24
        ```
        **References:**
        - [Service Bus Security](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-authentication-and-authorization)

3. How do you handle dead-letter messages?
    - **Answer:**
        Monitor dead-letter queues, set up alerts, process or investigate failed messages, and fix root causes.
    - **Implementation:**
        **Step 1: Receive from Dead-Letter Queue**
        ```csharp
        var dlqPath = EntityNameHelper.FormatDeadLetterPath("myqueue");
        var receiver = client.CreateReceiver(dlqPath);
        var message = await receiver.ReceiveMessageAsync();
        Console.WriteLine($"DLQ Reason: {message.DeadLetterReason}");
        ```
        **Step 2: Query DLQ Count (Kusto)**
        ```kusto
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.SERVICEBUS"
        | where MetricName == "DeadletteredMessages"
        | summarize max(Total) by bin(TimeGenerated, 1h)
        ```
        **Step 3: Set Up Alert**
        - Azure Monitor > Alerts > Condition: Dead-lettered Messages > 0
        **References:**
        - [Dead-Letter Queues](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dead-letter-queues)

4. How do you implement duplicate detection?
    - **Answer:**
        Enable duplicate detection on queue/topic, set MessageId, and configure detection window.
    - **Implementation:**
        **Step 1: Create Queue with Duplicate Detection**
        ```sh
        az servicebus queue create --resource-group myrg --namespace-name mynamespace --name myqueue --enable-duplicate-detection true --duplicate-detection-history-time-window P1D
        ```
        **Step 2: Set MessageId**
        ```csharp
        var message = new ServiceBusMessage("data")
        {
            MessageId = "unique-order-id-123"
        };
        await sender.SendMessageAsync(message);
        ```
        **References:**
        - [Duplicate Detection](https://learn.microsoft.com/en-us/azure/service-bus-messaging/duplicate-detection)

5. How do you monitor Service Bus health?
    - **Answer:**
        Use Azure Monitor metrics, set up alerts for queue depth and errors, and review diagnostic logs.
    - **Implementation:**
        **Step 1: View Metrics**
        - Service Bus Namespace > Monitoring > Metrics > Active Messages, Dead-lettered Messages
        **Step 2: Query Logs (Kusto)**
        ```kusto
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.SERVICEBUS"
        | where Category == "OperationalLogs"
        | project TimeGenerated, OperationName, ResultType
        ```
        **Step 3: Create Alert**
        - Azure Monitor > Alerts > Condition: Active Messages > 1000
        **References:**
        - [Monitor Service Bus](https://learn.microsoft.com/en-us/azure/service-bus-messaging/monitor-service-bus)

6. How do you automate topic/subscription creation?
    - **Answer:**
        Use ARM/Bicep templates, Azure CLI, or SDK for infrastructure as code.
    - **Implementation:**
        **Step 1: CLI**
        ```sh
        az servicebus topic create --resource-group myrg --namespace-name mynamespace --name mytopic
        az servicebus topic subscription create --resource-group myrg --namespace-name mynamespace --topic-name mytopic --name mysub
        ```
        **Step 2: Bicep Template**
        ```bicep
        resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
            parent: namespace
            name: 'mytopic'
        }
        resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
            parent: topic
            name: 'mysub'
        }
        ```
        **References:**
        - [Service Bus ARM Templates](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics)

7. How do you handle message ordering?
    - **Answer:**
        Use sessions for strict FIFO ordering within a session, design consumers to process sequentially.
    - **Implementation:**
        **Step 1: Enable Sessions (see question 1)**
        **Step 2: Process Messages in Order**
        ```csharp
        var sessionReceiver = await client.AcceptNextSessionAsync("myqueue");
        while (true)
        {
            var message = await sessionReceiver.ReceiveMessageAsync(TimeSpan.FromSeconds(5));
            if (message == null) break;
            // Process in order
            await sessionReceiver.CompleteMessageAsync(message);
        }
        ```
        **References:**
        - [Message Ordering](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-sessions)

8. How do you implement scheduled messages?
    - **Answer:**
        Set ScheduledEnqueueTime property to delay message delivery until specified time.
    - **Implementation:**
        **Step 1: Schedule Message (C#)**
        ```csharp
        var message = new ServiceBusMessage("Scheduled data");
        var sequenceNumber = await sender.ScheduleMessageAsync(message, DateTimeOffset.UtcNow.AddHours(1));
        ```
        **Step 2: Cancel Scheduled Message**
        ```csharp
        await sender.CancelScheduledMessageAsync(sequenceNumber);
        ```
        **References:**
        - [Scheduled Messages](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-sequencing)

9. How do you handle large messages?
    - **Answer:**
        Store payload in Blob Storage, send blob reference in Service Bus message (claim check pattern).
    - **Implementation:**
        **Step 1: Upload to Blob**
        ```csharp
        var blobClient = containerClient.GetBlobClient($"payloads/{Guid.NewGuid()}.json");
        await blobClient.UploadAsync(BinaryData.FromString(largePayload));
        ```
        **Step 2: Send Reference**
        ```csharp
        var message = new ServiceBusMessage(JsonSerializer.Serialize(new { BlobUri = blobClient.Uri }));
        await sender.SendMessageAsync(message);
        ```
        **Step 3: Download in Consumer**
        ```csharp
        var reference = JsonSerializer.Deserialize<BlobReference>(message.Body.ToString());
        var blobClient = new BlobClient(new Uri(reference.BlobUri), credential);
        var content = await blobClient.DownloadContentAsync();
        ```
        **References:**
        - [Claim Check Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/claim-check)

10. How do you integrate with Functions or Logic Apps?
    - **Answer:**
        Use Service Bus triggers for automatic processing and output bindings for sending messages.
    - **Implementation:**
        **Step 1: Azure Function with Service Bus Trigger**
        ```csharp
        [FunctionName("ProcessMessage")]
        public static void Run(
            [ServiceBusTrigger("myqueue", Connection = "ServiceBusConnection")] string message,
            ILogger log)
        {
            log.LogInformation($"Received: {message}");
        }
        ```
        **Step 2: Logic App Trigger**
        - Logic App Designer > Trigger: When a message is received in a queue (Service Bus)
        **Step 3: Output Binding**
        ```csharp
        [FunctionName("SendMessage")]
        [return: ServiceBus("myqueue", Connection = "ServiceBusConnection")]
        public static string Run([HttpTrigger] HttpRequest req) => "New message";
        ```
        **References:**
        - [Service Bus Bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus)

11. How do you automate failover?
    - **Answer:**
        Use geo-disaster recovery with namespace pairing and alias for automatic failover.
    - **Implementation:**
        **Step 1: Create Secondary Namespace**
        ```sh
        az servicebus namespace create --resource-group myrg --name mynamespace-secondary --location westus
        ```
        **Step 2: Create Geo-DR Pairing**
        ```sh
        az servicebus georecovery-alias set --resource-group myrg --namespace-name mynamespace --alias myalias --partner-namespace /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.ServiceBus/namespaces/mynamespace-secondary
        ```
        **Step 3: Initiate Failover**
        ```sh
        az servicebus georecovery-alias fail-over --resource-group myrg --namespace-name mynamespace-secondary --alias myalias
        ```
        **References:**
        - [Geo-DR](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-geo-dr)

12. How do you optimize for cost?
    - **Answer:**
        Use appropriate tier (Basic/Standard/Premium), monitor message counts, and clean up unused entities.
    - **Implementation:**
        **Step 1: Choose Right Tier**
        - Basic: Simple queues, Standard: Topics/subscriptions, Premium: High throughput
        **Step 2: Monitor Usage**
        - Service Bus > Metrics > Messages, Size
        **Step 3: Delete Unused Entities**
        ```sh
        az servicebus queue delete --resource-group myrg --namespace-name mynamespace --name unusedqueue
        ```
        **References:**
        - [Service Bus Pricing](https://azure.microsoft.com/en-us/pricing/details/service-bus/)

13. How do you audit access?
    - **Answer:**
        Enable diagnostic logs, send to Log Analytics, and review access patterns.
    - **Implementation:**
        **Step 1: Enable Diagnostics**
        ```sh
        az monitor diagnostic-settings create --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.ServiceBus/namespaces/mynamespace --name mydiag --logs '[{"category":"OperationalLogs","enabled":true}]' --workspace <workspace-id>
        ```
        **Step 2: Query Logs (Kusto)**
        ```kusto
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.SERVICEBUS"
        | project TimeGenerated, OperationName, CallerIpAddress
        ```
        **References:**
        - [Service Bus Logging](https://learn.microsoft.com/en-us/azure/service-bus-messaging/monitor-service-bus)

14. How do you handle message lock renewal?
    - **Answer:**
        Use auto-renewal in SDK, handle MessageLockLostException, and configure appropriate lock duration.
    - **Implementation:**
        **Step 1: Configure Auto Lock Renewal**
        ```csharp
        var processor = client.CreateProcessor("myqueue", new ServiceBusProcessorOptions
        {
            MaxAutoLockRenewalDuration = TimeSpan.FromMinutes(10)
        });
        ```
        **Step 2: Handle Lock Lost**
        ```csharp
        processor.ProcessErrorAsync += args =>
        {
            if (args.Exception is ServiceBusException sbEx && sbEx.Reason == ServiceBusFailureReason.MessageLockLost)
            {
                // Log and handle - message will be redelivered
            }
            return Task.CompletedTask;
        };
        ```
        **References:**
        - [Message Locks](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-transfers-locks-settlement)

15. How do you test Service Bus integration?
    - **Answer:**
        Use Service Bus Explorer for manual testing, integration tests with real queues, or local emulator.
    - **Implementation:**
        **Step 1: Use Service Bus Explorer**
        - Download from GitHub: Azure/ServiceBusExplorer
        - Connect to namespace and send/receive test messages
        **Step 2: Integration Test (C#)**
        ```csharp
        [Fact]
        public async Task CanSendAndReceiveMessage()
        {
            await sender.SendMessageAsync(new ServiceBusMessage("test"));
            var message = await receiver.ReceiveMessageAsync();
            Assert.Equal("test", message.Body.ToString());
            await receiver.CompleteMessageAsync(message);
        }
        ```
        **References:**
        - [Service Bus Explorer](https://github.com/paolosalvatori/ServiceBusExplorer)

16. How do you implement message correlation and request-reply pattern?
    - **Answer:**
        Use CorrelationId, ReplyTo, and ReplyToSessionId properties for correlating requests with responses across different queues.
    - **Implementation:**
        **Step 1: Send Request with Correlation**
        ```csharp
        public class RequestReplyService
        {
            public async Task<TResponse> SendRequestAsync<TRequest, TResponse>(string requestQueue, string replyQueue, TRequest request)
            {
                var correlationId = Guid.NewGuid().ToString();
                var sessionId = Guid.NewGuid().ToString();

                var message = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(request))
                {
                    CorrelationId = correlationId,
                    ReplyTo = replyQueue,
                    ReplyToSessionId = sessionId,
                    TimeToLive = TimeSpan.FromMinutes(5)
                };

                await _sender.SendMessageAsync(message);

                // Wait for response on session
                var sessionReceiver = await _client.AcceptSessionAsync(replyQueue, sessionId);
                var response = await sessionReceiver.ReceiveMessageAsync(TimeSpan.FromSeconds(30));

                if (response?.CorrelationId == correlationId)
                {
                    await sessionReceiver.CompleteMessageAsync(response);
                    return JsonSerializer.Deserialize<TResponse>(response.Body);
                }

                throw new TimeoutException("Response not received");
            }
        }
        ```
        **Step 2: Process and Reply**
        ```csharp
        async Task ProcessMessageAsync(ProcessMessageEventArgs args)
        {
            var request = JsonSerializer.Deserialize<OrderRequest>(args.Message.Body);
            var response = await ProcessOrderAsync(request);

            var replyMessage = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(response))
            {
                CorrelationId = args.Message.CorrelationId,
                SessionId = args.Message.ReplyToSessionId
            };

            var replySender = _client.CreateSender(args.Message.ReplyTo);
            await replySender.SendMessageAsync(replyMessage);
        }
        ```
        **References:**
        - [Request-Reply Pattern](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-sessions)

17. How do you implement message batching for throughput?
    - **Answer:**
        Use ServiceBusMessageBatch for sending multiple messages efficiently. SDK handles size limits automatically.
    - **Implementation:**
        **Step 1: Batch Send Messages**
        ```csharp
        public async Task SendBatchAsync<T>(IEnumerable<T> items)
        {
            using var batch = await _sender.CreateMessageBatchAsync();

            foreach (var item in items)
            {
                var message = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(item));

                if (!batch.TryAddMessage(message))
                {
                    // Batch is full, send and create new
                    await _sender.SendMessagesAsync(batch);
                    batch = await _sender.CreateMessageBatchAsync();

                    if (!batch.TryAddMessage(message))
                    {
                        throw new Exception("Message too large for batch");
                    }
                }
            }

            // Send remaining
            if (batch.Count > 0)
            {
                await _sender.SendMessagesAsync(batch);
            }
        }
        ```
        **Step 2: Configure Processor for Batching**
        ```csharp
        var processor = client.CreateProcessor("myqueue", new ServiceBusProcessorOptions
        {
            MaxConcurrentCalls = 10,
            PrefetchCount = 100
        });
        ```
        **References:**
        - [Message Batching](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-performance-improvements)

18. How do you implement scheduled messages?
    - **Answer:**
        Use ScheduledEnqueueTime property to defer message delivery. Messages are held in the queue until the scheduled time.
    - **Implementation:**
        **Step 1: Schedule Message**
        ```csharp
        public async Task<long> ScheduleMessageAsync<T>(T payload, DateTimeOffset scheduledTime)
        {
            var message = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(payload))
            {
                ScheduledEnqueueTime = scheduledTime
            };

            // Returns sequence number for cancellation
            return await _sender.ScheduleMessageAsync(message, scheduledTime);
        }
        ```
        **Step 2: Cancel Scheduled Message**
        ```csharp
        public async Task CancelScheduledMessageAsync(long sequenceNumber)
        {
            await _sender.CancelScheduledMessageAsync(sequenceNumber);
        }
        ```
        **Step 3: Schedule Multiple Messages**
        ```csharp
        public async Task<IEnumerable<long>> ScheduleRemindersAsync(IEnumerable<Reminder> reminders)
        {
            var messages = reminders.Select(r => new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(r))
            {
                ScheduledEnqueueTime = r.ReminderTime,
                MessageId = r.Id.ToString()
            });

            return await _sender.ScheduleMessagesAsync(messages, DateTimeOffset.UtcNow);
        }
        ```
        **References:**
        - [Scheduled Messages](https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-sequencing)

19. How do you implement message forwarding and auto-forwarding?
    - **Answer:**
        Auto-forwarding automatically routes messages from one queue/subscription to another for workflow chains and fan-out patterns.
    - **Implementation:**
        **Step 1: Create Queue with Auto-Forward**
        ```sh
        # Create destination queue
        az servicebus queue create \
            --resource-group myrg \
            --namespace-name mynamespace \
            --name processing-queue

        # Create source queue with auto-forward
        az servicebus queue create \
            --resource-group myrg \
            --namespace-name mynamespace \
            --name intake-queue \
            --forward-to processing-queue
        ```
        **Step 2: Subscription Auto-Forward**
        ```sh
        az servicebus topic subscription create \
            --resource-group myrg \
            --namespace-name mynamespace \
            --topic-name orders \
            --name high-priority \
            --forward-to high-priority-queue
        ```
        **Step 3: Bicep Template**
        ```bicep
        resource intakeQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
            parent: namespace
            name: 'intake-queue'
            properties: {
                forwardTo: processingQueue.name
                maxDeliveryCount: 10
            }
        }
        ```
        **References:**
        - [Auto-Forwarding](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-auto-forwarding)

20. How do you implement duplicate detection?
    - **Answer:**
        Enable duplicate detection on queues/topics. Service Bus tracks message IDs within a time window and rejects duplicates.
    - **Implementation:**
        **Step 1: Create Queue with Duplicate Detection**
        ```sh
        az servicebus queue create \
            --resource-group myrg \
            --namespace-name mynamespace \
            --name orders \
            --enable-duplicate-detection true \
            --duplicate-detection-history-time-window P1D
        ```
        **Step 2: Send Idempotent Messages**
        ```csharp
        public async Task SendOrderAsync(Order order)
        {
            var message = new ServiceBusMessage(JsonSerializer.SerializeToUtf8Bytes(order))
            {
                MessageId = order.Id.ToString() // Same ID = duplicate
            };

            try
            {
                await _sender.SendMessageAsync(message);
            }
            catch (ServiceBusException ex) when (ex.Reason == ServiceBusFailureReason.MessageSizeExceeded)
            {
                // Handle duplicate - already sent
                _logger.LogInformation($"Duplicate message detected: {order.Id}");
            }
        }
        ```
        **Step 3: Bicep Configuration**
        ```bicep
        resource ordersQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
            parent: namespace
            name: 'orders'
            properties: {
                requiresDuplicateDetection: true
                duplicateDetectionHistoryTimeWindow: 'PT10M'
            }
        }
        ```
        **References:**
        - [Duplicate Detection](https://learn.microsoft.com/en-us/azure/service-bus-messaging/duplicate-detection)

### 6.3 Azure Event Hubs
1. How do you implement event streaming?
    - **Answer:**
        Use Event Hubs SDK to send events and EventProcessorClient to consume events with checkpointing.
    - **Implementation:**
        **Step 1: Send Events (C#)**
        ```csharp
        await using var producer = new EventHubProducerClient(connectionString, "myhub");
        using var batch = await producer.CreateBatchAsync();
        batch.TryAdd(new EventData(Encoding.UTF8.GetBytes("Event 1")));
        batch.TryAdd(new EventData(Encoding.UTF8.GetBytes("Event 2")));
        await producer.SendAsync(batch);
        ```
        **Step 2: Consume with EventProcessorClient**
        ```csharp
        var processor = new EventProcessorClient(blobContainerClient, "$Default", connectionString, "myhub");
        processor.ProcessEventAsync += async args =>
        {
            Console.WriteLine($"Event: {Encoding.UTF8.GetString(args.Data.Body.ToArray())}");
            await args.UpdateCheckpointAsync();
        };
        processor.ProcessErrorAsync += args => { Console.WriteLine(args.Exception); return Task.CompletedTask; };
        await processor.StartProcessingAsync();
        ```
        **References:**
        - [Event Hubs SDK](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-dotnet-standard-getstarted-send)

2. How do you secure Event Hubs?
    - **Answer:**
        Use SAS tokens for temporary access, Azure AD for identity-based access, and firewall rules.
    - **Implementation:**
        **Step 1: Azure AD Authentication (C#)**
        ```csharp
        var producer = new EventHubProducerClient("mynamespace.servicebus.windows.net", "myhub", new DefaultAzureCredential());
        ```
        **Step 2: Generate SAS Token**
        ```csharp
        var sasBuilder = new SharedAccessSignatureBuilder
        {
            KeyName = "RootManageSharedAccessKey",
            Key = "<key>",
            Target = $"https://mynamespace.servicebus.windows.net/myhub",
            Ttl = TimeSpan.FromHours(1)
        };
        ```
        **Step 3: Configure Firewall**
        ```sh
        az eventhubs namespace network-rule add --resource-group myrg --namespace-name mynamespace --ip-address 203.0.113.0/24
        ```
        **References:**
        - [Event Hubs Security](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-authentication-and-security-model-overview)

3. How do you monitor event throughput?
    - **Answer:**
        Use Azure Monitor metrics for incoming/outgoing messages, throughput units, and set up alerts.
    - **Implementation:**
        **Step 1: View Metrics**
        - Event Hubs Namespace > Monitoring > Metrics > Incoming Messages, Outgoing Messages
        **Step 2: Query Metrics (Kusto)**
        ```kusto
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.EVENTHUB"
        | where MetricName in ("IncomingMessages", "OutgoingMessages")
        | summarize sum(Total) by MetricName, bin(TimeGenerated, 1h)
        ```
        **Step 3: Create Throughput Alert**
        - Azure Monitor > Alerts > Condition: Throttled Requests > 0
        **References:**
        - [Monitor Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/monitor-event-hubs)

4. How do you handle partitioning?
    - **Answer:**
        Set partition key on events for ordering, design consumers to process all partitions in parallel.
    - **Implementation:**
        **Step 1: Send with Partition Key**
        ```csharp
        var options = new SendEventOptions { PartitionKey = "customer-123" };
        await producer.SendAsync(new[] { new EventData("event") }, options);
        ```
        **Step 2: Send to Specific Partition**
        ```csharp
        var options = new SendEventOptions { PartitionId = "0" };
        await producer.SendAsync(batch, options);
        ```
        **Step 3: Process All Partitions**
        ```csharp
        // EventProcessorClient automatically balances partitions across instances
        var processor = new EventProcessorClient(blobClient, "$Default", connectionString, "myhub");
        ```
        **References:**
        - [Event Hubs Partitions](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features#partitions)

5. How do you handle event retention?
    - **Answer:**
        Configure retention period (1-90 days for Standard, up to 90 days for Premium), use Capture for long-term storage.
    - **Implementation:**
        **Step 1: Set Retention Period**
        ```sh
        az eventhubs eventhub update --resource-group myrg --namespace-name mynamespace --name myhub --message-retention 7
        ```
        **Step 2: Enable Capture**
        ```sh
        az eventhubs eventhub update --resource-group myrg --namespace-name mynamespace --name myhub --enable-capture true --capture-destination blob --storage-account mystorageaccount --blob-container captures
        ```
        **References:**
        - [Event Hubs Capture](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-overview)

6. How do you automate Event Hub creation?
    - **Answer:**
        Use ARM/Bicep templates, Azure CLI, or SDK for infrastructure as code.
    - **Implementation:**
        **Step 1: CLI**
        ```sh
        az eventhubs eventhub create --resource-group myrg --namespace-name mynamespace --name myhub --partition-count 4
        ```
        **Step 2: Bicep Template**
        ```bicep
        resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
            parent: namespace
            name: 'myhub'
            properties: {
                partitionCount: 4
                messageRetentionInDays: 7
            }
        }
        ```
        **References:**
        - [Event Hubs ARM Templates](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventhub/namespaces/eventhubs)

7. How do you handle consumer group management?
    - **Answer:**
        Create separate consumer groups for different processing applications, each maintains its own checkpoint.
    - **Implementation:**
        **Step 1: Create Consumer Group**
        ```sh
        az eventhubs eventhub consumer-group create --resource-group myrg --namespace-name mynamespace --eventhub-name myhub --name myprocessor
        ```
        **Step 2: Use in Processor**
        ```csharp
        var processor = new EventProcessorClient(blobClient, "myprocessor", connectionString, "myhub");
        ```
        **Step 3: Different Apps Use Different Groups**
        - App A uses consumer group "analytics"
        - App B uses consumer group "archiver"
        **References:**
        - [Consumer Groups](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features#consumer-groups)

8. How do you handle large event payloads?
    - **Answer:**
        Store payload in Blob Storage, send blob reference in event (claim check pattern), max event size is 1MB.
    - **Implementation:**
        **Step 1: Upload Large Payload**
        ```csharp
        var blobClient = containerClient.GetBlobClient($"events/{Guid.NewGuid()}.json");
        await blobClient.UploadAsync(BinaryData.FromString(largePayload));
        ```
        **Step 2: Send Reference**
        ```csharp
        var eventData = new EventData(JsonSerializer.SerializeToUtf8Bytes(new { BlobUri = blobClient.Uri }));
        await producer.SendAsync(new[] { eventData });
        ```
        **Step 3: Consumer Downloads Blob**
        ```csharp
        var reference = JsonSerializer.Deserialize<BlobReference>(args.Data.Body.ToArray());
        var content = await new BlobClient(new Uri(reference.BlobUri), credential).DownloadContentAsync();
        ```
        **References:**
        - [Claim Check Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/claim-check)

9. How do you integrate with Stream Analytics?
    - **Answer:**
        Configure Event Hub as input source for Stream Analytics jobs to process streaming data in real-time.
    - **Implementation:**
        **Step 1: Create Stream Analytics Job**
        ```sh
        az stream-analytics job create --resource-group myrg --name myjob --location eastus
        ```
        **Step 2: Add Event Hub Input**
        - Stream Analytics > Inputs > Add > Event Hub > Configure connection
        **Step 3: Write Query**
        ```sql
        SELECT System.Timestamp AS Time, COUNT(*) AS EventCount
        INTO [output]
        FROM [eventhub-input]
        GROUP BY TumblingWindow(minute, 5)
        ```
        **References:**
        - [Stream Analytics with Event Hubs](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-add-inputs)

10. How do you automate scaling?
    - **Answer:**
        Use Auto-Inflate feature for automatic throughput unit scaling, or manually adjust via CLI.
    - **Implementation:**
        **Step 1: Enable Auto-Inflate**
        ```sh
        az eventhubs namespace update --resource-group myrg --name mynamespace --enable-auto-inflate true --maximum-throughput-units 20
        ```
        **Step 2: Manual Scaling**
        ```sh
        az eventhubs namespace update --resource-group myrg --name mynamespace --capacity 10
        ```
        **Step 3: Monitor Scaling**
        - Event Hubs > Metrics > Throughput Units, Throttled Requests
        **References:**
        - [Auto-Inflate](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-auto-inflate)

11. How do you handle event ordering?
    - **Answer:**
        Use partition keys to ensure related events go to same partition, events within a partition are ordered.
    - **Implementation:**
        **Step 1: Use Partition Key**
        ```csharp
        // All events with same partition key go to same partition
        var options = new SendEventOptions { PartitionKey = "order-123" };
        await producer.SendAsync(events, options);
        ```
        **Step 2: Process in Order**
        ```csharp
        // Events from a partition arrive in order
        processor.ProcessEventAsync += async args =>
        {
            var partitionId = args.Partition.PartitionId;
            // Process sequentially within partition
        };
        ```
        **References:**
        - [Event Ordering](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features#partitions)

12. How do you monitor for dropped events?
    - **Answer:**
        Monitor Throttled Requests metric, review checkpoints, and set up alerts for processing lag.
    - **Implementation:**
        **Step 1: Query Throttled Events (Kusto)**
        ```kusto
        AzureMetrics
        | where ResourceProvider == "MICROSOFT.EVENTHUB"
        | where MetricName == "ThrottledRequests"
        | where Total > 0
        | project TimeGenerated, Total
        ```
        **Step 2: Monitor Checkpoint Lag**
        - Compare sequence numbers: latest in hub vs. checkpoint
        **Step 3: Create Alert**
        - Azure Monitor > Alerts > Condition: Throttled Requests > 0
        **References:**
        - [Monitor Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/monitor-event-hubs)

13. How do you optimize for cost?
    - **Answer:**
        Use appropriate tier and throughput units, enable Auto-Inflate with cap, and clean up unused hubs.
    - **Implementation:**
        **Step 1: Right-Size Throughput Units**
        - 1 TU = 1 MB/s ingress, 2 MB/s egress
        - Monitor actual usage and adjust
        **Step 2: Use Auto-Inflate with Cap**
        ```sh
        az eventhubs namespace update --resource-group myrg --name mynamespace --enable-auto-inflate true --maximum-throughput-units 10
        ```
        **Step 3: Monitor Costs**
        - Cost Management > Cost analysis > Filter by Event Hubs
        **References:**
        - [Event Hubs Pricing](https://azure.microsoft.com/en-us/pricing/details/event-hubs/)

14. How do you audit access?
    - **Answer:**
        Enable diagnostic logs, send to Log Analytics, and review access patterns.
    - **Implementation:**
        **Step 1: Enable Diagnostics**
        ```sh
        az monitor diagnostic-settings create --resource /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.EventHub/namespaces/mynamespace --name mydiag --logs '[{"category":"OperationalLogs","enabled":true}]' --workspace <workspace-id>
        ```
        **Step 2: Query Logs (Kusto)**
        ```kusto
        AzureDiagnostics
        | where ResourceProvider == "MICROSOFT.EVENTHUB"
        | project TimeGenerated, OperationName, CallerIpAddress, Status
        ```
        **References:**
        - [Event Hubs Logging](https://learn.microsoft.com/en-us/azure/event-hubs/monitor-event-hubs)

15. How do you test Event Hub integration?
    - **Answer:**
        Use Event Hub Capture for replay, integration tests with real hubs, or Azure Event Hubs emulator.
    - **Implementation:**
        **Step 1: Enable Capture for Replay**
        ```sh
        az eventhubs eventhub update --resource-group myrg --namespace-name mynamespace --name myhub --enable-capture true --storage-account mystorageaccount --blob-container captures
        ```
        **Step 2: Integration Test (C#)**
        ```csharp
        [Fact]
        public async Task CanSendAndReceiveEvents()
        {
            await producer.SendAsync(new[] { new EventData("test") });
            // Use EventProcessorClient to verify receipt
        }
        ```
        **Step 3: Use Kafka Protocol for Local Testing**
        - Event Hubs supports Kafka protocol
        - Use local Kafka for development
        **References:**
        - [Event Hubs Testing](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-dotnet-standard-getstarted-send)

16. How do you implement event processing with Azure Stream Analytics?
    - **Answer:**
        Stream Analytics provides real-time analytics on Event Hubs streams with SQL-like queries for filtering, aggregation, and windowing.
    - **Implementation:**
        **Step 1: Create Stream Analytics Job**
        ```sh
        az stream-analytics job create \
            --resource-group myrg \
            --name myasajob \
            --location eastus \
            --sku Standard
        ```
        **Step 2: Configure Event Hub Input**
        ```sh
        az stream-analytics input create \
            --resource-group myrg \
            --job-name myasajob \
            --name eventhubinput \
            --type Stream \
            --datasource '{
                "type": "Microsoft.ServiceBus/EventHub",
                "properties": {
                    "serviceBusNamespace": "mynamespace",
                    "eventHubName": "events",
                    "sharedAccessPolicyName": "RootManageSharedAccessKey"
                }
            }' \
            --serialization '{"type": "Json", "encoding": "UTF8"}'
        ```
        **Step 3: Write Stream Analytics Query**
        ```sql
        -- Real-time aggregation
        SELECT
            System.Timestamp() AS WindowEnd,
            deviceId,
            COUNT(*) AS EventCount,
            AVG(temperature) AS AvgTemperature,
            MAX(temperature) AS MaxTemperature
        FROM eventhubinput TIMESTAMP BY eventTime
        GROUP BY deviceId, TumblingWindow(minute, 5)

        -- Anomaly detection
        SELECT
            deviceId,
            temperature,
            AnomalyDetection_SpikeAndDip(temperature, 95, 120, 'spikesanddips') OVER(PARTITION BY deviceId LIMIT DURATION(minute, 10)) AS SpikeAndDipScores
        FROM eventhubinput

        -- Pattern matching
        SELECT *
        FROM eventhubinput MATCH_RECOGNIZE (
            PARTITION BY deviceId
            MEASURES
                First(A.temperature) AS StartTemp,
                Last(B.temperature) AS EndTemp
            PATTERN (A B+ C)
            DEFINE
                A AS A.status = 'normal',
                B AS B.temperature > A.temperature * 1.1,
                C AS C.status = 'alert'
        )
        ```
        **References:**
        - [Stream Analytics with Event Hubs](https://learn.microsoft.com/en-us/azure/stream-analytics/stream-analytics-introduction)

17. How do you implement Event Hubs Schema Registry?
    - **Answer:**
        Schema Registry provides centralized schema management for Avro/JSON schemas. Ensures producer/consumer compatibility and schema evolution.
    - **Implementation:**
        **Step 1: Create Schema Group**
        ```sh
        az eventhubs namespace schema-registry schema-group create \
            --resource-group myrg \
            --namespace-name mynamespace \
            --name myschemagroup \
            --schema-compatibility Forward \
            --schema-type Avro
        ```
        **Step 2: Register Schema**
        ```csharp
        var schemaRegistryClient = new SchemaRegistryClient(
            "<namespace>.servicebus.windows.net",
            new DefaultAzureCredential());

        var schema = @"{
            ""type"": ""record"",
            ""name"": ""Order"",
            ""namespace"": ""com.mycompany"",
            ""fields"": [
                { ""name"": ""id"", ""type"": ""string"" },
                { ""name"": ""amount"", ""type"": ""double"" },
                { ""name"": ""timestamp"", ""type"": ""long"" }
            ]
        }";

        var result = await schemaRegistryClient.RegisterSchemaAsync(
            "myschemagroup", "Order", schema, SchemaFormat.Avro);
        ```
        **Step 3: Produce with Schema Validation**
        ```csharp
        var encoder = new SchemaRegistryAvroEncoder(schemaRegistryClient, "myschemagroup");

        var order = new Order { Id = "123", Amount = 99.99, Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds() };
        var eventData = await encoder.EncodeAsync(order);
        await producer.SendAsync(new[] { eventData });
        ```
        **References:**
        - [Schema Registry](https://learn.microsoft.com/en-us/azure/event-hubs/schema-registry-overview)

18. How do you implement Kafka compatibility with Event Hubs?
    - **Answer:**
        Event Hubs exposes Kafka-compatible endpoints. Use existing Kafka clients without code changes by configuring connection strings.
    - **Implementation:**
        **Step 1: Configure Kafka Client**
        ```csharp
        var config = new ProducerConfig
        {
            BootstrapServers = "<namespace>.servicebus.windows.net:9093",
            SecurityProtocol = SecurityProtocol.SaslSsl,
            SaslMechanism = SaslMechanism.Plain,
            SaslUsername = "$ConnectionString",
            SaslPassword = "<eventhubs-connection-string>"
        };

        using var producer = new ProducerBuilder<string, string>(config).Build();
        await producer.ProduceAsync("orders", new Message<string, string>
        {
            Key = orderId,
            Value = JsonSerializer.Serialize(order)
        });
        ```
        **Step 2: Kafka Consumer Configuration**
        ```csharp
        var config = new ConsumerConfig
        {
            BootstrapServers = "<namespace>.servicebus.windows.net:9093",
            GroupId = "order-processors",
            SecurityProtocol = SecurityProtocol.SaslSsl,
            SaslMechanism = SaslMechanism.Plain,
            SaslUsername = "$ConnectionString",
            SaslPassword = "<eventhubs-connection-string>",
            AutoOffsetReset = AutoOffsetReset.Earliest
        };

        using var consumer = new ConsumerBuilder<string, string>(config).Build();
        consumer.Subscribe("orders");
        ```
        **References:**
        - [Event Hubs for Kafka](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-for-kafka-ecosystem-overview)

19. How do you implement event archiving with Event Hubs Capture?
    - **Answer:**
        Capture automatically archives events to Blob Storage or Data Lake in Avro format for long-term storage and batch processing.
    - **Implementation:**
        **Step 1: Enable Capture**
        ```sh
        az eventhubs eventhub update \
            --resource-group myrg \
            --namespace-name mynamespace \
            --name events \
            --enable-capture true \
            --capture-interval 300 \
            --capture-size-limit 314572800 \
            --destination-name EventHubArchive.AzureBlockBlob \
            --storage-account /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.Storage/storageAccounts/mystorageaccount \
            --blob-container captures \
            --archive-name-format "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
        ```
        **Step 2: Process Captured Events with Spark**
        ```python
        from pyspark.sql import SparkSession
        from pyspark.sql.functions import col

        spark = SparkSession.builder.appName("EventHubsCapture").getOrCreate()

        df = spark.read.format("avro").load(
            "wasbs://captures@mystorageaccount.blob.core.windows.net/mynamespace/events/*/*/*/*/*/*"
        )

        # Process captured events
        events = df.select(
            col("Body").cast("string").alias("event_data"),
            col("EnqueuedTimeUtc"),
            col("PartitionKey")
        )
        ```
        **Step 3: Bicep Configuration**
        ```bicep
        resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
            parent: namespace
            name: 'events'
            properties: {
                partitionCount: 8
                captureDescription: {
                    enabled: true
                    encoding: 'Avro'
                    intervalInSeconds: 300
                    sizeLimitInBytes: 314572800
                    destination: {
                        name: 'EventHubArchive.AzureBlockBlob'
                        properties: {
                            storageAccountResourceId: storageAccount.id
                            blobContainer: 'captures'
                            archiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
                        }
                    }
                }
            }
        }
        ```
        **References:**
        - [Event Hubs Capture](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-overview)

20. How do you implement geo-disaster recovery for Event Hubs?
    - **Answer:**
        Use Geo-DR pairing for automatic failover between primary and secondary namespaces in different regions.
    - **Implementation:**
        **Step 1: Create Paired Namespaces**
        ```sh
        # Create primary namespace
        az eventhubs namespace create \
            --resource-group myrg \
            --name primary-ns \
            --location eastus \
            --sku Premium

        # Create secondary namespace
        az eventhubs namespace create \
            --resource-group myrg \
            --name secondary-ns \
            --location westus \
            --sku Premium

        # Create Geo-DR pairing
        az eventhubs georecovery-alias create \
            --resource-group myrg \
            --namespace-name primary-ns \
            --alias-name mydr \
            --partner-namespace /subscriptions/<sub-id>/resourceGroups/myrg/providers/Microsoft.EventHub/namespaces/secondary-ns
        ```
        **Step 2: Use Alias for Connections**
        ```csharp
        // Use alias endpoint - works with both primary and secondary
        var connectionString = "Endpoint=sb://mydr.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=...";

        var producer = new EventHubProducerClient(connectionString, "events");
        ```
        **Step 3: Initiate Failover**
        ```sh
        # Manual failover (when primary is unavailable)
        az eventhubs georecovery-alias fail-over \
            --resource-group myrg \
            --namespace-name secondary-ns \
            --alias-name mydr
        ```
        **Step 4: Monitor DR Status**
        ```sh
        az eventhubs georecovery-alias show \
            --resource-group myrg \
            --namespace-name primary-ns \
            --alias-name mydr \
            --query "provisioningState"
        ```
        **References:**
        - [Event Hubs Geo-DR](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-geo-dr)


## 7. API Management (APIM)


### 7.1 Azure API Management
1. How do you secure APIs?
     - **Answer:**
         Use subscription keys, OAuth 2.0, JWT validation, and IP filtering policies in APIM.
     - **Implementation:**
         **Step 1: Require Subscription Key**
         - In APIM > APIs > Settings > Subscription required: Yes
         **Step 2: Add OAuth 2.0/JWT Validation Policy**
         - In API > Design > All operations > Inbound processing > Add policy:
         ```xml
         <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized">
             <openid-config url="https://login.microsoftonline.com/<tenant-id>/v2.0/.well-known/openid-configuration" />
             <required-claims>
                 <claim name="aud" match="any">
                     <value>api://<client-id></value>
                 </claim>
             </required-claims>
         </validate-jwt>
         ```
         **Step 3: Add IP Filter Policy**
         ```xml
         <check-header name="X-Forwarded-For" failed-check-httpcode="403" failed-check-error-message="Forbidden">
             <value>203.0.113.0</value>
         </check-header>
         ```
         **References:**
         - [APIM security policies](https://learn.microsoft.com/en-us/azure/api-management/api-management-access-restriction-policies)

2. How do you monitor API usage?
     - **Answer:**
         Use APIM analytics, Application Insights, and custom logging.
     - **Implementation:**
         **Step 1: Enable Application Insights**
         - APIM > APIs > Settings > Enable Application Insights
         **Step 2: View Analytics**
         - APIM > Analytics > View usage, performance, and errors
         **Step 3: Add Custom Logging Policy**
         ```xml
         <log-to-eventhub logger-id="apim-logger">@("Request: " + context.Request.Url)</log-to-eventhub>
         ```
         **References:**
         - [Monitor APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-use-azure-monitor)

3. How do you implement rate limiting?
     - **Answer:**
         Use rate-limit-by-key and quota-by-key policies in APIM.
     - **Implementation:**
         **Step 1: Add Rate Limit Policy**
         ```xml
         <rate-limit-by-key calls="10" renewal-period="60" counter-key="@(context.Subscription.Id)" />
         ```
         **Step 2: Add Quota Policy**
         ```xml
         <quota-by-key calls="1000" renewal-period="604800" counter-key="@(context.Subscription.Id)" />
         ```
         **References:**
         - [Rate limiting in APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-access-restriction-policies#RateLimitByKey)

4. How do you handle API versioning?
     - **Answer:**
         Use path, header, or query-based versioning, and manage revisions in APIM.
     - **Implementation:**
         **Step 1: Add Version to API**
         - APIM > APIs > Add version > Choose versioning scheme (path, header, query)
         **Step 2: Example Path Versioning**
         - /v1/orders, /v2/orders
         **References:**
         - [API versioning in APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-get-started-publish-versions-revisions)

5. How do you automate API deployment?
     - **Answer:**
         Use ARM/Bicep templates, CI/CD pipelines, and APIM DevOps toolkit.
     - **Implementation:**
         **Step 1: Export API as ARM Template**
         - APIM > APIs > Automation > Export template
         **Step 2: Deploy with Azure CLI**
         ```sh
         az deployment group create --resource-group myrg --template-file apim-template.json
         ```
         **Step 3: Use APIM DevOps Toolkit**
         - [APIM DevOps Resource Kit](https://github.com/Azure/azure-api-management-devops-resource-kit)

6. How do you transform requests/responses?
     - **Answer:**
         Use policies for transformation (set-body, set-header, etc.).
     - **Implementation:**
         **Step 1: Add Transformation Policy**
         ```xml
         <set-header name="X-MyHeader" exists-action="override">
             <value>my-value</value>
         </set-header>
         <set-body>@("{ 'message': 'Hello, world!' }")</set-body>
         ```
         **References:**
         - [Transform policies](https://learn.microsoft.com/en-us/azure/api-management/api-management-transformation-policies)

7. How do you secure backend services?
     - **Answer:**
         Use client certificates, IP restrictions, and VNet integration.
     - **Implementation:**
         **Step 1: Add Client Certificate to Backend**
         - APIM > APIs > Settings > Client certificates
         **Step 2: Restrict Backend by IP**
         - Backend service firewall > Allow only APIM IPs
         **Step 3: Use VNet Integration**
         - APIM > Virtual network > Enable VNet integration
         **References:**
         - [Secure backends](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-mutual-certificates)

8. How do you handle CORS?
     - **Answer:**
         Use CORS policy in APIM.
     - **Implementation:**
         **Step 1: Add CORS Policy**
         ```xml
         <cors>
             <allowed-origins>
                 <origin>https://myapp.com</origin>
             </allowed-origins>
             <allowed-methods>
                 <method>GET</method>
                 <method>POST</method>
             </allowed-methods>
             <allowed-headers>
                 <header>*</header>
             </allowed-headers>
         </cors>
         ```
         **References:**
         - [CORS in APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-cors)

9. How do you monitor for errors?
     - **Answer:**
         Set up alerts, review logs, and use Application Insights.
     - **Implementation:**
         **Step 1: Enable Application Insights (see question 2)**
         **Step 2: Set Up Alerts**
         - Application Insights > Alerts > New alert rule > Condition: Failed requests
         **References:**
         - [Monitor APIM errors](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-use-azure-monitor)

10. How do you implement caching?
     - **Answer:**
         Use cache-lookup and cache-store policies for response caching.
     - **Implementation:**
         **Step 1: Add Caching Policy**
         ```xml
         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" />
         <cache-store duration="300" />
         ```
         **References:**
         - [Caching in APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-caching-policies)

11. How do you handle developer onboarding?
     - **Answer:**
         Use the developer portal, publish documentation, and manage subscriptions.
     - **Implementation:**
         **Step 1: Customize Developer Portal**
         - APIM > Developer portal > Customize
         **Step 2: Publish API Documentation**
         - Add OpenAPI/Swagger definition
         **Step 3: Manage Subscriptions**
         - APIM > Products > Add product > Require subscription
         **References:**
         - [Developer portal](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-developer-portal)

12. How do you automate policy management?
     - **Answer:**
         Use templates, scripts, and APIM DevOps toolkit.
     - **Implementation:**
         **Step 1: Export/Import Policy XML**
         - APIM > APIs > Design > Inbound processing > Export policy
         - Use ARM template or APIM DevOps Toolkit for automation
         **References:**
         - [Automate APIM policies](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-policies)

13. How do you integrate with Logic Apps/Functions?
     - **Answer:**
         Add as backend, secure with keys or Managed Identity.
     - **Implementation:**
         **Step 1: Add Logic App/Function as Backend**
         - APIM > APIs > Settings > Web service URL: https://<function-app>.azurewebsites.net/api/<function>
         **Step 2: Secure with Function Key or Managed Identity**
         - Use Ocp-Apim-Subscription-Key header or configure Managed Identity
         **References:**
         - [APIM with Azure Functions](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad)

14. How do you handle API deprecation?
     - **Answer:**
         Mark versions as deprecated, notify consumers, and set retirement dates.
     - **Implementation:**
         **Step 1: Mark API Version as Deprecated**
         - APIM > APIs > Versions > Mark as deprecated
         **Step 2: Notify Consumers**
         - Use email notifications or developer portal announcements
         **Step 3: Set Retirement Date**
         - Document in API metadata and developer portal
         **References:**
         - [API versioning and deprecation](https://learn.microsoft.com/en-us/azure/api-management/api-management-get-started-publish-versions-revisions)

15. How do you test APIs in APIM?
     - **Answer:**
         Use the test console, Postman, or integration tests.
     - **Implementation:**
         **Step 1: Use APIM Test Console**
         - APIM > APIs > Test > Send request
         **Step 2: Use Postman**
         - Import OpenAPI definition, set subscription key in header
         **Step 3: Write Integration Tests (C#)**
         ```csharp
         var client = new HttpClient();
         client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", "<key>");
         var response = await client.GetAsync("https://<apim-name>.azure-api.net/api/endpoint");
         ```
         **References:**
         - [Test APIs in APIM](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-test)

16. How do you implement request/response transformation?
    - **Answer:**
        Use set-body, set-header, and rewrite-uri policies to transform requests before backend calls and responses before returning to clients.
    - **Implementation:**
        **Step 1: Transform Request Body**
        ```xml
        <inbound>
            <set-body>@{
                var body = context.Request.Body.As<JObject>();
                return new JObject(
                    new JProperty("orderId", body["id"]),
                    new JProperty("customer", new JObject(
                        new JProperty("name", body["customerName"]),
                        new JProperty("email", body["customerEmail"])
                    )),
                    new JProperty("timestamp", DateTime.UtcNow)
                ).ToString();
            }</set-body>
            <set-header name="X-Request-Id" exists-action="override">
                <value>@(Guid.NewGuid().ToString())</value>
            </set-header>
            <rewrite-uri template="/api/v2/orders" />
        </inbound>
        ```
        **Step 2: Transform Response**
        ```xml
        <outbound>
            <choose>
                <when condition="@(context.Response.StatusCode == 200)">
                    <set-body>@{
                        var response = context.Response.Body.As<JObject>();
                        return new JObject(
                            new JProperty("data", response),
                            new JProperty("meta", new JObject(
                                new JProperty("requestId", context.Variables["requestId"]),
                                new JProperty("timestamp", DateTime.UtcNow)
                            ))
                        ).ToString();
                    }</set-body>
                </when>
            </choose>
            <set-header name="X-Response-Time" exists-action="override">
                <value>@((DateTime.UtcNow - (DateTime)context.Variables["startTime"]).TotalMilliseconds.ToString())</value>
            </set-header>
        </outbound>
        ```
        **References:**
        - [Transformation Policies](https://learn.microsoft.com/en-us/azure/api-management/api-management-transformation-policies)

17. How do you implement backend load balancing and failover?
    - **Answer:**
        Use backend pools with multiple endpoints, configure health probes, and implement circuit breaker patterns for resilient API routing.
    - **Implementation:**
        **Step 1: Define Backend Pool**
        ```xml
        <backends>
            <backend id="primary-backend">
                <url>https://primary-api.azurewebsites.net</url>
            </backend>
            <backend id="secondary-backend">
                <url>https://secondary-api.azurewebsites.net</url>
            </backend>
        </backends>
        ```
        **Step 2: Implement Load Balancing Policy**
        ```xml
        <inbound>
            <set-variable name="backendUrl" value="@{
                var backends = new[] {
                    "https://backend1.azurewebsites.net",
                    "https://backend2.azurewebsites.net",
                    "https://backend3.azurewebsites.net"
                };
                var random = new Random();
                return backends[random.Next(backends.Length)];
            }" />
            <set-backend-service base-url="@((string)context.Variables["backendUrl"])" />
        </inbound>
        ```
        **Step 3: Circuit Breaker with Retry**
        ```xml
        <backend>
            <retry condition="@(context.Response.StatusCode >= 500)" count="3" interval="1" max-interval="10" delta="1">
                <forward-request buffer-request-body="true" />
            </retry>
            <circuit-breaker threshold-percentage="50" trip-duration="60">
                <forward-request />
            </circuit-breaker>
        </backend>
        ```
        **References:**
        - [Backend Services](https://learn.microsoft.com/en-us/azure/api-management/backends)

18. How do you implement API mocking for development?
    - **Answer:**
        Use mock-response policy to return predefined responses without calling backend. Useful for API-first development and testing.
    - **Implementation:**
        **Step 1: Configure Mock Response**
        ```xml
        <inbound>
            <mock-response status-code="200" content-type="application/json">
                <example>{
                    "id": "12345",
                    "name": "Sample Product",
                    "price": 29.99,
                    "inStock": true
                }</example>
            </mock-response>
        </inbound>
        ```
        **Step 2: Dynamic Mock Based on Request**
        ```xml
        <inbound>
            <choose>
                <when condition="@(context.Request.Headers.GetValueOrDefault("X-Mock-Response", "false") == "true")">
                    <mock-response status-code="200" content-type="application/json">
                        <example>{"mocked": true, "requestId": "@(context.RequestId)"}</example>
                    </mock-response>
                </when>
                <otherwise>
                    <!-- Forward to backend -->
                </otherwise>
            </choose>
        </inbound>
        ```
        **Step 3: Use Examples from OpenAPI Spec**
        ```xml
        <inbound>
            <!-- Automatically use examples defined in OpenAPI specification -->
            <mock-response status-code="200" />
        </inbound>
        ```
        **References:**
        - [API Mocking](https://learn.microsoft.com/en-us/azure/api-management/mock-api-responses)

19. How do you implement self-hosted gateway for hybrid scenarios?
    - **Answer:**
        Deploy APIM gateway as container in Kubernetes or on-premises for low-latency access to local backends while maintaining central management.
    - **Implementation:**
        **Step 1: Provision Self-Hosted Gateway**
        ```sh
        az apim gateway create \
            --resource-group myrg \
            --service-name myapim \
            --gateway-id on-premises-gateway \
            --description "On-premises gateway"
        ```
        **Step 2: Deploy to Kubernetes**
        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
            name: apim-gateway
        spec:
            replicas: 2
            selector:
                matchLabels:
                    app: apim-gateway
            template:
                metadata:
                    labels:
                        app: apim-gateway
                spec:
                    containers:
                        - name: gateway
                          image: mcr.microsoft.com/azure-api-management/gateway:2.3.0
                          ports:
                              - containerPort: 8080
                              - containerPort: 8081
                          env:
                              - name: config.service.endpoint
                                value: "https://myapim.configuration.azure-api.net?token=<gateway-token>"
                          resources:
                              requests:
                                  cpu: 500m
                                  memory: 512Mi
        ---
        apiVersion: v1
        kind: Service
        metadata:
            name: apim-gateway
        spec:
            type: LoadBalancer
            ports:
                - port: 80
                  targetPort: 8080
            selector:
                app: apim-gateway
        ```
        **Step 3: Configure API to Use Gateway**
        ```sh
        az apim api update \
            --resource-group myrg \
            --service-name myapim \
            --api-id my-api \
            --gateway-id on-premises-gateway
        ```
        **References:**
        - [Self-Hosted Gateway](https://learn.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview)

20. How do you implement synthetic GraphQL with APIM?
    - **Answer:**
        APIM can expose multiple REST APIs as a single GraphQL endpoint by defining GraphQL schema and using resolvers that call backend REST APIs.
    - **Implementation:**
        **Step 1: Import GraphQL Schema**
        ```graphql
        type Query {
            order(id: ID!): Order
            orders(customerId: String!): [Order]
            customer(id: ID!): Customer
        }

        type Order {
            id: ID!
            customerId: String!
            total: Float!
            items: [OrderItem]
            customer: Customer
        }

        type Customer {
            id: ID!
            name: String!
            email: String!
        }

        type OrderItem {
            productId: String!
            quantity: Int!
            price: Float!
        }
        ```
        **Step 2: Configure Resolvers**
        ```xml
        <resolver field="order" type="Query">
            <http-data-source>
                <http-request>
                    <set-method>GET</set-method>
                    <set-url>@($"https://orders-api.azurewebsites.net/api/orders/{context.GraphQL.Arguments["id"]}")</set-url>
                </http-request>
            </http-data-source>
        </resolver>

        <resolver field="customer" type="Order">
            <http-data-source>
                <http-request>
                    <set-method>GET</set-method>
                    <set-url>@($"https://customers-api.azurewebsites.net/api/customers/{context.GraphQL.Parent["customerId"]}")</set-url>
                </http-request>
            </http-data-source>
        </resolver>
        ```
        **Step 3: Create GraphQL API**
        ```sh
        az apim graphql-api create \
            --resource-group myrg \
            --service-name myapim \
            --api-id orders-graphql \
            --display-name "Orders GraphQL" \
            --path /graphql \
            --schema-description @schema.graphql
        ```
        **References:**
        - [Synthetic GraphQL](https://learn.microsoft.com/en-us/azure/api-management/graphql-apis-overview)


## 8. Real-World Scenarios & Best Practices

1. How do you migrate an on-premises SQL database to Azure with minimal downtime?
    - **Answer:** Use Azure Database Migration Service (DMS) with online migration, pre-migrate schema/data, cut over with minimal downtime.
2. How do you automate deployment of Azure resources and code?
    - **Answer:** Use ARM/Bicep/Terraform for infrastructure, Azure DevOps/GitHub Actions for CI/CD, automate tests and approvals.
3. How do you implement blue/green or canary deployments?
    - **Answer:** Use deployment slots, traffic routing, and staged rollouts.
4. How do you handle secrets in CI/CD pipelines?
    - **Answer:** Store in Key Vault, use pipeline secrets, never hardcode.
5. How do you monitor for cost overruns?
    - **Answer:** Use Cost Management, set budgets/alerts, review usage regularly.
6. How do you implement disaster recovery?
    - **Answer:** Use geo-redundancy, backup/restore, and failover strategies.
7. How do you enforce compliance?
    - **Answer:** Use Azure Policy, Blueprints, and regular audits.
8. How do you handle multi-region deployments?
    - **Answer:** Use Traffic Manager, geo-redundant storage, and region pairs.
9. How do you optimize for performance?
    - **Answer:** Use caching, autoscale, monitor bottlenecks, and optimize code.
10. How do you handle hybrid cloud scenarios?
    - **Answer:** Use VPN/ExpressRoute, Azure Arc, and hybrid connectors.
11. How do you automate resource cleanup?
    - **Answer:** Use automation scripts, policies, and scheduled jobs.
12. How do you monitor for security threats?
    - **Answer:** Use Security Center, threat detection, and alerts.
13. How do you handle regulatory requirements (GDPR, HIPAA)?
    - **Answer:** Use data classification, encryption, and compliance tools.
14. How do you manage large-scale deployments?
    - **Answer:** Use templates, automation, and modular infrastructure.
15. How do you test disaster recovery plans?
    - **Answer:** Schedule regular DR drills, document procedures, and review outcomes.

*This set covers all major AZ-204 topics with practical, scenario-based questions and detailed answers. For more depth, expand each section with additional scenarios and code samples as needed.*
