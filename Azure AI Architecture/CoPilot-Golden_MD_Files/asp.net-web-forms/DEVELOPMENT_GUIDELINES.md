# ImageOne Queues Development Guidelines

## Overview
This document provides comprehensive coding standards, architectural guidelines, and best practices specifically for the **ImageOne Queues** solution. All developers must follow these guidelines to ensure consistency, maintainability, and high-quality code throughout the preventive care outreach queue system.

## Table of Contents
1. [Solution Architecture](#solution-architecture)
2. [Naming Conventions](#naming-conventions)
3. [SOLID Principles Implementation](#solid-principles-implementation)
4. [VB.NET Development Standards](#vbnet-development-standards)
5. [JavaScript/Frontend Standards](#javascriptfrontend-standards)
6. [CSS Guidelines](#css-guidelines)
7. [Database Patterns](#database-patterns)
8. [Error Handling Strategy](#error-handling-strategy)
9. [Security Implementation](#security-implementation)
10. [Performance Guidelines](#performance-guidelines)
11. [Testing Standards](#testing-standards)

## Solution Architecture

### Current Architecture Overview
The ImageOne Queues solution follows a **layered architecture** pattern:

```
???????????????????????????????????????????
?         Presentation Layer              ?  ? ASPX Pages, User Controls
???????????????????????????????????????????
?         Business Logic Layer           ?  ? Code-behind, WebMethods
???????????????????????????????????????????
?         Data Access Layer              ?  ? PreventiveCareQueueDBFunctions
???????????????????????????????????????????
?         Database Layer                 ?  ? SQL Server, Stored Procedures
???????????????????????????????????????????
```

### Project Structure
```
ImageOneQueues/
??? /Common/                    # Shared constants and utilities
?   ??? Constants.vb
??? /DataAccess/               # Data access layer
?   ??? PreventiveCareQueueDBFunctions.vb
??? /Models/                   # Data models
?   ??? CaseGridModel.vb
?   ??? CaseDetailsModel.vb
?   ??? PhysicianAndMemberDataModel.vb
??? /JScripts/                 # JavaScript files
?   ??? MemberDetails.js
?   ??? /src/                  # Third-party libraries
??? /Styles/                   # CSS stylesheets
?   ??? MemberDetailsStyles.css
??? /App_Code/                 # Shared code classes
??? /*.aspx                    # Web forms
```

### Key Components
- **MemberDetails.aspx(.vb)**: Primary member management interface
- **PreventiveCareOutreachQueue.aspx**: Main queue management
- **PreventiveCareQueueDBFunctions**: Central data access class
- **Constants.vb**: Application-wide constants

## Naming Conventions

### VB.NET Conventions

#### Variables and Fields
```vb
' Local variables - camelCase
Dim memberId As String
Dim episodeDetails As CaseDetailsModel
Dim isActiveCase As Boolean

' Private fields - camelCase with underscore prefix
Private _preventiveCareDB As PreventiveCareQueueDBFunctions
Private _connectionString As String
Private _logger As ILogger

' Public properties - PascalCase
Public Property MemberId As String
Public Property EpisodeId As String
Public Property QueueStatus As String
```

#### Methods and Classes
```vb
' Methods - PascalCase with descriptive action verbs
Public Function GetCasesByMember(memberId As String) As List(Of CaseGridModel)
Private Sub BindDropDownDistinctList(dropDown As DropDownList, filterType As String)
Public Shared Function GetEpisodeDetails(episodeId As String) As CaseDetailsModel

' Classes - PascalCase with descriptive nouns
Public Class PreventiveCareQueueDBFunctions
Public Class MemberDetailsService
Public Class CaseGridModel

' WebMethods - PascalCase with clear intent
<WebMethod()>
Public Shared Function GetQualifiers(episodeId As String, episodeDate As String, siteZip As String, userId As String) As Object
```

#### Constants
```vb
' Use Constants class for application-wide values
Public Class Constants
    Public Const ImageOne As String = "ImageOne"
    Public Const NotFound As String = "NotFound"
    Public Const PcpOutreachQueue As String = "PcpOutreachQueue"
    Public Const PCFilterTypeActive As String = "1"
End Class
```

### JavaScript Conventions
```javascript
// Variables and functions - camelCase
const memberId = '';
const episodeDetails = {};
let isLoadingData = false;

// Functions - camelCase with descriptive verbs
function getMemberDetails(memberId) { }
function bindCasesGrid(data) { }
function validateEpisodeInput(episodeId) { }

// Classes - PascalCase
class MemberDetailsHandler { }
class CaseGridManager { }

// Constants - UPPER_SNAKE_CASE for module constants
const API_ENDPOINTS = {
    GET_CASES: '/ImageOneQueues/MemberDetails.aspx/GetCasesByMember',
    GET_EPISODE: '/ImageOneQueues/MemberDetails.aspx/GetEpisodeDetails'
};

const ERROR_MESSAGES = {
    MEMBER_NOT_FOUND: 'Member not found',
    EPISODE_LOAD_FAILED: 'Failed to load episode details'
};
```

### CSS/HTML Conventions
```css
/* Classes - kebab-case with BEM methodology */
.member-details { }
.member-details__header { }
.member-details__content { }
.member-details--loading { }

.case-grid { }
.case-grid__row { }
.case-grid__cell { }
.case-grid__cell--episode-id { }

/* IDs - kebab-case */
#member-details-form { }
#cases-table { }
#services-dropdown { }
```

## SOLID Principles Implementation

### Single Responsibility Principle (SRP)
Each class should have one reason to change.

```vb
' ? Bad - MemberDetails.aspx.vb doing too much
Public Class MemberDetails
    ' Page logic, data access, business rules, UMAP integration all mixed
End Class

' ? Good - Separate concerns
Public Class MemberDetailsService
    Public Function GetMemberCases(memberId As String) As List(Of CaseGridModel)
End Class

Public Class UMAPQualifierService
    Public Function GenerateQualifiers(episodeId As String, episodeDate As DateTime, siteZip As String, userId As String) As String
End Class

Public Class EpisodeValidator
    Public Function ValidateEpisodeId(episodeId As String) As Boolean
End Class
```

### Open/Closed Principle (OCP)
```vb
' ? Abstract base for different data sources
Public MustInherit Class BaseDataAccess
    Public MustOverride Function GetCaseDetails(episodeId As String) As CaseDetailsModel
    
    Protected Function LogError(ex As Exception, context As String) As Object
        ' Common error logging logic
    End Function
End Class

Public Class SqlDataAccess
    Inherits BaseDataAccess
    
    Public Overrides Function GetCaseDetails(episodeId As String) As CaseDetailsModel
        ' SQL implementation
    End Function
End Class
```

### Dependency Inversion Principle (DIP)
```vb
' ? Use interfaces and dependency injection
Public Interface IPreventiveCareRepository
    Function GetCasesByMember(memberId As String) As List(Of CaseGridModel)
    Function GetEpisodeDetails(episodeId As String) As CaseDetailsModel
End Interface

Public Class MemberDetailsPage
    Private ReadOnly _repository As IPreventiveCareRepository
    Private ReadOnly _logger As ILogger
    
    Public Sub New(repository As IPreventiveCareRepository, logger As ILogger)
        _repository = repository
        _logger = logger
    End Sub
End Class
```

## VB.NET Development Standards

### WebMethods Pattern
```vb
' ? Proper WebMethod implementation
<WebMethod()>
Public Shared Function GetCasesByMember(memberId As String) As List(Of CaseGridModel)
    Try
        ' Input validation
        If String.IsNullOrWhiteSpace(memberId) Then
            Throw New ArgumentException("Member ID is required", NameOf(memberId))
        End If
        
        ' Business logic
        Dim repository As New PreventiveCareQueueDBFunctions()
        Dim result = repository.GetCasesByMember(memberId)
        
        Return result
    Catch ex As Exception
        ' Log error with context
        Dim logger As New Logger()
        logger.LogError(ex, "Error retrieving cases for member: {MemberId}", memberId)
        Throw
    End Try
End Function
```

### Exception Handling
```vb
' ? Structured exception handling with CCN.Exceptions
Public Function GetUMAPQualifiers(episodeId As String, episodeDate As DateTime, siteZip As String, userId As String) As String
    Try
        ' Validate inputs
        ValidateQualifierInputs(episodeId, episodeDate, siteZip, userId)
        
        ' Business logic
        Dim caseDetails = GetCaseDetails(episodeId, episodeDate)
        If caseDetails Is Nothing Then
            Return String.Empty
        End If
        
        Return BuildQualifierString(caseDetails, siteZip, userId)
        
    Catch ex As ArgumentException
        ' Re-throw validation errors
        Throw
    Catch ex As Exception
        ' Log and wrap unexpected errors
        Dim context = $"EpisodeID: {episodeId}; EpisodeDate: {episodeDate}; SiteZip: {siteZip}; UserId: {userId}"
        Dim ccnEx = New CCN.Exceptions.CCNException("PreventiveCareOutreachQueue GetUMAPQualifiers Error", 
                                                   CCN.Exceptions.Enumerations.SeverityLevels.Normal, 
                                                   context, "ImageOneQueues", ex)
        CCN.Exceptions.ExceptionManager.Instance.LogException(ccnEx, CCN.Exceptions.SeverityLevels.Normal)
        Throw New ServiceException("Error generating UMAP qualifiers", ex)
    End Try
End Function
```

### Data Access Patterns
```vb
' ? Proper parameterized queries with error handling
Public Function GetCasesByMember(memberId As String) As List(Of CaseGridModel)
    Dim cases As New List(Of CaseGridModel)
    
    Try
        Using connection As New SqlConnection(ConfigurationManager.ConnectionStrings("strConnT1Read").ConnectionString)
            Using command As New SqlCommand("PC_GetMemberCaseDetails", connection)
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@MemberID", SqlDbType.VarChar, 25).Value = memberId
                
                connection.Open()
                Using reader As SqlDataReader = command.ExecuteReader()
                    While reader.Read()
                        cases.Add(MapToCaseGridModel(reader))
                    End While
                End Using
            End Using
        End Using
        
        Return cases
    Catch ex As SqlException
        Dim context = $"MemberID: {memberId}"
        Dim ccnEx = New CCN.Exceptions.CCNException("Database error in GetCasesByMember", 
                                                   CCN.Exceptions.Enumerations.SeverityLevels.Normal, 
                                                   context, "ImageOneQueues", ex)
        CCN.Exceptions.ExceptionManager.Instance.LogException(ccnEx, CCN.Exceptions.SeverityLevels.Normal)
        Throw
    End Try
End Function

Private Function MapToCaseGridModel(reader As SqlDataReader) As CaseGridModel
    Return New CaseGridModel With {
        .EpisodeID = SafeGetString(reader, "EpisodeId"),
        .Service = SafeGetString(reader, "Service"),
        .QueueStatus = SafeGetString(reader, "QueueStatus"),
        .DispositionDate = SafeGetString(reader, "DeterminationDate"),
        .NextOutreachDueDate = SafeGetString(reader, "NextOutReachDate"),
        .ActiveInActive = SafeGetString(reader, "ActiveInActive"),
        .EpisodeDate = SafeGetString(reader, "EpisodeDate"),
        .SiteZip = SafeGetString(reader, "SiteZip")
    }
End Function

Private Function SafeGetString(reader As SqlDataReader, columnName As String) As String
    Dim ordinal = reader.GetOrdinal(columnName)
    Return If(reader.IsDBNull(ordinal), String.Empty, reader.GetString(ordinal).Trim())
End Function
```

### Input Validation and Security
```vb
' ? Comprehensive input validation
Public Function GetStringValueOrDefault(fieldValue As String) As String
    If String.IsNullOrWhiteSpace(fieldValue) Then
        Return Constants.NotFound
    Else
        ' URL encode to prevent injection
        Return HttpUtility.UrlEncode(fieldValue)
    End If
End Function

Public Function ValidateEpisodeId(episodeId As String) As Boolean
    If String.IsNullOrWhiteSpace(episodeId) Then
        Return False
    End If
    
    ' Check for SQL injection patterns
    If ContainsSqlInjectionPatterns(episodeId) Then
        Throw New SecurityException("Invalid episode ID format")
    End If
    
    ' Validate format (alphanumeric with specific prefixes)
    Return Regex.IsMatch(episodeId, "^(CC|C)?[A-Za-z0-9]+$")
End Function

Private Function ContainsSqlInjectionPatterns(input As String) As Boolean
    Dim patterns As String() = {"'", "--", "/*", "*/", "xp_", "sp_", "DROP", "DELETE", "INSERT", "UPDATE"}
    Return patterns.Any(Function(pattern) input.ToUpper().Contains(pattern.ToUpper()))
End Function
```

## JavaScript/Frontend Standards

### Modern JavaScript Patterns
```javascript
// ? Use modern JavaScript features
class MemberDetailsManager {
    constructor() {
        this.apiEndpoints = {
            getCases: '/ImageOneQueues/MemberDetails.aspx/GetCasesByMember',
            getEpisode: '/ImageOneQueues/MemberDetails.aspx/GetEpisodeDetails',
            getQualifiers: '/ImageOneQueues/MemberDetails.aspx/GetQualifiers'
        };
        this.isLoading = false;
        this.currentMemberId = null;
    }
    
    async loadMemberCases(memberId) {
        try {
            this.validateMemberId(memberId);
            this.showLoadingState();
            
            const response = await this.callWebMethod(this.apiEndpoints.getCases, { memberId });
            
            if (response && response.d) {
                this.renderCasesGrid(response.d);
            } else {
                this.showNoDataMessage('No cases found for this member');
            }
        } catch (error) {
            this.handleError(error, 'loading member cases');
        } finally {
            this.hideLoadingState();
        }
    }
    
    async callWebMethod(url, data) {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    }
    
    validateMemberId(memberId) {
        if (!memberId || typeof memberId !== 'string') {
            throw new ValidationError('Member ID is required');
        }
        
        if (memberId.length > 25) {
            throw new ValidationError('Member ID cannot exceed 25 characters');
        }
        
        if (!/^[A-Za-z0-9]+$/.test(memberId)) {
            throw new ValidationError('Member ID contains invalid characters');
        }
    }
    
    renderCasesGrid(cases) {
        const container = document.getElementById('cases-grid-container');
        if (!container) return;
        
        if (!cases || cases.length === 0) {
            container.innerHTML = '<p class="no-data">No cases found</p>';
            return;
        }
        
        let html = '<table class="case-grid"><thead><tr>';
        html += '<th>Episode ID</th><th>Service</th><th>Status</th><th>Episode Date</th><th>Actions</th>';
        html += '</tr></thead><tbody>';
        
        cases.forEach(caseItem => {
            html += this.renderCaseRow(caseItem);
        });
        
        html += '</tbody></table>';
        container.innerHTML = html;
    }
    
    renderCaseRow(caseItem) {
        return `
            <tr class="case-grid__row" data-episode-id="${this.escapeHtml(caseItem.EpisodeID)}">
                <td class="case-grid__cell case-grid__cell--episode-id">
                    <a href="#" class="episode-link" data-episode-id="${this.escapeHtml(caseItem.EpisodeID)}"
                       data-episode-date="${this.escapeHtml(caseItem.EpisodeDate)}"
                       data-site-zip="${this.escapeHtml(caseItem.SiteZip)}">
                        ${this.escapeHtml(caseItem.EpisodeID)}
                    </a>
                </td>
                <td class="case-grid__cell">${this.escapeHtml(caseItem.Service)}</td>
                <td class="case-grid__cell">${this.escapeHtml(caseItem.QueueStatus)}</td>
                <td class="case-grid__cell">${this.formatDate(caseItem.EpisodeDate)}</td>
                <td class="case-grid__cell case-grid__cell--actions">
                    <button class="btn btn--small view-details-btn" data-episode-id="${this.escapeHtml(caseItem.EpisodeID)}">
                        View Details
                    </button>
                </td>
            </tr>
        `;
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    handleError(error, context) {
        console.error(`Error ${context}:`, error);
        
        let message = 'An unexpected error occurred';
        if (error instanceof ValidationError) {
            message = error.message;
        } else if (error.name === 'NetworkError') {
            message = 'Network error. Please check your connection.';
        }
        
        this.showErrorMessage(message);
    }
}

// Custom error classes
class ValidationError extends Error {
    constructor(message) {
        super(message);
        this.name = 'ValidationError';
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.memberDetailsManager = new MemberDetailsManager();
});
```

### Event Handling Best Practices
```javascript
// ? Event delegation and proper cleanup
class EventManager {
    constructor() {
        this.eventHandlers = new Map();
        this.initializeEvents();
    }
    
    initializeEvents() {
        // Use event delegation for dynamic content
        this.addEventListener(document, 'click', this.handleDocumentClick.bind(this));
        this.addEventListener(document, 'keydown', this.handleKeydown.bind(this));
        
        // Form-specific events
        const memberForm = document.getElementById('member-details-form');
        if (memberForm) {
            this.addEventListener(memberForm, 'submit', this.handleFormSubmit.bind(this));
        }
    }
    
    addEventListener(element, eventType, handler) {
        element.addEventListener(eventType, handler);
        
        // Store for cleanup
        if (!this.eventHandlers.has(element)) {
            this.eventHandlers.set(element, []);
        }
        this.eventHandlers.get(element).push({ eventType, handler });
    }
    
    handleDocumentClick(event) {
        // Handle episode links
        if (event.target.matches('.episode-link')) {
            event.preventDefault();
            this.handleEpisodeClick(event.target);
            return;
        }
        
        // Handle view details buttons
        if (event.target.matches('.view-details-btn')) {
            event.preventDefault();
            this.handleViewDetailsClick(event.target);
            return;
        }
    }
    
    async handleEpisodeClick(element) {
        try {
            const episodeId = element.dataset.episodeId;
            const episodeDate = element.dataset.episodeDate;
            const siteZip = element.dataset.siteZip;
            
            if (!episodeId) {
                throw new ValidationError('Episode ID is required');
            }
            
            await window.memberDetailsManager.loadEpisodeDetails(episodeId, episodeDate, siteZip);
        } catch (error) {
            window.memberDetailsManager.handleError(error, 'episode click');
        }
    }
    
    // Cleanup method
    destroy() {
        for (const [element, handlers] of this.eventHandlers) {
            handlers.forEach(({ eventType, handler }) => {
                element.removeEventListener(eventType, handler);
            });
        }
        this.eventHandlers.clear();
    }
}
```

## CSS Guidelines

### BEM Methodology with CSS Custom Properties
```css
/* ? CSS Custom Properties for theming */
:root {
    /* ImageOne Queues specific colors */
    --color-primary: #339999; /* bgColor from web.config */
    --color-secondary: #6c757d;
    --color-success: #198754;
    --color-danger: #dc3545;
    --color-warning: #ffc107;
    
    /* Typography */
    --font-family-base: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    --font-size-base: 1rem;
    --font-size-small: 0.875rem;
    
    /* Spacing */
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 1.5rem;
    --spacing-xl: 3rem;
    
    /* Layout */
    --border-radius: 0.375rem;
    --box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    --transition-base: all 0.15s ease-in-out;
}

/* ? BEM component structure */
.member-details {
    background: white;
    border-radius: var(--border-radius);
    box-shadow: var(--box-shadow);
    padding: var(--spacing-lg);
}

.member-details__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-md);
    padding-bottom: var(--spacing-sm);
    border-bottom: 1px solid #dee2e6;
}

.member-details__title {
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--color-primary);
    margin: 0;
}

.member-details__content {
    display: grid;
    gap: var(--spacing-md);
}

.member-details--loading {
    opacity: 0.6;
    pointer-events: none;
}

/* Case grid specific styles */
.case-grid {
    width: 100%;
    border-collapse: collapse;
    margin-top: var(--spacing-md);
}

.case-grid__header {
    background-color: var(--color-primary);
    color: white;
}

.case-grid__row {
    border-bottom: 1px solid #dee2e6;
    transition: var(--transition-base);
}

.case-grid__row:hover {
    background-color: #f8f9fa;
}

.case-grid__cell {
    padding: var(--spacing-sm) var(--spacing-md);
    text-align: left;
    vertical-align: middle;
}

.case-grid__cell--episode-id {
    font-weight: 600;
}

.case-grid__cell--actions {
    text-align: center;
    width: 120px;
}

/* Button components */
.btn {
    display: inline-block;
    padding: var(--spacing-sm) var(--spacing-md);
    border: 1px solid transparent;
    border-radius: var(--border-radius);
    font-size: var(--font-size-base);
    font-weight: 400;
    text-align: center;
    text-decoration: none;
    cursor: pointer;
    transition: var(--transition-base);
}

.btn--primary {
    background-color: var(--color-primary);
    border-color: var(--color-primary);
    color: white;
}

.btn--primary:hover {
    background-color: color-mix(in srgb, var(--color-primary) 85%, black);
    border-color: color-mix(in srgb, var(--color-primary) 85%, black);
}

.btn--small {
    padding: var(--spacing-xs) var(--spacing-sm);
    font-size: var(--font-size-small);
}

/* Responsive design */
@media (max-width: 768px) {
    .member-details__header {
        flex-direction: column;
        align-items: flex-start;
        gap: var(--spacing-sm);
    }
    
    .case-grid {
        font-size: var(--font-size-small);
    }
    
    .case-grid__cell {
        padding: var(--spacing-xs);
    }
}
```

## Database Patterns

### Stored Procedure Standards
```sql
-- ? Well-structured stored procedure following ImageOne patterns
CREATE PROCEDURE PC_GetMemberCaseDetails
    @MemberID NVARCHAR(25),
    @ServiceType NVARCHAR(100) = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @MemberID IS NULL OR LEN(TRIM(@MemberID)) = 0
    BEGIN
        RAISERROR('MemberID is required', 16, 1);
        RETURN;
    END
    
    -- Validate member ID format
    IF NOT (@MemberID LIKE '[A-Za-z0-9]%' AND LEN(@MemberID) <= 25)
    BEGIN
        RAISERROR('Invalid MemberID format', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        SELECT 
            c.EpisodeId,
            c.Service,
            c.QueueStatus,
            c.DeterminationDate,
            c.NextOutReachDate,
            c.ActiveInActive,
            c.EpisodeDate,
            c.SiteZip,
            m.PatientName,
            m.PatientPhone
        FROM PreventiveCases c
            INNER JOIN Members m ON c.MemberId = m.MemberId
        WHERE c.MemberId = @MemberID
            AND (@ServiceType IS NULL OR c.Service = @ServiceType)
            AND (@IncludeInactive = 1 OR c.ActiveInActive = 'Active')
        ORDER BY c.EpisodeDate DESC, c.EpisodeId;
        
    END TRY
    BEGIN CATCH
        -- Log error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        -- Insert into error log table
        INSERT INTO ErrorLog (ProcedureName, Parameters, ErrorMessage, ErrorDate)
        VALUES ('PC_GetMemberCaseDetails', 
                CONCAT('MemberID:', @MemberID, ', ServiceType:', ISNULL(@ServiceType, 'NULL')),
                @ErrorMessage, GETDATE());
        
        -- Re-raise error
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
```

### Data Access Best Practices
```vb
' ? Efficient data access with proper resource management
Public Function GetMemberCasesWithPaging(memberId As String, pageNumber As Integer, pageSize As Integer) As PagedResult(Of CaseGridModel)
    Try
        Using connection As New SqlConnection(ConfigurationManager.ConnectionStrings("strConnT1Read").ConnectionString)
            connection.Open()
            
            ' Get total count
            Dim totalRecords As Integer
            Using countCommand As New SqlCommand("SELECT COUNT(*) FROM PreventiveCases WHERE MemberId = @MemberId", connection)
                countCommand.Parameters.AddWithValue("@MemberId", memberId)
                totalRecords = CInt(countCommand.ExecuteScalar())
            End Using
            
            ' Get paged data
            Dim cases As New List(Of CaseGridModel)()
            Using command As New SqlCommand("PC_GetMemberCaseDetailsPaged", connection)
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.AddWithValue("@MemberID", memberId)
                command.Parameters.AddWithValue("@PageNumber", pageNumber)
                command.Parameters.AddWithValue("@PageSize", pageSize)
                
                Using reader = command.ExecuteReader()
                    While reader.Read()
                        cases.Add(MapToCaseGridModel(reader))
                    End While
                End Using
            End Using
            
            Return New PagedResult(Of CaseGridModel) With {
                .Items = cases,
                .TotalRecords = totalRecords,
                .PageNumber = pageNumber,
                .PageSize = pageSize
            }
        End Using
        
    Catch ex As Exception
        LogDataAccessError(ex, "GetMemberCasesWithPaging", $"MemberId: {memberId}")
        Throw
    End Try
End Function
```

## Error Handling Strategy

### Global Error Handling (Global.asax)
```vb
' ? Implement comprehensive global error handling
Protected Sub Application_Error(sender As Object, e As EventArgs)
    Dim exception = Server.GetLastError()
    Dim httpContext = HttpContext.Current
    
    ' Log the error with full context
    Try
        Dim context = New Dictionary(Of String, Object) From {
            {"Url", httpContext?.Request?.Url?.ToString()},
            {"UserAgent", httpContext?.Request?.UserAgent},
            {"User", httpContext?.User?.Identity?.Name},
            {"SessionId", httpContext?.Session?.SessionID},
            {"Timestamp", DateTime.Now}
        }
        
        Dim ccnEx = New CCN.Exceptions.CCNException(
            "Unhandled Application Error", 
            CCN.Exceptions.Enumerations.SeverityLevels.High, 
            context.ToString(), 
            "ImageOneQueues", 
            exception)
        
        CCN.Exceptions.ExceptionManager.Instance.LogException(ccnEx, CCN.Exceptions.SeverityLevels.High)
        
    Catch logEx As Exception
        ' Fallback logging if CCN.Exceptions fails
        EventLog.WriteEntry("ImageOneQueues", $"Critical error: {exception?.Message}. Logging failed: {logEx.Message}", EventLogEntryType.Error)
    End Try
    
    ' Clear the error
    Server.ClearError()
    
    ' Redirect to appropriate error page
    If TypeOf exception Is HttpException Then
        Dim httpException = DirectCast(exception, HttpException)
        Select Case httpException.GetHttpCode()
            Case 404
                Response.Redirect("~/ErrorPage.aspx?type=notfound")
            Case 403
                Response.Redirect("~/ErrorPage.aspx?type=forbidden")
            Case 500
                Response.Redirect("~/ErrorPage.aspx?type=server")
            Case Else
                Response.Redirect("~/ErrorPage.aspx")
        End Select
    Else
        Response.Redirect("~/ErrorPage.aspx")
    End If
End Sub
```

### Custom Exception Classes
```vb
' ? ImageOne Queues specific exception classes
Public Class PreventiveCareException
    Inherits Exception
    
    Public Property EpisodeId As String
    Public Property MemberId As String
    Public Property ContextData As Dictionary(Of String, Object)
    
    Public Sub New(message As String)
        MyBase.New(message)
        ContextData = New Dictionary(Of String, Object)()
    End Sub
    
    Public Sub New(message As String, episodeId As String, memberId As String)
        MyBase.New(message)
        Me.EpisodeId = episodeId
        Me.MemberId = memberId
        ContextData = New Dictionary(Of String, Object)()
    End Sub
    
    Public Sub New(message As String, innerException As Exception)
        MyBase.New(message, innerException)
        ContextData = New Dictionary(Of String, Object)()
    End Sub
End Class

Public Class QualifierGenerationException
    Inherits PreventiveCareException
    
    Public Property SiteZip As String
    Public Property UserId As String
    
    Public Sub New(message As String, episodeId As String, siteZip As String, userId As String)
        MyBase.New(message, episodeId, Nothing)
        Me.SiteZip = siteZip
        Me.UserId = userId
    End Sub
End Class
```

## Security Implementation

### Input Validation
```vb
' ? Comprehensive input validation following ImageOne patterns
Public Class SecurityHelper
    Private Shared ReadOnly SqlInjectionPatterns As String() = {
        "'", "--", "/*", "*/", "xp_", "sp_", "EXEC", "EXECUTE", 
        "DROP", "DELETE", "INSERT", "UPDATE", "UNION", "SELECT"
    }
    
    Private Shared ReadOnly XssPatterns As String() = {
        "<script", "</script>", "javascript:", "vbscript:", "onload=", 
        "onerror=", "onclick=", "eval(", "expression("
    }
    
    Public Shared Function ValidateAndSanitizeMemberId(memberId As String) As String
        If String.IsNullOrWhiteSpace(memberId) Then
            Throw New ArgumentException("Member ID cannot be null or empty")
        End If
        
        ' Check length
        If memberId.Length > 25 Then
            Throw New ArgumentException("Member ID cannot exceed 25 characters")
        End If
        
        ' Check for malicious patterns
        Dim upperInput = memberId.ToUpper()
        For Each pattern In SqlInjectionPatterns
            If upperInput.Contains(pattern.ToUpper()) Then
                Throw New SecurityException($"Member ID contains invalid pattern: {pattern}")
            End If
        Next
        
        ' Validate format (alphanumeric only)
        If Not Regex.IsMatch(memberId, "^[A-Za-z0-9]+$") Then
            Throw New ArgumentException("Member ID can only contain alphanumeric characters")
        End If
        
        Return memberId.Trim()
    End Function
    
    Public Shared Function ValidateEpisodeId(episodeId As String) As String
        If String.IsNullOrWhiteSpace(episodeId) Then
            Throw New ArgumentException("Episode ID cannot be null or empty")
        End If
        
        ' Clean up episode ID (handle CC->A0, C->A transformations)
        Dim cleanEpisodeId = episodeId.Replace("CC", "A0").Replace("C", "A")
        
        ' Validate the cleaned episode ID
        If Not Regex.IsMatch(cleanEpisodeId, "^[A-Za-z0-9]+$") Then
            Throw New ArgumentException("Episode ID contains invalid characters")
        End If
        
        Return cleanEpisodeId
    End Function
    
    Public Shared Function SanitizeForUrl(input As String) As String
        If String.IsNullOrWhiteSpace(input) Then
            Return Constants.NotFound
        End If
        
        ' Remove potentially dangerous characters
        Dim sanitized = Regex.Replace(input, "[<>\"'&]", "")
        
        ' URL encode
        Return HttpUtility.UrlEncode(sanitized)
    End Function
End Class
```

### Authentication and Authorization
```vb
' ? Implement proper authentication checks
Public Class AuthenticationHelper
    Public Shared Function GetCurrentUserId() As String
        Dim userId As String = String.Empty
        
        ' Check query string first
        If HttpContext.Current?.Request?.QueryString("UserName") IsNot Nothing Then
            userId = HttpContext.Current.Request.QueryString("UserName")
        End If
        
        ' Check session
        If String.IsNullOrEmpty(userId) AndAlso HttpContext.Current?.Session("UserName") IsNot Nothing Then
            userId = Convert.ToString(HttpContext.Current.Session("UserName"))
        End If
        
        ' Validate user ID
        If String.IsNullOrWhiteSpace(userId) Then
            Throw New UnauthorizedAccessException("User not authenticated")
        End If
        
        Return SecurityHelper.ValidateAndSanitizeMemberId(userId)
    End Function
    
    Public Shared Function CanAccessMemberData(userId As String, memberId As String) As Boolean
        ' Implement your authorization logic here
        ' This could check against employee restrictions, role-based access, etc.
        
        ' For now, basic validation
        If String.IsNullOrWhiteSpace(userId) OrElse String.IsNullOrWhiteSpace(memberId) Then
            Return False
        End If
        
        ' Could integrate with EmpRestrictionURL from web.config
        ' Return CheckEmployeeRestrictions(userId, memberId)
        
        Return True
    End Function
End Class
```

## Performance Guidelines

### Caching Strategy
```vb
' ? Implement appropriate caching for filter data
Public Class CachedDataService
    Private Shared ReadOnly CacheExpirationMinutes As Integer = 30
    Private Shared ReadOnly CacheKeyPrefix As String = "ImageOneQueues_"
    
    Public Shared Function GetFilterValues(filterType As String) As DataSet
        Dim cacheKey = $"{CacheKeyPrefix}FilterValues_{filterType}"
        
        ' Try cache first
        Dim cached = HttpContext.Current?.Cache(cacheKey)
        If cached IsNot Nothing Then
            Return DirectCast(cached, DataSet)
        End If
        
        ' Get from database
        Dim db As New PreventiveCareQueueDBFunctions()
        Dim result = db.GetPCFilterTypeValues(filterType)
        
        ' Cache the result
        If result IsNot Nothing AndAlso result.Tables.Count > 0 Then
            HttpContext.Current?.Cache.Insert(
                cacheKey,
                result,
                Nothing,
                DateTime.Now.AddMinutes(CacheExpirationMinutes),
                TimeSpan.Zero
            )
        End If
        
        Return result
    End Function
    
    Public Shared Sub ClearFilterCache()
        Dim cache = HttpContext.Current?.Cache
        If cache IsNot Nothing Then
            ' Remove all filter-related cache entries
            Dim keysToRemove As New List(Of String)()
            For Each item As DictionaryEntry In cache
                If item.Key.ToString().StartsWith($"{CacheKeyPrefix}FilterValues_") Then
                    keysToRemove.Add(item.Key.ToString())
                End If
            Next
            
            For Each key In keysToRemove
                cache.Remove(key)
            Next
        End If
    End Sub
End Class
```

### Database Performance
```vb
' ? Optimize database calls with proper connection management
Public Class OptimizedDataAccess
    Private ReadOnly _connectionString As String
    
    Public Sub New()
        _connectionString = ConfigurationManager.ConnectionStrings("strConnT1Read").ConnectionString
    End Sub
    
    Public Async Function GetMemberDataAsync(memberId As String) As Task(Of MemberDetailViewModel)
        Using connection As New SqlConnection(_connectionString)
            Await connection.OpenAsync()
            
            ' Use multiple result sets to reduce round trips
            Using command As New SqlCommand("PC_GetMemberDetailsComplete", connection)
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.AddWithValue("@MemberID", memberId)
                command.CommandTimeout = 60 ' Set appropriate timeout
                
                Using reader = Await command.ExecuteReaderAsync()
                    Dim result As New MemberDetailViewModel()
                    
                    ' First result set: Member details
                    If reader.HasRows AndAlso Await reader.ReadAsync() Then
                        result.MemberDetails = MapToMemberModel(reader)
                    End If
                    
                    ' Second result set: Cases
                    If Await reader.NextResultAsync() Then
                        result.Cases = New List(Of CaseGridModel)()
                        While Await reader.ReadAsync()
                            result.Cases.Add(MapToCaseGridModel(reader))
                        End While
                    End If
                    
                    ' Third result set: Physician details
                    If Await reader.NextResultAsync() AndAlso Await reader.ReadAsync() Then
                        result.PhysicianDetails = MapToPhysicianModel(reader)
                    End If
                    
                    Return result
                End Using
            End Using
        End Using
    End Function
End Class
```

## Testing Standards

### Unit Testing Patterns
```vb
' ? Unit test example for ImageOne Queues
<TestClass>
Public Class MemberDetailsServiceTests
    Private _mockRepository As Mock(Of IPreventiveCareRepository)
    Private _mockLogger As Mock(Of ILogger)
    Private _service As MemberDetailsService
    
    <TestInitialize>
    Public Sub Setup()
        _mockRepository = New Mock(Of IPreventiveCareRepository)()
        _mockLogger = New Mock(Of ILogger)()
        _service = New MemberDetailsService(_mockRepository.Object, _mockLogger.Object)
    End Sub
    
    <TestMethod>
    Public Async Function GetCasesByMember_ValidMemberId_ReturnsCases() As Task
        ' Arrange
        Dim memberId = "TEST123"
        Dim expectedCases = New List(Of CaseGridModel) From {
            New CaseGridModel With {.EpisodeID = "EP001", .Service = "Mammography"},
            New CaseGridModel With {.EpisodeID = "EP002", .Service = "Colonoscopy"}
        }
        
        _mockRepository.Setup(Function(r) r.GetCasesByMember(memberId)).Returns(expectedCases)
        
        ' Act
        Dim result = Await _service.GetCasesByMemberAsync(memberId)
        
        ' Assert
        Assert.IsNotNull(result)
        Assert.AreEqual(2, result.Count)
        Assert.AreEqual("EP001", result(0).EpisodeID)
        Assert.AreEqual("Mammography", result(0).Service)
    End Function
    
    <TestMethod>
    <ExpectedException(GetType(ArgumentException))>
    Public Async Function GetCasesByMember_NullMemberId_ThrowsArgumentException() As Task
        ' Act & Assert
        Await _service.GetCasesByMemberAsync(Nothing)
    End Function
    
    <TestMethod>
    <ExpectedException(GetType(ArgumentException))>
    Public Async Function GetCasesByMember_InvalidMemberId_ThrowsArgumentException() As Task
        ' Act & Assert
        Await _service.GetCasesByMemberAsync("INVALID<>ID")
    End Function
End Class
```

### Integration Testing
```vb
' ? Integration test example
<TestClass>
Public Class PreventiveCareQueueDBFunctionsIntegrationTests
    Private _dbFunctions As PreventiveCareQueueDBFunctions
    
    <TestInitialize>
    Public Sub Setup()
        _dbFunctions = New PreventiveCareQueueDBFunctions()
    End Sub
    
    <TestMethod>
    Public Sub GetCasesByMember_ValidMemberId_ReturnsExpectedData()
        ' Arrange
        Dim testMemberId = "TESTMEMBER001" ' Use test data
        
        ' Act
        Dim result = _dbFunctions.GetCasesByMember(testMemberId)
        
        ' Assert
        Assert.IsNotNull(result)
        Assert.IsInstanceOfType(result, GetType(List(Of CaseGridModel)))
        
        ' Verify structure of returned data
        If result.Count > 0 Then
            Dim firstCase = result(0)
            Assert.IsFalse(String.IsNullOrEmpty(firstCase.EpisodeID))
            Assert.IsFalse(String.IsNullOrEmpty(firstCase.Service))
        End If
    End Sub
End Class
```

## Code Quality Checklist

### Pre-Commit Checklist
Before committing code, ensure:

#### General
- [ ] Code follows naming conventions outlined in this document
- [ ] SOLID principles are applied appropriately
- [ ] No code duplication (DRY principle followed)
- [ ] Methods are focused and have single responsibility
- [ ] Error handling is implemented with CCN.Exceptions
- [ ] Input validation is performed at all entry points
- [ ] Resources are properly disposed (Using statements)

#### Security
- [ ] All user inputs are validated and sanitized
- [ ] SQL queries use parameterized statements
- [ ] Output is properly encoded (HttpUtility.UrlEncode)
- [ ] Authentication checks are in place
- [ ] No sensitive data is logged or exposed

#### Performance
- [ ] Database queries are optimized
- [ ] Appropriate caching is implemented
- [ ] Large datasets use pagination
- [ ] Async/await is used for I/O operations

#### VB.NET Specific
- [ ] WebMethods follow established patterns
- [ ] Exception handling uses CCN.Exceptions framework
- [ ] Constants are defined in Constants.vb
- [ ] Data models are properly structured in Models folder

#### JavaScript Specific
- [ ] Modern JavaScript features are used
- [ ] Event handlers are properly bound and cleaned up
- [ ] Error handling provides user-friendly messages
- [ ] XSS prevention is implemented (escapeHtml function)

### Code Review Guidelines
During code reviews, focus on:

1. **Architecture Compliance**: Does the code follow the established layered architecture?
2. **Security**: Are all inputs validated? Are there any potential vulnerabilities?
3. **Performance**: Will this code perform well under load?
4. **Maintainability**: Is the code easy to understand and modify?
5. **Error Handling**: Are errors properly caught, logged, and handled?
6. **Testing**: Are there adequate tests for the functionality?

## Deployment Considerations

### Configuration Management
- Use web.config transformations for different environments
- Keep sensitive data in encrypted sections
- Follow the established connection string patterns
- Maintain consistency with UPADSUrl and other ImageOne-specific settings

### Performance Monitoring
- Utilize ApplicationInsights configuration from web.config
- Monitor database query performance
- Track WebMethod response times
- Monitor cache hit ratios

### Error Monitoring
- Ensure CCN.Exceptions framework is properly configured
- Monitor exception trends and patterns
- Set up alerts for critical errors
- Review logs regularly for security threats

## Conclusion

These guidelines ensure consistency, security, and maintainability across the ImageOne Queues solution. All developers must adhere to these standards when implementing new features or modifying existing code.

### Key Reminders for ImageOne Queues
- **Always use CCN.Exceptions** for error handling and logging
- **Follow the Constants.vb pattern** for application-wide values
- **Use PreventiveCareQueueDBFunctions** for data access
- **Implement proper input validation** for all user inputs
- **Follow the established folder structure** and naming conventions
- **Integrate with UPADS** using the patterns shown in MemberDetails.aspx.vb
- **Use the existing CSS and JavaScript patterns** for UI consistency

### Resources
- Web.config: Application configuration and connection strings
- Constants.vb: Application-wide constants
- Models folder: Data transfer objects
- DataAccess folder: Database interaction classes
- JScripts folder: Client-side functionality
- Styles folder: CSS styling

For questions about these guidelines or clarification on specific patterns, consult with the development team lead or architect.