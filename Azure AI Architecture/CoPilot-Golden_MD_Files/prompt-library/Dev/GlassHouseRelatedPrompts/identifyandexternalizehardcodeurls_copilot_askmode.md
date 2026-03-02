## Prompt Name: DetectHardCodedValues_TableOutput
**Prompt:**
Use the output from the PowerShell script that scanned .cs\.xml\.vb\.html\.asp\.aspx\.ts\.ascx\.xslt\.master\.inc\.cshtml\.jsx\.xaml\.dbml\.frm\.vbs files for hardcoded values.
The script returns a table with:
•	Filename
•	MatchType
•	HardcodedValue
This output will be used to generate configuration keys and refactor code accordingly.
**Source:** Output from PowerShell script 
**Output:**
| Filename                           | MatchType              | HardcodedValue                                                            |
|------------------------------------|------------------------|---------------------------------------------------------------------------|
| ctrlViewCorrespondenceV3.ascx      | URL                    | http://imageone.carecorenational.com/FaxViewer/WebForm1.aspx?episodeID=   |
|------------------------------------|------------------------|---------------------------------------------------------------------------|

## Prompt Name: GenerateConfigurationKeys
**Prompt:**
For each hardcoded URL, add an <appSettings> entry in the config file. 
If a host and port combination in URL appears multiple times, add only one entry for that combination instead of the complete URL.
Use a descriptive key name. 
Only add key-value pairs to the config file that are applicable to the active code file.
**Do not include key-value pairs for URLs that do not appear in the active code file. Ignore values found in other files.**

**Source:**
- use output of prompt 1 to identify hardcoded URLs in the file.
- add the entries to the <appSettings> section of the config file.

## Prompt Name: AddEnvironmentKey_ConfigTransform

**Prompt:**  
Check if the `<appSettings>` section in App.config contains a key named `Environment`.  
- If it does not exist, add `<add key="Environment" value="" />` to the `<appSettings>` section in App.config.  
- Add the same key to App.DEVBSN.config with value `DEVBSN` using `xdt:Transform="SetAttributes"` and `xdt:Locator="Match(key)"`.

**Source:**  
- App.config file.

**Expected Output:**  
- App.config contains `<add key="Environment" value="" />` in the `<appSettings>` section if it was missing.

## Prompt Name: GenerateEnvironmentSpecificConfigFile

**Prompt**  
Generate a new environment-specific configuration transform file named app.DEVBSN.config based on the provided App.config file.

**Instructions:**  
- Use config transform syntax.
- The root `<configuration>` element must include `xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform"`.
- For each value to be replaced in `<appSettings>`, use `xdt:Transform="SetAttributes"` and `xdt:Locator="Match(key)"`.
- For each value to be replaced in `<connectionStrings>`, use `xdt:Transform="SetAttributes"` and `xdt:Locator="Match(name)"`.
- For each value to be replaced in `<system.serviceModel><client><endpoint>`, use `xdt:Transform="SetAttributes"` and `xdt:Locator="Match(name)"`.
- For each `<setting>` in `<applicationSettings>`, use `xdt:Transform="Replace"` and `xdt:Locator="Match(name)"`.
- For any custom elements containing environment-specific values, use the appropriate transform and locator attributes to target and update only the environment-specific values.
- Only include settings and elements that need to be transformed; do not include unchanged or static values.
- The transform file should only contain the sections and keys/values that are environment-specific.
- Include environment-specific values from `<appSettings>`, `<connectionStrings>`, `<system.serviceModel>`, `<applicationSettings>`, and any custom elements.
- Output the complete contents of the new app.DEVBSN.config file with the necessary transformations applied.

**Source**  
- Use App.config file as the base.

**Expected Output**  
- The complete contents of the new app.DEVBSN.config file with the necessary transformations applied, including all relevant environment-specific settings from `<appSettings>`, `<connectionStrings>`, `<system.serviceModel>`, `<applicationSettings>`, and any custom elements.

## Prompt Name: RefactorCode
**Prompt:**
Refactor the code in the file to replace hardcoded URL values with configuration key references.
Use ConfigurationManager.AppSettings["KeyName"] to retrieve the value from the config file and store it in a variable.
Mark the variable as readonly if it is not modified later in the code.
Variable names should be descriptive and follow the camelCase naming convention.
Use string interpolation to construct the full URL if needed.
Ensure that the variable is used wherever the hardcoded URL was previously used.
Ensure that the refactored code maintains the same functionality as before.
**Source:**
- use output of prompt 1 to identify hardcoded URLs in the file.
- use output of prompt 2 to get the corresponding configuration keys.
**Expected Output:**
- Refactored code with hardcoded URLs replaced by configuration key references.
- Share only the refactored code snippet, not the entire file.

## Prompt Name: ApplyRefactoredCode
**Prompt:**
Apply the refactored code to the original file, ensuring that all hardcoded URLs are replaced with the corresponding configuration key references.
Ensure that the code maintains the same functionality as before.
**Source:**
- use output of prompt 3 to get the refactored code.
- apply the refactored code to the original file.
**Expected Output:**
- The original file with hardcoded URLs replaced by configuration key references.
- Don't include the entire file, just the relevant code snippet.

## Prompt Name: AddTransformConfigToProjectFile
**Prompt:**
Add an MSBuild item declaration to the project file (.csproj) with the following details:

- **Item Type:** None
- **Include Attribute:** Web.DEVBSN.config
- **Item Metadata:** 
  - DependentUpon: Web.config
  - IsTransformFile: true
**Source:**
  - Use the project file (.csproj) as the base.
**Expected Output:**
  - The XML snippet to be added to the project file (.csproj) to include the App.DEVBSN.config file as a configuration transform for App.config.
```
<ItemGroup>
  <None Include="App.DEVBSN.config">
    <DependentUpon>App.config</DependentUpon>
    <IsTransformFile>true</IsTransformFile>
  </None>
</ItemGroup>
```

## Prompt Name: FindReleasePropertyGroups
**Prompt:**
Scan the project file (.csproj) and identify all MSBuild PropertyGroup declarations for Release configuration.  
Specifically, find every `<PropertyGroup>` element where the `Condition` attribute contains `$(Configuration)` set to `Release` and any value for `$(Platform)` (e.g., AnyCPU, x86, x64).  
List each matching PropertyGroup, including its Condition and the properties defined within.

**Source:**  
- Use the project file (.csproj) as the base.

**Expected Output:**
- A list of PropertyGroup elements that match the specified condition, including their Condition attribute and the properties defined within.
- Output only the relevant PropertyGroup elements, not the entire project file.
- The output should be in a table format with the following columns:
  - PropertyGroupCondition
  - Property
  - Value

**Output:**
| PropertyGroupCondition                                 | Property           | Value                                 |
|--------------------------------------------------------|--------------------|---------------------------------------|
| '$(Configuration)\|\$(Platform)' == 'Release|AnyCPU'   | DebugType          | pdbonly                               |
| '$(Configuration)\|\$(Platform)' == 'Release|AnyCPU'   | Optimize           | true                                  |
| '$(Configuration)\|\$(Platform)' == 'Release|AnyCPU'   | OutputPath         | bin\Release\                          |
| '$(Configuration)\|\$(Platform)' == 'Release|AnyCPU'   | DefineConstants    | TRACE                                 |
| '$(Configuration)\|\$(Platform)' == 'Release|AnyCPU'   | ErrorReport        | prompt                                |
| '$(Configuration)\|\$(Platform)' == 'Release|AnyCPU'   | WarningLevel       | 4                                     |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | OutputPath         | bin\x86\Release\                      |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | DefineConstants    | TRACE                                 |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | Optimize           | true                                  |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | DebugType          | pdbonly                               |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | PlatformTarget     | x86                                   |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | ErrorReport        | prompt                                |
| '$(Configuration)\|\$(Platform)' == 'Release|x86'      | CodeAnalysisRuleSet| MinimumRecommendedRules.ruleset       |

## Prompt Name: AddDevbsnPropertyGroups
**Prompt:**
Using the output from the previous prompt (all Release PropertyGroup declarations), create and add similar MSBuild PropertyGroup declarations for the DEVBSN configuration in the project file (.csproj).  
For each Release PropertyGroup found, generate a corresponding PropertyGroup for DEVBSN by replacing `Release` with `DEVBSN` in the Condition attribute, and preserve all other properties.  
Insert these new PropertyGroups into the project file.
Repeat for each platform found in the Release PropertyGroups (e.g., AnyCPU, x86, x64).

**Source:**  
- Use the output from the previous prompt to identify the Release PropertyGroups.

**Expected Output:**
- The XML snippets for the new DEVBSN PropertyGroups to be added to the project file (.csproj).

**Example:**
```
<PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'DEVBSN|AnyCPU' ">
  <DebugType>pdbonly</DebugType>
  <Optimize>true</Optimize>
  <OutputPath>bin\DEVBSN\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <ErrorReport>prompt</ErrorReport>
  <WarningLevel>4</WarningLevel>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'DEVBSN|x86'">
  <OutputPath>bin\x86\DEVBSN\</OutputPath>
  <DefineConstants>TRACE</DefineConstants>
  <Optimize>true</Optimize>
  <DebugType>pdbonly</DebugType>
  <PlatformTarget>x86</PlatformTarget>
  <ErrorReport>prompt</ErrorReport>
  <CodeAnalysisRuleSet>MinimumRecommendedRules.ruleset</CodeAnalysisRuleSet>
</PropertyGroup>
```

##Prompt Name: GenerateTestCases_FromCommitDiff
##Prompt:
Given the following git diff from commit <commit-id>, generate test cases for all new or modified methods and logic.
- Cover normal, edge, and error scenarios.
- Output test cases in C# using MSTest (or your preferred framework).
**Command**
- git --no-pager show 994f3b8d > E:\commit.txt
**Source:**
- The git diff output from commit.txt
**Expected Output:**
- id,test case,expected result,actual result
- 1,[Describe the scenario for the first change],[Expected outcome],(To be filled after test)
- 2,[Describe the scenario for the second change],[Expected outcome],(To be filled after test)




