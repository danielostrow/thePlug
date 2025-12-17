# Changelog

All notable changes to Code Health will be documented in this file.

## [1.0.0] - 2024-12-17

### Added

#### Agents
- **security-scanner**: Detects hardcoded secrets, OWASP vulnerability patterns, and dependency CVEs
- **debt-analyzer**: Analyzes code complexity, identifies code smells, tracks TODO comments with age
- **dependency-auditor**: Audits packages for updates, license issues, and security vulnerabilities
- **refactoring-assistant**: Applies safe auto-fixes and guides complex refactoring operations

#### Commands
- `/code-health:scan`: Full codebase health scan with quick and deep modes
- `/code-health:security`: Security-focused vulnerability analysis
- `/code-health:debt`: Technical debt and code quality analysis
- `/code-health:deps`: Dependency audit for updates, CVEs, and licenses
- `/code-health:fix`: Auto-fix common issues with dry-run support
- `/code-health:report`: Generate detailed reports in markdown, HTML, or JSON

#### Skills
- **Security Patterns**: OWASP detection patterns, secret detection regex, CVE database integration
- **Code Quality**: Complexity metrics, code smell catalog, dead code detection patterns
- **Refactoring Strategies**: Safe refactoring patterns, auto-fix templates, extraction techniques

#### Features
- Health score calculation with A-F grading
- Quick scan mode for fast overview
- Deep scan mode for comprehensive analysis
- Language-agnostic analysis supporting JS/TS, Python, Go, Rust, and more
- Git blame integration for TODO/FIXME age tracking
- Native package manager audit integration
