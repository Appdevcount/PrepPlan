1.Copy the contents of web.config and create a new configuration file named web.DEVBSN.config that includes only valid hardcoded URLs, IP addresses, and connection strings (ignore SMTP and email addresses).
a.Apply file transform logic using the xdt namespace for configuration transforms.
b.Set the Environment key to DEV with the appropriate transform attributes.
c.For connection strings, use xdt:Locator="Match(key)" xdt:Transform="SetAttributes" in <appSettings>.
d.For application settings, use xdt:Locator="Match(name)" xdt:Transform="Replace".

2.Add the following lines for DEVBSN configuration in .sln file
a. In GlobalSection(SolutionConfigurationPlatforms) = preSolution: add DEVBSN|Any CPU = DEVBSN|Any CPU
b. In GlobalSection(ProjectConfigurationPlatforms) = postSolution (replace <ProjectGUID> with your actual project GUID): add {<ProjectGUID>}.DEVBSN|Any CPU.ActiveCfg = DEVBSN|Any CPU
{<ProjectGUID>}.DEVBSN|Any CPU.Build.0 = DEVBSN|Any CPU

3.Add the following lines for DEVBSN configuration in .vbproj file
1)Marked web.config in the ItemGroup section as a transform file
2)Add the web.DEVBSN.config to the ItemGroup section to include the new config file in the project, ensuring it is linked to web.config and marked as a transform file
3)add <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'DEVBSN|AnyCPU'"> same like 'Release|AnyCPU'