@workspace

Please perform a full code review of this Flutter (Dart) project with Firebase backend. This is Project Atlas - a gamified study tracking mobile application with authentication, user profiles, and study management features.

**Tech Stack**: Flutter 3.29.0, Dart 3.7.0, Firebase (Auth & Firestore), Riverpod state management, Google Fonts

Analyze the entire codebase to grasp the full context and suggest architectural improvements. For each of the categories below, identify issues and document them in separate Markdown files under `/docs/`:

## Analysis Categories

1. **Code Hygiene** (unused code, duplications, nesting, complex methods, null-safety, naming consistency)
2. **Architecture** (layering, stateful misuse, separation of concerns, coupling)
3. **Performance** (build cost, list optimization, async usage, state management)
4. **Redundancy** (duplicated features, over-abstraction, YAGNI violations)
5. **Consistency** (folder/naming conventions, formatting, documentation, outdated patterns)

## Required Documentation Files

Generate the following Markdown files with clear headings, bullet points, tables, and ```dart code blocks:

### 1. `/docs/project_overview.md`
- App purpose, tech stack (Flutter, Firebase, etc.), high-level architecture
- Main user flows and authentication system
- Current development status and feature roadmap
- Key components and their relationships

### 2. `/docs/feature_map.md` 
- List each screen/page or feature, its function, and key related components/services
- Navigation flow between screens
- Authentication flows and user state management
- Planned vs implemented features

### 3. `/docs/file_summary.md`
- For each source file, brief description of contents and role
- Organize by directory structure (lib/, widgets/, screens/, services/, etc.)
- Dependencies and relationships between files
- Generated files (.g.dart, .freezed.dart) purposes

### 4. `/docs/code_issues_report.md`
For each category, list issues found, file locations, impact, and suggested fixes with code snippets:

- **Code Hygiene**: unused imports/variables, duplicate code, deeply nested widgets, overly long methods, null-safety gaps, inconsistent naming (classes use UpperCamelCase, methods use lowerCamelCase, files use lowercase_with_underscores)
- **Architecture**: logic in UI vs controllers, overuse of StatefulWidget, tight coupling, missing separation of concerns
- **Performance**: expensive build() operations, unoptimized ListViews, async issues like unawaited Futures, "setState after dispose" errors
- **Redundancy/Over-engineering**: multiple implementations of same logic, overly abstract patterns, unnecessary complexity
- **Consistency**: folder/file naming issues, formatting problems, missing doc comments (/// style), deprecated APIs

### 5. `/docs/architecture_analysis.md`
- Component hierarchy and data flow assessment
- Separation of concerns improvements (move logic out of widgets)
- State management optimization recommendations
- Widget reuse and composition patterns
- SOLID/Clean Architecture principles application
- Scalability considerations

### 6. `/docs/performance_optimization.md`
- Build() method optimization strategies
- Widget rebuild minimization techniques
- ListView and scrolling performance improvements
- Async/await pattern optimizations
- Memory usage and resource management
- State management performance considerations

### 7. `/docs/security_analysis.md`
- Firebase security rules assessment
- Authentication flow security review
- Data validation and sanitization
- User input handling security
- API endpoint protection
- Privacy and data protection compliance

### 8. `/docs/testing_strategy.md`
- Unit testing recommendations for providers and services
- Widget testing patterns for UI components
- Integration testing strategy for user flows
- Mock data and test setup guidelines
- CI/CD testing pipeline recommendations
- Test coverage analysis and goals

### 9. `/docs/refactoring_plan.md`
- Priority-ordered refactoring recommendations
- Step-by-step implementation guides
- Risk assessment for each refactoring
- Timeline and effort estimates
- Dependencies between refactoring tasks
- Rollback strategies

### 10. `/docs/dependency_analysis.md`
- Current package dependencies review
- Outdated or vulnerable package identification
- Package optimization opportunities
- Build vs buy analysis for custom components
- License compliance review
- Dependency update recommendations

### 11. `/docs/deployment_guide.md`
- Build configuration for different environments
- Firebase deployment setup and security
- App store release process and requirements
- Environment variable management
- Version control and release branching
- Rollback and disaster recovery procedures

### 12. `/docs/maintenance_guidelines.md`
- Code maintenance best practices
- Regular dependency update procedures
- Performance monitoring setup
- Error tracking and logging strategies
- Documentation update workflows
- Technical debt management

### 13. `/docs/api_documentation.md`
- Firebase Firestore collections and document structures
- Authentication API usage patterns
- Data model documentation (UserModel, AuthState, etc.)
- Error handling patterns and exception types
- Service layer API contracts
- Future API integration guidelines

### 14. `/docs/ui_component_library.md`
- Custom widget documentation and usage
- Design system implementation (AppColors, AppTheme)
- Component reusability guidelines
- Animation and interaction patterns
- Responsive design considerations
- Accessibility implementation

### 15. `/docs/PROJECT_SPEC.md`
Record key decisions for persistent agent memory:
- Naming conventions and coding standards
- Architecture choices and patterns
- Folder structure rationale
- State management approach (Riverpod patterns)
- Firebase integration patterns
- UI/UX design decisions
- Testing standards and approaches
- Development workflow guidelines

### 16. `/docs/code_quality_metrics.md`
- Cyclomatic complexity analysis for methods and classes
- Code coverage assessment and improvement recommendations
- Technical debt quantification and prioritization
- Code duplication percentage and hotspots identification
- Maintainability index calculation and trends
- Static analysis results and lint rule compliance
- Code review checklist and quality gates
- Automated quality monitoring setup

### 17. `/docs/critical_issues_remediation.md`
- Production-blocking issues identification and immediate fixes
- Deprecated API usage audit (withOpacity, textScaleFactor, ColorScheme)
- Security vulnerabilities assessment and patches
- Performance bottlenecks and optimization priorities
- Memory leaks and resource management issues
- Crash-prone code patterns and stabilization
- Data integrity and validation gaps
- Emergency hotfix procedures and rollback plans

### 18. `/docs/development_roadmap.md`
- Feature development timeline and milestones
- Technical debt reduction schedule
- Architecture evolution phases
- Package upgrade and migration plans
- Platform-specific implementation roadmap (iOS/Android)
- Integration testing expansion strategy
- Performance optimization phases
- Production readiness checklist and timeline

### 19. `/docs/state_management_deep_dive.md`
- Riverpod provider hierarchy and data flow analysis
- State mutation patterns and immutability enforcement
- Provider scope and lifecycle management
- State persistence and restoration strategies
- Cross-widget communication patterns
- State debugging and development tools
- Performance implications of state management choices
- Migration strategies from other state management solutions

### 20. `/docs/error_handling_strategy.md`
- Comprehensive error taxonomy and classification
- Exception handling patterns throughout the application
- User-facing error message standardization
- Logging and crash reporting implementation
- Error recovery and graceful degradation strategies
- Firebase error handling and retry mechanisms
- Network failure handling and offline capabilities
- Debug vs production error handling differences

## Formatting Requirements

- Use clear Markdown structure with proper headings (##, ###, ####)
- Include bullet points and numbered lists for organization
- Create tables for structured data comparison when helpful
- Use fenced code blocks with ```dart for all Dart/Flutter snippets
- Reference specific file paths and line numbers for issues
- Provide "before" and "after" code examples for refactoring suggestions
- Include priority levels (Critical/High/Medium/Low) for all recommendations

## Specific Analysis Instructions

**Code Hygiene Checks:**
- Flag unused imports, variables, functions (Dart linter catches unused variables)
- Identify copy-pasted or redundant code that can lead to inconsistencies and bugs
- Find deeply nested widgets that are harder to read - recommend breaking up large build() methods into smaller widgets
- Highlight overly large functions and suggest splitting them
- Check proper handling of Dart's null-safety (late, null checks)
- Enforce Dart naming style consistency throughout project

**Architecture Review:**
- Verify clear UI/business/data layering - widgets should only handle UI, business logic in separate services/controllers
- Minimize unnecessary StatefulWidget usage for better performance and simpler code
- Ensure single responsibility - flag widgets that both fetch data and render UI
- Look for tightly coupled components and suggest using providers/repository patterns

**Performance Analysis:**
- Avoid heavy work in build() methods - flag expensive operations and suggest const constructors
- Identify setState() misuse that rebuilds large trees unnecessarily
- Check for ListView optimization opportunities (use ListView.builder for large lists)
- Verify all async calls are properly awaited and handled to prevent "setState after dispose" errors

**Redundancy Detection:**
- Find features implemented multiple ways and recommend single consistent approaches
- Identify over-abstraction with unnecessary indirection layers
- Flag dead code paths or unused features (YAGNI violations)
- Ensure consistent Firebase access patterns throughout app

**Consistency Verification:**
- Check folder/file structure follows logical organization with consistent naming
- Verify Dart formatting compliance and lint satisfaction
- Flag missing /// documentation comments on public APIs
- Identify deprecated Flutter/Dart APIs and suggest modern alternatives

Please ensure all output uses proper Markdown formatting with syntax-highlighted code blocks. Perform complete analysis in this single prompt and output all 20 files above with their full contents. Be specific with file locations, line numbers, and actionable recommendations.

## Additional Analysis Requirements for New Files

**Code Quality Metrics Analysis:**
- Calculate and report cyclomatic complexity for all methods over 10 complexity points
- Identify code duplication hotspots using similarity analysis
- Generate technical debt heat map with specific remediation priorities
- Assess test coverage gaps and provide improvement roadmap
- Create maintainability scoring system for critical components

**Critical Issues Remediation Focus:**
- Prioritize production-blocking issues by severity and business impact
- Provide immediate fix recommendations with code examples
- Document emergency response procedures for critical failures
- Create rollback strategies for high-risk changes
- Establish monitoring and alerting for critical code paths

**Development Roadmap Planning:**
- Break down feature development into sprint-sized deliverables
- Map dependencies between architectural improvements and new features
- Establish clear acceptance criteria for each roadmap milestone
- Include resource allocation and timeline estimates
- Plan for parallel development tracks and integration points

**State Management Deep Analysis:**
- Trace complete data flow from UI actions to Firebase and back
- Identify state management anti-patterns and provide corrections
- Document provider optimization opportunities
- Analyze state persistence requirements for offline capabilities
- Map out testing strategies for complex state interactions

**Error Handling Strategy Development:**
- Create comprehensive error classification system
- Document user experience for each error scenario
- Establish logging standards and crash reporting integration
- Plan graceful degradation strategies for network failures
- Design error recovery workflows and user guidance
