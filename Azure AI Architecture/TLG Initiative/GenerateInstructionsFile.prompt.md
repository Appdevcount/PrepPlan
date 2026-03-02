
**TASK:** Analyze this codebase and create a comprehensive `instruction.md` file that will guide AI assistants (like Devin, Cursor, GitHub Copilot, etc.) to write code following this project's best practices, conventions, and architecture patterns.

**INSTRUCTIONS:**

1. **Analyze the codebase thoroughly** by examining:
   - Project structure and directory organization
   - Existing code files (at least 10-15 representative files)
   - Configuration files (package.json, pom.xml, .csproj, pyproject.toml, etc.)
   - Build and deployment scripts
   - Testing files and test structure
   - Documentation (README.md, CONTRIBUTING.md, etc.)
   - CI/CD configurations (.github/workflows, Jenkinsfile, etc.)

2. **Create an `instructions.md` file** in the root directory with the following sections:

## Section 1: Project Overview
- Project name and purpose
- Technology stack (languages, frameworks, libraries)
- Project type (frontend, backend, fullstack, library, etc.)
- Target deployment environment

## Section 2: Architecture & Design Patterns
- Overall architecture pattern (MVC, MVVM, Clean Architecture, Microservices, etc.)
- Key design patterns used in the codebase
- Project layer structure (data layer, business layer, presentation layer, etc.)
- Module/component organization
- Dependency injection approach (if applicable)

## Section 3: Code Structure & Organization
- Directory structure explanation
- File naming conventions
- Module/namespace organization
- Where to place new files of different types
- Separation of concerns guidelines

## Section 4: Coding Conventions & Style
- Language-specific style guide followed (if any)
- Indentation and formatting rules
- Naming conventions:
  - Classes/Interfaces
  - Methods/Functions
  - Variables/Properties
  - Constants
  - Files/Directories
- Comment style and documentation requirements
- Line length limits
- Import/using statement organization

## Section 5: Language & Framework Best Practices
### For C#/.NET projects:
- LINQ usage patterns
- Async/await conventions
- Exception handling approach
- Dependency injection (built-in DI, Autofac, etc.)
- Entity Framework usage patterns
- API versioning approach


### For TypeScript/JavaScript projects:
- TypeScript usage (strict mode, interfaces, types)
- Promise/async-await patterns
- Error handling approach
- State management (Redux, Zustand, Context API, etc.)
- Component structure (React/Angular/Vue specific)
- Hook usage patterns (React)
- Service/dependency injection patterns (Angular)

### For Python projects:
- Type hints usage
- Async patterns (if used)
- Error handling conventions
- Virtual environment setup
- Package management (pip, poetry, etc.)

## Section 6: Dependencies & Libraries
- Core dependencies and their purpose
- Approved libraries for common tasks:
  - HTTP requests
  - Date/time handling
  - Logging
  - Testing
  - Validation
  - Authentication
- Libraries to avoid
- How to add new dependencies (approval process, where to add)

## Section 7: API & Data Handling
- API endpoint structure and naming
- Request/response patterns
- DTO/model conventions
- Validation approach
- Error response format
- Authentication/authorization patterns
- API documentation approach (Swagger, OpenAPI, etc.)

## Section 8: Database & Data Access
- Database technology used
- ORM/data access pattern
- Entity/model definitions
- Migration approach
- Query patterns and best practices
- Transaction management
- Connection handling

## Section 9: Testing Standards
- Testing frameworks used
- Test file location and naming
- Unit test conventions
- Integration test approach
- Test coverage requirements
- Mocking/stubbing patterns
- Test data management
- What should be tested (business logic, edge cases, etc.)

## Section 10: Error Handling & Logging
- Exception handling strategy
- Custom exception types
- Error propagation patterns
- Logging framework and configuration
- Log levels usage (DEBUG, INFO, WARN, ERROR)
- What to log and what not to log
- Sensitive data handling in logs

## Section 11: Security Best Practices
- Authentication mechanism
- Authorization approach
- Secret/credential management
- Input validation and sanitization
- SQL injection prevention
- XSS prevention (for web apps)
- CORS configuration
- Security headers

## Section 12: Performance Considerations
- Caching strategies
- Database query optimization patterns
- Async operation usage
- Resource cleanup patterns
- Memory management considerations
- Performance monitoring approach

## Section 13: Configuration Management
- Environment variable usage
- Configuration file structure (.env, appsettings.json, application.properties, etc.)
- Environment-specific configurations
- Feature flags approach (if used)

## Section 14: Build & Deployment
- Build commands and scripts
- Environment setup requirements
- Pre-deployment checklist
- Deployment process
- CI/CD pipeline overview
- Version numbering scheme

## Section 15: Git & Version Control
- Branch naming conventions
- Commit message format
- PR/MR requirements
- Code review checklist
- What should not be committed

## Section 16: Common Patterns & Examples
- Provide 2-3 code examples of common patterns in the project:
  - Creating a new API endpoint
  - Adding a new service/component
  - Database query example
  - Error handling example
  - Test writing example

## Section 17: Do's and Don'ts
### DO:
- List 10-15 things developers SHOULD do

### DON'T:
- List 10-15 things developers SHOULD NOT do

## Section 18: Code Review Checklist
- What reviewers should check
- Common mistakes to watch for
- Quality gates that must be met

## Section 19: Troubleshooting & Common Issues
- Common setup issues and solutions
- Frequent bugs and how to fix them
- Debugging tips specific to this project

## Section 20: Additional Resources
- Links to relevant documentation
- Team contacts or Slack channels
- Related repositories
- External resources (framework docs, style guides, etc.)

---

**OUTPUT FORMAT:**
- Create the file as `copilot-instructions.md` in the project root (`\github\copilot-instructions.md`)
- Use clear Markdown formatting
- Include code examples where helpful
- Be specific and concrete (not generic advice)
- If something doesn't apply to this project, skip that section
- Prioritize patterns that appear multiple times in the codebase
- Include actual file paths and line numbers as examples where relevant

**IMPORTANT:**
- Base everything on ACTUAL code analysis, not assumptions
- If a pattern is used inconsistently, note both approaches and recommend the preferred one
- Focus on what makes THIS project unique, not generic best practices
- Make it actionable - AI assistants should be able to follow this to write code that fits seamlessly

**START ANALYSIS NOW** and create the `github\copilot-instructions.md` file.
